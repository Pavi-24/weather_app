import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text("Weather App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Temperature: $temperature"),
            Text("Humidity: $humidity"),
          ],
        ),
      )
      );
    }
}

Future<Position> _determinePosition() async{
  bool serviceEnabled;
  LocationPermission permission;
serviceEnabled= await Geolocator.isLocationServiceEnabled();
if(!serviceEnabled)
  {
    return Future.error("Location services are disabled");
  }
permission= await Geolocator.checkPermission();
if (permission==LocationPermission.denied)
  {
    permission=await Geolocator.requestPermission();
    if(permission==LocationPermission.denied)
      {
        return Future.error("Location services are denied");
      }
  }
if(permission==LocationPermission.deniedForever)
  {
    return Future.error("Location permissions are denied forever");
  }
return await Geolocator.getCurrentPosition();
}
int temperature = 0;
int humidity = 0;
Future<void> _getLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    print(position);
    await fetchData(position);
  } catch (e) {
    await Geolocator.requestPermission();
    };
  }
Future<void> fetchData(Position position) async {
  final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=10.7852&longitude=79.1391&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,visibility,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min&timezone=auto&forecast_days=1');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    temperature = data['current']['temperature_2m'];
    humidity = data['current']['relative_humidity_2m'];
    print(data);
  }
  else
    {
      throw Exception("Unable to get location");
    }
}