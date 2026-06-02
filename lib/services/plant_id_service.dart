import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:plant_me/classes/plant_id_result.dart';

class PlantIdService {
  final String _apiKey = dotenv.env['PLANT_ID_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.plant.id/v3';

  static const String _details =
      'common_names,best_watering,best_light_condition,toxicity,description,description_gpt,common_uses';

  Future<PlantIdResult?> identifyFromImage(File image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('$_baseUrl/identification?details=$_details'),
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'images': ['data:image/jpg;base64,$base64Image'],
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PlantIdResult.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<PlantIdResult?> searchByName(String name) async {
    try {
      // First call to find the plant by name, get its access_token
      final searchResponse = await http.get(
        Uri.parse(
          '$_baseUrl/kb/plants/name_search?q=${Uri.encodeComponent(name)}&language=en',
        ),
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (searchResponse.statusCode != 200) return null;

      final searchData = jsonDecode(searchResponse.body);
      final entities = searchData['entities'];
      if (entities == null || entities.isEmpty) return null;

      // Grab the access_token from the top result
      final accessToken = entities[0]['access_token'];

      // Second call to use access_token to get full details
      final detailResponse = await http.get(
        Uri.parse(
          '$_baseUrl/kb/plants/$accessToken?details=$_details',
        ),
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (detailResponse.statusCode != 200) return null;

      final detailData = jsonDecode(detailResponse.body);
      return PlantIdResult.fromSearchJson(detailData);
    } catch (e) {
      return null;
    }
  }
}