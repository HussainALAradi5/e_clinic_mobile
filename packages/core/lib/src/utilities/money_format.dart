/// Exact money helpers for the 3-decimal clinic currency: amounts travel as strings (`"25.500"`), sums use fils.
abstract final class MoneyFormat {
  static const decimals = 3;
  static const currency = 'BHD';
  static final _pattern = RegExp(r'^(-?)(\d+)(?:\.(\d{1,3}))?$');

  /// `"25.5"` → 25500 fils; null when the text is not an amount.
  static int? toMinor(String? amount) {
    final match = _pattern.firstMatch((amount ?? '').trim().replaceAll(',', ''));
    if (match == null) return null;
    final minor = int.parse(match[2]!) * 1000 + int.parse((match[3] ?? '').padRight(decimals, '0'));
    return match[1] == '-' ? -minor : minor;
  }

  /// 25500 → `"25.500"`.
  static String fromMinor(int minor) {
    final abs = minor.abs();
    return '${minor < 0 ? '-' : ''}${abs ~/ 1000}.${(abs % 1000).toString().padLeft(decimals, '0')}';
  }

  /// `BHD 1,250.500`.
  static String format(String amount, [String currency = MoneyFormat.currency]) {
    final minor = toMinor(amount);
    if (minor == null) return '$currency $amount';
    final text = fromMinor(minor);
    final negative = text.startsWith('-');
    final [whole, fraction] = text.replaceFirst('-', '').split('.');
    final grouped = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$currency ${negative ? '-' : ''}$grouped.$fraction';
  }
}
