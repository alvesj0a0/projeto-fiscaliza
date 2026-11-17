import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/municipios_para.dart';
import '../models/questoes_formulario.dart';
import '../models/vistoria_model.dart';
import '../models/item_vistoria_model.dart';
import '../repositories/vistoria_repository.dart';
import '../services/audit_service.dart';
import '../services/location_service.dart';

class RecebimentoPeaeScreen extends StatefulWidget {
  const RecebimentoPeaeScreen({Key? key}) : super(key: key);

  @override
  State<RecebimentoPeaeScreen> createState() => _RecebimentoPeaeScreenState();
}

class _RecebimentoPeaeScreenState extends State<RecebimentoPeaeScreen> {
  static const Color accentGreen = Color(0xFF0C7A68);
  final VistoriaRepository _repository = VistoriaRepository();

  String _municipioSelecionado = 'Breves';
  final Map<String, String> _respostas =
      {}; // id_pergunta -> 'Conforme' ou 'Divergente'
  final Map<String, TextEditingController> _obsControllers = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var q in ChecklistFormularios.perguntasPEAE) {
      _respostas[q.id] = 'Conforme';
      _obsControllers[q.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _obsControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  Future<void> _salvarVistoriaCompleta() async {
    setState(() => _isLoading = true);

    try {
      final idVistoria = const Uuid().v4();
      const escolaId = 'EEEF_SAO_FRANCISCO_01';
      const fiscalId = 'FISCAL_ANA_PAULA';
      final dataUtc = DateTime.now().toUtc().toIso8601String();

      final posicao = await LocationService.obterPosicaoAtual();
      final lat = posicao?.latitude ?? -1.81539;
      final lng = posicao?.longitude ?? -49.79518;

      final hash = AuditService.gerarHashVistoria(
        idVistoria: idVistoria,
        escolaId: escolaId,
        dataUtc: dataUtc,
        latitude: lat,
        longitude: lng,
        fiscalId: fiscalId,
      );

      // Se houver qualquer resposta crítica como Divergente, marca como Crítica
      bool temCritica = false;
      List<ItemVistoriaModel> itens = [];

      for (var q in ChecklistFormularios.perguntasPEAE) {
        final resp = _respostas[q.id] ?? 'Conforme';
        if (q.ehCritico && resp == 'Divergente') {
          temCritica = true;
        }

        itens.add(
          ItemVistoriaModel(
            id: const Uuid().v4(),
            vistoriaId: idVistoria,
            nomeItem: q.enunciado,
            status: resp,
            observacao: _obsControllers[q.id]?.text.trim(),
          ),
        );
      }

      final vistoria = VistoriaModel(
        id: idVistoria,
        escolaId: escolaId,
        tipoPrograma: 'PEAE',
        status: temCritica ? 'Critica' : 'Pendente',
        latitude: lat,
        longitude: lng,
        precisao: posicao?.accuracy ?? 5.0,
        dataUtc: dataUtc,
        hashSha256: hash,
        sincronizado: false,
      );

      await _repository.salvarVistoria(vistoria, itens);

      if (!mounted) return;

      if (temCritica) {
        Navigator.pushNamed(context, '/inconformidade');
      } else {
        Navigator.pushNamed(context, '/revisao_envio');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar formulário: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Formulário PEAE • Alimentação',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seleção de Município
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: DropdownButtonFormField<String>(
                  value: _municipioSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Município do Pará',
                    border: InputBorder.none,
                  ),
                  items: DadosPara.municipios.map((m) {
                    return DropdownMenuItem(
                      value: m.nome,
                      child: Text('${m.nome} (${m.dre})'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _municipioSelecionado = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Perguntas
            ...ChecklistFormularios.perguntasPEAE.map((pergunta) {
              final isDivergente = _respostas[pergunta.id] == 'Divergente';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pergunta.bloco,
                              style: const TextStyle(
                                fontSize: 10,
                                color: accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (pergunta.ehCritico) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Item Crítico',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pergunta.enunciado,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (pergunta.orientacaoFiscal != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Orientação: ${pergunta.orientacaoFiscal}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Botões Conforme / Divergente
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Conforme')),
                              selected: _respostas[pergunta.id] == 'Conforme',
                              selectedColor: Colors.green.shade100,
                              onSelected: (_) => setState(
                                () => _respostas[pergunta.id] = 'Conforme',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Divergente')),
                              selected: _respostas[pergunta.id] == 'Divergente',
                              selectedColor: Colors.red.shade100,
                              onSelected: (_) => setState(
                                () => _respostas[pergunta.id] = 'Divergente',
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (isDivergente) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _obsControllers[pergunta.id],
                          decoration: InputDecoration(
                            hintText: 'Descreva a irregularidade observada...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Botão Avançar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentGreen),
                onPressed: _isLoading ? null : _salvarVistoriaCompleta,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Salvar e Continuar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
