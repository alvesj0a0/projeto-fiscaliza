const express = require('express');
const router = express.Router();
const db = require('../database/db');

// Listar todas as vistorias com dados da escola para o Painel Web
router.get('/', (req, res) => {
    const query = `
    SELECT v.*, e.nome AS escola_nome, e.inep, e.dre
    FROM vistorias v
    LEFT JOIN escolas e ON v.escola_id = e.id
    ORDER BY v.data_utc DESC
  `;

    db.all(query, [], (err, rows) => {
        if (err) return res.status(500).json({ erro: err.message });
        res.json(rows);
    });
});

// Rota consumida pelo SyncService do App Flutter
router.post('/sincronizar', (req, res) => {
    const {
        id,
        escola_id,
        tipo_programa,
        status,
        latitude,
        longitude,
        precisao,
        data_utc,
        hash_sha256,
        itens = []
    } = req.body;

    // Validação básica de integridade criptográfica
    if (!id || !escola_id || !hash_sha256 || hash_sha256.length < 32) {
        return res.status(400).json({ erro: 'Payload inválido ou Hash SHA-256 ausente.' });
    }

    const recebidoEm = new Date().toISOString();

    db.serialize(() => {
        db.run('BEGIN TRANSACTION');

        const insertVistoria = `
      INSERT OR REPLACE INTO vistorias 
      (id, escola_id, tipo_programa, status, latitude, longitude, precisao, data_utc, hash_sha256, recebido_em)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

        db.run(
            insertVistoria,
            [id, escola_id, tipo_programa, status, latitude, longitude, precisao, data_utc, hash_sha256, recebidoEm],
            function (err) {
                if (err) {
                    db.run('ROLLBACK');
                    return res.status(500).json({ erro: 'Falha ao gravar vistoria: ' + err.message });
                }

                const insertItem = `
          INSERT OR REPLACE INTO itens_vistoria
          (id, vistoria_id, nome_item, qtd_recebida, qtd_nota, lote, validade, status, observacao)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

                const stmt = db.prepare(insertItem);
                for (const item of itens) {
                    stmt.run([
                        item.id,
                        id,
                        item.nome_item,
                        item.qtd_recebida ?? null,
                        item.qtd_nota ?? null,
                        item.lote ?? null,
                        item.validade ?? null,
                        item.status,
                        item.observacao ?? null
                    ]);
                }
                stmt.finalize((errItem) => {
                    if (errItem) {
                        db.run('ROLLBACK');
                        return res.status(500).json({ erro: 'Falha ao gravar itens: ' + errItem.message });
                    }

                    db.run('COMMIT');
                    res.status(201).json({
                        mensagem: 'Vistoria sincronizada e auditada com sucesso.',
                        id_vistoria: id,
                        recebido_em: recebidoEm
                    });
                });
            }
        );
    });
});

module.exports = router;