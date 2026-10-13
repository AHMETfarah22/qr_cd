import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../security/backup_integrity.dart';

class BackupService {
  /// Exports all data related to the given email as a JSON string.
  static Future<String?> exportUserData(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final Map<String, dynamic> exportData = {};
      final String prefix = 'user_${email.toLowerCase()}';

      for (String key in keys) {
        if (key.startsWith(prefix)) {
          exportData[key] = prefs.get(key);
        }
      }
      if (exportData.isEmpty) {
        return null;
      }
      final payload = <String, dynamic>{
        'version': BackupIntegrity.currentVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'email': email.toLowerCase(),
        'data': exportData,
      };

      final backup = <String, dynamic>{
        ...payload,
        'checksumAlgorithm': BackupIntegrity.checksumAlgorithm,
        'checksum': BackupIntegrity.computeChecksum(payload),
      };

      return jsonEncode(backup);
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  /// Imports user data from a JSON string.
  static Future<Map<String, dynamic>> importUserData(
    String jsonString,
    String currentEmail,
  ) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return {'success': false, 'message': 'Geçersiz yedek dosyası formatı.'};
      }
      final Map<String, dynamic> backup = decoded;

      if (!backup.containsKey('version') || !backup.containsKey('data')) {
        return {'success': false, 'message': 'Geçersiz yedek dosyası formatı.'};
      }

      final version = backup['version'];
      if (version == BackupIntegrity.currentVersion &&
          !BackupIntegrity.verify(backup)) {
        return {
          'success': false,
          'message':
              'Yedek dosyası bozulmuş veya değiştirilmiş. İçe aktarma iptal edildi.',
        };
      }
      // version 1 backups: no checksum — import allowed for backward compatibility

      final String backupEmail = (backup['email'] as String?) ?? '';
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        backup['data'] as Map,
      );
      final prefs = await SharedPreferences.getInstance();
      final String targetPrefix = 'user_${currentEmail.toLowerCase()}';
      final String sourcePrefix = 'user_${backupEmail.toLowerCase()}';

      int importedCount = 0;

      for (String key in data.keys) {
        dynamic value = data[key];
        String targetKey = key;

        if (backupEmail.isNotEmpty &&
            backupEmail.toLowerCase() != currentEmail.toLowerCase()) {
          if (key.startsWith(sourcePrefix)) {
            targetKey = key.replaceFirst(sourcePrefix, targetPrefix);
          }
        } else {
          if (!key.startsWith(targetPrefix)) {
            continue;
          }
        }

        if (value is String) {
          await prefs.setString(targetKey, value);
        } else if (value is int) {
          await prefs.setInt(targetKey, value);
        } else if (value is double) {
          await prefs.setDouble(targetKey, value);
        } else if (value is bool) {
          await prefs.setBool(targetKey, value);
        } else if (value is List) {
          await prefs.setStringList(
            targetKey,
            value.map((e) => e.toString()).toList(),
          );
        }
        importedCount++;
      }

      return {
        'success': true,
        'message': '$importedCount veri noktası başarıyla geri yüklendi.',
      };
    } catch (e) {
      return {'success': false, 'message': 'İçe aktarma hatası: $e'};
    }
  }
}
