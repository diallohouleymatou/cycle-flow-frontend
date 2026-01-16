import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/auth_provider.dart';
import '../../logic/cycle_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CycleProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final auth = context.read<AuthProvider>();
    final pred = cycle.prediction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Cycle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Cycle Indicator
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF06292), width: 8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (pred == null)
                      const Text('Pas de données', style: TextStyle(fontSize: 18))
                    else ...[
                      Text(
                        pred.daysUntilNext > 0 ? 'Prochaines règles dans' : 'Règles prévues',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        pred.daysUntilNext > 0 ? '${pred.daysUntilNext}' : 'Aujourd\'hui',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFF06292)),
                      ),
                      const Text('jours', style: TextStyle(fontSize: 18)),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    label: 'Début Règles',
                    icon: Icons.play_arrow,
                    color: Colors.redAccent,
                    onTap: () => cycle.startPeriod(DateTime.now()),
                  ),
                  _ActionButton(
                    label: 'Fin Règles',
                    icon: Icons.stop,
                    color: Colors.grey,
                    onTap: () => cycle.endPeriod(DateTime.now()),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Predictions Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prévisions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Divider(),
                      if (pred != null) ...[
                         ListTile(
                          leading: const Icon(Icons.calendar_today, color: Color(0xFFF06292)),
                          title: const Text('Prochain cycle'),
                          subtitle: Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(pred.nextPeriodDate)),
                        ),
                        ListTile(
                          leading: const Icon(Icons.loop, color: Color(0xFFF06292)),
                          title: const Text('Durée moyenne'),
                          subtitle: Text('${pred.avgCycleLength} jours'),
                        ),
                      ] else 
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('Enregistrez vos premières règles pour voir les prédictions.'),
                        )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Health Tips
              const Card(
                color: Color(0xFFFCE4EC),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Conseil : Buvez beaucoup d\'eau aujourd\'hui pour réduire les ballonnements.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open Daily Log (Symptoms)
        },
        backgroundColor: const Color(0xFFF06292),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}