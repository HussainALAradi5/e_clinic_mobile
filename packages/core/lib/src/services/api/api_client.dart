import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../constants/api_error_text.dart';
import '../../constants/error_codes.dart';
import '../../dtos/common/list_query.dart';
import '../../dtos/common/page.dart';
import 'api_exception.dart';

/// Turns the `data` of the success envelope into a model.
typedef Decoder<T> = T Function(Object? data);

/// A file on the phone to upload: its path and the name the server keeps.
typedef UploadFile = ({String path, String name});

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

  /// Sends files as `multipart/form-data` (`files[]`) with plain [fields]; the server checks type and size.
  Future<T> upload<T>(
    String path,
    Decoder<T> decode, {
    required List<UploadFile> files,
    Map<String, Object> fields = const {},
  }) async {
    final form = FormData.fromMap({
      ...fields,
      'files[]': [for (final file in files) await MultipartFile.fromFile(file.path, filename: file.name)],
    });
    return decode(await _data('POST', path, body: form));
  }

  /// Sends one in-memory file (e.g. a drawn signature) as `multipart/form-data` under [field].
  Future<T> uploadBytes<T>(
    String path,
    Decoder<T> decode, {
    required String field,
    required List<int> bytes,
    required String fileName,
  }) async {
    final form = FormData.fromMap({field: MultipartFile.fromBytes(bytes, filename: fileName)});
    return decode(await _data('POST', path, body: form));
  }

  /// A file the server returns as is (an image), or null when there is none (404).
  Future<Uint8List?> bytes(String path) async {
    try {
      final response = await _dio.get<List<int>>(path, options: Options(responseType: ResponseType.bytes));
      final data = response.data;
      return data == null ? null : Uint8List.fromList(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      throw ApiException.fromDio(error);
    }
  }

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
  }) async => (await _send(method, path, query: query, body: body, idempotencyKey: idempotencyKey))['data'];

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
        queryParameters: query == null
            ? null
            : {
                for (final entry in query.entries)
                  if (entry.value != null) entry.key: entry.value,
              },
        options: Options(method: method, headers: {'Idempotency-Key': ?idempotencyKey}),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data == null || data == '') return const {};
      throw const ApiException(
        status: 0,
        code: ErrorCodes.unexpected,
        message: ApiErrorText.unreadable,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
