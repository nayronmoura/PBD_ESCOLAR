import 'package:pbd_escolar/interfaces/model_interface.dart';

class NotasAlunoTurma implements IModel {
  int? id;
  int? idAluno;
  int? idTurma;
  double? nota1;
  double? nota2;
  double? nota3;
  double? nota4;

  NotasAlunoTurma(
      {this.id,
      this.idAluno,
      this.idTurma,
      this.nota1,
      this.nota2,
      this.nota3,
      this.nota4});

  factory NotasAlunoTurma.fromJson(Map<String, dynamic> json) {
    return NotasAlunoTurma(
      id: json['id'],
      idAluno: json['idAluno'],
      idTurma: json['idTurma'],
      nota1: json['nota1'],
      nota2: json['nota2'],
      nota3: json['nota3'],
      nota4: json['nota4'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'idAluno': idAluno,
        'idTurma': idTurma,
        'nota1': nota1,
        'nota2': nota2,
        'nota3': nota3,
        'nota4': nota4
      };

  static String getQuery() => """
    CREATE TABLE IF NOT EXISTS notas_aluno_turma (
      id SERIAL PRIMARY KEY,
      idAluno INTEGER NOT NULL,
      idTurma INTEGER NOT NULL,
      idMateria INTEGER NOT NULL,
      nota1 DOUBLE,
      nota2 DOUBLE,
      nota3 DOUBLE,
      nota4 DOUBLE,
      FOREIGN KEY (idAluno) REFERENCES aluno(id),
      FOREIGN KEY (idTurma) REFERENCES turma(id)
      FOREIGN KEY (idMateria) REFERENCES materia(id)
    );
  """;
}
