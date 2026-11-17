const express = require('express');
const cors = require('cors');
const path = require('path');

const vistoriasRoutes = require('./routes/vistorias.routes');
const escolasRoutes = require('./routes/escolas.routes');
const usuariosRoutes = require('./routes/usuarios.routes');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json({ limit: '15mb' }));

// Servir os arquivos do Painel Web Admin diretamente pelo servidor
app.use(express.static(path.join(__dirname, '../painel-web')));

// Rotas REST v1
app.use('/api/v1/vistorias', vistoriasRoutes);
app.use('/api/v1/escolas', escolasRoutes);
app.use('/api/v1/usuarios', usuariosRoutes);

app.get('/api/v1', (req, res) => {
  res.json({
    sistema: 'Fiscaliza Pará API • SEDUC-PA',
    status: 'online',
    endpoints_disponiveis: [
      '/api/v1/health',
      '/api/v1/escolas',
      '/api/v1/vistorias',
      '/api/v1/usuarios'
    ]
  });
});

app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'online', sistema: 'Fiscaliza Pará API • SEDUC-PA' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Painel Web Admin: http://localhost:${PORT}`);
  console.log(`API REST v1:      http://localhost:${PORT}/api/v1`);
});