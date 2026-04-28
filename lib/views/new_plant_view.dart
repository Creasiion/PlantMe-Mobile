import 'package:flutter/material.dart';
import 'package:plant_me/classes/plant_profile.dart';

class NewPlantView extends StatefulWidget {
  const NewPlantView({super.key});

  @override
  State<NewPlantView> createState() => _NewPlantViewState();
}

class _NewPlantViewState extends State<NewPlantView> {
  void _savePlantProfile() {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('New Plant Profile'),),
        actions: [
          IconButton(onPressed: _savePlantProfile, icon: Icon(Icons.save))
        ],
      ),
    );
  }
}