import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'sqlite_service.dart';

class BackupService {
  BackupService._();

  // All tables to back up
  static const _tables = [
    'job_applications',
    'job_application_status_history',
    'finance_settings',
    'expense_items',
    'youtube_videos',
    'content_calendar',
    'youtube_settings',
    'dashboard_settings',
    'content',
    'channel_stats',
  ];

  /// Export all SQLite data to a JSON file and share it.
  static Future<void> exportBackup(BuildContext context) async {
    try {
      final db = SqliteService.db;
      final Map<String, dynamic> backup = {};

      for (final table in _tables) {
        try {
          final rows = await db.query(table);
          backup[table] = rows;
        } catch (_) {
          // Table may not exist yet — skip gracefully
          backup[table] = [];
        }
      }

      final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'trillionaire_backup_$timestamp.tlbk';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonStr, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Trillionaire Life Backup — $timestamp',
      );
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, '❌ Export failed: $e', isError: true);
      }
    }
  }

  /// Import a backup .tlbk JSON file and restore all data.
  static Future<void> importBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['tlbk', 'json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        _showSnack(context, '❌ Could not read the backup file.', isError: true);
        return;
      }

      final jsonStr = utf8.decode(bytes);
      final Map<String, dynamic> backup = jsonDecode(jsonStr);

      final db = SqliteService.db;

      // Restore each table in a transaction
      await db.transaction((txn) async {
        for (final table in _tables) {
          if (!backup.containsKey(table)) continue;

          final rows = backup[table] as List<dynamic>;
          if (rows.isEmpty) continue;

          // Delete existing data
          try {
            await txn.delete(table);
          } catch (_) {}

          // Insert rows
          for (final row in rows) {
            try {
              await txn.insert(table, Map<String, dynamic>.from(row));
            } catch (_) {}
          }
        }
      });

      if (context.mounted) {
        _showSnack(context, '✅ Backup restored successfully! Restart the app to see changes.');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, '❌ Import failed: $e', isError: true);
      }
    }
  }

  /// Wipe all data from every table in the local database.
  static Future<void> clearAllData(BuildContext context) async {
    try {
      final db = SqliteService.db;
      await db.transaction((txn) async {
        for (final table in _tables) {
          try {
            await txn.delete(table);
          } catch (_) {}
        }
      });
      if (context.mounted) {
        _showSnack(context, '🗑️ All local data has been cleared.');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, '❌ Clear failed: $e', isError: true);
      }
    }
  }

  static void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
