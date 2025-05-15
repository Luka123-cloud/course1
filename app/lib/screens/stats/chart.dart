import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyChart extends StatefulWidget {
  const MyChart({super.key});

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  List<double> _chartData = [];
  ChartStatus _status = ChartStatus.loading;

  @override
  void initState() {
    super.initState();
    _setupDataListener(); // убрана лишняя инициализация _dataStream
  }

  void _setupDataListener() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Понедельник
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    FirebaseFirestore.instance
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('date', isLessThan: Timestamp.fromDate(endOfWeek))
        .snapshots()
        .listen(
      (snapshot) {
        final Map<int, double> weeklyData = {for (var i = 0; i < 7; i++) i: 0};

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['date'] as Timestamp;
          final amount = (data['amount'] ?? 0).toDouble();

          final dayIndex = timestamp.toDate().weekday - 1; // 0 - понедельник, 6 - воскресенье
          if (dayIndex >= 0 && dayIndex <= 6) {
            weeklyData[dayIndex] = weeklyData[dayIndex]! + amount;
          }

          // Отладка
          print('amount: $amount, date: ${timestamp.toDate()}');
        }

        _updateChartData(List.generate(7, (index) => weeklyData[index]!));
      },
      onError: (_) => _handleError(),
    );
  }

  void _updateChartData(List<double> newData) {
    if (mounted) {
      setState(() {
        _chartData = newData;
        _status = ChartStatus.ready;
      });
    }
  }

  void _handleError() {
    if (mounted) {
      setState(() => _status = ChartStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      ChartStatus.loading => _buildLoadingState(),
      ChartStatus.error => _buildErrorState(),
      ChartStatus.ready => _buildChart(),
    };
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Ошибка загрузки данных'),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _setupDataListener,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return BarChart(
      _buildChartData(),
      swapAnimationDuration: const Duration(milliseconds: 300),
    );
  }

  BarChartData _buildChartData() {
    return BarChartData(
      barTouchData: BarTouchData(enabled: true),
      titlesData: _buildTitlesData(),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: _buildBarGroups(),
    );
  }

  FlTitlesData _buildTitlesData() {
  return FlTitlesData(
    show: true,
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 38,
        getTitlesWidget: _getBottomTitles,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 38,
        getTitlesWidget: _getLeftTitles,
        interval: 1000, // шаг между делениями: 1000 = 1K
      ),
    ),
  );
}


  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(
      _chartData.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: _chartData[index],
            width: 20,
            gradient: _buildGradient(),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 5,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _buildGradient() {
    return LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.secondary,
        Theme.of(context).colorScheme.tertiary,
      ],
      transform: const GradientRotation(pi / 40),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const days = ['Mn', 'Ts', 'Wd', 'Th', 'Fr', 'St', 'Sn'];
    final index = value.toInt();
    final style = TextStyle(color: Colors.grey, fontSize: 14);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(index >= 0 && index < 7 ? days[index] : '', style: style),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
  const style = TextStyle(color: Colors.grey, fontSize: 14);
  if (value % 1000 != 0) return const SizedBox(); // Показ только для кратных 1000
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text('${(value ~/ 1000)}K', style: style),
  );
}

}

enum ChartStatus { loading, ready, error }
