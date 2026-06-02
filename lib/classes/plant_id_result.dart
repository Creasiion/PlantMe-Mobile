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

  /// Pulls readable text whether the field is a plain String, a Map shaped
  /// like { "value": "..." }, or null.
  static String _text(dynamic field) {
    if (field == null) return '';
    if (field is String) return field;
    if (field is Map) {
      final value = field['value'];
      if (value is String) return value;
      if (value != null) return value.toString();
    }
    return '';
  }

  /// Prefer the Wikipedia description; fall back to the GPT one when empty.
  static String _bestDescription(Map details) {
    final wiki = _text(details['description']);
    if (wiki.isNotEmpty) return wiki;
    return _text(details['description_gpt']);
  }

  factory PlantIdResult.fromJson(Map<String, dynamic> json) {
    final suggestion = json['result']['classification']['suggestions'][0];
    final details = suggestion['details'] ?? {};

    final watering = _text(details['best_watering']);
    final light = _text(details['best_light_condition']);
    final toxicity = _text(details['toxicity']);

    return PlantIdResult(
      species: suggestion['name'] ?? 'Unknown',
      description:
      'Watering: ${watering.isEmpty ? 'Unknown' : watering} | Light: ${light.isEmpty ? 'Unknown' : light} | Toxicity: ${toxicity.isEmpty ? 'Unknown' : toxicity}',
      descriptionGpt: _bestDescription(details),
      commonUses: _text(details['common_uses']),
    );
  }

  factory PlantIdResult.fromSearchJson(Map<String, dynamic> json) {
    final watering = _text(json['best_watering']);
    final light = _text(json['best_light_condition']);
    final toxicity = _text(json['toxicity']);
    final commonNames = json['common_names'] as List?;

    return PlantIdResult(
      species: commonNames != null && commonNames.isNotEmpty
          ? commonNames[0]
          : 'Unknown',
      description:
      'Watering: ${watering.isEmpty ? 'Unknown' : watering} | Light: ${light.isEmpty ? 'Unknown' : light} | Toxicity: ${toxicity.isEmpty ? 'Unknown' : toxicity}',
      descriptionGpt: _bestDescription(json),
      commonUses: _text(json['common_uses']),
    );
  }
}