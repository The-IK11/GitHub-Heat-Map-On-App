import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GithubHoverHeatmap extends StatelessWidget {
  final Map<DateTime, int> data;
  final DateTime startDate;

  const GithubHoverHeatmap({
    super.key,
    required this.data,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(365, (i) {
      final date = startDate.add(Duration(days: i));
      return DateTime(date.year, date.month, date.day);
    });

    return SizedBox(
      height: 140,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final count = data[day] ?? 0;

          return Tooltip(
            message:
                '$count contributions on ${DateFormat.yMMMd().format(day)}',
            waitDuration: const Duration(milliseconds: 200),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: githubGreen(count),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        },
      ),
    );
  }
}
Color githubGreen(int count) {
  if (count == 0) return const Color(0xff161b22);
  if (count < 3) return const Color(0xff0e4429);
  if (count < 6) return const Color(0xff006d32);
  if (count < 10) return const Color(0xff26a641);
  return const Color(0xff39d353);
}
