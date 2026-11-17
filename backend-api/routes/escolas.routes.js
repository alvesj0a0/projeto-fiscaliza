const express = require('express');
const router = express.Router();
const db = require('../database/db');

router.get('/', (req, res) => {
    db.all('SELECT * FROM escolas ORDER BY nome ASC', [], (err, rows) => {
        if (err) return res.status(500).json({ erro: err.message });
        res.json(rows);
    });
});

router.post('/', (req, res) => {
    const { id, inep, nome, localizacao, dre = '08ª DRE - Breves (Marajó)', diretor, tipo_rota, qtd_estudantes } = req.body;
    const escolaId = id || `ESC_${Date.now()}`;

    db.run(
        `INSERT INTO escolas (id, inep, nome, tipo, qtd_estudantes, localizacao, dre, diretor, tipo_rota)
     VALUES (?, ?, ?, 'Estadual', ?, ?, ?, ?, ?)`,
        [escolaId, inep, nome, qtd_estudantes, localizacao, dre, diretor, tipo_rota],
        function (err) {
            if (err) return res.status(500).json({ erro: err.message });
            res.status(201).json({ id: escolaId, mensagem: 'Escola cadastrada com sucesso.' });
        }
    );
});

module.exports = router;