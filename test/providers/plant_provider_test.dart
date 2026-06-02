import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_profile.dart';
import 'package:plant_me/database/plant_dao.dart';
import 'package:plant_me/providers/plant_provider.dart';

class FakePlantDao extends PlantDao {
  final List<PlantProfile> _plants = [];

  @override
  Future<List<PlantProfile>> getAllPlants() async =>
      List<PlantProfile>.from(_plants);

  @override
  Future<void> insertPlant(PlantProfile plant) async {
    _plants.add(plant);
  }

  @override
  Future<void> deletePlant(PlantProfile plant) async {
    _plants.removeWhere((p) => p.plantName == plant.plantName);
  }

  @override
  Future<void> updatePlant(PlantProfile plant) async {
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) _plants[index] = plant;
  }
}

PlantProfile _makePlant({
  String name = 'Plant',
  DateTime? created,
}) {
  return PlantProfile(
    plantName: name,
    plantSpecies: 'Species',
    plantImagePath: 'test/dummy.jpg',
    plantDescription: 'Description',
    descriptionGpt: '',
    commonUses: '',
    timeCreated: created ?? DateTime.now(),
    colorValue: Colors.green.toARGB32(),
  );
}

void main() {
  group('PlantProvider', () {
    test('starts with empty plant list', () {
      final provider = PlantProvider(FakePlantDao());
      expect(provider.plantProfiles, isEmpty);
    });

    test('addPlantProfile appends a plant', () async {
      final provider = PlantProvider(FakePlantDao());
      await provider.addPlantProfile(_makePlant(name: 'Keanu Leaves'));

      expect(provider.plantProfiles.length, 1);
      expect(provider.plantProfiles.first.plantName, 'Keanu Leaves');
    });

    test('addPlantProfile notifies listeners', () async {
      final provider = PlantProvider(FakePlantDao());
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.addPlantProfile(_makePlant());
      await provider.addPlantProfile(_makePlant());

      expect(notifyCount, 2);
    });

    test('plantProfiles are sorted newest first', () async {
      final provider = PlantProvider(FakePlantDao());
      final oldest = _makePlant(name: 'Oldest', created: DateTime(2023, 1, 1));
      final middle = _makePlant(name: 'Middle', created: DateTime(2024, 6, 1));
      final newest = _makePlant(name: 'Newest', created: DateTime(2025, 1, 1));

      await provider.addPlantProfile(middle);
      await provider.addPlantProfile(oldest);
      await provider.addPlantProfile(newest);

      final sorted = provider.plantProfiles;
      expect(sorted[0].plantName, 'Newest');
      expect(sorted[1].plantName, 'Middle');
      expect(sorted[2].plantName, 'Oldest');
    });

    test('loadPlants populates plantProfiles from dao', () async {
      final dao = FakePlantDao();
      await dao.insertPlant(_makePlant(name: 'Preloaded'));
      final provider = PlantProvider(dao);
      await provider.loadPlants();

      expect(provider.plantProfiles.length, 1);
      expect(provider.plantProfiles.first.plantName, 'Preloaded');
    });
  });
}