const express = require('express');
const router = express.Router();
const db = require('../database/db');

const PERFIS_PERMITIDOS = ['Diretor escolar', 'Gestor Sede SEDUC-PA'];

router.get('/', (req, res) => {
    db.all('SELECT id, nome, cpf, email, perfil, ativo FROM usuarios ORDER BY nome ASC', [], (err, rows) => {
        if (err) return res.status(500).json({ erro: err.message });
        res.json(rows);
    });
});

router.post('/', (req, res) => {
    const { nome, cpf, email, perfil } = req.body;

    if (!PERFIS_PERMITIDOS.includes(perfil)) {
        return res.status(403).json({
            erro: 'Perfil não autorizado. Apenas Diretores Escolares e Gestores da Sede SEDUC-PA podem atuar como fiscais.'
        });
    }

    db.run(
        'INSERT INTO usuarios (nome, cpf, email, perfil, ativo) VALUES (?, ?, ?, ?, 1)',
        [nome, cpf, email, perfil],
        function (err) {
            if (err) return res.status(400).json({ erro: 'CPF já cadastrado ou dados inválidos.' });
            res.status(201).json({ id: this.lastID, mensagem: 'Fiscal autorizado com sucesso.' });
        }
    );
});

module.exports = router;