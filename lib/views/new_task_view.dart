import 'package:flutter/material.dart';
import 'package:plant_me/classes/plant_task.dart';
import 'package:plant_me/classes/plant_task_instance.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/providers/task_provider.dart';
import 'package:provider/provider.dart';

class NewTaskView extends StatefulWidget {
  const NewTaskView({super.key});

  @override
  State<NewTaskView> createState() => _NewTaskViewState();
}

class _NewTaskViewState extends State<NewTaskView> {
  final _customNoteController = TextEditingController();
  final _intervalController = TextEditingController(text: '7');

  String _selectedTaskType = 'watering';
  String _recurrenceType = 'none';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int? _selectedPlantId;

  final List<String> _taskTypes = ['watering', 'light', 'fertilizing', 'custom'];

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _saveTask() async {
    if (_selectedPlantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a plant')),
      );
      return;
    }

    final interval = int.tryParse(_intervalController.text.trim()) ?? 7;

    final task = PlantTask(
      plantProfileId: _selectedPlantId!,
      taskType: _selectedTaskType,
      customNote: _selectedTaskType == 'custom'
          ? _customNoteController.text.trim()
          : null,
      recurrenceType: _recurrenceType,
      recurrenceInterval: interval,
      startDate: _startDate,
      endDateMillis: _endDate?.millisecondsSinceEpoch,
    );

    await context.read<TaskProvider>().addTask(task);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final plants = context.read<PlantProvider>().plantProfiles;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('New Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Plant dropdown
            const Text('Select Plant', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Choose a plant'),
              value: _selectedPlantId,
              items: plants.map((plant) {
                return DropdownMenuItem<int>(
                  value: plant.id,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: plant.color,
                        radius: 10,
                      ),
                      const SizedBox(width: 8),
                      Text(plant.plantName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedPlantId = value),
            ),

            const SizedBox(height: 16),

            // Task type
            const Text('Task Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: _selectedTaskType,
              items: _taskTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_taskIcon(type), size: 18),
                      const SizedBox(width: 8),
                      Text(type[0].toUpperCase() + type.substring(1)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedTaskType = value!),
            ),

            // Custom note field (only shows if custom is selected)
            if (_selectedTaskType == 'custom') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customNoteController,
                decoration: const InputDecoration(
                  labelText: 'Custom Note',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Start date
            const Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickStartDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            // Recurrence
            const Text('Recurrence', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: _recurrenceType,
              items: const [
                DropdownMenuItem(value: 'none', child: Text('No recurrence')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'interval', child: Text('Every X days')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              ],
              onChanged: (value) => setState(() => _recurrenceType = value!),
            ),

            // Interval field (only shows if interval is selected)
            if (_recurrenceType == 'interval') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Every how many days?',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            // End date (only shows if recurring)
            if (_recurrenceType != 'none') ...[
              const SizedBox(height: 16),
              const Text('End Date (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_endDate != null
                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                    : 'No end date (60 days by default)'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickEndDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _taskIcon(String taskType) {
    switch (taskType) {
      case 'watering':
        return Icons.water_drop;
      case 'light':
        return Icons.wb_sunny;
      case 'fertilizing':
        return Icons.eco;
      default:
        return Icons.task_alt;
    }
  }

  @override
  void dispose() {
    _customNoteController.dispose();
    _intervalController.dispose();
    super.dispose();
  }
}