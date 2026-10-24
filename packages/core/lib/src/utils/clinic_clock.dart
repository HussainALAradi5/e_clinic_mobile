/// Clinic wall clock (Asia/Bahrain, UTC+3, no daylight saving) — dates and times on the server are clinic-local.
abstract final class ClinicClock {
  static const offset = Duration(hours: 3);

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /// Now on the clinic wall clock (a UTC DateTime whose fields read as clinic time).
  static DateTime now() => DateTime.now().toUtc().add(offset);

  /// Today in the clinic as `YYYY-MM-DD`.
  static String today() => isoDate(now());

  /// `HH:mm` of the clinic wall clock.
  static String time() {
    final n = now();
    return '${_two(n.hour)}:${_two(n.minute)}';
  }

  static String isoDate(DateTime day) => '${day.year}-${_two(day.month)}-${_two(day.day)}';

  /// The date `days` after an ISO date.
  static String addDays(String iso, int days) => isoDate(parse(iso).add(Duration(days: days)));

  /// An ISO date as a UTC midnight DateTime.
  static DateTime parse(String iso) {
    final p = iso.substring(0, 10).split('-').map(int.parse).toList();
    return DateTime.utc(p[0], p[1], p[2]);
  }

  /// An instant as clinic wall-clock time.
  static DateTime local(DateTime instant) => instant.toUtc().add(offset);

  /// `Sun 25 Oct 2026`.
  static String day(String iso) {
    final d = parse(iso);
    return '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  /// `25 Oct 2026`.
  static String date(String iso) {
    final d = parse(iso);
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  /// `25 Oct 2026, 14:05` for an instant.
  static String dateTime(DateTime instant) {
    final l = local(instant);
    return '${date(isoDate(l))}, ${_two(l.hour)}:${_two(l.minute)}';
  }

  /// `Sun` / `25` / `Oct` pieces for date strips.
  static ({String weekday, int day, String month}) parts(String iso) {
    final d = parse(iso);
    return (weekday: _weekdays[d.weekday - 1], day: d.day, month: _months[d.month - 1]);
  }

  /// `Today`, `Tomorrow` or the day name with date.
  static String relativeDay(String iso) {
    final today = ClinicClock.today();
    if (iso == today) return 'Today';
    if (iso == addDays(today, 1)) return 'Tomorrow';
    return day(iso);
  }

  /// `5 min ago`, `3 h ago`, `2 days ago`, then the date.
  static String ago(DateTime instant) {
    final diff = DateTime.now().toUtc().difference(instant.toUtc());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return diff.inDays == 1 ? 'Yesterday' : '${diff.inDays} days ago';
    return date(isoDate(local(instant)));
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
