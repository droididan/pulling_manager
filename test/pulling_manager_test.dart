import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulling_manager/pulling_manager.dart';

void main() {
  // Ensure Flutter binding is initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PullingManager Lifecycle Tests', () {
    late PullingManager<int> pullingManager;
    late StreamController<int> dataController;
    late List<int> fetchedData;

    setUp(() {
      dataController = StreamController<int>();
      fetchedData = [];

      pullingManager = PullingManager<int>(
        fetchData: () async {
          // Simulate fetching data
          final data = DateTime.now().millisecondsSinceEpoch;
          dataController.add(data);
          return data;
        },
        customDurations: [
          const Duration(seconds: 5), // low
          const Duration(seconds: 3), // medium
          const Duration(seconds: 1), // high
        ],
        attachToLifecycle: true, // Enable lifecycle management
      );

      pullingManager.dataStream.listen((data) => fetchedData.add(data));
    });

    tearDown(() {
      dataController.close();
      pullingManager.dispose();
    });

    test('Starts fetching data at low frequency', () async {
      pullingManager.setFrequency(PollingFrequency.low);

      await Future.delayed(const Duration(seconds: 6));

      expect(fetchedData.isNotEmpty, isTrue);
      expect(fetchedData.length, greaterThanOrEqualTo(1));
    });

    test('Switches to medium frequency and fetches more frequently', () async {
      pullingManager.setFrequency(PollingFrequency.medium);

      await Future.delayed(const Duration(seconds: 5));

      expect(fetchedData.isNotEmpty, isTrue);
      expect(fetchedData.length, greaterThan(1));
    });

    test('Switches to high frequency and fetches most frequently', () async {
      pullingManager.setFrequency(PollingFrequency.high);

      await Future.delayed(const Duration(seconds: 4));

      expect(fetchedData.isNotEmpty, isTrue);
      expect(fetchedData.length, greaterThan(3));
    });

    test('Pauses fetching data', () async {
      pullingManager.setFrequency(PollingFrequency.high);

      await Future.delayed(const Duration(seconds: 2));

      pullingManager.pause();

      final initialLength = fetchedData.length;

      await Future.delayed(const Duration(seconds: 2));

      expect(fetchedData.length, equals(initialLength));
    });

    test('Resumes fetching data', () async {
      pullingManager.setFrequency(PollingFrequency.high);

      await Future.delayed(const Duration(seconds: 2));

      pullingManager.pause();

      final initialLength = fetchedData.length;

      await Future.delayed(const Duration(seconds: 2));

      expect(fetchedData.length, equals(initialLength));

      pullingManager.resume();

      await Future.delayed(const Duration(seconds: 2));

      expect(fetchedData.length, greaterThan(initialLength));
    });
  });
}
