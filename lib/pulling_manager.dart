import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

enum PollingFrequency { veryLow, low, medium, high, veryHigh }

class PullingManager<T> with WidgetsBindingObserver {
  // Default durations for each frequency level
  static const _defaultDurations = [
    Duration(seconds: 10),
    Duration(seconds: 5),
    Duration(seconds: 3),
    Duration(seconds: 2),
    Duration(seconds: 1),
  ];

  // Dynamic durations based on user input
  final List<Duration> _durations;

  // Subjects
  final _pollingFrequencySubject = BehaviorSubject<PollingFrequency>();
  final _dataFetchSubject = PublishSubject<void>();
  final _pauseResumeSubject = BehaviorSubject<bool>.seeded(false);

  // Stream of fetched data
  late final Stream<T> dataStream;

  final Future<T> Function() _fetchData;

  final bool _immediateFirstFetch;
  final bool _attachToLifecycle;

  bool _firstFetchCompleted = false;
  bool _isPaused = false;

  PullingManager({
    required Future<T> Function() fetchData,
    List<Duration>? customDurations,
    PollingFrequency initialFrequency = PollingFrequency.medium,
    bool immediateFirstFetch = true,
    bool attachToLifecycle = true,
  })  : _fetchData = fetchData,
        _immediateFirstFetch = immediateFirstFetch,
        _attachToLifecycle = attachToLifecycle,
        _durations = _configureDurations(customDurations) {
    if (_attachToLifecycle) {
      WidgetsBinding.instance.addObserver(this);
    }

    final pollingStream = _pollingFrequencySubject.switchMap((frequency) {
      final effectiveFrequency =
          (_immediateFirstFetch && !_firstFetchCompleted) ? PollingFrequency.veryHigh : frequency;

      final duration = _getDurationForFrequency(effectiveFrequency);

      return Stream<void>.periodic(duration, (_) {});
    });

    final combinedStream = Rx.merge([
      pollingStream,
      _dataFetchSubject,
      _pauseResumeSubject.where((isPaused) => !isPaused),
    ]);

    // Stream that fetches data when triggered
    dataStream = combinedStream
        .exhaustMap(
      (_) => _isPaused ? Stream<T>.empty() : Stream.fromFuture(_fetchData()),
    )
        .doOnData((_) {
      if (_immediateFirstFetch && !_firstFetchCompleted) {
        _firstFetchCompleted = true;
        _pollingFrequencySubject.add(_pollingFrequencySubject.value);
      }
    }).share();

    _pollingFrequencySubject.add(initialFrequency);

    if (_immediateFirstFetch) {
      _dataFetchSubject.add(null);
    }
  }

  static List<Duration> _configureDurations(List<Duration>? customDurations) {
    if (customDurations == null || customDurations.isEmpty) {
      return _defaultDurations;
    }

    final maxDurations = _defaultDurations.length;
    return List<Duration>.generate(
      maxDurations,
      (index) => customDurations.length > index ? customDurations[index] : _defaultDurations[index],
    );
  }

  Duration _getDurationForFrequency(PollingFrequency frequency) {
    return _durations[frequency.index];
  }

  void setFrequency(PollingFrequency frequency) {
    _pollingFrequencySubject.add(frequency);
  }

  void triggerManualFetch() {
    if (!_isPaused) _dataFetchSubject.add(null);
  }

  void pause() {
    _isPaused = true;
    _pauseResumeSubject.add(_isPaused);
  }

  void resume() {
    _isPaused = false;
    _pauseResumeSubject.add(_isPaused);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_attachToLifecycle) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      pause();
    } else if (state == AppLifecycleState.resumed) {
      resume();
    }
  }

  void dispose() {
    if (_attachToLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _pollingFrequencySubject.close();
    _dataFetchSubject.close();
    _pauseResumeSubject.close();
  }
}
