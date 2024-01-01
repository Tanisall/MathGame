class Score {
  String pola;
  int score;

  Score({
    required this.pola,
    required this.score,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      pola: json['pola'],
      score: json['score'] ?? 0,
    );
  }
}
