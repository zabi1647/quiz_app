import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

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
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.teal.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: isSmallScreen ? 35 : 45,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.displayName?.isNotEmpty ?? false
                                ? user.displayName![0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 32 : 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade600,
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 16 : 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? 'User',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? '',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
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
                const SizedBox(height: 24),
                // Overall Performance
                Text(
                  'Overall Performance',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                // Score Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    child: Column(
                      children: [
                        Text(
                          'Average Score',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${averageScore.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 40 : 48,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(averageScore),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: averageScore / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(averageScore),
                          ),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Statistics Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isSmallScreen ? 1.3 : 1.5,
                  children: [
                    _buildStatCard(
                      'Total Quizzes',
                      totalQuizzes.toString(),
                      Icons.quiz,
                      Colors.blue,
                      isSmallScreen,
                    ),
                    _buildStatCard(
                      'Total Questions',
                      totalQuestions.toString(),
                      Icons.question_answer,
                      Colors.purple,
                      isSmallScreen,
                    ),
                    _buildStatCard(
                      'Correct Answers',
                      correctAnswers.toString(),
                      Icons.check_circle,
                      Colors.green,
                      isSmallScreen,
                    ),
                    _buildStatCard(
                      'Incorrect Answers',
                      incorrectAnswers.toString(),
                      Icons.cancel,
                      Colors.red,
                      isSmallScreen,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Performance Chart
                Text(
                  'Performance Breakdown',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    child: Column(
                      children: [
                        SizedBox(
                          height: isSmallScreen ? 200 : 250,
                          child: totalQuestions > 0
                              ? PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: correctAnswers.toDouble(),
                                        title:
                                            '${(correctAnswers / totalQuestions * 100).toStringAsFixed(0)}%',
                                        color: Colors.green,
                                        radius: isSmallScreen ? 80 : 100,
                                        titleStyle: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: incorrectAnswers.toDouble(),
                                        title:
                                            '${(incorrectAnswers / totalQuestions * 100).toStringAsFixed(0)}%',
                                        color: Colors.red,
                                        radius: isSmallScreen ? 80 : 100,
                                        titleStyle: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    sectionsSpace: 2,
                                    centerSpaceRadius: isSmallScreen ? 40 : 50,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'No data available yet.\nTake a quiz to see your stats!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ),
                        ),
                        if (totalQuestions > 0) const SizedBox(height: 24),
                        if (totalQuestions > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildLegendItem(
                                'Correct',
                                Colors.green,
                                isSmallScreen,
                              ),
                              _buildLegendItem(
                                'Incorrect',
                                Colors.red,
                                isSmallScreen,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Improvement Tips
                if (averageScore < 80)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.amber.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tips for Improvement',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Practice regularly to improve your scores\n'
                            '• Review incorrect answers carefully\n'
                            '• Take quizzes from different categories\n'
                            '• Focus on understanding concepts, not memorizing',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 15,
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
    bool isSmallScreen,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isSmallScreen ? 28 : 36),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 16 : 20,
          height: isSmallScreen ? 16 : 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 15,
            fontWeight: FontWeight.w600,
          ),
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
