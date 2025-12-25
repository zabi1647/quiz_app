import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login first'));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal.shade50, Colors.white],
        ),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_performances')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final totalQuizzes = data['totalQuizzes'] ?? 0;
          final totalQuestions = data['totalQuestions'] ?? 0;
          final correctAnswers = data['correctAnswers'] ?? 0;
          final incorrectAnswers = data['incorrectAnswers'] ?? 0;
          final averageScore = (data['averageScore'] ?? 0.0).toDouble();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 4,
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.teal.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35.r,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.displayName?.isNotEmpty ?? false
                                ? user.displayName![0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade600,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? 'User',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                user.email ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Overall Performance
                Text(
                  'Overall Performance',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade600,
                  ),
                ),
                SizedBox(height: 16.h),
                // Score Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Text(
                          'Average Score',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${averageScore.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(averageScore),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        LinearProgressIndicator(
                          value: averageScore / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(averageScore),
                          ),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Statistics Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard(
                      'Total Quizzes',
                      totalQuizzes.toString(),
                      Icons.quiz,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Total Questions',
                      totalQuestions.toString(),
                      Icons.question_answer,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      'Correct Answers',
                      correctAnswers.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Incorrect Answers',
                      incorrectAnswers.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Performance Chart
                Text(
                  'Performance Breakdown',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade600,
                  ),
                ),
                SizedBox(height: 16.h),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200.h,
                          child: totalQuestions > 0
                              ? PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: correctAnswers.toDouble(),
                                        title:
                                            '${(correctAnswers / totalQuestions * 100).toStringAsFixed(0)}%',
                                        color: Colors.green,
                                        radius: 80.r,
                                        titleStyle: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: incorrectAnswers.toDouble(),
                                        title:
                                            '${(incorrectAnswers / totalQuestions * 100).toStringAsFixed(0)}%',
                                        color: Colors.red,
                                        radius: 80.r,
                                        titleStyle: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40.r,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'No data available yet.\nTake a quiz to see your stats!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                        ),
                        if (totalQuestions > 0) SizedBox(height: 24.h),
                        if (totalQuestions > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildLegendItem('Correct', Colors.green),
                              _buildLegendItem('Incorrect', Colors.red),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Improvement Tips
                if (averageScore < 80)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.amber.shade700,
                                size: 24.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Tips for Improvement',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '• Practice regularly to improve your scores\n'
                            '• Review incorrect answers carefully\n'
                            '• Take quizzes from different categories\n'
                            '• Focus on understanding concepts, not memorizing',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.amber.shade900,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16.w,
          height: 16.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
