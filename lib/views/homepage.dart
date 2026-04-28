import 'package:flutter/material.dart';
import 'package:plant_me/classes/plant_profile.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // REMOVE LATER, HARDCODED PLANT SAMPLE
  final List<PlantProfile> plants = [
    PlantProfile(
      name: 'Aloe Vera',
      plantSpecies: 'Aloe'
    ),
    PlantProfile(
      name: 'Snake Plant',
      plantSpecies: 'Sansevieria'
    ),
    PlantProfile(
      name: 'Monstera',
      plantSpecies: 'Monstera Deliciosa'
    ),
    PlantProfile(
      name: 'Peace Lily',
      plantSpecies: 'Spathiphyllum'
    ),
    PlantProfile(
      name: 'Cactus',
      plantSpecies: 'Cactaceae'
    ),
    PlantProfile(
      name: 'Pothos',
      plantSpecies: 'Epipremnum Aureum'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.count(
          crossAxisCount: 3, // 3 columns
          crossAxisSpacing: 5,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
          children: plants.map((plant) {
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      plant.img,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(
                  plant.name,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
