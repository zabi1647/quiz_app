class UserPerformanceModel {
  final String userId;
  final String userName;
  final String userEmail;
  final int totalQuizzes;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double averageScore;
  final DateTime lastAttempt;

  UserPerformanceModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.totalQuizzes,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.averageScore,
    required this.lastAttempt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'totalQuizzes': totalQuizzes,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'averageScore': averageScore,
      'lastAttempt': lastAttempt.toIso8601String(),
    };
  }

  factory UserPerformanceModel.fromMap(Map<String, dynamic> map) {
    return UserPerformanceModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      totalQuizzes: map['totalQuizzes'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      incorrectAnswers: map['incorrectAnswers'] ?? 0,
      averageScore: (map['averageScore'] ?? 0.0).toDouble(),
      lastAttempt: DateTime.parse(map['lastAttempt']),
    );
  }
}
