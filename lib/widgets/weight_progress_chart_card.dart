import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeightProgressChartCard extends StatelessWidget {
  const WeightProgressChartCard({
    super.key,
    required this.hasEntries,
    required this.chartDates,
    required this.chartSpots,
    required this.chartMinY,
    required this.chartMaxY,
    required this.isCurved,
  });

  final bool hasEntries;
  final List<String> chartDates;
  final List<FlSpot> chartSpots;
  final double chartMinY;
  final double chartMaxY;
  final bool isCurved;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.analytics_rounded, color: Color(0xFF35E0A1), size: 40),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: hasEntries
                ? LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 10,
                            reservedSize: 34,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();

                              if (index < 0 || index >= chartDates.length) {
                                return const SizedBox();
                              }

                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Transform.rotate(
                                  angle: -0.4,
                                  child: Text(
                                    chartDates[index],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      minX: 0,
                      maxX: (chartDates.length - 1).toDouble(),
                      minY: chartMinY,
                      maxY: chartMaxY == chartMinY ? chartMinY + 10 : chartMaxY,
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: isCurved,
                          color: const Color(0xFF35E0A1),
                          barWidth: 4,
                          dotData: FlDotData(show: true),
                          spots: chartSpots,
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Text(
                        'No entries yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
