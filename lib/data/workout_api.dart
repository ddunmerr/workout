import 'dart:convert';
import 'package:http/http.dart' as http;

/// Получает текущее состояние тренажера: расстояние, сопротивление, активность
Future<Map<String, dynamic>> fetchStateFromDevice(String ip) async {
  final response = await http.get(Uri.parse('$ip?json=1'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Ошибка при получении состояния устройства');
  }
}

/// Устанавливает новое сопротивление
Future<void> setResistanceToDevice(String ip, int resistance) async {
  await http.post(
    Uri.parse(ip),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'resistance': resistance}),
  );
}

/// Сбрасывает тренажер (сброс дистанции, состояния и т.п.)
Future<void> resetDevice(String ip) async {
  await http.post(Uri.parse('$ip/reset'));
}

/// Запускает тренировку (начинает считать дистанцию)
Future<void> startDevice(String ip) async {
  await http.post(Uri.parse('$ip/start'));
}

/// Останавливает тренировку (останавливает счётчик дистанции)
Future<void> stopDevice(String ip) async {
  await http.post(Uri.parse('$ip/stop'));
}
