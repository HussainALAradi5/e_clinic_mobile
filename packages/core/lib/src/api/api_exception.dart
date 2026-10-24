import 'package:dio/dio.dart';

import 'error_codes.dart';

/// The server error envelope `{ success: false, message, error_code, errors, meta, request_id }`, or a network failure.
class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.code,
    required this.message,
    this.fieldErrors = const {},
    this.meta = const {},
    this.requestId,
  });

  /// Maps any Dio failure to an [ApiException] (network problems become [ErrorCodes.offline]).
  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    if (response == null) {
      final offline = switch (error.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => true,
        _ => false,
      };
      return ApiException(
        status: 0,
        code: offline ? ErrorCodes.offline : ErrorCodes.unexpected,
        message: offline
            ? 'You seem to be offline. Check your connection and try again.'
            : 'Something went wrong. Please try again.',
      );
    }

    final status = response.statusCode ?? 0;
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : const <String, dynamic>{};
    final rawErrors = json['errors'];
    final rawMeta = json['meta'];
    return ApiException(
      status: status,
      code: json['error_code'] as String? ?? _codeFor(status),
      message: _message(json['message'] as String?, status, response.headers),
      fieldErrors: rawErrors is Map<String, dynamic>
          ? {
              for (final entry in rawErrors.entries)
                entry.key: [
                  for (final m in entry.value as List<dynamic>) m.toString(),
                ],
            }
          : const {},
      meta: rawMeta is Map<String, dynamic> ? rawMeta : const {},
      requestId: json['request_id'] as String? ?? response.headers.value('X-Request-Id'),
    );
  }

  final int status;
  final String code;
  final String message;

  /// 422 validation messages per snake_case field.
  final Map<String, List<String>> fieldErrors;
  final Map<String, dynamic> meta;

  /// Shown in error messages so support can find the request in the logs.
  final String? requestId;

  bool get isOffline => code == ErrorCodes.offline;

  /// First validation message of a field (snake_case key as sent by the server).
  String? fieldError(String field) {
    final messages = fieldErrors[field];
    return messages == null || messages.isEmpty ? null : messages.first;
  }

  static String _codeFor(int status) => switch (status) {
    401 => ErrorCodes.unauthenticated,
    403 => ErrorCodes.forbidden,
    404 => ErrorCodes.notFound,
    409 => ErrorCodes.concurrentModification,
    422 => ErrorCodes.validationFailed,
    423 => ErrorCodes.accountLocked,
    429 => ErrorCodes.tooManyRequests,
    _ => ErrorCodes.unexpected,
  };

  static String _message(String? message, int status, Headers headers) {
    if (status == 429) {
      final wait = int.tryParse(headers.value('Retry-After') ?? '');
      return wait == null
          ? 'Too many attempts. Please wait a moment and try again.'
          : 'Too many attempts. Try again in $wait seconds.';
    }
    if (message != null && message.isNotEmpty) return message;
    return status >= 500
        ? 'The clinic server had a problem. Please try again shortly.'
        : 'Something went wrong. Please try again.';
  }

  @override
  String toString() => 'ApiException($status $code: $message)';
}
