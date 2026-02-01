import 'package:flutter/material.dart';

// Reutilizando a paleta de cores Cash
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

class IncomeRegistrationScreen extends StatefulWidget {
  const IncomeRegistrationScreen({super.key});

  @override
  State<IncomeRegistrationScreen> createState() => _IncomeRegistrationScreenState();
}

class _IncomeRegistrationScreenState extends State<IncomeRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  String selectedCategory = 'Fixa';
  late int selectedDay;
  late String selectedMonth;
  late int selectedYear;

  final List<String> months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa com a data atual
    final now = DateTime.now();
    selectedDay = now.day;
    selectedMonth = months[now.month - 1];
    selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashColors.background,
      appBar: AppBar(
        backgroundColor: CashColors.success,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: const [
            Icon(Icons.attach_money, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'REGISTRO DE RECEITA',
              style: TextStyle(
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
            // Nome da Receita
            const Text(
              'Digite o nome da receita',
              style: TextStyle(
                color: CashColors.success,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: _boxDecoration(),
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

            // Categoria
            const Text(
              'Selecione o tipo de receita',
              style: TextStyle(
                color: CashColors.success,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text(
                      'Fixa',
                      style: TextStyle(fontSize: 16, fontFamily: 'DMSans'),
                    ),
                    value: 'Fixa',
                    groupValue: selectedCategory,
                    activeColor: CashColors.success,
                    onChanged: (value) => setState(() => selectedCategory = value!),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  RadioListTile<String>(
                    title: const Text(
                      'Variável',
                      style: TextStyle(fontSize: 16, fontFamily: 'DMSans'),
                    ),
                    value: 'Variável',
                    groupValue: selectedCategory,
                    activeColor: CashColors.success,
                    onChanged: (value) => setState(() => selectedCategory = value!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Valor
            const Text(
              'Valor recebido',
              style: TextStyle(
                color: CashColors.success,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: _boxDecoration(),
              child: TextField(
                controller: _valueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              ),
            ),

            const SizedBox(height: 30),

            // Data
            const Text(
              'Data do recebimento',
              style: TextStyle(
                color: CashColors.success,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Dia
                Expanded(
                  child: Container(
                    decoration: _boxDecoration(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedDay,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: CashColors.success),
                        onChanged: (value) => setState(() => selectedDay = value!),
                        items: List.generate(31, (i) => i + 1)
                            .map((day) => DropdownMenuItem(
                                  value: day,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      day.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'DMSans',
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Mês
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: _boxDecoration(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: CashColors.success),
                        onChanged: (value) => setState(() => selectedMonth = value!),
                        items: months
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      m,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'DMSans',
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ano
            Container(
              decoration: _boxDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedYear,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: CashColors.success),
                  onChanged: (value) => setState(() => selectedYear = value!),
                  items: List.generate(10, (i) => DateTime.now().year - 5 + i)
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                year.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'DMSans',
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),

            const Spacer(),

            // Botão Adicionar Receita
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _addIncome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CashColors.success,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ADICIONAR RECEITA',
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

  // Função auxiliar de estilo
  BoxDecoration _boxDecoration() => BoxDecoration(
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
      );

  void _addIncome() {
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

    final incomeData = {
      'name': _nameController.text,
      'category': selectedCategory,
      'value': value,
      'day': selectedDay,
      'month': selectedMonth,
      'year': selectedYear,
    };

    Navigator.of(context).pop(incomeData);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}