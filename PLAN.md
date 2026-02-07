# 🎰 Restaurant Roulette - Entwicklungsplan

## 📱 Projektübersicht
Cross-Plattform App (iOS/Android) zur zufälligen Restaurantwahl mit Hybrid-API Strategie.

## 🗓️ Phase 1: Projekt-Setup & Architektur (Tag 1-2)
- [ ] Flutter Projekt initialisieren (Material 3).
- [ ] State Management aufsetzen (**Riverpod** empfohlen für saubere Kapselung von API & Auth).
- [ ] Firebase Integration:
    - [ ] Firebase Console Projekt erstellen.
    - [ ] `flutterfire configure`.
    - [ ] Auth (Email/Google).
    - [ ] Firestore DB Design (Collections: `users`, `history`, `favorites`).
- [ ] Navigation einrichten (GoRouter oder Go_Router).

## 🌍 Phase 2: Location & API Layer (Tag 3-4)
- [ ] `ApiService` implementieren (Hybrid-Logik).
    - [ ] **Geoapify** Integration (Standard).
    - [ ] **Google Places** Integration (Fallback/Premium).
    - [ ] Weichen-Logik implementieren (Filter-Check).
- [ ] Caching Layer: `PlaceCacheService` (verhindert API-Kosten bei Re-Rolls).
- [ ] Geolocator Integration (Permission Handling).

## 🎨 Phase 3: Core UI & Roulette (Tag 5-7)
- [ ] Main Screen Layout.
- [ ] **AdMob** Banner Integration (Platzhalter unten fixieren!).
- [ ] **Roulette Animation**:
    - [ ] Integration `flutter_fortune_wheel`.
    - [ ] StreamController für Spin-Logik.
    - [ ] Visuelles Feedback bei Gewinner-Ermittlung.

## 💾 Phase 4: User Data & History (Tag 8-9)
- [ ] Firestore Service.
- [ ] History-Logik:
    - [ ] Nach jedem "Spin" -> Save to Firestore.
    - [ ] Beim Laden neuer Restaurants: Check gegen `last_10` History -> rausfiltern.
- [ ] Favoriten-Toggle.

## 🚀 Phase 5: Polish & Release (Tag 10)
- [ ] Error Handling (Kein GPS, Keine API Antwort).
- [ ] Splash Screen.
- [ ] App Icon.
- [ ] Release Builds.

## 🏗️ Architektur-Entscheidung
Wir nutzen **Riverpod** für Dependency Injection und State Management.
- `apiProvider`: Liefert je nach State den Geoapify oder Google Client.
- `rouletteProvider`: Hält den aktuellen List-State der Restaurants.
