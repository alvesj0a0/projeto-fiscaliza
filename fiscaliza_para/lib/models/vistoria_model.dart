class VistoriaModel {
  final String id;
  final String escolaId;
  final String tipoPrograma; // 'PEAE' ou 'PETE'
  final String status; // 'Pendente', 'Conforme', 'Critica'
  final double? latitude;
  final double? longitude;
  final double? precisao;
  final String dataUtc;
  final String hashSha256;
  final bool sincronizado;

  VistoriaModel({
    required this.id,
    required this.escolaId,
    required this.tipoPrograma,
    required this.status,
    this.latitude,
    this.longitude,
    this.precisao,
    required this.dataUtc,
    required this.hashSha256,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'escola_id': escolaId,
      'tipo_programa': tipoPrograma,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'precisao': precisao,
      'data_utc': dataUtc,
      'hash_sha256': hashSha256,
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  factory VistoriaModel.fromMap(Map<String, dynamic> map) {
    return VistoriaModel(
      id: map['id'] as String,
      escolaId: map['escola_id'] as String,
      tipoPrograma: map['tipo_programa'] as String,
      status: map['status'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      precisao: map['precisao'] as double?,
      dataUtc: map['data_utc'] as String,
      hashSha256: map['hash_sha256'] as String,
      sincronizado: (map['sincronizado'] as int) == 1,
    );
  }
}
