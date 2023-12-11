import 'package:pbd_escolar/interfaces/model_interface.dart';

class MateriaTurmaModel implements IModel {
  int? id;
  int? idMateria;
  int? idTurma;

  MateriaTurmaModel({this.id, this.idMateria, this.idTurma});

  factory MateriaTurmaModel.fromJson(Map<String, dynamic> json) {
    return MateriaTurmaModel(
      id: json['id'],
      idMateria: json['id_materia'],
      idTurma: json['id_turma'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'id_materia': idMateria, 'id_turma': idTurma};

  static String getQuery() => """
    CREATE TABLE IF NOT EXISTS materia_turma (
      id SERIAL PRIMARY KEY,
      id_materia INTEGER NOT NULL,
      id_turma INTEGER NOT NULL,
      FOREIGN KEY (id_materia) REFERENCES materia(id),
      FOREIGN KEY (id_turma) REFERENCES turma(id)
    );
  """;
}
