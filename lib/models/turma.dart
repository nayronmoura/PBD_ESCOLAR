import 'package:pbd_escolar/interfaces/model_interface.dart';

class TurmaModel implements IModel {
  int? id;
  String? nome;

  TurmaModel({this.id, this.nome});

  factory TurmaModel.fromJson(Map<String, dynamic> json) {
    return TurmaModel(
      id: json['id'],
      nome: json['nome'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome};

  static String getQuery() => """
  create table if not exists turma(
	  id serial primary key,
	  nome varchar(255)
  );
      """;
}
