const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'fiscaliza_central.sqlite');
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  db.run('PRAGMA foreign_keys = ON');

  // 1. Escolas
  db.run(`
    CREATE TABLE IF NOT EXISTS escolas (
      id TEXT PRIMARY KEY,
      inep TEXT NOT NULL,
      nome TEXT NOT NULL,
      tipo TEXT DEFAULT 'Estadual',
      qtd_estudantes INTEGER NOT NULL,
      localizacao TEXT NOT NULL,
      dre TEXT DEFAULT '08ª DRE - Breves (Marajó)',
      diretor TEXT NOT NULL,
      tipo_rota TEXT NOT NULL
    )
  `);

  // 2. Usuários Autorizados (Restrito a Diretores Escolares e Gestores Sede SEDUC-PA)
  db.run(`
    CREATE TABLE IF NOT EXISTS usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      cpf TEXT UNIQUE NOT NULL,
      email TEXT NOT NULL,
      perfil TEXT NOT NULL CHECK(perfil IN ('Diretor escolar', 'Gestor Sede SEDUC-PA')),
      ativo INTEGER DEFAULT 1
    )
  `);

  // 3. Vistorias Sincronizadas
  db.run(`
    CREATE TABLE IF NOT EXISTS vistorias (
      id TEXT PRIMARY KEY,
      escola_id TEXT NOT NULL,
      tipo_programa TEXT NOT NULL,
      status TEXT NOT NULL,
      latitude REAL,
      longitude REAL,
      precisao REAL,
      data_utc TEXT NOT NULL,
      hash_sha256 TEXT NOT NULL,
      recebido_em TEXT NOT NULL,
      FOREIGN KEY (escola_id) REFERENCES escolas (id)
    )
  `);

  // 4. Itens Inspecionados
  db.run(`
    CREATE TABLE IF NOT EXISTS itens_vistoria (
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
  `);
});

module.exports = db;