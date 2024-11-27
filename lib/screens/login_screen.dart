import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sophos_kodiak/screens/main_screen.dart';

final logger = Logger();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _cnpjController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _loggedInCnpj;
  String? _loggedInPassword;

  // Função para formatar o CNPJ enquanto digita
  String _formatCnpj(String value) {
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length > 14) value = value.substring(0, 14);
    if (value.length > 12) {
      value =
          '${value.substring(0, 2)}.${value.substring(2, 5)}.${value.substring(5, 8)}/${value.substring(8, 12)}-${value.substring(12)}';
    } else if (value.length > 8) {
      value =
          '${value.substring(0, 2)}.${value.substring(2, 5)}.${value.substring(5, 8)}/${value.substring(8)}';
    } else if (value.length > 5) {
      value =
          '${value.substring(0, 2)}.${value.substring(2, 5)}.${value.substring(5)}';
    } else if (value.length > 2) {
      value = '${value.substring(0, 2)}.${value.substring(2)}';
    }
    return value;
  }

  // Função para validar o CNPJ
  bool _isValidCnpj(String cnpj) {
    final regex = RegExp(r'^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$');
    return regex.hasMatch(cnpj);
  }

  // Função para validar a senha
  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  void _handleLogin() {
    final cnpj = _cnpjController.text;
    final password = _passwordController.text;

    if (_isValidCnpj(cnpj) && _isValidPassword(password)) {
      if (cnpj == '12.345.678/0001-90' && password == 'password123') {
        logger.i('Login bem-sucedido com CNPJ: $cnpj');
        setState(() {
          _loggedInCnpj = cnpj;
          _loggedInPassword = password;
        });
        _askPreferredName();
      } else {
        logger.e('CNPJ ou senha incorretos');
        _showErrorDialog('CNPJ ou senha incorretos');
      }
    } else {
      logger.e('CNPJ ou senha inválidos');
      _showErrorDialog('CNPJ ou senha inválidos');
    }
  }

  void _askPreferredName() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF171717),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Nome Preferido',
            style: TextStyle(color: Color(0xFFE6E6E6)),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Color(0xFFE6E6E6)),
            // Define a cor do texto aqui
            decoration: const InputDecoration(
              hintText: 'Digite seu nome preferido',
              hintStyle: TextStyle(
                  color: Color(0xFFA1A1A1), fontWeight: FontWeight.w400),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF6790F)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _goToMainScreen(nameController.text);
              },
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFFF6790F))),
            ),
          ],
        );
      },
    );
  }

  void _goToMainScreen(String userName) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(
            userName: userName,
            cnpj: _loggedInCnpj!,
            password: _loggedInPassword!),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Retângulo de fundo
            SizedBox(
              height: screenHeight,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: screenHeight / 1.7 + mediaQuery.padding.bottom,
                  decoration: BoxDecoration(
                    color: Color(0xFF171717),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'SOPHOS KODIAK',
                      style: TextStyle(
                          fontFamily: 'AntonSC',
                          color: Colors.white,
                          fontSize: 48,
                          letterSpacing: 0.5),
                    ),
                    Image.asset(
                      'assets/img/sophos_kodiak_logo.png',
                      height: 250,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bem-vindo de volta!',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Color(0xFFF6790F),
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Acesse sua conta',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xFFE6E6E6),
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: const Text('CNPJ',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xFFE6E6E6),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        controller: _cnpjController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final formatted = _formatCnpj(value);
                          if (formatted != value) {
                            _cnpjController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Digite o seu CNPJ',
                          hintStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFB8B8B8),
                              fontSize: 18),
                          filled: true,
                          fillColor: Color(0xFF454545),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: const Text('Senha',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xFFE6E6E6),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Digite a sua senha',
                          hintStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.normal,
                            color: Color(0xFFB8B8B8),
                            fontSize: 18,
                          ),
                          filled: true,
                          fillColor: Color(0xFF454545),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFFB8B8B8),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF6790F),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'ENTRAR',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3B1D00),
                                letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Link "Esqueci minha senha"
                    TextButton(
                      onPressed: () {
                        // Implementar a navegação para a tela de recuperação de senha
                      },
                      child: const Text(
                        'Esqueci minha senha',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            color: Color(0xFFE6E6E6),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFE6E6E6)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cnpjController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
