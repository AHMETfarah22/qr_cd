import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  
  /// Exports all data related to the given email as a JSON string.
  static Future<String?> exportUserData(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final Map<String, dynamic> exportData = {};
      final String prefix = 'user_${email.toLowerCase()}';

      // Find all keys for this user
      for (String key in keys) {
        if (key.startsWith(prefix)) {
          final value = prefs.get(key);
          // Store relative key (without prefix) for portability? 
          // No, keep full key for simplicity, assuming email is the unique ID.
          // Or strip prefix to allow importing to another email? 
          // Better to keep full key integrity for now, or use a "data" object.
          
          exportData[key] = value;
        }
      }

      if (exportData.isEmpty) {
        return null;
      }

      // Add metadata
      final backup = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'email': email,
        'data': exportData,
      };

      return jsonEncode(backup);
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  /// Imports user data from a JSON string.
  /// Returns a map with success status and message.
  static Future<Map<String, dynamic>> importUserData(String jsonString, String currentEmail) async {
    try {
      final Map<String, dynamic> backup = jsonDecode(jsonString);
      
      // Basic validation
      if (!backup.containsKey('version') || !backup.containsKey('data')) {
        return {'success': false, 'message': 'Geçersiz yedek dosyası formatı.'};
      }

      final String backupEmail = backup['email'] ?? '';
      if (backupEmail.toLowerCase() != currentEmail.toLowerCase()) {
         // Optional: Allow importing cross-account? For security, maybe warn or block.
         // For now, let's warn but allow if user insists? No, simpler to just check.
         // Actually, if we import data with a different email prefix, it won't be read by the app 
         // unless we rename the keys.
         
         // Let's implement smart import: rename keys to current email if different.
      }

      final Map<String, dynamic> data = backup['data'];
      final prefs = await SharedPreferences.getInstance();
      final String targetPrefix = 'user_${currentEmail.toLowerCase()}';
      final String sourcePrefix = 'user_${backupEmail.toLowerCase()}';
      
      int importedCount = 0;

      for (String key in data.keys) {
        dynamic value = data[key];
        String targetKey = key;

        // If email differs, rewrite the key
        if (backupEmail.isNotEmpty && backupEmail != currentEmail) {
            if (key.startsWith(sourcePrefix)) {
                targetKey = key.replaceFirst(sourcePrefix, targetPrefix);
            }
        } else {
             // Ensure we only import data for the CURRENT user to avoid polluting global namespace
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
           await prefs.setStringList(targetKey, value.map((e) => e.toString()).toList());
        }
        importedCount++;
      }

      return {'success': true, 'message': '$importedCount veri noktası başarıyla geri yüklendi.'};

    } catch (e) {
      return {'success': false, 'message': 'İçe aktarma hatası: $e'};
    }
  }
}
