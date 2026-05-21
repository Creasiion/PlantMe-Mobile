import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

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
  final int? reminderTimeMinutes; // minutes since midnight (e.g. 540 = 9:00 AM)

  PlantTask({
    this.id,
    required this.plantProfileId,
    required this.taskType,
    this.customNote,
    required this.recurrenceType,
    required this.recurrenceInterval,
    required this.startDate,
    this.endDateMillis,
    this.reminderTimeMinutes,
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
    reminderTimeMinutes: reminderTimeMinutes,
  );
}

  TimeOfDay? get reminderTime => reminderTimeMinutes != null
      ? TimeOfDay(hour: reminderTimeMinutes! ~/ 60, minute: reminderTimeMinutes! % 60)
      : null;

  // fxn to get DateTime back 
  DateTime? get endDate => endDateMillis != null
      ? DateTime.fromMillisecondsSinceEpoch(endDateMillis!)
      : null;


}