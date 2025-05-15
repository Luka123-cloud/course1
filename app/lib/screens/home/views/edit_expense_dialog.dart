import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditExpenseDialog extends StatefulWidget {
  final Expense expense;

  const EditExpenseDialog({Key? key, required this.expense}) : super(key: key);

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
    _selectedDate = widget.expense.date;
    _selectedCategory = widget.expense.category;
  }

  void _pickDate() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Expense'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Amount
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),

            // Date picker
            Row(
              children: [
                const Text('Date: '),
                Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Category dropdown
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: Category.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final newAmount = double.tryParse(_amountController.text);
            if (newAmount == null) return;

            final updated = widget.expense.copyWith(
              amount: newAmount,
              date: _selectedDate,
              category: _selectedCategory,
            );

            Navigator.pop(context, updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
