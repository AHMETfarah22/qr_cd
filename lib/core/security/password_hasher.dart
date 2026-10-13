import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 password hashing with legacy SHA-256 migration support.
class PasswordHasher {
  static const int pbkdf2Iterations = 100000;
  static const String currentVersion = '2';

  static String hash(String password, String salt) {
    final derived = _deriveKey(password, salt);
    return base64Encode(derived);
  }

  static bool verify({
    required String password,
    required String salt,
    required String storedHash,
    String? hashVersion,
  }) {
    if (hashVersion == currentVersion) {
      return hash(password, salt) == storedHash;
    }
    return _legacySha256WithSalt(password, salt) == storedHash;
  }

  /// Legacy: SHA-256(password) without salt (SharedPreferences migration).
  static bool verifyLegacyPlain(String password, String storedHash) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString() == storedHash;
  }

  static Uint8List _deriveKey(String password, String salt) {
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);
    const keyLength = 32;
    final hmac = Hmac(sha256, passwordBytes);
    final blockCount = (keyLength + 31) ~/ 32;
    final derived = BytesBuilder();

    for (var blockIndex = 1; blockIndex <= blockCount; blockIndex++) {
      final blockIndexBytes = ByteData(4)..setUint32(0, blockIndex, Endian.big);
      var u = hmac.convert([
        ...saltBytes,
        ...blockIndexBytes.buffer.asUint8List(),
      ]).bytes;
      final block = List<int>.from(u);

      for (var iter = 1; iter < pbkdf2Iterations; iter++) {
        u = hmac.convert(u).bytes;
        for (var i = 0; i < block.length; i++) {
          block[i] ^= u[i];
        }
      }
      derived.add(block);
    }

    return Uint8List.fromList(derived.toBytes().sublist(0, keyLength));
  }

  static String _legacySha256WithSalt(String password, String salt) {
    final bytes = utf8.encode('$password$salt');
    return sha256.convert(bytes).toString();
  }
}
