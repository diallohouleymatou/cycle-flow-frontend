import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/api_service.dart';
import 'ml_service.dart';
import 'health_service.dart';
import 'journal_provider.dart';

enum CyclePhase { menstrual, follicular, ovulation, luteal }

class CyclePrediction {
  final DateTime nextPeriodDate;
  final int avgCycleLength;
  final int daysUntilNext;
  final CyclePhase currentPhase;
  final int dayOfCycle;
  final double periodProbability; // ML Probability

  CyclePrediction({
    required this.nextPeriodDate,
    required this.avgCycleLength,
    required this.daysUntilNext,
    this.currentPhase = CyclePhase.follicular,
    this.dayOfCycle = 1,
    this.periodProbability = 0.0,
  });

  factory CyclePrediction.fromJson(Map<String, dynamic> json) {
    return CyclePrediction(
      nextPeriodDate: DateTime.parse(json['nextPeriodDate']),
      avgCycleLength: json['avgCycleLength'],
      daysUntilNext: json['daysUntilNext'],
      currentPhase: _parsePhase(json['currentPhase']),
      dayOfCycle: json['dayOfCycle'] ?? 1,
      periodProbability: (json['periodProbability'] ?? 0.0).toDouble(),
    );
  }

  static CyclePhase _parsePhase(String? phase) {
    switch (phase?.toLowerCase()) {
      case 'menstrual':
        return CyclePhase.menstrual;
      case 'follicular':
        return CyclePhase.follicular;
      case 'ovulation':
        return CyclePhase.ovulation;
      case 'luteal':
        return CyclePhase.luteal;
      default:
        return CyclePhase.follicular;
    }
  }
}

class CycleProvider extends ChangeNotifier {
  final ApiService _api;
  final JournalProvider _journal;
  final MLCyclePredictor _mlPredictor = MLCyclePredictor();
  final HealthService _healthService = HealthService();

  CyclePrediction? _prediction;
  List<dynamic> _history = [];
  bool _isLoading = false;
  int _cycleLength = 28;

  CycleProvider(this._api, this._journal) {
    _init();
  }

  CyclePrediction? get prediction => _prediction;
  List<dynamic> get history => _history;
  bool get isLoading => _isLoading;
  int get cycleLength => _cycleLength;

  Future<void> _init() async {
    await _loadPreferences();
    await _mlPredictor.init();
    // Request health permissions to ensure biometrics can be fetched
    // We do this silently or let the UI trigger it
    // await _healthService.requestPermissions(); 
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _cycleLength = prefs.getInt('cycleLength') ?? 28;
    notifyListeners();
  }

