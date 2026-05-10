# Architektur-Refactor Plan — RestaurantRoulet

> **Ziel:** Eine einheitliche, modulare Architektur, in der Funktionen und UI unabhängig voneinander erweitert oder ausgetauscht werden können. Refactor läuft **phasenweise und behavior-preserving** — die App bleibt nach jeder Phase voll funktionsfähig.

---

## 1. Ausgangslage (Stand Audit)

3.067 Zeilen Dart in 18 Dateien unter `lib/`. Hauptprobleme:

| Datei | LoC | Problem |
|---|---|---|
| `lib/screens/home_screen.dart` | 896 | Vermischt UI, Map, Filter, Profil, Dialoge, DB-Aufrufe, URL-Launching, Notification-Lookup |
| `lib/screens/visited_restaurants_screen.dart` | 531 | UI + Sortierung + DB-Zugriff + ActionSheet + RatingDialog in einer Klasse |
| `lib/providers/roulette_provider.dart` | 299 | State-Notifier macht **Side-Effects** (`launchUrl`, Notification-Scheduling) — gehört nicht in einen State-Notifier |
| Inline-Services | überall | `DatabaseService()` / `NotificationService()` werden in 5 verschiedenen Stellen direkt instanziiert → bricht die Singleton-Annahme, macht Mocking unmöglich |
| Hardcoded Strings | ~80–100 | Alle deutschen UI-Texte verteilt in Screens/Widgets/Provider/Service |
| Hardcoded Secrets | 3 Stellen | Supabase-URL+anonKey (`main.dart`), Geoapify-Key (`config/api_keys.dart`), Google-Web-Client-ID (`auth_service.dart`) |
| Routing | imperativ | Direkte `Navigator.push`-Calls verteilt; kein Auth-Guard, kein Deep-Linking |
| Code-Duplizierung | 2–3× | Sterne-Rendering, Action-Sheets, Error-Panels, Rating-Dialog jeweils mehrfach implementiert |

---

## 2. Zielarchitektur — Feature-First mit klaren Schichten

### 2.1 Ordnerstruktur

```
lib/
├── main.dart                          # nur Bootstrap (~30 LoC)
│
├── app/                               # App-weite Konfiguration
│   ├── app.dart                       # MaterialApp.router + ProviderScope
│   ├── bootstrap.dart                 # Supabase + Notifications init
│   ├── router.dart                    # go_router config + Auth-Guard
│   └── theme.dart                     # Colors, ButtonTheme, etc.
│
├── core/                              # Wirklich übergreifend, NICHT feature-spezifisch
│   ├── config/
│   │   └── env.dart                   # liest --dart-define
│   ├── localization/
│   │   ├── l10n/                      # de.arb, en.arb (stub)
│   │   └── app_localizations.dart    # generated
│   ├── models/
│   │   └── restaurant.dart            # geteiltes Datenmodell
│   ├── services/
│   │   └── link_launcher_service.dart # Wrapper um url_launcher
│   └── widgets/                       # generische, feature-übergreifende Widgets
│       ├── star_rating.dart           # ersetzt _RatingBadge + Sterne in RatingPopup
│       ├── app_action_sheet.dart      # generischer ActionSheet-Builder
│       └── app_error_panel.dart       # einheitliche Error-Card
│
└── features/                          # jedes Feature ist self-contained
    ├── auth/
    │   ├── data/
    │   │   └── auth_service.dart
    │   ├── application/
    │   │   └── auth_providers.dart    # authServiceProvider, authStateProvider
    │   └── presentation/
    │       └── pages/login_page.dart
    │
    ├── roulette/                      # Hauptfeature: Suche + Wheel + Map
    │   ├── data/
    │   │   ├── api_service.dart       # Geoapify
    │   │   └── search_filters.dart    # SearchFilters + GeocodingResult
    │   ├── application/
    │   │   ├── roulette_state.dart    # State-Klasse (immutable)
    │   │   ├── roulette_notifier.dart # NUR State-Mutation, keine Side-Effects
    │   │   └── location_controller.dart  # GPS-Logik raus aus Notifier
    │   └── presentation/
    │       ├── pages/home_page.dart   # ~150 LoC, nur Stack-Composer
    │       └── widgets/
    │           ├── map_layer.dart
    │           ├── search_button_panel.dart
    │           ├── profile_menu.dart
    │           ├── filter_panel.dart
    │           ├── manual_location_chip.dart
    │           ├── location_fallback_panel.dart
    │           ├── roulette_overlay.dart
    │           ├── winner_card.dart
    │           ├── control_buttons.dart
    │           └── address_search_dialog.dart
    │
    ├── visited/                       # History
    │   ├── data/
    │   │   └── visited_repository.dart  # umbenannt aus DatabaseService (visit-spezifisch)
    │   ├── application/
    │   │   ├── visited_providers.dart
    │   │   └── visited_sort.dart        # SortOption + Sortier-Funktion
    │   └── presentation/
    │       ├── pages/visited_page.dart
    │       └── widgets/
    │           ├── sort_chip_row.dart
    │           ├── visited_list_tile.dart
    │           ├── rate_button.dart
    │           └── visited_action_sheet.dart
    │
    ├── rating/                        # cross-feature: Restaurants bewerten
    │   ├── application/rating_providers.dart
    │   └── presentation/widgets/rating_popup.dart
    │
    ├── reservation/                   # bereits modular — bleibt
    │   ├── data/reservation_service.dart
    │   └── presentation/widgets/reservation_button.dart
    │
    └── notifications/
        ├── data/notification_service.dart
        └── presentation/pages/notification_settings_page.dart
```

