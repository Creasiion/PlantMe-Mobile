import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_profile.dart';
import 'package:plant_me/classes/plant_task.dart';
import 'package:plant_me/classes/plant_task_instance.dart';
import 'package:plant_me/database/app_database.dart';
import 'package:plant_me/database/plant_dao.dart';
import 'package:plant_me/database/plant_task_dao.dart';

void main() {
  late AppDatabase database;
  late PlantDao plantDao;
  late PlantTaskDao taskDao;

  setUp(() async {
    database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    plantDao = database.plantDao;
    taskDao = database.taskDao;
  });

  tearDown(() async {
    await database.close();
  });

  PlantProfile _makePlant({String name = 'Fern'}) {
    return PlantProfile(
      plantName: name,
      plantSpecies: 'Nephrolepis',
      plantImagePath: '/tmp/test.jpg',
      plantDescription: 'Watering: Moderate | Light: Indirect | Toxicity: None',
      descriptionGpt: 'A lovely fern.',
      commonUses: 'Decoration',
      timeCreated: DateTime(2025, 6, 1),
      colorValue: Colors.green.toARGB32(),
    );
  }

  group('PlantDao', () {
    test('insertPlant and getAllPlants', () async {
      await plantDao.insertPlant(_makePlant(name: 'Fern'));
      await plantDao.insertPlant(_makePlant(name: 'Cactus'));

      final plants = await plantDao.getAllPlants();
      expect(plants.length, 2);
    });

    test('getAllPlants returns in timeCreated DESC order', () async {
      await plantDao.insertPlant(PlantProfile(
        plantName: 'Older',
        plantSpecies: 'Sp1',
        plantImagePath: '/tmp/a.jpg',
        plantDescription: '',
        descriptionGpt: '',
        commonUses: '',
        timeCreated: DateTime(2024, 1, 1),
        colorValue: Colors.green.toARGB32(),
      ));
      await plantDao.insertPlant(PlantProfile(
        plantName: 'Newer',
        plantSpecies: 'Sp2',
        plantImagePath: '/tmp/b.jpg',
        plantDescription: '',
        descriptionGpt: '',
        commonUses: '',
        timeCreated: DateTime(2025, 6, 1),
        colorValue: Colors.blue.toARGB32(),
      ));

      final plants = await plantDao.getAllPlants();
      expect(plants.first.plantName, 'Newer');
      expect(plants.last.plantName, 'Older');
    });

    test('updatePlant modifies existing record', () async {
      await plantDao.insertPlant(_makePlant(name: 'Fern'));
      final plants = await plantDao.getAllPlants();
      final plant = plants.first;

      final updated = PlantProfile(
        id: plant.id,
        plantName: 'Updated Fern',
        plantSpecies: plant.plantSpecies,
        plantImagePath: plant.plantImagePath,
        plantDescription: plant.plantDescription,
        descriptionGpt: plant.descriptionGpt,
        commonUses: plant.commonUses,
        timeCreated: plant.timeCreated,
        colorValue: plant.colorValue,
      );
      await plantDao.updatePlant(updated);

      final result = await plantDao.getAllPlants();
      expect(result.first.plantName, 'Updated Fern');
    });

    test('deletePlant removes the record', () async {
      await plantDao.insertPlant(_makePlant(name: 'ToDelete'));
      var plants = await plantDao.getAllPlants();
      expect(plants.length, 1);

      await plantDao.deletePlant(plants.first);
      plants = await plantDao.getAllPlants();
      expect(plants, isEmpty);
    });
  });

  group('PlantTaskDao', () {
    test('insertTask returns generated id', () async {
      final id = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));
      expect(id, greaterThan(0));
    });

    test('getAllTasks returns inserted tasks', () async {
      await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));
      await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'light',
        recurrenceType: 'daily',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      final tasks = await taskDao.getAllTasks();
      expect(tasks.length, 2);
    });

    test('getTasksForPlant filters by plantProfileId', () async {
      await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));
      await taskDao.insertTask(PlantTask(
        plantProfileId: 2,
        taskType: 'light',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      final tasks = await taskDao.getTasksForPlant(1);
      expect(tasks.length, 1);
      expect(tasks.first.taskType, 'watering');
    });

    test('getTaskById returns correct task', () async {
      final id = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'fertilizing',
        recurrenceType: 'weekly',
        recurrenceInterval: 7,
        startDate: DateTime(2025, 6, 1),
      ));

      final task = await taskDao.getTaskById(id);
      expect(task, isNotNull);
      expect(task!.taskType, 'fertilizing');
      expect(task.recurrenceType, 'weekly');
    });

    test('getTaskById returns null for non-existent id', () async {
      final task = await taskDao.getTaskById(999);
      expect(task, isNull);
    });

    test('deleteTask removes the task', () async {
      await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      final tasks = await taskDao.getAllTasks();
      await taskDao.deleteTask(tasks.first);
      expect(await taskDao.getAllTasks(), isEmpty);
    });

    test('insertInstance and getAllInstances', () async {
      final taskId = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 1),
        taskType: 'watering',
      ));
      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 8),
        taskType: 'watering',
      ));

      final instances = await taskDao.getAllInstances();
      expect(instances.length, 2);
    });

    test('getInstancesForTask filters by taskId', () async {
      final taskId1 = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));
      final taskId2 = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'light',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId1,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 1),
        taskType: 'watering',
      ));
      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId2,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 1),
        taskType: 'light',
      ));

      final instances = await taskDao.getInstancesForTask(taskId1);
      expect(instances.length, 1);
      expect(instances.first.taskType, 'watering');
    });

    test('getInstancesForDate filters by date', () async {
      final taskId = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 1),
        taskType: 'watering',
      ));
      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 8),
        taskType: 'watering',
      ));

      final instances = await taskDao.getInstancesForDate(DateTime(2025, 6, 1));
      expect(instances.length, 1);
      expect(instances.first.dueDate, DateTime(2025, 6, 1));
    });

    test('getInstancesFromDate returns instances from date forward', () async {
      final taskId = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 1),
        taskType: 'watering',
      ));
      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 8),
        taskType: 'watering',
      ));
      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 15),
        taskType: 'watering',
      ));

      final instances =
          await taskDao.getInstancesFromDate(taskId, DateTime(2025, 6, 8));
      expect(instances.length, 2);
    });

    test('updateInstance modifies completion status', () async {
      final taskId = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      final instanceId = await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 1),
        taskType: 'watering',
      ));

      final instances = await taskDao.getAllInstances();
      expect(instances.first.isCompleted, false);

      await taskDao.updateInstance(PlantTaskInstance(
        id: instanceId,
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 1),
        taskType: 'watering',
        isCompleted: true,
        completedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ));

      final updated = await taskDao.getAllInstances();
      expect(updated.first.isCompleted, true);
    });

    test('deleteInstance removes the instance', () async {
      final taskId = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      await taskDao.insertInstance(PlantTaskInstance(
        plantTaskId: taskId,
        plantProfileId: 1,
        dueDate: DateTime(2025, 6, 1),
        taskType: 'watering',
      ));

      var instances = await taskDao.getAllInstances();
      expect(instances.length, 1);

      await taskDao.deleteInstance(instances.first);
      instances = await taskDao.getAllInstances();
      expect(instances, isEmpty);
    });

    test('stores and retrieves custom note', () async {
      final taskId = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'custom',
        customNote: 'Repot the plant',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(2025, 6, 1),
      ));

      final task = await taskDao.getTaskById(taskId);
      expect(task!.customNote, 'Repot the plant');
    });

    test('stores and retrieves endDateMillis and reminderTimeMinutes',
        () async {
      final taskId = await taskDao.insertTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'weekly',
        recurrenceInterval: 7,
        startDate: DateTime(2025, 6, 1),
        endDateMillis: DateTime(2025, 12, 31).millisecondsSinceEpoch,
        reminderTimeMinutes: 540, // 9:00 AM
      ));

      final task = await taskDao.getTaskById(taskId);
      expect(task!.endDateMillis, isNotNull);
      expect(task.reminderTimeMinutes, 540);
    });
  });
}
