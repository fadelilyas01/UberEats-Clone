import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// Location State
class CourierLocation {
  final double lat;
  final double lng;
  final double heading;
  final DateTime timestamp;

  CourierLocation({
    required this.lat,
    required this.lng,
    this.heading = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'heading': heading,
    'timestamp': timestamp.toIso8601String(),
  };
}

// Location Service Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Current Location Provider (Stream)
final currentLocationProvider = StreamProvider<CourierLocation>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.locationStream;
});

class LocationService {
  StreamController<CourierLocation>? _controller;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _uploadTimer;

  // Buffer for batching uploads
  final List<CourierLocation> _locationBuffer = [];
  
  Stream<CourierLocation> get locationStream {
    _controller ??= StreamController<CourierLocation>.broadcast(
      onListen: _startTracking,
      onCancel: _stopTracking,
    );
    return _controller!.stream;
  }

  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  void _startTracking() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      debugPrint('⚠️ Location permissions not granted');
      return;
    }

    debugPrint('📍 Starting location tracking...');

    // High accuracy for delivery tracking
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final location = CourierLocation(
        lat: position.latitude,
        lng: position.longitude,
        heading: position.heading,
      );

      _controller?.add(location);
      _locationBuffer.add(location);

      debugPrint('📍 New position: ${position.latitude}, ${position.longitude}');
    });

    // Upload to server every 30 seconds
    _uploadTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _uploadLocations();
    });
  }

  void _stopTracking() {
    debugPrint('🛑 Stopping location tracking');
    _positionSubscription?.cancel();
    _uploadTimer?.cancel();
    _locationBuffer.clear();
  }

  Future<void> _uploadLocations() async {
    if (_locationBuffer.isEmpty) return;

    final batch = List<CourierLocation>.from(_locationBuffer);
    _locationBuffer.clear();

    debugPrint('⬆️ Uploading ${batch.length} location points...');

    // TODO: Real Firebase/API upload
    // await FirebaseFirestore.instance
    //     .collection('courier_locations')
    //     .doc(courierId)
    //     .update({
    //       'current_location': batch.last.toJson(),
    //       'location_history': FieldValue.arrayUnion(batch.map((l) => l.toJson()).toList()),
    //     });
  }

  /// Simulates movement for testing without real GPS
  void startSimulation() {
    _controller ??= StreamController<CourierLocation>.broadcast();
    
    double lat = 48.8566;
    double lng = 2.3522;
    final random = Random();

    Timer.periodic(const Duration(seconds: 2), (timer) {
      // Random walk simulation
      lat += (random.nextDouble() - 0.5) * 0.001;
      lng += (random.nextDouble() - 0.5) * 0.001;

      _controller?.add(CourierLocation(lat: lat, lng: lng, heading: random.nextDouble() * 360));
    });
  }

  void dispose() {
    _stopTracking();
    _controller?.close();
  }
}
