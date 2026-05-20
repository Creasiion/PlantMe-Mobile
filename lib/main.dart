import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_me/database/app_database.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'views/homepage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final database = await $FloorAppDatabase
      .databaseBuilder('plant_me.db')
      .build();

  final plantProvider = PlantProvider(database.plantDao);
  await plantProvider.loadPlants();

  runApp(
    ChangeNotifierProvider.value(
      value: plantProvider,
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