### 2.2 Schicht-Verträge (was darf wo)

| Schicht | Darf | Darf NICHT |
|---|---|---|
| **`data/`** | I/O (HTTP, Supabase, SharedPrefs, url_launcher), DTO-Mapping | UI bauen, Riverpod-State halten, andere Features importieren |
| **`application/`** | Riverpod Provider/Notifier, State-Klassen, reine Berechnung | `launchUrl`, `showDialog`, `Navigator.push`, `BuildContext` anfassen |
| **`presentation/`** | Widgets, Pages, Side-Effects via `ref.read`, Navigation | Direkte HTTP-/DB-Calls, Business-Regeln duplizieren |
| **`core/`** | Generisch, von ≥ 2 Features genutzt | Feature-spezifische Logik, Imports aus `features/` |

**Goldene Regel:** Ein Feature darf `core/` importieren, aber **niemals ein anderes Feature**. Wenn zwei Features etwas teilen, wandert es nach `core/` oder ein neues Cross-Feature wird gebaut (siehe `rating/`).

### 2.3 Datei-Größen-Budget (Konvention)

- Pages: **max ~200 LoC** — sonst weiter splitten
- Widgets / Notifier / Services: **max ~200 LoC**
- State-Klassen: **max ~100 LoC**
- Wenn überschritten → Sub-Widgets extrahieren oder Verantwortung trennen

---

## 3. Schlüssel-Design-Entscheidungen

### 3.1 Side-Effects raus aus dem Notifier
`RouletteNotifier.launchGoogleMaps()` macht aktuell zwei Dinge: State ändern (`markAsVisited`) **und** `launchUrl`. Neue Aufteilung:

- **Notifier:** `markAsVisited(restaurant)` — nur State + DB.
- **Widget:** ruft `markAsVisited` ab und triggert dann `LinkLauncherService.openMaps(restaurant)` direkt.

Das macht den Notifier testbar (kein url_launcher-Mock nötig) und entkoppelt UI-Verhalten von State.

### 3.2 Routing mit `go_router`
- Routen: `/login`, `/`, `/visited`, `/notifications/settings`
- **Auth-Guard** als `redirect`-Funktion auf Basis von `authStateProvider`
- Ersetzt `AuthWrapper` und alle imperativen `Navigator.push`-Calls
- Deep-Linking-fähig (z. B. `/visited/<id>` für späteres Rating-Notification-Tap)

### 3.3 DI: alle Services über Riverpod
Aktuell mischen sich Provider-DI und inline `DatabaseService()`. Ziel:

| Service | Provider |
|---|---|
| `ApiService` | `apiServiceProvider` (existiert) |
| `AuthService` | `authServiceProvider` (existiert) |
| `VisitedRepository` (ex DatabaseService) | `visitedRepositoryProvider` (NEU) |
| `NotificationService` | `notificationServiceProvider` (NEU) |
| `ReservationService` | `reservationServiceProvider` (NEU, statt `const` inline) |
| `LinkLauncherService` | `linkLauncherServiceProvider` (NEU) |

Dann: `ref.read(visitedRepositoryProvider).getVisited()` — überall gleich, mockbar via `ProviderScope.overrides`.

