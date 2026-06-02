import 'package:flutter/cupertino.dart';
import 'package:plant_me/classes/plant_profile.dart';
import 'package:plant_me/database/plant_dao.dart';

class PlantProvider extends ChangeNotifier {
  final PlantDao _plantDao;
  final List<PlantProfile> _plantProfiles = [];

  PlantProvider(this._plantDao);

  List<PlantProfile> get plantProfiles {
    final sortedPlants = List<PlantProfile>.from(_plantProfiles);
    sortedPlants.sort((a, b) => b.timeCreated.compareTo(a.timeCreated));
    return sortedPlants;
  }

  Future<void> loadPlants() async {
    final plants = await _plantDao.getAllPlants();
    _plantProfiles
      ..clear()
      ..addAll(plants);
    notifyListeners();
  }
  Future<void> addPlantProfile(PlantProfile plantProfile) async {
    await _plantDao.insertPlant(plantProfile);
    await loadPlants();
  }
}
