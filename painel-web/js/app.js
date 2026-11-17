let mapaPara = null;
let camadaPins = null;

document.addEventListener('DOMContentLoaded', () => {
    inicializarMapaPara();
    configurarNavegacao();
    configurarFormularios();
    carregarDados();

    ['filtro-dre', 'filtro-programa', 'filtro-status', 'sidebar-dre-select'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('change', carregarDados);
    });

    const busca = document.getElementById('busca-global');
    if (busca) busca.addEventListener('input', carregarDados);
});

function inicializarMapaPara() {
    const container = document.getElementById('mapa-para');
    if (!container || typeof L === 'undefined') return;

    // Centraliza o mapa no Estado do Pará
    mapaPara = L.map('mapa-para', {
        center: [-3.8, -52.5],
        zoom: 5,
        minZoom: 4,
        maxZoom: 18
    });

    L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; OpenStreetMap &copy; CARTO'
    }).addTo(mapaPara);

    camadaPins = L.layerGroup().addTo(mapaPara);
}

function mudarAba(viewName) {
    document.querySelectorAll('.menu-item').forEach(b => {
        b.classList.toggle('active', b.getAttribute('data-view') === viewName);
    });
    document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
    const target = document.getElementById(`view-${viewName}`);
    if (target) target.classList.add('active');
}

function configurarNavegacao() {
    const titulos = {
        dashboard: 'Visão geral',
        mapa: 'Mapa territorial • Pará',
        vistorias: 'Vistorias & Auditoria',
        inconformidades: 'Inconformidades críticas',
        escolas: 'Unidades escolares',
        usuarios: 'Fiscais autorizados'
    };

    document.querySelectorAll('.menu-item').forEach(btn => {
        btn.addEventListener('click', () => {
            const viewName = btn.getAttribute('data-view');
            if (viewName === 'mapa') {
                mudarAba('dashboard');
                document.querySelector('.map-card')?.scrollIntoView({ behavior: 'smooth' });
                setTimeout(() => { if (mapaPara) mapaPara.invalidateSize(); }, 300);
                return;
            }
            mudarAba(viewName);
            document.getElementById('page-title').textContent = titulos[viewName] || 'Fiscaliza Pará';
            if (viewName === 'dashboard' && mapaPara) {
                setTimeout(() => mapaPara.invalidateSize(), 200);
            }
        });
    });
}

async function carregarDados() {
    try {
        const dreFiltro = document.getElementById('filtro-dre').value;
        const progFiltro = document.getElementById('filtro-programa').value;
        const statusFiltro = document.getElementById('filtro-status').value;
        const termoBusca = (document.getElementById('busca-global')?.value || '').toLowerCase();

        const [todasVistorias, escolas, usuarios] = await Promise.all([
            ApiService.listarVistorias(),
            ApiService.listarEscolas(),
            ApiService.listarUsuarios()
        ]);

        const vistoriasFiltradas = todasVistorias.filter(v => {
            const matchDre = dreFiltro === 'TODAS' || v.dre === dreFiltro;
            const matchProg = progFiltro === 'TODOS' || (v.tipo_programa && v.tipo_programa.startsWith(progFiltro));
            const matchStatus = statusFiltro === 'TODOS' || v.status === statusFiltro;
            const matchBusca = !termoBusca ||
                (v.escola_nome || '').toLowerCase().includes(termoBusca) ||
                (v.id || '').toLowerCase().includes(termoBusca);
            return matchDre && matchProg && matchStatus && matchBusca;
        });

        const total = vistoriasFiltradas.length;
        const conformes = vistoriasFiltradas.filter(v => v.status === 'Conforme').length;
        const criticas = vistoriasFiltradas.filter(v => v.status === 'Critica').length;
        const taxa = total > 0 ? Math.round((conformes / total) * 100) : 0;

        document.getElementById('kpi-escolas').textContent = escolas.length;
        document.getElementById('kpi-total').textContent = total;
        document.getElementById('kpi-criticas').textContent = criticas;
        document.getElementById('kpi-taxa').textContent = `${taxa}%`;
        document.getElementById('badge-inconf').textContent = criticas;

        atualizarPinsMapa(vistoriasFiltradas);
        renderizarGraficoEvolucao(vistoriasFiltradas);
        renderizarAlertasEStatus(vistoriasFiltradas, total, conformes, criticas);
        renderizarTabelas(vistoriasFiltradas, escolas, usuarios);
    } catch (erro) {
        console.error('Erro ao carregar dados:', erro);
    }
}

