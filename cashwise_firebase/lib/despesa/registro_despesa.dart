import 'package:flutter/material.dart';

// Paleta de cores Cash (diretamente no arquivo)
class CashColors {
  static const Color primary = Color(0xFF10a5c6);
  static const Color secondary1 = Color(0xFF106cc7);
  static const Color secondary2 = Color(0xFF10C7AD);
  static const Color secondary3 = Color(0xFF10C76F);
  static const Color secondary4 = Color(0xFF1032C7);
  static const Color secondary5 = Color(0xFF52B2C7);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF666666);
  static const Color success = Color(0xFF10C76F);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
}

class ExpenseRegistrationScreen extends StatefulWidget {
  final bool isIncome; // 🆕 NOVO: Parâmetro para identificar se é receita
  
  const ExpenseRegistrationScreen({
    super.key,
    this.isIncome = false, // 🆕 Por padrão é despesa
  });

  @override
  State<ExpenseRegistrationScreen> createState() => _ExpenseRegistrationScreenState();
}

class _ExpenseRegistrationScreenState extends State<ExpenseRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  
  String selectedCategory = 'Variável';
  int selectedDay = 6;
  String selectedMonth = 'Janeiro';
  int selectedYear = 2025;
  
  final List<String> months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  @override
  void initState() {
    super.initState();
    _nameController.text = '';
    _valueController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashColors.background,
      appBar: AppBar(
        backgroundColor: CashColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined, // ← SEMPRE O MESMO ÍCONE
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              widget.isIncome ? 'REGISTRO DE RECEITA' : 'REGISTRO DE DESPESA', // 🆕 Título muda
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.2,
                fontFamily: 'DMSans',
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo Nome
            const Text(
              'Digite o nome',
              style: TextStyle(
                color: CashColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: CashColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CashColors.textPrimary,
                  fontFamily: 'DMSans',
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 🆕 Categoria APENAS para despesas (esconde para receitas)
            if (!widget.isIncome) ...[
              const Text(
                'Selecione a categoria',
                style: TextStyle(
                  color: CashColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'DMSans',
                ),
              ),
              const SizedBox(height: 12),
              
              // Radio buttons para categoria
              Container(
                decoration: BoxDecoration(
                  color: CashColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text(
                        'Fixa', 
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'DMSans',
                        ),
                      ),
                      value: 'Fixa',
                      groupValue: selectedCategory,
                      activeColor: CashColors.primary,
                      onChanged: (String? value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    Divider(height: 1, color: Colors.grey[300]),
                    RadioListTile<String>(
                      title: const Text(
                        'Variável', 
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'DMSans',
                        ),
                      ),
                      value: 'Variável',
                      groupValue: selectedCategory,
                      activeColor: CashColors.primary,
                      onChanged: (String? value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
            
            // Valor
            const Text(
              'Valor',
              style: TextStyle(
                color: CashColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: CashColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _valueController,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CashColors.textPrimary,
                  fontFamily: 'DMSans',
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  prefixText: 'R\$ ',
                  prefixStyle: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CashColors.textPrimary,
                    fontFamily: 'DMSans',
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Data
            const Text(
              'Data',
              style: TextStyle(
                color: CashColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 12),
            
            // Seletores de data
            Row(
              children: [
                // Dia
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: CashColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedDay,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: CashColors.primary),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedDay = newValue!;
                          });
                        },
                        items: List.generate(31, (index) => index + 1)
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                value.toString(),
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'DMSans',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Mês
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CashColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: CashColors.primary),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMonth = newValue!;
                          });
                        },
                        items: months.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'DMSans',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Ano
            Container(
              decoration: BoxDecoration(
                color: CashColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedYear,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: CashColors.primary),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedYear = newValue!;
                    });
                  },
                  items: List.generate(10, (index) => DateTime.now().year - 5 + index)
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w500,
                            fontFamily: 'DMSans',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Botão Adicionar
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  _addExpense();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CashColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ADICIONAR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'DMSans',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  void _addExpense() {
    // Validação básica
    if (_nameController.text.isEmpty || _valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, preencha todos os campos!',
            style: TextStyle(fontFamily: 'DMSans'),
          ),
          backgroundColor: CashColors.error,
        ),
      );
      return;
    }
    
    // Converte o valor de String para double
    final valueString = _valueController.text.replaceAll(',', '.');
    final value = double.tryParse(valueString);
    
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, insira um valor válido!',
            style: TextStyle(fontFamily: 'DMSans'),
          ),
          backgroundColor: CashColors.error,
        ),
      );
      return;
    }
    
    // Cria o objeto de despesa/receita para retornar
    final expenseData = {
      'name': _nameController.text,
      'category': widget.isIncome ? 'Receita' : selectedCategory, // 🆕 Se for receita, categoria é 'Receita'
      'value': value,
      'day': selectedDay,
      'month': selectedMonth,
      'year': selectedYear,
    };
    
    // Retorna os dados para a tela anterior
    Navigator.of(context).pop(expenseData);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}