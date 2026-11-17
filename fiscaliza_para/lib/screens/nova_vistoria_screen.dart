import 'package:flutter/material.dart';
import '../models/escola_model.dart';
import '../services/database_helper.dart';

class NovaVistoriaScreen extends StatefulWidget {
  const NovaVistoriaScreen({Key? key}) : super(key: key);

  @override
  State<NovaVistoriaScreen> createState() => _NovaVistoriaScreenState();
}

class _NovaVistoriaScreenState extends State<NovaVistoriaScreen> {
  static const Color accentGreen = Color(0xFF0C7A68);
  List<EscolaModel> _escolas = [];
  EscolaModel? _escolaSelecionada;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarEscolas();
  }

  Future<void> _carregarEscolas() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('escolas');
      final lista = result.map((m) => EscolaModel.fromMap(m)).toList();

      if (!mounted) return;

      setState(() {
        _escolas = lista;
        if (_escolas.isNotEmpty) {
          _escolaSelecionada = _escolas.first;
        }
        _carregando = false;
      });
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nova vistoria',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _escolaSelecionada?.nome ?? 'Selecione uma escola',
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
                  const Text(
                    'UNIDADE ESCOLAR',
                    style: TextStyle(
                      color: accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Dropdown de Seleção de Escola
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<EscolaModel>(
                        value: _escolaSelecionada,
                        isExpanded: true,
                        items: _escolas.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(
                              '${e.nome} (${e.localizacao})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _escolaSelecionada = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'TIPO DE PROGRAMA',
                        style: TextStyle(
                          color: accentGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '1 de 4',
                        style: TextStyle(color: Colors.black45, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'O que será fiscalizado?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Escolha um programa para prosseguir com a vistoria.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Card PEAE
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/recebimento_peae'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.orange.shade700,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.restaurant,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PEAE',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Text(
                                      'Alimentação escolar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Registre recebimento, lote, validade, quantidade e condições dos alimentos.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card PETE
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/vistoria_pete'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.blue.shade700,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.directions_bus,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PETE',
                                      style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Text(
                                      'Transporte escolar (Terrestre / Fluvial)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Verifique veículo ou embarcação, segurança, documentação, lotação e rota.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
