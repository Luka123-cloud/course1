import 'package:app/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:app/screens/home/views/home_screen.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          // ignore: deprecated_member_use
          background: Colors.grey.shade100,
          onBackground: Colors.black,
          primary: const Color(0xFF461111),
          secondary: const Color(0xFFA13333),
          tertiary: const Color(0xFFB3541E),
          outline: Colors.grey,
        )
      ),
      home: BlocProvider(
        create: (context) => GetExpensesBloc(
          FirebaseExpenseRepo()
        )..add(GetExpenses()),
        child: const HomeScreen(),
      ),
    );
  }
}