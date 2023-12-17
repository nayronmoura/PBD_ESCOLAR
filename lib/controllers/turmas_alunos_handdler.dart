import 'dart:convert';

import 'package:pbd_escolar/banco/banco_dados.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:pbd_escolar/models/aluno_turma.dart';
import 'package:pbd_escolar/utils/response_formatter.dart';
import 'package:postgres/legacy.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class TurmasAlunosHandler extends IHandler {
  BancoDados bancoDados = BancoDados.instance;
  @override
  Router get handler {
    final router = Router();

    router.post('/alunos', _addAlunoTurma);
    router.get('/<id>/alunos', _getAlunoTurma);
    router.delete('/<idTurma>/alunos/<idAluno>', _delete);

    return router;
  }

  Future<Response> _addAlunoTurma(Request request) async {
    String body = await request.readAsString();
    try {
      final alunoTurma = AlunoTurmaModel.fromJson(jsonDecode(body));
      if (alunoTurma.idAluno == null || alunoTurma.idTurma == null) {
        return ResponseFormatter.badRequest(
            message: "Erro ao adicionar aluno, verifique os dados enviados");
      }

      final count = await bancoDados.query(
          "select count(*) from aluno_turma where id_aluno = ${alunoTurma.idAluno}");

      if (count.first['count'] > 0) {
        return ResponseFormatter.badRequest(
            message: "Erro ao adicionar aluno, aluno já cadastrado");
      }

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

  Future<Response> _getAlunoTurma(Request request, String id) async {
    try {
      if (id.isEmpty || int.tryParse(id) == null) {
        return ResponseFormatter.badRequest(message: 'Informe o id da turma');
      }
      final alunoTurmaMap = await bancoDados.query("""
        SELECT 
            aluno.*
        FROM aluno_turma
        INNER JOIN aluno ON aluno_turma.id_aluno = aluno.id
        WHERE aluno_turma.id_turma = $id
      """);

      return ResponseFormatter.sucess(message: alunoTurmaMap);
    } catch (e) {
      return ResponseFormatter.internalError(
          message: 'Erro ao buscar alunos da turma');
    }
  }

  Future<Response> _delete(
      Request request, String idTurma, String idAluno) async {
    try {
      if (int.tryParse(idAluno) == null || int.tryParse(idTurma) == null) {
        return ResponseFormatter.badRequest(
            message: "Erro ao remover aluno, verifique os dados enviados");
      }

      final countTurma = await bancoDados
          .query("select count(*) from turma where id = $idAluno");

      if (countTurma.first['count'] == 0) {
        return ResponseFormatter.badRequest(
            message: "Erro ao remover aluno, turma não existe");
      }

      final count = await bancoDados.query(
          "select count(*) from aluno_turma where id_aluno = $idAluno and id_turma = $idTurma");

      if (count.first['count'] == 0) {
        return ResponseFormatter.badRequest(
            message: "Erro ao remover aluno, aluno não cadastrado");
      }

      await bancoDados.execute(
          "delete from aluno_turma where id_aluno = $idAluno and id_turma = $idTurma");

      return ResponseFormatter.sucess(message: 'Aluno removido com sucesso');
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao remover aluno, verifique os dados enviados");
    } catch (e) {
      return ResponseFormatter.internalError(message: 'Erro ao remover aluno');
    }
  }
}
