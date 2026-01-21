class VaultRecord {
  final String entityId;
  final String content;
  final DateTime updatedAt;

  VaultRecord({
    required this.entityId,
    required this.content,
    required this.updatedAt,
  });
}

/// Modèle riche représentant une journée de données pour le ML
class DailyHealthLog {
  final DateTime date;
  
  // -- Données Cycle --
  final bool isPeriodStart;
  final String? flowIntensity; // Light, Medium, Heavy
  
  // -- Biométrie (Google Fit / HealthKit) --
  final double? restingHeartRate; // bpm
  final double? bodyTemperature; // Celsius
  final double? sleepHours;
  final int? sleepQualityScore; // 0-100
  
  // -- Symptômes Subjectifs (User Input) --
  final double moodScore; // 0.0 (Sad) - 1.0 (Happy)
  final double painScore; // 0.0 (None) - 1.0 (Severe)
  final String? cervicalMucus; // Dry, Sticky, Creamy, EggWhite

  DailyHealthLog({
    required this.date,
    this.isPeriodStart = false,
    this.flowIntensity,
    this.restingHeartRate,
    this.bodyTemperature,
    this.sleepHours,
    this.sleepQualityScore,
    this.moodScore = 0.5,
    this.painScore = 0.0,
    this.cervicalMucus,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'isPeriodStart': isPeriodStart,
      'flowIntensity': flowIntensity,
      'restingHeartRate': restingHeartRate,
      'bodyTemperature': bodyTemperature,
      'sleepHours': sleepHours,
      'sleepQualityScore': sleepQualityScore,
      'moodScore': moodScore,
      'painScore': painScore,
      'cervicalMucus': cervicalMucus,
    };
  }

  factory DailyHealthLog.fromJson(Map<String, dynamic> json) {
    return DailyHealthLog(
      date: DateTime.parse(json['date']),
      isPeriodStart: json['isPeriodStart'] ?? false,
      flowIntensity: json['flowIntensity'],
      restingHeartRate: json['restingHeartRate'],
      bodyTemperature: json['bodyTemperature'],
      sleepHours: json['sleepHours'],
      sleepQualityScore: json['sleepQualityScore'],
      moodScore: json['moodScore'] ?? 0.5,
      painScore: json['painScore'] ?? 0.0,
      cervicalMucus: json['cervicalMucus'],
    );
  }
  
  /// Calcule un score global de "symptômes prémenstruels" pour le ML
  double get aggregateSymptomScore {
    // Exemple simple : Douleur + (1 - Humeur)
    return (painScore + (1.0 - moodScore)) / 2;
  }
}