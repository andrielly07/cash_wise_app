import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _aceitouTermos = false;
  bool _isLoading = false;
  
  int _selectedDay = 1;
  String _selectedMonth = 'Janeiro';
  int _selectedYear = 2000;
  
  final List<String> _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Header azul
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B4D8),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        // Ícone do relógio
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'CADASTRE-SE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const Text(
                          'AQUI!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Formulário
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Campo Nome e Sobrenome
                          _buildInputField(
                            controller: _nomeController,
                            hintText: 'Nome e Sobrenome',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu nome';
                              }
                              if (value.trim().split(' ').length < 2) {
                                return 'Por favor, insira nome e sobrenome';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Campo Email
                          _buildInputField(
                            controller: _emailController,
                            hintText: 'E-mail',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu email';
                              }
                              // Validação básica de email
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Campo Telefone
                          _buildInputField(
                            controller: _telefoneController,
                            hintText: 'Celular',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu celular';
                              }
                              // Remove caracteres não numéricos
                              final numbersOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                              if (numbersOnly.length < 10) {
                                return 'Celular inválido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Data de Nascimento
                          const Text(
                            'Data de Nascimento:',
                            style: TextStyle(
                              color: Color(0xFF00B4D8),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          Row(
                            children: [
                              // Dia
                              Expanded(
                                flex: 1,
                                child: _buildDropdown(
                                  value: _selectedDay.toString(),
                                  items: List.generate(31, (index) => (index + 1).toString()),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDay = int.parse(value!);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 15),
                              
                              // Mês
                              Expanded(
                                flex: 2,
                                child: _buildDropdown(
                                  value: _selectedMonth,
                                  items: _months,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMonth = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 15),
                              
                              // Ano
                              Expanded(
                                flex: 1,
                                child: _buildDropdown(
                                  value: _selectedYear.toString(),
                                  items: List.generate(100, (index) => (DateTime.now().year - index).toString()),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedYear = int.parse(value!);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Campo Senha
                          _buildPasswordField(),
                          
                          const SizedBox(height: 30),
                          
                          // Termos de uso
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _aceitouTermos,
                                onChanged: (value) {
                                  setState(() {
                                    _aceitouTermos = value!;
                                  });
                                },
                                activeColor: const Color(0xFF00B4D8),
                              ),
                              const Expanded(
                                child: Text(
                                  'Ao finalizar o cadastro, você declara estar de acordo com os Termos de Uso e com a Política de Privacidade, incluindo o uso dos seus dados, conforme descrito.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Botão Cadastrar
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (_aceitouTermos && !_isLoading) ? _handleSignUp : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B4D8),
                                disabledBackgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 3,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'CADASTRE-SE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,

                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Link para Login
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Já tem uma conta? ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _isLoading ? null : () {
                                    Navigator.pushReplacementNamed(context, '/');
                                  },
                                  child: Text(
                                    'Entrar',
                                    style: TextStyle(
                                      color: _isLoading ? Colors.grey : const Color(0xFF00B4D8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF00B4D8),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF00B4D8),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: _senhaController,
        obscureText: _obscurePassword,
        enabled: !_isLoading,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira uma senha';
          }
          if (value.length < 6) {
            return 'A senha deve ter pelo menos 6 caracteres';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Digite a senha:',
          hintStyle: const TextStyle(
            color: Color(0xFF00B4D8),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFF00B4D8),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF00B4D8),
            ),
            onPressed: _isLoading ? null : () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
        style: const TextStyle(
          color: Color(0xFF00B4D8),
          fontSize: 14,
        ),
        dropdownColor: Colors.white,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: _isLoading ? null : onChanged,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF00B4D8),
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    // Validação do formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validação dos termos
    if (!_aceitouTermos) {
      _showSnackBar('Aceite os termos para continuar', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Preparar dados
      final email = _emailController.text.trim();
      final password = _senhaController.text;
      final name = _nomeController.text.trim();
      final phone = _telefoneController.text.trim();
      
      // Converter mês para número
      final monthNumber = _months.indexOf(_selectedMonth) + 1;
      final birthDate = '$_selectedDay/${monthNumber.toString().padLeft(2, '0')}/$_selectedYear';

      print('🔵 Iniciando cadastro para: $email');

      // 1. Criar usuário no Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Usuário criado no Auth com UID: ${userCredential.user?.uid}');

      // 2. Verificar se o usuário foi criado
      if (userCredential.user == null) {
        throw Exception('Falha ao criar usuário');
      }

      final uid = userCredential.user!.uid;

      // 3. Salvar dados no Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'uid': uid,
          'name': name,
          'email': email,
          'phone': phone,
          'birthDate': birthDate,
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
        });
        
        print('✅ Dados salvos no Firestore');
      } catch (firestoreError) {
        print('⚠️ Erro ao salvar no Firestore: $firestoreError');
        // Mesmo com erro no Firestore, o usuário foi criado no Auth
      }

      // 4. Enviar email de verificação (opcional)
      try {
        await userCredential.user!.sendEmailVerification();
        print('✅ Email de verificação enviado');
      } catch (emailError) {
        print('⚠️ Erro ao enviar email de verificação: $emailError');
        // Não é crítico, continua o fluxo
      }

      // 5. Sucesso! Mostrar mensagem e navegar
      if (!mounted) return;

      _showSnackBar('✅ Cadastro realizado com sucesso!');
      
      // Aguardar um momento para o usuário ver a mensagem
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // 6. Fazer logout e navegar para tela de login
      if (!mounted) return;
      
      await FirebaseAuth.instance.signOut();
      print('✅ Logout realizado');
      
      if (!mounted) return;
      
      // Navegar para a tela de login
      Navigator.pushReplacementNamed(context, '/');
      print('✅ Navegação para login concluída');

    } catch (e) {
      print('❌ Erro no cadastro: $e');
      
      String errorMessage = 'Erro ao realizar cadastro';
      
      // Tentar extrair mensagem de erro do Firebase
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Este e-mail já está cadastrado';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Senha muito fraca';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'E-mail inválido';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Erro de conexão. Verifique sua internet';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Muitas tentativas. Tente novamente mais tarde';
      } else {
        errorMessage = 'Erro: ${e.toString().split(':').last.trim()}';
      }
      
      if (mounted) {
        _showSnackBar(errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF00B4D8),
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}