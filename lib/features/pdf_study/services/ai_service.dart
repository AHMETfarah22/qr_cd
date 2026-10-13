import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum _Provider { openAi, gemini }

class _Credential {
  final _Provider provider;
  final String key;
  const _Credential(this.provider, this.key);
}

/// AI study helper: reading-time estimates, quiz generation and wrong-answer
/// coaching. Works with OpenAI (gpt-4.1-mini) and Google Gemini
/// (gemini-2.5-flash). Keys come from the build (`--dart-define-from-file=
/// secrets.json` with OPENAI_KEY / GEMINI_KEY) so students never have to
/// enter one; a key saved in Settings is tried first. When one provider
/// rejects the key or has no credit left, the next configured one is used.
class AiService {
  static const String _openAiModel = 'gpt-4.1-mini';
  static const String _openAiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _geminiModel = 'gemini-2.5-flash';
  static const String _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent';

  static const String _apiKeyStorageKey = 'gemini_api_key';
  static const _storage = FlutterSecureStorage();

  // Build-time keys, never committed: flutter run --dart-define-from-file=secrets.json
  static const String _openAiKey = String.fromEnvironment('OPENAI_KEY');
  static const String _geminiKey = String.fromEnvironment('GEMINI_KEY');

  /// Extracted text shorter than this is treated as a scanned PDF, so the
  /// file itself is sent instead.
  static const int _minUsefulTextLength = 300;
  static const int _maxTextChars = 20000;
  static const int _maxPdfBytes = 20 * 1024 * 1024;

  /// Keys that were rejected or have no credit left, skipped for the rest
  /// of this app session so each request doesn't wait on a known failure.
  static final Set<String> _unusableKeys = {};

  static _Provider? _providerFor(String key) {
    final k = key.trim();
    if (k.length < 20) return null;
    if (k.startsWith('sk-') && !k.startsWith('sk-or-')) return _Provider.openAi;
    if (k.startsWith('AIza') || k.startsWith('AQ.')) return _Provider.gemini;
    return null;
  }

  /// Whether [key] looks like an OpenAI ("sk-...") or Google Gemini
  /// ("AIza..." / "AQ....") API key. OpenRouter keys (sk-or-...) are not
  /// supported by the endpoints this service calls.
  static bool looksLikeApiKey(String key) => _providerFor(key) != null;

