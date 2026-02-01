import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String _extractNameFromEmail(String email) {
    if (email.contains('@')) {
      String username = email.split('@')[0];
      return username.isNotEmpty
          ? username[0].toUpperCase() + username.substring(1).toLowerCase()
          : 'Usuário';
    }
    return email.isNotEmpty ? email : 'Usuário';
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? const Color(0xFF10a5c6),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Validar formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Validações adicionais
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(
        'Por favor, preencha todos os campos',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar(
        'Por favor, insira um e-mail válido',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔵 Tentando login com: $email');

      // Login com Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print('✅ Login realizado com UID: ${userCredential.user?.uid}');

      // Buscar nome do usuário no Firestore (opcional)
      String userName = _extractNameFromEmail(email);

      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (userDoc.exists && userDoc.data() != null) {
          userName = userDoc.data()!['name'] ?? userName;
          print('✅ Nome do usuário encontrado: $userName');
        }
      } catch (firestoreError) {
        print('⚠️ Erro ao buscar dados do usuário: $firestoreError');
        // Continua mesmo sem os dados do Firestore
      }

      if (!mounted) return;

      _showSnackBar(
        'Login realizado com sucesso!',
        backgroundColor: Colors.green,
      );

      // Aguardar um momento antes de navegar
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navegar para tela inicial passando o nome do usuário
      Navigator.pushReplacementNamed(
        context,
        '/telainicial',
        arguments: userName,
      );

      print('✅ Navegação para tela inicial concluída');
    } catch (e) {
      print('❌ Erro no login: $e');

      String errorMessage = 'Erro ao realizar login';

      // Tratamento de erros específicos
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'Nenhum usuário encontrado com este e-mail';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Senha incorreta';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'E-mail inválido';
      } else if (e.toString().contains('invalid-credential')) {
        errorMessage = 'E-mail ou senha incorretos';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Erro de conexão. Verifique sua internet';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Muitas tentativas. Tente novamente mais tarde';
      } else if (e.toString().contains('user-disabled')) {
        errorMessage = 'Esta conta foi desativada';
      } else {
        errorMessage = 'Erro: ${e.toString().split(':').last.trim()}';
      }

      if (mounted) {
        _showSnackBar(errorMessage, backgroundColor: Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header com logo e título
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10a5c6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Logo da empresa dentro de um container\
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10a5c6),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.asset(
                          'assets/images/CashLogo.png',
                          height: 125,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback caso a imagem não carregue
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFF10a5c6),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.lightbulb_outline,
                                        color: Color(0xFF10a5c6),
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'CA\$H',
                                      style: TextStyle(
                                        color: Color(0xFF10a5c6),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF10a5c6),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    'wise',
                                    style: TextStyle(
                                      color: Color(0xFF10a5c6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Conteúdo principal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const Text(
                        'BEM-VINDO DE VOLTA!',
                        style: TextStyle(
                          color: Color(0xFF10a5c6),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Botão Google
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    _showSnackBar(
                                      'Funcionalidade em desenvolvimento',
                                    );
                                  },
                          icon: Image.network(
                            'https://developers.google.com/identity/images/g-logo.png',
                            height: 20,
                            width: 20,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.g_mobiledata,
                                color: Colors.red,
                                size: 28,
                              );
                            },
                          ),
                          label: const Text(
                            'Fazer login com o Google',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF10a5c6),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF10a5c6),
                            side: const BorderSide(
                              color: Color(0xFF10a5c6),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Botão Facebook
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    _showSnackBar(
                                      'Funcionalidade em desenvolvimento',
                                    );
                                  },
                          icon: const Icon(
                            Icons.facebook,
                            color: Color(0xFF1877F2),
                            size: 24,
                          ),
                          label: const Text(
                            'Fazer login com o Facebook',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF10a5c6),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF10a5c6),
                            side: const BorderSide(
                              color: Color(0xFF10a5c6),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Divisor "OU"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'OU',
                              style: TextStyle(
                                color: Color(0xFF10a5c6),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Campo de email
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu e-mail';
                            }
                            if (!_isValidEmail(value)) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'E-mail',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF10a5c6),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color(0xFF10a5c6),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ),

                      // Campo de senha
                      Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          enabled: !_isLoading,
                          onFieldSubmitted: (_) => _handleLogin(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira sua senha';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Senha',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF10a5c6),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF10a5c6),
                              ),
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color(0xFF10a5c6),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ),

                      // Botão ENTRAR
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10a5c6),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[400],
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Links de rodapé
                      Column(
                        children: [
                          GestureDetector(
                            onTap:
                                _isLoading
                                    ? null
                                    : () {
                                      Navigator.pushNamed(
                                        context,
                                        '/recuperacao',
                                      );
                                    },
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color:
                                      _isLoading ? Colors.grey : Colors.black87,
                                ),
                                children: [
                                  const TextSpan(text: 'Esqueceu sua senha? '),
                                  TextSpan(
                                    text: 'Clique aqui',
                                    style: TextStyle(
                                      color:
                                          _isLoading
                                              ? Colors.grey
                                              : const Color(0xFF10a5c6),
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap:
                                _isLoading
                                    ? null
                                    : () {
                                      Navigator.pushNamed(context, '/cadastro');
                                    },
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color:
                                      _isLoading ? Colors.grey : Colors.black87,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Não possui uma conta? ',
                                  ),
                                  TextSpan(
                                    text: 'Cadastre-se',
                                    style: TextStyle(
                                      color:
                                          _isLoading
                                              ? Colors.grey
                                              : const Color(0xFF10a5c6),
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
