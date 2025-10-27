import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class SyncHost {
  HttpServer? _server;
  Future<void> start({int port = 8080}) async {
    final app = Router();
    app.get('/handshake', (Request req) {
      final resp = {
        'ok': true,
        'dbVersion': 1,
        'serverTime': DateTime.now().toIso8601String(),
      };
      return Response.ok(
        jsonEncode(resp),
        headers: {'content-type': 'application/json'},
      );
    });
    app.post('/push', (Request req) async {
      final body = await req.readAsString();
      return Response.ok(
        jsonEncode({'ok': true, 'receivedBytes': body.length}),
        headers: {'content-type': 'application/json'},
      );
    });
    app.get('/pull', (Request req) {
      return Response.ok(
        jsonEncode({'ok': true, 'changes': []}),
        headers: {'content-type': 'application/json'},
      );
    });
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(app);
    _server = await io.serve(handler, '0.0.0.0', port);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
  }
}
