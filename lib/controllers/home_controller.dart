import 'package:pbd_escolar/controllers/alunos_handler.dart';
import 'package:pbd_escolar/controllers/materia_handler.dart';
import 'package:pbd_escolar/controllers/turmas_controller.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:shelf_router/shelf_router.dart';

class HomeController extends IHandler {
  @override
  Router get handler {
    final router = Router(notFoundHandler: notFound);

    router.mount("/aluno", AlunosHandler().handler);

    router.mount("/turma", TurmasController().handler);

    router.mount('/materia', MateriaHandler().handler);

    return router;
  }
}
