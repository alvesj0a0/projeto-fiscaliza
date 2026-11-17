import 'package:flutter/material.dart';
import '../models/escola_model.dart';
import '../services/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';

class ListaEscolasScreen extends StatefulWidget {
  const ListaEscolasScreen({Key? key}) : super(key: key);

  @override
  State<ListaEscolasScreen> createState() => _ListaEscolasScreenState();
}

class _ListaEscolasScreenState extends State<ListaEscolasScreen> {
  static const Color accentGreen = Color(0xFF0C7A68);
  List<EscolaModel> _escolas = [];
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

      if (!mounted) return;

      setState(() {
        _escolas = result.map((m) => EscolaModel.fromMap(m)).toList();
        _carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar escolas: $e');
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: const Text(
          'Unidades Escolares',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: accentGreen))
          : _escolas.isEmpty
          ? const Center(child: Text('Nenhuma escola encontrada.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _escolas.length,
              itemBuilder: (context, index) {
                final escola = _escolas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/escola_detalhes',
                        arguments: escola,
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: accentGreen.withOpacity(0.1),
                      child: const Icon(Icons.school, color: accentGreen),
                    ),
                    title: Text(
                      escola.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${escola.localizacao} • ${escola.tipoRota}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
