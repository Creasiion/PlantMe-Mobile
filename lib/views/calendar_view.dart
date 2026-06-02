import 'package:flutter/material.dart';
import 'package:plant_me/classes/plant_task_instance.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/providers/task_provider.dart';
import 'package:plant_me/views/new_task_view.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'homepage.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final plantProvider = context.watch<PlantProvider>();
    final selectedInstances = taskProvider.getInstancesForDate(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Care Calendar'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return taskProvider.getInstancesForDate(day);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox();

                // Show colored dots based on plant color
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.take(3).map((e) {
                    final instance = e as PlantTaskInstance;
                    final plant = plantProvider.plantProfiles
                        .where((p) => p.id == instance.plantProfileId)
                        .firstOrNull;
                    final color = plant?.color ?? Colors.green;

                    return Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: instance.isCompleted
                            ? color.withOpacity(0.3)
                            : color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const Divider(),

          // Task list for selected day
          Expanded(
            child: selectedInstances.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks for this day 🌱',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedInstances.length,
                    itemBuilder: (context, index) {
                      final instance = selectedInstances[index];
                      final plant = plantProvider.plantProfiles
                          .where((p) => p.id == instance.plantProfileId)
                          .firstOrNull;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: plant?.color ?? Colors.green,
                          child: Icon(
                            _taskIcon(instance.taskType),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        title: Text(instance.taskType == 'custom'
                            ? instance.customNote ?? 'Custom Task'
                            : instance.taskType),
                        subtitle: Text(plant?.plantName ?? 'Unknown Plant'),
                        trailing: IconButton(
                          icon: Icon(
                            instance.isCompleted
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                            color: Colors.green,
                            size: 32,
                            ),
                            onPressed: () {
                              context.read<TaskProvider>().completeInstance(instance);
                            },
),
                        onLongPress: () => _showDeleteOptions(context, instance),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewTaskView()),
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

        currentIndex: 1,

        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MyHomePage(title: 'PlantMe'),
              ),
            );
          }
        },
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

  void _showDeleteOptions(BuildContext context, PlantTaskInstance instance) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete this event'),
              onTap: () {
                Navigator.pop(context);
                context.read<TaskProvider>().deleteInstance(instance);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Delete this and following events'),
              onTap: () {
                Navigator.pop(context);
                context.read<TaskProvider>().deleteInstanceAndFollowing(instance);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Delete all events in series'),
              onTap: () async {
                Navigator.pop(context);
                final taskProvider = context.read<TaskProvider>();
                final task = await taskProvider.getTaskById(instance.plantTaskId);
                if (task != null) {
                  taskProvider.deleteAllInstances(task);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}