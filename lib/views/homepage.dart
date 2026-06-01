import 'package:flutter/material.dart';
import 'package:plant_me/views/plant_detail_view.dart';
import 'dart:io';
import 'new_plant_view.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:provider/provider.dart';
import 'package:plant_me/views/calendar_view.dart';
import 'package:plant_me/views/all_plant_profiles_view.dart';


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
        automaticallyImplyLeading: false,
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
                children: [
                  Text(
                    'My Plants',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllPlantsView(),
                        ),
                      );
                    },
                    label: const Text('View All'),
                    icon: const Icon(Icons.star),
                  )
                ],
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),

            SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                  final plant = plants[index];

                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlantProfileView(
                              plant: plant,
                            ),
                          ),
                        );
                      },
                    child: Column(
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
                    ),
                  );
                },
                childCount: plants.length > 9 ? 9 : plants.length,
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
        ],

        currentIndex: 0,

        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarView(),
              ),
            );
          }
        },
      ),
    );
  }
}