  /// API anahtarını güvenli depoya kaydeder.
  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: _apiKeyStorageKey, value: key);
  }

  /// API anahtarını güvenli depodan siler (gömülü anahtarlar etkilenmez).
  static Future<void> clearApiKey() async {
    await _storage.delete(key: _apiKeyStorageKey);
  }

  static Future<List<_Credential>> _credentials() async {
    final result = <_Credential>[];
    void add(String? raw) {
      final key = raw?.trim() ?? '';
      final provider = _providerFor(key);
      if (provider != null && result.every((c) => c.key != key)) {
        result.add(_Credential(provider, key));
      }
    }

    add(await _storage.read(key: _apiKeyStorageKey));
    add(_openAiKey);
    add(_geminiKey);
    return result;
  }

  /// İlk kullanılabilir API anahtarını döndürür.
  static Future<String?> getApiKey() async {
    final credentials = await _credentials();
    return credentials.isEmpty ? null : credentials.first.key;
  }

  /// API anahtarının mevcut olup olmadığını kontrol eder.
  static Future<bool> hasApiKey() async => (await _credentials()).isNotEmpty;

  /// Asks the first working provider. Key or billing problems fall through
  /// to the next configured provider; other failures are reported directly.
  static Future<String> _ask({
    required String systemPrompt,
    required String userPrompt,
    String text = '',
    String? filePath,
    bool json = false,
  }) async {
    final all = await _credentials();
    if (all.isEmpty) throw const AiException(AiErrorType.missingKey);
    final usable = all.where((c) => !_unusableKeys.contains(c.key)).toList();
    final credentials = usable.isEmpty ? all : usable;

    AiException? lastError;
    for (final credential in credentials) {
      try {
        return credential.provider == _Provider.openAi
            ? await _askOpenAi(
                credential.key,
                systemPrompt,
                userPrompt,
                text,
                filePath,
                json,
              )
            : await _askGemini(
                credential.key,
                systemPrompt,
                userPrompt,
                text,
                filePath,
                json,
              );
      } on AiException catch (e) {
        lastError = e;
        final tryNext =
            e.type == AiErrorType.invalidKey ||
            e.type == AiErrorType.noCredits ||
            e.type == AiErrorType.rateLimited;
        if (!tryNext) rethrow;
        if (e.type != AiErrorType.rateLimited) {
          _unusableKeys.add(credential.key);
        }
        debugPrint(
          'AI provider ${credential.provider.name} failed (${e.type.name}), trying next',
        );
      }
    }
    throw lastError!;
  }

  static String _clip(String text) =>
      text.length > _maxTextChars ? text.substring(0, _maxTextChars) : text;

  static Future<String?> _pdfBase64(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return null;
    final file = File(filePath);
    if (!await file.exists() || await file.length() > _maxPdfBytes) return null;
    return base64Encode(await file.readAsBytes());
  }

  /// A document was requested but neither its file nor its text is usable.
  static void _checkSource(String? filePath, String? pdf, String text) {
    final wantsDocument = filePath != null && filePath.isNotEmpty;
    if (wantsDocument && pdf == null && text.trim().isEmpty) {
      throw const AiException(AiErrorType.fileMissing);
    }
  }

  static Future<String> _askOpenAi(
    String key,
    String systemPrompt,
    String userPrompt,
    String text,
    String? filePath,
    bool json,
  ) async {
    // Extracted text is far cheaper than page images; send the PDF only for
    // scanned documents without usable text.
    final List<Map<String, dynamic>> content;
    if (text.trim().length >= _minUsefulTextLength) {
      content = [
        {'type': 'text', 'text': '$userPrompt\n\n${_clip(text)}'},
      ];
    } else {
      final pdf = await _pdfBase64(filePath);
      _checkSource(filePath, pdf, text);
      content = [
        if (pdf != null)
          {
            'type': 'file',
            'file': {
              'filename': 'document.pdf',
              'file_data': 'data:application/pdf;base64,$pdf',
            },
          },
        {
          'type': 'text',
          'text': pdf != null || text.isEmpty
              ? userPrompt
              : '$userPrompt\n\n$text',
        },
      ];
    }

    final data = await _postJson(
      Uri.parse(_openAiUrl),
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $key'},
      jsonEncode({
        'model': _openAiModel,
        'temperature': 0.3,
        'max_completion_tokens': 8192,
        if (json) 'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': content},
        ],
      }),
      _classifyOpenAi,
    );
    try {
      return (data['choices'][0]['message']['content'] as String).trim();
    } catch (_) {
      throw const AiException(AiErrorType.badResponse, 'openai response shape');
    }
  }

  static Future<String> _askGemini(
    String key,
    String systemPrompt,
    String userPrompt,
    String text,
    String? filePath,
    bool json,
  ) async {
    // Gemini reads PDFs natively (text, tables, figures), so prefer the file.
    final pdf = await _pdfBase64(filePath);
    _checkSource(filePath, pdf, text);
    final parts = [
      if (pdf != null)
        {
          'inline_data': {'mime_type': 'application/pdf', 'data': pdf},
        },
      {
        'text': pdf != null || text.isEmpty
            ? userPrompt
            : '$userPrompt\n\n${_clip(text)}',
      },
    ];

    final data = await _postJson(
      Uri.parse(_geminiUrl),
      // Key in a header rather than the URL keeps it out of logs.
      {'Content-Type': 'application/json', 'x-goog-api-key': key},
      jsonEncode({
        'contents': [
          {'parts': parts},
        ],
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 8192,
          if (json) 'responseMimeType': 'application/json',
        },
      }),
      _classifyGemini,
    );
    try {
      return (data['candidates'][0]['content']['parts'][0]['text'] as String)
          .trim();
    } catch (_) {
      throw const AiException(AiErrorType.badResponse, 'gemini response shape');
    }
  }

  static AiException _classifyOpenAi(int status, String body) {
    if (status == 401 || status == 403) {
      return AiException(AiErrorType.invalidKey, 'HTTP $status');
    }
    if (status == 429) {
      final noCredit =
          body.contains('insufficient_quota') ||
          body.contains('credit_balance') ||
          body.contains('billing');
      return AiException(
        noCredit ? AiErrorType.noCredits : AiErrorType.rateLimited,
      );
    }
    if (status >= 500) return AiException(AiErrorType.busy, 'HTTP $status');
    return AiException(AiErrorType.unknown, 'HTTP $status');
  }

  static AiException _classifyGemini(int status, String body) {
    if (status == 401 ||
        status == 403 ||
        (status == 400 && body.contains('API_KEY_INVALID'))) {
      return AiException(AiErrorType.invalidKey, 'HTTP $status');
    }
    if (status == 429) return const AiException(AiErrorType.rateLimited);
    if (status >= 500) return AiException(AiErrorType.busy, 'HTTP $status');
    return AiException(AiErrorType.unknown, 'HTTP $status');
  }

  /// POSTs [body] and returns the decoded JSON response, retrying busy,
  /// rate-limited and timed-out requests a couple of times.
  static Future<Map<String, dynamic>> _postJson(
    Uri url,
    Map<String, String> headers,
    String body,
    AiException Function(int status, String body) classify,
  ) async {
    const maxAttempts = 3;
    for (var attempt = 1; ; attempt++) {
      final http.Response response;
      try {
        response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 120));
      } on TimeoutException {
        if (attempt < maxAttempts) continue;
        throw const AiException(AiErrorType.network, 'timeout');
      } on SocketException catch (e) {
        throw AiException(AiErrorType.network, e.message);
      } on http.ClientException catch (e) {
        throw AiException(AiErrorType.network, e.message);
      }

      // Decode as UTF-8 explicitly: without a charset header the http package
      // falls back to Latin-1, which garbles Turkish characters.
      final text = utf8.decode(response.bodyBytes, allowMalformed: true);
      if (response.statusCode == 200) {
        try {
          return jsonDecode(text) as Map<String, dynamic>;
        } catch (_) {
          throw const AiException(AiErrorType.badResponse, 'invalid JSON');
        }
      }

      final error = classify(response.statusCode, text);
      debugPrint(
        'AI request failed: HTTP ${response.statusCode} (${error.type.name}), '
        'attempt $attempt/$maxAttempts',
      );
      final retryable =
          error.type == AiErrorType.busy ||
          error.type == AiErrorType.rateLimited;
      if (retryable && attempt < maxAttempts) {
        await Future.delayed(Duration(seconds: 2 * attempt));
        continue;
      }
      throw error;
    }
  }

  /// Pulls the JSON object out of a model reply that may be wrapped in
  /// ``` fences.
  static String _extractJson(String response) {
    var jsonStr = response;
    if (jsonStr.contains('```json')) {
      jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
    } else if (jsonStr.contains('```')) {
      jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
    }
    return jsonStr;
  }

  /// PDF dosyasını analiz edip tahmini okuma süresini döndürür.
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

    final response = await _ask(
      systemPrompt: systemPrompt,
      userPrompt: 'Bu belgeyi analiz et ve tahmini okuma süresini hesapla.',
      text: text,
      filePath: filePath,
      json: true,
    );

    try {
      return jsonDecode(_extractJson(response)) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Reading-time JSON parse error: $e');
      // Fallback: Kelime sayısından basit tahmin
      final wordCount = text.split(RegExp(r'\s+')).length;
      return {
        'estimatedMinutes': (wordCount / 200).ceil(),
        'difficulty': 'bilinmiyor',
        'subject': 'Genel',
        'wordCount': wordCount,
        'tips': 'AI analiz edilemedi, basit tahmin kullanıldı.',
      };
    }
  }

  /// Belgeden çoktan seçmeli quiz soruları (cevap ve açıklamalarıyla) üretir.
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
- Soruları belgenin dilinde yaz
- JSON çıktısını ASLA yarıda kesme, tüm süslü ve köşeli parantezleri eksiksiz kapat.