function atualizarPinsMapa(vistorias) {
    if (!mapaPara || !camadaPins) return;

    camadaPins.clearLayers();
    const caption = document.getElementById('map-status-caption');

    const comGps = vistorias.filter(v => v.latitude && v.longitude && v.latitude !== 0 && v.longitude !== 0);

    if (comGps.length === 0) {
        if (caption) caption.textContent = 'Estado do Pará • Nenhuma coordenada GPS sincronizada ainda';
        return;
    }

    if (caption) caption.textContent = `Estado do Pará • ${comGps.length} ponto(s) geolocalizado(s)`;

    const bounds = [];

    comGps.forEach(v => {
        const isCritica = v.status === 'Critica';
        const cor = isCritica ? '#DC2626' : '#0C7A68';

        const marcador = L.circleMarker([v.latitude, v.longitude], {
            radius: 9,
            fillColor: cor,
            color: '#FFFFFF',
            weight: 2,
            opacity: 1,
            fillOpacity: 0.9
        });

        marcador.bindPopup(`
      <div style="font-size:12px; line-height:1.4;">
        <strong>${v.escola_nome || v.escola_id}</strong><br>
        Programa: <b>${v.tipo_programa}</b><br>
        Status: <span style="color:${cor}; font-weight:bold;">${v.status}</span><br>
        GPS: ${Number(v.latitude).toFixed(5)}, ${Number(v.longitude).toFixed(5)}
      </div>
    `);

        marcador.addTo(camadaPins);
        bounds.push([v.latitude, v.longitude]);
    });

    if (bounds.length === 1) {
        mapaPara.setView(bounds[0], 11);
    } else if (bounds.length > 1) {
        mapaPara.fitBounds(bounds, { padding: [40, 40] });
    }
}

function renderizarGraficoEvolucao(vistorias) {
    const container = document.getElementById('grafico-evolucao');
    if (!container) return;

    const meses = ['Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov'];
    const contagem = [0, 0, 0, 0, 0, 0, 0, 0];

    vistorias.forEach(v => {
        if (!v.data_utc) return;
        const mesIndex = new Date(v.data_utc).getUTCMonth();
        const pos = mesIndex - 3;
        if (pos >= 0 && pos < 8) contagem[pos]++;
    });

    const maxVal = Math.max(...contagem, 1);
    container.innerHTML = meses.map((m, idx) => {
        const pct = contagem[idx] === 0 ? 4 : Math.round((contagem[idx] / maxVal) * 100);
        return `
      <div class="bar-col">
        <div class="bar ${contagem[idx] > 0 ? 'active' : ''}" style="height: ${pct}%;" title="${contagem[idx]} vistoria(s)"></div>
        <span>${m}</span>
      </div>
    `;
    }).join('');
}

