![pub package](https://img.shields.io/badge/version-0.1.3-blue)

  
A flexible and battery-efficient solution for handling real-time data updates in Flutter applications.

### Features

- Customizable polling frequencies (low, medium, high)
- Battery-efficient with automatic lifecycle management
- Smart request handling to prevent overlapping
- Context-aware frequency adjustments
- Simple, flexible API

### Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  pulling_manager: ^0.1.3
```

### Usage

Basic implementation:

```dart

  final pullManager = PullingManager(
    fetchData: () => repository.getData(),
    initialFrequency: PollingFrequency.low,
    immediateFirstFetch: true,
    attachToLifecycle: true,
    lowFrequencyDuration: const Duration(seconds: 10), 
    mediumFrequencyDuration: const Duration(seconds: 5),
    highFrequencyDuration: const Duration(seconds: 2),
  );

  // Listen to screen changes and adjust frequency
  screenStateSubject
    .listen(
      (screen) => pullManager.setFrequency(
        screen.when(
          dashboard: () => PollingFrequency.low,    
          details: () => PollingFrequency.high,     
          settings: () => PollingFrequency.medium,  
        ),
      ),
    );


  // Process data updates
  pullManager.dataStream
    .listen((result) {
        // do something with the result
    });

```

### Why PullingManager?

PullingManager was built to solve real-world needs in production apps. It provides:

- Dynamic Control: Change polling frequency based on app state or user context
- Resource Efficiency: Automatically handles lifecycle events to conserve battery
- Clean API: Simple to implement and maintain
- Built on RxDart: Leverages powerful reactive programming concepts

### Configuration

PullingManager can be customized with:

```dart
PullingManager(
  attachToLifecycle: true,              // Attach to lifecycle to pause in background, resume in foreground.
  fetchData: () => Future<T>,           // Your data fetch function
  initialFrequency: PollingFrequency,   // Starting frequency
  immediateFirstFetch: bool,            // Fetch immediately on start
  lowFrequencyDuration: Duration,       // Interval for low frequency
  mediumFrequencyDuration: Duration,    // Interval for medium frequency
  highFrequencyDuration: Duration,      // Interval for high frequency
)
```

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

```
MIT License

Copyright (c) 2024 Idan Ayalon

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
