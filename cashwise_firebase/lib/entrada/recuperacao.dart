import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header azul turquesa
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF10A5C6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botão voltar
                    Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'voltar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    // Ícone e título
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REDEFINIÇÃO DE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'SENHA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Conteúdo do formulário
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  // Texto explicativo
                  Text(
                    'Informe seu e-mail e enviaremos um link para recuperação da sua senha.',
                    style: TextStyle(
                      color: Color(0xFF10A5C6),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  // Label Email
                  Text(
                    'Email',
                    style: TextStyle(
                      color: Color(0xFF10A5C6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Campo de email
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Digite seu e-mail',
                        hintStyle: TextStyle(
                          color: Color(0xFF10a5c6).withOpacity(0.6),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Color(0xFF10A5C6),
                          size: 24,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: TextStyle(
                        color: Color(0xFF10A5C6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Botão Enviar link de recuperação
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // No onPressed do ElevatedButton:
                        onPressed: () async {
                          if (_emailController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Digite seu e-mail'), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          try {
                            // Novo: Enviar email de reset com Firebase
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: _emailController.text.trim(),
                            );

                            // Seu diálogo de sucesso existente (mantenha)
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Email enviado!'),
                                content: Text(
                                  'Um link de recuperação foi enviado para ${_emailController.text.trim()}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            String errorMessage;
                            switch (e.code) {
                              case 'invalid-email':
                                errorMessage = 'E-mail inválido.';
                                break;
                              case 'user-not-found':
                                errorMessage = 'Nenhum usuário encontrado com este e-mail.';
                                break;
                              default:
                                errorMessage = 'Erro: ${e.message}';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao enviar email: $e'), backgroundColor: Colors.red),
                            );
                          }
                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF10A5C6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Enviar link de recuperação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Link para voltar ao Login
                  Center(
                    child: GestureDetector(
                      onTap: () {
                      Navigator.pushNamed(context, '/');
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(text: 'Voltar para o '),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: Color(0xFF10A5C6),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
