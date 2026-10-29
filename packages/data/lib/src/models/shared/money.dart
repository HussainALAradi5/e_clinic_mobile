import 'package:e_clinic_core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';
part 'money.g.dart';

/// `{ amount: "25.500", currency: "BHD" }` — amounts are strings, never doubles.
@freezed
abstract class Money with _$Money {
  const factory Money({required String amount, @Default('BHD') String currency}) = _Money;

  const Money._();

  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);

  /// Exact value in fils.
  int get minor => MoneyFormat.toMinor(amount) ?? 0;

  bool get isPositive => minor > 0;

  /// `BHD 25.500`.
  String get label => MoneyFormat.format(amount, currency);

  /// Sum of several amounts in the clinic currency.
  static Money sum(Iterable<Money> values) =>
      Money(amount: MoneyFormat.fromMinor(values.fold(0, (total, m) => total + m.minor)));
}
