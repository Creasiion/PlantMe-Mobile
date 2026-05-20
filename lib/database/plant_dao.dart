import 'package:floor/floor.dart';
import 'package:plant_me/classes/plant_profile.dart';

@dao
abstract class PlantDao {
  @Query('SELECT * FROM PlantProfile ORDER BY timeCreated DESC')
  Future<List<PlantProfile>> getAllPlants();

  @insert
  Future<void> insertPlant(PlantProfile plant);

  @delete
  Future<void> deletePlant(PlantProfile plant);

  @update
  Future<void> updatePlant(PlantProfile plant);
}
