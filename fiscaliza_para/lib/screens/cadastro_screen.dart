import 'package:flutter/material.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  static const Color accentGreen = Color(0xFF0C7A68);
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String _perfilSelecionado = 'Fiscal estadual';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Criar Conta',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cadastre-se no Fiscaliza Pará',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Informe seus dados institucionais para acesso.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CPF',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) =>
                    v == null || v.length < 11 ? 'CPF inválido' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail Institucional',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _perfilSelecionado,
                decoration: InputDecoration(
                  labelText: 'Perfil de Acesso',
                  prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Fiscal estadual',
                    child: Text('Fiscal estadual'),
                  ),
                  DropdownMenuItem(
                    value: 'Diretor escolar',
                    child: Text('Diretor escolar'),
                  ),
                  DropdownMenuItem(
                    value: 'Gestor DRE',
                    child: Text('Gestor DRE'),
                  ),
                ],
                onChanged: (v) => setState(() => _perfilSelecionado = v!),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha de Acesso',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Mínimo de 6 caracteres' : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Conta criada com sucesso! Faça login.',
                          ),
                          backgroundColor: accentGreen,
                        ),
                      );
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: const Text(
                    'Concluir Cadastro',
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
      ),
    );
  }
}
