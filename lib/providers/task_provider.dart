import 'package:flutter/material.dart';
import 'package:plant_me/classes/plant_task.dart';
import 'package:plant_me/classes/plant_task_instance.dart';
import 'package:plant_me/database/plant_task_dao.dart';
import 'package:plant_me/classes/plant_task_instance.dart';

class TaskProvider extends ChangeNotifier {
  final PlantTaskDao _taskDao;
  List<PlantTaskInstance> _instances = [];

  TaskProvider(this._taskDao);

  List<PlantTaskInstance> get instances => _instances;

  Future<void> loadInstances() async {
    _instances = await _taskDao.getAllInstances();
    notifyListeners();
  }

  // Returns instances for a specific date (for calendar day view)
  List<PlantTaskInstance> getInstancesForDate(DateTime date) {
    return _instances.where((i) {
      return i.dueDate.year == date.year &&
          i.dueDate.month == date.month &&
          i.dueDate.day == date.day;
    }).toList();
  }

  // Returns dates that have at least one instance (for calendar dot markers)
  Set<DateTime> get datesWithInstances {
    return _instances.map((i) => DateTime(
      i.dueDate.year,
      i.dueDate.month,
      i.dueDate.day,
    )).toSet();
  }

  Future<void> addTask(PlantTask task) async {
    // Insert the task rule and get its id back
    final taskId = await _taskDao.insertTask(task);

    // Generate instances based on recurrence
    final instances = _generateInstances(task.copyWith(id: taskId));
    for (final instance in instances) {
      await _taskDao.insertInstance(instance);
    }

    await loadInstances();
  }

  List<PlantTaskInstance> _generateInstances(PlantTask task) {
    final instances = <PlantTaskInstance>[];
    final endDate = task.endDate ?? task.startDate.add(const Duration(days: 60));

    if (task.recurrenceType == 'none') {
      instances.add(PlantTaskInstance(
        plantTaskId: task.id!,
        plantProfileId: task.plantProfileId,
        dueDate: task.startDate,
        taskType: task.taskType,     
        customNote: task.customNote,  
        
      ));
    } else {
      DateTime current = task.startDate;
      while (!current.isAfter(endDate)) {
        instances.add(PlantTaskInstance(
          plantTaskId: task.id!,
          plantProfileId: task.plantProfileId,
          dueDate: current,
          taskType: task.taskType,     
          customNote: task.customNote,  
        ));

        if (task.recurrenceType == 'daily') {
          current = current.add(const Duration(days: 1));
        } else if (task.recurrenceType == 'interval') {
          current = current.add(Duration(days: task.recurrenceInterval));
        } else if (task.recurrenceType == 'weekly') {
          current = current.add(const Duration(days: 7));
        }
      }
    }

    return instances;
  }

  Future<void> completeInstance(PlantTaskInstance instance) async {
  final updated = PlantTaskInstance(
    id: instance.id,
    plantTaskId: instance.plantTaskId,
    plantProfileId: instance.plantProfileId,
    dueDate: instance.dueDate,
    taskType: instance.taskType,
    customNote: instance.customNote,
    isCompleted: !instance.isCompleted,  // toggle instead of always true
    completedAtMillis: !instance.isCompleted
        ? DateTime.now().millisecondsSinceEpoch
        : null,  // clear completedAt if uncompleting
  );
  await _taskDao.updateInstance(updated);
  await loadInstances();
}

  // Delete just this one instance
  Future<void> deleteInstance(PlantTaskInstance instance) async {
    await _taskDao.deleteInstance(instance);
    await loadInstances();
  }

  // Delete this and all future instances
  Future<void> deleteInstanceAndFollowing(PlantTaskInstance instance) async {
    final future = await _taskDao.getInstancesFromDate(
      instance.plantTaskId,
      instance.dueDate,
    );
    for (final i in future) {
      await _taskDao.deleteInstance(i);
    }
    await loadInstances();
  }

  // Delete all instances for a task rule
  Future<void> deleteAllInstances(PlantTask task) async {
    final all = await _taskDao.getInstancesForTask(task.id!);
    for (final i in all) {
      await _taskDao.deleteInstance(i);
    }
    await _taskDao.deleteTask(task);
    await loadInstances();
  }

  // Retrieve task 

  Future<PlantTask?> getTaskById(int id) async {
  return await _taskDao.getTaskById(id);
  }
}