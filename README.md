![pub package](https://img.shields.io/badge/version-0.1.5-blue)

A flexible and battery-efficient solution for handling real-time data updates in Flutter applications.

### Features

- Customizable Polling Frequencies
- Battery-efficient with automatic lifecycle management
- Smart request handling to prevent overlapping
- Context-aware frequency adjustments
- Simple, flexible API

### Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  pulling_manager: ^0.1.5
```
 

### Why PullingManager?

PullingManager was built to solve real-world needs in production apps. It provides:

- Dynamic Control: Change polling frequency based on app state or user context
- Resource Efficiency: Automatically handles lifecycle events to conserve battery
- Clean API: Simple to implement and maintain
- Built on RxDart: Leverages powerful reactive programming concepts

# Customizable Polling Frequencies

## Explanation

Customizable polling frequencies allow you to define how often specific tasks (like data refreshes or updates) occur by providing a list of predefined time intervals. This method ensures flexibility and efficiency, as different parts of an application can operate with varying refresh rates based on their needs.

### Key Concepts:

1. **Pass a List of Frequencies**: Provide a list of intervals (in seconds, milliseconds, etc.) to specify how often a task should execute.
2. **Context-Specific Updates**: Tie each frequency to a particular application state, page, or condition for dynamic control.

---

## Example Usage

Here is an example of how to use the `PullingManager` class in a Dart application:

```dart
void main() {
  // Create an instance of PullingManager
  final pullingManager = PullingManager<String>(
    fetchData: () async {
      // Simulate a network call or data fetch
      print("Fetching data...");
      await Future.delayed(Duration(seconds: 1));
      return "Data fetched successfully";
    },
    customDurations: [
      Duration(seconds: 15),  
      Duration(seconds: 10),  
      Duration(seconds: 5),   
      Duration(seconds: 2),   
      Duration(seconds: 1),  
    ],
    initialFrequency: PollingFrequency.medium,
    immediateFirstFetch: true,
    attachToLifecycle: true,
  );

  // Listen to the data stream
  pullingManager.dataStream.listen((data) {
    print("Received: $data");
  });

  // Change polling frequency
  pullingManager.setFrequency(PollingFrequency.high);

  // Trigger a manual fetch
  pullingManager.triggerManualFetch();

  // Pause and resume polling based on user interaction or app state
  pullingManager.pause();
  Future.delayed(Duration(seconds: 5), () {
    pullingManager.resume();
  });

  // Dispose the manager when no longer needed
  Future.delayed(Duration(seconds: 30), () {
    pullingManager.dispose();
  });
}
```

### Explanation:

- **`fetchData`**: A function that performs the actual data fetching.
- **`customDurations`**: Override the default durations for polling frequencies.
- **`setFrequency`**: Adjust the polling frequency dynamically.
- **`pause`/`resume`**: Temporarily halt and restart polling.
- **`dispose`**: Clean up resources when polling is no longer required.

---

## Benefits

- **Efficiency**: Reduces unnecessary system resource usage by avoiding constant updates.
- **Flexibility**: Allows different components of the app to operate independently with appropriate refresh rates.
- **Scalability**: Easy to modify or expand polling frequencies as the application evolves.

---

## Use Cases

1. **Real-Time Dashboards**: Frequently update critical components (e.g., every second) while less critical ones refresh periodically.
2. **IoT Applications**: Poll sensors at different rates depending on their importance or activity.
3. **Data-Heavy Applications**: Optimize network calls by adjusting frequencies dynamically based on user interaction.

---

## Implementation Tips

- Use a **Polling Manager** to centralize and manage polling logic.
- Store frequencies in a configuration file for easy updates.
- Dynamically adjust polling rates based on user activity or system performance.

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
