import 'dart:convert';

import 'package:pbd_escolar/banco/banco_dados.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:pbd_escolar/models/aluno_turma.dart';
import 'package:pbd_escolar/utils/response_formatter.dart';
import 'package:postgres/legacy.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class TurmasAlunosHandler extends HandlerInterface {
  BancoDados bancoDados = BancoDados.instance;
  @override
  Router get handler {
    final router = Router();

    router.post('/', _addAlunoTurma);

    router.all('/<ignored|.*>', notFound);

    return router;
  }

  Future<Response> _addAlunoTurma(Request request) async {
    String body = await request.readAsString();
    try {
      final alunoTurma = AlunoTurmaModel.fromJson(jsonDecode(body));
      await bancoDados.execute(
          "insert into aluno_turma (id_aluno, id_turma) values ('${alunoTurma.idAluno}', '${alunoTurma.idTurma}')");

      return ResponseFormatter.sucess(message: 'Aluno adicionado com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao adicionar aluno, aluno já existe");
      }
      return ResponseFormatter.internalError(
          message:
              'Erro ao adicionar aluno, aluno não existe ou turma não existe');
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao adicionar aluno, verifique os dados enviados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: 'Erro ao adicionar aluno');
    }
  }

  // Future<Response> _delete(Request request) async {
  //   final parameters = request.url.queryParameters;
  //   try {
  //     final idAluno = ParseParameters.parseInt(parameters['id_aluno']);
  //     final idTurma = ParseParameters.parseInt(parameters['id_turma']);

  //     await bancoDados.execute(
  //         "delete from aluno_turma where id_aluno = $idAluno and id_turma = $idTurma");

  //     return ResponseFormatter.sucess(message: 'Aluno removido com sucesso');
  //   } on FormatException {
  //     return ResponseFormatter.badRequest(
  //         message: "Erro ao remover aluno, verifique os dados enviados");
  //   } catch (e) {
  //     return ResponseFormatter.internalError(
  //         message: 'Erro ao remover aluno');
  //   }
  // }
}
