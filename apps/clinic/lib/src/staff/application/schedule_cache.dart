import 'dart:convert';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The last loaded schedule of today, for reading without a connection. Kept in the Keychain / Android Keystore
/// (encrypted), one copy per signed-in user, only for the day it was loaded, and wiped on sign-out.
class ScheduleCache {
  ScheduleCache([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _prefix = 'ec.schedule.';

  static String _key(String userId, {required bool mine}) => '$_prefix$userId.${mine ? 'mine' : 'all'}';

  Future<void> save(String userId, {required bool mine, required List<Appointment> visits}) => _storage.write(
    key: _key(userId, mine: mine),
    value: jsonEncode({
      'date': ClinicClock.today(),
      'saved_at': DateTime.now().toUtc().toIso8601String(),
      'visits': [for (final v in visits) v.toJson()],
    }),
  );

  /// Today's copy and when it was saved; null when there is none or it is from another day.
  Future<({List<Appointment> visits, DateTime savedAt})?> read(String userId, {required bool mine}) async {
    try {
      final raw = await _storage.read(key: _key(userId, mine: mine));
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['date'] != ClinicClock.today()) return null;
      return (
        visits: [for (final v in json['visits'] as List<dynamic>) Appointment.fromJson(v as Map<String, dynamic>)],
        savedAt: DateTime.parse(json['saved_at'] as String),
      );
    } on Object {
      return null;
    }
  }

  /// Removes every saved schedule (sign-out).
  Future<void> clear() async {
    final all = await _storage.readAll();
    for (final key in all.keys.where((k) => k.startsWith(_prefix))) {
      await _storage.delete(key: key);
    }
  }
}

final scheduleCacheProvider = Provider<ScheduleCache>((ref) => ScheduleCache());
