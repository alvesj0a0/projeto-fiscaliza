class EscolaModel {
  final String id;
  final String inep;
  final String nome;
  final String tipo;
  final int qtdEstudantes;
  final String localizacao;
  final String diretor;
  final String tipoRota;

  EscolaModel({
    required this.id,
    required this.inep,
    required this.nome,
    required this.tipo,
    required this.qtdEstudantes,
    required this.localizacao,
    required this.diretor,
    required this.tipoRota,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inep': inep,
      'nome': nome,
      'tipo': tipo,
      'qtd_estudantes': qtdEstudantes,
      'localizacao': localizacao,
      'diretor': diretor,
      'tipo_rota': tipoRota,
    };
  }

  factory EscolaModel.fromMap(Map<String, dynamic> map) {
    return EscolaModel(
      id: map['id'] as String,
      inep: map['inep'] as String,
      nome: map['nome'] as String,
      tipo: map['tipo'] as String,
      qtdEstudantes: map['qtd_estudantes'] as int,
      localizacao: map['localizacao'] as String,
      diretor: map['diretor'] as String,
      tipoRota: map['tipo_rota'] as String,
    );
  }
}
