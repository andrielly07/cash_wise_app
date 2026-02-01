import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  String selectedPeriod = 'Últimos 6 meses';
  bool _isLoading = true;
  List<TransactionReport> transactions = [];
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      print('🔵 Carregando transações para o relatório...');

      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.uid)
          .collection('transaction')
          .orderBy('date', descending: false)
          .get();

      List<TransactionReport> loadedTransactions = [];
      for (var doc in snapshot.docs) {
        loadedTransactions.add(TransactionReport.fromMap(doc.data()));
      }

      setState(() {
        transactions = loadedTransactions;
        _isLoading = false;
      });

      print('✅ ${loadedTransactions.length} transações carregadas para o relatório');
    } catch (e) {
      print('❌ Erro ao carregar transações: $e');
      setState(() => _isLoading = false);
    }
  }

  List<TransactionReport> get filteredTransactions {
    final now = DateTime.now();
    int monthsToSubtract;
    
    switch (selectedPeriod) {
      case 'Últimos 3 meses':
        monthsToSubtract = 3;
        break;
      case 'Últimos 6 meses':
        monthsToSubtract = 6;
        break;
      case 'Último ano':
        monthsToSubtract = 12;
        break;
      default:
        monthsToSubtract = 6;
    }
    
    final cutoffDate = DateTime(now.year, now.month - monthsToSubtract, now.day);
    return transactions.where((t) => t.date.isAfter(cutoffDate)).toList();
  }

  List<MonthData> get monthlyData {
    Map<String, MonthData> monthMap = {};
    
    for (var transaction in filteredTransactions) {
      final monthKey = '${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}';
      final monthName = _getMonthAbbreviation(transaction.date.month);
      
      if (!monthMap.containsKey(monthKey)) {
        monthMap[monthKey] = MonthData(monthName, 0, 0);
      }
      
      if (transaction.type == TransactionTypeReport.income) {
        monthMap[monthKey]!.income += transaction.amount;
      } else {
        monthMap[monthKey]!.expense += transaction.amount;
      }
    }
    
    return monthMap.values.toList();
  }

  List<CategoryExpense> get topExpenses {
    Map<String, CategoryExpense> categoryMap = {};
    
    for (var transaction in filteredTransactions) {
      if (transaction.type != TransactionTypeReport.income) {
        if (categoryMap.containsKey(transaction.category)) {
          categoryMap[transaction.category]!.amount += transaction.amount;
        } else {
          categoryMap[transaction.category] = CategoryExpense(
            transaction.category,
            transaction.amount,
            _getCategoryIcon(transaction.category),
            transaction.color,
          );
        }
      }
    }
    
    List<CategoryExpense> sorted = categoryMap.values.toList();
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(5).toList();
  }

  double get totalIncome => filteredTransactions
      .where((t) => t.type == TransactionTypeReport.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => filteredTransactions
      .where((t) => t.type != TransactionTypeReport.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;
  
  double get savingsRate => totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome) * 100 : 0;

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return months[month - 1];
  }

  IconData _getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('alimentação') || categoryLower.contains('comida') || categoryLower.contains('restaurante')) {
      return Icons.restaurant;
    } else if (categoryLower.contains('transporte') || categoryLower.contains('uber') || categoryLower.contains('gasolina')) {
      return Icons.directions_car;
    } else if (categoryLower.contains('lazer') || categoryLower.contains('entretenimento') || categoryLower.contains('cinema')) {
      return Icons.movie;
    } else if (categoryLower.contains('conta') || categoryLower.contains('água') || categoryLower.contains('luz')) {
      return Icons.receipt;
    } else if (categoryLower.contains('saúde') || categoryLower.contains('médico') || categoryLower.contains('farmácia')) {
      return Icons.local_hospital;
    } else if (categoryLower.contains('educação') || categoryLower.contains('curso') || categoryLower.contains('livro')) {
      return Icons.school;
    } else if (categoryLower.contains('casa') || categoryLower.contains('aluguel') || categoryLower.contains('moradia')) {
      return Icons.home;
    }
    return Icons.shopping_bag;
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Color(0xFF10a5c6),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Relatório Financeiro',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF10a5c6)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF10a5c6),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Relatório Financeiro',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadTransactions();
            },
          ),
        ],
      ),
      body: filteredTransactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma transação encontrada',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adicione transações para ver o relatório',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header com resumo
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10a5c6), Color(0xFF0d8aa3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Saldo do Período',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _formatCurrency(balance),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSummaryCard(
                              'Receitas',
                              _formatCurrency(totalIncome),
                              Icons.arrow_upward,
                              Colors.green,
                            ),
                            _buildSummaryCard(
                              'Despesas',
                              _formatCurrency(totalExpense),
                              Icons.arrow_downward,
                              Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Filtro de período
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFF10a5c6), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Período:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedPeriod,
                                isExpanded: true,
                                items: [
                                  'Últimos 3 meses',
                                  'Últimos 6 meses',
                                  'Último ano',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedPeriod = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Gráfico de barras
                  if (monthlyData.isNotEmpty)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receitas vs Despesas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 250,
                            child: _buildSimpleBarChart(),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegend(Colors.green, 'Receitas'),
                              SizedBox(width: 20),
                              _buildLegend(Colors.red, 'Despesas'),
                            ],
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 20),

                  // Taxa de economia
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: savingsRate >= 0 
                            ? [Colors.green[400]!, Colors.green[600]!]
                            : [Colors.red[400]!, Colors.red[600]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (savingsRate >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            savingsRate >= 0 ? Icons.savings : Icons.warning,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                savingsRate >= 0 ? 'Taxa de Economia' : 'Deficit',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${savingsRate.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          savingsRate >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: Colors.white,
                          size: 32,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Maiores despesas
                  if (topExpenses.isNotEmpty)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_down, color: Colors.red, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Maiores Despesas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ...topExpenses.map((expense) => _buildExpenseItem(expense)),
                        ],
                      ),
                    ),

                  SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSimpleBarChart() {
    if (monthlyData.isEmpty) return Container();
    
    double maxValue = monthlyData.map((e) => e.income > e.expense ? e.income : e.expense).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 1;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: monthlyData.map((data) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: (data.income / maxValue) * 180,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 16,
                      height: (data.expense / maxValue) * 180,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  data.month,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem(CategoryExpense expense) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: expense.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(expense.icon, color: expense.color, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              expense.category,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            _formatCurrency(expense.amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

// Classes auxiliares
enum TransactionTypeReport { income, expense, fixedExpense }

class TransactionReport {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final TransactionTypeReport type;
  final Color color;

  TransactionReport({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.color,
  });

  factory TransactionReport.fromMap(Map<String, dynamic> map) {
    TransactionTypeReport type;
    Color color;

    final typeString = map['type'] as String;
    switch (typeString) {
      case 'income':
        type = TransactionTypeReport.income;
        color = Colors.green;
        break;
      case 'expense':
        type = TransactionTypeReport.expense;
        color = Colors.red;
        break;
      case 'fixedExpense':
        type = TransactionTypeReport.fixedExpense;
        color = Color(0xFF1032C7);
        break;
      default:
        type = TransactionTypeReport.expense;
        color = Colors.red;
    }

    return TransactionReport(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      type: type,
      color: color,
    );
  }
}

class MonthData {
  final String month;
  double income;
  double expense;

  MonthData(this.month, this.income, this.expense);
}

class CategoryExpense {
  final String category;
  double amount;
  final IconData icon;
  final Color color;

  CategoryExpense(this.category, this.amount, this.icon, this.color);
}