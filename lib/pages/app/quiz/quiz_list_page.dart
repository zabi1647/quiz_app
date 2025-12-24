import 'package:flutter/material.dart';
import 'package:quiz_app/models/mcq_model.dart';
import 'package:quiz_app/services/firestore_service.dart';
import 'package:quiz_app/pages/app/quiz/quiz_page.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

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
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No quizzes available yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new quizzes!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            children: [
              // Header
              Text(
                'Available Quizzes',
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a category to start your quiz',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              // Category Cards
              ...groupedMcqs.entries.map((entry) {
                final category = entry.key;
                final categoryMcqs = entry.value;
                return _buildCategoryCard(
                  context,
                  category,
                  categoryMcqs,
                  isSmallScreen,
                );
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
    bool isSmallScreen,
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
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPage(category: category, mcqs: mcqs),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.shade400, color.shade600],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: isSmallScreen ? 32 : 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isSmallScreen ? 16 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${mcqs.length} Questions Available',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
