import 'package:pbd_escolar/interfaces/model_interface.dart';

class AlunoModel implements IModel {
  int? id;
  String nome;
  String sobrenome;
  String nascimento;
  String genero;

  AlunoModel(
      {required this.nome,
      required this.sobrenome,
      required this.nascimento,
      required this.genero,
      this.id});

  factory AlunoModel.fromJson(Map<String, dynamic> json) {
    return AlunoModel(
      nome: json['nome'],
      sobrenome: json['sobrenome'],
      nascimento: json['nascimento'],
      genero: json['genero'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nome": nome,
      "sobrenome": sobrenome,
      "nascimento": nascimento,
      "genero": genero,
      "id": id,
    };
  }

  static String getQuery() => """
  create table if not exists aluno(
	      id serial  primary key,
	      nome VARCHAR(255),
	      sobrenome VARCHAR(255),
	      nascimento VARCHAR(10),
	      genero VARCHAR(1)
      );
      """;
}
