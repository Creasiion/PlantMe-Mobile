import 'dart:io';
// Probably going to be updated when we know exactly what is coming from API
class PlantProfile {
  final String plantName;
  final String plantSpecies;
  final File plantImage;
  final String plantDescription;
  final DateTime timeCreated;

  PlantProfile({
    required this.plantName,
    required this.plantSpecies,
    required this.plantImage,
    required this.plantDescription,
    required this.timeCreated,
  });
}