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

  Widget _section(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(fontSize: 18, height: 1.4),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final description = plant.descriptionGpt.isNotEmpty
        ? plant.descriptionGpt
        : 'A beautiful addition to your plant collection 🌱';

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
                  // Header: image + name + species
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _section('About 🌱', description),
                  _section('Watering 💧', _extractWatering()),
                  _section('Light ☀️', _extractLight()),
                  _section('Toxicity 🤢', _extractToxicity()),
                  _section(
                    'Common Uses 🌿',
                    plant.commonUses.isEmpty
                        ? 'No common uses available.'
                        : plant.commonUses,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}