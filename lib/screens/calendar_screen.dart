import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/app_database.dart';
import '../models/activity.dart';
import 'activity_form.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime focusedDay = DateTime(2026, 1, 1);
  DateTime selectedDay = DateTime(2026, 1, 1);
  Set<String> markedDates = {};
  Future<List<Activity>>? activities;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    if (today.year == 2026) {
      focusedDay = today;
      selectedDay = today;
    }
    load();
  }

  Future<void> load() async {
    final marks = await AppDatabase.instance.datesWithActivities();
    final list = await AppDatabase.instance.activitiesForDate(selectedDay);
    if (!mounted) return;
    setState(() {
      markedDates = marks;
      activities = Future.value(list);
    });
  }

  Future<void> select(DateTime day, DateTime focus) async {
    setState(() {
      selectedDay = day;
      focusedDay = focus;
      activities = AppDatabase.instance.activitiesForDate(day);
    });
  }

  Future<void> add() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ActivityForm(initialDate: selectedDay)),
    );
    if (saved == true) load();
  }

  @override
  Widget build(BuildContext context) {
    final rawLabel = DateFormat("d 'de' MMMM 'de' y", 'es_AR').format(selectedDay);
    final label = rawLabel[0].toUpperCase() + rawLabel.substring(1);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario 2026')),
      floatingActionButton: FloatingActionButton(onPressed: add, child: const Icon(Icons.add)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(
          padding: const EdgeInsets.all(8),
          child: TableCalendar(
            locale: 'es_AR',
            firstDay: DateTime(2026, 1, 1),
            lastDay: DateTime(2026, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
            onDaySelected: select,
            onPageChanged: (day) => focusedDay = day,
            eventLoader: (day) => markedDates.contains(dateKey(day)) ? ['activity'] : [],
          ),
        )),
        const SizedBox(height: 16),
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        FutureBuilder<List<Activity>>(
          future: activities,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
            final items = snapshot.data!;
            if (items.isEmpty) {
              return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No hay actividades para esta fecha. Tocá + para agregar una.')));
            }
            return Column(children: items.map((a) => Card(child: ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(a.title),
              subtitle: Text('${a.startTime} – ${a.endTime} · ${a.category}'),
              trailing: a.isDone == 1 ? const Icon(Icons.check_circle, color: Colors.green) : null,
            ))).toList());
          },
        ),
      ]),
    );
  }
}
