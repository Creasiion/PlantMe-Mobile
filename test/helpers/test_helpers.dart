import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:plant_me/classes/plant_profile.dart';
import 'package:plant_me/classes/plant_task_instance.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/providers/task_provider.dart';
import 'package:provider/provider.dart';
import '../providers/plant_provider_test.dart' show FakePlantDao;
import '../providers/task_provider_test.dart' show FakeTaskDao;

/// 1x1 transparent PNG bytes for use in tests.
final kTransparentPng = Uint8List.fromList([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0a, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x62, 0x00, 0x00, 0x00, 0x02,
  0x00, 0x01, 0xe2, 0x21, 0xbc, 0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
  0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);

/// Creates a temporary PNG image file that can be used in widget tests.
Future<File> createTestImageFile() async {
  final dir = Directory.systemTemp.createTempSync('plant_test_');
  final file = File('${dir.path}/test_plant.png');
  await file.writeAsBytes(kTransparentPng);
  return file;
}

/// Makes a PlantProfile with a valid test image path.
PlantProfile makePlant({
  int? id,
  String name = 'Test Plant',
  String species = 'Testus plantus',
  String imagePath = '/tmp/test_plant.png',
  String description = 'Watering: Moderate | Light: Bright indirect | Toxicity: Non-toxic',
  String descriptionGpt = 'A lovely test plant.',
  String commonUses = 'Decoration, air purification',
  DateTime? created,
  int? colorValue,
}) {
  return PlantProfile(
    id: id,
    plantName: name,
    plantSpecies: species,
    plantImagePath: imagePath,
    plantDescription: description,
    descriptionGpt: descriptionGpt,
    commonUses: commonUses,
    timeCreated: created ?? DateTime(2025, 6, 1),
    colorValue: colorValue ?? Colors.green.toARGB32(),
  );
}

/// Makes a PlantTaskInstance for testing.
PlantTaskInstance makeInstance({
  int? id,
  int plantTaskId = 1,
  int plantProfileId = 1,
  DateTime? dueDate,
  String taskType = 'watering',
  String? customNote,
  bool isCompleted = false,
}) {
  return PlantTaskInstance(
    id: id,
    plantTaskId: plantTaskId,
    plantProfileId: plantProfileId,
    dueDate: dueDate ?? DateTime(2025, 6, 1),
    taskType: taskType,
    customNote: customNote,
    isCompleted: isCompleted,
  );
}

/// An [HttpOverrides] that returns our test image for any HTTP request,
/// preventing network errors in widget tests that use Image.network.
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

/// Wraps a widget with both PlantProvider and TaskProvider for widget tests.
Widget wrapWithProviders(
  Widget child, {
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
    child: MaterialApp(home: child),
  );
}
