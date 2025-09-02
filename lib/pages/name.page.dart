import 'dart:collection';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class NamePage extends StatelessWidget {
  const NamePage(this.name, {super.key});

  final Name name;

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: name.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Header
          LetterBackground(
            letter: name.name,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: GenderIcon(
                name.gender,
                iconSize: 50,
              ),
            ),
          ),

          // Name
          AppResources.spacerLarge,
          Text(
            name.name,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          // Saint
          if (name.isSaint) ...[
            AppResources.spacerLarge,
            const Text(
              'Ce prénom est un prénom de saint 😇',
              textAlign: TextAlign.center,
            ),
            Text(
              'Fête le ${name.saintDates!.map((e) => e.toDateString()).join(', ')}.',
              textAlign: TextAlign.center,
            ),
          ],

          // Stats
          AppResources.spacerLarge,
          Text(
            'Ce prénom a été donné ${name.totalCount} fois en France depuis 1900',
            textAlign: TextAlign.center,
          ),

          // Chart
          AppResources.spacerLarge,
          Text(
            'Répartition par année',
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          AppResources.spacerSmall,
          AspectRatio(
            aspectRatio: 1.70,
            child: LineChart(
              mainData(),   // TODO Optimise this (build only once)
            ),
          ),

        ],
      ),
    );
  }

  LineChartData mainData() {
    const gradientColors = [
      Colors.cyan,
      Colors.blue,
    ];

    final countByYear = SplayTreeMap.from(name.countByYear.map((key, value) => MapEntry(int.parse(key), value))..remove(0));

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
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
            interval: 20,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        /*leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            //interval: 10,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),*/
      ),
      borderData: FlBorderData(
        border: Border.all(color: const Color(0xff37434d)),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final year = touchedSpot.x.toInt();
              final count = touchedSpot.y.toInt();
              return LineTooltipItem(
                '$year : $count',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: countByYear.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
          //isCurved: true,
          gradient: const LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        value.round().toString(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return Text(
      value.round().toString(),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      textAlign: TextAlign.left,
    );
  }
}
