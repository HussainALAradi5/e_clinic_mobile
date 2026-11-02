part of 'interceptors.dart';

/// Retries reads (and keyed writes, which the server de-duplicates) after network failures: 3 tries, 0.5 s → 2 s.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;
  static const _maxRetries = 3;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra['retry'] as int?) ?? 0;
    final safe = options.method == 'GET' || options.headers.containsKey('Idempotency-Key');
    final network =
        err.response == null &&
        (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout);
    if (!safe || !network || attempt >= _maxRetries) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(Duration(milliseconds: 500 * (1 << attempt)));
    options.extra['retry'] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
