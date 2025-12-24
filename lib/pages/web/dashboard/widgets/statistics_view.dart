import 'package:flutter/material.dart';
import 'package:quiz_app/models/mcq_model.dart';
import 'package:quiz_app/services/firestore_service.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: FutureBuilder<Map<String, dynamic>>(
        future: firestoreService.getStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data ?? {};
          final mostAttempted =
              (stats['mostAttempted'] as List<MCQModel>?) ?? [];
          final mostMissed = (stats['mostMissed'] as List<MCQModel>?) ?? [];
          final categoryDist =
              (stats['categoryDistribution'] as Map<String, int>?) ?? {};
          final difficultyDist =
              (stats['difficultyDistribution'] as Map<String, int>?) ?? {};

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Quiz Statistics & Insights',
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade600,
                ),
              ),
              const SizedBox(height: 30),

              // Category Distribution
              _buildSection(
                context,
                'Category Distribution',
                Icons.category,
                _buildDistributionCards(
                  categoryDist,
                  Colors.blue,
                  isSmallScreen,
                ),
                isSmallScreen,
              ),
              const SizedBox(height: 24),

              // Difficulty Distribution
              _buildSection(
                context,
                'Difficulty Distribution',
                Icons.speed,
                _buildDistributionCards(
                  difficultyDist,
                  Colors.orange,
                  isSmallScreen,
                ),
                isSmallScreen,
              ),
              const SizedBox(height: 24),

              // Most Attempted Questions
              _buildSection(
                context,
                'Most Attempted Questions',
                Icons.trending_up,
                _buildMCQList(mostAttempted, isSmallScreen),
                isSmallScreen,
              ),
              const SizedBox(height: 24),

              // Most Missed Questions
              _buildSection(
                context,
                'Most Missed Questions',
                Icons.error_outline,
                _buildMCQList(mostMissed, isSmallScreen),
                isSmallScreen,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
    bool isSmallScreen,
  ) {
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
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purple.shade600),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildDistributionCards(
    Map<String, int> distribution,
    Color color,
    bool isSmallScreen,
  ) {
    if (distribution.isEmpty) {
      return const Text('No data available');
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: distribution.entries.map((entry) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: isSmallScreen ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                entry.value.toString(),
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMCQList(List<MCQModel> mcqs, bool isSmallScreen) {
    if (mcqs.isEmpty) {
      return const Text('No data available');
    }

    return Column(
      children: mcqs.map((mcq) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mcq.question,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text('Attempts: ${mcq.attemptsCount}'),
                    avatar: const Icon(Icons.people, size: 16),
                    backgroundColor: Colors.blue.shade100,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  Chip(
                    label: Text('Correct: ${mcq.correctCount}'),
                    avatar: const Icon(Icons.check, size: 16),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  Chip(
                    label: Text('Incorrect: ${mcq.incorrectCount}'),
                    avatar: const Icon(Icons.close, size: 16),
                    backgroundColor: Colors.red.shade100,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  Chip(
                    label: Text(mcq.category),
                    backgroundColor: Colors.purple.shade100,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
