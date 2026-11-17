import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/vistoria_model.dart';
import '../models/item_vistoria_model.dart';
import '../repositories/vistoria_repository.dart';
import '../services/audit_service.dart';
import '../services/location_service.dart';

class VistoriaPeteScreen extends StatefulWidget {
  const VistoriaPeteScreen({Key? key}) : super(key: key);

  @override
  State<VistoriaPeteScreen> createState() => _VistoriaPeteScreenState();
}

class _VistoriaPeteScreenState extends State<VistoriaPeteScreen> {
  static const Color accentGreen = Color(0xFF0C7A68);
  final VistoriaRepository _repository = VistoriaRepository();
  final _formKey = GlobalKey<FormState>();

  String _tipoTransporte = 'Fluvial'; // 'Fluvial' ou 'Terrestre'

  final TextEditingController _veiculoController = TextEditingController(
    text: 'Lancha Escolar 02 - Marajó',
  );
  final TextEditingController _lotacaoController = TextEditingController(
    text: '21',
  );
  final TextEditingController _segurancaController = TextEditingController(
    text: '12',
  );

  bool _itensSegurancaOk = false;
  bool _documentacaoOk = true;
  bool _isLoading = false;

  void _atualizarTipoTransporte(String tipo) {
    setState(() {
      _tipoTransporte = tipo;
      if (tipo == 'Terrestre') {
        _veiculoController.text = 'Ônibus Escolar Amarelinho - Placa QDA-8021';
      } else {
        _veiculoController.text = 'Lancha Escolar 02 - Marajó';
      }
    });
  }

  Future<void> _salvarEContinuar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final idVistoria = const Uuid().v4();
      const escolaId = 'EEEF_SAO_FRANCISCO_01';
      const fiscalId = 'FISCAL_RESPONSAVEL';
      final dataUtc = DateTime.now().toUtc().toIso8601String();

      final posicao = await LocationService.obterPosicaoAtual();
      final latitude = posicao?.latitude ?? -1.81539;
      final longitude = posicao?.longitude ?? -49.79518;
      final precisao = posicao?.accuracy ?? 7.0;

      final hashSha256 = AuditService.gerarHashVistoria(
        idVistoria: idVistoria,
        escolaId: escolaId,
        dataUtc: dataUtc,
        latitude: latitude,
        longitude: longitude,
        fiscalId: fiscalId,
      );

      final statusVistoria = !_itensSegurancaOk ? 'Critica' : 'Pendente';

      final vistoria = VistoriaModel(
        id: idVistoria,
        escolaId: escolaId,
        tipoPrograma:
            'PETE ($_tipoTransporte)', // Corrigido para _tipoTransporte
        status: statusVistoria,
        latitude: latitude,
        longitude: longitude,
        precisao: precisao,
        dataUtc: dataUtc,
        hashSha256: hashSha256,
        sincronizado: false,
      );

      final rotuloSeguranca = _tipoTransporte == 'Fluvial'
          ? 'Coletes salva-vidas'
          : 'Cintos de segurança';

      final itens = [
        ItemVistoriaModel(
          id: const Uuid().v4(),
          vistoriaId: idVistoria,
          nomeItem: 'Equipamentos de Segurança ($rotuloSeguranca)',
          status: _itensSegurancaOk ? 'Conforme' : 'Divergência',
          observacao:
              'Quantidade de $rotuloSeguranca: ${_segurancaController.text} para ${_lotacaoController.text} passageiros.',
        ),
        ItemVistoriaModel(
          id: const Uuid().v4(),
          vistoriaId: idVistoria,
          nomeItem: 'Documentação e CNH/Arrais do Condutor',
          status: _documentacaoOk ? 'Conforme' : 'Divergência',
        ),
      ];

      await _repository.salvarVistoria(vistoria, itens);

      if (!mounted) return;

      if (!_itensSegurancaOk) {
        Navigator.pushNamed(context, '/inconformidade');
      } else {
        Navigator.pushNamed(context, '/revisao_envio');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar vistoria PETE: $e'),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vistoria PETE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Transporte Escolar $_tipoTransporte',
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MODALIDADE DE TRANSPORTE',
                style: TextStyle(
                  color: accentGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(Icons.directions_boat, size: 18),
                      label: const Center(
                        child: Text('Fluvial (Barco/Lancha)'),
                      ),
                      selected: _tipoTransporte == 'Fluvial',
                      selectedColor: Colors.blue.shade100,
                      onSelected: (_) => _atualizarTipoTransporte('Fluvial'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(Icons.directions_bus, size: 18),
                      label: const Center(
                        child: Text('Terrestre (Ônibus/Van)'),
                      ),
                      selected: _tipoTransporte == 'Terrestre',
                      selectedColor: Colors.orange.shade100,
                      onSelected: (_) => _atualizarTipoTransporte('Terrestre'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _veiculoController,
                decoration: InputDecoration(
                  labelText: _tipoTransporte == 'Fluvial'
                      ? 'Embarcação / Nome da Lancha'
                      : 'Veículo / Placa do Ônibus',
                  prefixIcon: Icon(
                    _tipoTransporte == 'Fluvial'
                        ? Icons.directions_boat_outlined
                        : Icons.directions_bus_outlined,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Informe o veículo/embarcação'
                    : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lotacaoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nº Passageiros',
                        prefixIcon: const Icon(Icons.people_outline),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _segurancaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: _tipoTransporte == 'Fluvial'
                            ? 'Nº Coletes'
                            : 'Nº Cintos',
                        prefixIcon: const Icon(Icons.shield_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: Text(
                  _tipoTransporte == 'Fluvial'
                      ? 'Coletes salva-vidas suficientes para 100% dos alunos?'
                      : 'Cintos de segurança operacionais em todos os assentos?',
                ),
                value: _itensSegurancaOk,
                activeColor: accentGreen,
                onChanged: (val) => setState(() => _itensSegurancaOk = val),
              ),
              SwitchListTile(
                title: Text(
                  _tipoTransporte == 'Fluvial'
                      ? 'Carteira de Arrais e Registro da Embarcação em dia?'
                      : 'CNH Categoria D/E do motorista e Licenciamento válidos?',
                ),
                value: _documentacaoOk,
                activeColor: accentGreen,
                onChanged: (val) => setState(() => _documentacaoOk = val),
              ),
              const SizedBox(height: 24),

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
                  onPressed: _isLoading ? null : _salvarEContinuar,
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Gravando...' : 'Continuar para evidências',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
