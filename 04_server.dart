//静态服务器 https://github.com/dart-lang/samples/blob/master/server/simple/bin/server.dart
//遇到端口没关的话 netstat -ano，找到相应的端口和pid，kill掉
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

Future<void> main(List<String> args) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final cascade = Cascade().add(_staticHandler).add(_router);
  //一个请求队列 https://pub.dev/documentation/shelf/latest/shelf/Cascade-class.html
  final server = await shelf_io.serve(
      logRequests().addHandler(cascade.handler),
      //处理请求的时候顺带做个日志 https://pub.dev/documentation/shelf/latest/shelf/logRequests.html
      InternetAddress.anyIPv4,
      port);
  print(
      'Serving at http://${server.address.host}:${server.port}, Ctrl+C to stop.');
}

final _staticHandler =
    shelf_static.createStaticHandler('public', defaultDocument: 'index.html');

final _router = shelf_router.Router()
  ..get('/helloworld', _helloworldHandler)
  ..get(
    '/time',
    (request) => Response.ok(DateTime.now().toUtc().toIso8601String()),
  )
  ..get('/sum/<a|[0-9]+>/<b|[0-9]+>', _sumHandler);

Response _helloworldHandler(Request request) => Response.ok('Hello, world!');

Response _sumHandler(request, String a, String b) {
  final aNum = int.parse(a);
  final bNum = int.parse(b);
  return Response.ok(
    const JsonEncoder.withIndent(' ')
        .convert({'a': aNum, 'b': bNum, 'sum': aNum + bNum}),
    headers: {
      'content-type': 'application/json',
      'Cache-Control': 'public,max-age=6-4800',
    },
  );
}
