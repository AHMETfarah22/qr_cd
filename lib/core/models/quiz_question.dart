import 'dart:convert';

class QuizQuestion {
  final int id;
  final String question;
  final Map<String, String> options; // {"A": "...", "B": "...", ...}
  final String correctAnswer; // "A", "B", "C", or "D"
  final String explanation;
  final String? pageReference;
  String? userAnswer; // User's selected answer

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.pageReference,
    this.userAnswer,
  });

  bool get isCorrect => userAnswer == correctAnswer;
  bool get isAnswered => userAnswer != null;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as int,
    question: json['question'] as String,
    options: Map<String, String>.from(json['options'] as Map),
    correctAnswer: json['correctAnswer'] as String,
    explanation: (json['explanation'] as String?) ?? '',
    pageReference: json['pageReference'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
    'pageReference': pageReference,
    'userAnswer': userAnswer,
  };
}

class QuizResult {
  final String documentId;
  final String documentName;
  final List<QuizQuestion> questions;
  final DateTime completedAt;
  final int totalTimeSeconds;

  QuizResult({
    required this.documentId,
    required this.documentName,
    required this.questions,
    required this.completedAt,
    required this.totalTimeSeconds,
  });

  int get correctCount => questions.where((q) => q.isCorrect).length;
  int get totalCount => questions.length;
  double get scorePercent =>
      totalCount > 0 ? (correctCount / totalCount) * 100 : 0;

  List<QuizQuestion> get wrongAnswers =>
      questions.where((q) => !q.isCorrect && q.isAnswered).toList();

  Map<String, dynamic> toJson() => {
    'documentId': documentId,
    'documentName': documentName,
    'questions': questions.map((q) => q.toJson()).toList(),
    'completedAt': completedAt.toIso8601String(),
    'totalTimeSeconds': totalTimeSeconds,
  };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    documentId: json['documentId'] as String,
    documentName: json['documentName'] as String,
    questions: (json['questions'] as List)
        .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList(),
    completedAt: DateTime.parse(json['completedAt'] as String),
    totalTimeSeconds: json['totalTimeSeconds'] as int,
  );

  String toJsonString() => jsonEncode(toJson());
}
