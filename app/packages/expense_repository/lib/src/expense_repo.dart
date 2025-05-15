import 'package:expense_repository/expense_repository.dart';

abstract class ExpenseRepository {

  Future<void> createCategory(Category category);

  Future<List<Category>> getCategory();

  Future<void> createExpense(Expense expense);
  
  Future<void> updateExpense(Expense expense)
  ;
  Future<void> deleteExpense(String expenseId);

  Future<List<Expense>> getExpenses();
}
