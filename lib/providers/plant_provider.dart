import 'package:flutter/cupertino.dart';
import 'package:plant_me/classes/plant_profile.dart';

class PlantProvider extends ChangeNotifier {
  final List<PlantProfile> _plantProfiles = [];

  List<PlantProfile> get plantProfiles {
    final sortedPlants = List<PlantProfile>.from(_plantProfiles);
    sortedPlants.sort((a,b) => b.timeCreated.compareTo(a.timeCreated));

    return sortedPlants; // Newest -> Oldest
  }

  void addPlantProfile(PlantProfile plantProfile) {
    _plantProfiles.add(plantProfile);
    notifyListeners();
  }
}