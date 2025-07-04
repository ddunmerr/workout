import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchStateFromDevice(String ip) async {
  final response = await http.get(Uri.parse('$ip?json=1'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Ошибка при получении состояния устройства');
  }
}

Future<void> setResistanceToDevice(String ip, int resistance) async {
  await http.post(
    Uri.parse(ip),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'resistance': resistance}),
  );
}

Future<void> resetDevice(String ip) async {
  await http.post(Uri.parse('$ip/reset'));
}

Future<void> startDevice(String ip) async {
  await http.post(Uri.parse('$ip/start'));
}

Future<void> stopDevice(String ip) async {
  await http.post(Uri.parse('$ip/stop'));
}
