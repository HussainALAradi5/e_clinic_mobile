import 'package:e_clinic_core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds the Reverb address only when a key and host are given, defaulting to a secure socket', () {
    expect(ReverbConfig.fromValues(key: '', host: 'h', port: '', scheme: ''), isNull);
    expect(ReverbConfig.fromValues(key: 'k', host: '', port: '', scheme: ''), isNull);

    final local = ReverbConfig.fromValues(key: 'k', host: '127.0.0.1', port: '8085', scheme: 'http')!;
    expect((local.key, local.host, local.port, local.scheme), ('k', '127.0.0.1', 8085, 'http'));

    final live = ReverbConfig.fromValues(key: 'k', host: 'ws.clinic.bh', port: '', scheme: '')!;
    expect((live.port, live.scheme), (443, 'https'));
  });
}
