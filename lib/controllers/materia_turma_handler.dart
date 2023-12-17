import 'dart:convert';

import 'package:pbd_escolar/banco/banco_dados.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:pbd_escolar/models/materia_turma.dart';
import 'package:pbd_escolar/utils/response_formatter.dart';
import 'package:postgres/legacy.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class MateriaTurma extends IHandler {
  final bancoDados = BancoDados.instance;
  @override
  Router get handler {
    final router = Router();
    router.post('/materia', _postMateriaTurma);
    router.get("/<id>/materia", _getMateriaTurma);
    router.delete("/<id>/materia/<idMateria>", _delete);

    return router;
  }

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
    } on PostgreSQLException catch (e) {
      if (e.message.contains("violates foreign key constraint")) {
        return ResponseFormatter.badRequest(
            message:
                "Erro ao salvar materia na turma, verifique se a materia e a turma existem");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar materiaTurma, tente novamente");
    }
  }

  Future<Response> _getMateriaTurma(Request request, String id) async {
    try {
      if (id.isEmpty || int.tryParse(id) == null) {
        return ResponseFormatter.badRequest(message: 'Informe o id da turma');
      }
      final alunoTurmaMap = await bancoDados.query("""
        SELECT 
            materia.*
        FROM materia_turma
        INNER JOIN materia ON materia_turma.id_materia = materia.id
        WHERE materia_turma.id_turma = 1
      """);

      return ResponseFormatter.sucess(message: alunoTurmaMap);
    } catch (e) {
      return ResponseFormatter.internalError(
          message: 'Erro ao buscar alunos da turma');
    }
  }

  Future<Response> _delete(
      Request request, String idTurma, String idMateria) async {
    try {
      if (int.tryParse(idMateria) == null || int.tryParse(idTurma) == null) {
        return ResponseFormatter.badRequest(
            message: "Erro ao remover aluno, verifique os dados enviados");
      }

      final countTurma = await bancoDados
          .query("select count(*) from materia where id = $idMateria");

      if (countTurma.first['count'] == 0) {
        return ResponseFormatter.badRequest(
            message: "Erro ao remover materia, turma não existe");
      }

      final count = await bancoDados.query(
          "select count(*) from materia_turma where id_materia = $idMateria and id_turma = $idTurma");

      if (count.first['count'] == 0) {
        return ResponseFormatter.badRequest(
            message: "Erro ao remover materia, materia não cadastrado");
      }

      await bancoDados.execute(
          "delete from materia_turma where id_materia = $idMateria and id_turma = $idTurma");

      return ResponseFormatter.sucess(message: 'materia removido com sucesso');
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao remover materia, verifique os dados enviados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: 'Erro ao remover materia');
    }
  }
}
