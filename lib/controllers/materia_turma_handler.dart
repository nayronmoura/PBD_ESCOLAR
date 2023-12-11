import 'dart:convert';

import 'package:pbd_escolar/banco/banco_dados.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:pbd_escolar/models/materia_turma.dart';
import 'package:pbd_escolar/utils/response_formatter.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class MateriaTurma extends IHandler {
  final bancoDados = BancoDados.instance;
  @override
  Router get handler {
    final router = Router();
    router.post('/', _postMateriaTurma);

    return router;
  }

  // Future<Response> _getAll(Request request) async {
  //   try {
  //     final materiaTurmaMap =
  //         await bancoDados.query("select * from materia_turma");
  //     return ResponseFormatter.sucess(message: materiaTurmaMap);
  //   } catch (e) {
  //     return ResponseFormatter.badRequest(
  //         message: 'Erro ao buscar materia_turma');
  //   }
  // }

  Future<Response> _postMateriaTurma(Request request) async {
    String body = await request.readAsString();
    try {
      final materiaTurma = MateriaTurmaModel.fromJson(jsonDecode(body));

      if (materiaTurma.idMateria == null || materiaTurma.idTurma == null) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar materiaTurma, tente novamente");
      }

      await bancoDados.execute(
          "insert into materia_turma (id_materia, id_turma) values ('${materiaTurma.idMateria}', '${materiaTurma.idTurma}')");
      return ResponseFormatter.sucess(
          message: 'MateriaTurma criada com sucesso');
    } catch (e) {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar materiaTurma, tente novamente");
    }
  }
}
