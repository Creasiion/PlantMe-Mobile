import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/views/all_plant_profiles_view.dart';
import 'package:provider/provider.dart';
import '../helpers/test_helpers.dart';
import '../providers/plant_provider_test.dart' show FakePlantDao;

void main() {
  late File testImage;

  setUpAll(() async {
    testImage = await createTestImageFile();
  });

  tearDownAll(() {
    testImage.parent.deleteSync(recursive: true);
  });

  group('AllPlantsView', () {
    testWidgets('displays app bar title', (tester) async {
      final provider = PlantProvider(FakePlantDao());
      await tester.pumpWidget(
        ChangeNotifierProvider<PlantProvider>.value(
          value: provider,
          child: const MaterialApp(home: AllPlantsView()),
        ),
      );

      expect(find.text('All Plants'), findsOneWidget);
    });

    testWidgets('displays plant names in grid', (tester) async {
      final dao = FakePlantDao();
      await dao.insertPlant(
          makePlant(name: 'Fern', imagePath: testImage.path));
      await dao.insertPlant(
          makePlant(name: 'Cactus', imagePath: testImage.path));

      final provider = PlantProvider(dao);
      await provider.loadPlants();

      await tester.pumpWidget(
        ChangeNotifierProvider<PlantProvider>.value(
          value: provider,
          child: const MaterialApp(home: AllPlantsView()),
        ),
      );

      expect(find.text('Fern'), findsOneWidget);
      expect(find.text('Cactus'), findsOneWidget);
    });

    testWidgets('shows empty grid when no plants exist', (tester) async {
      final provider = PlantProvider(FakePlantDao());

      await tester.pumpWidget(
        ChangeNotifierProvider<PlantProvider>.value(
          value: provider,
          child: const MaterialApp(home: AllPlantsView()),
        ),
      );

      // GridView exists but is empty
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Fern'), findsNothing);
    });
  });
}
