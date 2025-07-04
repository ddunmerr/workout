import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/workout_vm.dart';
import 'workout_summary_screen.dart'; // ИМПОРТ ЭКРАНА С ГРАФИКОМ
import '../domain/workout_repository.dart'; // Нужен для создания WorkoutViewModel

class WorkoutScreen extends StatelessWidget {
  final String selectedDeviceIp; // Принимаем выбранный IP
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
                // Чтобы элементы были вверху
                crossAxisAlignment: CrossAxisAlignment.center,
                // Центрируем по горизонтали
                children: [
                  // Отображение времени
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
                      //const SizedBox(width: 20),

                      //const SizedBox(width: 20),
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
                        //icon: Icon(Icons.refresh),
                        // iconSize: 70,
                        child: const Text('Сброс'),
                      ),
                      ElevatedButton(
                        onPressed:
                            (vm.isRunning ||
                                (!vm.isRunning &&
                                    vm.workoutHistoryData.isNotEmpty &&
                                    vm.workoutHistoryData.length >= 2))
                            ? () async {
                                // Сначала останавливаем тренировку во ViewModel
                                await vm.stopWorkout();

                                // Проверяем, есть ли данные для графика, после остановки
                                // (ViewModel уже записал последнюю точку в stopWorkout)
                                if (vm.workoutHistoryData.isNotEmpty &&
                                    vm.workoutHistoryData.length >= 2) {
                                  // Переходим на экран с результатами
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => WorkoutSummaryScreen(
                                        workoutData: vm.workoutHistoryData,
                                        // totalDistance: vm.distance, // Передаем другие данные при необходимости
                                        // totalTimeSeconds: vm.elapsedSeconds,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Если данных мало или нет, можно просто показать сообщение
                                  // (или перейти на экран результатов без графика)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Тренировка завершена. Недостаточно данных для графика.',
                                      ),
                                    ),
                                  );
                                  // Можно также просто вернуться на предыдущий экран, если нужно
                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                        // Кнопка неактивна, если тренировка не запущена
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
