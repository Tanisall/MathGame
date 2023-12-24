class Score {
  String owner;
  String pola;
  int score;

  Score({required this.pola, required this.score, required this.owner});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      owner: json['owner'],
      pola: json['pola'],
      score: json['score'],
    );
  }
}
