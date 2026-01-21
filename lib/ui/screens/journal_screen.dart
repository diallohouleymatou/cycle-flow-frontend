import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/journal_provider.dart';
import '../styles/app_theme.dart';

class JournalScreen extends StatefulWidget {
  final DateTime? initialDate;

  const JournalScreen({super.key, this.initialDate});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late DateTime _selectedDate;
  final List<String> _selectedSymptoms = [];
  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _symptomOptions = [
    {'label': 'Crampes', 'icon': Icons.bolt},
    {'label': 'Maux de tête', 'icon': Icons.sick},
    {'label': 'Fatigue', 'icon': Icons.bed},
    {'label': 'Ballonnement', 'icon': Icons.water},
    {'label': 'Acné', 'icon': Icons.face},
    {'label': 'Fringales', 'icon': Icons.restaurant},
    {'label': 'Insomnie', 'icon': Icons.nightlight},
    {'label': 'Douleur seins', 'icon': Icons.favorite_border},
  ];

  final List<Map<String, dynamic>> _moodOptions = [
    {'label': 'Heureuse', 'emoji': '😊'},
    {'label': 'Calme', 'emoji': '😌'},
    {'label': 'Triste', 'emoji': '😢'},
    {'label': 'Irritable', 'emoji': '😠'},
    {'label': 'Anxieuse', 'emoji': '😰'},
    {'label': 'Fatiguée', 'emoji': '😴'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadEntryForDate(_selectedDate);
  }

  void _loadEntryForDate(DateTime date) {
    final entry = context.read<JournalProvider>().getEntryForDate(date);
    setState(() {
      _selectedSymptoms.clear();
      if (entry != null) {
        _selectedSymptoms.addAll(entry.symptoms);
        _selectedMood = entry.mood;
        _notesController.text = entry.notes ?? '';
      } else {
        _selectedMood = null;
        _notesController.clear();
      }
    });
  }

  void _saveEntry() {
    final entry = JournalEntry(
      date: _selectedDate,
      symptoms: List.from(_selectedSymptoms),
      mood: _selectedMood,
      notes: _notesController.text,
    );
    context.read<JournalProvider>().addEntry(entry);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Journal mis à jour avec succès"),
        backgroundColor: AppTheme.secondaryBrand,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Journal', style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            color: AppTheme.primaryBrand,
            onPressed: _saveEntry,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selector
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppTheme.primaryBrand,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppTheme.textMain,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() => _selectedDate = picked);
                  _loadEntryForDate(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.textMain.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryBrand),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Mood Section
            Text("Comment vous sentez-vous ?", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _moodOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final mood = _moodOptions[index];
                  final isSelected = _selectedMood == mood['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood['label']),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.tertiaryBrand.withOpacity(0.3) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppTheme.textMain : Colors.transparent,
                              width: 2
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              mood['emoji'],
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppTheme.textMain : AppTheme.textSub,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Symptoms Section
            Text("Symptômes", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _symptomOptions.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom['label']);
                return FilterChip(
                  selected: isSelected,
                  label: Text(symptom['label']),
                  avatar: Icon(
                    symptom['icon'], 
                    size: 16, 
                    color: isSelected ? Colors.white : AppTheme.textSub
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: AppTheme.primaryBrand,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textMain,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  elevation: 2,
                  pressElevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? Colors.transparent : Colors.black12),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom['label']);
                      } else {
                        _selectedSymptoms.remove(symptom['label']);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // Notes Section
            Text("Notes personnelles", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Quelque chose de spécial aujourd'hui ?",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveEntry,
        icon: const Icon(Icons.save),
        label: const Text("Enregistrer"),
        backgroundColor: AppTheme.primaryBrand,
      ),
    );
  }
}