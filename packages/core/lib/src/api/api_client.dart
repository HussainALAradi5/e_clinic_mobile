import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'api_exception.dart';
import 'error_codes.dart';
import 'list_query.dart';
import 'page.dart';

/// Turns the `data` of the success envelope into a model.
typedef Decoder<T> = T Function(Object? data);

/// A decoder for an object `data` (`fromJson` of a model).
Decoder<T> objectOf<T>(T Function(Map<String, dynamic> json) fromJson) =>
    (data) => fromJson(data! as Map<String, dynamic>);

/// A decoder for an array `data`.
Decoder<List<T>> listOf<T>(T Function(Map<String, dynamic> json) fromJson) =>
    (data) => [for (final item in data! as List<dynamic>) fromJson(item as Map<String, dynamic>)];

/// Thin Dio wrapper: unwraps `{ success, message, data, meta }`, maps failures to [ApiException].
/// Repositories call it with one method per endpoint; screens never see Dio.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;
  static const _uuid = Uuid();

  /// A fresh `Idempotency-Key` for money and booking calls; keep it for retries of the same attempt.
  static String newIdempotencyKey() => _uuid.v4();

  /// The API origin without a trailing slash, for links built by hand (`$baseUrl/codes/...`).
  String get baseUrl => _dio.options.baseUrl.replaceFirst(RegExp(r'/+$'), '');

  Future<T> get<T>(String path, Decoder<T> decode, {Map<String, Object?>? query}) async =>
      decode(await _data('GET', path, query: query));

  Future<Paged<T>> list<T>(
    String path,
    ListQuery query,
    T Function(Map<String, dynamic> json) fromJson, {
    Map<String, Object?> extra = const {},
  }) async {
    final body = await _send('GET', path, query: {...query.toParams(), ...extra});
    final rows = body['data'] as List<dynamic>? ?? const [];
    return Paged(
      items: [for (final row in rows) fromJson(row as Map<String, dynamic>)],
      meta: PageMeta.fromJson(body['meta'] as Map<String, dynamic>?, query.perPage ?? rows.length),
    );
  }

  Future<T> post<T>(String path, Decoder<T> decode, {Object? body, String? idempotencyKey}) async =>
      decode(await _data('POST', path, body: body, idempotencyKey: idempotencyKey));

  Future<T> put<T>(String path, Decoder<T> decode, {Object? body}) async =>
      decode(await _data('PUT', path, body: body));

  Future<T> patch<T>(String path, Decoder<T> decode, {Object? body}) async =>
      decode(await _data('PATCH', path, body: body));

  Future<void> delete(String path, {Object? body}) => _send('DELETE', path, body: body);

  /// For calls whose answer is not needed.
  static void ignore(Object? _) {}

  Future<Object?> _data(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    String? idempotencyKey,
  }) async =>
      (await _send(method, path, query: query, body: body, idempotencyKey: idempotencyKey))['data'];

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query == null ? null : {
          for (final entry in query.entries)
            if (entry.value != null) entry.key: entry.value,
        },
        options: Options(
          method: method,
          headers: {'Idempotency-Key': ?idempotencyKey},
        ),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data == null || data == '') return const {};
      throw const ApiException(
        status: 0,
        code: ErrorCodes.unexpected,
        message: 'The clinic server sent an answer the app could not read.',
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
