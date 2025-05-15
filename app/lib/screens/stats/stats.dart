import 'package:flutter/material.dart';
import 'chart.dart';

class StatScreen extends StatelessWidget {
  const StatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder( // Используем LayoutBuilder для получения контекста
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth, // Используем максимальную доступную ширину
                  height: constraints.maxWidth, // Квадратный контейнер
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(12, 20, 12, 12),
                    child: MyChart(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}