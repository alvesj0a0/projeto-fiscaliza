import '../models/vistoria_model.dart';
import '../models/item_vistoria_model.dart';
import '../services/database_helper.dart';

class VistoriaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insere uma nova vistoria com os seus respetivos itens numa transação
  Future<void> salvarVistoria(
    VistoriaModel vistoria,
    List<ItemVistoriaModel> itens,
  ) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1. Salvar a vistoria
      await txn.insert('vistorias', vistoria.toMap());

      // 2. Salvar todos os itens da vistoria
      for (var item in itens) {
        await txn.insert('itens_vistoria', item.toMap());
      }
    });
  }

  /// Recupera todas as vistorias salvas localmente
  Future<List<VistoriaModel>> obterTodasVistorias() async {
    final db = await _dbHelper.database;
    final result = await db.query('vistorias', orderBy: 'data_utc DESC');
    return result.map((map) => VistoriaModel.fromMap(map)).toList();
  }

  /// Recupera vistorias pendentes de sincronização
  Future<List<VistoriaModel>> obterVistoriasNaoSincronizadas() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'vistorias',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return result.map((map) => VistoriaModel.fromMap(map)).toList();
  }

  /// Atualiza o status de sincronização de uma vistoria
  Future<void> marcarComoSincronizado(String idVistoria) async {
    final db = await _dbHelper.database;
    await db.update(
      'vistorias',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [idVistoria],
    );
  }
}
