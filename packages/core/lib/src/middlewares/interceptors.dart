import 'dart:async';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../services/auth/token_store.dart';

part 'interceptors_auth_interceptor.dart';
part 'interceptors_retry_interceptor.dart';

const _uuid = Uuid();

/// `X-Request-Id` on every call, so an error message can be matched to the server log.
class RequestIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('X-Request-Id', () => _uuid.v4());
    handler.next(options);
  }
}
