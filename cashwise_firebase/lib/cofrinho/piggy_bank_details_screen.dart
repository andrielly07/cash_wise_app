import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cofrinho.dart';

class PiggyBankDetailsScreen extends StatefulWidget {
  final PiggyBank piggyBank;
  final Function(PiggyBank) onUpdate;
  final Function() onDelete;
  final Function() onGiveUp;

  const PiggyBankDetailsScreen({
    super.key,
    required this.piggyBank,
    required this.onUpdate,
    required this.onDelete,
    required this.onGiveUp,
  });

  @override
  State<PiggyBankDetailsScreen> createState() => _PiggyBankDetailsScreenState();
}

class _PiggyBankDetailsScreenState extends State<PiggyBankDetailsScreen> {
  late PiggyBank currentPiggyBank;
  double goalAmount = 2000.00;
  List<Map<String, dynamic>> transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentPiggyBank = widget.piggyBank;
    goalAmount = currentPiggyBank.goalAmount; // 🆕 CARREGA A META DO PORQUINHO
    _loadPiggyBankData();
  }

  // Carregar dados do cofrinho do Firestore
  Future<void> _loadPiggyBankData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🔵 Carregando dados do cofrinho: ${currentPiggyBank.id}');

      final doc = await FirebaseFirestore.instance
          .collection('piggyBanks')
          .doc(user.uid)
          .collection('piggyBank')
          .doc(currentPiggyBank.id)
          .get();

      if (doc.exists) {
        final data = doc.data();
        print('✅ Dados do cofrinho carregados: $data');
        
        setState(() {
          goalAmount = (data?['goalAmount'] as num?)?.toDouble() ?? 2000.00;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar dados do cofrinho: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Salvar meta no Firestore

  // 🆕 CRIAR TRANSAÇÃO DE DESPESA (quando guarda no cofrinho)
  Future<void> _createExpenseTransaction(double amount) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        return;
      }

      final now = DateTime.now();
      final transactionId = now.millisecondsSinceEpoch.toString();
      
      final transactionData = {
        'id': transactionId,
        'amount': amount,
        'category': 'Cofrinho - ${currentPiggyBank.name}',
        'date': now.toIso8601String(),
        'type': 'expense', // Despesa
      };

      print('🔵 Criando transação de despesa: $transactionData');

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.uid)
          .collection('transaction')
          .doc(transactionId)
          .set(transactionData);

      print('✅ Transação de despesa criada com sucesso!');
    } catch (e) {
      print('❌ Erro ao criar transação: $e');
      rethrow;
    }
  }

  // 🆕 CRIAR TRANSAÇÃO DE RECEITA (quando resgata do cofrinho)
  Future<void> _createIncomeTransaction(double amount) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        return;
      }

      final now = DateTime.now();
      final transactionId = now.millisecondsSinceEpoch.toString();
      
      final transactionData = {
        'id': transactionId,
        'amount': amount,
        'category': 'Resgate - ${currentPiggyBank.name}',
        'date': now.toIso8601String(),
        'type': 'income', // Receita
      };

      print('🔵 Criando transação de receita: $transactionData');

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.uid)
          .collection('transaction')
          .doc(transactionId)
          .set(transactionData);

      print('✅ Transação de receita criada com sucesso!');
    } catch (e) {
      print('❌ Erro ao criar transação: $e');
      rethrow;
    }
  }

  double get progressPercentage {
    if (goalAmount == 0) return 0;
    return (currentPiggyBank.savedAmount / goalAmount).clamp(0.0, 1.0);
  }

  void _showEditGoalDialog() {
    final nameController = TextEditingController(text: currentPiggyBank.name);
    final goalController = TextEditingController(text: goalAmount.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Editar Meta',
          style: TextStyle(
            color: Color(0xFF2EBBC7),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Porquinho',
                labelStyle: const TextStyle(color: Color(0xFF2EBBC7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2EBBC7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2EBBC7), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: goalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Valor da Meta (R\$)',
                labelStyle: const TextStyle(color: Color(0xFF2EBBC7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2EBBC7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2EBBC7), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentPiggyBank.name = nameController.text;
                goalAmount = double.tryParse(goalController.text) ?? goalAmount;
                currentPiggyBank.goalAmount = goalAmount; // 🆕 ATUALIZA A META NO PORQUINHO
              });
              
              widget.onUpdate(currentPiggyBank);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2EBBC7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Resgatar Dinheiro',
          style: TextStyle(
            color: Color(0xFF2EBBC7),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saldo disponível: R\$ ${currentPiggyBank.savedAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2EBBC7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Valor a resgatar (R\$)',
                labelStyle: const TextStyle(color: Color(0xFF2EBBC7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2EBBC7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2EBBC7), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0 && amount <= currentPiggyBank.savedAmount) {
                try {
                  // 🆕 Criar transação de RECEITA (volta o dinheiro para o saldo)
                  await _createIncomeTransaction(amount);
                  
                  // Atualizar saldo do cofrinho
                  setState(() {
                    currentPiggyBank.savedAmount -= amount;
                  });
                  widget.onUpdate(currentPiggyBank);
                  
                  Navigator.pop(context);
                  
                  // 🎯 RETORNAR TRUE PARA RECARREGAR A TELA INICIAL
                  Navigator.pop(context, true);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'R\$ ${amount.toStringAsFixed(2)} resgatado com sucesso!',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erro ao resgatar: $e',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Valor inválido ou maior que o saldo disponível!',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2EBBC7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Resgatar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Guardar Dinheiro',
          style: TextStyle(
            color: Color(0xFF2EBBC7),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Valor a guardar (R\$)',
            labelStyle: const TextStyle(color: Color(0xFF2EBBC7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2EBBC7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2EBBC7), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                try {
                  // 🆕 Criar transação de DESPESA (tira o dinheiro do saldo)
                  await _createExpenseTransaction(amount);
                  
                  // Atualizar saldo do cofrinho
                  setState(() {
                    currentPiggyBank.savedAmount += amount;
                  });
                  widget.onUpdate(currentPiggyBank);
                  
                  Navigator.pop(context);
                  
                  // 🎯 RETORNAR TRUE PARA RECARREGAR A TELA INICIAL
                  Navigator.pop(context, true);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'R\$ ${amount.toStringAsFixed(2)} guardado com sucesso!',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erro ao guardar: $e',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2EBBC7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showGiveUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Desistir da Meta',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja desistir desta meta? O porquinho ficará inativo mas você poderá reativá-lo depois.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onGiveUp();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Desistir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Excluir Porquinho',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja excluir este porquinho? Esta ação não pode ser desfeita.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2EBBC7),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Header com card do porquinho
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2EBBC7), Color(0xFF22D3EE)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Barra superior
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),

                        // Card principal
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Ícone e nome
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2EBBC7),
                                          Color(0xFF22D3EE)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Icon(
                                      Icons.savings,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      currentPiggyBank.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C2C2C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Círculo de progresso
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      height: 180,
                                      child: CircularProgressIndicator(
                                        value: progressPercentage,
                                        strokeWidth: 12,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF2EBBC7),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            currentPiggyBank.savedAmount
                                                .toStringAsFixed(2)
                                                .replaceAll('.', ','),
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2C2C2C),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${(progressPercentage * 100).toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFF2EBBC7),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Texto de progresso
                              Text(
                                'R\$ ${currentPiggyBank.savedAmount.toStringAsFixed(2).replaceAll('.', ',')} de R\$ ${goalAmount.toStringAsFixed(2).replaceAll('.', ',')} (${(progressPercentage * 100).toInt()}%)',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Botões de ação
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Botões principais
                          _buildActionButton(
                            label: 'Editar meta',
                            onTap: _showEditGoalDialog,
                            color: Colors.white,
                            textColor: const Color(0xFF2C2C2C),
                            borderColor: const Color(0xFF2EBBC7),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            label: 'Resgatar dinheiro',
                            onTap: _showWithdrawDialog,
                            color: Colors.white,
                            textColor: const Color(0xFF2C2C2C),
                            borderColor: const Color(0xFF2EBBC7),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            label: 'Guardar dinheiro',
                            onTap: _showDepositDialog,
                            color: const Color(0xFF2EBBC7),
                            textColor: Colors.white,
                            filled: true,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            label: 'Desistir da meta',
                            onTap: _showGiveUpDialog,
                            color: Colors.white,
                            textColor: const Color(0xFF2C2C2C),
                            borderColor: const Color(0xFF2EBBC7),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            label: 'Excluir',
                            onTap: _showDeleteDialog,
                            color: Colors.white,
                            textColor: const Color(0xFF2C2C2C),
                            borderColor: const Color(0xFF2EBBC7),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
    Color? borderColor,
    bool filled = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? color : Colors.white,
          side: BorderSide(
            color: borderColor ?? color,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}