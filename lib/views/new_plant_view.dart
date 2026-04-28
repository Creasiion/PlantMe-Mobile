import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:plant_me/classes/plant_profile.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:provider/provider.dart';

class NewPlantView extends StatefulWidget {
  const NewPlantView({super.key});

  @override
  State<NewPlantView> createState() => _NewPlantViewState();
}

class _NewPlantViewState extends State<NewPlantView> {
  final _plantNameController = TextEditingController();
  final _plantSpeciesController = TextEditingController();
  final _plantDescriptionController = TextEditingController();

  File? _selectedPlantImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromSource(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedPlantImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceChooser() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _savePlantProfile() {
    if (_selectedPlantImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an image before saving')),
      );
      return; // XFile is weird, this lets us assert we have an actual image
    }

    final plantProfile = PlantProfile(
      plantName: _plantNameController.text.trim(),
      plantSpecies: _plantSpeciesController.text.trim(),
      plantImage: _selectedPlantImage!,
      plantDescription: _plantDescriptionController.text.trim(),
      timeCreated: DateTime.now(),
    );

    context.read<PlantProvider>().addPlantProfile(plantProfile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('New Plant Profile')),
        actions: [
          IconButton(onPressed: _savePlantProfile, icon: const Icon(Icons.save))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _plantNameController,
              decoration: const InputDecoration(
                labelText: 'Plant Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _plantSpeciesController,
              decoration: const InputDecoration(
                labelText: 'Species',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showImageSourceChooser,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: _selectedPlantImage != null
                    ? Image.file(_selectedPlantImage!, fit: BoxFit.cover)
                    : const Center(
                  child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _plantDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              minLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _plantSpeciesController.dispose();
    _plantDescriptionController.dispose();

    super.dispose();
  }
}