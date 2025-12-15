import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:github_heat_map/data/api.dart';


class GithubHeatmapScreen extends StatefulWidget {
  const GithubHeatmapScreen({super.key});

  @override
  State<GithubHeatmapScreen> createState() => _GithubHeatmapScreenState();
}

class _GithubHeatmapScreenState extends State<GithubHeatmapScreen> {
  final ApiService _service = ApiService();
  Map<DateTime, int>? heatMapData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHeatmap();
  }

  Future<void> loadHeatmap() async {
    final data = await _service.fetchContributionHeatmap('The-IK11');
    setState(() {
      heatMapData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GitHub Contributions')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: HeatMap(
                startDate: DateTime.now().subtract(const Duration(days: 365)),
                endDate: DateTime.now(),
                datasets: heatMapData!,
                colorMode: ColorMode.color,
                defaultColor: Colors.grey.shade300,
                textColor: Colors.black,
                showText: false,
                scrollable: true,
                size: 18,
                colorsets: const {
                  1: Color(0xff9be9a8),
                  3: Color(0xff40c463),
                  6: Color(0xff30a14e),
                  10: Color(0xff216e39),
                },
              ),
            ),
    );
  }
}
