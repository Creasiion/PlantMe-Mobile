import 'package:floor/floor.dart';
import 'package:plant_me/classes/plant_task.dart';
import 'package:plant_me/classes/plant_task_instance.dart';

@dao
abstract class PlantTaskDao {
  // PlantTask (rules)
  @insert
  Future<int> insertTask(PlantTask task);

  @Query('SELECT * FROM PlantTask WHERE plantProfileId = :plantProfileId')
  Future<List<PlantTask>> getTasksForPlant(int plantProfileId);

  @Query('SELECT * FROM PlantTask')
  Future<List<PlantTask>> getAllTasks();

  @delete
  Future<void> deleteTask(PlantTask task);

  // PlantTaskInstance (occurrences)
  @insert
  Future<void> insertInstance(PlantTaskInstance instance);

  @Query('SELECT * FROM PlantTaskInstance WHERE dueDate = :date')
  Future<List<PlantTaskInstance>> getInstancesForDate(DateTime date);

  @Query('SELECT * FROM PlantTaskInstance WHERE plantTaskId = :taskId')
  Future<List<PlantTaskInstance>> getInstancesForTask(int taskId);

  @Query('SELECT * FROM PlantTaskInstance WHERE plantTaskId = :taskId AND dueDate >= :fromDate')
  Future<List<PlantTaskInstance>> getInstancesFromDate(int taskId, DateTime fromDate);

  @Query('SELECT * FROM PlantTaskInstance')
  Future<List<PlantTaskInstance>> getAllInstances();

  @Query('SELECT * FROM PlantTask WHERE id = :id')
  Future<PlantTask?> getTaskById(int id);

  @delete
  Future<void> deleteInstance(PlantTaskInstance instance);

  @update
  Future<void> updateInstance(PlantTaskInstance instance);
}