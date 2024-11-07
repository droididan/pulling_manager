import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

enum PollingFrequency { low, medium, high }

/// [PullingManager] is a class that manages the frequency of data fetching.
/// [T] is the type of data fetched.
/// The manager can be paused and resumed.
/// It can also be attached to the app lifecycle to pause and resume fetching
/// when the app goes to background and returns to foreground.
/// The manager can be used to fetch data at different frequencies.
/// The manager can also be used to trigger manual data fetches.
/// The manager can be used to fetch data immediately after initialization.
class PullingManager<T> with WidgetsBindingObserver {
  // Duration for each frequency level
  final Duration lowFrequencyDuration;
  final Duration mediumFrequencyDuration;
  final Duration highFrequencyDuration;

  // Subjects
  final _pollingFrequencySubject = BehaviorSubject<PollingFrequency>();
  final _dataFetchSubject = PublishSubject<void>();
  final _pauseResumeSubject = BehaviorSubject<bool>.seeded(false);

  // Stream of fetched data
  late final Stream<T> dataStream;

  late final StreamSubscription<T> _dataSubscription;

  final Future<T> Function() _fetchData;

  final bool _immediateFirstFetch;
  final bool _attachToLifecycle;

  bool _firstFetchCompleted = false;
  bool _isPaused = false;

  PullingManager({
    required Future<T> Function() fetchData,
    required this.lowFrequencyDuration,
    required this.mediumFrequencyDuration,
    required this.highFrequencyDuration,
    PollingFrequency initialFrequency = PollingFrequency.low,
    bool immediateFirstFetch = true,
    bool attachToLifecycle = true,
  })  : _fetchData = fetchData,
        _immediateFirstFetch = immediateFirstFetch,
        _attachToLifecycle = attachToLifecycle {
    if (_attachToLifecycle) {
      WidgetsBinding.instance.addObserver(this);
    }

    final pollingStream = _pollingFrequencySubject.switchMap((frequency) {
      final effectiveFrequency = (_immediateFirstFetch && !_firstFetchCompleted)
          ? PollingFrequency.high
          : frequency;

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

  Duration _getDurationForFrequency(PollingFrequency frequency) {
    switch (frequency) {
      case PollingFrequency.low:
        return lowFrequencyDuration;
      case PollingFrequency.medium:
        return mediumFrequencyDuration;
      case PollingFrequency.high:
        return highFrequencyDuration;
    }
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

  /// Lifecycle management: pause polling when app goes to background,
  /// resume polling when app returns to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_attachToLifecycle) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
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
    _dataSubscription.cancel();
  }
}
