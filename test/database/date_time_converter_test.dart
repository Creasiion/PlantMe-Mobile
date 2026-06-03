import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/database/date_time_converter.dart';

void main() {
  late DateTimeConverter converter;

  setUp(() {
    converter = DateTimeConverter();
  });

  group('DateTimeConverter', () {
    test('encode converts DateTime to millisecondsSinceEpoch', () {
      final dateTime = DateTime(2025, 6, 1, 12, 30);
      final encoded = converter.encode(dateTime);
      expect(encoded, dateTime.millisecondsSinceEpoch);
    });

    test('decode converts int back to DateTime', () {
      final millis = DateTime(2025, 6, 1, 12, 30).millisecondsSinceEpoch;
      final decoded = converter.decode(millis);
      expect(decoded, DateTime(2025, 6, 1, 12, 30));
    });

    test('encode then decode is identity', () {
      final original = DateTime(2025, 3, 15, 9, 45, 30);
      final result = converter.decode(converter.encode(original));
      expect(result, original);
    });

    test('handles epoch zero', () {
      final decoded = converter.decode(0);
      expect(decoded, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}
