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
            'CREATE TABLE IF NOT EXISTS `PlantProfile` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `plantName` TEXT NOT NULL, `plantSpecies` TEXT NOT NULL, `plantImagePath` TEXT NOT NULL, `plantDescription` TEXT NOT NULL, `timeCreated` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PlantDao get plantDao {
    return _plantDaoInstance ??= _$PlantDao(database, changeListener);
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
                  'timeCreated': _dateTimeConverter.encode(item.timeCreated)
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
                  'timeCreated': _dateTimeConverter.encode(item.timeCreated)
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
                  'timeCreated': _dateTimeConverter.encode(item.timeCreated)
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
            timeCreated: _dateTimeConverter.decode(row['timeCreated'] as int)));
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

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
