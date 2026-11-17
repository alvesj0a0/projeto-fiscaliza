import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuditService {
  /// Gera o hash SHA-256 combinando os dados críticos da vistoria
  static String gerarHashVistoria({
    required String idVistoria,
    required String escolaId,
    required String dataUtc,
    required double latitude,
    required double longitude,
    required String fiscalId,
  }) {
    final String rawData =
        '$idVistoria|$escolaId|$dataUtc|$latitude|$longitude|$fiscalId';
    final bytes = utf8.encode(rawData);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Valida se o hash SHA-256 corresponde aos dados originais
  static bool validarIntegridade({
    required String hashOriginal,
    required String idVistoria,
    required String escolaId,
    required String dataUtc,
    required double latitude,
    required double longitude,
    required String fiscalId,
  }) {
    final hashCalculado = gerarHashVistoria(
      idVistoria: idVistoria,
      escolaId: escolaId,
      dataUtc: dataUtc,
      latitude: latitude,
      longitude: longitude,
      fiscalId: fiscalId,
    );
    return hashCalculado == hashOriginal;
  }
}
