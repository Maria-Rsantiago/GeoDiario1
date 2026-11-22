import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/place.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final directory = await getApplicationDocumentsDirectory();
    final databasePath = p.join(directory.path, 'geodiario.db');

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE places (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            image_path TEXT NOT NULL,
            loc_lat REAL NOT NULL,
            loc_lng REAL NOT NULL,
            date_time TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_places_date_time ON places(date_time)',
        );
      },
    );
    return _database!;
  }

  Future<void> insertPlace(Place place) async {
    final db = await database;
    await db.insert(
      'places',
      place.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Place>> getPlaces({bool newestFirst = true}) async {
    final db = await database;
    final rows = await db.query(
      'places',
      orderBy: 'date_time ${newestFirst ? 'DESC' : 'ASC'}',
    );
    return rows.map(Place.fromMap).toList();
  }

  Future<void> deletePlace(String id) async {
    final db = await database;
    await db.delete('places', where: 'id = ?', whereArgs: [id]);
  }
}
