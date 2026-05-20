import 'package:floor/floor.dart';
// Floor only takes in a couple types and since we used DateTime for sorting
// we need it to have it be a column in the database. If it breaks we can just
// switch to an int for the entity and write a function in provider to convert
class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}
