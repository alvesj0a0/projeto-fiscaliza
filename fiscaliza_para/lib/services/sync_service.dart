import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../repositories/vistoria_repository.dart';
import '../services/database_helper.dart';

class SyncService {
  final VistoriaRepository _repository = VistoriaRepository();
  final String _baseUrl =
      'http://192.168.1.XX:3000/api/v1'; // Endpoint da API da SEDUC

  /// Verifica se há conexão de rede ativa
  Future<bool> temConexaoInternet() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity()
        .checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    }
    return false;
  }

  /// Sincroniza todas as vistorias pendentes com o servidor
  Future<Map<String, int>> sincronizarVistoriasPendentes() async {
    int enviadasComSucesso = 0;
    int falhas = 0;

    // 1. Verificar se o dispositivo está online
    final estaOnline = await temConexaoInternet();
    if (!estaOnline) {
      return {'sucesso': 0, 'falhas': 0, 'status': -1}; // Sem conexão
    }

    // 2. Buscar vistorias pendentes no SQLite
    final vistoriasPendentes = await _repository
        .obterVistoriasNaoSincronizadas();
    final db = await DatabaseHelper.instance.database;

    for (var vistoria in vistoriasPendentes) {
      try {
        // Buscar itens associados à vistoria
        final rawItens = await db.query(
          'itens_vistoria',
          where: 'vistoria_id = ?',
          whereArgs: [vistoria.id],
        );

        // Montar o payload JSON completo da vistoria (com itens e hash SHA-256)
        final Map<String, dynamic> payload = {
          ...vistoria.toMap(),
          'itens': rawItens,
        };

        // 3. Enviar para o servidor central
        final response = await http.post(
          Uri.parse('$_baseUrl/vistorias/sincronizar'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 4. Marcar como sincronizado localmente
          await _repository.marcarComoSincronizado(vistoria.id);
          enviadasComSucesso++;
        } else {
          falhas++;
        }
      } catch (e) {
        falhas++;
      }
    }

    return {
      'sucesso': enviadasComSucesso,
      'falhas': falhas,
      'status': 1, // Sincronização concluída
    };
  }
}
