/// Reverb channels and events the app listens to (as in the server's `routes/channels.php` and its events).
abstract final class RealtimeChannels {
  /// Colleagues going Online / Offline (staff who use chat).
  static const staffPresence = 'staff.presence';
  static const presenceChanged = 'presence.changed';
}
