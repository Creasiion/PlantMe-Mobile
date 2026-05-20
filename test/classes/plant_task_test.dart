import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_task.dart';

void main() {
  group('PlantTask', () {
    test('stores all fields correctly', () {
      final start = DateTime(2025, 6, 1);
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'weekly',
        recurrenceInterval: 7,
        startDate: start,
      );

      expect(task.plantProfileId, 1);
      expect(task.taskType, 'watering');
      expect(task.recurrenceType, 'weekly');
      expect(task.recurrenceInterval, 7);
      expect(task.startDate, start);
      expect(task.endDateMillis, null);
      expect(task.customNote, null);
    });

    test('endDate getter returns null when endDateMillis is null', () {
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime.now(),
      );

      expect(task.endDate, isNull);
    });

    test('endDate getter returns correct DateTime when endDateMillis is set', () {
      final end = DateTime(2025, 12, 31);
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime.now(),
        endDateMillis: end.millisecondsSinceEpoch,
      );

      expect(task.endDate?.year, 2025);
      expect(task.endDate?.month, 12);
      expect(task.endDate?.day, 31);
    });

    test('copyWith updates id and keeps other fields', () {
      final task = PlantTask(
        plantProfileId: 2,
        taskType: 'fertilizing',
        recurrenceType: 'interval',
        recurrenceInterval: 14,
        startDate: DateTime(2025, 1, 1),
        customNote: 'Use liquid fertilizer',
      );

      final copied = task.copyWith(id: 99);

      expect(copied.id, 99);
      expect(copied.plantProfileId, 2);
      expect(copied.taskType, 'fertilizing');
      expect(copied.customNote, 'Use liquid fertilizer');
    });

    test('stores custom note correctly', () {
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'custom',
        customNote: 'Rotate 90 degrees',
        recurrenceType: 'weekly',
        recurrenceInterval: 7,
        startDate: DateTime.now(),
      );

      expect(task.customNote, 'Rotate 90 degrees');
    });
  });
}