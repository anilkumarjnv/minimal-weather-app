import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('8caefff9532d3b0e87ca454c0ec486e3');
  Weather? _weather;
  String _statusMessage = "Fetching weather data...";
  final TextEditingController _cityController = TextEditingController();
  String _currentCity = "";

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Location permissions are permanently denied. Please enable them in app settings.");
    }
  }

  Future<void> _fetchWeather({String? city}) async {
    try {
      setState(() {
        _statusMessage = "Fetching weather data...";
        _weather = null;
      });

      // Use current city if no input is provided
      String cityName = city ?? _currentCity;
      if (cityName.isEmpty) {
        // Get user's current city if not provided
        await _requestLocationPermission();
        cityName = await _weatherService.getCurrentCity();
        setState(() {
          _currentCity = cityName; // Save current city
        });
      }

      // Fetch weather for the specified city
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
        _statusMessage = "";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Failed to fetch weather: Enter a valid city name";
      });
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'snow':
        return 'assets/snow.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunder storm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      ),
      resizeToAvoidBottomInset: true, // Prevent overflow when keyboard appears
      body: SingleChildScrollView(
        // Make the content scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _cityController,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'RobotoCondensed',
                ),
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  hintStyle: const TextStyle(
                    fontFamily: 'RobotoCondensed',
                    color: Colors.white70,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white70),
                      borderRadius: BorderRadius.circular(50)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(50)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      _fetchWeather(city: _cityController.text.trim());
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _weather == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 200),
                        Lottie.asset(
                          'assets/loading.json',
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'RobotoCondensed',
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        SvgPicture.asset(
                          'assets/location.svg',
                          height: 40,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          _weather!.cityName,
                          style: const TextStyle(
                              fontFamily: 'RobotoCondensed',
                              fontSize: 28,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Lottie.asset(
                          getWeatherAnimation(_weather!.mainCondition),
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '${_weather!.temperature.round()}°C',
                          style: const TextStyle(
                              fontFamily: 'RobotoCondensed',
                              fontSize: 40,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _weather!.mainCondition,
                          style: const TextStyle(
                              fontFamily: 'RobotoCondensed',
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
