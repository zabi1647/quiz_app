import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/models/mcq_model.dart';
import 'package:quiz_app/services/firestore_service.dart';
import 'package:quiz_app/services/spaced_repetition_service.dart';
import 'package:quiz_app/pages/app/quiz/quiz_page.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal.shade50, Colors.white],
        ),
      ),
      child: StreamBuilder<List<MCQModel>>(
        stream: firestoreService.getMCQs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final mcqs = snapshot.data ?? [];

          if (mcqs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 80.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No quizzes available yet',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Check back later for new quizzes!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group MCQs by category
          Map<String, List<MCQModel>> groupedMcqs = {};
          for (var mcq in mcqs) {
            if (!groupedMcqs.containsKey(mcq.category)) {
              groupedMcqs[mcq.category] = [];
            }
            groupedMcqs[mcq.category]!.add(mcq);
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Header
              Text(
                'Available Quizzes',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Questions you struggle with appear more often',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 24.h),

              // Practice Mode Card (Spaced Repetition)
              if (mcqs.isNotEmpty)
                Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      // Select questions using spaced repetition
                      final selectedQuestions =
                          SpacedRepetitionService.selectQuestionsForQuiz(
                            mcqs,
                            20, // Select 20 questions
                          );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPage(
                            category: 'Practice Mode (Smart Mix)',
                            mcqs: selectedQuestions,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple.shade400,
                            Colors.purple.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 32.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Practice Mode',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Text(
                                        'SMART',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Focus on your weak areas',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 8.h),
              Text(
                'Or choose by category:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16.h),

              // Category Cards
              ...groupedMcqs.entries.map((entry) {
                final category = entry.key;
                final categoryMcqs = entry.value;
                return _buildCategoryCard(context, category, categoryMcqs);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String category,
    List<MCQModel> mcqs,
  ) {
    final categoryIcons = {
      'General': Icons.lightbulb,
      'Science': Icons.science,
      'Math': Icons.calculate,
      'History': Icons.history_edu,
      'Geography': Icons.public,
    };

    final categoryColors = {
      'General': Colors.blue,
      'Science': Colors.purple,
      'Math': Colors.orange,
      'History': Colors.brown,
      'Geography': Colors.green,
    };

    final icon = categoryIcons[category] ?? Icons.quiz;
    final color = categoryColors[category] ?? Colors.teal;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Apply spaced repetition to category questions
          final sortedMcqs = SpacedRepetitionService.sortByPriority(mcqs);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  QuizPage(category: category, mcqs: sortedMcqs),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.shade400, color.shade600],
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(icon, size: 32.sp, color: Colors.white),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${mcqs.length} Questions Available',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
