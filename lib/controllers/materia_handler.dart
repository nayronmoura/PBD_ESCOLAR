import 'dart:convert';

import 'package:pbd_escolar/banco/banco_dados.dart';
import 'package:pbd_escolar/interfaces/handler_interface.dart';
import 'package:pbd_escolar/models/materia.dart';
import 'package:pbd_escolar/utils/parse_parameters.dart';
import 'package:pbd_escolar/utils/response_formatter.dart';
import 'package:postgres/legacy.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class MateriaHandler extends IHandler {
  final bancoDados = BancoDados.instance;
  @override
  Router get handler {
    final router = Router();
    router.get('/', _getMateria);
    router.post('/', _create);
    router.put('/', _put);
    router.delete('/<id>', _delete);

    return router;
  }

  Future<Response> _getMateria(Request request) async {
    try {
      final result = await bancoDados.query('SELECT * FROM materia');
      return ResponseFormatter.sucess(message: result);
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  }

  Future<Response> _create(Request request) async {
    String body = await request.readAsString();
    try {
      final materia = MateriaModel.fromJson(jsonDecode(body));
      await bancoDados
          .execute("insert into materia (nome) values ('${materia.nome}')");

      return ResponseFormatter.sucess(message: 'Materia criada com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar materia, materia já existe");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar materia, tente novamente");
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar materia, verifique os dados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: "Erro ao salvar materia, tente novamente");
    }
  }

  Future<Response> _put(Request request) async {
    String body = await request.readAsString();
    try {
      final Map<String, dynamic> data = jsonDecode(body);
      if (data['id'] == null) {
        return ResponseFormatter.badRequest(
            message: "é necessário informar o id da materia");
      }
      final id = data['id'];
      data.remove('id');
      await bancoDados.execute(
          "update materia set ${ParseParameters.parseParameters(data)} where id = $id");

      return ResponseFormatter.sucess(
          message: 'materia atualizado com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar materia, materia já existe");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar materia, tente novamente");
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar materia, verifique os dados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: "Erro ao salvar materia, tente novamente");
    }
  }

  Future<Response> _delete(Request request, String id) async {
    String body = await request.readAsString();

    try {
      if (id.isEmpty || int.tryParse(id) == null) {
        return ResponseFormatter.badRequest(
            message: "é necessário informar o id do materia");
      }
      await bancoDados.execute("delete from materia where id = $id");
      return ResponseFormatter.sucess(message: 'materia deletado com sucesso');
    } on PostgreSQLException catch (e) {
      if (e.message
          .contains("duplicate key value violates unique constraint")) {
        return ResponseFormatter.badRequest(
            message: "Erro ao salvar materia, materia já existe");
      }
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar materia, tente novamente");
    } on FormatException {
      return ResponseFormatter.badRequest(
          message: "Erro ao salvar materia, verifique os dados");
    } catch (e) {
      return ResponseFormatter.internalError(
          message: "Erro ao salvar materia, tente novamente");
    }
  }
}
