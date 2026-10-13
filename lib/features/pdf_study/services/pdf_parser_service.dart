import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:uuid/uuid.dart';
import '../../../core/models/pdf_document.dart';

/// PDF dosyalarından metin çıkaran servis.
class PdfParserService {
  static const _uuid = Uuid();

  /// Verilen dosya yolundaki PDF'ten metin çıkarır ve [PdfDocument] döndürür.
  static Future<PdfDocument> parsePdf(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('PDF dosyası bulunamadı.');
      }

      final bytes = await file.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: bytes);
      final textExtractor = syncfusion.PdfTextExtractor(document);

      final StringBuffer fullText = StringBuffer();
      final pageCount = document.pages.count;

      for (int i = 0; i < pageCount; i++) {
        final pageText = textExtractor.extractText(startPageIndex: i);
        if (pageText.isNotEmpty) {
          fullText.writeln(pageText);
        }
      }

      document.dispose();

      final extractedText = fullText.toString().trim();
      if (extractedText.isEmpty) {
        throw Exception(
          'PDF\'ten metin çıkarılamadı. Dosya taranmış (görüntü) olabilir.',
        );
      }

      final wordCount = extractedText
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .length;

      final fileName = filePath.split(Platform.pathSeparator).last;

      return PdfDocument(
        id: _uuid.v4(),
        fileName: fileName,
        filePath: filePath,
        extractedText: extractedText,
        pageCount: pageCount,
        wordCount: wordCount,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('PDF Parse Error: $e');
      rethrow;
    }
  }
}
