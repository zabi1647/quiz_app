import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/models/mcq_model.dart';
import 'package:quiz_app/models/user_performance_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // MCQ Operations
  Future<String> addMCQ(MCQModel mcq) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('mcqs')
          .add(mcq.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add MCQ: $e');
    }
  }

  Future<void> updateMCQ(String id, MCQModel mcq) async {
    try {
      await _firestore
          .collection('mcqs')
          .doc(id)
          .update(mcq.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update MCQ: $e');
    }
  }

  Future<void> deleteMCQ(String id) async {
    try {
      await _firestore.collection('mcqs').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete MCQ: $e');
    }
  }

  Stream<List<MCQModel>> getMCQs() {
    return _firestore
        .collection('mcqs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MCQModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      // Get all MCQs
      QuerySnapshot mcqSnapshot = await _firestore.collection('mcqs').get();
      List<MCQModel> mcqs = mcqSnapshot.docs
          .map(
            (doc) =>
                MCQModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Calculate total attempts
      int totalAttempts = mcqs.fold(0, (sum, mcq) => sum + mcq.attemptsCount);

      // Most attempted questions
      List<MCQModel> mostAttempted = List.from(mcqs)
        ..sort((a, b) => b.attemptsCount.compareTo(a.attemptsCount));

      // Most missed questions (highest incorrect count)
      List<MCQModel> mostMissed = List.from(mcqs)
        ..sort((a, b) => b.incorrectCount.compareTo(a.incorrectCount));

      // Category distribution
      Map<String, int> categoryCount = {};
      for (var mcq in mcqs) {
        categoryCount[mcq.category] = (categoryCount[mcq.category] ?? 0) + 1;
      }

      // Difficulty distribution
      Map<String, int> difficultyCount = {};
      for (var mcq in mcqs) {
        difficultyCount[mcq.difficulty] =
            (difficultyCount[mcq.difficulty] ?? 0) + 1;
      }

      return {
        'totalMCQs': mcqs.length,
        'totalAttempts': totalAttempts,
        'mostAttempted': mostAttempted.take(5).toList(),
        'mostMissed': mostMissed.take(5).toList(),
        'categoryDistribution': categoryCount,
        'difficultyDistribution': difficultyCount,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // User Performance
  Stream<List<UserPerformanceModel>> getUserPerformances() {
    return _firestore
        .collection('user_performances')
        .orderBy('averageScore', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserPerformanceModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<int> getTotalUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('user_performances')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Search MCQs
  Future<List<MCQModel>> searchMCQs(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('mcqs').get();
      List<MCQModel> allMcqs = snapshot.docs
          .map(
            (doc) =>
                MCQModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Filter by question text or category
      return allMcqs
          .where(
            (mcq) =>
                mcq.question.toLowerCase().contains(query.toLowerCase()) ||
                mcq.category.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search MCQs: $e');
    }
  }
}
