import 'package:flutter_test/flutter_test.dart';
import 'package:tscan/core/models/quiz_question.dart';

void main() {
  group('QuizQuestion Model Tests', () {
    test('should calculate correctness correctly', () {
      final question = QuizQuestion(
        id: 1,
        question: 'What is the capital of Turkey?',
        options: {'A': 'Istanbul', 'B': 'Ankara', 'C': 'Izmir', 'D': 'Bursa'},
        correctAnswer: 'B',
        explanation: 'Ankara is the capital.',
      );

      expect(question.isAnswered, isFalse);
      expect(question.isCorrect, isFalse);

      question.userAnswer = 'A';
      expect(question.isAnswered, isTrue);
      expect(question.isCorrect, isFalse);

      question.userAnswer = 'B';
      expect(question.isAnswered, isTrue);
      expect(question.isCorrect, isTrue);
    });

    test('should serialize and deserialize json correctly', () {
      final question = QuizQuestion(
        id: 1,
        question: 'What is 2+2?',
        options: {'A': '3', 'B': '4', 'C': '5'},
        correctAnswer: 'B',
        explanation: 'Simple math.',
      );

      final jsonMap = question.toJson();
      expect(jsonMap['id'], 1);
      expect(jsonMap['question'], 'What is 2+2?');

      final parsedQuestion = QuizQuestion.fromJson(jsonMap);
      expect(parsedQuestion.id, 1);
      expect(parsedQuestion.question, 'What is 2+2?');
      expect(parsedQuestion.correctAnswer, 'B');
    });
  });

  group('QuizResult Model Tests', () {
    test('should calculate correct count and percentage correctly', () {
      final question1 = QuizQuestion(
        id: 1,
        question: 'Q1',
        options: {'A': '1', 'B': '2'},
        correctAnswer: 'A',
        explanation: '',
      );
      final question2 = QuizQuestion(
        id: 2,
        question: 'Q2',
        options: {'A': '1', 'B': '2'},
        correctAnswer: 'B',
        explanation: '',
      );

      final result = QuizResult(
        documentId: 'doc123',
        documentName: 'math_test.pdf',
        questions: [question1, question2],
        completedAt: DateTime.now(),
        totalTimeSeconds: 120,
      );

      expect(result.totalCount, 2);
      expect(result.correctCount, 0);
      expect(result.scorePercent, 0.0);

      question1.userAnswer = 'A'; // correct
      question2.userAnswer = 'A'; // wrong

      expect(result.correctCount, 1);
      expect(result.scorePercent, 50.0);
      expect(result.wrongAnswers.length, 1);
      expect(result.wrongAnswers.first.id, 2);
    });
  });
}
