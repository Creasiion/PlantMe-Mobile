import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:provider/provider.dart';

class AllPlantsView extends StatelessWidget {
  const AllPlantsView({super.key});

  @override
  Widget build(BuildContext context) {
    final plants = context.watch<PlantProvider>().plantProfiles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Plants'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(10),

        child: GridView.builder(
          itemCount: plants.length,

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),

          itemBuilder: (context, index) {
            final plant = plants[index];

            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: Image.file(
                      File(plant.plantImagePath),
                      fit: BoxFit.cover,
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
        ),
      ),
    );
  }
}