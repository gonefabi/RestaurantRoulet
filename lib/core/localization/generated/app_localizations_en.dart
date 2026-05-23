// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Restaurant Roulette';

  @override
  String get loginWelcome => 'Welcome to\nRestaurant Roulette!';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get searchRestaurants => 'Find a restaurant';

  @override
  String get chooseYourFate => 'Choose your fate!';

  @override
  String get spin => 'SPIN';

  @override
  String get winner => '🎉 WINNER 🎉';

  @override
  String get startRoute => 'START ROUTE';

  @override
  String get alreadyVisited => 'Already visited';

  @override
  String get cancel => 'Cancel';

  @override
  String get spinAgain => 'Spin again';

  @override
  String get newSearch => 'Start a new search';

  @override
  String get errorLocationServicesDisabled => 'Location services are disabled.';

  @override
  String get errorLocationPermissionDenied => 'Location permission denied.';

  @override
  String get errorLocationPermissionForeverDenied =>
      'Location permission permanently denied.';

  @override
  String get errorNoLocation => 'No location selected.';

  @override
  String get errorNoRestaurantsFound => 'No restaurants found.';

  @override
  String get errorNoRestaurantsFoundExcludingVisited =>
      'No restaurants found. (Visited ones hidden)';

  @override
  String get errorApiUnknown => 'Unknown error while querying.';

  @override
  String get errorGeneric => 'An error occurred.';

  @override
  String get errorRetryLocation => 'Try location again';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileVisited => 'Visited restaurants';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get profileImprint => 'Imprint';

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterClose => 'Close';

  @override
  String get filterRadiusTitle => 'Search radius';

  @override
  String get filterRadiusSubtitle => 'How far away may the restaurant be?';

  @override
  String filterRadiusValue(String km) {
    return '$km km';
  }

  @override
  String get filterPlaceTypeTitle => 'Place type';

  @override
  String get filterPlaceTypeSubtitle =>
      'What are you looking for? Multi-select supported.';

  @override
  String get filterCuisineTitle => 'Cuisine';

  @override
  String get filterCuisineSubtitle =>
      'Restricts results to restaurants with this cuisine. Only applies when „Restaurant\" is enabled as place type.';

  @override
  String get filterCuisineHint =>
      'Enable „Restaurant\" above to use cuisine filters.';

  @override
  String get filterDietTitle => 'Diet';

  @override
  String get filterDietSubtitle => 'Only show places offering these options.';

  @override
  String get filterDietVegan => 'Vegan available';

  @override
  String get filterDietVegetarian => 'Vegetarian available';

  @override
  String get filterComfortTitle => 'Comfort';

  @override
  String get filterComfortSubtitle =>
      'Amenities & accessibility, where recorded in OSM.';

  @override
  String get filterComfortWheelchair => 'Wheelchair accessible';

  @override
  String get filterMiscTitle => 'Other';

  @override
  String get filterMiscSubtitle => 'Refine the roulette result.';

  @override
  String get filterMiscExcludeVisited => 'Hide visited';

  @override
  String get filterMiscExcludeVisitedSubtitle =>
      'Exclude places you\'ve already been to';

  @override
  String get filterOsmHeader => 'Data source: OpenStreetMap';

  @override
  String get filterOsmDescription =>
      'Restaurants & filter properties (vegan, wheelchair …) come from the free OSM database — maintained by volunteers. Data is not 100% complete or up to date.';

  @override
  String get filterOsmContribute =>
      'Missing something? Add it on openstreetmap.org';

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
  String get placeTypeBiergarten => 'Beer garden';

  @override
  String get placeTypeIceCream => 'Ice cream parlor';

  @override
  String get cuisineItalian => 'Italian';

  @override
  String get cuisinePizza => 'Pizza';

  @override
  String get cuisinePasta => 'Pasta';

  @override
  String get cuisineAsian => 'Asian';

  @override
  String get cuisineChinese => 'Chinese';

  @override
  String get cuisineJapanese => 'Japanese';

  @override
  String get cuisineSushi => 'Sushi';

  @override
  String get cuisineKorean => 'Korean';

  @override
  String get cuisineThai => 'Thai';

  @override
  String get cuisineVietnamese => 'Vietnamese';

  @override
  String get cuisineIndian => 'Indian';

  @override
  String get cuisineTurkish => 'Turkish';

  @override
  String get cuisineKebab => 'Kebab';

  @override
  String get cuisineGreek => 'Greek';

  @override
  String get cuisineFrench => 'French';

  @override
  String get cuisineGerman => 'German';

  @override
  String get cuisineRegional => 'Regional';

  @override
  String get cuisineMexican => 'Mexican';

  @override
  String get cuisineAmerican => 'American';

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
  String get cuisineNoodle => 'Noodles';

  @override
  String get visitedTitle => 'Visited restaurants';

  @override
  String get visitedEmpty => 'No restaurants visited yet.';

  @override
  String visitedError(String error) {
    return 'Error: $error';
  }

  @override
  String get visitedRateChange => 'Change rating';

  @override
  String get visitedRateNew => 'Rate now';

  @override
  String get visitedNotRated => 'Not yet rated';

  @override
  String get visitedReVisit => 'Visit again';

  @override
  String get visitedReVisitSubtitle => 'Open route in Google Maps';

  @override
  String get rateButton => 'Rate';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortBest => 'Best';

  @override
  String get sortWorst => 'Worst';

  @override
  String get sortUnrated => 'Unrated';

  @override
  String get sortMostVisited => 'Most visited';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsToggleTitle => 'Receive notifications';

  @override
  String get notificationsToggleSubtitle =>
      'Reminders to rate after restaurant visits';

  @override
  String notificationRatingTitle(String name) {
    return 'How was it at $name?';
  }

  @override
  String get notificationRatingBody => 'Rate your visit now!';

  @override
  String get notificationRatingChannelName => 'Ratings';

  @override
  String get notificationRatingChannelDescription =>
      'Reminders to rate restaurant visits';

  @override
  String get ratingSave => 'Save rating';

  @override
  String ratingVisitedOn(String date) {
    return 'Visited on: $date';
  }

  @override
  String get loadingSearch => 'Searching restaurants...';

  @override
  String get loadingSlow =>
      'One moment please, the search is taking a bit longer.';

  @override
  String get restaurantUnknownName => 'Unknown restaurant';

  @override
  String get restaurantNoAddress => 'No address available';
}
