class WorkoutDataPoint {
  final int timeSeconds; // Время в секундах от начала тренировки (ось X)
  final int difficultyLevel; // Текущий уровень сложности (ось Y)

  WorkoutDataPoint({required this.timeSeconds, required this.difficultyLevel});

  // Опционально: можно добавить методы toJson/fromJson, если сохранять/загружать
  // историю тренировок, но для простого отображения графика они не нужны.
}
