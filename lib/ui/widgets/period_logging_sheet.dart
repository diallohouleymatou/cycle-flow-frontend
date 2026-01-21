import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../styles/app_theme.dart';
import 'primary_button.dart';

class PeriodLoggingSheet extends StatefulWidget {
  final Function(DateTime date, String intensity) onSave;

  const PeriodLoggingSheet({super.key, required this.onSave});

  @override
  State<PeriodLoggingSheet> createState() => _PeriodLoggingSheetState();
}

class _PeriodLoggingSheetState extends State<PeriodLoggingSheet> {
  DateTime _selectedDate = DateTime.now();
  String _selectedIntensity = "Moyen";

  final List<String> _intensities = ["Léger", "Moyen", "Abondant"];

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  "Enregistrer mes règles",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  "Sélectionne la date de début et l'intensité de ton flux.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSub),
                ),
                const SizedBox(height: 32),
                
                Text("Quand ont-elles commencé ?", style: theme.textTheme.titleSmall),
                const SizedBox(height: 16),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDateOption("Hier", DateTime.now().subtract(const Duration(days: 1))),
                      const SizedBox(width: 12),
                      _buildDateOption("Aujourd'hui", DateTime.now()),
                      const SizedBox(width: 12),
                      _buildDateOption("Autre", null, isOther: true),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text("Intensité du flux", style: theme.textTheme.titleSmall),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _intensities.map((intensity) => _buildIntensityItem(intensity)).toList(),
                ),
                
                const SizedBox(height: 40),
                
                PrimaryButton(
                  label: "CONFIRMER",
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    widget.onSave(_selectedDate, _selectedIntensity);
                  },
                  backgroundColor: AppTheme.accentPeriod,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateOption(String label, DateTime? date, {bool isOther = false}) {
    bool isSelected = false;
    if (date != null) {
      isSelected = _selectedDate.year == date.year && 
                   _selectedDate.month == date.month && 
                   _selectedDate.day == date.day;
    } else if (isOther) {
      isSelected = !_isToday(_selectedDate) && !_isYesterday(_selectedDate);
    }

        return Semantics(

          button: true,

          selected: isSelected,

          label: label,

          child: GestureDetector(

            onTap: () {

              HapticFeedback.selectionClick();

              if (date != null) {

                setState(() => _selectedDate = date);

              } else {

                showDatePicker(

                  context: context,

                  initialDate: _selectedDate,

                  firstDate: DateTime(2020),

                  lastDate: DateTime.now(),

                  builder: (context, child) {

                    return Theme(

                      data: AppTheme.lightTheme.copyWith(

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

                ).then((picked) {

                  if (picked != null) setState(() => _selectedDate = picked);

                });

              }

            },

            child: AnimatedContainer(

              duration: const Duration(milliseconds: 200),

              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),

              decoration: BoxDecoration(

                color: isSelected ? AppTheme.primaryBrand : AppTheme.surfaceLight,

                borderRadius: BorderRadius.circular(16),

              ),

              child: Text(

                isOther && isSelected 

                    ? DateFormat('d MMM', 'fr_FR').format(_selectedDate) 

                    : label,

                style: TextStyle(

                  color: isSelected ? Colors.white : AppTheme.textMain,

                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,

                ),

              ),

            ),

          ),

        );

      }

    

      Widget _buildIntensityItem(String label) {

        final isSelected = _selectedIntensity == label;

        int count = 1;

        if (label == "Moyen") count = 2;

        if (label == "Abondant") count = 3;

    

        return Semantics(

          button: true,

          selected: isSelected,

          label: "Flux $label",

          child: GestureDetector(

            onTap: () {

              HapticFeedback.selectionClick();

              setState(() => _selectedIntensity = label);

            },

            child: AnimatedContainer(

              duration: const Duration(milliseconds: 250),

              width: 100,

              padding: const EdgeInsets.symmetric(vertical: 20),

              decoration: BoxDecoration(

                color: isSelected ? AppTheme.surfacePeriod : AppTheme.surfaceLight,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(

                  color: isSelected ? AppTheme.accentPeriod.withOpacity(0.5) : Colors.transparent,

                  width: 2,

                ),

              ),

              child: Column(

                children: [

                  Row(

                    mainAxisAlignment: MainAxisAlignment.center,

                    children: List.generate(count, (index) => 

                      Icon(

                        Icons.water_drop_rounded, 

                        size: 20, 

                        color: isSelected ? AppTheme.accentPeriod : AppTheme.textSub.withOpacity(0.3)

                      )

                    ),

                  ),

                  const SizedBox(height: 12),

                  Text(

                    label,

                    style: TextStyle(

                      fontSize: 13,

                      color: isSelected ? AppTheme.accentPeriod : AppTheme.textSub,

                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,

                    ),

                  )

                ],

              ),

            ),

          ),

        );

      }

    }

    