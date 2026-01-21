import 'package:flutter/material.dart';

class JournalEntry {
  final DateTime date;
  final List<String> symptoms;
  final String? mood;
  final String? notes;

  JournalEntry({
    required this.date,
    this.symptoms = const [],
    this.mood,
    this.notes,
  });
}

class JournalProvider extends ChangeNotifier {
  final List<JournalEntry> _entries = [];

  List<JournalEntry> get entries => _entries;

  void addEntry(JournalEntry entry) {
    // Remove existing entry for same date if exists
    _entries.removeWhere((e) => 
      e.date.year == entry.date.year && 
      e.date.month == entry.date.month && 
      e.date.day == entry.date.day
    );
    
    _entries.add(entry);
    notifyListeners();
  }

  JournalEntry? getEntryForDate(DateTime date) {
    try {
      return _entries.firstWhere((e) => 
        e.date.year == date.year && 
        e.date.month == date.month && 
        e.date.day == date.day
      );
    } catch (_) {
      return null;
    }
  }
}
