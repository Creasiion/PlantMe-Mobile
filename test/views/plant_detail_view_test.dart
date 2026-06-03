import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/views/plant_detail_view.dart';
import '../helpers/test_helpers.dart';

void main() {
  late File testImage;

  setUpAll(() async {
    testImage = await createTestImageFile();
  });

  tearDownAll(() {
    testImage.parent.deleteSync(recursive: true);
  });

  Widget buildView(
      {String description = '',
      String descriptionGpt = '',
      String commonUses = ''}) {
    final plant = makePlant(
      name: 'Fern',
      species: 'Nephrolepis exaltata',
      imagePath: testImage.path,
      description: description,
      descriptionGpt: descriptionGpt,
      commonUses: commonUses,
    );
    return MaterialApp(home: PlantProfileView(plant: plant));
  }

  group('PlantProfileView', () {
    testWidgets('displays plant name and species', (tester) async {
      await tester.pumpWidget(buildView());

      expect(find.text('Fern'), findsWidgets);
      expect(find.text('Nephrolepis exaltata'), findsOneWidget);
    });

    testWidgets('parses watering from description', (tester) async {
      await tester.pumpWidget(buildView(
        description:
            'Watering: Keep soil moist | Light: Bright indirect | Toxicity: Non-toxic',
      ));

      expect(find.text('Keep soil moist'), findsOneWidget);
    });

    testWidgets('parses light from description', (tester) async {
      await tester.pumpWidget(buildView(
        description:
            'Watering: Moderate | Light: Full sun | Toxicity: Non-toxic',
      ));

      expect(find.text('Full sun'), findsOneWidget);
    });

    testWidgets('parses toxicity from description', (tester) async {
      await tester.pumpWidget(buildView(
        description:
            'Watering: Moderate | Light: Bright | Toxicity: Mildly toxic to pets',
      ));

      expect(find.text('Mildly toxic to pets'), findsOneWidget);
    });

    testWidgets('shows Unknown when watering is missing', (tester) async {
      await tester.pumpWidget(buildView(description: 'Light: Bright'));

      // The watering section should show Unknown
      expect(find.text('Unknown'), findsWidgets);
    });

    testWidgets('shows GPT description in About section', (tester) async {
      await tester.pumpWidget(buildView(
        descriptionGpt: 'The Boston fern is a classic houseplant.',
      ));

      expect(
          find.text('The Boston fern is a classic houseplant.'), findsOneWidget);
    });

    testWidgets('shows fallback when descriptionGpt is empty', (tester) async {
      await tester.pumpWidget(buildView(descriptionGpt: ''));

      expect(
        find.text('A beautiful addition to your plant collection 🌱'),
        findsOneWidget,
      );
    });

    testWidgets('shows common uses', (tester) async {
      await tester.pumpWidget(buildView(commonUses: 'Air purification'));

      expect(find.text('Air purification'), findsOneWidget);
    });

    testWidgets('shows fallback when common uses is empty', (tester) async {
      await tester.pumpWidget(buildView(commonUses: ''));

      expect(find.text('No common uses available.'), findsOneWidget);
    });

    testWidgets('displays all section titles', (tester) async {
      await tester.pumpWidget(buildView(
        descriptionGpt: 'About text',
        description: 'Watering: W | Light: L | Toxicity: T',
        commonUses: 'Uses',
      ));

      // Scroll down to see all sections
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('About 🌱'), findsOneWidget);
      expect(find.text('Watering 💧'), findsOneWidget);
      expect(find.text('Light ☀️'), findsOneWidget);
      expect(find.text('Toxicity 🤢'), findsOneWidget);
      expect(find.text('Common Uses 🌿'), findsOneWidget);
    });
  });
}
