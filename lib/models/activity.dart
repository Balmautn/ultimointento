class Activity {
  final int? id;
  final String title;
  final String description;
  final String date;
  final String startTime;
  final String endTime;
  final String category;
  final int isDone;

  const Activity({
    this.id,
    required this.title,
    this.description = '',
    required this.date,
    required this.startTime,
    required this.endTime,
    this.category = 'Personal',
    this.isDone = 0,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date,
    'start_time': startTime,
    'end_time': endTime,
    'category': category,
    'is_done': isDone,
  };

  factory Activity.fromMap(Map<String, Object?> map) => Activity(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: (map['description'] as String?) ?? '',
    date: map['date'] as String,
    startTime: map['start_time'] as String,
    endTime: map['end_time'] as String,
    category: (map['category'] as String?) ?? 'Personal',
    isDone: (map['is_done'] as int?) ?? 0,
  );
}