### 3.4 i18n via `flutter_localizations` + `.arb`
- `pubspec.yaml`: `flutter_localizations` + `intl` aktivieren
- `l10n.yaml` im Repo-Root
- `lib/core/localization/l10n/intl_de.arb` (Default) + `intl_en.arb` (Stub für später)
- Alle ~80–100 hardcoded Strings phasenweise pro Feature migrieren

### 3.5 Secrets über `--dart-define`
- Kein zusätzliches Package (kein `flutter_dotenv`) — Standard-Mechanismus reicht
- `lib/core/config/env.dart`:
  ```dart
  class Env {
    static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    static const geoapifyKey = String.fromEnvironment('GEOAPIFY_KEY');
    static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  }
  ```
- `.vscode/launch.json` mit `--dart-define`-Args (Template einchecken, echte Werte in lokalem Override)
- `.env.example` als Doku, `.env` in `.gitignore`
- **Build-Befehl:** `flutter run --dart-define=SUPABASE_URL=… --dart-define=…`

---

## 4. Migrations-Phasen

Jede Phase ist **eigenständig mergebar**, App läuft nach jeder Phase normal.

### Phase 0 — Vorbereitung (1 Commit)
- `docs/ARCHITECTURE_PLAN.md` (dieses Dokument) einchecken
- Leere Ordner `lib/app/`, `lib/core/`, `lib/features/` anlegen mit `.gitkeep`
- `flutter analyze` muss clean sein (Baseline)
- **Acceptance:** Repo enthält neue Struktur, Build unverändert

### Phase 1 — App-Setup + Routing (1–2 Commits)
- `main.dart` zerlegen: Bootstrap → `app/bootstrap.dart`, Theme → `app/theme.dart`
- `pubspec.yaml`: `go_router` hinzufügen
- `app/router.dart` mit aktuellen 4 Routen + Auth-Redirect
- `MaterialApp` → `MaterialApp.router`
- `AuthWrapper` löschen (Logik in Router-Redirect)
- Bestehende `Navigator.push`-Aufrufe → `context.go(…)` / `context.push(…)`
- **Acceptance:** Login → Home → Visited → Notifications funktioniert via Router

### Phase 2 — Core extrahieren (1 Commit)
- `models/restaurant.dart` → `core/models/`
- Neues `core/widgets/star_rating.dart` (extrahiert aus `_RatingBadge` + Sterne in `RatingPopup`)
- Neues `core/widgets/app_action_sheet.dart`
- Neues `core/widgets/app_error_panel.dart`
- Neues `core/services/link_launcher_service.dart` mit Provider
- **Acceptance:** Beide Screens nutzen die neuen Komponenten, keine Doppel-Implementierung mehr

### Phase 3 — Feature `roulette/` aufbauen (2–3 Commits)
- `api_service.dart` + `SearchFilters` + `GeocodingResult` → `features/roulette/data/`
- `RouletteState` ausgliedern → `features/roulette/application/roulette_state.dart`
- `RouletteNotifier` → `features/roulette/application/roulette_notifier.dart` — **Side-Effects entfernen**:
  - `launchGoogleMaps` → nur noch `markAsVisited`; `launchUrl` macht Widget
  - `navigateToRestaurant` → Widget-Verantwortung
- GPS-Logik (`_determinePosition`) → `location_controller.dart`
- `home_screen.dart` (896 LoC) zerlegen in:
  - `home_page.dart` (~150 LoC, Stack-Composer)
  - 9–10 Sub-Widgets unter `presentation/widgets/`
- **Acceptance:** Home funktioniert wie vorher; jede Datei < 200 LoC; `flutter analyze` clean

### Phase 4 — Feature `visited/` aufbauen (1–2 Commits)
- DB-Methoden für Besuche aus `DatabaseService` → `features/visited/data/visited_repository.dart`
- `_SortOption` + `_sorted` → `features/visited/application/visited_sort.dart`
- `visited_restaurants_screen.dart` (531 LoC) zerlegen in:
  - `visited_page.dart` (~120 LoC)
  - `sort_chip_row.dart`, `visited_list_tile.dart`, `rate_button.dart`, `visited_action_sheet.dart`
- `_RatingBadge` löschen (durch `core/widgets/star_rating.dart` ersetzt)
- **Acceptance:** Visited-Screen funktioniert wie vorher; alle Dateien < 200 LoC

