import 'package:floor/floor.dart';

@entity
class PlantTaskInstance {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int plantTaskId;
  final int plantProfileId; // stored for easy calendar lookup
  final DateTime dueDate;
  final bool isCompleted;
  final int? completedAtMillis;
  final String taskType;
  final String? customNote;

  PlantTaskInstance({
    this.id,
    required this.plantTaskId,
    required this.plantProfileId,
    required this.dueDate,
    required this.taskType,
    this.customNote,
    this.isCompleted = false,
    this.completedAtMillis,

  });

  DateTime? get completedAt => completedAtMillis != null
      ? DateTime.fromMillisecondsSinceEpoch(completedAtMillis!)
      : null;
}