  Future<void> setCycleLength(int length) async {
    _cycleLength = length;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cycleLength', length);
    await _calculateLocalPrediction();
    notifyListeners();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    try {
      try {
        final predJson = await _api.get('/cycles/predictions');
        if (predJson != null) {
          _prediction = CyclePrediction.fromJson(predJson);
        }
        _history = await _api.get('/cycles/history');
      } catch (e) {
        await _calculateLocalPrediction();
      }

      if (_prediction == null) {
        await _calculateLocalPrediction();
      }
    } catch (e) {
      print('Error calculating cycle data: $e');
      await _calculateLocalPrediction();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _calculateLocalPrediction() async {
    // 1. Determine Start Date (Real date from history)
    DateTime lastPeriodStart;
    
    if (_history.isNotEmpty) {
      try {
        final sortedHistory = List.from(_history);
        sortedHistory.sort((a, b) {
           DateTime dateA = DateTime.parse(a['date'] ?? a['startDate']);
           DateTime dateB = DateTime.parse(b['date'] ?? b['startDate']);
           return dateB.compareTo(dateA); // Descending
        });
        lastPeriodStart = DateTime.parse(sortedHistory.first['date'] ?? sortedHistory.first['startDate']);
      } catch (e) {
         lastPeriodStart = DateTime.now().subtract(const Duration(days: 28));
      }
    } else {
       // If no history, assume due now for safety
       lastPeriodStart = DateTime.now().subtract(Duration(days: _cycleLength)); 
    }

    // 2. Math-based Prediction (The "Theoretical" date)
    DateTime nextPeriod = lastPeriodStart.add(Duration(days: _cycleLength));
    
    // Normalize today for accurate day diff (strip time)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextPeriodNormalized = DateTime(nextPeriod.year, nextPeriod.month, nextPeriod.day);
    
    int daysUntil = nextPeriodNormalized.difference(today).inDays;
    
    // Safety: Calculate Current Cycle Day
    final lastStartNormalized = DateTime(lastPeriodStart.year, lastPeriodStart.month, lastPeriodStart.day);
    int dayOfCycle = today.difference(lastStartNormalized).inDays + 1;
    if (dayOfCycle < 1) dayOfCycle = 1;

    // 3. Determine Phase
    CyclePhase phase;
    if (dayOfCycle <= 5) {
      phase = CyclePhase.menstrual;
    } else if (dayOfCycle <= (_cycleLength / 2) - 2) {
      phase = CyclePhase.follicular;
    } else if (dayOfCycle <= (_cycleLength / 2) + 2) {
      phase = CyclePhase.ovulation;
    } else {
      phase = CyclePhase.luteal;
    }

    // 4. ML Enhancement (The "Adaptive" Logic)
    
    // Fetch live biometrics (Real data from Apple Health / Google Fit)
    // Note: On simulators, this will likely be null.
    double? rhr = await _healthService.getRestingHeartRate(DateTime.now());
    double? temp = await _healthService.getBodyTemperature(DateTime.now());
    
    // Biometric Scoring
    double bioScore = 0.0;
    // RHR usually drops before period. If it's high, period might be delayed.
    // If it drops significantly (requires history tracking), period is imminent.
    // Simplified heuristic for now:
    if (rhr != null) {
       // Placeholder logic: ideally we compare to user's baseline
       if (rhr > 65) bioScore += 0.2; 
    }
    if (temp != null) {
       // Temp drops before period
       if (temp < 36.6 && phase == CyclePhase.luteal) bioScore += 0.4;
    }

    // Symptom Scoring (Connected to Journal)
    double symptomScore = 0.0; 
    final todayEntry = _journal.getEntryForDate(DateTime.now());
    
    if (todayEntry != null) {
      if (todayEntry.symptoms.contains('Cramps') || todayEntry.symptoms.contains('Douleurs')) symptomScore += 0.3;
      if (todayEntry.symptoms.contains('Spotting')) symptomScore += 0.5; // Strong indicator
      if (todayEntry.mood == 'Sad' || todayEntry.mood == 'Irritable') symptomScore += 0.2;
    }

    // Get Probability from ML Service
    double mlProbability = await _mlPredictor.predictPeriodLikelihood(
      dayOfCycle: dayOfCycle,
      avgCycleLength: _cycleLength,
      symptomsScore: symptomScore,
      biometricsScore: bioScore,
    );

    // 5. Dynamic Adjustment of "Days Remaining"
    // If the ML is very sure (> 70%) that period is coming today/tomorrow,
    // we override the math calculation.
    if (mlProbability > 0.7 && daysUntil > 1) {
       daysUntil = 1; // "Demain ou aujourd'hui"
       // We could also visually indicate this override in the UI later
    }

    _prediction = CyclePrediction(
      nextPeriodDate: nextPeriod,
      avgCycleLength: _cycleLength,
      daysUntilNext: daysUntil < 0 ? 0 : daysUntil, // Never show negative days
      currentPhase: phase,
      dayOfCycle: dayOfCycle,
      periodProbability: mlProbability,
    );
  }

  Future<void> startPeriod(DateTime date) async {
    try {
      await _api.post('/cycles/start', {'date': date.toIso8601String()});
      _history.add({'date': date.toIso8601String(), 'type': 'start'});
    } catch (_) {
       _history.add({'date': date.toIso8601String(), 'type': 'start'});
    }
    await _calculateLocalPrediction();
    notifyListeners();
  }

  Future<void> endPeriod(DateTime date) async {
    try {
      await _api.post('/cycles/end', {'date': date.toIso8601String()});
    } catch (_) {}
    await refreshData();
  }
}