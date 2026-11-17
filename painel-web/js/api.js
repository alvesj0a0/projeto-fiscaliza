const API_BASE_URL = 'http://localhost:3000/api/v1';

const ApiService = {
    async listarVistorias() {
        const res = await fetch(`${API_BASE_URL}/vistorias`);
        if (!res.ok) throw new Error('Erro ao buscar vistorias');
        return await res.json();
    },

    async listarEscolas() {
        const res = await fetch(`${API_BASE_URL}/escolas`);
        if (!res.ok) throw new Error('Erro ao buscar escolas');
        return await res.json();
    },

    async salvarEscola(novaEscola) {
        const res = await fetch(`${API_BASE_URL}/escolas`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(novaEscola)
        });
        if (!res.ok) {
            const err = await res.json();
            throw new Error(err.erro || 'Erro ao salvar escola no servidor');
        }
        return await res.json();
    },

    async listarUsuarios() {
        const res = await fetch(`${API_BASE_URL}/usuarios`);
        if (!res.ok) throw new Error('Erro ao buscar usuários');
        return await res.json();
    },

    async salvarUsuario(novoUsuario) {
        const res = await fetch(`${API_BASE_URL}/usuarios`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(novoUsuario)
        });
        if (!res.ok) {
            const err = await res.json();
            throw new Error(err.erro || 'Erro ao autorizar usuário no servidor');
        }
        return await res.json();
    }
};