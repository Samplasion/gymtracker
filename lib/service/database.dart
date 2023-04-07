import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../model/exercise.dart';
import '../model/workout.dart';

class DatabaseService extends GetxService with ChangeNotifier {
  final GetStorage exerciseStorage = GetStorage("exercises");
  final GetStorage routinesStorage = GetStorage("routines");
  final GetStorage workoutsStorage = GetStorage("workouts");
  final GetStorage settingsStorage = GetStorage("settings");

  writeSetting<T>(String key, T value) {
    settingsStorage.write(key, value);
    notifyListeners();
  }

  @override
  onInit() {
    super.onInit();

    onServiceChange("main")();
    exerciseStorage.listen(onServiceChange("exercise"));
    routinesStorage.listen(onServiceChange("routines"));
    workoutsStorage.listen(onServiceChange("workouts"));
    settingsStorage.listen(onServiceChange("settings"));
  }

  Future ensureInitialized() async {
    return Future.wait([
      exerciseStorage.initStorage,
      routinesStorage.initStorage,
      workoutsStorage.initStorage,
      settingsStorage.initStorage,
    ]);
  }

  void Function() onServiceChange(String service) {
    return () {
      printInfo(info: "$service service updated");
    };
  }

  @override
  notifyListeners() {
    super.notifyListeners();
    printInfo(info: "Notified listeners");
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

  set routines(List<Workout> routines) => writeRoutines(routines);

  writeRoutines(List<Workout> routines) {
    List jsons = [for (final rt in routines) rt.toJson()];
    routinesStorage.write("data", json.encode(jsons));
    notifyListeners();
  }

  List<Workout> get workoutHistory {
    List jsons = json.decode(workoutsStorage.read<String>("data") ?? "[]");
    return [for (final json in jsons) Workout.fromJson(json)];
  }

  set workoutHistory(List<Workout> history) => writeHistory(history);

  writeHistory(List<Workout> history) {
    List jsons = [for (final wo in history) wo.toJson()];
    workoutsStorage
        .write("data", json.encode(jsons))
        .then((_) => notifyListeners());
  }

  toJson() {
    return {
      "exercise": jsonDecode(exerciseStorage.read("data")),
      "routines": jsonDecode(routinesStorage.read("data")),
      "workouts": jsonDecode(workoutsStorage.read("data")),
      "settings": {
        for (final key in settingsStorage.getKeys<Iterable<String>>())
          key: settingsStorage.read(key),
      },
    };
  }

  fromJson(Map<String, dynamic> json) {
    final previousJson = toJson();

    innerImportJson(Map<String, dynamic> json) {
      if (json['exercise'] is List) {
        exerciseStorage.write("data", jsonEncode(json['exercise']));
      }
      if (json['routines'] is List) {
        routinesStorage.write("data", jsonEncode(json['routines']));
      }
      if (json['workouts'] is List) {
        workoutsStorage.write("data", jsonEncode(json['workouts']));
      }
      if (json['settings'] is Map<String, dynamic>) {
        for (final key in json['settings'].keys) {
          writeSetting(key, json['settings']);
        }
      }
    }

    try {
      innerImportJson(json);
    } catch (_) {
      innerImportJson(previousJson);
      rethrow;
    }
  }
}
