import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'domain/workout_repository.dart';
import 'data/network_discovery_service.dart';
import 'view_model/device_selection_vm.dart';
import 'ui/device_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WorkoutRepository>(create: (_) => WorkoutRepositoryImpl()),
        Provider<NetworkDiscoveryService>(
          create: (_) => NetworkDiscoveryService(),
        ),
        ChangeNotifierProvider<DeviceSelectionViewModel>(
          create: (context) => DeviceSelectionViewModel(
            discoveryService: context.read<NetworkDiscoveryService>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Управление Тренажёром',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const DeviceSelectionScreen(),
      ),
    );
  }
}
