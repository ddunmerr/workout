import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/workout_repository.dart';
import '../domain/workout_data_point.dart';

class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository repository;
  final String deviceIp;

  List<WorkoutDataPoint> _workoutHistoryData = [];

  List<WorkoutDataPoint> get workoutHistoryData =>
      List.unmodifiable(_workoutHistoryData);

  static const int minDifficultyLevel = 1;
  static const int maxDifficultyLevel = 10;
  static const int resistancePerLevelStep = 5;
  int _currentDifficultyLevel = minDifficultyLevel;

  double _distance = 0.0;
  bool _isRunning = false;
  Timer? _pollingTimer;

  int _elapsedSeconds = 0;
  Timer? _workoutDurationTimer;

  WorkoutViewModel({required this.repository, required this.deviceIp}) {
    _sendCurrentResistanceToServer();
  }

  void _addHistoryPoint() {
    _workoutHistoryData.add(
      WorkoutDataPoint(
        timeSeconds: _elapsedSeconds,
        difficultyLevel: _currentDifficultyLevel,
      ),
    );
  }

  int get currentDifficultyLevel => _currentDifficultyLevel;

  int get _calculatedResistance {
    int level = _currentDifficultyLevel.clamp(
      minDifficultyLevel,
      maxDifficultyLevel,
    );
    return level * resistancePerLevelStep;
  }

  double get distance => _distance;

  bool get isRunning => _isRunning;

  int get elapsedSeconds => _elapsedSeconds;

  String get formattedElapsedTime {
    int hours = _elapsedSeconds ~/ 3600;
    int minutes = (_elapsedSeconds % 3600) ~/ 60;
    int seconds = _elapsedSeconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hoursStr:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

  int _resistanceToDifficultyLevel(int serverResistance) {
    if (resistancePerLevelStep == 0) return minDifficultyLevel;
    if (serverResistance <= 0) return minDifficultyLevel;
    double calculatedLevel = serverResistance / resistancePerLevelStep;
    return calculatedLevel.round().clamp(
      minDifficultyLevel,
      maxDifficultyLevel,
    );
  }

  Future<void> fetchState() async {
    try {
      final state = await repository.fetchState(deviceIp);
      int serverResistance = state['resistance'] ?? _calculatedResistance;
      _currentDifficultyLevel = _resistanceToDifficultyLevel(serverResistance);
      _distance = (state['distance'] ?? _distance).toDouble();
      notifyListeners();
    } catch (e) {
      print('Ошибка при получении состояния: $e');
    }
  }

  Future<void> _sendCurrentResistanceToServer() async {
    try {
      await repository.setResistance(deviceIp, _calculatedResistance);
    } catch (e) {
      print('Ошибка при установке сопротивления в WorkoutViewModel: $e');
    }
  }

  Future<void> increaseResistance() async {
    if (_currentDifficultyLevel < maxDifficultyLevel) {
      _currentDifficultyLevel++;
      await _sendCurrentResistanceToServer();
      _addHistoryPoint();
      notifyListeners();
    }
  }

  Future<void> decreaseResistance() async {
    if (_currentDifficultyLevel > minDifficultyLevel) {
      _currentDifficultyLevel--;
      await _sendCurrentResistanceToServer();
      _addHistoryPoint();
      notifyListeners();
    }
  }

  Future<void> startWorkout() async {
    await repository.startWorkout(deviceIp);
    _isRunning = true;
    _addHistoryPoint();
    _startPolling();
    notifyListeners();
  }

  Future<void> stopWorkout() async {
    await repository.stopWorkout(deviceIp);
    _isRunning = false;
    _stopPolling();
    _addHistoryPoint();
    notifyListeners();
  }

  Future<void> resetWorkout() async {
    await repository.resetWorkout(deviceIp);
    _elapsedSeconds = 0;
    _distance = 0.0;
    _workoutHistoryData.clear();
    notifyListeners();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 1), (_) => fetchState());
    _workoutDurationTimer?.cancel();
    _workoutDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _workoutDurationTimer?.cancel();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
