import 'package:flutter/material.dart';
import 'package:quiz_app/models/mcq_model.dart';

class QuizResultPage extends StatelessWidget {
  final List<MCQModel> mcqs;
  final Map<int, int> selectedAnswers;
  final String category;

  const QuizResultPage({
    super.key,
    required this.mcqs,
    required this.selectedAnswers,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    int correctAnswers = 0;
    for (var i = 0; i < mcqs.length; i++) {
      if (selectedAnswers[i] == mcqs[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }

    final incorrectAnswers = mcqs.length - correctAnswers;
    final percentage = (correctAnswers / mcqs.length * 100).toStringAsFixed(1);
    final passed = correctAnswers / mcqs.length >= 0.6; // 60% passing grade

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              passed ? Colors.green.shade50 : Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Column(
            children: [
              // Score Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: passed
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.red.shade400, Colors.red.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        passed
                            ? Icons.emoji_events
                            : Icons.sentiment_dissatisfied,
                        size: isSmallScreen ? 60 : 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        passed ? 'Congratulations!' : 'Keep Practicing!',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        passed
                            ? 'You passed the quiz!'
                            : 'You need more practice',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 48 : 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Score',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Correct',
                      correctAnswers.toString(),
                      Icons.check_circle,
                      Colors.green,
                      isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Incorrect',
                      incorrectAnswers.toString(),
                      Icons.cancel,
                      Colors.red,
                      isSmallScreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Review Answers
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Review Your Answers',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...mcqs.asMap().entries.map((entry) {
                final index = entry.key;
                final mcq = entry.value;
                final userAnswer = selectedAnswers[index];
                final isCorrect = userAnswer == mcq.correctAnswerIndex;

                return _buildAnswerReviewCard(
                  index,
                  mcq,
                  userAnswer,
                  isCorrect,
                  isSmallScreen,
                );
              }),
              const SizedBox(height: 24),
              // Back Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          children: [
            Icon(icon, color: color, size: isSmallScreen ? 32 : 40),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 28 : 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerReviewCard(
    int index,
    MCQModel mcq,
    int? userAnswer,
    bool isCorrect,
    bool isSmallScreen,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  width: isSmallScreen ? 32 : 40,
                  height: isSmallScreen ? 32 : 40,
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: isCorrect
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mcq.question,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: isSmallScreen ? 24 : 28,
                ),
              ],
            ),
            const Divider(height: 24),
            // Options
            ...mcq.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final isCorrectOption = optionIndex == mcq.correctAnswerIndex;
              final isUserSelection = optionIndex == userAnswer;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: isCorrectOption
                      ? Colors.green.shade50
                      : (isUserSelection && !isCorrect)
                      ? Colors.red.shade50
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrectOption
                        ? Colors.green
                        : (isUserSelection && !isCorrect)
                        ? Colors.red
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrectOption
                          ? Icons.check_circle
                          : (isUserSelection && !isCorrect)
                          ? Icons.cancel
                          : Icons.radio_button_unchecked,
                      color: isCorrectOption
                          ? Colors.green
                          : (isUserSelection && !isCorrect)
                          ? Colors.red
                          : Colors.grey,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 15,
                          fontWeight: isCorrectOption || isUserSelection
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isCorrectOption
                              ? Colors.green.shade700
                              : (isUserSelection && !isCorrect)
                              ? Colors.red.shade700
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
