import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/workout_vm.dart';
import 'workout_summary_screen.dart';
import '../domain/workout_repository.dart';

class WorkoutScreen extends StatelessWidget {
  final String selectedDeviceIp;

  const WorkoutScreen({super.key, required this.selectedDeviceIp});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WorkoutViewModel>(
      create: (ctx) => WorkoutViewModel(
        repository: ctx.read<WorkoutRepository>(),
        deviceIp: 'http://$selectedDeviceIp',
      )..fetchState(),
      child: Consumer<WorkoutViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new),
              ),
              title: Text('Тренировка'),
              centerTitle: true,
            ),
            body: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 50),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Время: ${vm.formattedElapsedTime}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Дистанция: ${vm.distance.toStringAsFixed(2)} м',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 100),
                  Text(
                    'Уровень сложности: ${vm.currentDifficultyLevel}',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Color.fromRGBO(236, 240, 241, 1),
                          ),
                        ),
                        iconSize: 80,
                        onPressed:
                            vm.currentDifficultyLevel >
                                WorkoutViewModel.minDifficultyLevel
                            ? vm.decreaseResistance
                            : null,
                      ),
                      const SizedBox(width: 100),

                      IconButton(
                        icon: const Icon(Icons.add),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Color.fromRGBO(236, 240, 241, 1),
                          ),
                        ),

                        iconSize: 80,
                        onPressed:
                            vm.currentDifficultyLevel <
                                WorkoutViewModel.maxDifficultyLevel
                            ? vm.increaseResistance
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 75),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen[200],
                          fixedSize: Size(150, 75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onPressed: vm.isRunning ? null : vm.startWorkout,
                        child: const Text('Старт'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[200],
                          fixedSize: Size(150, 75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: vm.isRunning ? vm.stopWorkout : null,
                        child: const Text('Стоп'),
                      ),
                    ],
                  ),
                  SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue[200],
                          fixedSize: Size(150, 75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: vm.resetWorkout,
                        child: const Text('Сброс'),
                      ),
                      ElevatedButton(
                        onPressed:
                            (vm.isRunning ||
                                (!vm.isRunning &&
                                    vm.workoutHistoryData.isNotEmpty &&
                                    vm.workoutHistoryData.length >= 2))
                            ? () async {
                                await vm.stopWorkout();
                                if (vm.workoutHistoryData.isNotEmpty &&
                                    vm.workoutHistoryData.length >= 2) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WorkoutSummaryScreen(
                                            workoutData: vm.workoutHistoryData,
                                          ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Тренировка завершена. Недостаточно данных для графика.',
                                      ),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(150, 75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Завершить'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
