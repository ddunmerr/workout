import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/device_selection_vm.dart';
import 'workout_screen.dart';

class DeviceSelectionScreen extends StatelessWidget {
  const DeviceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DeviceSelectionViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Выбор тренажера'),
        actions: [
          IconButton(
            icon: vm.isScanning
                ? const Icon(Icons.stop)
                : const Icon(Icons.refresh),
            onPressed: () {
              if (vm.isScanning) {
                vm.stopScan();
              } else {
                vm.startScan();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              vm.statusMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (vm.isScanning && vm.devices.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (!vm.isScanning && vm.devices.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Тренажеры не найдены. Убедитесь, что вы подключены к той же Wi-Fi сети, что и тренажер, и тренажер включен.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: vm.devices.length,
                itemBuilder: (context, index) {
                  final device = vm.devices[index];
                  return ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.ipAddress),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkoutScreen(selectedDeviceIp: device.ipAddress),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
