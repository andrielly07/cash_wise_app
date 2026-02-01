import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'criar.dart';
import 'piggy_bank_details_screen.dart';

class PiggyBank {
  String id;
  String name;
  final DateTime createdAt;
  double savedAmount;
  bool isActive;
  double goalAmount; // 🆕 ADICIONADO

  PiggyBank({
    String? id,
    required this.name,
    required this.createdAt,
    this.savedAmount = 0.0,
    this.isActive = true,
    this.goalAmount = 2000.00, // 🆕 ADICIONADO
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Converter para Map (salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'savedAmount': savedAmount,
      'isActive': isActive,
      'goalAmount': goalAmount, // 🆕 CORRIGIDO - agora usa a propriedade
    };
  }

  // Criar PiggyBank a partir do Map (ler do Firestore)
  factory PiggyBank.fromMap(Map<String, dynamic> map) {
    return PiggyBank(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      savedAmount: (map['savedAmount'] as num).toDouble(),
      isActive: map['isActive'] as bool? ?? true,
      goalAmount: (map['goalAmount'] as num?)?.toDouble() ?? 2000.00, // 🆕 ADICIONADO
    );
  }
}

class CofrinhoScreen extends StatefulWidget {
  const CofrinhoScreen({super.key});

  @override
  State<CofrinhoScreen> createState() => _CofrinhoScreenState();
}

class _CofrinhoScreenState extends State<CofrinhoScreen> {
  List<PiggyBank> piggyBanks = [];
  PiggyBank? latestPiggyBank;
  bool showFlashcard = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPiggyBanks();
  }

  // Carregar cofrinhos do Firestore
  Future<void> _loadPiggyBanks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🔵 Carregando cofrinhos do usuário: ${user.uid}');

      final snapshot = await FirebaseFirestore.instance
          .collection('piggyBanks')
          .doc(user.uid)
          .collection('piggyBank')
          .orderBy('createdAt', descending: true)
          .get();

      List<PiggyBank> loadedPiggyBanks = [];

      for (var doc in snapshot.docs) {
        final piggyBank = PiggyBank.fromMap(doc.data());
        loadedPiggyBanks.add(piggyBank);
      }

      setState(() {
        piggyBanks = loadedPiggyBanks;
        _isLoading = false;
      });

