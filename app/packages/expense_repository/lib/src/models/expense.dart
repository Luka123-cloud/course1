import 'package:expense_repository/expense_repository.dart';

class Expense {
  String expenseId;
  Category category;
  DateTime date;
  double amount;

  Expense({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
  });

  // Пустой экземпляр для дефолтных значений
  static final empty = Expense(
    expenseId: '',
    category: Category.empty,
    date: DateTime.now(),
    amount: 0.0,
  );

  // Преобразование в сущность, где amount - целое число
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      expenseId: expenseId,
      category: category,
      date: date,
      amount: amount.toInt(),  // Преобразуем amount в int
    );
  }

  // Преобразование из сущности в Expense
  static Expense fromEntity(ExpenseEntity entity) {
    return Expense(
      expenseId: entity.expenseId,
      category: entity.category,
      date: entity.date,
      amount: entity.amount.toDouble(),  // Преобразуем обратно в double
    );
  }

  // Копирование объекта с возможностью изменения некоторых полей
  Expense copyWith({
    String? expenseId,
    Category? category,
    DateTime? date,
    double? amount,  // Используем double, так как это тип поля amount
  }) {
    return Expense(
      expenseId: expenseId ?? this.expenseId,
      category: category ?? this.category,
      date: date ?? this.date,
      amount: amount ?? this.amount,  // amount уже double, не требуется преобразования
    );
  }
}
