import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/cycle_provider.dart';
import '../styles/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final theme = Theme.of(context);
    
    // Simple calendar generation logic
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Calendrier', style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => setState(() => _focusedDay = DateTime.now()),
          )
        ],
      ),
      body: Column(
        children: [
          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: theme.iconTheme.color ?? AppTheme.textMain,
                  onPressed: () => setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                  }),
                ),
                const SizedBox(width: 16),
                Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(_focusedDay).toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBrand,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: theme.iconTheme.color ?? AppTheme.textMain,
                  onPressed: () => setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                  }),
                ),
              ],
            ),
          ),
          
          // Days of Week Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) => 
                SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSub,
                    ),
                  ),
                )
              ).toList(),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Calendar Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: daysInMonth + startingWeekday - 1,
              itemBuilder: (context, index) {
                if (index < startingWeekday - 1) {
                  return const SizedBox();
                }
                
                final day = index - (startingWeekday - 1) + 1;
                final currentDate = DateTime(_focusedDay.year, _focusedDay.month, day);
                final isToday = currentDate.year == DateTime.now().year && 
                                currentDate.month == DateTime.now().month && 
                                currentDate.day == DateTime.now().day;
                
                // Prediction Logic for Calendar Highlight
                bool isPredictedPeriod = false;
                bool isPredictedOvulation = false;
                
                if (cycle.prediction != null) {
                   final nextPeriod = cycle.prediction!.nextPeriodDate;
                   // Simple logic: highlight 5 days starting from nextPeriod
                   final diff = currentDate.difference(nextPeriod).inDays;
                   if (diff >= 0 && diff < 5) {
                     isPredictedPeriod = true;
                   }
                   
                   // Ovulation is roughly 14 days before next period
                   final ovulationDate = nextPeriod.subtract(const Duration(days: 14));
                   if (currentDate.year == ovulationDate.year && 
                       currentDate.month == ovulationDate.month && 
                       currentDate.day == ovulationDate.day) {
                     isPredictedOvulation = true;
                   }
                }

                return GestureDetector(
                  onTap: () {
                     // Future: Log symptoms for this date
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isToday 
                          ? AppTheme.textMain 
                          : isPredictedPeriod 
                              ? AppTheme.primaryBrand.withOpacity(0.8)
                              : isPredictedOvulation
                                  ? AppTheme.tertiaryBrand
                                  : Colors.white,
                      shape: BoxShape.circle,
                      border: isToday ? null : Border.all(color: Colors.transparent),
                      boxShadow: (isPredictedPeriod || isToday) ? [
                        BoxShadow(
                          color: (isToday ? Colors.black : AppTheme.primaryBrand).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2)
                        )
                      ] : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isToday 
                              ? Colors.white 
                              : isPredictedPeriod 
                                  ? Colors.white
                                  : AppTheme.textMain,
                          fontWeight: (isToday || isPredictedPeriod) ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Legend
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: AppTheme.primaryBrand, label: "Règles"),
                _LegendItem(color: AppTheme.tertiaryBrand, label: "Ovulation"),
                _LegendItem(color: AppTheme.textMain, label: "Aujourd'hui"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSub)),
      ],
    );
  }
}