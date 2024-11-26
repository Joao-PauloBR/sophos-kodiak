import 'package:flutter/material.dart';
import 'package:sophos_kodiak/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String cnpj;
  final String password;

  const SettingsScreen({required this.cnpj, required this.password, super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conta', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        backgroundColor: Color(0xFF171717),
        iconTheme: const IconThemeData(color: Color(0xFFE6E6E6)),
      ),
      body: Container(
        color: Color(0xFF171717),
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildListTile(
              context,
              icon: Icons.business_rounded,
              title: 'CNPJ',
              subtitle: widget.cnpj,
              iconColor: Color(0xFFE6E6E6),
            ),
            _buildListTile(
              context,
              icon: Icons.vpn_key_rounded,
              title: 'Senha',
              subtitle: isPasswordVisible ? widget.password : '********',
              onTap: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
              textColor: Colors.white,
              iconColor: Color(0xFFE6E6E6),
            ),
            _buildListTile(
              context,
              icon: Icons.person_rounded,
              title: 'Nome',
              subtitle: 'Controtech',
              iconColor: Color(0xFFE6E6E6),
            ),
            _buildListTile(
              context,
              icon: Icons.color_lens_rounded,
              title: 'Esquema de cores',
              subtitle: 'Sistema (Padrão)',
              iconColor: Color(0xFFE6E6E6),
            ),
            _buildListTile(
              context,
              icon: Icons.language_rounded,
              title: 'Idioma',
              subtitle: 'Padrão do sistema',
              iconColor: Color(0xFFE6E6E6),
            ),
            _buildListTile(
              context,
              icon: Icons.mic_rounded,
              title: 'Idioma de entrada',
              subtitle: 'Autodetectar',
              iconColor: Color(0xFFE6E6E6),
            ),
            const Divider(color: Color(0xFF454545), height: 10),
            _buildListTile(
              context,
              icon: Icons.logout,
              title: 'Sair',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon, required String title, String subtitle = '', VoidCallback? onTap, Color textColor = Colors.white, Color iconColor = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: subtitle.isEmpty
          ? Text(
        title,
        style: TextStyle(color: textColor, fontSize: 18),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor, fontSize: 18),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}