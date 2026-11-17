import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({Key? key, required this.currentIndex})
    : super(key: key);

  void _executarSincronizacao(BuildContext context) async {
    final syncService = SyncService();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A verificar conexão e a sincronizar dados...'),
        duration: Duration(seconds: 2),
      ),
    );

    final resultado = await syncService.sincronizarVistoriasPendentes();

    if (!context.mounted) return;

    if (resultado['status'] == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem conexão com a internet no momento.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      final sucesso = resultado['sucesso'];
      final falhas = resultado['falhas'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sincronização: $sucesso enviada(s), $falhas falha(s).',
          ),
          backgroundColor: falhas == 0 ? const Color(0xFF0C7A68) : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF0C7A68);
    const inactiveColor = Colors.black45;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: activeColor,
      unselectedItemColor: inactiveColor,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (index) {
        if (index == 3) {
          _executarSincronizacao(context);
          return;
        }
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/escola_detalhes');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/escolas');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/revisao_envio');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Escolas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Vistorias',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Sincronizar'),
      ],
    );
  }
}