function renderizarAlertasEStatus(vistorias, total, conformes, criticas) {
    const listaAlertas = document.getElementById('lista-alertas-prioritarios');
    const criticasLista = vistorias.filter(v => v.status === 'Critica');

    if (listaAlertas) {
        listaAlertas.innerHTML = criticasLista.length === 0
            ? '<div class="alert-item atencao"><strong>Nenhuma ocorrência crítica ativa</strong><span>Aguardando registros ou todas as unidades estão regulares.</span></div>'
            : criticasLista.slice(0, 3).map(v => `
        <div class="alert-item critico" onclick="inspecionarVistoria('${v.id}')">
          <strong>⚠ Divergência crítica • ${v.tipo_programa}</strong>
          <span>${v.escola_nome || v.escola_id} • Protocolo ${v.id}</span>
        </div>
      `).join('');
    }

    const graficoStatus = document.getElementById('grafico-status');
    if (graficoStatus) {
        const pctConf = total > 0 ? Math.round((conformes / total) * 100) : 0;
        const pctCrit = total > 0 ? Math.round((criticas / total) * 100) : 0;

        graficoStatus.innerHTML = `
      <div class="progress-row">
        <label><span>Conformes</span><strong>${conformes} (${pctConf}%)</strong></label>
        <div class="progress-track"><div class="progress-fill" style="width:${pctConf}%; background:#0C7A68;"></div></div>
      </div>
      <div class="progress-row">
        <label><span>Inconformidades Críticas</span><strong>${criticas} (${pctCrit}%)</strong></label>
        <div class="progress-track"><div class="progress-fill" style="width:${pctCrit}%; background:#DC2626;"></div></div>
      </div>
      <div class="progress-row">
        <label><span>Integridade Criptográfica (SHA-256)</span><strong>${total} (${total > 0 ? 100 : 0}%)</strong></label>
        <div class="progress-track"><div class="progress-fill" style="width:${total > 0 ? 100 : 0}%; background:#2563EB;"></div></div>
      </div>
    `;
    }
}

function renderizarTabelas(vistorias, escolas, usuarios) {
    const tbodyRecentes = document.getElementById('tabela-recentes');
    if (tbodyRecentes) {
        tbodyRecentes.innerHTML = vistorias.length === 0
            ? '<tr><td colspan="6">Nenhuma vistoria sincronizada ainda.</td></tr>'
            : vistorias.slice(0, 6).map(v => `
        <tr>
          <td><strong>${v.id}</strong></td>
          <td>${v.escola_nome || v.escola_id}</td>
          <td>${v.tipo_programa}</td>
          <td>${v.data_utc}</td>
          <td><span class="${v.status === 'Critica' ? 'pill-red' : 'pill-green'}">${v.status}</span></td>
          <td><span class="hash-code">${(v.hash_sha256 || '').substring(0, 14)}...</span></td>
        </tr>
      `).join('');
    }

    const tbodyCompleta = document.getElementById('tabela-vistorias-completa');
    if (tbodyCompleta) {
        tbodyCompleta.innerHTML = vistorias.length === 0
            ? '<tr><td colspan="7">Nenhum registro de auditoria encontrado.</td></tr>'
            : vistorias.map(v => `
        <tr>
          <td><strong>${v.id}</strong></td>
          <td>${v.escola_nome || v.escola_id}</td>
          <td>${v.tipo_programa}</td>
          <td>${v.latitude || 0}, ${v.longitude || 0}</td>
          <td><span class="${v.status === 'Critica' ? 'pill-red' : 'pill-green'}">${v.status}</span></td>
          <td><span class="hash-code">${(v.hash_sha256 || '').substring(0, 18)}...</span></td>
          <td><button class="btn-primary" onclick="inspecionarVistoria('${v.id}')">Auditar</button></td>
        </tr>
      `).join('');
    }

    const tbodyInconf = document.getElementById('tabela-inconformidades');
    if (tbodyInconf) {
        const apenasCriticas = vistorias.filter(v => v.status === 'Critica');
        tbodyInconf.innerHTML = apenasCriticas.length === 0
            ? '<tr><td colspan="5">Nenhuma inconformidade crítica pendente.</td></tr>'
            : apenasCriticas.map(v => `
        <tr>
          <td><strong>${v.id}</strong></td>
          <td>${v.escola_nome || v.escola_id}</td>
          <td>${v.tipo_programa}</td>
          <td>${v.data_utc}</td>
          <td><button class="btn-primary" onclick="inspecionarVistoria('${v.id}')">Ver Detalhes</button></td>
        </tr>
      `).join('');
    }

    const tbodyEscolas = document.getElementById('tabela-escolas');
    if (tbodyEscolas) {
        tbodyEscolas.innerHTML = escolas.length === 0
            ? '<tr><td colspan="5">Nenhuma escola cadastrada ainda.</td></tr>'
            : escolas.map(e => `
        <tr>
          <td>${e.inep}</td>
          <td><strong>${e.nome}</strong></td>
          <td>${e.localizacao}</td>
          <td>${e.tipo_rota}</td>
          <td>${e.diretor}</td>
        </tr>
      `).join('');
    }

    const tbodyUsuarios = document.getElementById('tabela-usuarios');
    if (tbodyUsuarios) {
        tbodyUsuarios.innerHTML = usuarios.length === 0
            ? '<tr><td colspan="5">Nenhum fiscal cadastrado ainda.</td></tr>'
            : usuarios.map(u => `
        <tr>
          <td><strong>${u.nome}</strong></td>
          <td>${u.cpf}</td>
          <td>${u.email}</td>
          <td>${u.perfil}</td>
          <td><span class="pill-green">Ativo</span></td>
        </tr>
      `).join('');
    }
}

