import 'package:pbd_escolar/interfaces/model_interface.dart';

class AlunoTurmaModel implements IModel {
  int? id;
  int? idAluno;
  int? idTurma;

  AlunoTurmaModel({this.id, this.idAluno, this.idTurma});

  factory AlunoTurmaModel.fromJson(Map<String, dynamic> json) {
    return AlunoTurmaModel(
        id: json['id'], idAluno: json['id_aluno'], idTurma: json['id_turma']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_aluno': idAluno,
      'id_turma': idTurma,
    };
  }

  static String getQuery() => '''
      create table if not exists aluno_turma (
        id serial primary key,
        id_aluno int not null,
        id_turma int not null,
        foreign key (id_aluno) references aluno(id),
        foreign key (id_turma) references turma(id)
      );
    ''';
}
