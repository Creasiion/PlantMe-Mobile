import 'package:floor/floor.dart';

@entity
class PlantProfile {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String plantName;
  final String plantSpecies;
  final String plantImagePath;
  final String plantDescription;
  final DateTime timeCreated;

  PlantProfile({
    this.id,
    required this.plantName,
    required this.plantSpecies,
    required this.plantImagePath,
    required this.plantDescription,
    required this.timeCreated,
  });
}
