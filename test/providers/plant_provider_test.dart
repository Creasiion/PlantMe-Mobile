import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_profile.dart';
import 'package:plant_me/providers/plant_provider.dart';

PlantProfile _makePlant({
  String name = 'Plant',
  DateTime? created,
}) {
  return PlantProfile(
    plantName: name,
    plantSpecies: 'Species',
    plantImage: File('test/dummy.jpg'),
    plantDescription: 'Description',
    timeCreated: created ?? DateTime.now(),
  );
}

void main() {
  group('PlantProvider', () {
    test('starts with empty plant list', () {
      final provider = PlantProvider();
      expect(provider.plantProfiles, isEmpty);
    });

    test('addPlantProfile appends a plant', () {
      final provider = PlantProvider();
      provider.addPlantProfile(_makePlant(name: 'Keanu Leaves'));

      expect(provider.plantProfiles.length, 1);
      expect(provider.plantProfiles.first.plantName, 'Keanu Leaves');
    });

    test('addPlantProfile notifies listeners', () {
      final provider = PlantProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.addPlantProfile(_makePlant());
      provider.addPlantProfile(_makePlant());

      expect(notifyCount, 2);
    });

    test('plantProfiles are sorted newest first', () {
      final provider = PlantProvider();
      final oldest = _makePlant(name: 'Oldest', created: DateTime(2023, 1, 1));
      final middle = _makePlant(name: 'Middle', created: DateTime(2024, 6, 1));
      final newest = _makePlant(name: 'Newest', created: DateTime(2025, 1, 1));

      provider.addPlantProfile(middle);
      provider.addPlantProfile(oldest);
      provider.addPlantProfile(newest);

      final sorted = provider.plantProfiles;
      expect(sorted[0].plantName, 'Newest');
      expect(sorted[1].plantName, 'Middle');
      expect(sorted[2].plantName, 'Oldest');
    });
  });
}