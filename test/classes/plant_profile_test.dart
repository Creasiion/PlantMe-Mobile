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
        timeCreated: now,
      );

      expect(profile.plantName, 'Keanu Leaves');
      expect(profile.plantSpecies, 'Jeane Wickedocia');
      expect(profile.plantImagePath, 'test/dummy.jpg');
      expect(profile.plantDescription, 'A leafy friend');
      expect(profile.timeCreated, now);
    });

    test('handles empty description', () {
      final profile = PlantProfile(
        plantName: 'Cactus',
        plantSpecies: 'Cactasaurus',
        plantImagePath: 'test/dummy.jpg',
        plantDescription: '',
        timeCreated: DateTime.now(),
      );

      expect(profile.plantDescription, '');
    });
  });
}
