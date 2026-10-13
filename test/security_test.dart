import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tscan/core/security/backup_integrity.dart';
import 'package:tscan/core/security/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test('PBKDF2 hash verifies with current version', () {
      const password = 'test-password';
      const salt = 'fixed-salt-uuid';
      final hash = PasswordHasher.hash(password, salt);
      expect(
        PasswordHasher.verify(
          password: password,
          salt: salt,
          storedHash: hash,
          hashVersion: PasswordHasher.currentVersion,
        ),
        isTrue,
      );
      expect(
        PasswordHasher.verify(
          password: 'wrong',
          salt: salt,
          storedHash: hash,
          hashVersion: PasswordHasher.currentVersion,
        ),
        isFalse,
      );
    });

    test('legacy SHA256+salt still verifies without version', () {
      const password = 'legacy';
      const salt = 'salt';
      final legacyHash =
          sha256.convert(utf8.encode('$password$salt')).toString();
      expect(
        PasswordHasher.verify(
          password: password,
          salt: salt,
          storedHash: legacyHash,
          hashVersion: null,
        ),
        isTrue,
      );
    });
  });

  group('BackupIntegrity', () {
    test('checksum detects tampered payload', () {
      final payload = <String, dynamic>{
        'version': BackupIntegrity.currentVersion,
        'timestamp': '2026-01-01T00:00:00.000',
        'email': 'user@test.com',
        'data': {'user_user@test.com_name': 'Test'},
      };
      final backup = <String, dynamic>{
        ...payload,
        'checksumAlgorithm': BackupIntegrity.checksumAlgorithm,
        'checksum': BackupIntegrity.computeChecksum(payload),
      };
      expect(BackupIntegrity.verify(backup), isTrue);

      backup['data'] = {'user_user@test.com_name': 'Hacked'};
      expect(BackupIntegrity.verify(backup), isFalse);
    });
  });
}