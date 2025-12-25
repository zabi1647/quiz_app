import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Score Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 8,
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: passed
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.red.shade400, Colors.red.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        passed
                            ? Icons.emoji_events
                            : Icons.sentiment_dissatisfied,
                        size: 60.sp,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        passed ? 'Congratulations!' : 'Keep Practicing!',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        passed
                            ? 'You passed the quiz!'
                            : 'You need more practice',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Your Score',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Correct',
                      correctAnswers.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      'Incorrect',
                      incorrectAnswers.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Review Answers
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Review Your Answers',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade600,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
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
                );
              }),
              SizedBox(height: 24.h),
              // Back Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
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
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
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
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isCorrect
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    mcq.question,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24.sp,
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
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isCorrectOption
                      ? Colors.green.shade50
                      : (isUserSelection && !isCorrect)
                      ? Colors.red.shade50
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10.r),
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
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 13.sp,
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
