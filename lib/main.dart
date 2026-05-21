import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_me/database/app_database.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/providers/task_provider.dart';
import 'package:plant_me/services/notification_service.dart';
import 'views/homepage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService().init();

  final database = await $FloorAppDatabase
      .databaseBuilder('plant_me.db')
      .build();

  final plantProvider = PlantProvider(database.plantDao);
  await plantProvider.loadPlants();

  final taskProvider = TaskProvider(
    database.taskDao,
    notificationService: NotificationService(),
  );
  await taskProvider.loadInstances();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: plantProvider),
        ChangeNotifierProvider.value(value: taskProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantMe Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'PlantMe'),
    );
  }
}