      print('✅ ${loadedPiggyBanks.length} cofrinhos carregados');
    } catch (e) {
      print('❌ Erro ao carregar cofrinhos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Salvar cofrinho no Firestore
  Future<void> _savePiggyBank(PiggyBank piggyBank) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      print('🔵 Salvando cofrinho: ${piggyBank.name}');

      await FirebaseFirestore.instance
          .collection('piggyBanks')
          .doc(user.uid)
          .collection('piggyBank')
          .doc(piggyBank.id)
          .set(piggyBank.toMap());

      print('✅ Cofrinho salvo com sucesso');
    } catch (e) {
      print('❌ Erro ao salvar cofrinho: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar cofrinho: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Atualizar cofrinho no Firestore
  Future<void> _updatePiggyBank(PiggyBank piggyBank) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      print('🔵 Atualizando cofrinho: ${piggyBank.name}');

      await FirebaseFirestore.instance
          .collection('piggyBanks')
          .doc(user.uid)
          .collection('piggyBank')
          .doc(piggyBank.id)
          .update(piggyBank.toMap());

      print('✅ Cofrinho atualizado com sucesso');
    } catch (e) {
      print('❌ Erro ao atualizar cofrinho: $e');
    }
  }

  // Deletar cofrinho do Firestore
  Future<void> _deletePiggyBank(PiggyBank piggyBank) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      print('🔵 Deletando cofrinho: ${piggyBank.name}');

      await FirebaseFirestore.instance
          .collection('piggyBanks')
          .doc(user.uid)
          .collection('piggyBank')
          .doc(piggyBank.id)
          .delete();

      print('✅ Cofrinho deletado com sucesso');
    } catch (e) {
      print('❌ Erro ao deletar cofrinho: $e');
    }
  }

  double get totalSaved {
    return piggyBanks
        .where((piggy) => piggy.isActive)
        .fold(0.0, (sum, piggy) => sum + piggy.savedAmount);
  }

  void _onPiggyBankCreated(PiggyBank piggyBank) {
    setState(() {
      piggyBanks.insert(0, piggyBank);
      latestPiggyBank = piggyBank;
      showFlashcard = true;
    });

    // Salvar no Firestore
    _savePiggyBank(piggyBank);

    // Auto-hide flashcard after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          showFlashcard = false;
        });
      }
    });
  }

  void _onPiggyBankTap(PiggyBank piggyBank) {
    // Se o porquinho está inativo, mostra diálogo de reativação
    if (!piggyBank.isActive) {
      _showReactivateDialog(piggyBank);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PiggyBankDetailsScreen(
          piggyBank: piggyBank,
          onUpdate: (updatedPiggyBank) {
            setState(() {
              final index = piggyBanks.indexWhere((p) => p.id == piggyBank.id);
              if (index != -1) {
                piggyBanks[index] = updatedPiggyBank;
              }
            });
            // Atualizar no Firestore
            _updatePiggyBank(updatedPiggyBank);
          },
          onDelete: () {
            setState(() {
              piggyBanks.remove(piggyBank);
            });
            // Deletar do Firestore
            _deletePiggyBank(piggyBank);
          },
          onGiveUp: () {
            setState(() {
              piggyBank.isActive = false;
            });
            // Atualizar no Firestore
            _updatePiggyBank(piggyBank);
          },
        ),
      ),
    );
  }

  void _showReactivateDialog(PiggyBank piggyBank) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Porquinho Inativo',
          style: TextStyle(
            color: Color(0xFF2EBBC7),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'O porquinho "${piggyBank.name}" está inativo. Deseja reativá-lo para continuar guardando dinheiro?',
          style: const TextStyle(fontSize: 16),
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
                piggyBank.isActive = true;
              });
              // Atualizar no Firestore
              _updatePiggyBank(piggyBank);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Porquinho "${piggyBank.name}" reativado com sucesso!',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2EBBC7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reativar',
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF10a5c6), Color(0xFF10a5c6)],
              ),
            ),
            child: Column(
              children: [
                // Header com botão voltar e título
                Padding(
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: 16,
                    right: 16,
                    bottom: 20,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Ícone do porquinho
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.savings,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'GUARDAR NO\nCOFRINHO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Círculo com valor
                Container(
  width: 220,
  height: 220,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF4DD5C7), Color(0xFF2EBBC7)],
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF1A9BA5).withOpacity(0.4),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: Container(
    margin: const EdgeInsets.all(12),
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xFF2EBBC7),
    ),
    child: Center(
      child: _isLoading
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : Text(
              totalSaved == 0
                  ? 'R\$0,00'
                  : 'R\$${totalSaved.toStringAsFixed(2).replaceAll(".", ",")}',
              style: TextStyle(
                color: Colors.white,
                fontSize: totalSaved >= 10000 ? 28 : 32,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
    ),
  ),
),

                const SizedBox(height: 50),

                // Botão Guardar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: () {
                      // Implementar funcionalidade de guardar dinheiro rapidamente
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Selecione um porquinho para guardar dinheiro',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF10a5c6),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10a5c6),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10a5c6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '+ Guardar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Seção inferior branca
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF10a5c6),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Criar Porquinho
                                  _buildMenuItem(
                                    icon: Icons.savings,
                                    text: 'Criar Porquinho',
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreatePiggyBankScreen(),
                                        ),
                                      );
                                      if (result != null && result is PiggyBank) {
                                        _onPiggyBankCreated(result);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Lista de porquinhos criados
                                  if (piggyBanks.isNotEmpty) ...[
                                    const SizedBox(height: 30),
                                    Container(
                                      height: 1,
                                      color: Colors.grey[300],
                                      margin:
                                          const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    const Text(
                                      'Meus Porquinhos Criados',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF10a5c6),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ...piggyBanks.map((piggyBank) => Column(
                                          children: [
                                            _buildPiggyBankItem(piggyBank),
                                            const SizedBox(height: 16),
                                          ],
                                        )),
                                  ],
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Flashcard de confirmação
          if (showFlashcard && latestPiggyBank != null)
            Positioned(
              top: 120,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: showFlashcard ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 28,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showFlashcard = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Porquinho Criado com Sucesso!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nome: ${latestPiggyBank!.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF10a5c6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Criado em: ${latestPiggyBank!.createdAt.day.toString().padLeft(2, '0')}/${latestPiggyBank!.createdAt.month.toString().padLeft(2, '0')}/${latestPiggyBank!.createdAt.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPiggyBankItem(PiggyBank piggyBank) {
    return GestureDetector(
      onTap: () => _onPiggyBankTap(piggyBank),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: piggyBank.isActive
                ? const Color(0xFF2EBBC7)
                : Colors.grey.shade400,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: piggyBank.isActive
                  ? const Color(0xFF2EBBC7).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: piggyBank.isActive
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4DD5C7), Color(0xFF2EBBC7)],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey.shade400, Colors.grey.shade500],
                      ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: piggyBank.isActive
                        ? const Color(0xFF2EBBC7).withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.savings,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          piggyBank.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: piggyBank.isActive
                                ? const Color(0xFF2C2C2C)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: piggyBank.isActive
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          piggyBank.isActive ? 'Ativo' : 'Inativo',
                          style: TextStyle(
                            fontSize: 12,
                            color: piggyBank.isActive
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'R\$ ${piggyBank.savedAmount.toStringAsFixed(2).replaceAll(".", ",")}',
                    style: TextStyle(
                      fontSize: 15,
                      color: piggyBank.isActive
                          ? const Color(0xFF2EBBC7)
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Criado em ${piggyBank.createdAt.day.toString().padLeft(2, '0')}/${piggyBank.createdAt.month.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: piggyBank.isActive
                    ? const Color(0xFF2EBBC7).withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                piggyBank.isActive ? Icons.arrow_forward_ios : Icons.lock,
                color: piggyBank.isActive
                    ? const Color(0xFF2EBBC7)
                    : Colors.grey.shade500,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2EBBC7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}