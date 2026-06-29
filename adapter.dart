void runAdapterExample() {
  print("\n--- Adapter ---");

  print(
      "\nO que é? O padrão Adapter permite que classes com interfaces incompatíveis trabalhem juntas. Ele atua como um 'adaptador' entre duas interfaces, convertendo a interface de uma classe em outra que o cliente espera. Isso promove a reutilização de código e a integração de sistemas legados.\n");

  final weatherAPI = WeatherAPI();
  final weatherData = weatherAPI.fetchWeatherData("São Paulo");
  final weather = WeatherAdapter.fromJson(weatherData);

  print("Dados do clima obtidos da API:");
  print(weather);
}

class Weather {
  final String city;
  final double temperatureCelsius;

  Weather(this.city, this.temperatureCelsius);

  @override
  String toString() {
    return 'Weather(city: $city, temperatureCelsius: $temperatureCelsius)';
  }
}

class WeatherAPI {
  Map<String, dynamic> fetchWeatherData(String city) {
    return {
      'city': city,
      'temp': 25.0,
    };
  }
}

class WeatherAdapter {
  static Weather fromJson(Map<String, dynamic> json) {
    final city = json['city'] as String;
    final temperatureCelsius = (json['temp'] as num).toDouble();
    return Weather(city, temperatureCelsius);
  }
}
