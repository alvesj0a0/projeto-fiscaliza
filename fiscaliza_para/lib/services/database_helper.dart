import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fiscaliza_para.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.rawQuery('PRAGMA journal_mode = WAL');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabela de Escolas
    await db.execute('''
      CREATE TABLE escolas (
        id TEXT PRIMARY KEY,
        inep TEXT NOT NULL,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        qtd_estudantes INTEGER NOT NULL,
        localizacao TEXT NOT NULL,
        diretor TEXT NOT NULL,
        tipo_rota TEXT NOT NULL
      )
    ''');

    // 2. Tabela de Vistorias
    await db.execute('''
      CREATE TABLE vistorias (
        id TEXT PRIMARY KEY,
        escola_id TEXT NOT NULL,
        tipo_programa TEXT NOT NULL,
        status TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        precisao REAL,
        data_utc TEXT NOT NULL,
        hash_sha256 TEXT NOT NULL,
        sincronizado INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (escola_id) REFERENCES escolas (id)
      )
    ''');

    // 3. Tabela de Itens da Vistoria
    await db.execute('''
      CREATE TABLE itens_vistoria (
        id TEXT PRIMARY KEY,
        vistoria_id TEXT NOT NULL,
        nome_item TEXT NOT NULL,
        qtd_recebida REAL,
        qtd_nota REAL,
        lote TEXT,
        validade TEXT,
        status TEXT NOT NULL,
        observacao TEXT,
        FOREIGN KEY (vistoria_id) REFERENCES vistorias (id)
      )
    ''');

    // 4. Tabela de Fotos
    await db.execute('''
      CREATE TABLE fotos_vistoria (
        id TEXT PRIMARY KEY,
        vistoria_id TEXT NOT NULL,
        caminho_arquivo TEXT NOT NULL,
        hash_foto TEXT NOT NULL,
        data_captura TEXT NOT NULL,
        FOREIGN KEY (vistoria_id) REFERENCES vistorias (id)
      )
    ''');

    // 5. Tabela de Providências
    await db.execute('''
      CREATE TABLE providencias (
        id TEXT PRIMARY KEY,
        vistoria_id TEXT NOT NULL,
        descricao_providencia TEXT NOT NULL,
        prazo_dias INTEGER NOT NULL,
        data_registro TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (vistoria_id) REFERENCES vistorias (id)
      )
    ''');

    // Índices de Desempenho
    await db.execute(
      'CREATE INDEX idx_vistorias_sincronizado ON vistorias (sincronizado);',
    );
    await db.execute(
      'CREATE INDEX idx_vistorias_data ON vistorias (data_utc DESC);',
    );
    await db.execute(
      'CREATE INDEX idx_itens_vistoria_id ON itens_vistoria (vistoria_id);',
    );
    await db.execute(
      'CREATE INDEX idx_fotos_vistoria_id ON fotos_vistoria (vistoria_id);',
    );
    await db.execute(
      'CREATE INDEX idx_providencias_vistoria_id ON providencias (vistoria_id);',
    );

    // Seed Data com Substituição sem Conflito de Chave
    await db.insert('escolas', {
      'id': 'EEEF_SAO_FRANCISCO_01',
      'inep': '15128408',
      'nome': 'EEEF São Francisco do Rio',
      'tipo': 'Estadual',
      'qtd_estudantes': 286,
      'localizacao': 'Comunidade São João, Rio Canaticu — Curralinho',
      'diretor': 'Marta de Nazaré Silva',
      'tipo_rota': 'Rota fluvial',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('escolas', {
      'id': 'EEEM_SOL_NASCENTE_02',
      'inep': '15098211',
      'nome': 'EEEM Sol Nascente',
      'tipo': 'Estadual',
      'qtd_estudantes': 540,
      'localizacao': 'Centro — Breves',
      'diretor': 'Carlos Eduardo Ramos',
      'tipo_rota': 'Terrestre',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('escolas', {
      'id': 'EEEF_MARAJO_03',
      'inep': '15110499',
      'nome': 'EEEF Princesa do Marajó',
      'tipo': 'Estadual',
      'qtd_estudantes': 310,
      'localizacao': 'Rio Paracauari — Soure',
      'diretor': 'Ana Lúcia Barbosa',
      'tipo_rota': 'Rota fluvial',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
