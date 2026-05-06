import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Restaurant Roulette'**
  String get appTitle;

  /// No description provided for @loginWelcome.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei\nRestaurant Roulette!'**
  String get loginWelcome;

  /// No description provided for @loginWithGoogle.
  ///
  /// In de, this message translates to:
  /// **'Mit Google anmelden'**
  String get loginWithGoogle;

  /// No description provided for @searchRestaurants.
  ///
  /// In de, this message translates to:
  /// **'Restaurant suchen'**
  String get searchRestaurants;

  /// No description provided for @chooseYourFate.
  ///
  /// In de, this message translates to:
  /// **'Wähle dein Schicksal!'**
  String get chooseYourFate;

  /// No description provided for @spin.
  ///
  /// In de, this message translates to:
  /// **'SPIN'**
  String get spin;

  /// No description provided for @winner.
  ///
  /// In de, this message translates to:
  /// **'🎉 GEWINNER 🎉'**
  String get winner;

  /// No description provided for @startRoute.
  ///
  /// In de, this message translates to:
  /// **'ROUTE STARTEN'**
  String get startRoute;

  /// No description provided for @alreadyVisited.
  ///
  /// In de, this message translates to:
  /// **'Bereits besucht'**
  String get alreadyVisited;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @spinAgain.
  ///
  /// In de, this message translates to:
  /// **'Nochmal drehen'**
  String get spinAgain;

  /// No description provided for @newSearch.
  ///
  /// In de, this message translates to:
  /// **'Neue Suche starten'**
  String get newSearch;

  /// No description provided for @errorLocationServicesDisabled.
  ///
  /// In de, this message translates to:
  /// **'Standortdienste sind deaktiviert.'**
  String get errorLocationServicesDisabled;

  /// No description provided for @errorLocationPermissionDenied.
  ///
  /// In de, this message translates to:
  /// **'Standortberechtigung verweigert.'**
  String get errorLocationPermissionDenied;

  /// No description provided for @errorLocationPermissionForeverDenied.
  ///
  /// In de, this message translates to:
  /// **'Standortberechtigung dauerhaft verweigert.'**
  String get errorLocationPermissionForeverDenied;

  /// No description provided for @errorNoLocation.
  ///
  /// In de, this message translates to:
  /// **'Kein Standort ausgewählt.'**
  String get errorNoLocation;

  /// No description provided for @errorNoRestaurantsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Restaurants gefunden.'**
  String get errorNoRestaurantsFound;

  /// No description provided for @errorNoRestaurantsFoundExcludingVisited.
  ///
  /// In de, this message translates to:
  /// **'Keine Restaurants gefunden. (Besuchte ausgeblendet)'**
  String get errorNoRestaurantsFoundExcludingVisited;

  /// No description provided for @errorApiUnknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Fehler bei der Abfrage.'**
  String get errorApiUnknown;

  /// No description provided for @errorGeneric.
  ///
  /// In de, this message translates to:
  /// **'Ein Fehler ist aufgetreten.'**
  String get errorGeneric;

  /// No description provided for @profileTitle.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileVisited.
  ///
  /// In de, this message translates to:
  /// **'Besuchte Restaurants'**
  String get profileVisited;

  /// No description provided for @profileNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get profileNotifications;

  /// No description provided for @profilePrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get profilePrivacy;

  /// No description provided for @profileImprint.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get profileImprint;

  /// No description provided for @filterTitle.
  ///
  /// In de, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @filterClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get filterClose;

  /// No description provided for @filterRadiusTitle.
  ///
  /// In de, this message translates to:
  /// **'Suchradius'**
  String get filterRadiusTitle;

  /// No description provided for @filterRadiusSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wie weit darf das Restaurant entfernt sein?'**
  String get filterRadiusSubtitle;

  /// No description provided for @filterRadiusValue.
  ///
  /// In de, this message translates to:
  /// **'{km} km'**
  String filterRadiusValue(String km);

  /// No description provided for @filterPlaceTypeTitle.
  ///
  /// In de, this message translates to:
  /// **'Lokal-Typ'**
  String get filterPlaceTypeTitle;

  /// No description provided for @filterPlaceTypeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wonach suchst du? Mehrfachauswahl möglich.'**
  String get filterPlaceTypeSubtitle;

  /// No description provided for @filterCuisineTitle.
  ///
  /// In de, this message translates to:
  /// **'Küche'**
  String get filterCuisineTitle;

  /// No description provided for @filterCuisineSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Schränkt die Auswahl auf Restaurants mit dieser Küche ein. Greift nur, wenn „Restaurant\" als Lokal-Typ aktiv ist.'**
  String get filterCuisineSubtitle;

  /// No description provided for @filterCuisineHint.
  ///
  /// In de, this message translates to:
  /// **'Aktiviere „Restaurant\" oben, damit Küchen-Filter wirken.'**
  String get filterCuisineHint;

  /// No description provided for @filterDietTitle.
  ///
  /// In de, this message translates to:
  /// **'Ernährung'**
  String get filterDietTitle;

  /// No description provided for @filterDietSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Zeigt nur Lokale, die diese Optionen anbieten.'**
  String get filterDietSubtitle;

  /// No description provided for @filterDietVegan.
  ///
  /// In de, this message translates to:
  /// **'Vegan verfügbar'**
  String get filterDietVegan;

  /// No description provided for @filterDietVegetarian.
  ///
  /// In de, this message translates to:
  /// **'Vegetarisch verfügbar'**
  String get filterDietVegetarian;

  /// No description provided for @filterComfortTitle.
  ///
  /// In de, this message translates to:
  /// **'Komfort'**
  String get filterComfortTitle;

  /// No description provided for @filterComfortSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ausstattung & Zugänglichkeit, sofern in OSM erfasst.'**
  String get filterComfortSubtitle;

  /// No description provided for @filterComfortWheelchair.
  ///
  /// In de, this message translates to:
  /// **'Rollstuhl-zugänglich'**
  String get filterComfortWheelchair;

  /// No description provided for @filterMiscTitle.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get filterMiscTitle;

  /// No description provided for @filterMiscSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verfeinere das Roulette-Ergebnis.'**
  String get filterMiscSubtitle;

  /// No description provided for @filterMiscExcludeVisited.
  ///
  /// In de, this message translates to:
  /// **'Besuchte ausblenden'**
  String get filterMiscExcludeVisited;

  /// No description provided for @filterMiscExcludeVisitedSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bereits besuchte Orte ausschließen'**
  String get filterMiscExcludeVisitedSubtitle;

  /// No description provided for @filterOsmHeader.
  ///
  /// In de, this message translates to:
  /// **'Datenquelle: OpenStreetMap'**
  String get filterOsmHeader;

  /// No description provided for @filterOsmDescription.
  ///
  /// In de, this message translates to:
  /// **'Restaurants & Filter-Eigenschaften (Vegan, Rollstuhl …) stammen aus der freien OSM-Datenbank — gepflegt von Freiwilligen. Daten sind nicht zu 100 % vollständig oder aktuell.'**
  String get filterOsmDescription;

  /// No description provided for @filterOsmContribute.
  ///
  /// In de, this message translates to:
  /// **'Fehlt was? Selbst eintragen auf openstreetmap.org'**
  String get filterOsmContribute;

  /// No description provided for @placeTypeRestaurant.
  ///
  /// In de, this message translates to:
  /// **'Restaurant'**
  String get placeTypeRestaurant;

  /// No description provided for @placeTypeFastFood.
  ///
  /// In de, this message translates to:
  /// **'Fast Food'**
  String get placeTypeFastFood;

  /// No description provided for @placeTypeCafe.
  ///
  /// In de, this message translates to:
  /// **'Café'**
  String get placeTypeCafe;

  /// No description provided for @placeTypeBar.
  ///
  /// In de, this message translates to:
  /// **'Bar'**
  String get placeTypeBar;

  /// No description provided for @placeTypePub.
  ///
  /// In de, this message translates to:
  /// **'Pub'**
  String get placeTypePub;

  /// No description provided for @placeTypeBiergarten.
  ///
  /// In de, this message translates to:
  /// **'Biergarten'**
  String get placeTypeBiergarten;

  /// No description provided for @placeTypeIceCream.
  ///
  /// In de, this message translates to:
  /// **'Eisdiele'**
  String get placeTypeIceCream;

  /// No description provided for @cuisineItalian.
  ///
  /// In de, this message translates to:
  /// **'Italienisch'**
  String get cuisineItalian;

  /// No description provided for @cuisinePizza.
  ///
  /// In de, this message translates to:
  /// **'Pizza'**
  String get cuisinePizza;

  /// No description provided for @cuisinePasta.
  ///
  /// In de, this message translates to:
  /// **'Pasta'**
  String get cuisinePasta;

  /// No description provided for @cuisineAsian.
  ///
  /// In de, this message translates to:
  /// **'Asiatisch'**
  String get cuisineAsian;

  /// No description provided for @cuisineChinese.
  ///
  /// In de, this message translates to:
  /// **'Chinesisch'**
  String get cuisineChinese;

  /// No description provided for @cuisineJapanese.
  ///
  /// In de, this message translates to:
  /// **'Japanisch'**
  String get cuisineJapanese;

  /// No description provided for @cuisineSushi.
  ///
  /// In de, this message translates to:
  /// **'Sushi'**
  String get cuisineSushi;

  /// No description provided for @cuisineKorean.
  ///
  /// In de, this message translates to:
  /// **'Koreanisch'**
  String get cuisineKorean;

  /// No description provided for @cuisineThai.
  ///
  /// In de, this message translates to:
  /// **'Thailändisch'**
  String get cuisineThai;

  /// No description provided for @cuisineVietnamese.
  ///
  /// In de, this message translates to:
  /// **'Vietnamesisch'**
  String get cuisineVietnamese;

  /// No description provided for @cuisineIndian.
  ///
  /// In de, this message translates to:
  /// **'Indisch'**
  String get cuisineIndian;

  /// No description provided for @cuisineTurkish.
  ///
  /// In de, this message translates to:
  /// **'Türkisch'**
  String get cuisineTurkish;

  /// No description provided for @cuisineKebab.
  ///
  /// In de, this message translates to:
  /// **'Kebab'**
  String get cuisineKebab;

  /// No description provided for @cuisineGreek.
  ///
  /// In de, this message translates to:
  /// **'Griechisch'**
  String get cuisineGreek;

  /// No description provided for @cuisineFrench.
  ///
  /// In de, this message translates to:
  /// **'Französisch'**
  String get cuisineFrench;

  /// No description provided for @cuisineGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get cuisineGerman;

  /// No description provided for @cuisineRegional.
  ///
  /// In de, this message translates to:
  /// **'Regional'**
  String get cuisineRegional;

  /// No description provided for @cuisineMexican.
  ///
  /// In de, this message translates to:
  /// **'Mexikanisch'**
  String get cuisineMexican;

  /// No description provided for @cuisineAmerican.
  ///
  /// In de, this message translates to:
  /// **'Amerikanisch'**
  String get cuisineAmerican;

  /// No description provided for @cuisineBurger.
  ///
  /// In de, this message translates to:
  /// **'Burger'**
  String get cuisineBurger;

  /// No description provided for @cuisineSteakhouse.
  ///
  /// In de, this message translates to:
  /// **'Steakhouse'**
  String get cuisineSteakhouse;

  /// No description provided for @cuisineBarbecue.
  ///
  /// In de, this message translates to:
  /// **'Barbecue'**
  String get cuisineBarbecue;

  /// No description provided for @cuisineFishAndChips.
  ///
  /// In de, this message translates to:
  /// **'Fish & Chips'**
  String get cuisineFishAndChips;

  /// No description provided for @cuisineSeafood.
  ///
  /// In de, this message translates to:
  /// **'Seafood'**
  String get cuisineSeafood;

  /// No description provided for @cuisineNoodle.
  ///
  /// In de, this message translates to:
  /// **'Nudeln'**
  String get cuisineNoodle;

  /// No description provided for @visitedTitle.
  ///
  /// In de, this message translates to:
  /// **'Besuchte Restaurants'**
  String get visitedTitle;

  /// No description provided for @visitedEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Restaurants besucht.'**
  String get visitedEmpty;

  /// No description provided for @visitedError.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String visitedError(String error);

  /// No description provided for @visitedRateChange.
  ///
  /// In de, this message translates to:
  /// **'Bewertung ändern'**
  String get visitedRateChange;

  /// No description provided for @visitedRateNew.
  ///
  /// In de, this message translates to:
  /// **'Jetzt bewerten'**
  String get visitedRateNew;

  /// No description provided for @visitedNotRated.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht bewertet'**
  String get visitedNotRated;

  /// No description provided for @visitedReVisit.
  ///
  /// In de, this message translates to:
  /// **'Erneut besuchen'**
  String get visitedReVisit;

  /// No description provided for @visitedReVisitSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Route in Google Maps öffnen'**
  String get visitedReVisitSubtitle;

  /// No description provided for @rateButton.
  ///
  /// In de, this message translates to:
  /// **'Bewerten'**
  String get rateButton;

  /// No description provided for @sortNewest.
  ///
  /// In de, this message translates to:
  /// **'Neueste'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In de, this message translates to:
  /// **'Älteste'**
  String get sortOldest;

  /// No description provided for @sortBest.
  ///
  /// In de, this message translates to:
  /// **'Beste'**
  String get sortBest;

  /// No description provided for @sortWorst.
  ///
  /// In de, this message translates to:
  /// **'Schlechteste'**
  String get sortWorst;

  /// No description provided for @sortUnrated.
  ///
  /// In de, this message translates to:
  /// **'Unbewertet'**
  String get sortUnrated;

  /// No description provided for @sortMostVisited.
  ///
  /// In de, this message translates to:
  /// **'Meist besucht'**
  String get sortMostVisited;

  /// No description provided for @notificationsTitle.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get notificationsTitle;

  /// No description provided for @notificationsToggleTitle.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen erhalten'**
  String get notificationsToggleTitle;

  /// No description provided for @notificationsToggleSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen zur Bewertung nach Restaurantbesuchen'**
  String get notificationsToggleSubtitle;

  /// No description provided for @notificationRatingTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie war es bei {name}?'**
  String notificationRatingTitle(String name);

  /// No description provided for @notificationRatingBody.
  ///
  /// In de, this message translates to:
  /// **'Bewerte jetzt deinen Besuch!'**
  String get notificationRatingBody;

  /// No description provided for @notificationRatingChannelName.
  ///
  /// In de, this message translates to:
  /// **'Bewertungen'**
  String get notificationRatingChannelName;

  /// No description provided for @notificationRatingChannelDescription.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung zur Bewertung von Restaurantbesuchen'**
  String get notificationRatingChannelDescription;

  /// No description provided for @ratingSave.
  ///
  /// In de, this message translates to:
  /// **'Bewertung speichern'**
  String get ratingSave;

  /// No description provided for @ratingVisitedOn.
  ///
  /// In de, this message translates to:
  /// **'Besucht am: {date}'**
  String ratingVisitedOn(String date);

  /// No description provided for @loadingSearch.
  ///
  /// In de, this message translates to:
  /// **'Suche Restaurants...'**
  String get loadingSearch;

  /// No description provided for @loadingSlow.
  ///
  /// In de, this message translates to:
  /// **'Einen Moment Geduld, die Suche dauert etwas länger.'**
  String get loadingSlow;

  /// No description provided for @restaurantUnknownName.
  ///
  /// In de, this message translates to:
  /// **'Unbekanntes Restaurant'**
  String get restaurantUnknownName;

  /// No description provided for @restaurantNoAddress.
  ///
  /// In de, this message translates to:
  /// **'Keine Adresse verfügbar'**
  String get restaurantNoAddress;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
