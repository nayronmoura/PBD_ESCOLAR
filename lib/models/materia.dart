import 'package:pbd_escolar/interfaces/model_interface.dart';

class MateriaModel implements IModel {
  int? id;
  String? nome;

  MateriaModel({this.id, this.nome});

  factory MateriaModel.fromJson(Map<String, dynamic> json) {
    return MateriaModel(
      id: json['id'],
      nome: json['nome'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome};

  static String getQuery() => """
    CREATE TABLE IF NOT EXISTS materia (
      id SERIAL PRIMARY KEY,
      nome VARCHAR(255) NOT NULL
    );
  """;
}
