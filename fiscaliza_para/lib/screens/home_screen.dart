import 'package:flutter/material.dart';
import '../models/vistoria_model.dart';
import '../repositories/vistoria_repository.dart';
import '../services/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color accentGreen = Color(0xFF0C7A68);
  final VistoriaRepository _repository = VistoriaRepository();

  bool _carregando = true;
  int _vistoriasHoje = 0;
  int _vistoriasPendentes = 0;
  int _vistoriasCriticas = 0;
  List<VistoriaModel> _atividadesRecentes = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosDashboard();
  }

  Future<void> _carregarDadosDashboard() async {
    try {
      await DatabaseHelper.instance.database;
      final allVistorias = await _repository.obterTodasVistorias();
      final hojeStr = DateTime.now().toUtc().toIso8601String().substring(0, 10);

      int hojeCount = 0;
      int pendentesCount = 0;
      int criticasCount = 0;

      for (var v in allVistorias) {
        if (v.dataUtc.startsWith(hojeStr)) hojeCount++;
        if (!v.sincronizado) pendentesCount++;
        if (v.status.toLowerCase().contains('critica') ||
            v.status.toLowerCase().contains('crítica')) {
          criticasCount++;
        }
      }

      if (!mounted) return;

      setState(() {
        _vistoriasHoje = hojeCount;
        _vistoriasPendentes = pendentesCount;
        _vistoriasCriticas = criticasCount;
        _atividadesRecentes = allVistorias.take(5).toList();
        _carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dashboard: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _exibirMensagemFeedback(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
        backgroundColor: accentGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Leitura dinâmica dos parâmetros passados pela tela de login
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String nomeUsuario = args?['nome'] ?? 'Fiscal Responsável';
    final String perfilUsuario = args?['perfil'] ?? 'Fiscal estadual';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        child: _carregando
            ? const Center(child: CircularProgressIndicator(color: accentGreen))
            : RefreshIndicator(
                onRefresh: _carregarDadosDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header com Nome e Perfil Dinâmicos
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fiscaliza Pará',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Olá, $nomeUsuario',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '$perfilUsuario • DRE Marajó',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            onPressed: () => _exibirMensagemFeedback(
                              'Nenhuma notificação pendente.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Banner Offline
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.wifi_off,
                              color: Color(0xFFE65100),
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Modo offline',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE65100),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Registros serão enviados depois',
                                    style: TextStyle(
                                      color: Color(0xFFE65100),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: Color(0xFFE65100),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Métricas
                      Row(
                        children: [
                          _buildMetricCard(
                            _vistoriasHoje.toString().padLeft(2, '0'),
                            'vistorias hoje',
                            Icons.assignment_turned_in_outlined,
                            Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          _buildMetricCard(
                            _vistoriasPendentes.toString().padLeft(2, '0'),
                            'pendentes',
                            Icons.access_time,
                            Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _buildMetricCard(
                            _vistoriasCriticas.toString().padLeft(2, '0'),
                            'crítica',
                            Icons.error_outline,
                            Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Botão Nova Vistoria
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
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              '/nova_vistoria',
                            );
                            _carregarDadosDashboard();
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Iniciar nova vistoria',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Próxima Escola
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Próxima escola',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _exibirMensagemFeedback(
                              'Rota fluvial calculada para Curralinho.',
                            ),
                            child: const Text(
                              'Ver rota',
                              style: TextStyle(
                                color: accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              '/escola_detalhes',
                            );
                            _carregarDadosDashboard();
                          },
                          leading: CircleAvatar(
                            backgroundColor: accentGreen.withOpacity(0.1),
                            child: const Icon(Icons.school, color: accentGreen),
                          ),
                          title: const Text(
                            'EEEF São Francisco do Rio',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Curralinho • Comunidade São João',
                                style: TextStyle(fontSize: 11),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: [
                                  _buildTag(
                                    'Rota fluvial',
                                    Colors.blue.shade100,
                                    Colors.blue.shade800,
                                    icon: Icons.sailing,
                                  ),
                                  _buildTag(
                                    '18,6 km',
                                    Colors.grey.shade200,
                                    Colors.black87,
                                    icon: Icons.place_outlined,
                                  ),
                                  _buildTag(
                                    'PEAE + PETE',
                                    Colors.orange.shade100,
                                    Colors.orange.shade900,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Atividade Recente
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Atividade recente',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/revisao_envio',
                              );
                              _carregarDadosDashboard();
                            },
                            child: const Text(
                              'Histórico',
                              style: TextStyle(
                                color: accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _atividadesRecentes.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'Nenhuma vistoria registrada no dispositivo.',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: _atividadesRecentes.map((vistoria) {
                                  final isSincronizado = vistoria.sincronizado;
                                  return Column(
                                    children: [
                                      ListTile(
                                        leading: _buildTag(
                                          isSincronizado
                                              ? 'Sincronizado'
                                              : 'Pendente',
                                          isSincronizado
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          isSincronizado
                                              ? Colors.green.shade900
                                              : Colors.orange.shade900,
                                          icon: isSincronizado
                                              ? Icons.check
                                              : Icons.upload,
                                        ),
                                        title: Text(
                                          'Vistoria ${vistoria.tipoPrograma}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${vistoria.id.length > 8 ? vistoria.id.substring(0, 8) : vistoria.id}... • ${vistoria.dataUtc.length >= 10 ? vistoria.dataUtc.substring(0, 10) : vistoria.dataUtc}',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        trailing: Text(
                                          vistoria.tipoPrograma,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                vistoria.tipoPrograma == 'PETE'
                                                ? Colors.blue
                                                : Colors.orange,
                                          ),
                                        ),
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          '/revisao_envio',
                                        ),
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildMetricCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color text, {IconData? icon}) {
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
