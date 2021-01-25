import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/services.dart';

import 'package:flutter_weather/widgets/Weather.dart';
import 'package:flutter_weather/widgets/WeatherItem.dart';
import 'package:flutter_weather/models/WeatherData.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  bool isLoading = false;
  WeatherData weatherData;


  @override
  void initState() {
    super.initState();

    loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            title: Text('Flutter Weather App'),
          ),
          body: Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: weatherData != null ? Weather(weather: weatherData) : Container(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isLoading ? CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: new AlwaysStoppedAnimation(Colors.white),
                            ) : IconButton(
                              icon: new Icon(Icons.refresh),
                              tooltip: 'Refresh',
                              onPressed: loadWeather,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
              )
          )
      ),
    );
  }

  loadWeather() async {
    setState(() {
      isLoading = true;
    });

    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    _locationData = await location.getLocation();


    if (location != null) {
      final lat = _locationData.latitude;
      final lon = _locationData.longitude;

      final weatherResponse = await http.get(
          'https://api.openweathermap.org/data/2.5/weather?APPID=6d01e13c96a915eb73acedb3b602e083&lat=${lat
              .toString()}&lon=${lon.toString()}');


      if (weatherResponse.statusCode == 200) {
        return setState(() {
          weatherData =
          new WeatherData.fromJson(jsonDecode(weatherResponse.body));
          isLoading = false;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }
}



























