import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_task.dart';
import 'package:plant_me/classes/plant_task_instance.dart';
import 'package:plant_me/database/plant_task_dao.dart';
import 'package:plant_me/providers/task_provider.dart';

class FakeTaskDao extends PlantTaskDao {
  final List<PlantTask> _tasks = [];
  final List<PlantTaskInstance> _instances = [];
  int _nextTaskId = 1;
  int _nextInstanceId = 1;

  @override
  Future<int> insertTask(PlantTask task) async {
    final id = _nextTaskId++;
    _tasks.add(task.copyWith(id: id));
    return id;
  }

  @override
  Future<int> insertInstance(PlantTaskInstance instance) async {
    final id = _nextInstanceId++;
    _instances.add(PlantTaskInstance(
      id: id,
      plantTaskId: instance.plantTaskId,
      plantProfileId: instance.plantProfileId,
      dueDate: instance.dueDate,
      taskType: instance.taskType,
      customNote: instance.customNote,
      isCompleted: instance.isCompleted,
      completedAtMillis: instance.completedAtMillis,
    ));
    return id;
  }

  @override
  Future<List<PlantTaskInstance>> getAllInstances() async =>
      List<PlantTaskInstance>.from(_instances);

  @override
  Future<List<PlantTaskInstance>> getInstancesForTask(int taskId) async =>
      _instances.where((i) => i.plantTaskId == taskId).toList();

  @override
  Future<List<PlantTaskInstance>> getInstancesFromDate(int taskId, DateTime fromDate) async =>
      _instances.where((i) =>
          i.plantTaskId == taskId && !i.dueDate.isBefore(fromDate)).toList();

  @override
  Future<List<PlantTaskInstance>> getInstancesForDate(DateTime date) async =>
      _instances.where((i) =>
          i.dueDate.year == date.year &&
          i.dueDate.month == date.month &&
          i.dueDate.day == date.day).toList();

  @override
  Future<void> updateInstance(PlantTaskInstance instance) async {
    final index = _instances.indexWhere((i) => i.id == instance.id);
    if (index != -1) _instances[index] = instance;
  }

  @override
  Future<void> deleteInstance(PlantTaskInstance instance) async {
    _instances.removeWhere((i) => i.id == instance.id);
  }

  @override
  Future<void> deleteTask(PlantTask task) async {
    _tasks.removeWhere((t) => t.id == task.id);
  }

  @override
  Future<List<PlantTask>> getAllTasks() async =>
      List<PlantTask>.from(_tasks);

  @override
  Future<List<PlantTask>> getTasksForPlant(int plantProfileId) async =>
      _tasks.where((t) => t.plantProfileId == plantProfileId).toList();

  @override
  Future<PlantTask?> getTaskById(int id) async =>
      _tasks.where((t) => t.id == id).firstOrNull;
}

PlantTask _makeTask({
  String recurrenceType = 'none',
  int interval = 1,
  DateTime? startDate,
  DateTime? endDate,
}) {
  return PlantTask(
    plantProfileId: 1,
    taskType: 'watering',
    recurrenceType: recurrenceType,
    recurrenceInterval: interval,
    startDate: startDate ?? DateTime(2025, 6, 1),
    endDateMillis: endDate?.millisecondsSinceEpoch,
  );
}

