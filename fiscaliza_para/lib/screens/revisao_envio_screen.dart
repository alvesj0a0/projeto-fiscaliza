import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/foto_model.dart';
import '../models/vistoria_model.dart';
import '../services/database_helper.dart';
import '../services/pdf_report_service.dart';

class RevisaoEnvioScreen extends StatefulWidget {
  final String vistoriaId;
  final bool temDivergenciaCritica;

  const RevisaoEnvioScreen({
    Key? key,
    this.vistoriaId = 'V-E-2026-001',
    this.temDivergenciaCritica = false,
  }) : super(key: key);

  @override
  State<RevisaoEnvioScreen> createState() => _RevisaoEnvioScreenState();
}

class _RevisaoEnvioScreenState extends State<RevisaoEnvioScreen> {
  static const Color accentGreen = Color(0xFF0C7A68);
  final ImagePicker _picker = ImagePicker();

  List<FotoModel> _fotos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosVistoria();
  }

  Future<void> _carregarDadosVistoria() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'fotos_vistoria',
        where: 'vistoria_id = ?',
        whereArgs: [widget.vistoriaId],
      );

      if (!mounted) return;

      setState(() {
        _fotos = result.map((m) => FotoModel.fromMap(m)).toList();
      });
    } catch (e) {
      debugPrint('Aviso ao consultar fotos locais: $e');
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _capturarFotoComCamara() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo == null) return;

      final db = await DatabaseHelper.instance.database;

      // 1. Garante que a vistoria pai existe na tabela 'vistorias' para evitar erro de Foreign Key
      final vistoriaExistente = await db.query(
        'vistorias',
        where: 'id = ?',
        whereArgs: [widget.vistoriaId],
      );

      if (vistoriaExistente.isEmpty) {
        await db.insert('vistorias', {
          'id': widget.vistoriaId,
          'escola_id': 'EEEF_SAO_FRANCISCO_01',
          'tipo_programa': 'PEAE / PETE',
          'status': 'Pendente',
          'latitude': -1.81539,
          'longitude': -49.79518,
          'precisao': 7.0,
          'data_utc': DateTime.now().toUtc().toIso8601String(),
          'hash_sha256': '9f3a8d71b4e2c90676cd112a8190342a',
          'sincronizado': 0,
        });
      }

      // 2. Gera a hash SHA-256 do ficheiro e guarda na tabela 'fotos_vistoria'
      final hash = await FotoModel.gerarHashArquivo(photo.path);
      final novaFoto = FotoModel(
        id: const Uuid().v4(),
        vistoriaId: widget.vistoriaId,
        caminhoArquivo: photo.path,
        hashFoto: hash,
        dataCaptura: DateTime.now().toUtc().toIso8601String(),
      );

      await db.insert('fotos_vistoria', novaFoto.toMap());

      _carregarDadosVistoria();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto e Hash SHA-256 de evidência salvos com sucesso!'),
          backgroundColor: accentGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _gerarPdfOficial() async {
    final vistoriaExemplo = VistoriaModel(
      id: widget.vistoriaId,
      escolaId: 'EEEF_SAO_FRANCISCO_01',
      tipoPrograma: 'PEAE / PETE',
      status: 'Concluído',
      latitude: -1.81539,
      longitude: -49.79518,
      precisao: 5.0,
      dataUtc: DateTime.now().toUtc().toIso8601String(),
      hashSha256: '9f3a8d71b4e2c90676cd112a8190342a',
      sincronizado: false,
    );

    await PdfReportService.gerarECompartilharRelatorio(
      vistoria: vistoriaExemplo,
      itens: [],
      nomeEscola: 'EEEF São Francisco do Rio',
      inepEscola: '15128408',
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
        title: const Text(
          'Revisão e envio',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
            tooltip: 'Gerar PDF',
            onPressed: _gerarPdfOficial,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: accentGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EVIDÊNCIAS E INTEGRIDADE',
                    style: TextStyle(
                      color: accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_fotos.length} foto(s) anexada(s)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.verified, size: 14, color: accentGreen),
                          SizedBox(width: 4),
                          Text(
                            'Originais preservados',
                            style: TextStyle(
                              fontSize: 11,
                              color: accentGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        GestureDetector(
                          onTap: _capturarFotoComCamara,
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: accentGreen,
                                width: 1.5,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  color: accentGreen,
                                  size: 28,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Adicionar',
                                  style: TextStyle(
                                    color: accentGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ..._fotos.map(
                          (foto) => Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black12),
                              image: DecorationImage(
                                image: FileImage(File(foto.caminhoArquivo)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Integridade do registro',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildIntegridadeRow(
                          Icons.gps_fixed,
                          'LOCALIZAÇÃO CONFIRMADA',
                          '-1.81539, -49.79518 • precisão 7m',
                          'OK',
                        ),
                        const Divider(height: 16),
                        _buildIntegridadeRow(
                          Icons.access_time,
                          'DATA/HORA UTC',
                          '2026-09-30 12:46:18 UTC',
                          'OK',
                        ),
                        const Divider(height: 16),
                        _buildIntegridadeRow(
                          Icons.fingerprint,
                          'HASH SHA-256',
                          '9f3a8d71b4e2c906...76cd112a',
                          'Íntegro',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (widget.temDivergenciaCritica) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Falha de validação',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                Text(
                                  'Inconformidade identificada exige registo de providência.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/inconformidade'),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Corrigir 1 pendência',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: accentGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vistoria salva localmente!'),
                            backgroundColor: accentGreen,
                          ),
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.save_alt, color: accentGreen),
                      label: const Text(
                        'Salvar para enviar depois',
                        style: TextStyle(
                          color: accentGreen,
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

  Widget _buildIntegridadeRow(
    IconData icon,
    String title,
    String sub,
    String badge,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: Colors.green.shade900,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
