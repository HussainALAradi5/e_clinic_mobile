part of 'interceptors.dart';

/// Adds the bearer token; a 401 on a call that carried one means the session ended elsewhere.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokens, required this.onExpired});

  final TokenStore tokens;
  final void Function() onExpired;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokens.current;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final sentToken = err.requestOptions.headers.containsKey('Authorization');
    if (err.response?.statusCode == 401 && sentToken) onExpired();
    handler.next(err);
  }
}
