import 'dart:io';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plant_me/classes/plant_id_result.dart';
import 'package:plant_me/classes/plant_profile.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/services/plant_id_service.dart';
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
  final _searchController = TextEditingController();

  File? _selectedPlantImage;
  bool _identifying = false;
  Color _selectedColor = Colors.green;
  PlantIdResult? _identificationResult;
  final ImagePicker _picker = ImagePicker();
  final PlantIdService _plantIdService = PlantIdService();

  @override
  void initState() {
    super.initState();
    _retrieveLostData();
  }

  Future<void> _retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.file != null) {
      final imageFile = File(response.file!.path);
      setState(() {
        _selectedPlantImage = imageFile;
        _identifying = true;
      });
      final result = await _plantIdService.identifyFromImage(imageFile);
      if (result != null) {
        setState(() {
          _identificationResult = result;
          _plantSpeciesController.text = result.species;
          _plantDescriptionController.text = result.description;
          _identifying = false;
        });
      } else {
        setState(() => _identifying = false);
      }
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _selectedPlantImage = imageFile;
        _identifying = true;
      });

      if (_plantSpeciesController.text.trim().isEmpty) {
        final result = await _plantIdService.identifyFromImage(imageFile);
        if (result != null) {
          setState(() {
            _identificationResult = result;
            _plantSpeciesController.text = result.species;
            _plantDescriptionController.text = result.description;
            _identifying = false;
          });
        } else {
          setState(() => _identifying = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not identify plant, please fill in manually')),
            );
          }
        }
      } else {
        setState(() => _identifying = false);
      }
    }
  }

  Future<void> _searchByName() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _identifying = true);

    final result = await _plantIdService.searchByName(query);

    if (result != null) {
      setState(() {
        _identificationResult = result;
        _plantSpeciesController.text = result.species;
        _plantDescriptionController.text = result.description;
        _identifying = false;
      });
    } else {
      setState(() => _identifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No plant found, try a different name')),
        );
      }
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

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a plant color'),
        content: BlockPicker(
          pickerColor: _selectedColor,
          onColorChanged: (color) {
            setState(() => _selectedColor = color);
          },
        ),
        actions: [
          TextButton(
            child: const Text('Done'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlantProfile() async {
    if (_selectedPlantImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an image before saving')),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'plant_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final permanentImage = await _selectedPlantImage!.copy('${appDir.path}/$fileName');

    final plantProfile = PlantProfile(
      plantName: _plantNameController.text.trim(),
      plantSpecies: _plantSpeciesController.text.trim(),
      plantImagePath: permanentImage.path,
      plantDescription: _plantDescriptionController.text.trim(),
      descriptionGpt: _identificationResult?.descriptionGpt ?? '',
      commonUses: _identificationResult?.commonUses ?? '',
      timeCreated: DateTime.now(),
      colorValue: _selectedColor.toARGB32(),
    );

    await context.read<PlantProvider>().addPlantProfile(plantProfile);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('New Plant Profile')),
        actions: [
          IconButton(
            onPressed: _savePlantProfile,
            icon: const Icon(Icons.save),
          )
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
              onTap: _identifying ? null : _showImageSourceChooser,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: _identifying
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedPlantImage != null
                        ? Image.file(_selectedPlantImage!, fit: BoxFit.cover)
                        : const Center(
                            child: Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'or Search by name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _identifying ? null : _searchByName,
                  child: const Text('Search'),
                ),
              ],
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
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Plant Color'),
              subtitle: const Text('Shows on the calendar'),
              trailing: GestureDetector(
                onTap: _showColorPicker,
                child: CircleAvatar(
                  backgroundColor: _selectedColor,
                  radius: 20,
                ),
              ),
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
    _searchController.dispose();
    super.dispose();
  }
}