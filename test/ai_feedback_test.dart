import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tscan/features/pdf_study/services/ai_service.dart';
import 'package:tscan/features/pdf_study/widgets/ai_feedback.dart';
import 'package:tscan/l10n/app_localizations.dart';

void main() {
  final tr = lookupAppLocalizations(const Locale('tr'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('missing key gets a clear message instead of a raw exception', () {
    const e = AiException(AiErrorType.missingKey);
    expect(aiErrorMessage(e, tr), tr.aiErrMissingKey);
    expect(aiErrorMessage(e, en), en.aiErrMissingKey);
    expect(aiErrorMessage(e, en), isNot(contains('Exception')));
    expect(aiErrorNeedsKey(e), isTrue);
  });

  test('busy and network errors do not ask for a key', () {
    expect(aiErrorMessage(const AiException(AiErrorType.busy), tr), tr.aiErrBusy);
    expect(aiErrorNeedsKey(const AiException(AiErrorType.network)), isFalse);
    expect(aiErrorMessage(Exception('boom'), en), en.aiErrGeneric);
  });

  test('no credit or a rejected key never asks the student for a key', () {
    for (final type in [AiErrorType.noCredits, AiErrorType.invalidKey]) {
      final e = AiException(type);
      expect(aiErrorMessage(e, tr), tr.aiErrUnavailable);
      expect(aiErrorNeedsKey(e), isFalse);
    }
  });

  test('accepts OpenAI and Gemini key formats, rejects OpenRouter keys', () {
    expect(AiService.looksLikeApiKey('sk-proj-${'x' * 40}'), isTrue);
    expect(AiService.looksLikeApiKey('AIza${'x' * 35}'), isTrue);
    expect(AiService.looksLikeApiKey('AQ.${'x' * 40}'), isTrue);
    expect(AiService.looksLikeApiKey('sk-or-v1-${'x' * 40}'), isFalse);
    expect(AiService.looksLikeApiKey('AIza'), isFalse);
  });
}
