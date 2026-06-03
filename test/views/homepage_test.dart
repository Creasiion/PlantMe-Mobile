import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_me/providers/plant_provider.dart';
import 'package:plant_me/providers/task_provider.dart';
import 'package:plant_me/views/homepage.dart';
import 'package:provider/provider.dart';
import '../helpers/test_helpers.dart';
import '../providers/plant_provider_test.dart' show FakePlantDao;
import '../providers/task_provider_test.dart' show FakeTaskDao;

/// Returns a 1x1 transparent PNG as bytes.
Uint8List get _transparentPng => kTransparentPng;

/// Mock [HttpOverrides] that intercepts all HTTP requests and returns a
/// transparent 1x1 PNG.  This prevents [Image.network] from hitting the
/// real network in widget tests.
class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  late File testImage;

  setUpAll(() async {
    testImage = await createTestImageFile();
    HttpOverrides.global = _MockHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
    testImage.parent.deleteSync(recursive: true);
  });

  Widget buildHomepage({PlantProvider? plantProvider}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlantProvider>.value(
          value: plantProvider ?? PlantProvider(FakePlantDao()),
        ),
        ChangeNotifierProvider<TaskProvider>.value(
          value: TaskProvider(FakeTaskDao()),
        ),
      ],
      child: const MaterialApp(home: MyHomePage(title: 'PlantMe')),
    );
  }

  group('MyHomePage', () {
    testWidgets('shows title in app bar', (tester) async {
      await tester.pumpWidget(buildHomepage());
      await tester.pump();
      expect(find.text('PlantMe'), findsOneWidget);
    });

    testWidgets('shows Get Started message when no plants', (tester) async {
      await tester.pumpWidget(buildHomepage());
      await tester.pump();
      expect(find.text('Get Started!'), findsOneWidget);
      expect(
        find.text(
            'Create a profile by clicking the + in the bottom-right corner'),
        findsOneWidget,
      );
    });

    testWidgets('shows Welcome back when plants exist', (tester) async {
      final dao = FakePlantDao();
      await dao.insertPlant(makePlant(name: 'Fern', imagePath: testImage.path));
      final provider = PlantProvider(dao);
      await provider.loadPlants();

      await tester.pumpWidget(buildHomepage(plantProvider: provider));
      await tester.pump();

      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('shows My Plants section', (tester) async {
      await tester.pumpWidget(buildHomepage());
      await tester.pump();
      expect(find.text('My Plants'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('displays plant names in grid', (tester) async {
      final dao = FakePlantDao();
      await dao.insertPlant(makePlant(name: 'Fern', imagePath: testImage.path));
      await dao
          .insertPlant(makePlant(name: 'Cactus', imagePath: testImage.path));
      final provider = PlantProvider(dao);
      await provider.loadPlants();

      await tester.pumpWidget(buildHomepage(plantProvider: provider));
      await tester.pump();

      // Scroll down to reveal plant grid beneath the banner
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('Fern'), findsOneWidget);
      expect(find.text('Cactus'), findsOneWidget);
    });

    testWidgets('shows FAB with add icon', (tester) async {
      await tester.pumpWidget(buildHomepage());
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows bottom navigation bar with Home and Calendar',
        (tester) async {
      await tester.pumpWidget(buildHomepage());
      await tester.pump();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });
  });
}
