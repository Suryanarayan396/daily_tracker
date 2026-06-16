class ScoreCalculator {
  ScoreCalculator._();

  /// Calculates a daily reflection score (e.g., scale of 1-100)
  /// based on reflection rating, learning hours, and finance savings.
  static double calculateDailyScore({
    required double reflectionRating, // 1 to 5
    required double learningHours,   // e.g. 0 to 8
    required bool completedGoals,
    required double financeSavings,  // positive savings add to score
  }) {
    double score = 0;
    
    // Reflection contribution (up to 40 points)
    score += (reflectionRating / 5.0) * 40.0;
    
    // Learning contribution (up to 30 points, max 4 hours for full score)
    final clampedHours = learningHours.clamp(0.0, 4.0);
    score += (clampedHours / 4.0) * 30.0;
    
    // Completed goals contribution (up to 20 points)
    if (completedGoals) {
      score += 20.0;
    }
    
    // Finance savings contribution (up to 10 points)
    if (financeSavings > 0) {
      score += 10.0;
    }
    
    return score.clamp(0.0, 100.0);
  }
}
