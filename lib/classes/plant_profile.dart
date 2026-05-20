import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

@entity
class PlantProfile {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String plantName;
  final String plantSpecies;
  final String plantImagePath;
  final String plantDescription;
  final DateTime timeCreated;
  final int colorValue; // stores Color.value as int

  PlantProfile({
    this.id,
    required this.plantName,
    required this.plantSpecies,
    required this.plantImagePath,
    required this.plantDescription,
    required this.timeCreated,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}