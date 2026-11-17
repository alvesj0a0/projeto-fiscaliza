import '../models/providencia_model.dart';
import '../services/database_helper.dart';

class ProvidenciaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Regista uma nova providência no SQLite
  Future<void> salvarProvidencia(ProvidenciaModel providencia) async {
    final db = await _dbHelper.database;
    await db.insert('providencias', providencia.toMap());
  }

  /// Recupera todas as providências de uma vistoria
  Future<List<ProvidenciaModel>> obterProvidenciasPorVistoria(
    String vistoriaId,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'providencias',
      where: 'vistoria_id = ?',
      whereArgs: [vistoriaId],
      orderBy: 'data_registro DESC',
    );
    return result.map((m) => ProvidenciaModel.fromMap(m)).toList();
  }
}
