import 'dart:convert';

class PdfDocument {
  final String id;
  final String fileName;
  final String filePath;
  final String extractedText;
  final int pageCount;
  final int wordCount;
  final DateTime uploadedAt;

  // AI analysis results
  int? estimatedMinutes;
  String? difficulty;
  String? subject;
  String? tips;

  PdfDocument({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.extractedText,
    required this.pageCount,
    required this.wordCount,
    required this.uploadedAt,
    this.estimatedMinutes,
    this.difficulty,
    this.subject,
    this.tips,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'filePath': filePath,
        'extractedText': extractedText,
        'pageCount': pageCount,
        'wordCount': wordCount,
        'uploadedAt': uploadedAt.toIso8601String(),
        'estimatedMinutes': estimatedMinutes,
        'difficulty': difficulty,
        'subject': subject,
        'tips': tips,
      };

  factory PdfDocument.fromJson(Map<String, dynamic> json) => PdfDocument(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        filePath: json['filePath'] as String,
        extractedText: json['extractedText'] as String,
        pageCount: json['pageCount'] as int,
        wordCount: json['wordCount'] as int,
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        estimatedMinutes: json['estimatedMinutes'] as int?,
        difficulty: json['difficulty'] as String?,
        subject: json['subject'] as String?,
        tips: json['tips'] as String?,
      );

  String toJsonString() => jsonEncode(toJson());

  factory PdfDocument.fromJsonString(String jsonString) =>
      PdfDocument.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
