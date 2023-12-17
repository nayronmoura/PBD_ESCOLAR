import 'package:pbd_escolar/interfaces/model_interface.dart';
import 'package:pbd_escolar/models/aluno.dart';
import 'package:pbd_escolar/models/aluno_turma.dart';
import 'package:pbd_escolar/models/materia.dart';
import 'package:pbd_escolar/models/materia_turma.dart';
import 'package:pbd_escolar/models/turma.dart';
import 'package:postgres/postgres.dart';

class BancoDados<T extends IModel> {
  Connection? conn;
  BancoDados._();

  static BancoDados? _instance;

  static BancoDados get instance {
    _instance ??= BancoDados._();
    return _instance!;
  }

  Future<void> init() async {
    conn = await Connection.open(
        Endpoint(
          host: 'localhost',
          database: 'fbd_escolar',
          username: 'postgres',
          password: 'postgres',
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable));

    await execute(AlunoModel.getQuery());
    await execute(TurmaModel.getQuery());
    await execute(AlunoTurmaModel.getQuery());
    await execute(MateriaModel.getQuery());
    await execute(MateriaTurmaModel.getQuery());
  }

  Future<bool> execute(String sql) async {
    await conn!.execute(sql);
    return true;
  }

  Future<List<Map<String, dynamic>>> query(String sql) async {
    final result = await conn!.execute(sql);
    return result.map((element) => element.toColumnMap()).toList();
  }
}
