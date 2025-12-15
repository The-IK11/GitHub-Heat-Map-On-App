import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService{

  final Dio _dio=Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com/graphql',

      headers: {
        'Content-Type': 'application/json',
        // Read the token from environment variables. Make sure to call
        // `await dotenv.load(fileName: ".env")` in your `main()` before
        // the app initializes (e.g. in `main.dart`).
        'Authorization': 'Bearer ${dotenv.env['AUTH_TOKEN'] ?? ''}',
      }

    )
  );

  Future<Map<DateTime, int>> fetchContributionHeatmap(String username) async {
    const query = r'''
    query ($login: String!) {
      user(login: $login) {
        contributionsCollection {
          contributionCalendar {
            weeks {
              contributionDays {
                date
                contributionCount
              }
            }
          }
        }
      }
    }
    ''';

    final response = await _dio.post(
      '',
      data: {
        'query': query,
        'variables': {'login': username},
      },
    );

    final weeks = response.data['data']['user']
        ['contributionsCollection']['contributionCalendar']['weeks'];

    final Map<DateTime, int> heatMapData = {};

    for (var week in weeks) {
      for (var day in week['contributionDays']) {
        final date = DateTime.parse(day['date']);
        heatMapData[
          DateTime(date.year, date.month, date.day)
        ] = day['contributionCount'];
      }
    }

    return heatMapData;
  }
}