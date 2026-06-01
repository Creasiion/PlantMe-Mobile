import 'dart:io';

import 'package:flutter/material.dart';
import '../classes/plant_profile.dart';

class PlantProfileView extends StatelessWidget {
  final PlantProfile plant;

  const PlantProfileView({super.key, required this.plant});

  String _extractWatering() {
    final parts = plant.plantDescription.split('|');

    for (final part in parts) {
      if (part.contains('Watering:')) {
        return part.replaceAll('Watering:', '').trim();
      }
    }

    return 'Unknown';
  }

  String _extractLight() {
    final parts = plant.plantDescription.split('|');

    for (final part in parts) {
      if (part.contains('Light:')) {
        return part.replaceAll('Light:', '').trim();
      }
    }

    return 'Unknown';
  }

  String _extractToxicity() {
    final parts = plant.plantDescription.split('|');

    for (final part in parts) {
      if (part.contains('Toxicity:')) {
        return part.replaceAll('Toxicity:', '').trim();
      }
    }

    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(plant.plantName),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(plant.plantImagePath),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant.plantName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              plant.plantSpecies,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              plant.descriptionGpt.isNotEmpty
                                  ? plant.descriptionGpt
                                  : 'A beautiful addition to your plant collection 🌱',
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Watering
                  const Text(
                    'Watering 💧',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _extractWatering(),
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 30),

                  // Light
                  const Text(
                    'Light ☀️',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _extractLight(),
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 30),

                  // Toxicity
                  const Text(
                    'Toxicity 🤢',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _extractToxicity(),
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 30),

                  // Common Uses
                  const Text(
                    'Common Uses 🌿',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    plant.commonUses.isEmpty
                        ? 'No common uses available.'
                        : plant.commonUses,
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}