SADECE aşağıdaki JSON formatında cevap ver, başka hiçbir şey yazma:
{"questions": [{"id": 1, "question": "Soru metni?", "options": {"A": "Şık A", "B": "Şık B", "C": "Şık C", "D": "Şık D"}, "correctAnswer": "B", "explanation": "Doğru cevabın açıklaması", "pageReference": "İlgili bölüm"}]}''';

    const maxJsonRetries = 2;
    for (var i = 0; i < maxJsonRetries; i++) {
      final response = await _ask(
        systemPrompt: systemPrompt,
        userPrompt:
            'Bu belgeden $questionCount adet çoktan seçmeli soru oluştur.',
        text: text,
        filePath: filePath,
        json: true,
      );

      try {
        var jsonStr = _extractJson(response).trim();
        // Bazen model sonundaki ']}' kısmını kesebiliyor, basit bir onarım dene
        if (!jsonStr.endsWith('}') && !jsonStr.endsWith(']')) {
          jsonStr += '}]}';
        } else if (jsonStr.endsWith(']')) {
          jsonStr += '}';
        }
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final questions = List<Map<String, dynamic>>.from(
          data['questions'] as List,
        );
        if (questions.isNotEmpty) return questions;
      } catch (e) {
        debugPrint('Quiz JSON parse error on try ${i + 1}: $e');
      }
    }
    throw const AiException(AiErrorType.badResponse, 'quiz JSON');
  }

  /// Yanlış cevapları analiz edip öneriler üretir.
  static Future<String> analyzeWrongAnswers(
    String originalText,
    List<Map<String, dynamic>> wrongQuestions,
  ) {
    const systemPrompt =
        '''Sen bir eğitim koçusun. Öğrenci aşağıdaki metni okudu ve bazı soruları yanlış cevapladı.

Yanlış cevaplanan soruları analiz et ve öğrenciye:
1. Hangi konuları tam anlamadığını açıkla
2. Tekrar bakması gereken bölümleri belirt
3. Konuyu daha iyi anlaması için kısa ipuçları ver

Türkçe cevap ver, samimi ve motive edici bir ton kullan. Kısa ve öz tut (max 200 kelime).''';

    final shortText = originalText.length > 3000
        ? originalText.substring(0, 3000)
        : originalText;
    return _ask(
      systemPrompt: systemPrompt,
      userPrompt:
          'ORİJİNAL METİN (kısa):\n$shortText\n\n'
          'YANLIŞ CEVAPLANAN SORULAR:\n${jsonEncode(wrongQuestions)}',
    );
  }
}

enum AiErrorType {
  missingKey,
  invalidKey,
  noCredits,
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
