import 'package:quiz_app/models/mcq_model.dart';

class SpacedRepetitionService {
  static List<MCQModel> sortByPriority(List<MCQModel> mcqs) {
    List<MCQModel> sortedMcqs = List.from(mcqs);

    sortedMcqs.sort((a, b) {
      double priorityA = _calculatePriority(a);
      double priorityB = _calculatePriority(b);
      return priorityB.compareTo(priorityA);
    });

    return sortedMcqs;
  }

  static double _calculatePriority(MCQModel mcq) {
    if (mcq.attemptsCount == 0) {
      return 5.0;
    }

    double errorRate = mcq.incorrectCount / mcq.attemptsCount;

    double baseScore = errorRate * 10;

    double incorrectWeight = mcq.incorrectCount * 0.5;

    return baseScore + incorrectWeight;
  }

  static List<MCQModel> selectQuestionsForQuiz(
    List<MCQModel> allMcqs,
    int count,
  ) {
    if (allMcqs.length <= count) {
      return allMcqs;
    }

    List<MCQModel> selected = [];

    List<MCQModel> sortedByPriority = sortByPriority(allMcqs);

    int difficultCount = (count * 0.7).round();
    selected.addAll(sortedByPriority.take(difficultCount));

    List<MCQModel> remaining = sortedByPriority.skip(difficultCount).toList();
    remaining.shuffle();

    int randomCount = count - difficultCount;
    if (remaining.length > randomCount) {
      selected.addAll(remaining.take(randomCount));
    } else {
      selected.addAll(remaining);
    }

    selected.shuffle();

    return selected;
  }

  static String getDifficultyLabel(MCQModel mcq) {
    if (mcq.attemptsCount == 0) {
      return 'Not Attempted';
    }

    double errorRate = mcq.incorrectCount / mcq.attemptsCount;

    if (errorRate >= 0.7) {
      return 'Very Difficult';
    } else if (errorRate >= 0.5) {
      return 'Difficult';
    } else if (errorRate >= 0.3) {
      return 'Medium';
    } else {
      return 'Easy';
    }
  }

  static int getReviewIntervalDays(MCQModel mcq) {
    if (mcq.attemptsCount == 0) {
      return 1; // Review soon if never attempted
    }

    double errorRate = mcq.incorrectCount / mcq.attemptsCount;

    if (errorRate >= 0.7) {
      return 1; // Review daily if very difficult
    } else if (errorRate >= 0.5) {
      return 3; // Review every 3 days if difficult
    } else if (errorRate >= 0.3) {
      return 7; // Review weekly if medium
    } else {
      return 14; // Review bi-weekly if easy
    }
  }
}
