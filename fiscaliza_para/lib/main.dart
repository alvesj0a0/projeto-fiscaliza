import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lista_escolas_screen.dart';
import 'screens/escola_detalhes_screen.dart';
import 'screens/nova_vistoria_screen.dart';
import 'screens/recebimento_peae_screen.dart';
import 'screens/revisao_envio_screen.dart';
import 'screens/inconformidade_critica_screen.dart';
import 'screens/vistoria_pete_screen.dart';
import 'screens/cadastro_screen.dart';

void main() {
  runApp(const FiscalizaParaApp());
}

class FiscalizaParaApp extends StatelessWidget {
  const FiscalizaParaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiscaliza Pará',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C7A68)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/login':
            page = const LoginPage();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/escolas':
            page = const ListaEscolasScreen();
            break;
          case '/escola_detalhes':
            page = const EscolaDetalhesScreen();
            break;
          case '/nova_vistoria':
            page = const NovaVistoriaScreen();
            break;
          case '/vistoria_pete':
            page = const VistoriaPeteScreen();
            break;
          case '/recebimento_peae':
            page = const RecebimentoPeaeScreen();
            break;
          case '/revisao_envio':
            page = const RevisaoEnvioScreen();
            break;
          case '/inconformidade':
            page = const InconformidadeCriticaScreen();
            break;
          case '/cadastro':
            page = const CadastroScreen();
            break;
          default:
            page = const HomeScreen();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
      },
    );
  }
}
