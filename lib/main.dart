import 'package:flutter/material.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'views/homepage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      ChangeNotifierProvider(
        create: (_) => PlantProvider(),
        child: const MyApp(),)
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantMe Mobile App',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'PlantMe'),
    );
  }
}