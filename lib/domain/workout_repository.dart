import '../data/workout_api.dart';

abstract class WorkoutRepository {
  Future<Map<String, dynamic>> fetchState(String ip);

  Future<void> setResistance(String ip, int resistance);

  Future<void> startWorkout(String ip);

  Future<void> stopWorkout(String ip);

  Future<void> resetWorkout(String ip);
}

class WorkoutRepositoryImpl implements WorkoutRepository {
  @override
  Future<Map<String, dynamic>> fetchState(String ip) {
    return fetchStateFromDevice(ip);
  }

  @override
  Future<void> setResistance(String ip, int resistance) {
    return setResistanceToDevice(ip, resistance);
  }

  @override
  Future<void> startWorkout(String ip) {
    return startDevice(ip);
  }

  @override
  Future<void> stopWorkout(String ip) {
    return stopDevice(ip);
  }

  @override
  Future<void> resetWorkout(String ip) {
    return resetDevice(ip);
  }
}
