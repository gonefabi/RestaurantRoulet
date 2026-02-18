import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/restaurant.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'restaurant_roulette.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE visited_restaurants(
            id TEXT PRIMARY KEY,
            name TEXT,
            address TEXT,
            visited_at TEXT,
            rating INTEGER,
            popup_dismissed INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE visited_restaurants ADD COLUMN rating INTEGER');
          await db.execute('ALTER TABLE visited_restaurants ADD COLUMN popup_dismissed INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<void> addVisitedRestaurant(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      'visited_restaurants',
      {
        'id': restaurant.id,
        'name': restaurant.name,
        'address': restaurant.address,
        'visited_at': DateTime.now().toIso8601String(),
        'rating': restaurant.userRating,
        'popup_dismissed': restaurant.popupDismissed ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Restaurant>> getVisitedRestaurants() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('visited_restaurants', orderBy: 'visited_at DESC');
    return maps.map((e) => Restaurant.fromMap(e)).toList();
  }

  Future<Set<String>> getVisitedRestaurantIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('visited_restaurants');
    return maps.map((e) => e['id'] as String).toSet();
  }

  Future<void> updateRating(String id, int rating) async {
    final db = await database;
    await db.update(
      'visited_restaurants',
      {'rating': rating},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markPopupDismissed(String id) async {
    final db = await database;
    await db.update(
      'visited_restaurants',
      {'popup_dismissed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> removeVisitedRestaurant(String id) async {
    final db = await database;
    await db.delete(
      'visited_restaurants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
