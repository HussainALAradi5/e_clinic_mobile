import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../config/reverb_config.dart';

/// One message from a private channel: its event name and JSON data.
typedef RealtimeEvent = ({String channel, String event, Map<String, dynamic> data});

/// The live connection to Reverb (Pusher protocol 7). Private channels are joined with the API token through
/// `POST broadcasting/auth` (the same Dio, so the auth header is added); pings are answered; a dropped socket
/// connects again after a few seconds and joins its channels again. Failures are quiet: screens still poll.
class RealtimeClient {
  RealtimeClient({required ReverbConfig config, required Dio dio}) : _config = config, _dio = dio;

  final ReverbConfig _config;
  final Dio _dio;
  final _events = StreamController<RealtimeEvent>.broadcast();
  final _channels = <String>{};
  WebSocketChannel? _socket;
  String? _socketId;
  Timer? _retry;
  var _closed = false;

  static const _retryAfter = Duration(seconds: 5);

  /// The data of each [event] on private [channel] (e.g. `staff.presence`, `presence.changed`).
  Stream<Map<String, dynamic>> listen(String channel, String event) {
    final name = 'private-$channel';
    if (_channels.add(name)) {
      _socketId == null ? _connect() : unawaited(_subscribe(name));
    }
    return _events.stream.where((e) => e.channel == name && e.event == event).map((e) => e.data);
  }

  void dispose() {
    _closed = true;
    _retry?.cancel();
    unawaited(_socket?.sink.close());
    unawaited(_events.close());
  }

  void _connect() {
    if (_socket != null || _closed) return;
    final uri = Uri(
      scheme: _config.scheme == 'https' ? 'wss' : 'ws',
      host: _config.host,
      port: _config.port,
      path: '/app/${_config.key}',
      queryParameters: const {'protocol': '7', 'client': 'dart', 'version': '1.0'},
    );
    final socket = WebSocketChannel.connect(uri);
    _socket = socket;
    socket.stream.listen(_onMessage, onDone: _dropped, onError: (Object _) => _dropped(), cancelOnError: true);
  }

  void _onMessage(dynamic raw) {
    if (raw is! String) return;
    final message = jsonDecode(raw) as Map<String, dynamic>;
    final event = message['event'] as String? ?? '';
    final body = message['data'];
    final data = body is String && body.isNotEmpty ? jsonDecode(body) : body;
    switch (event) {
      case 'pusher:connection_established':
        _socketId = (data as Map<String, dynamic>)['socket_id'] as String?;
        for (final channel in _channels) {
          unawaited(_subscribe(channel));
        }
      case 'pusher:ping':
        _send({'event': 'pusher:pong', 'data': <String, Object?>{}});
      default:
        final channel = message['channel'];
        if (channel is String && data is Map<String, dynamic>) {
          _events.add((channel: channel, event: event, data: data));
        }
    }
  }

  Future<void> _subscribe(String channel) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'broadcasting/auth',
        data: {'socket_id': _socketId, 'channel_name': channel},
      );
      final auth = response.data?['auth'];
      if (auth is String) _send({'event': 'pusher:subscribe', 'data': {'auth': auth, 'channel': channel}});
    } on DioException {
      // Not allowed or offline: the screens keep polling.
    }
  }

  void _send(Map<String, Object?> message) => _socket?.sink.add(jsonEncode(message));

  void _dropped() {
    _socket = null;
    _socketId = null;
    if (_closed || _channels.isEmpty) return;
    _retry?.cancel();
    _retry = Timer(_retryAfter, _connect);
  }
}
