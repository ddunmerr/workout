import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Для Platform.isAndroid/isIOS
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import '../domain/discovered_device.dart'; //модель

class NetworkDiscoveryService {
  final NetworkInfo _networkInfo = NetworkInfo();

  // Стрим для передачи найденных устройств по мере их обнаружения
  StreamController<DiscoveredDevice> _discoveredDevicesController =
      StreamController.broadcast();

  Stream<DiscoveredDevice> get discoveredDevicesStream =>
      _discoveredDevicesController.stream;

  bool _isScanning = false;

  bool get isScanning => _isScanning;

  Future<void> startDiscovery({int timeoutSeconds = 2}) async {
    if (_isScanning) return;
    _isScanning = true;
    try {
      String? wifiIP = await _networkInfo.getWifiIP();
      if (wifiIP == null) {
        _discoveredDevicesController.addError(
          "Wi-Fi не подключен или IP не получен.",
        );
        _isScanning = false;
        return;
      }
      final String subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
      for (int i = 1; i < 255; i++) {
        if (!_isScanning) break;
        String currentIpToScan = '$subnet.$i';
        if (currentIpToScan == wifiIP) continue;
        try {
          final uri = Uri.parse('http://$currentIpToScan?json=1');
          final response = await http
              .get(uri)
              .timeout(Duration(seconds: timeoutSeconds));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data.containsKey('resistance') &&
                data.containsKey('distance')) {
              _discoveredDevicesController.add(
                DiscoveredDevice(
                  ipAddress: currentIpToScan,
                  name: data.containsKey('name') ? data['name'] : 'Тренажер',
                ),
              );
            }
          }
        } catch (e) {}
      }
    } catch (e) {
      _discoveredDevicesController.addError("Ошибка при сканировании: $e");
    } finally {
      stopDiscovery();
    }
  }

  void stopDiscovery() {
    _isScanning = false;
  }

  void dispose() {
    _discoveredDevicesController.close();
  }
}
