import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_id_result.dart';

void main() {
  group('PlantIdResult additional parsing', () {
    test('fromJson handles Map-valued detail fields', () {
      final json = {
        'result': {
          'classification': {
            'suggestions': [
              {
                'name': 'Fern',
                'details': {
                  'best_watering': {'value': 'Keep soil moist'},
                  'best_light_condition': {'value': 'Indirect light'},
                  'toxicity': {'value': 'Non-toxic'},
                  'description': {'value': 'Wiki description'},
                  'common_uses': {'value': 'Air purification'},
                },
              }
            ]
          }
        }
      };

      final result = PlantIdResult.fromJson(json);
      expect(result.species, 'Fern');
      expect(result.description, contains('Keep soil moist'));
      expect(result.description, contains('Indirect light'));
      expect(result.description, contains('Non-toxic'));
      expect(result.descriptionGpt, 'Wiki description');
      expect(result.commonUses, 'Air purification');
    });

    test('fromJson prefers wiki description over GPT', () {
      final json = {
        'result': {
          'classification': {
            'suggestions': [
              {
                'name': 'Rose',
                'details': {
                  'description': 'Wiki says roses are nice',
                  'description_gpt': 'GPT says roses are red',
                },
              }
            ]
          }
        }
      };

      final result = PlantIdResult.fromJson(json);
      expect(result.descriptionGpt, 'Wiki says roses are nice');
    });

    test('fromJson falls back to GPT when wiki description empty', () {
      final json = {
        'result': {
          'classification': {
            'suggestions': [
              {
                'name': 'Rose',
                'details': {
                  'description': '',
                  'description_gpt': 'GPT says roses are red',
                },
              }
            ]
          }
        }
      };

      final result = PlantIdResult.fromJson(json);
      expect(result.descriptionGpt, 'GPT says roses are red');
    });

    test('fromJson handles null details gracefully', () {
      final json = {
        'result': {
          'classification': {
            'suggestions': [
              {
                'name': 'Mystery Plant',
                'details': null,
              }
            ]
          }
        }
      };

      final result = PlantIdResult.fromJson(json);
      expect(result.species, 'Mystery Plant');
      expect(result.description, contains('Unknown'));
    });

    test('fromJson handles non-string Map value', () {
      final json = {
        'result': {
          'classification': {
            'suggestions': [
              {
                'name': 'Test',
                'details': {
                  'best_watering': {'value': 42},
                  'best_light_condition': null,
                  'toxicity': null,
                },
              }
            ]
          }
        }
      };

      final result = PlantIdResult.fromJson(json);
      expect(result.description, contains('42'));
    });

    test('fromSearchJson handles Map-valued fields', () {
      final json = {
        'common_names': ['Boston Fern'],
        'best_watering': {'value': 'Regular watering'},
        'best_light_condition': {'value': 'Partial shade'},
        'toxicity': {'value': 'Safe'},
        'description': {'value': 'A popular fern'},
        'common_uses': {'value': 'Indoor decoration'},
      };

      final result = PlantIdResult.fromSearchJson(json);
      expect(result.species, 'Boston Fern');
      expect(result.description, contains('Regular watering'));
      expect(result.description, contains('Partial shade'));
      expect(result.description, contains('Safe'));
      expect(result.descriptionGpt, 'A popular fern');
      expect(result.commonUses, 'Indoor decoration');
    });

    test('fromSearchJson with null common_names list', () {
      final json = <String, dynamic>{
        'common_names': null,
      };

      final result = PlantIdResult.fromSearchJson(json);
      expect(result.species, 'Unknown');
    });

    test('fromSearchJson falls back to GPT description', () {
      final json = <String, dynamic>{
        'common_names': ['Test'],
        'description': '',
        'description_gpt': 'GPT fallback description',
      };

      final result = PlantIdResult.fromSearchJson(json);
      expect(result.descriptionGpt, 'GPT fallback description');
    });
  });
}
