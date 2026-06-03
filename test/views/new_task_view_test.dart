import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/providers/task_provider.dart';
import 'package:plant_me/views/new_task_view.dart';
import 'package:provider/provider.dart';
import '../helpers/test_helpers.dart';
import '../providers/plant_provider_test.dart' show FakePlantDao;
import '../providers/task_provider_test.dart' show FakeTaskDao;

void main() {
  late File testImage;

  setUpAll(() async {
    testImage = await createTestImageFile();
  });

  tearDownAll(() {
    testImage.parent.deleteSync(recursive: true);
  });

  Widget buildNewTaskView({PlantProvider? plantProvider}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlantProvider>.value(
          value: plantProvider ?? PlantProvider(FakePlantDao()),
        ),
        ChangeNotifierProvider<TaskProvider>.value(
          value: TaskProvider(FakeTaskDao()),
        ),
      ],
      child: const MaterialApp(home: NewTaskView()),
    );
  }

  group('NewTaskView', () {
    testWidgets('shows app bar with title and save button', (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      expect(find.text('New Task'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('shows all form sections', (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      expect(find.text('Select Plant'), findsOneWidget);
      expect(find.text('Task Type'), findsOneWidget);
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('Recurrence'), findsOneWidget);
      expect(find.text('Reminder Time'), findsOneWidget);
    });

    testWidgets('shows Choose a plant hint', (tester) async {
      await tester.pumpWidget(buildNewTaskView());
      expect(find.text('Choose a plant'), findsOneWidget);
    });

    testWidgets('shows No reminder default', (tester) async {
      await tester.pumpWidget(buildNewTaskView());
      expect(find.text('No reminder'), findsOneWidget);
    });

    testWidgets('tapping save without plant shows snackbar', (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please select a plant'), findsOneWidget);
    });

    testWidgets('displays plants in dropdown', (tester) async {
      final dao = FakePlantDao();
      await dao.insertPlant(
          makePlant(id: 1, name: 'Fern', imagePath: testImage.path));
      await dao.insertPlant(
          makePlant(id: 2, name: 'Cactus', imagePath: testImage.path));
      final provider = PlantProvider(dao);
      await provider.loadPlants();

      await tester.pumpWidget(buildNewTaskView(plantProvider: provider));

      // Open the plant dropdown
      await tester.tap(find.text('Choose a plant'));
      await tester.pumpAndSettle();

      expect(find.text('Fern'), findsWidgets);
      expect(find.text('Cactus'), findsWidgets);
    });

    testWidgets('shows task type options in dropdown', (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      // Default is 'watering', open the task type dropdown
      // First find the dropdown that contains 'Watering'
      await tester.tap(find.text('Watering'));
      await tester.pumpAndSettle();

      expect(find.text('Watering'), findsWidgets);
      expect(find.text('Light'), findsWidgets);
      expect(find.text('Fertilizing'), findsWidgets);
      expect(find.text('Custom'), findsWidgets);
    });

    testWidgets('selecting custom task type shows custom note field',
        (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      // Open task type dropdown
      await tester.tap(find.text('Watering'));
      await tester.pumpAndSettle();

      // Select custom
      await tester.tap(find.text('Custom').last);
      await tester.pumpAndSettle();

      expect(find.text('Custom Note'), findsOneWidget);
    });

    testWidgets('shows recurrence options', (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      // Open recurrence dropdown
      await tester.tap(find.text('No recurrence'));
      await tester.pumpAndSettle();

      expect(find.text('No recurrence'), findsWidgets);
      expect(find.text('Daily'), findsWidgets);
      expect(find.text('Every X days'), findsWidgets);
      expect(find.text('Weekly'), findsWidgets);
    });

    testWidgets('selecting interval recurrence shows interval field',
        (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      // Open recurrence dropdown
      await tester.tap(find.text('No recurrence'));
      await tester.pumpAndSettle();

      // Select interval
      await tester.tap(find.text('Every X days').last);
      await tester.pumpAndSettle();

      expect(find.text('Every how many days?'), findsOneWidget);
    });

    testWidgets('selecting daily recurrence shows end date option',
        (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      // Scroll down to see recurrence field
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Open recurrence dropdown
      await tester.tap(find.text('No recurrence'));
      await tester.pumpAndSettle();

      // Select daily
      await tester.tap(find.text('Daily').last);
      await tester.pumpAndSettle();

      expect(find.text('End Date (optional)'), findsOneWidget);
      expect(
          find.text('No end date (60 days by default)'), findsOneWidget);
    });

    testWidgets('displays start date', (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      final now = DateTime.now();
      expect(find.text('${now.day}/${now.month}/${now.year}'), findsOneWidget);
    });

    testWidgets('selecting weekly recurrence shows end date option',
        (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      // Scroll down to recurrence field
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Open recurrence dropdown
      await tester.tap(find.text('No recurrence'));
      await tester.pumpAndSettle();

      // Select weekly
      await tester.tap(find.text('Weekly').last);
      await tester.pumpAndSettle();

      expect(find.text('End Date (optional)'), findsOneWidget);
    });

    testWidgets('can select a plant and save task', (tester) async {
      final plantDao = FakePlantDao();
      await plantDao.insertPlant(
          makePlant(id: 1, name: 'Fern', imagePath: testImage.path));
      final plantProvider = PlantProvider(plantDao);
      await plantProvider.loadPlants();

      final taskDao = FakeTaskDao();
      final taskProvider = TaskProvider(taskDao);

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<PlantProvider>.value(value: plantProvider),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ],
        child: const MaterialApp(home: NewTaskView()),
      ));

      // Select the plant from dropdown
      await tester.tap(find.text('Choose a plant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fern').last);
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Task should have been created
      expect(taskProvider.instances.length, 1);
    });

    testWidgets('tapping start date shows date picker', (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      final now = DateTime.now();
      // Tap on the start date tile
      await tester.tap(find.text('${now.day}/${now.month}/${now.year}'));
      await tester.pumpAndSettle();

      // Date picker should be visible
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('tapping reminder time tile shows time picker', (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      // Scroll down to see reminder time
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap on the reminder time tile
      await tester.tap(find.text('No reminder'));
      await tester.pumpAndSettle();

      // Time picker should be visible
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('task type dropdown shows icons', (tester) async {
      await tester.pumpWidget(buildNewTaskView());

      // Open task type dropdown
      await tester.tap(find.text('Watering'));
      await tester.pumpAndSettle();

      // Check icons are present in dropdown items
      expect(find.byIcon(Icons.water_drop), findsWidgets);
      expect(find.byIcon(Icons.wb_sunny), findsWidgets);
      expect(find.byIcon(Icons.eco), findsWidgets);
      expect(find.byIcon(Icons.task_alt), findsWidgets);
    });

    testWidgets('selecting plant shows colored avatar in dropdown',
        (tester) async {
      final plantDao = FakePlantDao();
      await plantDao.insertPlant(
          makePlant(id: 1, name: 'Fern', imagePath: testImage.path));
      final plantProvider = PlantProvider(plantDao);
      await plantProvider.loadPlants();

      await tester.pumpWidget(buildNewTaskView(plantProvider: plantProvider));

      // Open plant dropdown
      await tester.tap(find.text('Choose a plant'));
      await tester.pumpAndSettle();

      // CircleAvatar should be shown in the dropdown item
      expect(find.byType(CircleAvatar), findsWidgets);
    });
  });
}

