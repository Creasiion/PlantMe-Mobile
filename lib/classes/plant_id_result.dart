class PlantIdResult {
  final String species;
  final String description;
  final String descriptionGpt;
  final String commonUses;

  PlantIdResult({
    required this.species,
    required this.description,
    required this.descriptionGpt,
    required this.commonUses,
  });

  factory PlantIdResult.fromJson(Map<String, dynamic> json) {
    final suggestion = json['result']['classification']['suggestions'][0];
    final details = suggestion['details'] ?? {};

    final watering = details['best_watering'] ?? 'Unknown';
    final light = details['best_light_condition'] ?? 'Unknown';
    final toxicity = details['toxicity'] ?? 'Unknown';

    return PlantIdResult(
      species: suggestion['name'] ?? 'Unknown',
      description: 'Watering: $watering | Light: $light | Toxicity: $toxicity',
      descriptionGpt: details['description_gpt'] ?? '',
      commonUses: details['common_uses'] ?? '',
    );
  }

  factory PlantIdResult.fromSearchJson(Map<String, dynamic> json) {
    final watering = json['best_watering'] ?? 'Unknown';
    final light = json['best_light_condition'] ?? 'Unknown';
    final toxicity = json['toxicity'] ?? 'Unknown';
    final commonNames = json['common_names'] as List?;

    return PlantIdResult(
      species: commonNames != null && commonNames.isNotEmpty
          ? commonNames[0]
          : 'Unknown',
      description: 'Watering: $watering | Light: $light | Toxicity: $toxicity',
      descriptionGpt: json['description_gpt'] ?? '',
      commonUses: json['common_uses'] ?? '',
    );
  }
}