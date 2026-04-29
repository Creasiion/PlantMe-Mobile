import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_id_result.dart';

void main() {
  group('PlantIdResult.fromJson', () {
    test('parses species and description from image identification response', () {
      final json = {
        'result': {
          'classification': {
            'suggestions': [
              {
                'name': 'Aloe vera',
                'details': {
                  'best_watering': 'Low',
                  'best_light_condition': 'Full sun',
                  'toxicity': 'Mildly toxic',
                },
              }
            ]
          }
        }
      };

      final result = PlantIdResult.fromJson(json);

      expect(result.species, 'Aloe vera');
      expect(result.description, 'Watering: Low | Light: Full sun | Toxicity: Mildly toxic');
    });

    test('uses Unknown when details are missing', () {
      final json = {
        'result': {
          'classification': {
            'suggestions': [
              {
                'name': 'Aloe vera',
                'details': {},
              }
            ]
          }
        }
      };

      final result = PlantIdResult.fromJson(json);

      expect(result.species, 'Aloe vera');
      expect(result.description, 'Watering: Unknown | Light: Unknown | Toxicity: Unknown');
    });
  });

  group('PlantIdResult.fromSearchJson', () {
    test('parses species and description from name search response', () {
      final json = {
        'common_names': ['Aloe vera', 'Barbados aloe'],
        'best_watering': 'Low',
        'best_light_condition': 'Full sun',
        'toxicity': 'Mildly toxic',
      };

      final result = PlantIdResult.fromSearchJson(json);

      expect(result.species, 'Aloe vera');
      expect(result.description, 'Watering: Low | Light: Full sun | Toxicity: Mildly toxic');
    });

    test('uses Unknown when fields are missing', () {
      final json = {
        'common_names': ['Aloe vera'],
      };

      final result = PlantIdResult.fromSearchJson(json);

      expect(result.species, 'Aloe vera');
      expect(result.description, 'Watering: Unknown | Light: Unknown | Toxicity: Unknown');
    });

    test('uses Unknown for species when common_names is empty', () {
      final json = {
        'common_names': [],
      };

      final result = PlantIdResult.fromSearchJson(json);

      expect(result.species, 'Unknown');
    });
  });
}