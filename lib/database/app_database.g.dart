// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PlantDao? _plantDaoInstance;

  PlantTaskDao? _taskDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PlantProfile` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `plantName` TEXT NOT NULL, `plantSpecies` TEXT NOT NULL, `plantImagePath` TEXT NOT NULL, `plantDescription` TEXT NOT NULL, `timeCreated` INTEGER NOT NULL, `colorValue` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PlantTask` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `plantProfileId` INTEGER NOT NULL, `taskType` TEXT NOT NULL, `customNote` TEXT, `recurrenceType` TEXT NOT NULL, `recurrenceInterval` INTEGER NOT NULL, `startDate` INTEGER NOT NULL, `endDateMillis` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PlantTaskInstance` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `plantTaskId` INTEGER NOT NULL, `plantProfileId` INTEGER NOT NULL, `dueDate` INTEGER NOT NULL, `isCompleted` INTEGER NOT NULL, `completedAtMillis` INTEGER, `taskType` TEXT NOT NULL, `customNote` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PlantDao get plantDao {
    return _plantDaoInstance ??= _$PlantDao(database, changeListener);
  }

  @override
  PlantTaskDao get taskDao {
    return _taskDaoInstance ??= _$PlantTaskDao(database, changeListener);
  }
}

class _$PlantDao extends PlantDao {
  _$PlantDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _plantProfileInsertionAdapter = InsertionAdapter(
            database,
            'PlantProfile',
            (PlantProfile item) => <String, Object?>{
                  'id': item.id,
                  'plantName': item.plantName,
                  'plantSpecies': item.plantSpecies,
                  'plantImagePath': item.plantImagePath,
                  'plantDescription': item.plantDescription,
                  'timeCreated': _dateTimeConverter.encode(item.timeCreated),
                  'colorValue': item.colorValue
                }),
        _plantProfileUpdateAdapter = UpdateAdapter(
            database,
            'PlantProfile',
            ['id'],
            (PlantProfile item) => <String, Object?>{
                  'id': item.id,
                  'plantName': item.plantName,
                  'plantSpecies': item.plantSpecies,
                  'plantImagePath': item.plantImagePath,
                  'plantDescription': item.plantDescription,
                  'timeCreated': _dateTimeConverter.encode(item.timeCreated),
                  'colorValue': item.colorValue
                }),
        _plantProfileDeletionAdapter = DeletionAdapter(
            database,
            'PlantProfile',
            ['id'],
            (PlantProfile item) => <String, Object?>{
                  'id': item.id,
                  'plantName': item.plantName,
                  'plantSpecies': item.plantSpecies,
                  'plantImagePath': item.plantImagePath,
                  'plantDescription': item.plantDescription,
                  'timeCreated': _dateTimeConverter.encode(item.timeCreated),
                  'colorValue': item.colorValue
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PlantProfile> _plantProfileInsertionAdapter;

  final UpdateAdapter<PlantProfile> _plantProfileUpdateAdapter;

  final DeletionAdapter<PlantProfile> _plantProfileDeletionAdapter;

  @override
  Future<List<PlantProfile>> getAllPlants() async {
    return _queryAdapter.queryList(
        'SELECT * FROM PlantProfile ORDER BY timeCreated DESC',
        mapper: (Map<String, Object?> row) => PlantProfile(
            id: row['id'] as int?,
            plantName: row['plantName'] as String,
            plantSpecies: row['plantSpecies'] as String,
            plantImagePath: row['plantImagePath'] as String,
            plantDescription: row['plantDescription'] as String,
            timeCreated: _dateTimeConverter.decode(row['timeCreated'] as int),
            colorValue: row['colorValue'] as int));
  }

  @override
  Future<void> insertPlant(PlantProfile plant) async {
    await _plantProfileInsertionAdapter.insert(plant, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePlant(PlantProfile plant) async {
    await _plantProfileUpdateAdapter.update(plant, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePlant(PlantProfile plant) async {
    await _plantProfileDeletionAdapter.delete(plant);
  }
}

class _$PlantTaskDao extends PlantTaskDao {
  _$PlantTaskDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _plantTaskInsertionAdapter = InsertionAdapter(
            database,
            'PlantTask',
            (PlantTask item) => <String, Object?>{
                  'id': item.id,
                  'plantProfileId': item.plantProfileId,
                  'taskType': item.taskType,
                  'customNote': item.customNote,
                  'recurrenceType': item.recurrenceType,
                  'recurrenceInterval': item.recurrenceInterval,
                  'startDate': _dateTimeConverter.encode(item.startDate),
                  'endDateMillis': item.endDateMillis
                }),
        _plantTaskInstanceInsertionAdapter = InsertionAdapter(
            database,
            'PlantTaskInstance',
            (PlantTaskInstance item) => <String, Object?>{
                  'id': item.id,
                  'plantTaskId': item.plantTaskId,
                  'plantProfileId': item.plantProfileId,
                  'dueDate': _dateTimeConverter.encode(item.dueDate),
                  'isCompleted': item.isCompleted ? 1 : 0,
                  'completedAtMillis': item.completedAtMillis,
                  'taskType': item.taskType,
                  'customNote': item.customNote
                }),
        _plantTaskInstanceUpdateAdapter = UpdateAdapter(
            database,
            'PlantTaskInstance',
            ['id'],
            (PlantTaskInstance item) => <String, Object?>{
                  'id': item.id,
                  'plantTaskId': item.plantTaskId,
                  'plantProfileId': item.plantProfileId,
                  'dueDate': _dateTimeConverter.encode(item.dueDate),
                  'isCompleted': item.isCompleted ? 1 : 0,
                  'completedAtMillis': item.completedAtMillis,
                  'taskType': item.taskType,
                  'customNote': item.customNote
                }),
        _plantTaskDeletionAdapter = DeletionAdapter(
            database,
            'PlantTask',
            ['id'],
            (PlantTask item) => <String, Object?>{
                  'id': item.id,
                  'plantProfileId': item.plantProfileId,
                  'taskType': item.taskType,
                  'customNote': item.customNote,
                  'recurrenceType': item.recurrenceType,
                  'recurrenceInterval': item.recurrenceInterval,
                  'startDate': _dateTimeConverter.encode(item.startDate),
                  'endDateMillis': item.endDateMillis
                }),
        _plantTaskInstanceDeletionAdapter = DeletionAdapter(
            database,
            'PlantTaskInstance',
            ['id'],
            (PlantTaskInstance item) => <String, Object?>{
                  'id': item.id,
                  'plantTaskId': item.plantTaskId,
                  'plantProfileId': item.plantProfileId,
                  'dueDate': _dateTimeConverter.encode(item.dueDate),
                  'isCompleted': item.isCompleted ? 1 : 0,
                  'completedAtMillis': item.completedAtMillis,
                  'taskType': item.taskType,
                  'customNote': item.customNote
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PlantTask> _plantTaskInsertionAdapter;

  final InsertionAdapter<PlantTaskInstance> _plantTaskInstanceInsertionAdapter;

  final UpdateAdapter<PlantTaskInstance> _plantTaskInstanceUpdateAdapter;

  final DeletionAdapter<PlantTask> _plantTaskDeletionAdapter;

  final DeletionAdapter<PlantTaskInstance> _plantTaskInstanceDeletionAdapter;

  @override
  Future<List<PlantTask>> getTasksForPlant(int plantProfileId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM PlantTask WHERE plantProfileId = ?1',
        mapper: (Map<String, Object?> row) => PlantTask(
            id: row['id'] as int?,
            plantProfileId: row['plantProfileId'] as int,
            taskType: row['taskType'] as String,
            customNote: row['customNote'] as String?,
            recurrenceType: row['recurrenceType'] as String,
            recurrenceInterval: row['recurrenceInterval'] as int,
            startDate: _dateTimeConverter.decode(row['startDate'] as int),
            endDateMillis: row['endDateMillis'] as int?),
        arguments: [plantProfileId]);
  }

  @override
  Future<List<PlantTask>> getAllTasks() async {
    return _queryAdapter.queryList('SELECT * FROM PlantTask',
        mapper: (Map<String, Object?> row) => PlantTask(
            id: row['id'] as int?,
            plantProfileId: row['plantProfileId'] as int,
            taskType: row['taskType'] as String,
            customNote: row['customNote'] as String?,
            recurrenceType: row['recurrenceType'] as String,
            recurrenceInterval: row['recurrenceInterval'] as int,
            startDate: _dateTimeConverter.decode(row['startDate'] as int),
            endDateMillis: row['endDateMillis'] as int?));
  }

  @override
  Future<List<PlantTaskInstance>> getInstancesForDate(DateTime date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM PlantTaskInstance WHERE dueDate = ?1',
        mapper: (Map<String, Object?> row) => PlantTaskInstance(
            id: row['id'] as int?,
            plantTaskId: row['plantTaskId'] as int,
            plantProfileId: row['plantProfileId'] as int,
            dueDate: _dateTimeConverter.decode(row['dueDate'] as int),
            taskType: row['taskType'] as String,
            customNote: row['customNote'] as String?,
            isCompleted: (row['isCompleted'] as int) != 0,
            completedAtMillis: row['completedAtMillis'] as int?),
        arguments: [_dateTimeConverter.encode(date)]);
  }

  @override
  Future<List<PlantTaskInstance>> getInstancesForTask(int taskId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM PlantTaskInstance WHERE plantTaskId = ?1',
        mapper: (Map<String, Object?> row) => PlantTaskInstance(
            id: row['id'] as int?,
            plantTaskId: row['plantTaskId'] as int,
            plantProfileId: row['plantProfileId'] as int,
            dueDate: _dateTimeConverter.decode(row['dueDate'] as int),
            taskType: row['taskType'] as String,
            customNote: row['customNote'] as String?,
            isCompleted: (row['isCompleted'] as int) != 0,
            completedAtMillis: row['completedAtMillis'] as int?),
        arguments: [taskId]);
  }

  @override
  Future<List<PlantTaskInstance>> getInstancesFromDate(
    int taskId,
    DateTime fromDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM PlantTaskInstance WHERE plantTaskId = ?1 AND dueDate >= ?2',
        mapper: (Map<String, Object?> row) => PlantTaskInstance(id: row['id'] as int?, plantTaskId: row['plantTaskId'] as int, plantProfileId: row['plantProfileId'] as int, dueDate: _dateTimeConverter.decode(row['dueDate'] as int), taskType: row['taskType'] as String, customNote: row['customNote'] as String?, isCompleted: (row['isCompleted'] as int) != 0, completedAtMillis: row['completedAtMillis'] as int?),
        arguments: [taskId, _dateTimeConverter.encode(fromDate)]);
  }

  @override
  Future<List<PlantTaskInstance>> getAllInstances() async {
    return _queryAdapter.queryList('SELECT * FROM PlantTaskInstance',
        mapper: (Map<String, Object?> row) => PlantTaskInstance(
            id: row['id'] as int?,
            plantTaskId: row['plantTaskId'] as int,
            plantProfileId: row['plantProfileId'] as int,
            dueDate: _dateTimeConverter.decode(row['dueDate'] as int),
            taskType: row['taskType'] as String,
            customNote: row['customNote'] as String?,
            isCompleted: (row['isCompleted'] as int) != 0,
            completedAtMillis: row['completedAtMillis'] as int?));
  }

  @override
  Future<PlantTask?> getTaskById(int id) async {
    return _queryAdapter.query('SELECT * FROM PlantTask WHERE id = ?1',
        mapper: (Map<String, Object?> row) => PlantTask(
            id: row['id'] as int?,
            plantProfileId: row['plantProfileId'] as int,
            taskType: row['taskType'] as String,
            customNote: row['customNote'] as String?,
            recurrenceType: row['recurrenceType'] as String,
            recurrenceInterval: row['recurrenceInterval'] as int,
            startDate: _dateTimeConverter.decode(row['startDate'] as int),
            endDateMillis: row['endDateMillis'] as int?),
        arguments: [id]);
  }

  @override
  Future<int> insertTask(PlantTask task) {
    return _plantTaskInsertionAdapter.insertAndReturnId(
        task, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertInstance(PlantTaskInstance instance) async {
    await _plantTaskInstanceInsertionAdapter.insert(
        instance, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateInstance(PlantTaskInstance instance) async {
    await _plantTaskInstanceUpdateAdapter.update(
        instance, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTask(PlantTask task) async {
    await _plantTaskDeletionAdapter.delete(task);
  }

  @override
  Future<void> deleteInstance(PlantTaskInstance instance) async {
    await _plantTaskInstanceDeletionAdapter.delete(instance);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
