import 'package:flutter/cupertino.dart';
import 'package:plant_me/classes/plant_profile.dart';

class PlantProvider extends ChangeNotifier {
  final List<PlantProfile> _plantprofiles = [];

  List<PlantProfile> get plantprofiles {
    final sortedPlants = List<PlantProfile>.from(_plantprofiles);
    sortedPlants.sort((a,b) => b.timeCreated.compareTo(a.timeCreated));

    return sortedPlants;
  }

  void addPlantProfile(PlantProfile plantProfile) {
    _plantprofiles.add(plantProfile);
    notifyListeners();
  }
}