import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_database.dart';
import '../models/activity.dart';
import 'activity_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Activity>> future;

  @override
  void initState() {
    super.initState();
    future = AppDatabase.instance.activitiesForDate(DateTime.now());
  }

  void reload() => setState(() => future = AppDatabase.instance.activitiesForDate(DateTime.now()));

  Future<void> add() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ActivityForm(initialDate: DateTime.now())),
    );
    if (saved == true) reload();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat("EEEE d 'de' MMMM", 'es_AR').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claude Organizador'),
        actions: [IconButton(tooltip: 'Nueva actividad', onPressed: add, icon: const Icon(Icons.add_circle_outline))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: add,
        icon: const Icon(Icons.add),
        label: const Text('Nueva actividad'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => reload(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Text(dateLabel[0].toUpperCase() + dateLabel.substring(1), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Organizá tu día, paso a paso.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(children: [
                  Icon(Icons.event_available, size: 32),
                  SizedBox(width: 12),
                  Expanded(child: Text('Tus actividades de hoy', style: TextStyle(fontWeight: FontWeight.w600))),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Activity>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Card(child: Padding(
                    padding: EdgeInsets.all(22),
                    child: Column(children: [
                      Icon(Icons.wb_sunny_outlined, size: 38),
                      SizedBox(height: 10),
                      Text('Todavía no tenés actividades para hoy.'),
                      SizedBox(height: 4),
                      Text('Usá “Nueva actividad” para organizarte.', textAlign: TextAlign.center),
                    ]),
                  ));
                }
                return Column(children: items.map((a) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(a.title, style: TextStyle(decoration: a.isDone == 1 ? TextDecoration.lineThrough : null)),
                    subtitle: Text('${a.startTime} – ${a.endTime} · ${a.category}'),
                    trailing: Checkbox(
                      value: a.isDone == 1,
                      onChanged: (v) async {
                        if (a.id != null) await AppDatabase.instance.setActivityDone(a.id!, v ?? false);
                        reload();
                      },
                    ),
                  ),
                )).toList());
              },
            ),
            const SizedBox(height: 18),
            Text('Próximamente', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Rutinas recurrentes, alarmas, notas, finanzas y copias de seguridad se incorporarán en las siguientes versiones.'),
          ],
        ),
      ),
    );
  }
}
