import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_provider.freezed.dart';
part 'booking_provider.g.dart';

/// Someone who can be booked for a kind of visit (GET /appointments/providers).
@freezed
abstract class BookingProvider with _$BookingProvider {
  const factory BookingProvider({
    required String id,
    required String fullName,
    String? jobTitle,
    String? department,
    @Default(false) bool isDoctor,
  }) = _BookingProvider;

  factory BookingProvider.fromJson(Map<String, dynamic> json) => _$BookingProviderFromJson(json);
}
