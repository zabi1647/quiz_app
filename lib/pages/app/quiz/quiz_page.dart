import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/models/mcq_model.dart';
import 'package:quiz_app/pages/app/quiz/quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  final String category;
  final List<MCQModel> mcqs;

  const QuizPage({super.key, required this.category, required this.mcqs});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {};
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final currentMcq = widget.mcqs[_currentQuestionIndex];
    final selectedAnswer = _selectedAnswers[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Progress Bar
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1}/${widget.mcqs.length}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade600,
                        ),
                      ),
                      Text(
                        '${((_currentQuestionIndex + 1) / widget.mcqs.length * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / widget.mcqs.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.teal.shade600,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            // Question and Options
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.quiz,
                                    color: Colors.teal.shade600,
                                    size: isSmallScreen ? 20 : 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Chip(
                                  label: Text(currentMcq.difficulty),
                                  backgroundColor: _getDifficultyColor(
                                    currentMcq.difficulty,
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentMcq.question,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Options
                    Text(
                      'Select your answer:',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...currentMcq.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = selectedAnswer == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            if (!_isSubmitted) {
                              setState(() {
                                _selectedAnswers[_currentQuestionIndex] = index;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.teal.shade600
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.teal.shade600
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: isSmallScreen ? 32 : 40,
                                  height: isSmallScreen ? 32 : 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade100,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(
                                        65 + index,
                                      ), // A, B, C, D
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.teal.shade600
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 12 : 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 15 : 17,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Navigation Buttons
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal.shade600,
                          side: BorderSide(
                            color: Colors.teal.shade600,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: selectedAnswer != null
                          ? () {
                              if (_currentQuestionIndex <
                                  widget.mcqs.length - 1) {
                                setState(() {
                                  _currentQuestionIndex++;
                                });
                              } else {
                                _submitQuiz();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _currentQuestionIndex < widget.mcqs.length - 1
                            ? 'Next'
                            : 'Submit Quiz',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitQuiz() async {
    // Calculate results
    int correctAnswers = 0;
    for (var i = 0; i < widget.mcqs.length; i++) {
      if (_selectedAnswers[i] == widget.mcqs[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Update user performance
        final userPerfRef = FirebaseFirestore.instance
            .collection('user_performances')
            .doc(user.uid);

        final docSnapshot = await userPerfRef.get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          final totalQuizzes = (data['totalQuizzes'] ?? 0) + 1;
          final totalQuestions =
              (data['totalQuestions'] ?? 0) + widget.mcqs.length;
          final totalCorrect = (data['correctAnswers'] ?? 0) + correctAnswers;
          final totalIncorrect =
              (data['incorrectAnswers'] ?? 0) +
              (widget.mcqs.length - correctAnswers);
          final averageScore = (totalCorrect / totalQuestions) * 100;

          await userPerfRef.update({
            'totalQuizzes': totalQuizzes,
            'totalQuestions': totalQuestions,
            'correctAnswers': totalCorrect,
            'incorrectAnswers': totalIncorrect,
            'averageScore': averageScore,
            'lastAttempt': DateTime.now().toIso8601String(),
          });
        }

        // Update MCQ statistics
        for (var i = 0; i < widget.mcqs.length; i++) {
          final mcq = widget.mcqs[i];
          final isCorrect = _selectedAnswers[i] == mcq.correctAnswerIndex;

          await FirebaseFirestore.instance
              .collection('mcqs')
              .doc(mcq.id)
              .update({
                'attemptsCount': FieldValue.increment(1),
                'correctCount': isCorrect
                    ? FieldValue.increment(1)
                    : mcq.correctCount,
                'incorrectCount': !isCorrect
                    ? FieldValue.increment(1)
                    : mcq.incorrectCount,
              });
        }
      } catch (e) {
        debugPrint('Error updating stats: $e');
      }
    }

    // Navigate to results page
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultPage(
            mcqs: widget.mcqs,
            selectedAnswers: _selectedAnswers,
            category: widget.category,
          ),
        ),
      );
    }
  }
}