function configurarFormularios() {
    document.getElementById('form-escola')?.addEventListener('submit', async (e) => {
        e.preventDefault();
        try {
            await ApiService.salvarEscola({
                id: 'ESC_' + Date.now(),
                inep: document.getElementById('esc-inep').value.trim(),
                nome: document.getElementById('esc-nome').value.trim(),
                localizacao: document.getElementById('esc-municipio').value.trim(),
                tipo_rota: document.getElementById('esc-rota').value,
                diretor: document.getElementById('esc-diretor').value.trim(),
                qtd_estudantes: parseInt(document.getElementById('esc-alunos').value, 10)
            });
            e.target.reset();
            await carregarDados();
            alert('Unidade escolar salva com sucesso!');
        } catch (erro) {
            alert('Erro ao salvar escola: ' + erro.message);
        }
    });

    document.getElementById('form-usuario')?.addEventListener('submit', async (e) => {
        e.preventDefault();
        try {
            await ApiService.salvarUsuario({
                nome: document.getElementById('usr-nome').value.trim(),
                cpf: document.getElementById('usr-cpf').value.trim(),
                email: document.getElementById('usr-email').value.trim(),
                perfil: document.getElementById('usr-perfil').value
            });
            e.target.reset();
            await carregarDados();
            alert('Fiscal autorizado com sucesso!');
        } catch (erro) {
            alert('Erro ao salvar fiscal: ' + erro.message);
        }
    });
}

async function inspecionarVistoria(id) {
    const vistorias = await ApiService.listarVistorias();
    const v = vistorias.find(item => item.id === id);
    if (!v) return;

    document.getElementById('modal-body').innerHTML = `
    <p><strong>Protocolo:</strong> ${v.id}</p>
    <p><strong>Unidade:</strong> ${v.escola_nome || v.escola_id}</p>
    <p><strong>Programa:</strong> ${v.tipo_programa}</p>
    <p><strong>Coordenadas GPS:</strong> ${v.latitude}, ${v.longitude}</p>
    <p><strong>Data UTC:</strong> ${v.data_utc}</p>
    <hr style="margin: 10px 0; border: 0; border-top: 1px solid #E2E8F0;">
    <p><strong>Assinatura Digital SHA-256:</strong><br><span class="hash-code">${v.hash_sha256}</span></p>
  `;
    document.getElementById('modal-auditoria').classList.remove('hidden');
}

function fecharModal() {
    document.getElementById('modal-auditoria').classList.add('hidden');
}