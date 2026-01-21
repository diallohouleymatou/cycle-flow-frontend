class FertilityCalculator {
  /// Calcule la date d'ovulation estimée
  /// [lastPeriodDate] : Date du premier jour des dernières règles
  /// [cycleLength] : Durée moyenne du cycle (par défaut 28 jours)
  static DateTime calculateEstimatedOvulation(DateTime lastPeriodDate, {int cycleLength = 28}) {
    // L'ovulation se produit généralement 14 jours avant les prochaines règles
    final nextPeriod = lastPeriodDate.add(Duration(days: cycleLength));
    return nextPeriod.subtract(const Duration(days: 14));
  }

  /// Vérifie si une date donnée est dans la fenêtre fertile
  static bool isFertileWindow(DateTime dateToCheck, DateTime ovulationDate) {
    // La fenêtre fertile est souvent considérée comme 5 jours avant l'ovulation et 1 jour après
    final startWindow = ovulationDate.subtract(const Duration(days: 5));
    final endWindow = ovulationDate.add(const Duration(days: 1));
    
    // On normalise les dates pour ignorer l'heure (comparaison jour seulement)
    final check = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    final start = DateTime(startWindow.year, startWindow.month, startWindow.day);
    final end = DateTime(endWindow.year, endWindow.month, endWindow.day);

    return (check.isAfter(start) || check.isAtSameMomentAs(start)) && 
           (check.isBefore(end) || check.isAtSameMomentAs(end));
  }

  /// Évalue le risque de grossesse
  /// Retourne un niveau de risque : 0 (Nul/Inconnu), 1 (Faible), 2 (Moyen), 3 (Élevé)
  /// et un message explicatif.
  static RiskAssessment assessPregnancyRisk({
    required DateTime intercourseDate,
    required DateTime lastPeriodDate,
    required int cycleLength,
    required bool usedContraception,
    String? contraceptionMethod, // 'pill', 'condom', 'none'
  }) {
    if (usedContraception) {
      if (contraceptionMethod == 'condom') {
        return RiskAssessment(
          level: RiskLevel.low,
          message: "Si le préservatif a été utilisé correctement, le risque est faible.",
          colorHex: 0xFF4CAF50, // Green
        );
      }
      return RiskAssessment(
        level: RiskLevel.veryLow,
        message: "Avec une contraception hormonale régulière, le risque est minime.",
        colorHex: 0xFF81C784, // Light Green
      );
    }

    final ovulationDate = calculateEstimatedOvulation(lastPeriodDate, cycleLength: cycleLength);
    final isFertile = isFertileWindow(intercourseDate, ovulationDate);

    if (isFertile) {
       // Check if closer to ovulation day (Higher risk)
       final diff = intercourseDate.difference(ovulationDate).inDays.abs();
       if (diff <= 1) {
         return RiskAssessment(
           level: RiskLevel.high,
           message: "Attention : Rapport non protégé très proche de l'ovulation estimée.",
           colorHex: 0xFFE53935, // Red
         );
       }
       return RiskAssessment(
         level: RiskLevel.medium,
         message: "Rapport non protégé dans la fenêtre fertile théorique.",
         colorHex: 0xFFFB8C00, // Orange
       );
    }

    return RiskAssessment(
      level: RiskLevel.low,
      message: "Rapport en dehors de la fenêtre fertile théorique, mais le risque zéro n'existe pas sans contraception.",
      colorHex: 0xFFCDDC39, // Lime
    );
  }
}

enum RiskLevel { veryLow, low, medium, high }

class RiskAssessment {
  final RiskLevel level;
  final String message;
  final int colorHex;

  RiskAssessment({required this.level, required this.message, required this.colorHex});
}
