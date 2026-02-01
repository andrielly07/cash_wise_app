import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'despesa/registro_despesa.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashWise',
      theme: ThemeData(cardColor: const Color(0xFF10a5c6), fontFamily: 'Roboto'),
      home: FinanceApp(userName: '',),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Transaction {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final TransactionType type;
  final IconData icon;
  final Color color;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    TransactionType type;
    IconData icon;
    Color color;

    final typeString = map['type'] as String;
    switch (typeString) {
      case 'income':
        type = TransactionType.income;
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case 'expense':
        type = TransactionType.expense;
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      case 'fixedExpense':
        type = TransactionType.fixedExpense;
        icon = Icons.schedule;
        color = Color(0xFF1032C7);
        break;
      default:
        type = TransactionType.expense;
        icon = Icons.arrow_downward;
        color = Colors.red;
    }

    return Transaction(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      type: type,
      icon: icon,
      color: color,
    );
  }
}

enum TransactionType { income, expense, fixedExpense }

class FinanceApp extends StatefulWidget {
  final String userName;

  const FinanceApp({super.key, required this.userName});

  @override
  _FinanceAppState createState() => _FinanceAppState();
}

// 🎯 SUBSTITUA A CLASSE _FinanceAppState POR ESTA VERSÃO OTIMIZADA

class _FinanceAppState extends State<FinanceApp> with WidgetsBindingObserver {
  double currentBalance = 0.0;
  String userName = 'Usuário';
  String? userPhotoBase64;
  List<Transaction> transactions = [];
  bool _isLoadingUserData = true;
  bool _isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadTransactions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // REMOVIDO: Não recarrega automaticamente quando retoma
      // Deixa apenas o trigger manual funcionar
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        print('🔵 Usuário autenticado: ${user.uid}');
        
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data();
          print('✅ Dados do usuário encontrados');
          
