import 'package:pbd_escolar/controllers/alunos_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class HomeController {
  Router get handler {
    final router = Router();

    router.get("/", (request) async => Response.notFound(""));

    router.mount("/alunos", (request) async => AlunosHandler().router(request));

    return router;
  }
}
