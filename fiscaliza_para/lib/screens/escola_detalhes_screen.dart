import 'package:flutter/material.dart';
import '../models/escola_model.dart';

class EscolaDetalhesScreen extends StatelessWidget {
  final EscolaModel? escola;

  const EscolaDetalhesScreen({Key? key, this.escola}) : super(key: key);

  static const Color accentGreen = Color(0xFF0C7A68);

  @override
  Widget build(BuildContext context) {
    // Recupera a escola enviada por argumento ou usa uma padrão
    final EscolaModel escolaAtual =
        escola ??
        (ModalRoute.of(context)?.settings.arguments as EscolaModel?) ??
        EscolaModel(
          id: 'EEEF_SAO_FRANCISCO_01',
          inep: '15128408',
          nome: 'EEEF São Francisco do Rio',
          tipo: 'Estadual',
          qtdEstudantes: 286,
          localizacao: 'Comunidade São João, Rio Canaticu — Curralinho',
          diretor: 'Marta de Nazaré Silva',
          tipoRota: 'Rota fluvial',
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/escolas');
            }
          },
        ),
        title: Text(
          escolaAtual.nome,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.school, color: accentGreen),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              escolaAtual.nome,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${escolaAtual.tipo} • ${escolaAtual.qtdEstudantes} estudantes',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.blue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            escolaAtual.localizacao,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildChip(
                        escolaAtual.tipoRota,
                        Colors.blue.shade100,
                        Colors.blue.shade900,
                      ),
                      _buildChip(
                        'PEAE',
                        Colors.orange.shade100,
                        Colors.orange.shade900,
                      ),
                      _buildChip(
                        'PETE',
                        Colors.blue.shade100,
                        Colors.blue.shade900,
                      ),
                    ],
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
                  backgroundColor: accentGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(context, '/nova_vistoria'),
                icon: const Icon(Icons.add_task, color: Colors.white),
                label: const Text(
                  'Iniciar vistoria',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Abrindo coordenadas GPS no Google Maps...',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.near_me_outlined,
                      color: Colors.black87,
                      size: 18,
                    ),
                    label: const Text(
                      'Traçar rota',
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'A ligar para o(a) diretor(a) ${escolaAtual.diretor}...',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.phone_outlined,
                      color: Colors.black87,
                      size: 18,
                    ),
                    label: const Text(
                      'Ligar',
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
