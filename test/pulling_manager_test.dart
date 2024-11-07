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
        lowFrequencyDuration: const Duration(seconds: 3),
        mediumFrequencyDuration: const Duration(seconds: 2),
        highFrequencyDuration: const Duration(seconds: 1),
        attachToLifecycle: true, // Enable lifecycle management
      );

      pullingManager.dataStream.listen((data) => fetchedData.add(data));
    });

    tearDown(() {
      dataController.close();
    });

    test('Starts fetching data at low frequency', () async {
      pullingManager.setFrequency(PollingFrequency.low);

      await Future.delayed(const Duration(seconds: 4));

      expect(fetchedData.isNotEmpty, isTrue);
      expect(fetchedData.length, greaterThanOrEqualTo(1));
    });

    test('Switches to medium frequency and fetches more frequently', () async {
      pullingManager.setFrequency(PollingFrequency.medium);

      await Future.delayed(const Duration(seconds: 5));

      expect(fetchedData.isNotEmpty, isTrue);
      expect(fetchedData.length, greaterThan(2));
    });

    test('Switches to high frequency and fetches most frequently', () async {
      pullingManager.setFrequency(PollingFrequency.high);

      await Future.delayed(const Duration(seconds: 3));

      expect(fetchedData.isNotEmpty, isTrue);
      expect(fetchedData.length, greaterThan(2));
    });

    test('Resumes fetching after restarting', () async {
      pullingManager.setFrequency(PollingFrequency.low);

      await Future.delayed(const Duration(seconds: 2));
      int initialDataCount = fetchedData.length;

      await Future.delayed(const Duration(seconds: 1));
      pullingManager = PullingManager<int>(
        fetchData: () async {
          final data = DateTime.now().millisecondsSinceEpoch;
          dataController.add(data);
          return data;
        },
        lowFrequencyDuration: const Duration(seconds: 3),
        mediumFrequencyDuration: const Duration(seconds: 2),
        highFrequencyDuration: const Duration(seconds: 1),
        attachToLifecycle: true,
      );

      pullingManager.dataStream.listen((data) => fetchedData.add(data));

      await Future.delayed(const Duration(seconds: 3));
      expect(fetchedData.length, greaterThan(initialDataCount));
    });
  });
}
