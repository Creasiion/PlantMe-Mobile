import 'package:flutter/material.dart';
import 'dart:io';
import 'new_plant_view.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:provider/provider.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final plants = context.watch<PlantProvider>().plantProfiles;
    final hasPlants = plants.isNotEmpty;

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
                child: Padding(padding: EdgeInsets.only(bottom: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            'https://img.magnific.com/free-vector/houseplant-sticker-botanical-doodle-vector_53876-156464.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasPlants ? 'Welcome back!' : 'Get Started!',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            hasPlants
                                ? 'Let’s check on your plants 🌱'
                                : 'Create a profile by clicking the + in the bottom-right corner',
                          ),
                        ],
                      ),
                    )

                  ],
                )
                )
            ),
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
                          child: Image.file(
                            File(plant.plantImagePath),
                            fit: BoxFit.cover
                          ),
                        ),
                      ),
                      Text(
                        plant.plantName,
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
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NewPlantView()),
            );
          },
          child: const Icon(Icons.add),
      ),
    );
  }
}
