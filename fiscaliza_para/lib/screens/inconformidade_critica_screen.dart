import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/providencia_model.dart';
import '../repositories/providencia_repository.dart';
import '../widgets/bottom_nav_bar.dart';

class InconformidadeCriticaScreen extends StatefulWidget {
  final String vistoriaId;

  const InconformidadeCriticaScreen({Key? key, this.vistoriaId = 'P-E-0941'})
    : super(key: key);

  @override
  State<InconformidadeCriticaScreen> createState() =>
      _InconformidadeCriticaScreenState();
}

class _InconformidadeCriticaScreenState
    extends State<InconformidadeCriticaScreen> {
  static const Color accentGreen = Color(0xFF0C7A68);
  final ProvidenciaRepository _providenciaRepository = ProvidenciaRepository();
  List<ProvidenciaModel> _providencias = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProvidencias();
  }

  Future<void> _carregarProvidencias() async {
    final lista = await _providenciaRepository.obterProvidenciasPorVistoria(
      widget.vistoriaId,
    );
    setState(() {
      _providencias = lista;
      _carregando = false;
    });
  }

  void _abrirModalRegistarProvidencia() {
    final TextEditingController providenciaController = TextEditingController();
    int prazoSelecionado = 3;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Registar Providência',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descrição da ação notificatória:',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: providenciaController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Ex: Notificado o responsável para adequação do número de coletes e limitação de passageiros.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Prazo para regularização:',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: prazoSelecionado,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('24 Horas (Urgente)'),
                      ),
                      DropdownMenuItem(value: 3, child: Text('3 Dias Úteis')),
                      DropdownMenuItem(value: 5, child: Text('5 Dias Úteis')),
                      DropdownMenuItem(value: 10, child: Text('10 Dias Úteis')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => prazoSelecionado = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () async {
                    if (providenciaController.text.trim().isEmpty) return;

                    final novaProvidencia = ProvidenciaModel(
                      id: const Uuid().v4(),
                      vistoriaId: widget.vistoriaId,
                      descricaoProvidencia: providenciaController.text.trim(),
                      prazoDias: prazoSelecionado,
                      dataRegistro: DateTime.now().toUtc().toIso8601String(),
                      status: 'Em Andamento',
                    );

                    await _providenciaRepository.salvarProvidencia(
                      novaProvidencia,
                    );
                    if (!mounted) return;
                    Navigator.pop(context);
                    _carregarProvidencias();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Providência registada e notificação gerada!',
                        ),
                        backgroundColor: accentGreen,
                      ),
                    );
                  },
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inconformidade crítica',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'PETE • ${widget.vistoriaId}',
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ],
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: accentGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBadge(
                        'Crítica',
                        Colors.red.shade100,
                        Colors.red.shade900,
                        icon: Icons.warning_amber_rounded,
                      ),
                      _buildBadge(
                        _providencias.isEmpty
                            ? 'Pendente de ação'
                            : 'Notificado',
                        _providencias.isEmpty
                            ? Colors.orange.shade100
                            : Colors.blue.shade100,
                        _providencias.isEmpty
                            ? Colors.orange.shade900
                            : Colors.blue.shade900,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Card do Problema
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SEGURANÇA DE PASSAGEIROS',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Coletes insuficientes e lotação acima do limite',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Foram encontrados 12 coletes para 21 passageiros. A lotação licenciada é de 18 pessoas.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Histórico de Providências
                  const Text(
                    'Histórico de providências registadas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),

                  if (_providencias.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Center(
                        child: Text(
                          'Nenhuma providência registada para esta inconformidade.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    ..._providencias.map(
                      (prov) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Prazo: ${prov.prazoDias} dia(s)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: accentGreen,
                                  ),
                                ),
                                _buildBadge(
                                  prov.status,
                                  Colors.green.shade100,
                                  Colors.green.shade900,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              prov.descricaoProvidencia,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Registado em: ${prov.dataRegistro.length >= 10 ? prov.dataRegistro.substring(0, 10) : prov.dataRegistro}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Botão Registrar Providência
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _abrirModalRegistarProvidencia,
                      icon: const Icon(
                        Icons.assignment_turned_in_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Registrar providência',
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildBadge(String label, Color bg, Color text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
