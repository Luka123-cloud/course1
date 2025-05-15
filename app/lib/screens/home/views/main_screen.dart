import 'dart:math';
import 'package:app/screens/home/views/edit_expense_dialog.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final List<Expense> expenses;
  const MainScreen(this.expenses, {super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double balance = 0;
  double income = 0;

  double get totalExpenses =>
      widget.expenses.fold(0, (sum, e) => sum + e.amount);

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('balance') ?? 0.0;
      income = prefs.getDouble('income') ?? 0.0;
    });
  }

  Future<void> _saveValue(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  void _showEditDialog({
    required String title,
    required double initialValue,
    required String prefsKey,
    required void Function(double) onSaved,
  }) {
    final controller = TextEditingController(text: initialValue.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: '0.00'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final input = double.tryParse(controller.text);
              if (input != null) {
                _saveValue(prefsKey, input);
                onSaved(input);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editBalance() {
    _showEditDialog(
      title: 'Enter your balance',
      initialValue: balance,
      prefsKey: 'balance',
      onSaved: (v) => setState(() => balance = v),
    );
  }

  void _editIncome() {
    _showEditDialog(
      title: 'Enter your income',
      initialValue: income,
      prefsKey: 'income',
      onSaved: (v) => setState(() => income = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = balance - totalExpenses + income;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          children: [
            // — Header —
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.yellow[700]),
                        ),
                        Icon(CupertinoIcons.person_fill, color: Colors.yellow[800]),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome!",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        Text(
                          "Albert",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.settings,)),
              ],
            ),
            const SizedBox(height: 20),

            // — Balance Card (tap to edit) —
            GestureDetector(
              onTap: _editBalance,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                    transform: const GradientRotation(pi / 4),
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 4,
                        color: Color.fromARGB(255, 151, 149, 149),
                        offset: Offset(5, 5)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total balance',
                      style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₽ ${remaining.toStringAsFixed(2)}',
                      style: GoogleFonts.montserrat(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Income
                          GestureDetector(
                            onTap: _editIncome,
                            child: Row(
                              children: [
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: const BoxDecoration(
                                      color: Colors.white30, shape: BoxShape.circle),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.arrow_down,
                                      size: 12,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Income',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      '₽ ${income.toStringAsFixed(2)}',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // — Expenses (read-only) —
                          Row(
                            children: [
                              Container(
                                width: 25,
                                height: 25,
                                decoration: const BoxDecoration(
                                    color: Colors.white30, shape: BoxShape.circle),
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.arrow_down,
                                    size: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                    'Expenses',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    '₽ ${totalExpenses.toStringAsFixed(2)}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // — Transactions List —
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'View All',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.expenses.length,
                itemBuilder: (context, i) {
                  final e = widget.expenses[i];
                    return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Dismissible(
                      key: Key(e.expenseId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        setState(() => widget.expenses.removeAt(i));
                        await FirebaseExpenseRepo().deleteExpense(e.expenseId);
                      },
                      child: GestureDetector(
                        onTap: () async {
                          final updated = await showDialog<Expense>(
                            context: context,
                            builder: (_) => EditExpenseDialog(expense: e), 
                          );

                          if (updated != null) {
                            setState(() => widget.expenses[i] = updated);
                            await FirebaseExpenseRepo().updateExpense(updated);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Color(e.category.color),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/${e.category.icon}.png',
                                          scale: 2,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      e.category.name,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onBackground,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₽ ${e.amount.toStringAsFixed(2)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onBackground,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd.MM.yyyy').format(e.date),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.outline,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
