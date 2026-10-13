import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Google Gemini API üzerinden AI modellerine erişim sağlayan servis.
/// Gemini 2.5 Flash modelini kullanır ve PDF'leri native vision ile işler.
class AiService {
  // Gemini REST API doğrudan kullanımı (ücretsiz kota destekli model)
  static const String _model = 'gemini-2.5-flash';
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const String _apiKeyStorageKey = 'gemini_api_key';
  static const _storage = FlutterSecureStorage();

  // Geliştirici anahtarı derleme sırasında verilir, koda gömülmez:
  //   flutter run --dart-define-from-file=secrets.json
  static const String _defaultApiKey = String.fromEnvironment('GEMINI_KEY');

  /// Whether [key] looks like a Google Gemini API key. Classic keys start
  /// with "AIza"; newer Google Cloud keys start with "AQ.". OpenRouter keys
  /// (sk-or-...) do not work with the Gemini endpoint this service calls.
  static bool looksLikeGeminiKey(String key) {
    final k = key.trim();
    return k.length >= 20 && (k.startsWith('AIza') || k.startsWith('AQ.'));
  }

  /// API anahtarını güvenli depoya kaydeder.
  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: _apiKeyStorageKey, value: key);
  }

  /// API anahtarını güvenli depodan siler.
  static Future<void> clearApiKey() async {
    await _storage.delete(key: _apiKeyStorageKey);
  }

  /// API anahtarını güvenli depodan okur. Gerekirse gömülü varsayılan anahtarı kullanır.
  static Future<String?> getApiKey() async {
    final savedKey = await _storage.read(key: _apiKeyStorageKey);
    if (savedKey != null && savedKey.isNotEmpty) {
      return savedKey;
    }
    if (_defaultApiKey.isNotEmpty) {
      return _defaultApiKey;
    }
    return null;
  }

  /// API anahtarının mevcut olup olmadığını kontrol eder.
  static Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Gemini API'ye metin tabanlı istek gönderir (metin içerikler için).
  static Future<String> _sendTextRequest(
    String systemPrompt,
    String userContent,
  ) {
    return _generate(
      parts: [
        {'text': userContent},
      ],
      systemPrompt: systemPrompt,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Gemini API'ye PDF dosyasını native inline document olarak gönderir.
  /// Bu yaklaşım; metin, görsel, tablo ve diyagramları birlikte anlayan
  /// Gemini'nin native PDF vision özelliğini kullanır.
  static Future<String> _sendPdfRequest(
    String filePath,
    String systemPrompt,
    String userPrompt,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const AiException(AiErrorType.fileMissing);
    }
    final pdfBase64 = base64Encode(await file.readAsBytes());

    return _generate(
      parts: [
        {
          'inline_data': {'mime_type': 'application/pdf', 'data': pdfBase64},
        },
        {'text': userPrompt},
      ],
      systemPrompt: systemPrompt,
      timeout: const Duration(seconds: 120),
    );
  }

  /// Sends one generateContent request, retrying busy / rate-limited /
  /// timed-out calls, and maps failures to [AiException] types the UI can
  /// explain to the student.
  static Future<String> _generate({
    required List<Map<String, dynamic>> parts,
    required String systemPrompt,
    required Duration timeout,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiException(AiErrorType.missingKey);
    }

    final body = jsonEncode({
      'contents': [
        {'parts': parts},
      ],
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 8192},
    });

    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final http.Response response;
      try {
        response = await http
            .post(
              Uri.parse(_geminiBaseUrl),
              // Key in a header rather than the URL keeps it out of logs.
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': apiKey,
              },
              body: body,
            )
            .timeout(timeout);
      } on TimeoutException {
        if (attempt < maxAttempts) continue;
        throw const AiException(AiErrorType.network, 'timeout');
      } on SocketException catch (e) {
        throw AiException(AiErrorType.network, e.message);
      } on http.ClientException catch (e) {
        throw AiException(AiErrorType.network, e.message);
      }

      final status = response.statusCode;
      if (status == 200) {
        try {
          final data = jsonDecode(response.body);
          return (data['candidates'][0]['content']['parts'][0]['text']
                  as String)
              .trim();
        } catch (_) {
          throw const AiException(
            AiErrorType.badResponse,
            'unexpected response shape',
          );
        }
      }

      debugPrint('Gemini API error $status (attempt $attempt/$maxAttempts)');
      final retryable = status == 429 || status == 500 || status == 503;
      if (retryable && attempt < maxAttempts) {
        await Future.delayed(Duration(seconds: 2 * attempt));
        continue;
      }

      if (status == 401 ||
          status == 403 ||
          (status == 400 && response.body.contains('API_KEY_INVALID'))) {
        throw AiException(AiErrorType.invalidKey, 'HTTP $status');
      }
      if (status == 429) throw const AiException(AiErrorType.rateLimited);
      if (status >= 500) throw AiException(AiErrorType.busy, 'HTTP $status');
      throw AiException(AiErrorType.unknown, 'HTTP $status');
    }
    throw const AiException(AiErrorType.busy);
  }

  /// PDF dosyasını analiz edip tahmini okuma süresini döndürür.
  /// PDF dosya yolu varsa native PDF vision kullanır, yoksa metin kullanır.
  static Future<Map<String, dynamic>> estimateReadingTime(
    String text, {
    String? filePath,
  }) async {
    const systemPrompt =
        '''Sen bir eğitim koçusun. Sana gönderilen akademik içeriği analiz et.

Analiz kriterleri:
1. Toplam kelime sayısı (yaklaşık)
2. Konu alanı (Tıp, Hukuk, Mühendislik, Tarih, Matematik vb.)
3. Teknik terim yoğunluğu (düşük/orta/yüksek)
4. İçerik karmaşıklığı

Ortalama bir üniversite öğrencisinin bu içeriği anlayarak okumasının kaç dakika süreceğini tahmin et.

SADECE aşağıdaki JSON formatında cevap ver, başka hiçbir şey yazma:
{"estimatedMinutes": 45, "difficulty": "orta", "subject": "Biyoloji", "wordCount": 3200, "tips": "Diyagram ve şekillere dikkat et"}''';

    String response;

    if (filePath != null && filePath.isNotEmpty) {
      // Native PDF vision — belgeyi tam olarak görür (metin, grafik, tablo)
      response = await _sendPdfRequest(
        filePath,
        systemPrompt,
        'Bu PDF belgesini analiz et ve tahmini okuma süresini hesapla.',
      );
    } else {
      // Fallback: metin tabanlı analiz
      final trimmedText = text.length > 8000 ? text.substring(0, 8000) : text;
      response = await _sendTextRequest(systemPrompt, trimmedText);
    }

    try {
      String jsonStr = response;
      if (jsonStr.contains('```json')) {
        jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
      } else if (jsonStr.contains('```')) {
        jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
      }

      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('JSON parse error: $e\nResponse: $response');
      // Fallback: Kelime sayısından basit tahmin
      final wordCount = text.split(RegExp(r'\s+')).length;
      final estimatedMinutes = (wordCount / 200).ceil();
      return {
        'estimatedMinutes': estimatedMinutes,
        'difficulty': 'bilinmiyor',
        'subject': 'Genel',
        'wordCount': wordCount,
        'tips': 'AI analiz edilemedi, basit tahmin kullanıldı.',
      };
    }
  }

  /// PDF dosyasından quiz soruları üretir.
  /// PDF dosya yolu varsa native PDF vision kullanır, yoksa metin kullanır.
  static Future<List<Map<String, dynamic>>> generateQuiz(
    String text, {
    int questionCount = 5,
    String? filePath,
  }) async {
    final systemPrompt =
        '''Öğrenci aşağıdaki içeriği okudu. İçeriğe sadık kalarak zorluk derecesi orta düzeyde $questionCount adet çoktan seçmeli soru hazırla.

KURALLAR:
- Her soru 4 şık (A, B, C, D) içermeli
- Doğru cevap içerikte açıkça yer almalı
- Sorular farklı bölümlerden gelmeli
- Şıklar mantıklı ve yanıltıcı olmalı
- JSON çıktısını ASLA yarıda kesme, tüm süslü ve köşeli parantezleri eksiksiz kapat.

SADECE aşağıdaki JSON formatında cevap ver, başka hiçbir şey yazma:
{"questions": [{"id": 1, "question": "Soru metni?", "options": {"A": "Şık A", "B": "Şık B", "C": "Şık C", "D": "Şık D"}, "correctAnswer": "B", "explanation": "Doğru cevabın açıklaması", "pageReference": "İlgili bölüm"}]}''';

    int maxJsonRetries = 2;
    for (int i = 0; i < maxJsonRetries; i++) {
      String response;
      if (filePath != null && filePath.isNotEmpty) {
        response = await _sendPdfRequest(
          filePath,
          systemPrompt,
          'Bu PDF belgesinden $questionCount adet çoktan seçmeli soru oluştur.',
        );
      } else {
        final trimmedText = text.length > 8000 ? text.substring(0, 8000) : text;
        response = await _sendTextRequest(systemPrompt, trimmedText);
      }

      try {
        String jsonStr = response;
        if (jsonStr.contains('```json')) {
          jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
        } else if (jsonStr.contains('```')) {
          jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
        }

        // Bazen model sonundaki ']}' kısmını kesebiliyor, basit bir onarım deneyebiliriz
        if (!jsonStr.trim().endsWith('}') && !jsonStr.trim().endsWith(']')) {
          jsonStr += '}]}';
        } else if (jsonStr.trim().endsWith(']')) {
          jsonStr += '}';
        }

        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['questions'] as List);
      } catch (e) {
        debugPrint(
          'Quiz JSON parse error on try ${i + 1}: $e\nResponse: $response',
        );
        if (i == maxJsonRetries - 1) {
          throw const AiException(AiErrorType.badResponse, 'quiz JSON');
        }
      }
    }
    throw const AiException(AiErrorType.badResponse, 'quiz JSON');
  }

  /// Yanlış cevapları analiz edip öneriler üretir.
  static Future<String> analyzeWrongAnswers(
    String originalText,
    List<Map<String, dynamic>> wrongQuestions,
  ) async {
    const systemPrompt =
        '''Sen bir eğitim koçusun. Öğrenci aşağıdaki metni okudu ve bazı soruları yanlış cevapladı.

Yanlış cevaplanan soruları analiz et ve öğrenciye:
1. Hangi konuları tam anlamadığını açıkla
2. Tekrar bakması gereken bölümleri belirt
3. Konuyu daha iyi anlaması için kısa ipuçları ver

Türkçe cevap ver, samimi ve motive edici bir ton kullan. Kısa ve öz tut (max 200 kelime).''';

    final userContent =
        '''
ORİJİNAL METİN (kısa):
${originalText.length > 3000 ? originalText.substring(0, 3000) : originalText}

YANLIŞ CEVAPLANAN SORULAR:
${jsonEncode(wrongQuestions)}
''';

    return _sendTextRequest(systemPrompt, userContent);
  }
}

enum AiErrorType {
  missingKey,
  invalidKey,
  busy,
  rateLimited,
  network,
  fileMissing,
  badResponse,
  unknown,
}

/// A failed AI request, typed so screens can show a clear, localized message.
class AiException implements Exception {
  final AiErrorType type;
  final String? detail;

  const AiException(this.type, [this.detail]);

  @override
  String toString() =>
      'AiException(${type.name}${detail == null ? '' : ': $detail'})';
}
