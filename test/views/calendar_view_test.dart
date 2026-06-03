import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/classes/plant_task.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/providers/task_provider.dart';
import 'package:plant_me/views/calendar_view.dart';
import 'package:provider/provider.dart';
import '../helpers/test_helpers.dart';
import '../providers/plant_provider_test.dart' show FakePlantDao;
import '../providers/task_provider_test.dart' show FakeTaskDao;

void main() {
  Widget buildCalendar({
    PlantProvider? plantProvider,
    TaskProvider? taskProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlantProvider>.value(
          value: plantProvider ?? PlantProvider(FakePlantDao()),
        ),
        ChangeNotifierProvider<TaskProvider>.value(
          value: taskProvider ?? TaskProvider(FakeTaskDao()),
        ),
      ],
      child: const MaterialApp(home: CalendarView()),
    );
  }

  group('CalendarView', () {
    testWidgets('shows Care Calendar title', (tester) async {
      await tester.pumpWidget(buildCalendar());
      expect(find.text('Care Calendar'), findsOneWidget);
    });

    testWidgets('shows bottom navigation bar', (tester) async {
      await tester.pumpWidget(buildCalendar());
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('shows FAB for adding tasks', (tester) async {
      await tester.pumpWidget(buildCalendar());
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows empty state when no tasks for selected day',
        (tester) async {
      await tester.pumpWidget(buildCalendar());
      expect(find.text('No tasks for this day 🌱'), findsOneWidget);
    });

    testWidgets('displays task instances for selected day', (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      // Create a task for today
      final today = DateTime.now();
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(today.year, today.month, today.day),
      );
      await taskProvider.addTask(task);

      // Set up plant provider with a plant matching the profile id
      final plantDao = FakePlantDao();
      await plantDao.insertPlant(makePlant(id: 1, name: 'My Fern'));
      final plantProvider = PlantProvider(plantDao);
      await plantProvider.loadPlants();

      await tester.pumpWidget(buildCalendar(
        plantProvider: plantProvider,
        taskProvider: taskProvider,
      ));

      expect(find.text('watering'), findsOneWidget);
    });

    testWidgets('shows custom note for custom task type', (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      final today = DateTime.now();
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'custom',
        customNote: 'Repot the plant',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(today.year, today.month, today.day),
      );
      await taskProvider.addTask(task);

      await tester.pumpWidget(buildCalendar(taskProvider: taskProvider));

      expect(find.text('Repot the plant'), findsOneWidget);
    });

    testWidgets('tapping check icon toggles task completion', (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      final today = DateTime.now();
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(today.year, today.month, today.day),
      );
      await taskProvider.addTask(task);

      await tester.pumpWidget(buildCalendar(taskProvider: taskProvider));

      // Find and tap the check icon
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('long press shows delete options', (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      final today = DateTime.now();
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(today.year, today.month, today.day),
      );
      await taskProvider.addTask(task);

      await tester.pumpWidget(buildCalendar(taskProvider: taskProvider));

      // Long press on the task ListTile
      await tester.longPress(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(find.text('Delete this event'), findsOneWidget);
      expect(find.text('Delete this and following events'), findsOneWidget);
      expect(find.text('Delete all events in series'), findsOneWidget);
    });

    testWidgets('delete this and following events removes future instances',
        (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      final today = DateTime.now();
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'daily',
        recurrenceInterval: 1,
        startDate: DateTime(today.year, today.month, today.day),
        endDateMillis: DateTime(today.year, today.month, today.day + 2)
            .millisecondsSinceEpoch,
      );
      await taskProvider.addTask(task);

      // Verify 3 instances were created
      expect(taskProvider.instances.length, 3);

      await tester.pumpWidget(buildCalendar(taskProvider: taskProvider));

      // Long press to open delete menu
      await tester.longPress(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Tap 'Delete this and following events'
      await tester.tap(find.text('Delete this and following events'));
      await tester.pumpAndSettle();

      // All instances from today onward should be deleted
      expect(find.text('No tasks for this day 🌱'), findsOneWidget);
    });

    testWidgets('delete all events in series removes everything',
        (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      final today = DateTime.now();
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'daily',
        recurrenceInterval: 1,
        startDate: DateTime(today.year, today.month, today.day),
        endDateMillis: DateTime(today.year, today.month, today.day + 2)
            .millisecondsSinceEpoch,
      );
      await taskProvider.addTask(task);

      expect(taskProvider.instances.length, 3);

      await tester.pumpWidget(buildCalendar(taskProvider: taskProvider));

      // Long press to open delete menu
      await tester.longPress(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Tap 'Delete all events in series'
      await tester.tap(find.text('Delete all events in series'));
      await tester.pumpAndSettle();

      expect(taskProvider.instances, isEmpty);
    });

    testWidgets('displays multiple tasks for same day', (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day);

      await taskProvider.addTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: startDate,
      ));
      await taskProvider.addTask(PlantTask(
        plantProfileId: 1,
        taskType: 'light',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: startDate,
      ));

      await tester.pumpWidget(buildCalendar(taskProvider: taskProvider));

      expect(find.text('watering'), findsOneWidget);
      expect(find.text('light'), findsOneWidget);
    });

    testWidgets('shows plant name in task subtitle', (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      final today = DateTime.now();
      await taskProvider.addTask(PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(today.year, today.month, today.day),
      ));

      // Plant provider without matching plant shows "Unknown Plant"
      await tester.pumpWidget(buildCalendar(taskProvider: taskProvider));
      expect(find.text('Unknown Plant'), findsOneWidget);
    });

    testWidgets('shows Custom Task for custom type without note',
        (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      final today = DateTime.now();
      await taskProvider.addTask(PlantTask(
        plantProfileId: 1,
        taskType: 'custom',
        customNote: null,
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(today.year, today.month, today.day),
      ));

      await tester.pumpWidget(buildCalendar(taskProvider: taskProvider));
      expect(find.text('Custom Task'), findsOneWidget);
    });

    testWidgets('delete this event removes the instance', (tester) async {
      final dao = FakeTaskDao();
      final taskProvider = TaskProvider(dao);

      final today = DateTime.now();
      final task = PlantTask(
        plantProfileId: 1,
        taskType: 'watering',
        recurrenceType: 'none',
        recurrenceInterval: 1,
        startDate: DateTime(today.year, today.month, today.day),
      );
      await taskProvider.addTask(task);

      await tester.pumpWidget(buildCalendar(taskProvider: taskProvider));

      // Long press to open delete menu
      await tester.longPress(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Tap 'Delete this event'
      await tester.tap(find.text('Delete this event'));
      await tester.pumpAndSettle();

      expect(find.text('No tasks for this day 🌱'), findsOneWidget);
    });
  });
}
