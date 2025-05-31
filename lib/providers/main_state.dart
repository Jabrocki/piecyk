import 'package:flutter/material.dart';
import 'package:piecyk/repositories/weather_repository.dart';

class MainState extends ChangeNotifier {
  final WeatherRepository weatherRepo;
  MainState({required this.weatherRepo});
}
