import 'package:flutter/material.dart';
import 'package:quiz_app/models/user_performance_model.dart';
import 'package:quiz_app/services/firestore_service.dart';

class UserPerformance extends StatelessWidget {
  const UserPerformance({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          color: Colors.white,
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.purple.shade600, size: 28),
              const SizedBox(width: 12),
              Text(
                'User Performance',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserPerformanceModel>>(
            stream: firestoreService.getUserPerformances(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final performances = snapshot.data ?? [];

              if (performances.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No user performance data available yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1000) {
                    // Desktop view - Table
                    return _buildDataTable(performances, context);
                  } else {
                    // Mobile/Tablet view - Cards
                    return _buildCardList(performances, isSmallScreen);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(
    List<UserPerformanceModel> performances,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
          columns: const [
            DataColumn(
              label: Text(
                'User Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Quizzes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Questions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Correct',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Incorrect',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Avg Score',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: performances.map((performance) {
            return DataRow(
              cells: [
                DataCell(Text(performance.userName)),
                DataCell(Text(performance.userEmail)),
                DataCell(Text(performance.totalQuizzes.toString())),
                DataCell(Text(performance.totalQuestions.toString())),
                DataCell(
                  Text(
                    performance.correctAnswers.toString(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    performance.incorrectAnswers.toString(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(performance.averageScore),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${performance.averageScore.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardList(
    List<UserPerformanceModel> performances,
    bool isSmallScreen,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      itemCount: performances.length,
      itemBuilder: (context, index) {
        final performance = performances[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Text(
                        performance.userName.isNotEmpty
                            ? performance.userName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: Colors.purple.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            performance.userName,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            performance.userEmail,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(performance.averageScore),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${performance.averageScore.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatChip(
                      'Quizzes',
                      performance.totalQuizzes.toString(),
                      Icons.quiz,
                      Colors.blue,
                    ),
                    _buildStatChip(
                      'Questions',
                      performance.totalQuestions.toString(),
                      Icons.question_answer,
                      Colors.orange,
                    ),
                    _buildStatChip(
                      'Correct',
                      performance.correctAnswers.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatChip(
                      'Incorrect',
                      performance.incorrectAnswers.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text('$label: $value'),
      labelStyle: const TextStyle(fontSize: 12),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
