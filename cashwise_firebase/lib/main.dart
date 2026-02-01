import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importações de todas as telas
import 'entrada/login.dart';
import 'entrada/teladecadastro.dart';
import 'entrada/recuperacao.dart';
import 'telainicial.dart';
import 'cofrinho/cofrinho.dart';
import 'despesa/relatorio.dart';
import 'despesa/registro_despesa.dart';
import 'receita/registro_receita.dart';
import 'perfil/perfil.dart';
import 'perfil/alterar_senha.dart';
import 'perfil/sobre.dart';
import 'perfil/preferencias.dart';


void main() async {
  // CRÍTICO: Inicializar o Flutter antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar o Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso');
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
  }
  
  runApp(const CashWiseApp());
}

class CashWiseApp extends StatelessWidget {
  const CashWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashWise',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: const Color(0xFF10a5c6),
        useMaterial3: true,
        fontFamily: 'DMSans',  // ← MUDEI AQUI DE 'Roboto' PARA 'DMSans'
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10a5c6),
          brightness: Brightness.light,
        ),
      ),
      debugShowCheckedModeBanner: false,
      // Rota inicial deve ser '/' para o login
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const SignUpScreen(),
        '/recuperacao': (context) => PasswordResetScreen(),
        '/telainicial': (context) => const FinanceApp(userName: ''),
        '/cofrinho': (context) => const CofrinhoScreen(),
        '/relatorio': (context) => const RelatorioScreen(),
        '/registro_despesa': (context) => const ExpenseRegistrationScreen(),
        '/registro_receita': (context) => const IncomeRegistrationScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/alterar': (context) => const AlterarSenhaScreen(),
        '/sobre': (context) => const SobreScreen(),
        '/preferencias': (context) => const PreferenciasScreen(),        
      },
      // Tratamento de rotas não encontradas
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}