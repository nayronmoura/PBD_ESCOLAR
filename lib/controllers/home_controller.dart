import 'package:pbd_escolar/controllers/alunos_handler.dart';
import 'package:pbd_escolar/controllers/turmas_controller.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class HomeController extends HandlerInterface {
  @override
  Router get handler {
    final router = Router();

    router.get("/", (request) async => Response.notFound(""));

    router.mount(
        "/alunos", (request) async => AlunosHandler().handler(request));

    router.mount(
        "/turmas", (request) async => TurmasController().handler(request));

    router.all('/<ignored|.*>', notFound);
    return router;
  }
}
