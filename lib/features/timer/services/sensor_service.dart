import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final StreamController<bool> _faceDownController = StreamController<bool>.broadcast();

  Stream<bool> get isFaceDown => _faceDownController.stream;

  void startListening() {
    _subscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      // Z-axis is approx -9.8 when screen is facing down.
      bool isFaceDown = event.z < -8.0;
      _faceDownController.add(isFaceDown);
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopListening();
    _faceDownController.close();
  }
}