          if (mounted) {
            setState(() {
              final fullName = userData?['name'] ?? 'Usuário';
              userName = fullName.split(' ').first;
              userPhotoBase64 = userData?['photoBase64'] as String?;
              _isLoadingUserData = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoadingUserData = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingUserData = false;
          });
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar dados do usuário: $e');
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  // 🚀 VERSÃO OTIMIZADA - Carrega transações de forma mais eficiente
  Future<void> _loadTransactions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoadingTransactions = false;
          });
        }
        return;
      }

      print('🔵 Carregando transações do usuário: ${user.uid}');

      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.uid)
          .collection('transaction')
          .orderBy('date', descending: false)
          .get();

      List<Transaction> loadedTransactions = [];
      double balance = 0.0;

      for (var doc in snapshot.docs) {
        final transaction = Transaction.fromMap(doc.data());
        loadedTransactions.add(transaction);

        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }

      if (mounted) {
        setState(() {
          transactions = loadedTransactions;
          currentBalance = balance;
          _isLoadingTransactions = false;
        });
      }

      print('✅ ${loadedTransactions.length} transações carregadas');
      print('💰 Saldo calculado: R\$ ${balance.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Erro ao carregar transações: $e');
      if (mounted) {
        setState(() {
          _isLoadingTransactions = false;
        });
      }
    }
  }

  // 🚀 NOVO MÉTODO: Recarrega APENAS as transações (mais rápido)
  Future<void> _quickReloadTransactions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      print('⚡ Recarregamento rápido de transações...');

      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.uid)
          .collection('transaction')
          .orderBy('date', descending: false)
          .get();

      List<Transaction> loadedTransactions = [];
      double balance = 0.0;

      for (var doc in snapshot.docs) {
        final transaction = Transaction.fromMap(doc.data());
        loadedTransactions.add(transaction);

        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }

      if (mounted) {
        setState(() {
          transactions = loadedTransactions;
          currentBalance = balance;
        });
      }

      print('✅ Recarregamento rápido completo!');
    } catch (e) {
      print('❌ Erro no recarregamento rápido: $e');
    }
  }

  Future<void> _saveTransaction(Transaction transaction) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print('❌ ERRO: Nenhum usuário autenticado ao tentar salvar transação');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: Usuário não autenticado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('🔵 Iniciando salvamento da transação...');
      final transactionData = transaction.toMap();

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.uid)
          .collection('transaction')
          .doc(transaction.id)
          .set(transactionData);

      print('✅ Transação salva com sucesso no Firestore!');
      
    } catch (e, stackTrace) {
      print('❌ ERRO ao salvar transação: $e');
      print('📍 Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print('❌ ERRO: Nenhum usuário autenticado ao tentar deletar transação');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: Usuário não autenticado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('🔵 Deletando transação: ${transaction.id}');

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.uid)
          .collection('transaction')
          .doc(transaction.id)
          .delete();

      setState(() {
        transactions.removeWhere((t) => t.id == transaction.id);
        
        if (transaction.type == TransactionType.income) {
          currentBalance -= transaction.amount;
        } else {
          currentBalance += transaction.amount;
        }
      });

      print('✅ Transação deletada com sucesso!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transação "${transaction.category}" excluída'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      print('❌ ERRO ao deletar transação: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _addTransaction(String category, double amount, TransactionType type, DateTime transactionDate) {
    IconData icon;
    Color color;

    switch (type) {
      case TransactionType.income:
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case TransactionType.expense:
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      case TransactionType.fixedExpense:
        icon = Icons.schedule;
        color = Color(0xFF1032C7);
        break;
    }

    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      date: transactionDate,
      type: type,
      icon: icon,
      color: color,
    );

    setState(() {
      transactions.add(newTransaction);
      transactions.sort((a, b) => a.date.compareTo(b.date));
      
      if (type == TransactionType.income) {
        currentBalance += amount;
      } else {
        currentBalance -= amount;
      }
    });

    _saveTransaction(newTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return FinanceScreen(
      currentBalance: currentBalance,
      userName: userName,
      userPhotoBase64: userPhotoBase64,
      transactions: transactions,
      onAddTransaction: _addTransaction,
      onDeleteTransaction: _deleteTransaction,
      isLoadingUserData: _isLoadingUserData,
      isLoadingTransactions: _isLoadingTransactions,
      onRefreshUserData: _loadUserData,
      onQuickReload: _quickReloadTransactions, // 🚀 NOVO CALLBACK RÁPIDO
    );
  }
}

class FinanceScreen extends StatefulWidget {
  final double currentBalance;
  final String userName;
  final String? userPhotoBase64;
  final List<Transaction> transactions;
  final Function(String, double, TransactionType, DateTime) onAddTransaction;
  final Function(Transaction) onDeleteTransaction;
  final bool isLoadingUserData;
  final bool isLoadingTransactions;
  final VoidCallback onRefreshUserData;
  final VoidCallback onQuickReload; // 🚀 NOVO: Callback para recarregamento rápido

  const FinanceScreen({
    super.key,
    required this.currentBalance,
    required this.userName,
    this.userPhotoBase64,
    required this.transactions,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
    required this.isLoadingUserData,
    required this.isLoadingTransactions,
    required this.onRefreshUserData,
    required this.onQuickReload, // 🚀 NOVO
  });

  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String searchQuery = '';
  bool _isRefreshing = false;  // ← ADICIONE ESTA LINHA

  double get totalIncome => widget.transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => widget.transactions
      .where(
        (t) =>
            t.type == TransactionType.expense ||
            t.type == TransactionType.fixedExpense,
      )
      .fold(0.0, (sum, t) => sum + t.amount);

  List<Transaction> get filteredTransactions {
    if (searchQuery.isEmpty) {
      return widget.transactions;
    }
    return widget.transactions
        .where(
          (transaction) =>
              transaction.category.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              transaction.amount.toString().contains(searchQuery),
        )
        .toList();
  }

  Map<String, List<Transaction>> get transactionsByMonth {
    final Map<String, List<Transaction>> grouped = {};
    
    for (var transaction in filteredTransactions) {
      final monthKey = '${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}';
      
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(transaction);
    }
    
    return grouped;
  }

  double get incomePercentage {
    final total = totalIncome + totalExpense;
    if (total == 0) return 0;
    return (totalIncome / total) * 100;
  }

  double get expensePercentage {
    final total = totalIncome + totalExpense;
    if (total == 0) return 0;
    return (totalExpense / total) * 100;
  }


  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  Widget _buildProfileAvatar() {
    if (widget.userPhotoBase64 != null && widget.userPhotoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(widget.userPhotoBase64!);
        return CircleAvatar(
          backgroundImage: MemoryImage(bytes),
          backgroundColor: Colors.white.withOpacity(0.3),
        );
      } catch (e) {
        print('❌ Erro ao decodificar foto: $e');
        return _buildDefaultAvatar();
      }
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.white.withOpacity(0.3),
      child: Text(
        _getInitials(widget.userName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == 'Usuário') return 'U';
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return; // Evita múltiplos refreshes simultâneos
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Recarrega as transações
      widget.onQuickReload();
      await Future.delayed(Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dados atualizados!'),
            backgroundColor: Color(0xFF10a5c6),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Erro ao atualizar: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

 void _showMenuOptions(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.savings, color: Color(0xFF10a5c6)),
            title: Text('Cofrinho'),
            onTap: () async {
              Navigator.pop(context);
              // 🎯 AGUARDAR O RETORNO DO COFRINHO
              final result = await Navigator.pushNamed(context, '/cofrinho');
              
              // 🎯 SE RETORNOU TRUE, RECARREGAR AS TRANSAÇÕES
              if (result == true && mounted) {
                // Recarregar dados do usuário
                widget.onRefreshUserData();
                
                // Forçar atualização da tela principal
                setState(() {
                  // Isso força o rebuild da tela
                });
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart, color: Color(0xFF10a5c6)),
            title: Text('Relatório'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/relatorio');
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: Color(0xFF10a5c6)),
            title: Text('Perfil'),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.pushNamed(context, '/perfil');
              if (result == true && mounted) {
                widget.onRefreshUserData();
              }
            },
          ),
        ],
      ),
    ),
  );
}

  Future<void> _openExpenseRegistration() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
     builder: (context) => const ExpenseRegistrationScreen(), // ← SEM PARÂMETRO (despesa é padrão) // 🆕 ADICIONE isIncome: true
    ),
  );

    if (result != null && result is Map<String, dynamic>) {
      final category = result['name'] as String;
      final value = result['value'] as double;
      final categoryType = result['category'] as String;
      
      final day = result['day'] as int;
      final monthName = result['month'] as String;
      final year = result['year'] as int;
      
      final months = [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
      ];
      final month = months.indexOf(monthName) + 1;
      final transactionDate = DateTime(year, month, day);
      
      final transactionType = categoryType == 'Fixa' 
          ? TransactionType.fixedExpense 
          : TransactionType.expense;
      
      widget.onAddTransaction(category, value, transactionType, transactionDate);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Despesa "$category" adicionada com sucesso!',
            style: TextStyle(fontFamily: 'DMSans'),
          ),
          backgroundColor: Color(0xFF10a5c6),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF10a5c6),
        elevation: 0,
        leading: Container(),
        centerTitle: true,  // ← ADICIONE ESTA LINHA AQUI
        title: Text(
          'CashWise',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMenuOptions(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF10a5c6), Color(0xFF10a5c6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.pushNamed(context, '/perfil');
                          if (result == true) {
                            widget.onRefreshUserData();
                          }
                        },
                        child: _buildProfileAvatar(),
                      ),
                      SizedBox(width: 12),
                      widget.isLoadingUserData
                          ? SizedBox(
                              width: 100,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Olá, ${widget.userName}!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo atual',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _formatCurrency(widget.currentBalance),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child:
                            totalIncome + totalExpense > 0
                                ? Row(
                                  children: [
                                    if (expensePercentage > 0)
                                      Expanded(
                                        flex: expensePercentage.round(),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: Colors.red[400],
                                          ),
                                        ),
                                      ),
                                    if (incomePercentage > 0)
                                      Expanded(
                                        flex: incomePercentage.round(),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: Colors.blue[200],
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                                : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Despesa',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue[200],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Receita',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: Color(0xFF10a5c6),
                backgroundColor: Colors.white,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Histórico',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text('Buscar Transação'),
                                    content: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          searchQuery = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                            'Digite categoria ou valor...',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                      autofocus: true,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            searchQuery = '';
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text('Limpar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Buscar'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search,
                                  color: const Color(0xFF10a5c6),
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Buscar',
                                  style: TextStyle(
                                    color: const Color(0xFF10a5c6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    Expanded(
                      child: widget.isLoadingTransactions
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF10a5c6),
                              ),
                            )
                          : filteredTransactions.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      searchQuery.isNotEmpty
                                          ? Icons.search_off
                                          : Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      searchQuery.isNotEmpty
                                          ? 'Nenhuma transação encontrada'
                                          : 'Nenhuma transação encontrada',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      searchQuery.isNotEmpty
                                          ? 'Tente buscar por outro termo'
                                          : 'Toque no botão + para adicionar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                itemCount: transactionsByMonth.length,
                                itemBuilder: (context, index) {
                                  final monthKeys = transactionsByMonth.keys.toList();
                                  final monthKey = monthKeys[index];
                                  final monthTransactions = transactionsByMonth[monthKey]!;
                                  final parts = monthKey.split('/');
                                  final month = int.parse(parts[0]);
                                  final year = int.parse(parts[1]);
                                  
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: index == 0 ? 0 : 20,
                                          bottom: 12,
                                        ),
                                        child: Text(
                                          '${_getMonthName(month)} de $year',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10a5c6),
                                          ),
                                        ),
                                      ),
                                      ...monthTransactions.map((transaction) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: transaction.color.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  transaction.icon,
                                                  color: transaction.color,
                                                  size: 20,
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _formatCurrency(transaction.amount),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      transaction.category,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _formatDate(transaction.date),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: Text('Excluir transação'),
                                                          content: Text(
                                                            'Deseja realmente excluir "${transaction.category}" de ${_formatCurrency(transaction.amount)}?',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(context).pop(),
                                                              child: Text('Cancelar'),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                                widget.onDeleteTransaction(transaction);
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.red,
                                                              ),
                                                              child: Text(
                                                                'Excluir',
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red[400],
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),
            )
          ],
        ),
      ),

      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF10a5c6), Color(0xFF10a5c6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.arrow_upward, color: Color(0xFF10a5c6)),
                      title: Text('Receita'),
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExpenseRegistrationScreen(isIncome: true), // ← ADICIONAR AQUI
                          ),
                        );

                        if (result != null && result is Map<String, dynamic>) {
                          final category = result['name'] as String;
                          final value = result['value'] as double;
                          
                          final day = result['day'] as int;
                          final monthName = result['month'] as String;
                          final year = result['year'] as int;
                          
                          final months = [
                            'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
                            'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
                          ];
                          final month = months.indexOf(monthName) + 1;
                          final transactionDate = DateTime(year, month, day);
                          
                          widget.onAddTransaction(category, value, TransactionType.income, transactionDate);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Receita "$category" adicionada com sucesso!',
                                style: TextStyle(fontFamily: 'DMSans'),
                              ),
                              backgroundColor: Color(0xFF10a5c6),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.arrow_downward, color: Color(0xFF10a5c6)),
                      title: Text('Despesa'),
                      onTap: () {
                        Navigator.pop(context);
                        _openExpenseRegistration();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}