import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gymtracker/adapters/builtin.dart' as builtin_adapters;
import 'package:gymtracker/adapters/exercise.dart';
import 'package:gymtracker/adapters/set.dart';
import 'package:gymtracker/adapters/superset.dart';
import 'package:gymtracker/adapters/workout.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:hive_flutter/hive_flutter.dart';

const DATABASE_VERSION = 1;

class DatabaseService extends GetxService with ChangeNotifier {
  late final Box<Exercise> exerciseBox;
  late final Box<Workout> routinesBox;
  late final Box<Workout> historyBox;
  final GetStorage settingsStorage = GetStorage("settings");
  final GetStorage ongoingStorage = GetStorage("ongoing");

  writeSetting<T>(String key, T value) {
    settingsStorage.write(key, value);
    notifyListeners();
  }

  @override
  onInit() {
    super.onInit();

    onServiceChange("main")();
    exerciseBox.listenable().addListener(onServiceChange("exercises"));
    routinesBox.listenable().addListener(onServiceChange("routines"));
    historyBox.listenable().addListener(onServiceChange("history"));
    settingsStorage.listen(onServiceChange("settings"));
    ongoingStorage.listen(onServiceChange("ongoing"));
  }

  Future ensureInitialized() async {
    await Hive.initFlutter();

    builtin_adapters.registerAll();
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(MuscleGroupAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(SupersetAdapter());
    Hive.registerAdapter(SetKindAdapter());
    Hive.registerAdapter(SetParametersAdapter());
    Hive.registerAdapter(ExSetAdapter());

    exerciseBox = await Hive.openBox<Exercise>("exercises");
    routinesBox = await Hive.openBox<Workout>("routines");
    historyBox = await Hive.openBox<Workout>("history");

    return Future.wait([
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
    return exerciseBox.values.toList();
  }

  set exercises(List<Exercise> exercises) {
    exerciseBox.clear().then((_) {
      exerciseBox.addAll(exercises).then((value) => notifyListeners());
    });
  }

  List<Workout> get routines {
    return routinesBox.values.toList();
  }

  set routines(List<Workout> routines) => writeRoutines(routines);

  writeRoutines(List<Workout> routines) {
    routinesBox.clear().then((_) {
      routinesBox.addAll(routines).then((value) => notifyListeners());
    });
  }

  List<Workout> get workoutHistory {
    return historyBox.values.toList();
  }

  set workoutHistory(List<Workout> history) => writeHistory(history);

  writeHistory(List<Workout> history) {
    historyBox.clear().then((_) {
      historyBox.addAll(history).then((value) => notifyListeners());
    });
  }

  toJson() {
    return {
      "version": DATABASE_VERSION,
      "exercise": exerciseBox.values.map((e) => e.toJson()).toList(),
      "routines": routinesBox.values.map((e) => e.toJson()).toList(),
      "workouts": historyBox.values.map((e) => e.toJson()).toList(),
      "settings": {
        for (final key in settingsStorage.getKeys<Iterable<String>>())
          key: settingsStorage.read(key),
      },
    };
  }

  fromJson(Map<String, dynamic> json) {
    final previousJson = toJson();

    if (json['version'] is int && (json['version'] as int) > DATABASE_VERSION) {
      throw DatabaseImportVersionMismatch((json['version'] as int? ?? -1));
    }

    innerImportJson(Map<String, dynamic> json) {
      if (json['exercise'] is List) {
        exercises = ([
          for (final json in json['exercise']) Exercise.fromJson(json),
        ]);
      }
      if (json['routines'] is List) {
        writeRoutines([
          for (final json in json['routines']) Workout.fromJson(json),
        ]);
      }
      if (json['workouts'] is List) {
        writeHistory([
          for (final json in json['workouts']) Workout.fromJson(json),
        ]);
      }
      if (json['settings'] is Map<String, dynamic>) {
        for (final key in json['settings'].keys) {
          writeSetting(key, json['settings'][key]);
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

  void writeToOngoing(Map<String, dynamic> data) {
    printInfo(info: "Requested write of ongoing workout data: $data");
    ongoingStorage.write("data", jsonEncode(data));
  }

  Map<String, dynamic>? getOngoingData() {
    if (!hasOngoing) return null;
    return jsonDecode(ongoingStorage.read("data"));
  }

  void deleteOngoing() {
    printInfo(info: "Requested deletion of ongoing workout data");
    ongoingStorage.remove("data");
  }

  bool get hasOngoing => ongoingStorage.hasData("data");
}

class DatabaseImportVersionMismatch implements Exception {
  final int version;

  DatabaseImportVersionMismatch(this.version);

  @override
  String toString() {
    return "Trying to import a newer version of the database: $version (current version: $DATABASE_VERSION)";
  }
}
