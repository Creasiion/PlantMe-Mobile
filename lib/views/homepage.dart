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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: const [
                  Text(
                    'My Plants',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star), // placeholder for "view all"
                ],
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),

            SliverGrid( // Later needs onclick to specified profile
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final plant = plants[index];

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
                },
                childCount: plants.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
