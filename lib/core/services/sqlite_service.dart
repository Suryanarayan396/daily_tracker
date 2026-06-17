import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class SqliteService {
  static Database? _db;
  static final _changeController = StreamController<String>.broadcast();

  static Future<void> init() async {
    if (_db != null) return;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'lifeos_sqlite.db');

    _db = await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        // Create Job Applications table
        await db.execute('''
          CREATE TABLE job_applications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            company TEXT NOT NULL,
            role TEXT NOT NULL,
            status TEXT NOT NULL,
            salary REAL NOT NULL,
            offeredSalary REAL NOT NULL DEFAULT 0.0,
            dateApplied TEXT NOT NULL,
            recruiterContacted INTEGER NOT NULL,
            interviewDate TEXT NOT NULL,
            notes TEXT NOT NULL,
            reminderDateTime TEXT NOT NULL DEFAULT ""
          )
        ''');

        // Create Job Application Status History table
        await db.execute('''
          CREATE TABLE job_application_status_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            applicationId INTEGER NOT NULL,
            status TEXT NOT NULL,
            changedAt TEXT NOT NULL
          )
        ''');

        // Create Finance Settings table
        await db.execute('''
          CREATE TABLE finance_settings (
            id INTEGER PRIMARY KEY,
            salary REAL NOT NULL,
            netWorth REAL NOT NULL,
            debt REAL NOT NULL,
            emergencyFund REAL NOT NULL,
            emergencyFundTarget REAL NOT NULL,
            savings REAL NOT NULL,
            savingsTarget REAL NOT NULL,
            netWorthHistory TEXT NOT NULL,
            netWorthMonths TEXT NOT NULL
          )
        ''');

        // Create Expense Items table
        await db.execute('''
          CREATE TABLE expense_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');

        // Create Youtube Videos table (Legacy/Deprecated but kept for compatibility)
        await db.execute('''
          CREATE TABLE youtube_videos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            type TEXT NOT NULL,
            stage TEXT NOT NULL,
            views INTEGER NOT NULL,
            watchTimeMinutes INTEGER NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        // Create Content Calendar table (Legacy/Deprecated but kept for compatibility)
        await db.execute('''
          CREATE TABLE content_calendar (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            type TEXT NOT NULL,
            scheduledDate TEXT NOT NULL,
            isPublished INTEGER NOT NULL
          )
        ''');

        // Create Youtube Settings table (Legacy/Deprecated but kept for compatibility)
        await db.execute('''
          CREATE TABLE youtube_settings (
            id INTEGER PRIMARY KEY,
            subscribers INTEGER NOT NULL
          )
        ''');

        // Create Dashboard Settings table
        await db.execute('''
          CREATE TABLE dashboard_settings (
            id INTEGER PRIMARY KEY,
            welcomeMessage TEXT NOT NULL,
            dailyMission TEXT NOT NULL,
            streakDays INTEGER NOT NULL,
            dailyScore INTEGER NOT NULL,
            highestImpactTask TEXT NOT NULL,
            isHitCompleted INTEGER NOT NULL,
            currentLawInsight TEXT NOT NULL,
            targetSalary REAL NOT NULL
          )
        ''');

        // Create new Youtube Content table
        await db.execute('''
          CREATE TABLE content (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            target_date TEXT NOT NULL,
            status TEXT NOT NULL,
            published_at TEXT,
            created_at TEXT NOT NULL,
            reminderDateTime TEXT NOT NULL DEFAULT ""
          )
        ''');

        // Create new Youtube Channel Stats table
        await db.execute('''
          CREATE TABLE channel_stats (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS expense_items');
          await db.execute('''
            CREATE TABLE expense_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT NOT NULL,
              description TEXT NOT NULL,
              amount REAL NOT NULL,
              date TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS content (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              target_date TEXT NOT NULL,
              status TEXT NOT NULL,
              published_at TEXT,
              created_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS channel_stats (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 4) {
          try {
            await db.execute('ALTER TABLE job_applications ADD COLUMN offeredSalary REAL DEFAULT 0.0');
          } catch (_) {}
          await db.execute('''
            CREATE TABLE IF NOT EXISTS job_application_status_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              applicationId INTEGER NOT NULL,
              status TEXT NOT NULL,
              changedAt TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 5) {
          try {
            await db.execute('ALTER TABLE job_applications ADD COLUMN reminderDateTime TEXT DEFAULT ""');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE content ADD COLUMN reminderDateTime TEXT DEFAULT ""');
          } catch (_) {}
        }
      },
    );
  }

  static Database get db {
    if (_db == null) {
      throw StateError('SqliteService not initialized. Call SqliteService.init() first.');
    }
    return _db!;
  }

  /// Broadcast a change event for a table to notify listeners.
  static void notify(String table) {
    _changeController.add(table);
  }

  /// Watch a specific table for changes.
  static Stream<String> get changeStream => _changeController.stream;

  /// Watch a specific table for changes.
  static Stream<String> watchTable(String table) {
    return _changeController.stream.where((event) => event == table);
  }
}
