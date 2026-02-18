import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS config if needed in future
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        if (response.payload != null) {
          // Logic to open popup will be handled by UI checking DB
          // or we can use a stream to notify UI
        }
      },
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleRatingNotification(Restaurant restaurant) async {
    final prefs = await SharedPreferences.getInstance();
    final bool notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (!notificationsEnabled) return;

    // Schedule for 3 hours from now
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(hours: 3));
    // debug: 10 seconds for testing if needed
    // final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: restaurant.id.hashCode, // Unique ID based on restaurant ID
      title: 'Wie war es bei ${restaurant.name}?',
      body: 'Bewerte jetzt deinen Besuch!',
      scheduledDate: scheduledTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'rating_channel',
          'Bewertungen',
          channelDescription: 'Erinnerung zur Bewertung von Restaurantbesuchen',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: restaurant.id,
    );
  }

  Future<void> cancelNotification(String restaurantId) async {
    await flutterLocalNotificationsPlugin.cancel(id: restaurantId.hashCode);
  }
}
