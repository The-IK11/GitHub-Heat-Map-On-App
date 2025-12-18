import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:github_heat_map/data/api.dart';

class GithubWrapedScreen extends StatelessWidget {
  final String username;
  final Map<DateTime, int> heatmapData;
  final ApiService apiService;

  const GithubWrapedScreen({
    super.key,
    required this.username,
    required this.heatmapData,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('GitHub Summary - $username', style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top heatmap card
              Container(
            //    height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.grey.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Heatmap preview with proper coloring
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: HeatMap(
                        startDate: DateTime.now().subtract(const Duration(days: 365)),
                        endDate: DateTime.now(),
                        datasets: heatmapData,
                        colorMode: ColorMode.color,
                        defaultColor: Colors.grey.shade800,
                        textColor: Colors.white,
                        showText: false,
                        scrollable: true,
                        size: 15,
                        colorsets: const {
                          1: Color(0xff9be9a8),
                          3: Color(0xff40c463),
                          6: Color(0xff30a14e),
                          10: Color(0xff216e39),
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stats on the right
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${heatmapData.values.fold<int>(0, (sum, count) => sum + count)} contributions in 2025',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        // const SizedBox(height: 12),
                        // ElevatedButton.icon(
                        //   onPressed: () {},
                        //   icon: const Icon(Icons.share),
                        //   label: const Text('Share'),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.teal.shade700,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //   ),
                        // ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Grid of small stat cards (2 columns)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _statCards(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _statCards(BuildContext context) {
    // Calculate metrics from heatmap data
    final totalCommits = heatmapData.values.fold<int>(0, (sum, count) => sum + count);
    final longestStreak = _calculateLongestStreak();
    final mostActiveMonth = _getMostActiveMonth();
    final mostActiveDay = _getMostActiveDay();
    final universalRank = _calculateUniversalRank(totalCommits);
    final powerLevel = _calculatePowerLevel(totalCommits, longestStreak);

    final items = <_StatItem>[
      _StatItem('Universal Rank', universalRank, Icons.emoji_events, Colors.deepPurple),
      _StatItem('Longest Streak', '$longestStreak days', Icons.bolt, Colors.cyan),
      _StatItem('Total Commits', '$totalCommits', Icons.commit, Colors.pink),
      _StatItem('Most Active Month', mostActiveMonth, Icons.calendar_month, Colors.deepOrange),
      _StatItem('Most Active Day', mostActiveDay, Icons.calendar_today, Colors.indigo),
      _StatItem('Power Level', powerLevel, Icons.whatshot, Colors.brown),
    ];

    final cardWidth = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2 - 6;

    final List<Widget> cards = items.map((i) => SizedBox(
      width: cardWidth,
      child: _StatCard(item: i),
    )).toList();

    // Add Total Stars card as FutureBuilder
    cards.insert(5, SizedBox(
      width: cardWidth,
      child: FutureBuilder<int>(
        future: apiService.fetchTotalStars(username),
        builder: (context, snapshot) {
          String displayValue = 'Loading...';
          if (snapshot.hasData) {
            displayValue = '⭐ ${snapshot.data}';
          } else if (snapshot.hasError) {
            displayValue = 'Error';
          }
          
          return _StatCard(
            item: _StatItem('Total Stars', displayValue, Icons.star, Colors.amber),
          );
        },
      ),
    ));

    // Add Top Language card as FutureBuilder
    cards.insert(6, SizedBox(
      width: cardWidth,
      child: FutureBuilder<String?>(
        future: apiService.fetchTopLanguage(username),
        builder: (context, snapshot) {
          String displayValue = 'Loading...';
          if (snapshot.hasData) {
            displayValue = snapshot.data ?? 'N/A';
          } else if (snapshot.hasError) {
            displayValue = 'Error';
          }
          
          return _StatCard(
            item: _StatItem('Top Language', displayValue, Icons.code, Colors.green),
          );
        },
      ),
    ));

    return cards;
  }

  // Calculate longest consecutive contribution streak
  int _calculateLongestStreak() {
    if (heatmapData.isEmpty) return 0;

    final sortedDates = heatmapData.keys.toList()..sort();
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final date in sortedDates) {
      if (heatmapData[date]! > 0) {
        if (lastDate == null || date.difference(lastDate).inDays == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      }
      lastDate = date;
    }

    return maxStreak;
  }

  // Get the month with most commits
  String _getMostActiveMonth() {
    if (heatmapData.isEmpty) return 'N/A';

    final monthCounts = <String, int>{};
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (final entry in heatmapData.entries) {
      final month = months[entry.key.month - 1];
      monthCounts[month] = (monthCounts[month] ?? 0) + entry.value;
    }

    var maxMonth = 'N/A';
    var maxCount = 0;
    monthCounts.forEach((month, count) {
      if (count > maxCount) {
        maxCount = count;
        maxMonth = month;
      }
    });

    return maxMonth;
  }

  // Get the day of week with most commits
  String _getMostActiveDay() {
    if (heatmapData.isEmpty) return 'N/A';

    final dayCounts = <String, int>{};
    const daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (final entry in heatmapData.entries) {
      final dayOfWeek = daysOfWeek[entry.key.weekday - 1];
      dayCounts[dayOfWeek] = (dayCounts[dayOfWeek] ?? 0) + entry.value;
    }

    var maxDay = 'N/A';
    var maxCount = 0;
    dayCounts.forEach((day, count) {
      if (count > maxCount) {
        maxCount = count;
        maxDay = day;
      }
    });

    return maxDay;
  }

  // Calculate universal rank based on total commits
  String _calculateUniversalRank(int totalCommits) {
    if (totalCommits < 50) return 'Beginner';
    if (totalCommits < 100) return 'Novice';
    if (totalCommits < 300) return 'Top 25%';
    if (totalCommits < 600) return 'Top 10%';
    if (totalCommits < 1000) return 'Top 5%';
    return 'Elite';
  }

  // Calculate power level based on contributions and streak
  String _calculatePowerLevel(int totalCommits, int longestStreak) {
    final score = totalCommits + (longestStreak * 5);

    if (score < 100) return 'Padawan';
    if (score < 250) return 'Jedi';
    if (score < 500) return 'Jedi Master';
    if (score < 1000) return 'Sith Lord';
    return 'Ninja';
  }
}

class _HeatmapDisplay extends StatelessWidget {
  final Map<DateTime, int> heatmapData;

  const _HeatmapDisplay({required this.heatmapData});

  @override
  Widget build(BuildContext context) {
    if (heatmapData.isEmpty) {
      return const Center(
        child: Text(
          'No contribution data available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Simple grid of colored squares to mimic heatmap
    return LayoutBuilder(builder: (context, constraints) {
      final cols = 20;
      final rows = 5;
      final gap = 4.0;
      final cellSize = (constraints.maxWidth - (cols - 1) * gap) / cols;

      // Get sorted dates to display
      final sortedDates = heatmapData.keys.toList()..sort();

      return Column(
        children: List.generate(rows, (r) {
          return Padding(
            padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : gap),
            child: Row(
              children: List.generate(cols, (c) {
                final index = r * cols + c;
                final color = index < sortedDates.length
                    ? _getColorForContributions(heatmapData[sortedDates[index]] ?? 0)
                    : Colors.transparent;

                return Padding(
                  padding: EdgeInsets.only(right: c == cols - 1 ? 0 : gap),
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      );
    });
  }

  Color _getColorForContributions(int count) {
    if (count == 0) return Colors.grey.shade900;
    if (count < 5) return Colors.green.shade900;
    if (count < 15) return Colors.green.shade700;
    if (count < 30) return Colors.green.shade500;
    return Colors.green.shade300;
  }
}


class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem(this.title, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
    colors: [item.color.withAlpha(46), item.color.withAlpha(15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
  border: Border.all(color: item.color.withAlpha(30)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
              decoration: BoxDecoration(
              color: item.color.withAlpha(46),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: item.color.withAlpha(20),
                  blurRadius: 8,
                )
              ],
            ),
            child: Icon(item.icon, color: item.color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
