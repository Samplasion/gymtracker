import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../model/exercise.dart';
import '../model/workout.dart';

class DatabaseService extends GetxService with ChangeNotifier {
  final GetStorage exerciseStorage = GetStorage("exercises");
  final GetStorage routinesStorage = GetStorage("routines");
  // History
  final GetStorage workoutsStorage = GetStorage("workouts");
  final GetStorage settingsStorage = GetStorage("settings");

  writeSetting<T>(String key, T value) {
    settingsStorage.write(key, value);
    notifyListeners();
  }

  @override
  onInit() {
    super.onInit();

    onServiceChange();
    exerciseStorage.listen(onServiceChange);
    routinesStorage.listen(onServiceChange);
    workoutsStorage.listen(onServiceChange);
    settingsStorage.listen(onServiceChange);
  }

  Future ensureInitialized() async {
    return Future.wait([
      exerciseStorage.initStorage,
      routinesStorage.initStorage,
      workoutsStorage.initStorage,
      settingsStorage.initStorage,
    ]);
  }

  void onServiceChange() {
    printInfo(info: "Notified listeners");
    notifyListeners();
  }

  List<Exercise> get exercises {
    List jsons = json.decode(exerciseStorage.read<String>("data") ?? "[]");
    return [for (final json in jsons) Exercise.fromJson(json)];
  }

  set exercises(List<Exercise> exercises) {
    List jsons = [for (final ex in exercises) ex.toJson()];
    exerciseStorage.write("data", json.encode(jsons));
    notifyListeners();
  }

  List<Workout> get routines {
    List jsons = json.decode(routinesStorage.read<String>("data") ?? "[]");
    return [for (final json in jsons) Workout.fromJson(json)];
  }

  set routines(List<Workout> routines) {
    List jsons = [for (final rt in routines) rt.toJson()];
    routinesStorage.write("data", json.encode(jsons));
    notifyListeners();
  }

  List<Workout> get workoutHistory {
    List jsons = json.decode(workoutsStorage.read<String>("data") ?? "[]");
    return [for (final json in jsons) Workout.fromJson(json)];
  }

  set workoutHistory(List<Workout> workoutHistory) {
    List jsons = [for (final wo in workoutHistory) wo.toJson()];
    workoutsStorage.write("data", json.encode(jsons));
    notifyListeners();
  }
}
