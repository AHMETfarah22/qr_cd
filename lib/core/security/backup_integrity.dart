import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Backup format versioning and SHA-256 integrity checks.
class BackupIntegrity {
  static const int currentVersion = 2;
  static const String checksumAlgorithm = 'sha256';

  static String computeChecksum(Map<String, dynamic> payload) {
    final canonical = jsonEncode(payload);
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static bool verify(Map<String, dynamic> backup) {
    final stored = backup['checksum'];
    if (stored is! String || stored.isEmpty) return false;

    final algorithm = backup['checksumAlgorithm'];
    if (algorithm != checksumAlgorithm) return false;

    final payload = <String, dynamic>{
      'version': backup['version'],
      'timestamp': backup['timestamp'],
      'email': backup['email'],
      'data': backup['data'],
    };

    return computeChecksum(payload) == stored;
  }
}