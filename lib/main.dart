import 'package:flutter/material.dart';

import 'pages/weather_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'RobotoCondensed',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const WeatherPage(),
    );
  }
}
