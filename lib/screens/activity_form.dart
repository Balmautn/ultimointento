import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/app_database.dart';
import '../models/activity.dart';

class ActivityForm extends StatefulWidget {
  final DateTime initialDate;
  const ActivityForm({super.key, required this.initialDate});
  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final description = TextEditingController();
  final start = TextEditingController(text: '09:00');
  final end = TextEditingController(text: '10:00');
  String category = 'Personal';
  late DateTime date;
  bool saving = false;

  @override
  void initState() { super.initState(); date = widget.initialDate; }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    start.dispose();
    end.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      locale: const Locale('es', 'AR'),
    );
    if (picked != null) setState(() => date = picked);
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    if (end.text.compareTo(start.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La hora de finalización debe ser posterior al inicio.')));
      return;
    }
    setState(() => saving = true);
    try {
      await AppDatabase.instance.addActivity(Activity(
        title: title.text.trim(),
        description: description.text.trim(),
        date: dateKey(date),
        startTime: start.text.trim(),
        endTime: end.text.trim(),
        category: category,
      ));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo guardar la actividad.')));
      }
    }
  }

  String? validateTime(String? value) {
    if (value == null || !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) return 'Usá el formato HH:mm';
    final parts = value.split(':').map(int.parse).toList();
    if (parts[0] > 23 || parts[1] > 59) return 'Hora no válida';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva actividad')),
      body: Form(
        key: formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          TextFormField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Nombre de la actividad', border: OutlineInputBorder()),
            validator: (v) => v == null || v.trim().isEmpty ? 'Ingresá un nombre' : null,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: chooseDate, icon: const Icon(Icons.calendar_today), label: Text(DateFormat('dd/MM/yyyy').format(date))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: TextFormField(controller: start, keyboardType: TextInputType.datetime, decoration: const InputDecoration(labelText: 'Desde (HH:mm)', border: OutlineInputBorder()), validator: validateTime)),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: end, keyboardType: TextInputType.datetime, decoration: const InputDecoration(labelText: 'Hasta (HH:mm)', border: OutlineInputBorder()), validator: validateTime)),
          ]),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: category,
            decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
            items: const ['Personal', 'Trabajo', 'Estudio', 'Salud', 'Familia', 'Otro'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => category = v ?? 'Personal'),
          ),
          const SizedBox(height: 14),
          TextFormField(controller: description, maxLines: 4, decoration: const InputDecoration(labelText: 'Descripción y notas', alignLabelWithHint: true, border: OutlineInputBorder())),
          const SizedBox(height: 22),
          FilledButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.save), label: Text(saving ? 'Guardando...' : 'Guardar actividad')),
        ]),
      ),
    );
  }
}
