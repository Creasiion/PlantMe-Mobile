import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_profile.dart';

void main() {
  group('PlantProfile', () {
    test('stores all fields correctly', () {
      final now = DateTime(2025, 6, 15);
      final profile = PlantProfile(
        plantName: 'Keanu Leaves',
        plantSpecies: 'Jeane Wickedocia',
        plantImagePath: 'test/dummy.jpg',
        plantDescription: 'A leafy friend',
        descriptionGpt: 'A plant that loves shade.',
        commonUses: 'Decoration',
        timeCreated: now,
        colorValue: Colors.green.toARGB32(),
      );

      expect(profile.plantName, 'Keanu Leaves');
      expect(profile.plantSpecies, 'Jeane Wickedocia');
      expect(profile.plantImagePath, 'test/dummy.jpg');
      expect(profile.plantDescription, 'A leafy friend');
      expect(profile.descriptionGpt, 'A plant that loves shade.');
      expect(profile.commonUses, 'Decoration');
      expect(profile.timeCreated, now);
      expect(profile.colorValue, Colors.green.toARGB32());
    });

    test('handles empty description', () {
      final profile = PlantProfile(
        plantName: 'Cactus',
        plantSpecies: 'Cactasaurus',
        plantImagePath: 'test/dummy.jpg',
        plantDescription: '',
        descriptionGpt: '',
        commonUses: '',
        timeCreated: DateTime.now(),
        colorValue: Colors.green.toARGB32(),
      );

      expect(profile.plantDescription, '');
    });

    test('color getter returns correct Color from colorValue', () {
      final profile = PlantProfile(
        plantName: 'Cactus',
        plantSpecies: 'Cactasaurus',
        plantImagePath: 'test/dummy.jpg',
        plantDescription: '',
        descriptionGpt: '',
        commonUses: '',
        timeCreated: DateTime.now(),
        colorValue: Colors.blue.toARGB32(),
      );

      expect(profile.color, equals(const Color(0xff2196f3)));
    });
  });
}