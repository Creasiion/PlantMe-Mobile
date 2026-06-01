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
  final String descriptionGpt;
  final String commonUses;
  final DateTime timeCreated;
  final int colorValue;

  PlantProfile({
    this.id,
    required this.plantName,
    required this.plantSpecies,
    required this.plantImagePath,
    required this.plantDescription,
    required this.descriptionGpt,
    required this.commonUses,
    required this.timeCreated,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}