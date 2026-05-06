// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Restaurant Roulette';

  @override
  String get loginWelcome => 'Willkommen bei\nRestaurant Roulette!';

  @override
  String get loginWithGoogle => 'Mit Google anmelden';

  @override
  String get searchRestaurants => 'Restaurant suchen';

  @override
  String get chooseYourFate => 'Wähle dein Schicksal!';

  @override
  String get spin => 'SPIN';

  @override
  String get winner => '🎉 GEWINNER 🎉';

  @override
  String get startRoute => 'ROUTE STARTEN';

  @override
  String get alreadyVisited => 'Bereits besucht';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get spinAgain => 'Nochmal drehen';

  @override
  String get newSearch => 'Neue Suche starten';

  @override
  String get errorLocationServicesDisabled =>
      'Standortdienste sind deaktiviert.';

  @override
  String get errorLocationPermissionDenied =>
      'Standortberechtigung verweigert.';

  @override
  String get errorLocationPermissionForeverDenied =>
      'Standortberechtigung dauerhaft verweigert.';

  @override
  String get errorNoLocation => 'Kein Standort ausgewählt.';

  @override
  String get errorNoRestaurantsFound => 'Keine Restaurants gefunden.';

  @override
  String get errorNoRestaurantsFoundExcludingVisited =>
      'Keine Restaurants gefunden. (Besuchte ausgeblendet)';

  @override
  String get errorApiUnknown => 'Unbekannter Fehler bei der Abfrage.';

  @override
  String get errorGeneric => 'Ein Fehler ist aufgetreten.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileVisited => 'Besuchte Restaurants';

  @override
  String get profileNotifications => 'Benachrichtigungen';

  @override
  String get profilePrivacy => 'Datenschutz';

  @override
  String get profileImprint => 'Impressum';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterClose => 'Schließen';

  @override
  String get filterRadiusTitle => 'Suchradius';

  @override
  String get filterRadiusSubtitle =>
      'Wie weit darf das Restaurant entfernt sein?';

  @override
  String filterRadiusValue(String km) {
    return '$km km';
  }

  @override
  String get filterPlaceTypeTitle => 'Lokal-Typ';

  @override
  String get filterPlaceTypeSubtitle =>
      'Wonach suchst du? Mehrfachauswahl möglich.';

  @override
  String get filterCuisineTitle => 'Küche';

  @override
  String get filterCuisineSubtitle =>
      'Schränkt die Auswahl auf Restaurants mit dieser Küche ein. Greift nur, wenn „Restaurant\" als Lokal-Typ aktiv ist.';

  @override
  String get filterCuisineHint =>
      'Aktiviere „Restaurant\" oben, damit Küchen-Filter wirken.';

  @override
  String get filterDietTitle => 'Ernährung';

  @override
  String get filterDietSubtitle =>
      'Zeigt nur Lokale, die diese Optionen anbieten.';

  @override
  String get filterDietVegan => 'Vegan verfügbar';

  @override
  String get filterDietVegetarian => 'Vegetarisch verfügbar';

  @override
  String get filterComfortTitle => 'Komfort';

  @override
  String get filterComfortSubtitle =>
      'Ausstattung & Zugänglichkeit, sofern in OSM erfasst.';

  @override
  String get filterComfortWheelchair => 'Rollstuhl-zugänglich';

  @override
  String get filterMiscTitle => 'Sonstiges';

  @override
  String get filterMiscSubtitle => 'Verfeinere das Roulette-Ergebnis.';

  @override
  String get filterMiscExcludeVisited => 'Besuchte ausblenden';

  @override
  String get filterMiscExcludeVisitedSubtitle =>
      'Bereits besuchte Orte ausschließen';

  @override
  String get filterOsmHeader => 'Datenquelle: OpenStreetMap';

  @override
  String get filterOsmDescription =>
      'Restaurants & Filter-Eigenschaften (Vegan, Rollstuhl …) stammen aus der freien OSM-Datenbank — gepflegt von Freiwilligen. Daten sind nicht zu 100 % vollständig oder aktuell.';

  @override
  String get filterOsmContribute =>
      'Fehlt was? Selbst eintragen auf openstreetmap.org';

  @override
  String get placeTypeRestaurant => 'Restaurant';

  @override
  String get placeTypeFastFood => 'Fast Food';

  @override
  String get placeTypeCafe => 'Café';

  @override
  String get placeTypeBar => 'Bar';

  @override
  String get placeTypePub => 'Pub';

  @override
  String get placeTypeBiergarten => 'Biergarten';

  @override
  String get placeTypeIceCream => 'Eisdiele';

  @override
  String get cuisineItalian => 'Italienisch';

  @override
  String get cuisinePizza => 'Pizza';

  @override
  String get cuisinePasta => 'Pasta';

  @override
  String get cuisineAsian => 'Asiatisch';

  @override
  String get cuisineChinese => 'Chinesisch';

  @override
  String get cuisineJapanese => 'Japanisch';

  @override
  String get cuisineSushi => 'Sushi';

  @override
  String get cuisineKorean => 'Koreanisch';

  @override
  String get cuisineThai => 'Thailändisch';

  @override
  String get cuisineVietnamese => 'Vietnamesisch';

  @override
  String get cuisineIndian => 'Indisch';

  @override
  String get cuisineTurkish => 'Türkisch';

  @override
  String get cuisineKebab => 'Kebab';

  @override
  String get cuisineGreek => 'Griechisch';

  @override
  String get cuisineFrench => 'Französisch';

  @override
  String get cuisineGerman => 'Deutsch';

  @override
  String get cuisineRegional => 'Regional';

  @override
  String get cuisineMexican => 'Mexikanisch';

  @override
  String get cuisineAmerican => 'Amerikanisch';

  @override
  String get cuisineBurger => 'Burger';

  @override
  String get cuisineSteakhouse => 'Steakhouse';

  @override
  String get cuisineBarbecue => 'Barbecue';

  @override
  String get cuisineFishAndChips => 'Fish & Chips';

  @override
  String get cuisineSeafood => 'Seafood';

  @override
  String get cuisineNoodle => 'Nudeln';

  @override
  String get visitedTitle => 'Besuchte Restaurants';

  @override
  String get visitedEmpty => 'Noch keine Restaurants besucht.';

  @override
  String visitedError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get visitedRateChange => 'Bewertung ändern';

  @override
  String get visitedRateNew => 'Jetzt bewerten';

  @override
  String get visitedNotRated => 'Noch nicht bewertet';

  @override
  String get visitedReVisit => 'Erneut besuchen';

  @override
  String get visitedReVisitSubtitle => 'Route in Google Maps öffnen';

  @override
  String get rateButton => 'Bewerten';

  @override
  String get sortNewest => 'Neueste';

  @override
  String get sortOldest => 'Älteste';

  @override
  String get sortBest => 'Beste';

  @override
  String get sortWorst => 'Schlechteste';

  @override
  String get sortUnrated => 'Unbewertet';

  @override
  String get sortMostVisited => 'Meist besucht';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationsToggleTitle => 'Benachrichtigungen erhalten';

  @override
  String get notificationsToggleSubtitle =>
      'Erinnerungen zur Bewertung nach Restaurantbesuchen';

  @override
  String notificationRatingTitle(String name) {
    return 'Wie war es bei $name?';
  }

  @override
  String get notificationRatingBody => 'Bewerte jetzt deinen Besuch!';

  @override
  String get notificationRatingChannelName => 'Bewertungen';

  @override
  String get notificationRatingChannelDescription =>
      'Erinnerung zur Bewertung von Restaurantbesuchen';

  @override
  String get ratingSave => 'Bewertung speichern';

  @override
  String ratingVisitedOn(String date) {
    return 'Besucht am: $date';
  }

  @override
  String get loadingSearch => 'Suche Restaurants...';

  @override
  String get loadingSlow =>
      'Einen Moment Geduld, die Suche dauert etwas länger.';

  @override
  String get restaurantUnknownName => 'Unbekanntes Restaurant';

  @override
  String get restaurantNoAddress => 'Keine Adresse verfügbar';
}
