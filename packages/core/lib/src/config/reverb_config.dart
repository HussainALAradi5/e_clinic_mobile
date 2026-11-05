/// Where the app reaches the Reverb websocket server (live updates), passed at build time:
/// `--dart-define=REVERB_KEY=… --dart-define=REVERB_HOST=… --dart-define=REVERB_PORT=8085 --dart-define=REVERB_SCHEME=http`.
/// The app key is public; the secret stays on the server.
class ReverbConfig {
  const ReverbConfig({required this.key, required this.host, required this.port, this.scheme = 'https'});

  final String key;
  final String host;
  final int port;

  /// `http` or `https` (the socket then uses `ws` or `wss`).
  final String scheme;

  /// Null while no key or host is given: the app keeps polling instead.
  static ReverbConfig? fromValues({required String key, required String host, required String port, required String scheme}) =>
      key.isEmpty || host.isEmpty
      ? null
      : ReverbConfig(key: key, host: host, port: int.tryParse(port) ?? 443, scheme: scheme.isEmpty ? 'https' : scheme);
}
