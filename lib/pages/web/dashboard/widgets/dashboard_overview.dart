import 'package:flutter/material.dart';
import 'package:quiz_app/services/firestore_service.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Admin Dashboard',
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of your quiz app',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          FutureBuilder<Map<String, dynamic>>(
            future: firestoreService.getStatistics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final stats = snapshot.data ?? {};
              final totalMCQs = stats['totalMCQs'] ?? 0;
              final totalAttempts = stats['totalAttempts'] ?? 0;

              return FutureBuilder<int>(
                future: firestoreService.getTotalUsers(),
                builder: (context, userSnapshot) {
                  final totalUsers = userSnapshot.data ?? 0;

                  return Column(
                    children: [
                      // Statistics Cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = constraints.maxWidth;
                          final crossAxisCount = cardWidth > 1200
                              ? 4
                              : (cardWidth > 800 ? 2 : 1);

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: isSmallScreen ? 1.5 : 2,
                            children: [
                              _buildStatCard(
                                icon: Icons.quiz,
                                title: 'Total MCQs',
                                value: totalMCQs.toString(),
                                color: Colors.blue,
                                context: context,
                              ),
                              _buildStatCard(
                                icon: Icons.people,
                                title: 'Total Users',
                                value: totalUsers.toString(),
                                color: Colors.green,
                                context: context,
                              ),
                              _buildStatCard(
                                icon: Icons.trending_up,
                                title: 'Total Attempts',
                                value: totalAttempts.toString(),
                                color: Colors.orange,
                                context: context,
                              ),
                              _buildStatCard(
                                icon: Icons.check_circle,
                                title: 'Active Quizzes',
                                value: totalMCQs.toString(),
                                color: Colors.purple,
                                context: context,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 24 : 32),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
