class ProvidenciaModel {
  final String id;
  final String vistoriaId;
  final String descricaoProvidencia;
  final int prazoDias;
  final String dataRegistro;
  final String status; // 'Pendente', 'Em Andamento', 'Concluído'

  ProvidenciaModel({
    required this.id,
    required this.vistoriaId,
    required this.descricaoProvidencia,
    required this.prazoDias,
    required this.dataRegistro,
    this.status = 'Pendente',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vistoria_id': vistoriaId,
      'descricao_providencia': descricaoProvidencia,
      'prazo_dias': prazoDias,
      'data_registro': dataRegistro,
      'status': status,
    };
  }

  factory ProvidenciaModel.fromMap(Map<String, dynamic> map) {
    return ProvidenciaModel(
      id: map['id'] as String,
      vistoriaId: map['vistoria_id'] as String,
      descricaoProvidencia: map['descricao_providencia'] as String,
      prazoDias: map['prazo_dias'] as int,
      dataRegistro: map['data_registro'] as String,
      status: map['status'] as String,
    );
  }
}
