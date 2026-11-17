import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _cpfController = TextEditingController(
    text: '184.***.***-20',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '..........',
  );

  String _selectedPerfil = 'Fiscal estadual';

  static const Color primaryDark = Color(0xFF0F3846);
  static const Color accentGreen = Color(0xFF0C7A68);
  static const Color badgeGreenBackground = Color(0xFFE8F5E9);
  static const Color badgeGreenText = Color(0xFF2E7D32);
  static const Color bgLight = Color(0xFFF6F8F8);

  void _fazerLogin() {
    final nomeOuMatricula = _cpfController.text.trim();
    final nomeFormatado = nomeOuMatricula.isNotEmpty
        ? nomeOuMatricula
        : 'Fiscal Responsável';

    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {'nome': nomeFormatado, 'perfil': _selectedPerfil},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Escuro
            Container(
              color: primaryDark,
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Fiscaliza Pará',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Governo do Estado',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeGreenBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: badgeGreenText,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Ambiente seguro',
                              style: TextStyle(
                                color: badgeGreenText,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Fiscalização com\nrastreabilidade, mesmo\nsem sinal.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PEAE e PETE em um fluxo seguro para operações terrestres e fluviais.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Formulário
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acesso institucional',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Entre com as credenciais fornecidas pela SEDUC.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('CPF ou matrícula'),
                  _buildInputField(
                    controller: _cpfController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Senha'),
                  _buildInputField(
                    controller: _passwordController,
                    icon: Icons.key_outlined,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Perfil de acesso'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPerfil,
                        isExpanded: true,
                        items:
                            <String>[
                              'Fiscal estadual',
                              'Diretor escolar',
                              'Gestor / DRE',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null)
                            setState(() => _selectedPerfil = newValue);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _buildChip(
                        'Fiscal',
                        _selectedPerfil == 'Fiscal estadual',
                        () =>
                            setState(() => _selectedPerfil = 'Fiscal estadual'),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        'Diretor escolar',
                        _selectedPerfil == 'Diretor escolar',
                        () =>
                            setState(() => _selectedPerfil = 'Diretor escolar'),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        'Gestor / DRE',
                        _selectedPerfil == 'Gestor / DRE',
                        () => setState(() => _selectedPerfil = 'Gestor / DRE'),
                      ),
                    ],
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
                      onPressed: _fazerLogin,
                      icon: const Icon(
                        Icons.login,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Entrar com segurança',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Recuperar Senha',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Informe seu CPF cadastrado. Um link de redefinição será enviado para seu e-mail institucional registrado na SEDUC.',
                                style: TextStyle(fontSize: 12),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(color: accentGreen),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'Esqueci a senha',
                          style: TextStyle(
                            color: accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Suporte Técnico SEDUC',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Dúvidas ou problemas no acesso ao Fiscaliza Pará?\n\nE-mail: suporte.fiscaliza@seduc.pa.gov.br\nTelefone/WhatsApp: (91) 3201-5000',
                                style: TextStyle(fontSize: 12),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Fechar',
                                    style: TextStyle(color: accentGreen),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'Precisa de ajuda?',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECF3F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.fingerprint, color: accentGreen, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sessão protegida e registros assinados digitalmente neste dispositivo.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentGreen),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE1F0EC)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: accentGreen.withOpacity(0.3))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? accentGreen : Colors.black87,
          ),
        ),
      ),
    );
  }
}
