import 'package:e_clinic_data/data.dart';
import 'package:geolocator/geolocator.dart';

/// The phone's position for clocking in or out, asking for location once. Null when location is off, refused or
/// too slow — the server then relies on the clinic network alone (it decides either way).
Future<ClockPosition?> clockPosition() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
    );
    return (latitude: p.latitude, longitude: p.longitude, accuracy: p.accuracy);
  } on Exception {
    return null;
  }
}
