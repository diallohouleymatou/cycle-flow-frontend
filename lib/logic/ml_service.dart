import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Service gérant la logique prédictive locale (Edge AI)
class MLCyclePredictor {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // Singleton
  static final MLCyclePredictor _instance = MLCyclePredictor._internal();
  factory MLCyclePredictor() => _instance;
  MLCyclePredictor._internal();

  /// Initialise le modèle TFLite
  Future<void> init() async {
    try {
      // TODO: Placer le fichier .tflite dans assets/models/cycle_model.tflite
      // Pour l'instant, on gère l'absence de modèle pour le "Cold Start"
      // _interpreter = await Interpreter.fromAsset('models/cycle_model.tflite');
      _isModelLoaded = true;
      print("ML Model loaded successfully (Mock mode for now)");
    } catch (e) {
      print("Error loading ML model: $e");
      _isModelLoaded = false;
    }
  }

  /// Prédit la probabilité que les règles arrivent aujourd'hui (0.0 à 1.0)
  /// [dayOfCycle]: Jour actuel du cycle (ex: J-25)
  /// [avgCycleLength]: Longueur moyenne historique (ex: 28)
  /// [symptomsScore]: Score normalisé (0-1) des symptômes (douleurs, humeur...)
  /// [biometricsScore]: Score normalisé (0-1) des signaux corporels (RHR, Temp...)
  Future<double> predictPeriodLikelihood({
    required int dayOfCycle,
    required int avgCycleLength,
    double symptomsScore = 0.0,
    double biometricsScore = 0.0,
  }) async {
    // Si le modèle n'est pas prêt, on utilise l'heuristique "Cold Start"
    if (_interpreter == null) {
      return _heuristicPrediction(
        dayOfCycle,
        avgCycleLength,
        symptomsScore,
        biometricsScore,
      );
    }

    // TODO: Implémentation réelle TFLite
    // var input = [[dayOfCycle, avgCycleLength, symptomsScore, biometricsScore]];
    // var output = List.filled(1, 0).reshape([1, 1]);
    // _interpreter!.run(input, output);
    // return output[0][0];
    
    return 0.0;
  }

  /// Algorithme "Cold Start" (Logique probabiliste sans réseau de neurones)
  /// Utilisé quand l'utilisateur n'a pas encore assez d'historique pour le Fine-Tuning
  double _heuristicPrediction(
    int day,
    int avgLength,
    double symp,
    double bio,
  ) {
    // 1. Probabilité de base (Gaussienne centrée sur la durée moyenne)
    // Plus on est proche de la date prévue, plus la proba augmente
    double baseProb = _gaussian(day.toDouble(), avgLength.toDouble(), 1.5);

    // 2. Facteur d'irrégularité (Adaptation)
    // Si on dépasse la date prévue, la proba reste haute au lieu de chuter
    if (day > avgLength) {
      baseProb = 0.4 + (0.1 * (day - avgLength)); // Augmente doucement
      if (baseProb > 0.9) baseProb = 0.9;
    }

    // 3. Fusion avec les biomarqueurs (C'est là que la magie opère pour les irréguliers)
    // Les symptômes physiques "pèsent" 60% de la décision finale s'ils sont forts
    double physiologicalSignal = (symp + bio) / 2; // Moyenne des signaux

    double finalProb;
    if (physiologicalSignal > 0.5) {
      // Si le corps parle fort, on l'écoute plus que le calendrier
      finalProb = (baseProb * 0.4) + (physiologicalSignal * 0.6);
    } else {
      // Sinon on fait confiance au calendrier
      finalProb = (baseProb * 0.8) + (physiologicalSignal * 0.2);
    }

    return finalProb.clamp(0.0, 1.0);
  }

  double _gaussian(double x, double mu, double sigma) {
    var expVal = -pow(x - mu, 2) / (2 * pow(sigma, 2));
    return exp(expVal);
  }
}
