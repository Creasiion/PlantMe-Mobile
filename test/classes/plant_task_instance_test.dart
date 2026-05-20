import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_task_instance.dart';

void main() {
  group('PlantTaskInstance', () {
    test('stores all fields correctly', () {
      final due = DateTime(2025, 6, 15);
      final instance = PlantTaskInstance(
        plantTaskId: 1,
        plantProfileId: 2,
        dueDate: due,
        taskType: 'watering',
      );

      expect(instance.plantTaskId, 1);
      expect(instance.plantProfileId, 2);
      expect(instance.dueDate, due);
      expect(instance.taskType, 'watering');
      expect(instance.isCompleted, false);
      expect(instance.completedAtMillis, null);
    });

    test('defaults isCompleted to false', () {
      final instance = PlantTaskInstance(
        plantTaskId: 1,
        plantProfileId: 1,
        dueDate: DateTime.now(),
        taskType: 'watering',
      );

      expect(instance.isCompleted, false);
    });

    test('completedAt getter returns null when completedAtMillis is null', () {
      final instance = PlantTaskInstance(
        plantTaskId: 1,
        plantProfileId: 1,
        dueDate: DateTime.now(),
        taskType: 'watering',
      );

      expect(instance.completedAt, isNull);
    });

    test('completedAt getter returns correct DateTime when set', () {
      final completed = DateTime(2025, 6, 15, 10, 30);
      final instance = PlantTaskInstance(
        plantTaskId: 1,
        plantProfileId: 1,
        dueDate: DateTime.now(),
        taskType: 'watering',
        isCompleted: true,
        completedAtMillis: completed.millisecondsSinceEpoch,
      );

      expect(instance.completedAt?.year, 2025);
      expect(instance.completedAt?.month, 6);
      expect(instance.completedAt?.day, 15);
    });

    test('stores custom note correctly', () {
      final instance = PlantTaskInstance(
        plantTaskId: 1,
        plantProfileId: 1,
        dueDate: DateTime.now(),
        taskType: 'custom',
        customNote: 'Rotate plant',
      );

      expect(instance.customNote, 'Rotate plant');
    });
  });
}