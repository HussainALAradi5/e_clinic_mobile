// Adds what the apps need to the Android / iOS folders made by `flutter create`:
// internet access, plain-HTTP to a local dev server (debug only), the fingerprint / face prompt, and the camera
// for the staff app's scanner.
// Usage (from the repository root): dart run tools/patch_platforms.dart apps/patient  (or apps/staff)
// Safe to run more than once.
import 'dart:io';

void main(List<String> args) {
  final app = args.isEmpty ? 'apps/patient' : args.first;
  _android(app);
  _ios(app);
  stdout.writeln('Platform folders of $app are ready.');
}

bool _isStaff(String app) => RegExp(r'(^|[\\/])staff[\\/]?$').hasMatch(app);

void _android(String app) {
  final main = File('$app/android/app/src/main/AndroidManifest.xml');
  if (!main.existsSync()) {
    stderr.writeln('No Android folder in $app — run flutter create first (see README).');
    exit(1);
  }
  var manifest = main.readAsStringSync();
  final permissions = [
    'android.permission.INTERNET',
    'android.permission.USE_BIOMETRIC',
    // The staff app scans codes with the camera.
    if (_isStaff(app)) 'android.permission.CAMERA',
  ];
  for (final permission in permissions) {
    if (!manifest.contains(permission)) {
      manifest = manifest.replaceFirst(
        RegExp(r'<application'),
        '<uses-permission android:name="$permission"/>\n    <application',
      );
    }
  }
  main.writeAsStringSync(manifest);

  // Debug builds may call http://10.0.2.2:8000 (php artisan serve on the host); release builds use HTTPS only.
  final debug = File('$app/android/app/src/debug/AndroidManifest.xml');
  if (debug.existsSync()) {
    var text = debug.readAsStringSync();
    if (!text.contains('usesCleartextTraffic')) {
      text = text.replaceFirst('</manifest>', '    <application android:usesCleartextTraffic="true"/>\n</manifest>');
      debug.writeAsStringSync(text);
    }
  }

  // local_auth needs a FragmentActivity.
  final activities = Directory('$app/android/app/src/main')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('MainActivity.kt') || f.path.endsWith('MainActivity.java'));
  for (final file in activities) {
    final text = file.readAsStringSync()
        .replaceAll('io.flutter.embedding.android.FlutterActivity', 'io.flutter.embedding.android.FlutterFragmentActivity')
        .replaceAll(RegExp(r'\bFlutterActivity\(\)'), 'FlutterFragmentActivity()')
        .replaceAll(RegExp(r'extends FlutterActivity\b'), 'extends FlutterFragmentActivity');
    file.writeAsStringSync(text);
  }
}

void _ios(String app) {
  final plist = File('$app/ios/Runner/Info.plist');
  if (!plist.existsSync()) return;
  var text = plist.readAsStringSync();
  final entries = {
    'NSFaceIDUsageDescription': '<string>Unlock e-Clinic with Face ID to keep your health information private.</string>',
    // Local development against php artisan serve over plain HTTP.
    'NSAppTransportSecurity': '<dict>\n\t\t<key>NSAllowsLocalNetworking</key>\n\t\t<true/>\n\t</dict>',
    if (_isStaff(app))
      'NSCameraUsageDescription': '<string>Scan patient cards, check-in codes and labels at the clinic.</string>',
  };
  for (final MapEntry(:key, :value) in entries.entries) {
    if (!text.contains('<key>$key</key>')) {
      text = text.replaceFirst(RegExp(r'</dict>\s*</plist>'), '\t<key>$key</key>\n\t$value\n</dict>\n</plist>');
    }
  }
  plist.writeAsStringSync(text);
}
