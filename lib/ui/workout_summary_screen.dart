import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../domain/workout_data_point.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final List<WorkoutDataPoint> workoutData;

  const WorkoutSummaryScreen({super.key, required this.workoutData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты тренировки'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'График сложности',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildChart(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    if (workoutData.isEmpty || workoutData.length < 2) {
      return const Center(
        child: Text('Недостаточно данных для построения графика.'),
      );
    }

    final List<FlSpot> spots = workoutData.map((point) {
      return FlSpot(
        point.timeSeconds.toDouble(),
        point.difficultyLevel.toDouble(),
      );
    }).toList();

    double maxX = workoutData.map((p) => p.timeSeconds.toDouble()).reduce(max);
    double maxY = workoutData
        .map((p) => p.difficultyLevel.toDouble())
        .reduce(max);
    maxY = (maxY < 5) ? 5 : maxY + 1;
    double minY = 0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: Colors.grey, strokeWidth: 0.5),
          getDrawingVerticalLine: (value) =>
              const FlLine(color: Colors.grey, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (maxX / 5).ceilToDouble() > 0
                  ? (maxX / 5).ceilToDouble()
                  : 1,
              getTitlesWidget: (value, meta) {
                final int minutes = value.toInt() ~/ 60;
                final int seconds = value.toInt() % 60;
                final String timeFormatted =
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                if (value == 0 ||
                    value == maxX ||
                    meta.appliedInterval == value) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.0,
                    child: Text(
                      timeFormatted,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            axisNameWidget: const Text('Время (ММ:СС)'),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value % 1 == 0 && value >= minY && value <= maxY) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.left,
                  );
                }
                return const Text('');
              },
            ),
            axisNameWidget: const Text('Сложность'),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black26, width: 1),
        ),
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final int minutes = flSpot.x.toInt() ~/ 60;
                final int seconds = flSpot.x.toInt() % 60;
                final String timeFormatted =
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                return LineTooltipItem(
                  'Время: $timeFormatted\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Сложность: ${flSpot.y.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                  textAlign: TextAlign.left,
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
