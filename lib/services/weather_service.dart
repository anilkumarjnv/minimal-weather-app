import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static String _baseUrl = dotenv.env['BASE_URL'] ?? '';
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  WeatherService();

  // Fetch weather data for a given city name
  Future<Weather> getWeather(String cityName) async {
    final url = Uri.parse('$_baseUrl?q=$cityName&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            "Failed to load weather data: ${response.statusCode} ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("Error fetching weather data: $e");
    }
  }

  // Get the current city name based on GPS location
  Future<String> getCurrentCity() async {
    try {
      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            "Location permissions are permanently denied. Please enable them in app settings.");
      }

      // Fetch the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Get placemarks from coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      // Extract the city name
      String? city = placemarks.isNotEmpty ? placemarks[0].locality : null;

      if (city != null && city.isNotEmpty) {
        return city;
      } else {
        throw Exception("Unable to determine city name from location.");
      }
    } catch (e) {
      throw Exception("Error fetching current city: $e");
    }
  }
}
