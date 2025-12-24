class MCQModel {
  final String? id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String difficulty;
  final int attemptsCount;
  final int correctCount;
  final int incorrectCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  MCQModel({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.difficulty,
    this.attemptsCount = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'category': category,
      'difficulty': difficulty,
      'attemptsCount': attemptsCount,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MCQModel.fromMap(String id, Map<String, dynamic> map) {
    return MCQModel(
      id: id,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      attemptsCount: map['attemptsCount'] ?? 0,
      correctCount: map['correctCount'] ?? 0,
      incorrectCount: map['incorrectCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  MCQModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    String? category,
    String? difficulty,
    int? attemptsCount,
    int? correctCount,
    int? incorrectCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MCQModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
