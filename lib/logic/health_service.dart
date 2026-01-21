import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  /// Types de données nécessaires pour notre algorithme ML
  static const List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BODY_TEMPERATURE, // Souvent manuel ou thermomètres connectés
    HealthDataType.SLEEP_SESSION, // Pour la qualité du sommeil
  ];

  /// Demande les permissions à l'utilisateur (Apple Health / Google Fit)
  Future<bool> requestPermissions() async {
    // Check si l'API est supportée sur le device
    // Note: configure() est nécessaire avant use sur Android depuis v10+
    await _health.configure(); 
    
    bool? hasPermissions = await _health.hasPermissions(_types);
    if (hasPermissions == false) {
        try {
          return await _health.requestAuthorization(_types);
        } catch (e) {
          print("Erreur lors de la demande de permissions Health: $e");
          return false;
        }
    }
    return true;
  }

  /// Récupère la moyenne RHR (Resting Heart Rate) pour une journée
  /// Utile pour détecter le shift de phase lutéale
  Future<double?> getRestingHeartRate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    try {
      List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.HEART_RATE],
      );

      if (points.isEmpty) return null;

      // Calcul moyenne simple (idéalement on filtrerait pour le repos strict)
      double sum = 0;
      int count = 0;
      for (var p in points) {
        if (p.value is NumericHealthValue) {
           sum += (p.value as NumericHealthValue).numericValue.toDouble();
           count++;
        }
      }
      return count > 0 ? sum / count : null;
    } catch (e) {
      print("Erreur fetch HeartRate: $e");
      return null;
    }
  }

  /// Récupère la température basale (si dispo)
  Future<double?> getBodyTemperature(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    try {
      List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.BODY_TEMPERATURE],
      );

      if (points.isEmpty) return null;
      // On prend la première valeur du matin idéalement, ici la moyenne
       double sum = 0;
      int count = 0;
      for (var p in points) {
        if (p.value is NumericHealthValue) {
           sum += (p.value as NumericHealthValue).numericValue.toDouble();
           count++;
        }
      }
      return count > 0 ? sum / count : null;
    } catch (e) {
      return null;
    }
  }
}
