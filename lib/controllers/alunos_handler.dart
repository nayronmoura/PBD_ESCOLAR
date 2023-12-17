import 'dart:convert';

import 'package:pbd_escolar/banco/banco_dados.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:pbd_escolar/models/aluno.dart';
import 'package:pbd_escolar/utils/parse_parameters.dart';
import 'package:pbd_escolar/utils/response_formatter.dart';
import 'package:postgres/legacy.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AlunosHandler extends IHandler {
  BancoDados bancoDados = BancoDados.instance;
  @override
  Router get handler {
    final router = Router();

    router.get('/', _getAll);

    router.post('/', _create);

    router.put('/', _put);

    router.delete('/<id>', _delete);

    router.get('/<id>', _getAluno);

    return router;
  }

  Future<Response> _getAll(Request request) async {
    try {
      final alunosMap = await bancoDados.query("select * from aluno");
      final alunosModel = alunosMap
          .map((aluno) => AlunoModel.fromJson(aluno).toJson())
          .toList();
      return ResponseFormatter.sucess(message: alunosModel);
    } catch (e) {
      return ResponseFormatter.internalError(message: 'Erro ao buscar alunos');
    }
  }

  Future<Response> _create(Request request) async {
    String body = await request.readAsString();
    try {
      final aluno = AlunoModel.fromJson(jsonDecode(body));
      await bancoDados.execute(
          "insert into aluno (nome, sobrenome, nascimento, genero) values ('${aluno.nome}', '${aluno.sobrenome}', '${aluno.nascimento}', '${aluno.genero}')");

      return ResponseFormatter.sucess(message: 'Aluno criado com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar aluno, aluno já existe");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar aluno, tente novamente");
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar aluno, verifique os dados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: "Erro ao salvar aluno, tente novamente");
    }
  }

  Future<Response> _put(Request request) async {
    String body = await request.readAsString();
    try {
      final Map<String, dynamic> data = jsonDecode(body);
      if (data['id'] == null) {
        return ResponseFormatter.badRequest(
            message: "é necessário informar o id do aluno");
      }
      final id = data['id'];
      data.remove('id');
      await bancoDados.execute(
          "update aluno set ${ParseParameters.parseParameters(data)} where id = $id");

      return ResponseFormatter.sucess(message: 'Aluno atualizado com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar aluno, aluno já existe");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar aluno, tente novamente");
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar aluno, verifique os dados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: "Erro ao salvar aluno, tente novamente");
    }
  }

  Future<Response> _delete(Request request, String id) async {
    try {
      if (id.isEmpty || int.tryParse(id) == null) {
        return ResponseFormatter.badRequest(
            message: "é necessário informar o id do aluno");
      }
      await bancoDados.execute("delete from aluno where id = $id");
      return ResponseFormatter.sucess(message: 'Aluno deletado com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar aluno, aluno já existe");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar aluno, tente novamente");
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar aluno, verifique os dados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: "Erro ao salvar aluno, tente novamente");
    }
  }

  Future<Response> _getAluno(Request request, String id) async {
    try {
      final alunosMap =
          await bancoDados.query("select * from aluno where id = $id");
      final alunosModel = alunosMap
          .map<AlunoModel>((aluno) => AlunoModel.fromJson(aluno))
          .toList();
      return ResponseFormatter.sucess(message: alunosModel.first.toJson());
    } catch (e) {
      return Response.internalServerError(body: 'Erro ao buscar alunos');
    }
  }
}
