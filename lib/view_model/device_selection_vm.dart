import 'dart:async';
import 'package:flutter/material.dart';
import '../data/network_discovery_service.dart';
import '../domain/discovered_device.dart';

class DeviceSelectionViewModel extends ChangeNotifier {
  final NetworkDiscoveryService _discoveryService;

  List<DiscoveredDevice> _devices = [];

  List<DiscoveredDevice> get devices => _devices;

  bool get isScanning => _discoveryService.isScanning;

  String _statusMessage = "";

  String get statusMessage => _statusMessage;

  StreamSubscription? _devicesSubscription;

  DeviceSelectionViewModel({required NetworkDiscoveryService discoveryService})
    : _discoveryService = discoveryService {
    _devicesSubscription = _discoveryService.discoveredDevicesStream.listen((
      device,
    ) {
      if (!_devices.any((d) => d.ipAddress == device.ipAddress)) {
        _devices.add(device);
        notifyListeners();
      }
    });
  }

  Future<void> startScan() async {
    _devices.clear();
    notifyListeners();
    await _discoveryService.startDiscovery();
    notifyListeners();
  }

  void stopScan() {
    _discoveryService.stopDiscovery();
    notifyListeners();
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    _discoveryService.dispose();
    super.dispose();
  }
}
