import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/views/new_plant_view.dart';

Widget _wrapInApp(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => PlantProvider(),
    child: MaterialApp(home: child),
  );
}

void main() {
    setUpAll(() async {
    dotenv.testLoad(fileInput: 'PLANT_ID_API_KEY=test_key');
  });
  group('NewPlantView', () {
    testWidgets('displays all input fields and the image picker', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      expect(find.text('New Plant Profile'), findsOneWidget);
      expect(find.text('Plant Name'), findsOneWidget);
      expect(find.text('Species'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });


    testWidgets('tapping save without an image shows a SnackBar', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      await tester.tap(find.byIcon(Icons.save));
      await tester.pump(); // start SnackBar animation
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please pick an image before saving'), findsOneWidget);
    });

    testWidgets('tapping the image area opens the source chooser', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      await tester.tap(find.byIcon(Icons.add_a_photo));
      await tester.pumpAndSettle();

      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
    });
  });
}