import 'package:floor/floor.dart';

@entity
class PlantTask {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int plantProfileId;
  final String taskType; // 'watering', 'light', 'fertilizing', 'custom'
  final String? customNote;
  final String recurrenceType; // 'none', 'daily', 'interval', 'weekly'
  final int recurrenceInterval; // IE 7 for every 7 days, 1 for daily
  final DateTime startDate;
  final int? endDateMillis; // store as int instead of DateTime?

  PlantTask({
    this.id,
    required this.plantProfileId,
    required this.taskType,
    this.customNote,
    required this.recurrenceType,
    required this.recurrenceInterval,
    required this.startDate,
    this.endDateMillis,
  });

  PlantTask copyWith({int? id}) {
  return PlantTask(
    id: id ?? this.id,
    plantProfileId: plantProfileId,
    taskType: taskType,
    customNote: customNote,
    recurrenceType: recurrenceType,
    recurrenceInterval: recurrenceInterval,
    startDate: startDate,
    endDateMillis: endDateMillis,
  );
}

  // fxn to get DateTime back 
  DateTime? get endDate => endDateMillis != null
      ? DateTime.fromMillisecondsSinceEpoch(endDateMillis!)
      : null;


}