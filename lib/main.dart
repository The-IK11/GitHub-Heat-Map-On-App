import 'package:flutter/material.dart';
import 'package:github_heat_map/presentation/github_ui_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:github_heat_map/presentation/github_wraped/github_wraped_screen.dart';
import 'package:github_heat_map/presentation/github_wraped/user_name_input_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the .env file before the app starts.
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home:UserNameInputScreen()
    );
  }
}
