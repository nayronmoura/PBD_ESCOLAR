import 'dart:convert';

import 'package:pbd_escolar/banco/banco_dados.dart';
import 'package:pbd_escolar/controllers/materia_turma_handler.dart';
import 'package:pbd_escolar/controllers/turmas_alunos_handdler.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:pbd_escolar/models/turma.dart';
import 'package:pbd_escolar/utils/parse_parameters.dart';
import 'package:pbd_escolar/utils/response_formatter.dart';
import 'package:postgres/legacy.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class TurmasController extends IHandler {
  BancoDados bancoDados = BancoDados.instance;

  @override
  Router get handler {
    final router = Router();

    router.get('/', _getAll);

    router.post('/', _create);

    router.put('/', _put);

    router.delete('/', _delete);

    router.mount(
        '/alunos', (request) async => TurmasAlunosHandler().handler(request));

    router.mount(
        '/materias', (request) async => MateriaTurma().handler(request));

    router.get('/<idTurma>', _getId);
    return router;
  }

  Future<Response> _getAll(Request request) async {
    try {
      final turmaMap = await bancoDados.query("select * from turma");
      final turmasModel =
          turmaMap.map((turma) => TurmaModel.fromJson(turma).toJson()).toList();
      return ResponseFormatter.sucess(message: turmasModel);
    } catch (e) {
      return ResponseFormatter.internalError(message: 'Erro ao buscar turmas');
    }
  }

  Future<Response> _create(Request request) async {
    String body = await request.readAsString();
    try {
      final turma = TurmaModel.fromJson(jsonDecode(body));
      await bancoDados
          .execute("insert into turma (nome) values ('${turma.nome}')");

      return ResponseFormatter.sucess(message: 'turma criado com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar turma, turma já existe");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar turma, tente novamente");
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar turma, verifique os dados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: "Erro ao salvar turma, tente novamente");
    }
  }

  Future<Response> _put(Request request) async {
    String body = await request.readAsString();
    try {
      final Map<String, dynamic> data = jsonDecode(body);
      if (data['id'] == null) {
        return ResponseFormatter.badRequest(
            message: "é necessário informar o id da turma");
      }
      final id = data['id'];
      data.remove('id');
      await bancoDados.execute(
          "update turma set ${ParseParameters.parseParameters(data)} where id = $id");

      return ResponseFormatter.sucess(message: 'turma atualizado com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar turma, turma já existe");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar turma, tente novamente");
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar turma, verifique os dados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: "Erro ao salvar turma, tente novamente");
    }
  }

  Future<Response> _delete(Request request) async {
    String body = await request.readAsString();

    try {
      final Map<String, dynamic> data = jsonDecode(body);
      if (data['id'] == null) {
        return ResponseFormatter.badRequest(
            message: "é necessário informar o id do turma");
      }
      await bancoDados.execute("delete from turma where id = ${data['id']}");
      return ResponseFormatter.sucess(message: 'turma deletado com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar turma, turma já existe");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar turma, tente novamente");
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar turma, verifique os dados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: "Erro ao salvar turma, tente novamente");
    }
  }

  Future<Response> _getId(Request request, String id) async {
    try {
      if (id.isEmpty || int.tryParse(id) == null) {
        return ResponseFormatter.badRequest(message: 'Informe o id da turma');
      }
      final turmaMap = await bancoDados.query("""
      SELECT 
        turma.id AS id_turma,
        turma.nome AS turma_nome,
        json_agg(aluno.*) AS alunos,
        json_agg(materia.*) AS materias
      FROM aluno_turma
      INNER JOIN aluno ON aluno_turma.id_aluno = aluno.id
      INNER JOIN turma ON aluno_turma.id_turma = turma.id
      LEFT JOIN LATERAL (
        SELECT materia.id, materia.nome 
        FROM materia_turma 
        INNER JOIN materia ON materia_turma.id_materia = materia.id 
        WHERE materia_turma.id_turma = turma.id
      ) materia ON true
      WHERE turma.id = $id
      GROUP BY turma.id, turma.nome
      ORDER BY turma.nome;
      """);

      final turmaModel = turmaMap.first;
      return ResponseFormatter.sucess(message: {
        'id': turmaModel['id_turma'],
        'nome': turmaModel['turma_nome'],
        'alunos': turmaModel['alunos'],
        'materias': turmaModel['materias']
      });
    } catch (e) {
      return ResponseFormatter.internalError(message: 'Erro ao buscar turmas');
    }
  }
}
