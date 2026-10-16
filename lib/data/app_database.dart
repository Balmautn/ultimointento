import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/activity.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'claude_organizador.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activities(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            date TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL,
            category TEXT NOT NULL DEFAULT 'Personal',
            is_done INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('CREATE INDEX idx_activities_date ON activities(date)');
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL DEFAULT '',
            linked_date TEXT,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount_cents INTEGER NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            kind TEXT NOT NULL DEFAULT 'expense'
          )
        ''');
        await db.execute('''
          CREATE TABLE subtasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            activity_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            is_done INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(activity_id) REFERENCES activities(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return _db!;
  }

  Future<int> addActivity(Activity activity) async {
    final db = await database;
    return db.insert('activities', activity.toMap());
  }

  Future<List<Activity>> activitiesForDate(DateTime date) async {
    final db = await database;
    final rows = await db.query(
      'activities',
      where: 'date = ?',
      whereArgs: [dateKey(date)],
      orderBy: 'start_time ASC',
    );
    return rows.map(Activity.fromMap).toList();
  }

  Future<List<Activity>> upcomingActivities({int limit = 8}) async {
    final db = await database;
    final rows = await db.query(
      'activities',
      where: 'date >= ?',
      whereArgs: [dateKey(DateTime.now())],
      orderBy: 'date ASC, start_time ASC',
      limit: limit,
    );
    return rows.map(Activity.fromMap).toList();
  }

  Future<void> setActivityDone(int id, bool done) async {
    final db = await database;
    await db.update('activities', {'is_done': done ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteActivity(int id) async {
    final db = await database;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  Future<Set<String>> datesWithActivities() async {
    final db = await database;
    final rows = await db.rawQuery('SELECT DISTINCT date FROM activities');
    return rows.map((r) => r['date'] as String).toSet();
  }
}

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
