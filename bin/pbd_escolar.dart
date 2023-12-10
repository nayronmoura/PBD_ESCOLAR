import 'package:pbd_escolar/banco/banco_dados.dart';
import 'package:pbd_escolar/controllers/home_controller.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

Future<void> main(List<String> arguments) async {
  await BancoDados.instance.init();
  var handler = Pipeline().addMiddleware(logRequests()).addHandler((request) {
    return HomeController().handler(request);
  });

  var server = await shelf_io.serve(handler, 'localhost', 8080,
      poweredByHeader: "Powered by Nayron Moura");

  var swegger = await shelf_io.serve(
      SwaggerUI("swagger.yaml"), 'localhost', 8081,
      poweredByHeader: "Powered by Nayron Moura");

  print('Servidor em http://${server.address.host}:${server.port}');
  print('Swagger em http://${swegger.address.host}:${swegger.port}');
}
