class ItemVistoriaModel {
  final String id;
  final String vistoriaId;
  final String nomeItem;
  final double? qtdRecebida;
  final double? qtdNota;
  final String? lote;
  final String? validade;
  final String status; // 'Conforme', 'Divergência'
  final String? observacao;

  ItemVistoriaModel({
    required this.id,
    required this.vistoriaId,
    required this.nomeItem,
    this.qtdRecebida,
    this.qtdNota,
    this.lote,
    this.validade,
    required this.status,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vistoria_id': vistoriaId,
      'nome_item': nomeItem,
      'qtd_recebida': qtdRecebida,
      'qtd_nota': qtdNota,
      'lote': lote,
      'validade': validade,
      'status': status,
      'observacao': observacao,
    };
  }

  factory ItemVistoriaModel.fromMap(Map<String, dynamic> map) {
    return ItemVistoriaModel(
      id: map['id'] as String,
      vistoriaId: map['vistoria_id'] as String,
      nomeItem: map['nome_item'] as String,
      qtdRecebida: map['qtd_recebida'] as double?,
      qtdNota: map['qtd_nota'] as double?,
      lote: map['lote'] as String?,
      validade: map['validade'] as String?,
      status: map['status'] as String,
      observacao: map['observacao'] as String?,
    );
  }
}
