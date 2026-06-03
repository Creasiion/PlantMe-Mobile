import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/views/new_plant_view.dart';
import '../providers/plant_provider_test.dart' show FakePlantDao;

Widget _wrapInApp(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => PlantProvider(FakePlantDao()),
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

    testWidgets('displays search by name field and button', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      expect(find.text('or Search by name'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('can enter text in Plant Name field', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      await tester.enterText(
        find.widgetWithText(TextField, 'Plant Name'),
        'My Fern',
      );
      expect(find.text('My Fern'), findsOneWidget);
    });

    testWidgets('can enter text in Species field', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      await tester.enterText(
        find.widgetWithText(TextField, 'Species'),
        'Nephrolepis',
      );
      expect(find.text('Nephrolepis'), findsOneWidget);
    });

    testWidgets('can enter text in Description field', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      // Scroll down to see description field
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'A beautiful fern',
      );
      expect(find.text('A beautiful fern'), findsOneWidget);
    });

    testWidgets('can enter text in search field', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      await tester.enterText(
        find.widgetWithText(TextField, 'or Search by name'),
        'Boston Fern',
      );
      expect(find.text('Boston Fern'), findsOneWidget);
    });

    testWidgets('tapping Search with empty field does nothing', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      // Tap search with empty search field
      await tester.tap(find.text('Search'));
      await tester.pump();

      // No snackbar or loading indicator
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('image area shows add_a_photo icon initially', (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      // Container should show the camera icon
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });

    testWidgets('source chooser has camera and gallery options',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(const NewPlantView()));

      // Open source chooser
      await tester.tap(find.byIcon(Icons.add_a_photo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.photo_camera), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });
  });
}

