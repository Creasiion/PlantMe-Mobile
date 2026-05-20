import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:plant_me/classes/plant_profile.dart';
import 'package:plant_me/classes/plant_task.dart';
import 'package:plant_me/classes/plant_task_instance.dart';
import 'package:plant_me/database/date_time_converter.dart';
import 'package:plant_me/database/plant_dao.dart';
import 'package:plant_me/database/plant_task_dao.dart';

part 'app_database.g.dart';

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [PlantProfile, PlantTask, PlantTaskInstance])
abstract class AppDatabase extends FloorDatabase {
  PlantDao get plantDao;
  PlantTaskDao get taskDao;
}