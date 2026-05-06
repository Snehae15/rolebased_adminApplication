import 'dart:io';

const _targetBaseUrl = 'https://critter-liver-bodacious.ngrok-free.dev';
const _port = 8787;

final _targetBase = Uri.parse(_targetBaseUrl);

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, _port);
  stdout.writeln('Proxy listening on http://localhost:$_port');
  stdout.writeln('Forwarding to $_targetBaseUrl');

  await for (final request in server) {
    await _handle(request);
  }
}

Future<void> _handle(HttpRequest request) async {
  _addCorsHeaders(request.response);

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  final client = HttpClient();
  try {
    final targetUri = _targetBase.replace(
      path: request.uri.path,
      query: request.uri.query.isEmpty ? null : request.uri.query,
    );
    final upstream = await client.openUrl(request.method, targetUri);

    request.headers.forEach((name, values) {
      if (_isHopByHopHeader(name)) return;
      for (final value in values) {
        upstream.headers.add(name, value);
      }
    });
    upstream.headers.set('host', _targetBase.host);
    upstream.headers.set('ngrok-skip-browser-warning', 'true');

    await upstream.addStream(request);
    final upstreamResponse = await upstream.close();

    request.response.statusCode = upstreamResponse.statusCode;
    upstreamResponse.headers.forEach((name, values) {
      if (_isHopByHopHeader(name)) return;
      for (final value in values) {
        request.response.headers.add(name, value);
      }
    });
    _addCorsHeaders(request.response);
    await request.response.addStream(upstreamResponse);
  } catch (error) {
    request.response.statusCode = HttpStatus.badGateway;
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      '{"success":false,"message":"Proxy request failed","details":"$error"}',
    );
  } finally {
    client.close(force: true);
    await request.response.close();
  }
}

void _addCorsHeaders(HttpResponse response) {
  response.headers
    ..set('access-control-allow-origin', '*')
    ..set('access-control-allow-methods', 'GET, POST, PUT, DELETE, OPTIONS')
    ..set(
      'access-control-allow-headers',
      'Content-Type, Authorization, ngrok-skip-browser-warning',
    );
}

bool _isHopByHopHeader(String name) {
  final lower = name.toLowerCase();
  return lower == 'host' ||
      lower == 'connection' ||
      lower == 'content-length' ||
      lower == 'transfer-encoding' ||
      lower == 'keep-alive' ||
      lower == 'proxy-authenticate' ||
      lower == 'proxy-authorization' ||
      lower == 'te' ||
      lower == 'trailer' ||
      lower == 'upgrade';
}
