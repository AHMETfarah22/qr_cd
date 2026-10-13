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
  ) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API anahtarı bulunamadı. Lütfen ayarlardan ekleyin.');
    }

    final url = Uri.parse('$_geminiBaseUrl?key=$apiKey');

    int maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
      try {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': userContent},
                    ],
                  },
                ],
                'systemInstruction': {
                  'parts': [
                    {'text': systemPrompt},
                  ],
                },
                'generationConfig': {
                  'temperature': 0.3,
                  'maxOutputTokens': 8192,
                },
              }),
            )
            .timeout(const Duration(seconds: 60));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content =
              data['candidates'][0]['content']['parts'][0]['text'] as String;
          return content.trim();
        } else if (response.statusCode == 503 && i < maxRetries - 1) {
          debugPrint('Gemini API 503 Error. Retrying ${i + 1}/$maxRetries...');
          await Future.delayed(Duration(seconds: 2 * (i + 1)));
          continue;
        } else if (response.statusCode == 429 && i < maxRetries - 1) {
          debugPrint('Gemini API 429 Error (Rate Limit). Retrying ${i + 1}/$maxRetries...');
          await Future.delayed(Duration(seconds: 3 * (i + 1)));
          continue;
        } else {
          debugPrint('Gemini API Error ${response.statusCode}: ${response.body}');
          if (response.statusCode == 503) {
            throw Exception('Sistem şu an çok yoğun. Lütfen birkaç dakika sonra tekrar deneyin.');
          }
          throw Exception(
            'Gemini API yanıt vermedi (${response.statusCode}): ${response.body}',
          );
        }
      } catch (e) {
        if (i < maxRetries - 1 && (e.toString().contains('503') || e.toString().contains('Timeout'))) {
           debugPrint('Gemini Request Failed: $e. Retrying ${i + 1}/$maxRetries...');
           await Future.delayed(Duration(seconds: 2 * (i + 1)));
           continue;
        }
        debugPrint('Gemini Request Error: $e');
        if (e.toString().contains('503')) {
          throw Exception('Sistem şu an çok yoğun. Lütfen birkaç dakika sonra tekrar deneyin.');
        }
        rethrow;
      }
    }
    throw Exception('API çok fazla deneme sonrası yanıt vermedi. Lütfen daha sonra tekrar deneyin.');
  }

  /// Gemini API'ye PDF dosyasını native inline document olarak gönderir.
  /// Bu yaklaşım; metin, görsel, tablo ve diyagramları birlikte anlayan
  /// Gemini'nin native PDF vision özelliğini kullanır.
  static Future<String> _sendPdfRequest(
    String filePath,
    String systemPrompt,
    String userPrompt,
  ) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API anahtarı bulunamadı. Lütfen ayarlardan ekleyin.');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('PDF dosyası bulunamadı: $filePath');
    }

    final pdfBytes = await file.readAsBytes();
    final pdfBase64 = base64Encode(pdfBytes);

    final url = Uri.parse('$_geminiBaseUrl?key=$apiKey');

    int maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
      try {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {
                        'inline_data': {
                          'mime_type': 'application/pdf',
                          'data': pdfBase64,
                        },
                      },
                      {'text': userPrompt},
                    ],
                  },
                ],
                'systemInstruction': {
                  'parts': [
                    {'text': systemPrompt},
                  ],
                },
                'generationConfig': {
                  'temperature': 0.3,
                  'maxOutputTokens': 8192,
                },
              }),
            )
            .timeout(const Duration(seconds: 120));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content =
              data['candidates'][0]['content']['parts'][0]['text'] as String;
          return content.trim();
        } else if (response.statusCode == 503 && i < maxRetries - 1) {
          debugPrint('Gemini PDF API 503 Error. Retrying ${i + 1}/$maxRetries...');
          await Future.delayed(Duration(seconds: 3 * (i + 1)));
          continue;
        } else if (response.statusCode == 429 && i < maxRetries - 1) {
          debugPrint('Gemini PDF API 429 Error. Retrying ${i + 1}/$maxRetries...');
          await Future.delayed(Duration(seconds: 4 * (i + 1)));
          continue;
        } else {
          debugPrint(
            'Gemini PDF API Error ${response.statusCode}: ${response.body}',
          );
          if (response.statusCode == 503) {
            throw Exception('Sistem şu an çok yoğun (503). Lütfen birkaç dakika sonra tekrar deneyin.');
          }
          throw Exception(
            'Gemini API yanıt vermedi (${response.statusCode}): ${response.body}',
          );
        }
      } catch (e) {
        if (i < maxRetries - 1 && (e.toString().contains('503') || e.toString().contains('Timeout'))) {
           debugPrint('Gemini PDF Request Failed: $e. Retrying ${i + 1}/$maxRetries...');
           await Future.delayed(Duration(seconds: 3 * (i + 1)));
           continue;
        }
        debugPrint('Gemini PDF Request Error: $e');
        if (e.toString().contains('503')) {
          throw Exception('Sistem şu an çok yoğun (503). Lütfen birkaç dakika sonra tekrar deneyin.');
        }
        rethrow;
      }
    }
    throw Exception('API çok fazla deneme sonrası yanıt vermedi. Lütfen daha sonra tekrar deneyin.');
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
        debugPrint('Quiz JSON parse error on try ${i + 1}: $e\nResponse: $response');
        if (i == maxJsonRetries - 1) {
          throw Exception('Quiz soruları oluşturulamadı. Lütfen tekrar deneyin.');
        }
      }
    }
    throw Exception('Quiz soruları oluşturulamadı. Lütfen tekrar deneyin.');
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

    final userContent = '''
ORİJİNAL METİN (kısa):
${originalText.length > 3000 ? originalText.substring(0, 3000) : originalText}

YANLIŞ CEVAPLANAN SORULAR:
${jsonEncode(wrongQuestions)}
''';

    return _sendTextRequest(systemPrompt, userContent);
  }
}
