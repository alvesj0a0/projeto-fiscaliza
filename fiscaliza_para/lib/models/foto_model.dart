import 'dart:io';
import 'package:crypto/crypto.dart';

class FotoModel {
  final String id;
  final String vistoriaId;
  final String caminhoArquivo;
  final String hashFoto;
  final String dataCaptura;

  FotoModel({
    required this.id,
    required this.vistoriaId,
    required this.caminhoArquivo,
    required this.hashFoto,
    required this.dataCaptura,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vistoria_id': vistoriaId,
      'caminho_arquivo': caminhoArquivo,
      'hash_foto': hashFoto,
      'data_captura': dataCaptura,
    };
  }

  factory FotoModel.fromMap(Map<String, dynamic> map) {
    return FotoModel(
      id: map['id'] as String,
      vistoriaId: map['vistoria_id'] as String,
      caminhoArquivo: map['caminho_arquivo'] as String,
      hashFoto: map['hash_foto'] as String,
      dataCaptura: map['data_captura'] as String,
    );
  }

  /// Gerador estático de hash SHA-256 para o arquivo de imagem
  static Future<String> gerarHashArquivo(String caminho) async {
    final file = File(caminho);
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }
}