void main() {
  group('TaskProvider', () {
    test('starts with empty instances', () {
      final provider = TaskProvider(FakeTaskDao());
      expect(provider.instances, isEmpty);
    });

    test('addTask with no recurrence creates one instance', () async {
      final provider = TaskProvider(FakeTaskDao());
      await provider.addTask(_makeTask(recurrenceType: 'none'));

      expect(provider.instances.length, 1);
      expect(provider.instances.first.dueDate, DateTime(2025, 6, 1));
    });

    test('addTask with weekly recurrence creates correct instances', () async {
      final provider = TaskProvider(FakeTaskDao());
      final start = DateTime(2025, 6, 1);
      final end = DateTime(2025, 6, 22);

      await provider.addTask(_makeTask(
        recurrenceType: 'weekly',
        startDate: start,
        endDate: end,
      ));

      expect(provider.instances.length, 4);
    });

    test('addTask with interval recurrence creates correct instances', () async {
      final provider = TaskProvider(FakeTaskDao());
      final start = DateTime(2025, 6, 1);
      final end = DateTime(2025, 6, 15);

      await provider.addTask(_makeTask(
        recurrenceType: 'interval',
        interval: 7,
        startDate: start,
        endDate: end,
      ));

      expect(provider.instances.length, 3);
    });

    test('addTask with daily recurrence creates correct instances', () async {
      final provider = TaskProvider(FakeTaskDao());
      final start = DateTime(2025, 6, 1);
      final end = DateTime(2025, 6, 5);

      await provider.addTask(_makeTask(
        recurrenceType: 'daily',
        startDate: start,
        endDate: end,
      ));

      expect(provider.instances.length, 5);
    });

    test('getInstancesForDate returns only matching instances', () async {
      final provider = TaskProvider(FakeTaskDao());
      final start = DateTime(2025, 6, 1);
      final end = DateTime(2025, 6, 14);

      await provider.addTask(_makeTask(
        recurrenceType: 'weekly',
        startDate: start,
        endDate: end,
      ));

      final results = provider.getInstancesForDate(DateTime(2025, 6, 1));
      expect(results.length, 1);
      expect(results.first.dueDate, DateTime(2025, 6, 1));
    });

    test('getInstancesForDate returns empty for date with no tasks', () async {
      final provider = TaskProvider(FakeTaskDao());
      await provider.addTask(_makeTask(recurrenceType: 'none'));

      final results = provider.getInstancesForDate(DateTime(2025, 7, 1));
      expect(results, isEmpty);
    });

    test('completeInstance toggles isCompleted to true', () async {
      final provider = TaskProvider(FakeTaskDao());
      await provider.addTask(_makeTask(recurrenceType: 'none'));

      final instance = provider.instances.first;
      expect(instance.isCompleted, false);

      await provider.completeInstance(instance);
      expect(provider.instances.first.isCompleted, true);
    });

    test('completeInstance toggles isCompleted back to false', () async {
      final provider = TaskProvider(FakeTaskDao());
      await provider.addTask(_makeTask(recurrenceType: 'none'));

      final instance = provider.instances.first;
      await provider.completeInstance(instance);
      await provider.completeInstance(provider.instances.first);

      expect(provider.instances.first.isCompleted, false);
    });

    test('deleteInstance removes only that instance', () async {
      final provider = TaskProvider(FakeTaskDao());
      final start = DateTime(2025, 6, 1);
      final end = DateTime(2025, 6, 15);

      await provider.addTask(_makeTask(
        recurrenceType: 'weekly',
        startDate: start,
        endDate: end,
      ));

      expect(provider.instances.length, 3);
      await provider.deleteInstance(provider.instances.first);
      expect(provider.instances.length, 2);
    });

    test('deleteAllInstances removes all instances and the task', () async {
      final dao = FakeTaskDao();
      final provider = TaskProvider(dao);
      final start = DateTime(2025, 6, 1);
      final end = DateTime(2025, 6, 15);

      await provider.addTask(_makeTask(
        recurrenceType: 'weekly',
        startDate: start,
        endDate: end,
      ));

      expect(provider.instances.length, 3);
      final task = await dao.getTaskById(1);
      await provider.deleteAllInstances(task!);
      expect(provider.instances, isEmpty);
    });

    test('deleteInstanceAndFollowing removes this and future instances',
        () async {
      final dao = FakeTaskDao();
      final provider = TaskProvider(dao);
      final start = DateTime(2025, 6, 1);
      final end = DateTime(2025, 6, 15);

      await provider.addTask(_makeTask(
        recurrenceType: 'weekly',
        startDate: start,
        endDate: end,
      ));

      expect(provider.instances.length, 3); // Jun 1, 8, 15

      // Delete from Jun 8 onward
      final jun8Instance = provider.instances
          .firstWhere((i) => i.dueDate == DateTime(2025, 6, 8));
      await provider.deleteInstanceAndFollowing(jun8Instance);

      expect(provider.instances.length, 1);
      expect(provider.instances.first.dueDate, DateTime(2025, 6, 1));
    });

    test('loadInstances refreshes from database', () async {
      final dao = FakeTaskDao();
      final provider = TaskProvider(dao);

      await provider.addTask(_makeTask(recurrenceType: 'none'));
      expect(provider.instances.length, 1);

      // Directly remove from dao and reload
      final instances = await dao.getAllInstances();
      await dao.deleteInstance(instances.first);
      await provider.loadInstances();
      expect(provider.instances, isEmpty);
    });

    test('getTaskById returns task', () async {
      final dao = FakeTaskDao();
      final provider = TaskProvider(dao);

      await provider.addTask(_makeTask(recurrenceType: 'none'));
      final task = await provider.getTaskById(1);
      expect(task, isNotNull);
      expect(task!.plantProfileId, 1);
    });

    test('getTaskById returns null for non-existent id', () async {
      final dao = FakeTaskDao();
      final provider = TaskProvider(dao);

      final task = await provider.getTaskById(999);
      expect(task, isNull);
    });

    test('datesWithInstances returns correct set of dates', () async {
      final provider = TaskProvider(FakeTaskDao());
      final start = DateTime(2025, 6, 1);
      final end = DateTime(2025, 6, 15);

      await provider.addTask(_makeTask(
        recurrenceType: 'weekly',
        startDate: start,
        endDate: end,
      ));

      final dates = provider.datesWithInstances;
      expect(dates.contains(DateTime(2025, 6, 1)), true);
      expect(dates.contains(DateTime(2025, 6, 8)), true);
      expect(dates.contains(DateTime(2025, 6, 15)), true);
      expect(dates.contains(DateTime(2025, 6, 2)), false);
    });
  });
}