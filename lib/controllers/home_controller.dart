import 'package:pbd_escolar/controllers/alunos_handler.dart';
import 'package:pbd_escolar/controllers/materia_handler.dart';
import 'package:pbd_escolar/controllers/turmas_controller.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:shelf_router/shelf_router.dart';

class HomeController extends IHandler {
  @override
  Router get handler {
    final router = Router(notFoundHandler: notFound);

    router.mount(
        "/alunos", (request) async => AlunosHandler().handler(request));

    router.mount(
        "/turmas", (request) async => TurmasController().handler(request));

    router.mount('/materia', (request) => MateriaHandler().handler(request));

    return router;
  }
}