### Phase 5 — DI-Cleanup (1 Commit)
- `VisitedRepository`, `NotificationService`, `ReservationService`, `LinkLauncherService` als Riverpod-Provider
- Alle `DatabaseService()` / `NotificationService()` Inline-Instanziierungen ersetzen durch `ref.read(…Provider)`
- `RouletteNotifier`-Provider-Definition aufräumen
- **Acceptance:** Kein `new ServiceX()` mehr in `screens/` oder `widgets/`; alle Tests via `ProviderScope.overrides` mockbar

### Phase 6 — Secrets auslagern (1 Commit)
- `lib/core/config/env.dart` mit `String.fromEnvironment`
- Hardcoded Keys ersetzen in `bootstrap.dart`, `auth_service.dart`, `api_service.dart`
- `lib/config/api_keys.dart` löschen
- `.env.example` + `.vscode/launch.json` (Template ohne echte Keys)
- `README.md` um Build-Anleitung mit `--dart-define` ergänzen
- **Acceptance:** `git grep` findet keinen echten Key mehr; App startet mit korrekten dart-defines

### Phase 7 — i18n einführen (mehrere Commits, pro Feature 1)
- `flutter_localizations` + `intl` in `pubspec.yaml`
- `l10n.yaml` + `intl_de.arb` + `intl_en.arb` (Stub)
- `app/app.dart` mit `localizationsDelegates`
- Strings phasenweise migrieren — pro Feature 1 PR
- Reihenfolge: `roulette/` → `visited/` → `notifications/` → `auth/` → `core/`
- **Acceptance pro Feature:** Keine hardcoded deutschen Strings mehr in dem Feature; UI sieht identisch aus

---

## 5. Erweiterungs-Beispiele (so sieht "modular" in der Praxis aus)

| Aufgabe | Berührt nur | Berührt NICHT |
|---|---|---|
| Neue Reservierungs-Plattform OpenTable | `features/reservation/data/reservation_service.dart` | UI, anderer Service, anderes Feature |
| Filter "Preisklasse" hinzufügen | `roulette_state.dart` (1 Field), `roulette_notifier.dart` (1 Method), `filter_panel.dart` (1 Toggle) | API-Service-Schnittstelle, andere Widgets |
| Englische Sprache aktivieren | `intl_en.arb` befüllen | Code |
| Wheel-Animation ändern | `roulette_overlay.dart` / Wheel-Widget | Notifier, State, Repository |
| Visited-Liste exportieren | neuer Button im `visited_page.dart` + Methode in `visited_repository.dart` | roulette/, auth/, core/ |
| Tests für Notifier schreiben | `ProviderScope.overrides({visitedRepositoryProvider, apiServiceProvider})` | Echte Services anfassen |

---

## 6. Out of Scope (bewusst nicht im Plan)

- **Test-Coverage-Ausbau** — Architektur ist test-freundlich, aber Test-Scaffold wurde abgewählt
- **Backend-Änderungen** (Supabase-Schema, RPC, etc.)
- **Neue Features** (alles funktional unverändert)
- **Datenmodell-Erweiterungen** (`Restaurant` bleibt wie es ist)
- **Performance-Optimierungen**

---

## 7. Verifikation pro Phase

Nach jeder Phase manueller Smoke-Test:
1. `flutter pub get && flutter analyze` — clean
2. App startet
3. Login mit Google funktioniert
4. Home: Standort wird ermittelt, Filter setzbar, "Restaurant suchen" → Wheel → Gewinner
5. "ROUTE STARTEN" öffnet Google Maps (markiert als besucht)
6. "TISCH ÜBER THEFORK RESERVIEREN" öffnet TheFork
7. Visited-Screen: Liste lädt, Sortierung funktioniert, Rating-Dialog speichert
8. Notification-Settings öffnen
9. Logout funktioniert

---

## 8. Reihenfolge der Umsetzung — Empfehlung

1. **Phase 0** + **Phase 1** zusammen (Setup + Routing) — Fundament, danach erstmal pausieren und 1–2 Tage normalen Betrieb prüfen
2. **Phase 2** (Core-Widgets) — niedriges Risiko, hoher Aufräum-Effekt
3. **Phase 3** (roulette splitten) — größter Brocken, am meisten Wert
4. **Phase 4** (visited splitten) — analog
5. **Phase 5** (DI-Cleanup) — danach ist die App test-bereit
6. **Phase 6** (Secrets) — vor jedem öffentlichen Push wichtig
7. **Phase 7** (i18n) — kosmetisch, kann zuletzt

Phasen 1–5 sind die "Architektur-Phasen", 6+7 sind unabhängige Aufräum-Stränge und können parallel/dazwischen erfolgen.
