import 'package:flutter/material.dart';
import '../data/services/api_service.dart';

class CyclePrediction {
  final DateTime nextPeriodDate;
  final int avgCycleLength;
  final int daysUntilNext;

  CyclePrediction({
    required this.nextPeriodDate, 
    required this.avgCycleLength, 
    required this.daysUntilNext
  });

  factory CyclePrediction.fromJson(Map<String, dynamic> json) {
    return CyclePrediction(
      nextPeriodDate: DateTime.parse(json['nextPeriodDate']),
      avgCycleLength: json['avgCycleLength'],
      daysUntilNext: json['daysUntilNext'],
    );
  }
}

class CycleProvider extends ChangeNotifier {
  final ApiService _api;
  
  CyclePrediction? _prediction;
  List<dynamic> _history = [];
  bool _isLoading = false;

  CycleProvider(this._api);

  CyclePrediction? get prediction => _prediction;
  List<dynamic> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final predJson = await _api.get('/cycles/predictions');
      if (predJson != null) {
        _prediction = CyclePrediction.fromJson(predJson);
      }
      _history = await _api.get('/cycles/history');
    } catch (e) {
      print('Error fetching cycle data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startPeriod(DateTime date) async {
    await _api.post('/cycles/start', {'date': date.toIso8601String()});
    await refreshData();
  }

  Future<void> endPeriod(DateTime date) async {
    await _api.post('/cycles/end', {'date': date.toIso8601String()});
    await refreshData();
  }
}
