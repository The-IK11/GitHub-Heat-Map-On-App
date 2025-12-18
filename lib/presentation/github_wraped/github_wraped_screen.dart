import 'package:flutter/material.dart';

class GithubWrapedScreen extends StatelessWidget {
  const GithubWrapedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('GitHub Summary'),
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
                height: 200,
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
                    // Heatmap preview (placeholder grid of dots)
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Center(child: _HeatmapPlaceholder()),
                    ),
                    const SizedBox(height: 20),
                    // Stats on the right
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '627 contributions in 2025',
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
    final items = <_StatItem>[
      _StatItem('Universal Rank', 'Top 5%', Icons.emoji_events, Colors.deepPurple),
      _StatItem('Longest Streak', '18 days', Icons.bolt, Colors.cyan),
      _StatItem('Total Commits', '627', Icons.commit, Colors.pink),
      _StatItem('Most Active Month', 'May', Icons.calendar_month, Colors.deepOrange),
      _StatItem('Most Active Day', 'Thursday', Icons.calendar_today, Colors.indigo),
      _StatItem('Total Stars', '3', Icons.star, Colors.amber),
      _StatItem('Top Language', 'C', Icons.code, Colors.green),
      _StatItem('Power Level', 'Ninja', Icons.whatshot, Colors.brown),
    ];

    return items.map((i) => SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2 - 6,
      child: _StatCard(item: i),
    )).toList();
  }
}

class _HeatmapPlaceholder extends StatelessWidget {
  const _HeatmapPlaceholder();

  @override
  Widget build(BuildContext context) {
    // Simple grid of colored squares to mimic heatmap
    return LayoutBuilder(builder: (context, constraints) {
      final cols = 20;
      final rows = 5;
      final gap = 4.0;
      final cellSize = (constraints.maxWidth - (cols - 1) * gap) / cols;

      return Column(
        children: List.generate(rows, (r) {
          return Padding(
            padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : gap),
            child: Row(
              children: List.generate(cols, (c) {
                // choose color intensity based on position for visual variety
                final intensity = ((r + c) % 4);
                final color = [
                  Colors.transparent,
                  Colors.green.shade700,
                  Colors.green.shade500,
                  Colors.green.shade300,
                ][intensity];

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
