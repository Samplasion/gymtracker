///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsIt with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsIt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.it,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <it>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsIt _root = this; // ignore: unused_field

	@override
	TranslationsIt $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsIt(meta: meta ?? this.$meta);

	// Translations
	@override String get appName => 'Gym Bro';
	@override late final Translations$navigation$it navigation = Translations$navigation$it._(_root);
	@override late final Translations$appInfo$it appInfo = Translations$appInfo$it._(_root);
	@override late final Translations$set$it set = Translations$set$it._(_root);
	@override late final Translations$exercise$it exercise = Translations$exercise$it._(_root);
	@override late final Translations$workouts$it workouts = Translations$workouts$it._(_root);
	@override late final Translations$routines$it routines = Translations$routines$it._(_root);
	@override late final Translations$history$it history = Translations$history$it._(_root);
	@override late final Translations$settings$it settings = Translations$settings$it._(_root);
	@override late final Translations$ongoingWorkout$it ongoingWorkout = Translations$ongoingWorkout$it._(_root);
	@override late final Translations$timer$it timer = Translations$timer$it._(_root);
	@override late final Translations$exerciseList$it exerciseList = Translations$exerciseList$it._(_root);
	@override late final Translations$general$it general = Translations$general$it._(_root);
	@override Map<String, String> get muscleGroups => {
		'abductors': 'Abduttori',
		'abs': 'Addominali',
		'adductors': 'Adductori',
		'biceps': 'Bicipiti',
		'calves': 'Polpacci',
		'chest': 'Petto',
		'forearm': 'Avambraccio',
		'glutes': 'Glutei',
		'hamstrings': 'Femorali',
		'lats': 'Gran dorsale',
		'lowerBack': 'Schiena bassa',
		'none': 'Nessuno',
		'other': 'Altro',
		'quadriceps': 'Quadricipiti',
		'shoulders': 'Spalle',
		'traps': 'Trapezoidi',
		'triceps': 'Tricipiti',
		'upperBack': 'Schiena alta',
		'thighs': 'Cosce',
		'forearms': 'Avambracci',
		'hands': 'Mani',
		'obliques': 'Obliqui',
		'tibialis': 'Tibiali',
	};
	@override Map<String, String> get muscleCategories => {
		'arms': 'Braccia',
		'back': 'Schiena',
		'chest': 'Petto',
		'core': 'Core',
		'legs': 'Gambe',
		'shoulders': 'Spalle',
	};
	@override late final Translations$titleGenerator$it titleGenerator = Translations$titleGenerator$it._(_root);
	@override late final Translations$actions$it actions = Translations$actions$it._(_root);
	@override Map<String, String> get units => {
		'kg': 'kg',
		'lb': 'lbs',
		'km': 'km',
		'mi': 'mi',
	};
	@override late final Translations$time$it time = Translations$time$it._(_root);
	@override Map<String, String> get locales => {
		'en': 'Inglese',
		'it': 'Italiano',
	};
	@override Map<String, String> get weightUnits => {
		'kg': 'Chili',
		'lb': 'Libbre',
	};
	@override Map<String, String> get distanceUnits => {
		'km': 'Chilometri',
		'mi': 'Miglia',
	};
	@override Map<String, String> get barbells => {
		'normal': 'Normale',
		'short': 'Corto',
		'ezBar': 'EZ bar',
		'none': 'Nessuno',
	};
	@override late final Translations$weightCalculator$it weightCalculator = Translations$weightCalculator$it._(_root);
	@override late final Translations$androidNotificationChannel$it androidNotificationChannel = Translations$androidNotificationChannel$it._(_root);
	@override late final Translations$library$it library = Translations$library$it._(_root);
	@override late final Translations$infobox$it infobox = Translations$infobox$it._(_root);
	@override String superset({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Superserie senza esercizi',
		one: 'Superserie con un esercizio',
		two: 'Superserie con ${n} esercizi',
		few: 'Superserie con ${n} esercizi',
		many: 'Superserie con ${n} esercizi',
		other: 'Superserie con ${n} esercizi',
	);
	@override late final Translations$historyEditor$it historyEditor = Translations$historyEditor$it._(_root);
	@override late final Translations$importRoutine$it importRoutine = Translations$importRoutine$it._(_root);
	@override late final Translations$unknownUrl$it unknownUrl = Translations$unknownUrl$it._(_root);
	@override late final Translations$me$it me = Translations$me$it._(_root);
	@override late final Translations$richText$it richText = Translations$richText$it._(_root);
	@override late final Translations$errorView$it errorView = Translations$errorView$it._(_root);
	@override late final Translations$timeSeriesChart$it timeSeriesChart = Translations$timeSeriesChart$it._(_root);
	@override late final Translations$androidRequestExactAlarmsPermission$it androidRequestExactAlarmsPermission = Translations$androidRequestExactAlarmsPermission$it._(_root);
	@override late final Translations$routineFormPicker$it routineFormPicker = Translations$routineFormPicker$it._(_root);
	@override late final Translations$cardioTimer$it cardioTimer = Translations$cardioTimer$it._(_root);
	@override late final Translations$migrations$it migrations = Translations$migrations$it._(_root);
	@override late final Translations$exerciseFormPicker$it exerciseFormPicker = Translations$exerciseFormPicker$it._(_root);
	@override late final Translations$exercises$it exercises = Translations$exercises$it._(_root);
	@override late final Translations$food$it food = Translations$food$it._(_root);
	@override late final Translations$equipment$it equipment = Translations$equipment$it._(_root);
	@override late final Translations$achievements$it achievements = Translations$achievements$it._(_root);
	@override late final Translations$workoutGenerator$it workoutGenerator = Translations$workoutGenerator$it._(_root);
	@override late final Translations$boutique$it boutique = Translations$boutique$it._(_root);
	@override late final Translations$login$it login = Translations$login$it._(_root);
	@override late final Translations$sync$it sync = Translations$sync$it._(_root);
	@override Map<String, dynamic> get bodyMeasurement => {
		'neck': Translations$bodyMeasurement$neck$it._(_root),
		'waist': Translations$bodyMeasurement$waist$it._(_root),
		'bodyFat': Translations$bodyMeasurement$bodyFat$it._(_root),
		'shoulder': Translations$bodyMeasurement$shoulder$it._(_root),
		'chest': Translations$bodyMeasurement$chest$it._(_root),
		'leftBicep': Translations$bodyMeasurement$leftBicep$it._(_root),
		'rightBicep': Translations$bodyMeasurement$rightBicep$it._(_root),
		'leftForearm': Translations$bodyMeasurement$leftForearm$it._(_root),
		'rightForearm': Translations$bodyMeasurement$rightForearm$it._(_root),
		'abdomen': Translations$bodyMeasurement$abdomen$it._(_root),
		'hips': Translations$bodyMeasurement$hips$it._(_root),
		'leftThigh': Translations$bodyMeasurement$leftThigh$it._(_root),
		'rightThigh': Translations$bodyMeasurement$rightThigh$it._(_root),
		'leftCalf': Translations$bodyMeasurement$leftCalf$it._(_root),
		'rightCalf': Translations$bodyMeasurement$rightCalf$it._(_root),
	};
	@override late final Translations$onboarding$it onboarding = Translations$onboarding$it._(_root);
	@override Map<String, dynamic> get nags => {
		'routines': Translations$nags$routines$it._(_root),
		'button': 'Unisciti ora!',
		'library': Translations$nags$library$it._(_root),
		'history': Translations$nags$history$it._(_root),
		'food': Translations$nags$food$it._(_root),
	};
	@override late final Translations$feed$it feed = Translations$feed$it._(_root);
	@override late final Translations$workoutPage$it workoutPage = Translations$workoutPage$it._(_root);
	@override late final Translations$pro$it pro = Translations$pro$it._(_root);
	@override late final Translations$userProfile$it userProfile = Translations$userProfile$it._(_root);
	@override late final Translations$friendRequests$it friendRequests = Translations$friendRequests$it._(_root);
	@override late final Translations$profileSearch$it profileSearch = Translations$profileSearch$it._(_root);
	@override String get you => 'Tu';
	@override late final Translations$error$it error = Translations$error$it._(_root);
	@override late final Translations$legacyWorkoutRecovery$it legacyWorkoutRecovery = Translations$legacyWorkoutRecovery$it._(_root);
	@override late final Translations$friendsList$it friendsList = Translations$friendsList$it._(_root);
	@override late final Translations$social$it social = Translations$social$it._(_root);
	@override late final Translations$hydration$it hydration = Translations$hydration$it._(_root);
	@override late final Translations$reports$it reports = Translations$reports$it._(_root);
	@override late final Translations$plateau$it plateau = Translations$plateau$it._(_root);
	@override late final Translations$progression$it progression = Translations$progression$it._(_root);
	@override late final Translations$paywall$it paywall = Translations$paywall$it._(_root);
	@override late final Translations$routineImport$it routineImport = Translations$routineImport$it._(_root);
}

// Path: navigation
class Translations$navigation$it implements Translations$navigation$en {
	Translations$navigation$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get feed => 'Feed';
	@override String get profile => 'Profilo';
	@override String get food => 'Diario';
	@override String get workouts => 'Allenati';
	@override String get pro => 'PRO';
	@override String get settings => 'Impostazioni';
}

// Path: appInfo
class Translations$appInfo$it implements Translations$appInfo$en {
	Translations$appInfo$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String version({required Object version, required Object build}) => 'Versione ${version} (build ${build})';
	@override String get shortDescription => 'Compagno di allenamenti';
	@override String get terms => 'Termini di servizio';
	@override String get privacy => 'Informativa sulla privacy';
}

// Path: set
class Translations$set$it implements Translations$set$en {
	Translations$set$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get kind => 'Tipo serie';
	@override late final Translations$set$kindShort$it kindShort = Translations$set$kindShort$it._(_root);
	@override Map<String, String> get kindLong => {
		'normal': 'Serie normale',
		'warmUp': 'Riscaldamento',
		'drop': 'Drop set',
		'failure': 'A cedimento',
		'failureStripping': 'A cedimento con stripping',
	};
	@override late final Translations$set$kinds$it kinds = Translations$set$kinds$it._(_root);
}

// Path: exercise
class Translations$exercise$it implements Translations$exercise$en {
	Translations$exercise$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exercise$chart$it chart = Translations$exercise$chart$it._(_root);
	@override late final Translations$exercise$fields$it fields = Translations$exercise$fields$it._(_root);
	@override late final Translations$exercise$actions$it actions = Translations$exercise$actions$it._(_root);
	@override late final Translations$exercise$editor$it editor = Translations$exercise$editor$it._(_root);
	@override late final Translations$exercise$picker$it picker = Translations$exercise$picker$it._(_root);
	@override String get custom => 'Personalizzato';
	@override late final Translations$exercise$info$it info = Translations$exercise$info$it._(_root);
	@override late final Translations$exercise$continuation$it continuation = Translations$exercise$continuation$it._(_root);
	@override late final Translations$exercise$delete$it delete = Translations$exercise$delete$it._(_root);
}

// Path: workouts
class Translations$workouts$it implements Translations$workouts$en {
	Translations$workouts$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get untitled => 'Allenamento senza nome';
	@override String get title => 'Allenamenti';
	@override late final Translations$workouts$actions$it actions = Translations$workouts$actions$it._(_root);
}

// Path: routines
class Translations$routines$it implements Translations$routines$en {
	Translations$routines$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Routine';
	@override String get newRoutine => 'Nuova routine';
	@override late final Translations$routines$quickWorkout$it quickWorkout = Translations$routines$quickWorkout$it._(_root);
	@override late final Translations$routines$actions$it actions = Translations$routines$actions$it._(_root);
	@override late final Translations$routines$editor$it editor = Translations$routines$editor$it._(_root);
	@override String get newFolder => 'Nuova cartella';
	@override String get folderNameEmpty => 'Il nome non dev\'essere vuoto.';
	@override String get folderName => 'Nome';
	@override String get editFolder => 'Modifica cartella';
	@override String get dropHere => 'Rilascia qui';
	@override String get moveToRoot => 'Rilascia la routine qui per muoverla nella schermata principale.';
	@override String get none => 'Nessuna routine';
	@override String get pick => 'Seleziona routine';
	@override String get rootFolder => 'Home';
	@override String get emptyFolder => 'Questa cartella è vuota';
	@override String get emptyFolderSubtitle => 'Tieni premuto e trascina una routine dalla pagina Home per aggiungerla a questa cartella.';
	@override String get folder => 'Cartella';
	@override String get nullFolder => 'Cartella eliminata';
	@override String get nullFolderSubtitle => 'Puoi tornare alla pagina Home.';
	@override String get folderNotes => 'Note';
	@override late final Translations$routines$loadError$it loadError = Translations$routines$loadError$it._(_root);
}

// Path: history
class Translations$history$it implements Translations$history$en {
	Translations$history$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cronologia';
	@override String get empty => 'Nessun allenamento';
	@override String andMore({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: '…e un altro',
		two: '…e altri ${n}',
		few: '…e altri ${n}',
		many: '…e altri ${n}',
		other: '…e altri ${n}',
	);
	@override late final Translations$history$actions$it actions = Translations$history$actions$it._(_root);
	@override String get showAll => 'Mostra tutto';
	@override String get search => 'Cerca allenamenti';
}

// Path: settings
class Translations$settings$it implements Translations$settings$en {
	Translations$settings$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impostazioni';
	@override late final Translations$settings$options$it options = Translations$settings$options$it._(_root);
	@override late final Translations$settings$colorPicker$it colorPicker = Translations$settings$colorPicker$it._(_root);
	@override late final Translations$settings$advanced$it advanced = Translations$settings$advanced$it._(_root);
	@override late final Translations$settings$panes$it panes = Translations$settings$panes$it._(_root);
	@override late final Translations$settings$permissions$it permissions = Translations$settings$permissions$it._(_root);
	@override late final Translations$settings$pro$it pro = Translations$settings$pro$it._(_root);
	@override String get logout => 'Esci';
	@override late final Translations$settings$logoutWarning$it logoutWarning = Translations$settings$logoutWarning$it._(_root);
}

// Path: ongoingWorkout
class Translations$ongoingWorkout$it implements Translations$ongoingWorkout$en {
	Translations$ongoingWorkout$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Allenamento';
	@override late final Translations$ongoingWorkout$actions$it actions = Translations$ongoingWorkout$actions$it._(_root);
	@override late final Translations$ongoingWorkout$exercises$it exercises = Translations$ongoingWorkout$exercises$it._(_root);
	@override late final Translations$ongoingWorkout$info$it info = Translations$ongoingWorkout$info$it._(_root);
	@override late final Translations$ongoingWorkout$finish$it finish = Translations$ongoingWorkout$finish$it._(_root);
	@override late final Translations$ongoingWorkout$cancel$it cancel = Translations$ongoingWorkout$cancel$it._(_root);
	@override late final Translations$ongoingWorkout$overwrite$it overwrite = Translations$ongoingWorkout$overwrite$it._(_root);
	@override String get restOver => 'È scaduto il tempo di recupero!';
	@override String get weightCalculator => 'Calcolatrice pesi';
	@override late final Translations$ongoingWorkout$superset$it superset = Translations$ongoingWorkout$superset$it._(_root);
	@override late final Translations$ongoingWorkout$stopwatch$it stopwatch = Translations$ongoingWorkout$stopwatch$it._(_root);
	@override late final Translations$ongoingWorkout$simple$it simple = Translations$ongoingWorkout$simple$it._(_root);
	@override late final Translations$ongoingWorkout$toolbox$it toolbox = Translations$ongoingWorkout$toolbox$it._(_root);
	@override late final Translations$ongoingWorkout$updateRoutine$it updateRoutine = Translations$ongoingWorkout$updateRoutine$it._(_root);
	@override late final Translations$ongoingWorkout$goodJob$it goodJob = Translations$ongoingWorkout$goodJob$it._(_root);
	@override late final Translations$ongoingWorkout$exercisesToSuperset$it exercisesToSuperset = Translations$ongoingWorkout$exercisesToSuperset$it._(_root);
}

// Path: timer
class Translations$timer$it implements Translations$timer$en {
	Translations$timer$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get add15s => '+15s';
	@override String get subtract15s => '-15s';
	@override String get skip => 'Salta';
}

// Path: exerciseList
class Translations$exerciseList$it implements Translations$exerciseList$en {
	Translations$exerciseList$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get restTime => 'Recupero: ';
	@override late final Translations$exerciseList$fields$it fields = Translations$exerciseList$fields$it._(_root);
	@override late final Translations$exerciseList$workoutMuscleCategoriesBarChart$it workoutMuscleCategoriesBarChart = Translations$exerciseList$workoutMuscleCategoriesBarChart$it._(_root);
	@override late final Translations$exerciseList$stats$it stats = Translations$exerciseList$stats$it._(_root);
	@override late final Translations$exerciseList$workoutWeightDistributionBarChart$it workoutWeightDistributionBarChart = Translations$exerciseList$workoutWeightDistributionBarChart$it._(_root);
	@override late final Translations$exerciseList$workoutEquipmentDistributionBarChart$it workoutEquipmentDistributionBarChart = Translations$exerciseList$workoutEquipmentDistributionBarChart$it._(_root);
}

// Path: general
class Translations$general$it implements Translations$general$en {
	Translations$general$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$general$dialogs$it dialogs = Translations$general$dialogs$it._(_root);
	@override String exercises({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Nessun esercizio',
		one: '${n} esercizio',
		two: '${n} esercizi',
		few: '${n} esercizi',
		many: '${n} di esercizi',
		other: '${n} esercizi',
	);
	@override String totalTime({required Object time}) => 'Tempo totale: ${time}';
	@override String selected({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Nessuna selezione',
		one: '1 elemento selezionato',
		two: '${n} elementi selezionati',
		few: '${n} elementi selezionati',
		many: '${n} elementi selezionati',
		other: '${n} elementi selezionati',
	);
	@override String workouts({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Nessun allenamento',
		one: '${n} allenamento',
		two: '${n} allenamenti',
		few: '${n} allenamenti',
		many: '${n} allenamenti',
		other: '${n} allenamenti',
	);
	@override String routines({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Nessuna routine',
		one: '${n} routine',
		two: '${n} routine',
		few: '${n} routine',
		many: '${n} routine',
		other: '${n} routine',
	);
	@override String get optional => '(facoltativo)';
	@override String get unnamed => 'Unnamed';
}

// Path: titleGenerator
class Translations$titleGenerator$it implements Translations$titleGenerator$en {
	Translations$titleGenerator$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String template({required Object muscles}) => 'Allenamento ${muscles}';
	@override late final Translations$titleGenerator$title$it title = Translations$titleGenerator$title$it._(_root);
}

// Path: actions
class Translations$actions$it implements Translations$actions$en {
	Translations$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get create => 'Crea';
	@override String get remove => 'Rimuovi';
	@override String get edit => 'Modifica';
	@override String get undo => 'Annulla';
	@override String get save => 'Salva';
}

// Path: time
class Translations$time$it implements Translations$time$en {
	Translations$time$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String hours({required num n, required Object minutes, required Object seconds, required Object hours}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: '${minutes}:${seconds}',
		one: '${hours} ora, ${minutes}:${seconds}',
		two: '${hours} ore, ${minutes}:${seconds}',
		few: '${hours} ore, ${minutes}:${seconds}',
		many: '${hours} di ore, ${minutes}:${seconds}',
		other: '${hours} ore, ${minutes}:${seconds}',
	);
	@override String justHours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: '${n}',
		one: '${n} ora',
		two: '${n} ore',
		few: '${n} ore',
		many: '${n} di ore',
		other: '${n} ore',
	);
	@override String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: '0 giorni',
		one: '1 giorno',
		two: '2 giorni',
		few: '${n} giorni',
		many: '${n} di giorni',
		other: '${n} giorni',
	);
	@override String weeks({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: '0 settimane',
		one: '1 settimana',
		two: '2 settimane',
		few: '${n} settimane',
		many: '${n} di settimane',
		other: '${n} settimane',
	);
}

// Path: weightCalculator
class Translations$weightCalculator$it implements Translations$weightCalculator$en {
	Translations$weightCalculator$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$weightCalculator$weight$it weight = Translations$weightCalculator$weight$it._(_root);
	@override late final Translations$weightCalculator$weights$it weights = Translations$weightCalculator$weights$it._(_root);
	@override late final Translations$weightCalculator$barbells$it barbells = Translations$weightCalculator$barbells$it._(_root);
	@override String get insert => 'Inserisci peso';
}

// Path: androidNotificationChannel
class Translations$androidNotificationChannel$it implements Translations$androidNotificationChannel$en {
	Translations$androidNotificationChannel$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Timer tempo di recupero';
	@override String get description => 'Invia una notifica quando il timer del tempo di recupero finisce.';
}

// Path: library
class Translations$library$it implements Translations$library$en {
	Translations$library$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Libreria';
	@override late final Translations$library$cardio$it cardio = Translations$library$cardio$it._(_root);
	@override late final Translations$library$chest$it chest = Translations$library$chest$it._(_root);
	@override late final Translations$library$biceps$it biceps = Translations$library$biceps$it._(_root);
	@override late final Translations$library$abs$it abs = Translations$library$abs$it._(_root);
	@override late final Translations$library$calves$it calves = Translations$library$calves$it._(_root);
	@override late final Translations$library$quadriceps$it quadriceps = Translations$library$quadriceps$it._(_root);
	@override late final Translations$library$hamstrings$it hamstrings = Translations$library$hamstrings$it._(_root);
	@override late final Translations$library$shoulders$it shoulders = Translations$library$shoulders$it._(_root);
	@override late final Translations$library$back$it back = Translations$library$back$it._(_root);
	@override late final Translations$library$triceps$it triceps = Translations$library$triceps$it._(_root);
	@override late final Translations$library$custom$it custom = Translations$library$custom$it._(_root);
	@override String get newCustomExercise => 'Nuovo esercizio';
	@override late final Translations$library$hips$it hips = Translations$library$hips$it._(_root);
	@override late final Translations$library$forearms$it forearms = Translations$library$forearms$it._(_root);
	@override late final Translations$library$obliques$it obliques = Translations$library$obliques$it._(_root);
	@override late final Translations$library$other$it other = Translations$library$other$it._(_root);
	@override late final Translations$library$glutes$it glutes = Translations$library$glutes$it._(_root);
}

// Path: infobox
class Translations$infobox$it implements Translations$infobox$en {
	Translations$infobox$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Note';
}

// Path: historyEditor
class Translations$historyEditor$it implements Translations$historyEditor$en {
	Translations$historyEditor$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String title({required Object name}) => 'Modifica: ${name}';
	@override late final Translations$historyEditor$exercises$it exercises = Translations$historyEditor$exercises$it._(_root);
	@override late final Translations$historyEditor$info$it info = Translations$historyEditor$info$it._(_root);
	@override late final Translations$historyEditor$actions$it actions = Translations$historyEditor$actions$it._(_root);
	@override late final Translations$historyEditor$finish$it finish = Translations$historyEditor$finish$it._(_root);
}

// Path: importRoutine
class Translations$importRoutine$it implements Translations$importRoutine$en {
	Translations$importRoutine$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Importa routine';
	@override late final Translations$importRoutine$errors$it errors = Translations$importRoutine$errors$it._(_root);
	@override late final Translations$importRoutine$import$it import = Translations$importRoutine$import$it._(_root);
}

// Path: unknownUrl
class Translations$unknownUrl$it implements Translations$unknownUrl$en {
	Translations$unknownUrl$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'URL sconosciuto';
	@override String get text => 'Hai seguito un URL che non porta da nessuna parte.';
}

// Path: me
class Translations$me$it implements Translations$me$en {
	Translations$me$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profilo';
	@override late final Translations$me$weight$it weight = Translations$me$weight$it._(_root);
	@override late final Translations$me$addWeight$it addWeight = Translations$me$addWeight$it._(_root);
	@override late final Translations$me$allData$it allData = Translations$me$allData$it._(_root);
	@override late final Translations$me$calendar$it calendar = Translations$me$calendar$it._(_root);
	@override late final Translations$me$stats$it stats = Translations$me$stats$it._(_root);
	@override late final Translations$me$workoutDistribution$it workoutDistribution = Translations$me$workoutDistribution$it._(_root);
	@override late final Translations$me$profile$it profile = Translations$me$profile$it._(_root);
	@override late final Translations$me$sync$it sync = Translations$me$sync$it._(_root);
	@override String get bodyMeasurements => 'Misurazioni corporee';
	@override late final Translations$me$trainer$it trainer = Translations$me$trainer$it._(_root);
}

// Path: richText
class Translations$richText$it implements Translations$richText$en {
	Translations$richText$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get highlight => 'Evidenzia';
}

// Path: errorView
class Translations$errorView$it implements Translations$errorView$en {
	Translations$errorView$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get shortTitle => 'Errore';
	@override String get title => 'Oh cavolo!';
	@override String get subtitle => 'Qualcosa è andato storto.';
	@override String get body => 'Se il problema persiste, prova a:\n\n • Riavviare l\'app\n • Assicurarti di avere l\'ultima versione dell\'app\n • Contattare il supporto';
	@override String get stack => 'Se il problema persiste, per favore fornisci le seguenti informazioni al supporto:';
	@override String get noStack => 'Nessuna informazione disponibile sullo stack.';
}

// Path: timeSeriesChart
class Translations$timeSeriesChart$it implements Translations$timeSeriesChart$en {
	Translations$timeSeriesChart$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get selectInterval => 'Seleziona intervallo';
	@override Map<String, String> get interval => {
		'threeMonths': '3 mesi',
		'sixMonths': '6 mesi',
		'oneYear': '1 anno',
	};
	@override late final Translations$timeSeriesChart$noData$it noData = Translations$timeSeriesChart$noData$it._(_root);
}

// Path: androidRequestExactAlarmsPermission
class Translations$androidRequestExactAlarmsPermission$it implements Translations$androidRequestExactAlarmsPermission$en {
	Translations$androidRequestExactAlarmsPermission$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Permesso di invio notifiche';
	@override String get message => 'Questa applicazione richiede un permesso speciale, "Promemoria e avvisi", sulle versioni di Android a partire da Android 14. Puoi scegliere di rifiutarlo, ma funzionalità come le notifiche di fine recupero non funzioneranno. Vuoi dare il permesso?';
}

// Path: routineFormPicker
class Translations$routineFormPicker$it implements Translations$routineFormPicker$en {
	Translations$routineFormPicker$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$routineFormPicker$fields$it fields = Translations$routineFormPicker$fields$it._(_root);
}

// Path: cardioTimer
class Translations$cardioTimer$it implements Translations$cardioTimer$en {
	Translations$cardioTimer$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Timer a intervalli';
	@override late final Translations$cardioTimer$setUp$it setUp = Translations$cardioTimer$setUp$it._(_root);
	@override late final Translations$cardioTimer$confirmExit$it confirmExit = Translations$cardioTimer$confirmExit$it._(_root);
}

// Path: migrations
class Translations$migrations$it implements Translations$migrations$en {
	Translations$migrations$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$customToLibraryExercise$it customToLibraryExercise = Translations$migrations$customToLibraryExercise$it._(_root);
	@override late final Translations$migrations$common$it common = Translations$migrations$common$it._(_root);
	@override String get title => 'Migrazioni';
	@override late final Translations$migrations$removeUnusedExercises$it removeUnusedExercises = Translations$migrations$removeUnusedExercises$it._(_root);
	@override late final Translations$migrations$removeWeightFromCustomExercise$it removeWeightFromCustomExercise = Translations$migrations$removeWeightFromCustomExercise$it._(_root);
	@override late final Translations$migrations$genericMultiplyWeight$it genericMultiplyWeight = Translations$migrations$genericMultiplyWeight$it._(_root);
	@override late final Translations$migrations$doubleExerciseWeight$it doubleExerciseWeight = Translations$migrations$doubleExerciseWeight$it._(_root);
	@override late final Translations$migrations$halveExerciseWeight$it halveExerciseWeight = Translations$migrations$halveExerciseWeight$it._(_root);
}

// Path: exerciseFormPicker
class Translations$exerciseFormPicker$it implements Translations$exerciseFormPicker$en {
	Translations$exerciseFormPicker$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exerciseFormPicker$fields$it fields = Translations$exerciseFormPicker$fields$it._(_root);
}

// Path: exercises
class Translations$exercises$it implements Translations$exercises$en {
	Translations$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exercises$none$it none = Translations$exercises$none$it._(_root);
}

// Path: food
class Translations$food$it implements Translations$food$en {
	Translations$food$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Diario alimentare';
	@override late final Translations$food$home$it home = Translations$food$home$it._(_root);
	@override late final Translations$food$searchBar$it searchBar = Translations$food$searchBar$it._(_root);
	@override Map<String, String> get nutriments => {
		'calories': 'Calorie',
		'fat': 'Grassi',
		'saturatedFat': 'Acidi grassi saturi',
		'carbs': 'Carboidrati',
		'sugar': 'Zuccheri',
		'protein': 'Proteine',
		'salt': 'Sale',
		'sodium': 'Sodio',
		'fiber': 'Fibre',
		'addedSugars': 'Zuccheri aggiunti',
		'proteins': 'Proteine',
		'caffeine': 'Caffeina',
		'calcium': 'Calcio',
		'iron': 'Ferro',
		'vitaminC': 'Vitamina C',
		'magnesium': 'Magnesio',
		'phosphorus': 'Fosforo',
		'potassium': 'Potassio',
		'zinc': 'Zinco',
		'copper': 'Rame',
		'selenium': 'Selenio',
		'vitaminA': 'Vitamina A',
		'vitaminE': 'Vitamina E',
		'vitaminD': 'Vitamina D',
		'vitaminB1': 'Vitamina B1',
		'vitaminB2': 'Vitamina B2',
		'vitaminPP': 'Vitamina PP',
		'vitaminB6': 'Vitamina B6',
		'vitaminB12': 'Vitamina B12',
		'vitaminB9': 'Vitamina B9',
		'vitaminK': 'Vitamina K',
		'cholesterol': 'Colesterolo',
		'butyricAcid': 'Acido butirrico',
		'caproicAcid': 'Acido caproico',
		'caprylicAcid': 'Acido caprilico',
		'capricAcid': 'Acido caprico',
		'lauricAcid': 'Acido laurico',
		'myristicAcid': 'Acido miristico',
		'palmiticAcid': 'Acido palmitico',
		'stearicAcid': 'Acido stearico',
		'oleicAcid': 'Acido oleico',
		'linoleicAcid': 'Acido linoleico',
		'docosahexaenoicAcid': 'Acido docosaesaenoico',
		'eicosapentaenoicAcid': 'Acido eicosapenaenoico',
		'erucicAcid': 'Acido erucico',
		'monounsaturatedFat': 'Acidi grassi monoinsaturi',
		'polyunsaturatedFat': 'Acidi grassi polinsaturi',
		'alcohol': 'Alcol',
		'pantothenicAcid': 'Acido pantotenico',
		'biotin': 'Biotina',
		'chloride': 'Cloruro',
		'chromium': 'Cromo',
		'fluoride': 'Fluoruro',
		'iodine': 'Iodio',
		'manganese': 'Manganese',
		'molybdenum': 'Molibdeno',
		'omega3': 'Omega 3',
		'omega6': 'Omega 6',
		'omega9': 'Omega 9',
		'betaCarotene': 'ß-carotene',
		'bicarbonate': 'Bicarbonato',
		'sugarAlcohol': 'Polioli',
		'alphaLinolenicAcid': 'Acido alfa-linolenico',
		'arachidicAcid': 'Acido arachidico',
		'arachidonicAcid': 'Acido arachidonico',
		'behenicAcid': 'Acido beenico',
		'ceroticAcid': 'Acido cerotico',
		'dihomoGammaLinolenicAcid': 'Acido diomo-gamma-linolenico',
		'elaidicAcid': 'Acido elaidico',
		'gammaLinolenicAcid': 'Acido gamma-linolenico',
		'gondoicAcid': 'Acido gondoico (acido 11-eicosenoico)',
		'lignocericAcid': 'Acido lignocerico',
		'meadAcid': 'Acido di Mead',
		'melissicAcid': 'Acido melissico',
		'montanicAcid': 'Acido montanico',
		'nervonicAcid': 'Acido nervonico',
		'transFat': 'Acidi grassi trans',
		'water': 'Acqua',
	};
	@override Map<String, String> get nutrimentUnits => {
		'kcal': 'kcal',
		'kj': 'kJ',
		'g': 'g',
		'milliG': 'mg',
		'microG': 'µg',
		'milliL': 'ml',
		'l': 'L',
		'percent': '%',
		'unknown': 'Sconosciuto',
	};
	@override late final Translations$food$add$it add = Translations$food$add$it._(_root);
	@override String get offAttribution => 'Dati forniti da OpenFoodFacts';
	@override late final Translations$food$edit$it edit = Translations$food$edit$it._(_root);
	@override late final Translations$food$addCustom$it addCustom = Translations$food$addCustom$it._(_root);
	@override late final Translations$food$search$it search = Translations$food$search$it._(_root);
	@override late final Translations$food$barcodeReader$it barcodeReader = Translations$food$barcodeReader$it._(_root);
	@override late final Translations$food$addCustomFood$it addCustomFood = Translations$food$addCustomFood$it._(_root);
	@override late final Translations$food$nutritionGoal$it nutritionGoal = Translations$food$nutritionGoal$it._(_root);
	@override late final Translations$food$nutritionGoals$it nutritionGoals = Translations$food$nutritionGoals$it._(_root);
	@override late final Translations$food$combine$it combine = Translations$food$combine$it._(_root);
	@override String get removeFavorite => 'Rimuovi dai preferiti';
	@override String get addFavorite => 'Aggiungi ai preferiti';
	@override Map<String, String> get languages => {
		'aa': 'Afar',
		'ae': 'Lingua avestica',
		'af': 'Afrikaans',
		'ak': 'Akan',
		'am': 'Amarico',
		'an': 'Aragonese',
		'ar': 'Arabo',
		'as': 'Assamese',
		'av': 'Avar',
		'ay': 'Aymara',
		'az': 'Azero',
		'ba': 'Bashkir',
		'be': 'Bielorusso',
		'bg': 'Bulgaro',
		'bh': 'Bihari',
		'bi': 'Bislama',
		'bm': 'Bambara',
		'bn': 'Bengalese',
		'bo': 'Tibetano',
		'br': 'Bretone',
		'bs': 'Bosniaco',
		'ca': 'Catalano',
		'ce': 'Ceceno',
		'ch': 'Chamorro',
		'co': 'Corso',
		'cr': 'Cree',
		'cs': 'Ceco',
		'cu': 'Slavo ecclesiastico',
		'cv': 'Chuvash',
		'cy': 'Gallese',
		'da': 'Danese',
		'de': 'Tedesco',
		'dv': 'Maldiviano',
		'dz': 'Dzongkha',
		'ee': 'Ewe',
		'el': 'Greco',
		'en': 'Inglese',
		'eo': 'Esperanto',
		'es': 'Spagnolo',
		'et': 'Estone',
		'eu': 'Basco',
		'fa': 'Persiano',
		'ff': 'Fulah',
		'fi': 'Finnico',
		'fj': 'Fijian',
		'fo': 'Faroese',
		'fr': 'Francese',
		'fy': 'Frisone occidentale',
		'ga': 'Irlandese',
		'gd': 'Gaelico scozzese',
		'gl': 'Galiziano',
		'gn': 'Guarani',
		'gu': 'Gujarati',
		'gv': 'Manx',
		'ha': 'Hausa',
		'he': 'Ebraico',
		'hi': 'Hindi',
		'ho': 'Hiri Motu',
		'hr': 'Croato',
		'ht': 'Creolo haitiano',
		'hu': 'Ungherese',
		'hy': 'Armeno',
		'hz': 'Herero',
		'ia': 'Interlingua',
		'id': 'Indonesiano',
		'ie': 'Interlingue',
		'ig': 'Igbo',
		'ii': 'Nuosu',
		'ik': 'Inupiaq',
		'io': 'Ido',
		'is': 'Islandese',
		'it': 'Italiano',
		'iu': 'Inuktitut',
		'ja': 'Giapponese',
		'jv': 'Giavanese',
		'ka': 'Georgiano',
		'kg': 'Kongo',
		'ki': 'Gikuyu',
		'kj': 'Kwanyama',
		'kk': 'Kazaco',
		'kl': 'Groenlandese',
		'km': 'Khmer',
		'kn': 'Kannada',
		'ko': 'Coreano',
		'kr': 'Kanuri',
		'ks': 'Kashmiri',
		'ku': 'Curdo',
		'kv': 'Komi',
		'kw': 'Cornico',
		'ky': 'Kirghiso',
		'la': 'Latino',
		'lb': 'Lussemburghese',
		'lg': 'Ganda',
		'li': 'Limburgan',
		'ln': 'Lingala',
		'lo': 'Lao',
		'lt': 'Lituano',
		'lu': 'Luba-Katanga',
		'lv': 'Lettone',
		'mg': 'Malagasy',
		'mh': 'Marshallese',
		'mi': 'Maori',
		'mk': 'Macedone',
		'ml': 'Malese',
		'mn': 'Mongolo',
		'mo': 'Moldavo',
		'mr': 'Marathi',
		'ms': 'Malese',
		'mt': 'Maltese',
		'my': 'Burmese',
		'na': 'Nauru',
		'nb': 'Bokmal',
		'nd': 'Ndebele del nord',
		'ne': 'Nepalese',
		'ng': 'Ndonga',
		'nl': 'Olandese',
		'nn': 'Nynorsk',
		'no': 'Norvegese',
		'nr': 'Ndebele del sud',
		'nv': 'Navajo',
		'ny': 'Chichewa',
		'oc': 'Occitano',
		'oj': 'Ojibwe',
		'om': 'Oromo',
		'or': 'Odia',
		'os': 'Osseto',
		'pa': 'Punjabi',
		'pi': 'Pali',
		'pl': 'Polacco',
		'ps': 'Pashto',
		'pt': 'Portoghese',
		'qu': 'Quechua',
		'rm': 'Romancio',
		'rn': 'Kirundi',
		'ro': 'Rumeno',
		'ru': 'Russo',
		'rw': 'Kinyarmanda',
		'sa': 'Sanscrito',
		'sc': 'Sardo',
		'sd': 'Sindhi',
		'se': 'Samish settentrionale',
		'sg': 'Sango',
		'si': 'Cingalese',
		'sk': 'Slovacco',
		'sl': 'Sloveno',
		'sm': 'Samoano',
		'sn': 'Shona',
		'so': 'Somalo',
		'sq': 'Albanese',
		'sr': 'Serbo',
		'ss': 'Swazi',
		'st': 'Sotho',
		'su': 'Sundanese',
		'sv': 'Svedese',
		'sw': 'Swahili',
		'ta': 'Tamil',
		'te': 'Telugu',
		'tg': 'Tajik',
		'th': 'Thailandese',
		'ti': 'Tigrinya',
		'tk': 'Turkmeno',
		'tl': 'Tagalog',
		'tn': 'Tswana',
		'to': 'Tonga',
		'tr': 'Turco',
		'ts': 'Tsonga',
		'tt': 'Tatar',
		'tw': 'Twi',
		'ty': 'Tahitiano',
		'ug': 'Uyghur',
		'uk': 'Ucraino',
		'ur': 'Urdu',
		'uz': 'Uzbeco',
		've': 'Venda',
		'vi': 'Vietnamita',
		'vo': 'Volapuk',
		'wo': 'Wolof',
		'xh': 'Xhosa',
		'yi': 'Yiddish',
		'yo': 'Yoruba',
		'za': 'Zhuang',
		'zh': 'Cinese',
		'zu': 'Zulu',
		'xx': 'Lingua sconosciuta',
		'world': 'Mondo (pseudo-lingua)',
		'und': 'Lingua non definita',
	};
	@override Map<String, String> get countries => {
		'ad': 'Andorra',
		'ae': 'Emirati Arabi Uniti',
		'af': 'Afghanistan',
		'ag': 'Antigua e Barbuda',
		'ai': 'Anguilla',
		'al': 'Albania',
		'am': 'Armenia',
		'ao': 'Angola',
		'aq': 'Antartide',
		'ar': 'Argentina',
		'as': 'Samoa Americane',
		'at': 'Austria',
		'au': 'Australia',
		'aw': 'Aruba',
		'ax': 'Isole Åland',
		'az': 'Azerbaigian',
		'ba': 'Bosnia e Herzegovina',
		'bb': 'Barbados',
		'bd': 'Bangladesh',
		'be': 'Belgio',
		'bf': 'Burkina Faso',
		'bg': 'Bulgaria',
		'bh': 'Bahrain',
		'bi': 'Burundi',
		'bj': 'Benin',
		'bl': 'San Bartolomeo',
		'bm': 'Bermuda',
		'bn': 'Brunei Darussalam',
		'bo': 'Bolivia (Stato Plurinazionale della)',
		'bq': 'Bonaire, Sint Eustatius e Saba',
		'br': 'Brasile',
		'bs': 'Bahamas',
		'bt': 'Butan',
		'bv': 'Isola Bouvet',
		'bw': 'Botswana',
		'by': 'Bielorussia',
		'bz': 'Belize',
		'ca': 'Canada',
		'cc': 'Isole Cocos (Keeling)',
		'cd': 'Congo, Repubblica Democratica del',
		'cf': 'Repubblica Centrafricana',
		'cg': 'Congo',
		'ch': 'Svizzera',
		'ci': 'Costa d\'Avorio',
		'ck': 'Isole Cook',
		'cl': 'Cile',
		'cm': 'Cameron',
		'cn': 'Cina',
		'co': 'Colombia',
		'cr': 'Costa Rica',
		'cu': 'Cuba',
		'cv': 'Capo Verde',
		'cw': 'Curaçao',
		'cx': 'Isola di Natale',
		'cy': 'Cipro',
		'cz': 'Repubblica Ceca',
		'de': 'Germania',
		'dj': 'Djibouti',
		'dk': 'Danimarca',
		'dm': 'Dominica',
		'do': 'Repubblica Domenicana',
		'dz': 'Algeria',
		'ec': 'Ecuador',
		'ee': 'Estonia',
		'eg': 'Egitto',
		'eh': 'Sahara Occidentale',
		'er': 'Eritrea',
		'es': 'Spagna',
		'et': 'Etiopia',
		'fi': 'Finlandia',
		'fj': 'Fiji',
		'fk': 'Isole Falkland (Malvine)',
		'fm': 'Micronesia (Stati Federati di)',
		'fo': 'Isole Fær Øer',
		'fr': 'Francia',
		'ga': 'Gabon',
		'gd': 'Grenada',
		'ge': 'Georgia',
		'gf': 'Guyana Francese',
		'gg': 'Guernsey',
		'gh': 'Ghana',
		'gi': 'Gibilterra',
		'gl': 'Groenlandia',
		'gm': 'Gambia',
		'gn': 'Guinea',
		'gp': 'Guadalupe',
		'gq': 'Guinea Equatoriale',
		'gr': 'Grecia',
		'gs': 'Georgia del Sud e Isole Sandwich Meridionali',
		'gt': 'Guatemala',
		'gu': 'Guam',
		'gw': 'Guinea-Bissau',
		'gy': 'Guyana',
		'hk': 'Hong Kong',
		'hm': 'Isole Heard e McDonald',
		'hn': 'Honduras',
		'hr': 'Croazia',
		'ht': 'Haiti',
		'hu': 'Ungheria',
		'id': 'Indonesia',
		'ie': 'Irlanda',
		'il': 'Israele',
		'im': 'Isola di Man',
		'in': 'India',
		'io': 'Territorio Britannico dell\'Oceano Indiano',
		'iq': 'Iraq',
		'ir': 'Iran (Repubblica Islamica di)',
		'is': 'Islanda',
		'it': 'Italia',
		'je': 'Jersey',
		'jm': 'Giamaica',
		'jo': 'Giordania',
		'jp': 'Giappone',
		'ke': 'Kenya',
		'kg': 'Kyrgyzstan',
		'kh': 'Cambogia',
		'ki': 'Kiribati',
		'km': 'Comoros',
		'kn': 'Saint Kitts e Nevis',
		'kp': 'Corea (Repubblica Democratica Popolare di)',
		'kr': 'Corea, Repubblica di',
		'kw': 'Kuwait',
		'ky': 'Isole Cayman',
		'kz': 'Kazakhstan',
		'la': 'Laos',
		'lb': 'Libano',
		'lc': 'Santa Lucia',
		'li': 'Liechtenstein',
		'lk': 'Sri Lanka',
		'lr': 'Liberia',
		'ls': 'Lesotho',
		'lt': 'Lituania',
		'lu': 'Lussemburgo',
		'lv': 'Lettonia',
		'ly': 'Libia',
		'ma': 'Marocco',
		'mc': 'Monaco',
		'md': 'Moldavia, Repubblica di',
		'me': 'Montenegro',
		'mf': 'Saint Martin (parte francese)',
		'mg': 'Madagascar',
		'mh': 'Isole Marshall',
		'mk': 'Macedonia del Nord',
		'ml': 'Mali',
		'mm': 'Myanmar',
		'mn': 'Mongolia',
		'mo': 'Macao',
		'mp': 'Commonwealth delle Isole Marianne Settentrionali',
		'mq': 'Martinica',
		'mr': 'Mauritania',
		'ms': 'Montserrat',
		'mt': 'Malta',
		'mu': 'Mauritius',
		'mv': 'Maldive',
		'mw': 'Malawi',
		'mx': 'Messico',
		'my': 'Malesia',
		'mz': 'Mozambico',
		'na': 'Namibia',
		'nc': 'Nuova Caledonia',
		'ne': 'Niger',
		'nf': 'Isola Norfolk',
		'ng': 'Nigeria',
		'ni': 'Nicaragua',
		'nl': 'Paesi bassi',
		'no': 'Norvegia',
		'np': 'Nepal',
		'nr': 'Nauru',
		'nu': 'Niue',
		'nz': 'Nuova zelanda',
		'om': 'Oman',
		'pa': 'Panama',
		'pe': 'Perù',
		'pf': 'Polinesia francese',
		'pg': 'Papua Nuova Guinea',
		'ph': 'Filippine',
		'pk': 'Pakistan',
		'pl': 'Polonia',
		'pm': 'Saint Pierre e Miquelon',
		'pn': 'Pitcairn',
		'pr': 'Porto Rico',
		'ps': 'Palestina, Stato di',
		'pt': 'Portogallo',
		'pw': 'Palau',
		'py': 'Paraguay',
		'qa': 'Qatar',
		're': 'Réunion',
		'ro': 'Romania',
		'rs': 'Serbia',
		'ru': 'Russia (Federazione Russa)',
		'rw': 'Rwanda',
		'sa': 'Arabia Saudita',
		'sb': 'Isole Solomone',
		'sc': 'Seychelles',
		'sd': 'Sudan',
		'se': 'Svezia',
		'sg': 'Singapore',
		'sh': 'Sant\'Elena, Ascensione e Tristan da Cunha',
		'si': 'Slovenia',
		'sj': 'Svalbard e Jan Mayen',
		'sk': 'Slovacchia',
		'sl': 'Sierra Leone',
		'sm': 'San Marino',
		'sn': 'Senegal',
		'so': 'Somalia',
		'sr': 'Suriname',
		'ss': 'Sud Sudan',
		'st': 'Sao Tome e Principe',
		'sv': 'El Salvador',
		'sx': 'Sint Maarten (parte olandese)',
		'sy': 'Siria, Repubblica Araba di',
		'sz': 'Eswatini',
		'tc': 'Isole Turk e Caicos',
		'td': 'Chad',
		'tf': 'Territori Francesi meridionali',
		'tg': 'Togo',
		'th': 'Thailandia',
		'tj': 'Tajikistan',
		'tk': 'Tokelau',
		'tl': 'Timor-Leste',
		'tm': 'Turkmenistan',
		'tn': 'Tunisia',
		'to': 'Tonga',
		'tr': 'Turchia',
		'tt': 'Trinidad e Tobago',
		'tv': 'Tuvalu',
		'tw': 'Taiwan',
		'tz': 'Tanzania, Repubblica Unita di',
		'ua': 'Ucraina',
		'ug': 'Uganda',
		'uk': 'Regno Unito di Gran Bretagna e Irlanda del Nord',
		'um': 'Isole minori esterne degli Stati Uniti',
		'us': 'Stati Uniti d\'America',
		'uy': 'Uruguay',
		'uz': 'Uzbekistan',
		'va': 'Santa Sede',
		'vc': 'Saint Vincent e Grenadine',
		've': 'Venezuela (Repubblica Bolivariana del)',
		'vg': 'Virgin Islands (Britanniche)',
		'vi': 'Virgin Islands (U.S.)',
		'vn': 'Vietnam',
		'vu': 'Vanuatu',
		'wf': 'Wallis e Futuna',
		'ws': 'Samoa',
		'ye': 'Yemen',
		'yt': 'Mayotte',
		'za': 'Sudafrica',
		'zm': 'Zambia',
		'zw': 'Zimbabwe',
		'world': 'Mondo',
	};
	@override late final Translations$food$categoryList$it categoryList = Translations$food$categoryList$it._(_root);
	@override late final Translations$food$categoryEditor$it categoryEditor = Translations$food$categoryEditor$it._(_root);
	@override late final Translations$food$categoryFoods$it categoryFoods = Translations$food$categoryFoods$it._(_root);
	@override late final Translations$food$permission$it permission = Translations$food$permission$it._(_root);
	@override late final Translations$food$datePicker$it datePicker = Translations$food$datePicker$it._(_root);
	@override late final Translations$food$catalog$it catalog = Translations$food$catalog$it._(_root);
	@override late final Translations$food$picker$it picker = Translations$food$picker$it._(_root);
	@override late final Translations$food$recipes$it recipes = Translations$food$recipes$it._(_root);
}

// Path: equipment
class Translations$equipment$it implements Translations$equipment$en {
	Translations$equipment$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$equipment$none$it none = Translations$equipment$none$it._(_root);
	@override late final Translations$equipment$barbell$it barbell = Translations$equipment$barbell$it._(_root);
	@override late final Translations$equipment$dumbbell$it dumbbell = Translations$equipment$dumbbell$it._(_root);
	@override late final Translations$equipment$cable$it cable = Translations$equipment$cable$it._(_root);
	@override late final Translations$equipment$machine$it machine = Translations$equipment$machine$it._(_root);
	@override late final Translations$equipment$kettlebell$it kettlebell = Translations$equipment$kettlebell$it._(_root);
	@override late final Translations$equipment$plates$it plates = Translations$equipment$plates$it._(_root);
	@override late final Translations$equipment$resistanceBand$it resistanceBand = Translations$equipment$resistanceBand$it._(_root);
	@override late final Translations$equipment$suspensionBands$it suspensionBands = Translations$equipment$suspensionBands$it._(_root);
	@override late final Translations$equipment$landmine$it landmine = Translations$equipment$landmine$it._(_root);
	@override late final Translations$equipment$other$it other = Translations$equipment$other$it._(_root);
}

// Path: achievements
class Translations$achievements$it implements Translations$achievements$en {
	Translations$achievements$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Conquiste';
	@override String get locked => 'Bloccato';
	@override String unlockedOn({required Object date}) => 'Sbloccato: ${date}';
	@override String get history => 'Cronologia';
	@override late final Translations$achievements$firstSteps$it firstSteps = Translations$achievements$firstSteps$it._(_root);
	@override late final Translations$achievements$foodWatcher$it foodWatcher = Translations$achievements$foodWatcher$it._(_root);
	@override late final Translations$achievements$marathoner$it marathoner = Translations$achievements$marathoner$it._(_root);
	@override late final Translations$achievements$earlyBird$it earlyBird = Translations$achievements$earlyBird$it._(_root);
	@override late final Translations$achievements$nightOwl$it nightOwl = Translations$achievements$nightOwl$it._(_root);
	@override late final Translations$achievements$realGymBro$it realGymBro = Translations$achievements$realGymBro$it._(_root);
	@override late final Translations$achievements$workoutFreak$it workoutFreak = Translations$achievements$workoutFreak$it._(_root);
	@override late final Translations$achievements$trailblazer$it trailblazer = Translations$achievements$trailblazer$it._(_root);
	@override late final Translations$achievements$cycleChampion$it cycleChampion = Translations$achievements$cycleChampion$it._(_root);
	@override late final Translations$achievements$professionalWeightlifter$it professionalWeightlifter = Translations$achievements$professionalWeightlifter$it._(_root);
	@override late final Translations$achievements$programPlanner$it programPlanner = Translations$achievements$programPlanner$it._(_root);
	@override late final Translations$achievements$perfectPlanner$it perfectPlanner = Translations$achievements$perfectPlanner$it._(_root);
	@override late final Translations$achievements$routineMaster$it routineMaster = Translations$achievements$routineMaster$it._(_root);
	@override late final Translations$achievements$intensityInnovator$it intensityInnovator = Translations$achievements$intensityInnovator$it._(_root);
	@override late final Translations$achievements$completionist$it completionist = Translations$achievements$completionist$it._(_root);
	@override late final Translations$achievements$notDrunk$it notDrunk = Translations$achievements$notDrunk$it._(_root);
	@override late final Translations$achievements$steamedHams$it steamedHams = Translations$achievements$steamedHams$it._(_root);
	@override late final Translations$achievements$swimsuitSeason$it swimsuitSeason = Translations$achievements$swimsuitSeason$it._(_root);
	@override late final Translations$achievements$pbBreaker$it pbBreaker = Translations$achievements$pbBreaker$it._(_root);
	@override late final Translations$achievements$sparta$it sparta = Translations$achievements$sparta$it._(_root);
	@override late final Translations$achievements$midnightRain$it midnightRain = Translations$achievements$midnightRain$it._(_root);
	@override late final Translations$achievements$equipmentSpecialist$it equipmentSpecialist = Translations$achievements$equipmentSpecialist$it._(_root);
	@override late final Translations$achievements$bodyweightBeast$it bodyweightBeast = Translations$achievements$bodyweightBeast$it._(_root);
}

// Path: workoutGenerator
class Translations$workoutGenerator$it implements Translations$workoutGenerator$en {
	Translations$workoutGenerator$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Genera allenamento';
	@override String get muscleGroups => 'Seleziona gruppi muscolari';
	@override String get equipment => 'Seleziona attrezzatura';
	@override late final Translations$workoutGenerator$actions$it actions = Translations$workoutGenerator$actions$it._(_root);
	@override late final Translations$workoutGenerator$success$it success = Translations$workoutGenerator$success$it._(_root);
	@override late final Translations$workoutGenerator$empty$it empty = Translations$workoutGenerator$empty$it._(_root);
}

// Path: boutique
class Translations$boutique$it implements Translations$boutique$en {
	Translations$boutique$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Schede';
	@override late final Translations$boutique$package$it package = Translations$boutique$package$it._(_root);
	@override Map<String, String> get errors => {
		'unknown': 'Caricamento fallito. Controlla la connessione a Internet e riprova.',
		'version': 'Questa versione dell\'app non è compatibile con lo store di schede. Aggiorna all\'ultima versione dell\'app e riprova.',
	};
	@override late final Translations$boutique$marketingUpdating$it marketingUpdating = Translations$boutique$marketingUpdating$it._(_root);
}

// Path: login
class Translations$login$it implements Translations$login$en {
	Translations$login$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Login';
	@override late final Translations$login$tabs$it tabs = Translations$login$tabs$it._(_root);
	@override late final Translations$login$errors$it errors = Translations$login$errors$it._(_root);
	@override late final Translations$login$fields$it fields = Translations$login$fields$it._(_root);
	@override late final Translations$login$buttons$it buttons = Translations$login$buttons$it._(_root);
	@override late final Translations$login$upsell$it upsell = Translations$login$upsell$it._(_root);
	@override late final Translations$login$verifyEmail$it verifyEmail = Translations$login$verifyEmail$it._(_root);
	@override late final Translations$login$presentation$it presentation = Translations$login$presentation$it._(_root);
	@override late final Translations$login$recovery$it recovery = Translations$login$recovery$it._(_root);
}

// Path: sync
class Translations$sync$it implements Translations$sync$en {
	Translations$sync$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$sync$conflict$it conflict = Translations$sync$conflict$it._(_root);
	@override late final Translations$sync$overwrite$it overwrite = Translations$sync$overwrite$it._(_root);
	@override String get inProgress => 'Sincronizzo';
}

// Path: bodyMeasurement.neck
class Translations$bodyMeasurement$neck$it implements Translations$bodyMeasurement$neck$en {
	Translations$bodyMeasurement$neck$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Collo';
}

// Path: bodyMeasurement.waist
class Translations$bodyMeasurement$waist$it implements Translations$bodyMeasurement$waist$en {
	Translations$bodyMeasurement$waist$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Vita';
}

// Path: bodyMeasurement.bodyFat
class Translations$bodyMeasurement$bodyFat$it implements Translations$bodyMeasurement$bodyFat$en {
	Translations$bodyMeasurement$bodyFat$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Percentuale di grasso corporeo';
}

// Path: bodyMeasurement.shoulder
class Translations$bodyMeasurement$shoulder$it implements Translations$bodyMeasurement$shoulder$en {
	Translations$bodyMeasurement$shoulder$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Spalla';
}

// Path: bodyMeasurement.chest
class Translations$bodyMeasurement$chest$it implements Translations$bodyMeasurement$chest$en {
	Translations$bodyMeasurement$chest$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Petto';
}

// Path: bodyMeasurement.leftBicep
class Translations$bodyMeasurement$leftBicep$it implements Translations$bodyMeasurement$leftBicep$en {
	Translations$bodyMeasurement$leftBicep$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Bicipite sinistro';
}

// Path: bodyMeasurement.rightBicep
class Translations$bodyMeasurement$rightBicep$it implements Translations$bodyMeasurement$rightBicep$en {
	Translations$bodyMeasurement$rightBicep$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Bicipite destro';
}

// Path: bodyMeasurement.leftForearm
class Translations$bodyMeasurement$leftForearm$it implements Translations$bodyMeasurement$leftForearm$en {
	Translations$bodyMeasurement$leftForearm$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Avambraccio sinistro';
}

// Path: bodyMeasurement.rightForearm
class Translations$bodyMeasurement$rightForearm$it implements Translations$bodyMeasurement$rightForearm$en {
	Translations$bodyMeasurement$rightForearm$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Avambraccio destro';
}

// Path: bodyMeasurement.abdomen
class Translations$bodyMeasurement$abdomen$it implements Translations$bodyMeasurement$abdomen$en {
	Translations$bodyMeasurement$abdomen$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Addome';
}

// Path: bodyMeasurement.hips
class Translations$bodyMeasurement$hips$it implements Translations$bodyMeasurement$hips$en {
	Translations$bodyMeasurement$hips$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Anche';
}

// Path: bodyMeasurement.leftThigh
class Translations$bodyMeasurement$leftThigh$it implements Translations$bodyMeasurement$leftThigh$en {
	Translations$bodyMeasurement$leftThigh$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Coscia sinistra';
}

// Path: bodyMeasurement.rightThigh
class Translations$bodyMeasurement$rightThigh$it implements Translations$bodyMeasurement$rightThigh$en {
	Translations$bodyMeasurement$rightThigh$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Coscia destra';
}

// Path: bodyMeasurement.leftCalf
class Translations$bodyMeasurement$leftCalf$it implements Translations$bodyMeasurement$leftCalf$en {
	Translations$bodyMeasurement$leftCalf$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Polpaccio sinistro';
}

// Path: bodyMeasurement.rightCalf
class Translations$bodyMeasurement$rightCalf$it implements Translations$bodyMeasurement$rightCalf$en {
	Translations$bodyMeasurement$rightCalf$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Polpaccio destro';
}

// Path: onboarding
class Translations$onboarding$it implements Translations$onboarding$en {
	Translations$onboarding$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$onboarding$buttons$it buttons = Translations$onboarding$buttons$it._(_root);
	@override late final Translations$onboarding$welcome$it welcome = Translations$onboarding$welcome$it._(_root);
	@override late final Translations$onboarding$notifications$it notifications = Translations$onboarding$notifications$it._(_root);
	@override late final Translations$onboarding$camera$it camera = Translations$onboarding$camera$it._(_root);
	@override late final Translations$onboarding$done$it done = Translations$onboarding$done$it._(_root);
	@override late final Translations$onboarding$login$it login = Translations$onboarding$login$it._(_root);
}

// Path: nags.routines
class Translations$nags$routines$it implements Translations$nags$routines$en {
	Translations$nags$routines$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Stai usando Gym Bro da un po\' di tempo, vero?';
	@override String get subtitle => 'Con Gym Bro Pro, puoi creare routine illimitate. Diventa un Pro Bro e porta i tuoi allenamenti al livello successivo!';
}

// Path: nags.library
class Translations$nags$library$it implements Translations$nags$library$en {
	Translations$nags$library$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Stai esplorando Gym Bro da un po\' di tempo, vero?';
	@override String get subtitle => 'Con Gym Bro Pro, puoi creare esercizi illimitati. Diventa un Pro Bro e porta i tuoi allenamenti al livello successivo!';
}

// Path: nags.history
class Translations$nags$history$it implements Translations$nags$history$en {
	Translations$nags$history$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Stai sfruttando Gym Bro da un bel po\' di tempo, sembra!';
	@override String get subtitle => 'Con Gym Bro Pro, puoi iniziare allenamenti illimitati. Diventa un Pro Bro e porta i tuoi allenamenti al livello successivo!';
}

// Path: nags.food
class Translations$nags$food$it implements Translations$nags$food$en {
	Translations$nags$food$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aspetta un attimo, non puoi ancora farlo.';
	@override String get subtitle => 'Con la versione Pro, puoi vedere i dati storici dei tuoi pasti. Diventa un Pro Bro e porta la tua nutrizione al livello successivo!';
}

// Path: feed
class Translations$feed$it implements Translations$feed$en {
	Translations$feed$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Feed';
	@override late final Translations$feed$empty$it empty = Translations$feed$empty$it._(_root);
	@override String get startWorkout => 'Scegli un allenamento';
	@override late final Translations$feed$workout$it workout = Translations$feed$workout$it._(_root);
	@override late final Translations$feed$achievement$it achievement = Translations$feed$achievement$it._(_root);
	@override late final Translations$feed$userButton$it userButton = Translations$feed$userButton$it._(_root);
	@override late final Translations$feed$noSync$it noSync = Translations$feed$noSync$it._(_root);
	@override String get noMoreData => 'Hai raggiunto la fine del feed :)';
	@override String get loadMore => 'Carica altro';
	@override String get suggestedRoutines => 'Routine suggerite';
	@override late final Translations$feed$suggestions$it suggestions = Translations$feed$suggestions$it._(_root);
	@override late final Translations$feed$loadError$it loadError = Translations$feed$loadError$it._(_root);
}

// Path: workoutPage
class Translations$workoutPage$it implements Translations$workoutPage$en {
	Translations$workoutPage$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Allenati';
}

// Path: pro
class Translations$pro$it implements Translations$pro$en {
	Translations$pro$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'PRO';
}

// Path: userProfile
class Translations$userProfile$it implements Translations$userProfile$en {
	Translations$userProfile$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profilo';
	@override String get addFriend => 'Aggiungi amico';
	@override String get unfriend => 'Rimuovi amico';
	@override String get requestSent => 'Richiesta inviata';
	@override late final Translations$userProfile$cancelRequestConfirmation$it cancelRequestConfirmation = Translations$userProfile$cancelRequestConfirmation$it._(_root);
	@override String get accept => 'Accetta';
	@override String get decline => 'Rifiuta';
	@override late final Translations$userProfile$unfriendConfirmation$it unfriendConfirmation = Translations$userProfile$unfriendConfirmation$it._(_root);
	@override String get reject => 'Rifiuta';
	@override late final Translations$userProfile$stats$it stats = Translations$userProfile$stats$it._(_root);
	@override late final Translations$userProfile$feed$it feed = Translations$userProfile$feed$it._(_root);
	@override late final Translations$userProfile$edit$it edit = Translations$userProfile$edit$it._(_root);
	@override late final Translations$userProfile$crop$it crop = Translations$userProfile$crop$it._(_root);
	@override late final Translations$userProfile$error$it error = Translations$userProfile$error$it._(_root);
	@override late final Translations$userProfile$errors$it errors = Translations$userProfile$errors$it._(_root);
}

// Path: friendRequests
class Translations$friendRequests$it implements Translations$friendRequests$en {
	Translations$friendRequests$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Richieste di amicizia';
	@override String get subtitle => 'ti ha inviato una richiesta di amicizia';
	@override late final Translations$friendRequests$empty$it empty = Translations$friendRequests$empty$it._(_root);
}

// Path: profileSearch
class Translations$profileSearch$it implements Translations$profileSearch$en {
	Translations$profileSearch$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cerca profili';
	@override String get searchHint => 'Cerca nome utente...';
	@override late final Translations$profileSearch$noResults$it noResults = Translations$profileSearch$noResults$it._(_root);
}

// Path: error
class Translations$error$it implements Translations$error$en {
	Translations$error$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Si è verificato un errore';
	@override String get retry => 'Riprova';
	@override String get logs => 'Apri log';
}

// Path: legacyWorkoutRecovery
class Translations$legacyWorkoutRecovery$it implements Translations$legacyWorkoutRecovery$en {
	Translations$legacyWorkoutRecovery$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Allenamento precedente da recuperare';
	@override String get action => 'Recupera in questo account';
	@override String confirm({required Object account}) => 'Recuperare questo allenamento in ${account}? Diventerà l’allenamento in corso di questo account.';
	@override String get guest => 'Ospite';
	@override String get failed => 'Impossibile recuperare l’allenamento. Verifica che questo account non abbia un allenamento in corso, poi riprova.';
}

// Path: friendsList
class Translations$friendsList$it implements Translations$friendsList$en {
	Translations$friendsList$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get loadMore => 'Carica altri';
	@override String get title => 'Amici';
	@override String get empty => 'Non hai ancora amici';
	@override String get emptyDescription => 'Le amicizie accettate appariranno qui.';
	@override String historyTitle({required Object name}) => 'Traguardi di ${name}';
	@override String get historyEmpty => 'Nessun traguardo ottenuto';
	@override String get historyEmptyDescription => 'I traguardi ottenuti da questo amico appariranno qui.';
	@override String get unknownAchievement => 'Traguardo sconosciuto';
	@override String get accessDenied => 'La cronologia è disponibile solo per i tuoi amici.';
}

// Path: social
class Translations$social$it implements Translations$social$en {
	Translations$social$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get notifications => 'Notifiche';
	@override String get post => 'Post';
	@override String get comments => 'Commenti';
	@override String get comment => 'Commenta';
	@override String get like => 'Mi piace';
	@override String get unlike => 'Non mi piace più';
	@override String get send => 'Invia';
	@override String get edit => 'Modifica';
	@override String get delete => 'Elimina';
	@override String get more => 'Carica altri';
	@override String get private => 'Solo io';
	@override String get friends => 'Amici';
	@override String get visibility => 'Visibilità';
	@override String get pending => 'Modifica in attesa di sincronizzazione';
	@override String get unpublished => 'In attesa di pubblicazione';
	@override String get unavailable => 'Contenuto non disponibile';
	@override String get error => 'Operazione non riuscita. Riprova.';
	@override String get empty => 'Non ci sono elementi da mostrare.';
	@override String get block => 'Blocca utente';
	@override String get unblock => 'Sblocca';
	@override String get blockedUsers => 'Utenti bloccati';
	@override String get report => 'Segnala utente';
	@override String get reports => 'Le mie segnalazioni';
	@override String get reason => 'Motivazione (obbligatoria)';
	@override String get reportSent => 'Segnalazione inviata';
	@override String get blockConfirm => 'Bloccare questo utente? L’amicizia e le richieste verranno eliminate.';
	@override String get cancel => 'Annulla';
	@override String get confirm => 'Conferma';
	@override String get received => 'Ricevuta';
	@override String get reviewing => 'In esame';
	@override String get resolved => 'Risolta';
	@override String get dismissed => 'Archiviata';
	@override String get friendRequest => 'Ti ha inviato una richiesta di amicizia';
	@override String get friendAccepted => 'Ha accettato la tua richiesta di amicizia';
	@override String get likedPost => 'Ha messo Mi piace al tuo post';
	@override String get commentedPost => 'Ha commentato il tuo post';
	@override String get achievementUnlocked => 'Ha sbloccato un achievement';
	@override String get reportUpdated => 'Lo stato della tua segnalazione è cambiato';
	@override String get accept => 'Accetta';
	@override String get reject => 'Rifiuta';
	@override String get signIn => 'Accedi per continuare';
	@override String get save => 'Salva';
	@override String get push => 'Notifiche push';
	@override String get pushDescription => 'Richieste, interazioni, achievement e segnalazioni';
	@override String get pushDisabled => 'Push non configurate su questo dispositivo';
	@override String get trainerPlan => 'Il tuo trainer ha pubblicato una scheda o una revisione';
}

// Path: hydration
class Translations$hydration$it implements Translations$hydration$en {
	Translations$hydration$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Acqua';
	@override String get drinking => 'Acqua bevuta';
	@override String get food => 'Dagli alimenti';
	@override String get add => 'Aggiungi acqua';
	@override String get custom => 'Quantità personalizzata';
	@override String get amount => 'Quantità (ml)';
	@override String get time => 'Orario';
	@override String get goal => 'Obiettivo giornaliero (ml)';
	@override String get setGoal => 'Imposta obiettivo';
	@override String get noGoal => 'Nessun obiettivo impostato';
	@override String get optionalGoal => 'Lascia vuoto per rimuovere l’obiettivo';
	@override String get save => 'Salva';
	@override String get cancel => 'Annulla';
	@override String get delete => 'Elimina';
	@override String get edit => 'Modifica';
	@override String get invalid => 'Inserisci una quantità positiva valida';
	@override String get future => 'Scegli un orario nel passato';
	@override String get connect => 'Collega a Salute';
	@override String get disconnect => 'Disattiva invio a Salute';
	@override String get disabled => 'Invio a Salute disattivato';
	@override String get synced => 'Acqua sincronizzata con Salute';
	@override String get pending => 'Invio a Salute in attesa: controlla i permessi e riprova';
	@override String get unavailable => 'Servizio Salute non disponibile';
	@override String get syncing => 'Invio a Salute…';
	@override String get empty => 'Nessuna acqua bevuta registrata';
	@override String get error => 'Impossibile salvare. Riprova.';
	@override String get natural => 'Acqua naturale';
	@override String get sparkling => 'Acqua frizzante';
	@override String get cucumber => 'Cetriolo con buccia, crudo';
	@override String get tomato => 'Pomodoro rosso, crudo';
	@override String get watermelon => 'Anguria, cruda';
	@override String get apple => 'Mela con buccia, cruda';
	@override String get source => 'Fonte: USDA SR Legacy';
	@override String get waterPer100 => 'Acqua (ml per 100 g/ml)';
	@override String get history => 'Cronologia acqua';
	@override String get permissionDenied => 'L’acqua viene salvata nel diario. Per aggiungerla anche a Salute, consenti l’accesso da Impostazioni → Autorizzazioni.';
}

// Path: reports
class Translations$reports$it implements Translations$reports$en {
	Translations$reports$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Report progressi';
	@override String get day => 'Giorno';
	@override String get week => 'Settimana';
	@override String get month => 'Mese';
	@override String get training => 'Allenamento';
	@override String get nutrition => 'Alimentazione';
	@override String get measurements => 'Misurazioni corporee';
	@override String get preview => 'Anteprima report';
	@override String get save => 'Salva PDF';
	@override String get share => 'Condividi';
	@override String get reference => 'Data di riferimento';
	@override String get chooseSection => 'Seleziona almeno una sezione.';
	@override String get empty => 'Nessuna registrazione nel periodo.';
	@override String get missing => 'Nessuna registrazione';
	@override String get unavailable => 'Non disponibile';
	@override String get error => 'Impossibile generare il report. Riprova.';
	@override String get exportError => 'Impossibile esportare il PDF. Riprova.';
	@override String get retry => 'Riprova';
	@override String get saved => 'PDF salvato';
	@override String get generated => 'Generato il';
	@override String get daily => 'Dettaglio giornaliero';
	@override String get summary => 'Riepilogo';
	@override String get sessions => 'Sessioni';
	@override String get sets => 'Serie completate';
	@override String get reps => 'Ripetizioni';
	@override String get load => 'Carico';
	@override String get duration => 'Durata';
	@override String get distance => 'Distanza';
	@override String get volume => 'Volume (carichi positivi × ripetizioni)';
	@override String get exercise => 'Esercizio';
	@override String get status => 'Stato';
	@override String get done => 'Completata';
	@override String get pending => 'Non completata';
	@override String get superset => 'Superserie';
	@override String get continuation => 'Continuazione';
	@override String get food => 'Alimento / pasto';
	@override String get quantity => 'Quantità';
	@override String get calories => 'Calorie';
	@override String get protein => 'Proteine';
	@override String get carbs => 'Carboidrati';
	@override String get fat => 'Grassi';
	@override String get total => 'Totale';
	@override String get average => 'Media per giorno registrato';
	@override String get coverage => 'Giorni con registrazioni';
	@override String get first => 'Prima';
	@override String get last => 'Ultima';
	@override String get change => 'Variazione';
	@override String get value => 'Valore';
	@override String get date => 'Data';
	@override String get goal => 'Obiettivo giornaliero salvato';
	@override String get criteria => 'Le medie alimentari usano solo i giorni con alimenti registrati, inclusi i valori zero. I totali descrivono gli alimenti registrati, non necessariamente giornate complete. Le registrazioni assenti non equivalgono a zero. I totali di allenamento comprendono solo le serie svolte; il volume include solo carichi positivi con ripetizioni. Le variazioni corporee usano la prima e l’ultima misura effettiva del periodo. Nessuna interpolazione o misura prevista. I grafici corporei mostrano l’ultima misura effettiva di ogni giorno.';
	@override String get partial => 'Periodo in corso: sono incluse solo le registrazioni disponibili alla generazione.';
	@override String get units => 'Unità';
	@override String get activityChart => 'Serie completate per giorno';
	@override String get calorieChart => 'Calorie registrate per giorno';
	@override String get chartNote => 'I punti indicano valori registrati. I giorni senza dati restano vuoti, senza interpolazione.';
	@override String get privacy => 'Report locale · Nessuna valutazione medica o nutrizionale';
	@override String get selection => 'Contenuto del report';
	@override String get weight => 'Peso';
	@override String get configureDescription => 'Crea un report dei tuoi progressi da salvare o condividere con il tuo professionista.';
	@override String get period => 'Periodo';
	@override String get includedPeriod => 'Periodo incluso nel report';
	@override String get weekReferenceHint => 'Scegli un giorno della settimana da includere.';
	@override String get monthReferenceHint => 'Scegli un giorno del mese da includere.';
	@override String get selectionHint => 'Scegli una o più sezioni da inserire nel PDF.';
	@override String get previewTitle => 'Anteprima PDF';
}

// Path: plateau
class Translations$plateau$it implements Translations$plateau$en {
	Translations$plateau$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Possibili plateau';
	@override String get intro => 'Ultime 8 settimane, considerando solo le serie normali completate. A seguire sono riportati suggerimenti basati sull\'analisi dei dati, che non vanno presi come certezza.';
	@override String get criteria => 'Servono 6 sedute confrontabili in almeno 28 giorni e 4 settimane di calendario, di cui l’ultima entro 14 giorni, senza pause oltre i 21 giorni. Il riferimento è la mediana delle prime 3 sedute. Viene considerato progresso: +2,5% di carico senza perdere ripetizioni, +1 ripetizione a carico equivalente (±1%) oppure +5% di volume. A corpo libero: +1 ripetizione nella serie migliore o +5% di ripetizioni totali.';
	@override String get possiblePlateau => 'Possibile plateau';
	@override String get progressing => 'Nessun possibile plateau rilevato';
	@override String get insufficientData => 'Servono più dati: registra almeno 6 sedute confrontabili distribuite su 4 settimane.';
	@override String get stale => 'Mancano sedute confrontabili recenti: riprendi a registrare questo esercizio prima di valutarne i progressi.';
	@override String get unsupported => 'Non valutato: assistenza, tempo e distanza non offrono metriche confrontabili di carico e ripetizioni.';
	@override String get incomparable => 'Non valutato: identità, definizione dell’esercizio o più sedute nello stesso giorno impediscono un confronto affidabile.';
	@override String get empty => 'Servono più dati. Registra serie completati per diverse settimane per valutare i progressi.';
	@override String get period => 'Periodo';
	@override String get sessions => 'Sedute';
	@override String get sets => 'Serie normali per seduta';
	@override String get reference => 'Riferimento: mediana delle prime 3 sedute';
	@override String get load => 'Carico massimo';
	@override String get reps => 'Ripetizioni al carico massimo';
	@override String get bestReps => 'Ripetizioni massime per serie';
	@override String get totalReps => 'Ripetizioni totali';
	@override String get volume => 'Volume della seduta';
	@override String get data => 'Sedute utilizzate';
	@override String get other => 'Altri esercizi';
	@override String get volumeInfo => 'Volume = somma di carico × ripetizioni delle serie selezionati. Il corpo libero viene valutato solo tramite le ripetizioni.';
}

// Path: progression
class Translations$progression$it implements Translations$progression$en {
	Translations$progression$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Progressione guidata';
	@override String get configure => 'Imposta progressione';
	@override String get remove => 'Rimuovi progressione';
	@override String get lastTime => 'Ultima volta';
	@override String get noHistory => 'Completa una sessione per vedere l\'ultima prestazione';
	@override String get goal => 'Obiettivo di oggi';
	@override String get double => 'Doppia progressione';
	@override String get cyclic => 'Progressione lineare ciclica';
	@override String get minReps => 'Ripetizioni minime';
	@override String get maxReps => 'Ripetizioni massime';
	@override String get repsPerStep => 'Ripetizioni per passo';
	@override String get startingWeight => 'Peso iniziale';
	@override String get weightPerStep => 'Aumento del peso per passo';
	@override String get weightPerCycle => 'Aumento del peso iniziale per ciclo';
	@override String get preview => 'Prossimi obiettivi';
	@override String get save => 'Salva';
	@override String get invalid => 'Controlla i valori e il numero di serie normali';
	@override String step({required Object cycle, required Object step}) => 'Ciclo ${cycle}, passo ${step}';
	@override String get advance => 'Avanza manualmente';
}

// Path: paywall
class Translations$paywall$it implements Translations$paywall$en {
	Translations$paywall$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'GymBro Pro';
	@override String get subtitle => 'Scegli un abbonamento per sbloccare le funzionalità Pro.';
	@override String get loadError => 'Impossibile caricare gli abbonamenti. Riprova.';
	@override String get empty => 'Nessun abbonamento disponibile al momento. Riprova più tardi.';
	@override late final Translations$paywall$trialPeriod$it trialPeriod = Translations$paywall$trialPeriod$it._(_root);
	@override late final Translations$paywall$autoRenewNotice$it autoRenewNotice = Translations$paywall$autoRenewNotice$it._(_root);
	@override late final Translations$paywall$purchaseError$it purchaseError = Translations$paywall$purchaseError$it._(_root);
	@override late final Translations$paywall$restoreError$it restoreError = Translations$paywall$restoreError$it._(_root);
	@override late final Translations$paywall$actions$it actions = Translations$paywall$actions$it._(_root);
}

// Path: routineImport
class Translations$routineImport$it implements Translations$routineImport$en {
	Translations$routineImport$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get summary => 'Contenuto da importare';
	@override String get summaryDescription => 'Importa una copia personale. Il programma condiviso rimarrà invariato.';
	@override String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: '1 giornata',
		other: '${n} giornate',
	);
	@override String exercises({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: '1 esercizio',
		other: '${n} esercizi',
	);
	@override String sets({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: '1 serie',
		other: '${n} serie',
	);
	@override String get preview => 'Anteprima allenamento';
	@override String get day => 'Giornata';
	@override String get dayDescription => 'Scegli una giornata da consultare. Verrà importato il programma completo.';
	@override String get programNotes => 'Note del programma';
	@override String get workoutNotes => 'Note dell’allenamento';
	@override String get exerciseList => 'Esercizi';
	@override String get emptyTitle => 'Nessun esercizio in questa giornata';
	@override String get emptyDescription => 'Questa giornata non contiene ancora esercizi da svolgere.';
	@override String get noSets => 'Nessuna serie prescritta';
	@override String get custom => 'Esercizio personalizzato';
	@override String get assistance => 'Assistenza';
	@override String rest({required Object duration}) => 'Recupero ${duration}';
	@override String setNumber({required Object number}) => 'Serie ${number}';
	@override String seconds({required Object count}) => '${count} s';
	@override String get loadingTitle => 'Apertura del programma condiviso';
	@override String get loadingDescription => 'Caricamento delle giornate e delle prescrizioni.';
	@override String get unavailableTitle => 'Programma non disponibile';
	@override String get retry => 'Riprova';
	@override String get proRequired => 'Per importare le schede condivise è necessario Gym Bro Pro.';
	@override String get importing => 'Importazione…';
	@override String get loadError => 'Si è verificato un problema. Riprova tra poco.';
	@override String get networkError => 'Impossibile connettersi. Controlla la connessione e riprova.';
}

// Path: set.kindShort
class Translations$set$kindShort$it implements Translations$set$kindShort$en {
	Translations$set$kindShort$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get warmUp => 'R';
	@override String get drop => 'D';
	@override String get failure => 'C';
	@override String get failureStripping => 'S';
}

// Path: set.kinds
class Translations$set$kinds$it implements Translations$set$kinds$en {
	Translations$set$kinds$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override Map<String, String> get help => {
		'title': 'Cosa significa?',
		'warmUp': 'Una serie di riscaldamento è una serie leggera di un esercizio che esegui prima delle serie di lavoro effettive. Il suo scopo è preparare i muscoli per il lavoro pesante imminente.',
		'normal': 'Una serie normale è una serie regolare di un esercizio, in cui esegui un certo numero di ripetizioni con un certo peso.',
		'drop': 'Una serie di drop ("Drop set") è una serie in cui abbassi il peso dopo aver raggiunto il cedimento muscolare e continui a eseguire ripetizioni con il peso inferiore.',
		'failure': 'Una serie a cedimento è una serie in cui esegui ripetizioni fino a raggiungere il cedimento muscolare.',
		'failureStripping': 'Una serie a cedimento con stripping è una serie a cedimento che parte immediatamente dalla serie precedente (quindi senza recupero), in cui esegui ripetizioni fino a raggiungere il cedimento muscolare.',
	};
}

// Path: exercise.chart
class Translations$exercise$chart$it implements Translations$exercise$chart$en {
	Translations$exercise$chart$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exercise$chart$views$it views = Translations$exercise$chart$views$it._(_root);
}

// Path: exercise.fields
class Translations$exercise$fields$it implements Translations$exercise$fields$en {
	Translations$exercise$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get restTime => 'Recupero';
	@override String get weight => 'Peso';
	@override String get time => 'Tempo';
	@override String get reps => 'Ripetizioni';
	@override String get distance => 'Distanza';
}

// Path: exercise.actions
class Translations$exercise$actions$it implements Translations$exercise$actions$en {
	Translations$exercise$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get addSet => '+ Aggiungi serie';
}

// Path: exercise.editor
class Translations$exercise$editor$it implements Translations$exercise$editor$en {
	Translations$exercise$editor$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exercise$editor$create$it create = Translations$exercise$editor$create$it._(_root);
	@override late final Translations$exercise$editor$edit$it edit = Translations$exercise$editor$edit$it._(_root);
	@override late final Translations$exercise$editor$fields$it fields = Translations$exercise$editor$fields$it._(_root);
	@override late final Translations$exercise$editor$cannotChangeParameters$it cannotChangeParameters = Translations$exercise$editor$cannotChangeParameters$it._(_root);
	@override late final Translations$exercise$editor$setless$it setless = Translations$exercise$editor$setless$it._(_root);
	@override late final Translations$exercise$editor$overwriteInWorkout$it overwriteInWorkout = Translations$exercise$editor$overwriteInWorkout$it._(_root);
	@override late final Translations$exercise$editor$advanced$it advanced = Translations$exercise$editor$advanced$it._(_root);
}

// Path: exercise.picker
class Translations$exercise$picker$it implements Translations$exercise$picker$en {
	Translations$exercise$picker$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Seleziona esercizi';
	@override late final Translations$exercise$picker$errors$it errors = Translations$exercise$picker$errors$it._(_root);
	@override late final Translations$exercise$picker$filter$it filter = Translations$exercise$picker$filter$it._(_root);
}

// Path: exercise.info
class Translations$exercise$info$it implements Translations$exercise$info$en {
	Translations$exercise$info$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Info esercizio';
	@override String get viewWorkout => 'Vedi allenamento';
	@override String get noHistory => 'Non ci sono allenamenti per questo esercizio.';
	@override late final Translations$exercise$info$heaviestWeight$it heaviestWeight = Translations$exercise$info$heaviestWeight$it._(_root);
	@override late final Translations$exercise$info$best1rm$it best1rm = Translations$exercise$info$best1rm$it._(_root);
	@override late final Translations$exercise$info$bestSetVolume$it bestSetVolume = Translations$exercise$info$bestSetVolume$it._(_root);
	@override late final Translations$exercise$info$bestSessionVolume$it bestSessionVolume = Translations$exercise$info$bestSessionVolume$it._(_root);
	@override String get usefulData => 'Dati utili';
	@override String get home => 'Home';
	@override String get history => 'Cronologia';
	@override String get explanation => 'Spiegazione';
	@override String get explanationDisclaimer => 'Nota che questa spiegazione è fornita a puro scopo informativo, e non sostituisce il parere di un trainer qualificato.';
	@override String primaryMuscleGroup({required Object muscleGroup}) => 'Gruppo muscolare: ${muscleGroup}';
	@override String secondaryMuscleGroups({required Object muscleGroups}) => 'Gruppi muscolari secondari: ${muscleGroups}';
	@override String equipment({required Object equipment}) => 'Attrezzatura: ${equipment}';
	@override late final Translations$exercise$info$explanationNone$it explanationNone = Translations$exercise$info$explanationNone$it._(_root);
}

// Path: exercise.continuation
class Translations$exercise$continuation$it implements Translations$exercise$continuation$en {
	Translations$exercise$continuation$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Continuazione';
	@override String get description => 'Tocca per unire i due allenamenti in un\'unica voce.';
	@override late final Translations$exercise$continuation$combine$it combine = Translations$exercise$continuation$combine$it._(_root);
}

// Path: exercise.delete
class Translations$exercise$delete$it implements Translations$exercise$delete$en {
	Translations$exercise$delete$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Elimina esercizio';
	@override String get body => 'Vuoi davvero eliminare questo esercizio? Quest\'azione non può essere annullata.';
}

// Path: workouts.actions
class Translations$workouts$actions$it implements Translations$workouts$actions$en {
	Translations$workouts$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$workouts$actions$delete$it delete = Translations$workouts$actions$delete$it._(_root);
	@override String get start => 'Ripeti allenamento';
	@override late final Translations$workouts$actions$edit$it edit = Translations$workouts$actions$edit$it._(_root);
	@override late final Translations$workouts$actions$editContinuation$it editContinuation = Translations$workouts$actions$editContinuation$it._(_root);
	@override late final Translations$workouts$actions$rename$it rename = Translations$workouts$actions$rename$it._(_root);
	@override late final Translations$workouts$actions$changeParent$it changeParent = Translations$workouts$actions$changeParent$it._(_root);
	@override late final Translations$workouts$actions$saveAsRoutine$it saveAsRoutine = Translations$workouts$actions$saveAsRoutine$it._(_root);
	@override String get kContinue => 'Continua quest\'allenamento';
	@override late final Translations$workouts$actions$share$it share = Translations$workouts$actions$share$it._(_root);
}

// Path: routines.quickWorkout
class Translations$routines$quickWorkout$it implements Translations$routines$quickWorkout$en {
	Translations$routines$quickWorkout$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Allenamento libero';
	@override String get subtitle => 'Inizia senza una routine';
	@override String get proLimit => 'Hai raggiunto il limite gratuito di allenamenti. Continua con PRO.';
}

// Path: routines.actions
class Translations$routines$actions$it implements Translations$routines$actions$en {
	Translations$routines$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$routines$actions$delete$it delete = Translations$routines$actions$delete$it._(_root);
	@override String get edit => 'Modifica routine';
	@override String get start => 'Avvia routine';
	@override String get create => 'Crea routine';
	@override String get viewHistory => 'Cronologia';
	@override late final Translations$routines$actions$deleteFolder$it deleteFolder = Translations$routines$actions$deleteFolder$it._(_root);
}

// Path: routines.editor
class Translations$routines$editor$it implements Translations$routines$editor$en {
	Translations$routines$editor$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$routines$editor$exercises$it exercises = Translations$routines$editor$exercises$it._(_root);
	@override late final Translations$routines$editor$fields$it fields = Translations$routines$editor$fields$it._(_root);
	@override late final Translations$routines$editor$superset$it superset = Translations$routines$editor$superset$it._(_root);
}

// Path: routines.loadError
class Translations$routines$loadError$it implements Translations$routines$loadError$en {
	Translations$routines$loadError$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impossibile caricare le routine';
	@override String get text => 'Riprova per caricare le routine e le cartelle.';
}

// Path: history.actions
class Translations$history$actions$it implements Translations$history$actions$en {
	Translations$history$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$history$actions$deleteMultiple$it deleteMultiple = Translations$history$actions$deleteMultiple$it._(_root);
}

// Path: settings.options
class Translations$settings$options$it implements Translations$settings$options$en {
	Translations$settings$options$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$settings$options$useDynamicColor$it useDynamicColor = Translations$settings$options$useDynamicColor$it._(_root);
	@override late final Translations$settings$options$color$it color = Translations$settings$options$color$it._(_root);
	@override late final Translations$settings$options$locale$it locale = Translations$settings$options$locale$it._(_root);
	@override late final Translations$settings$options$weightUnit$it weightUnit = Translations$settings$options$weightUnit$it._(_root);
	@override late final Translations$settings$options$distanceUnit$it distanceUnit = Translations$settings$options$distanceUnit$it._(_root);
	@override late final Translations$settings$options$showSuggestedRoutines$it showSuggestedRoutines = Translations$settings$options$showSuggestedRoutines$it._(_root);
	@override late final Translations$settings$options$import$it import = Translations$settings$options$import$it._(_root);
	@override late final Translations$settings$options$themeMode$it themeMode = Translations$settings$options$themeMode$it._(_root);
	@override late final Translations$settings$options$export$it export = Translations$settings$options$export$it._(_root);
	@override late final Translations$settings$options$notifications$it notifications = Translations$settings$options$notifications$it._(_root);
	@override late final Translations$settings$options$tintExercises$it tintExercises = Translations$settings$options$tintExercises$it._(_root);
	@override late final Translations$settings$options$defaultToSimpleWorkoutView$it defaultToSimpleWorkoutView = Translations$settings$options$defaultToSimpleWorkoutView$it._(_root);
	@override late final Translations$settings$options$exportSQL$it exportSQL = Translations$settings$options$exportSQL$it._(_root);
	@override String get nutritionLanguage => 'Lingua di ricerca alimenti';
	@override String get nutritionCountry => 'Paese di ricerca alimenti';
	@override late final Translations$settings$options$health$it health = Translations$settings$options$health$it._(_root);
}

// Path: settings.colorPicker
class Translations$settings$colorPicker$it implements Translations$settings$colorPicker$en {
	Translations$settings$colorPicker$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$settings$colorPicker$heading$it heading = Translations$settings$colorPicker$heading$it._(_root);
}

// Path: settings.advanced
class Translations$settings$advanced$it implements Translations$settings$advanced$en {
	Translations$settings$advanced$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impostazioni avanzate';
	@override String get subtitle => 'Lasciate ogni speranza, o voi ch\'entrate';
	@override late final Translations$settings$advanced$options$it options = Translations$settings$advanced$options$it._(_root);
	@override late final Translations$settings$advanced$deleteAccount$it deleteAccount = Translations$settings$advanced$deleteAccount$it._(_root);
}

// Path: settings.panes
class Translations$settings$panes$it implements Translations$settings$panes$en {
	Translations$settings$panes$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get appearance => 'Aspetto';
	@override String get units => 'Unità';
	@override String get permissions => 'Autorizzazioni';
	@override String get off => 'OpenFoodFacts';
}

// Path: settings.permissions
class Translations$settings$permissions$it implements Translations$settings$permissions$en {
	Translations$settings$permissions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get tapToRequest => 'Tocca per richiedere l\'autorizzazione';
}

// Path: settings.pro
class Translations$settings$pro$it implements Translations$settings$pro$en {
	Translations$settings$pro$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Gestisci il tuo abbonamento';
}

// Path: settings.logoutWarning
class Translations$settings$logoutWarning$it implements Translations$settings$logoutWarning$en {
	Translations$settings$logoutWarning$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vuoi uscire?';
	@override String get content => 'Potrai rientrare dalla scheda Profilo.';
}

// Path: ongoingWorkout.actions
class Translations$ongoingWorkout$actions$it implements Translations$ongoingWorkout$actions$en {
	Translations$ongoingWorkout$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get finish => 'Termina allenamento';
	@override String get cancel => 'Scarta allenamento';
	@override late final Translations$ongoingWorkout$actions$short$it short = Translations$ongoingWorkout$actions$short$it._(_root);
	@override String get changeWeightUnit => 'Cambia unità di peso';
	@override String get changeDistanceUnit => 'Cambia unità di distanza';
}

// Path: ongoingWorkout.exercises
class Translations$ongoingWorkout$exercises$it implements Translations$ongoingWorkout$exercises$en {
	Translations$ongoingWorkout$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get add => '+ Aggiungi esercizio';
	@override String get addSuperset => '+ Aggiungi superserie';
	@override String get replace => 'Cambia esercizio…';
	@override String get reorder => 'Riordina esercizi…';
	@override String get reorderSets => 'Riordina serie…';
	@override String get remove => 'Rimuovi esercizio';
	@override String get addToSuperset => 'Aggiungi a superserie…';
	@override String get startCardioTimer => 'Avvia timer a intervalli';
	@override String rpeBadge({required Object rpe}) => 'RPE ${rpe}';
	@override String get setRPE => 'Imposta RPE';
	@override String get generate => 'Genera';
}

// Path: ongoingWorkout.info
class Translations$ongoingWorkout$info$it implements Translations$ongoingWorkout$info$en {
	Translations$ongoingWorkout$info$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get time => 'Tempo';
	@override String get reps => 'Ripetizioni';
	@override String get volume => 'Volume sollevato';
	@override String get heartRate => 'BPM';
	@override String get activeEnergy => 'KCAL';
}

// Path: ongoingWorkout.finish
class Translations$ongoingWorkout$finish$it implements Translations$ongoingWorkout$finish$en {
	Translations$ongoingWorkout$finish$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Termina allenamento';
	@override late final Translations$ongoingWorkout$finish$fields$it fields = Translations$ongoingWorkout$finish$fields$it._(_root);
	@override String get save => 'Salva allenamento';
	@override String get saving => 'Salvataggio…';
	@override String get saveError => 'Impossibile salvare l’allenamento. Riprova: le modifiche sono ancora qui.';
	@override late final Translations$ongoingWorkout$finish$discard$it discard = Translations$ongoingWorkout$finish$discard$it._(_root);
}

// Path: ongoingWorkout.cancel
class Translations$ongoingWorkout$cancel$it implements Translations$ongoingWorkout$cancel$en {
	Translations$ongoingWorkout$cancel$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Scartare l\'allenamento?';
	@override String get text => 'Non potrai annullare quest\'azione se cambi idea.';
	@override late final Translations$ongoingWorkout$cancel$actions$it actions = Translations$ongoingWorkout$cancel$actions$it._(_root);
}

// Path: ongoingWorkout.overwrite
class Translations$ongoingWorkout$overwrite$it implements Translations$ongoingWorkout$overwrite$en {
	Translations$ongoingWorkout$overwrite$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Avviare l\'allenamento?';
	@override String get text => 'L\'allenamento in corso sarà sovrascritto.';
	@override late final Translations$ongoingWorkout$overwrite$actions$it actions = Translations$ongoingWorkout$overwrite$actions$it._(_root);
}

// Path: ongoingWorkout.superset
class Translations$ongoingWorkout$superset$it implements Translations$ongoingWorkout$superset$en {
	Translations$ongoingWorkout$superset$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get replaceWithExercise => 'Cambia con esercizio';
	@override String get remove => 'Rimuovi superserie';
}

// Path: ongoingWorkout.stopwatch
class Translations$ongoingWorkout$stopwatch$it implements Translations$ongoingWorkout$stopwatch$en {
	Translations$ongoingWorkout$stopwatch$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Cronometro';
	@override String get start => 'Avvia';
	@override String get pause => 'Pausa';
	@override String get reset => 'Resetta';
}

// Path: ongoingWorkout.simple
class Translations$ongoingWorkout$simple$it implements Translations$ongoingWorkout$simple$en {
	Translations$ongoingWorkout$simple$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => 'Allenamento completato';
	@override String get completedDescription => 'Hai completato tutte le serie. Salva il tuo allenamento o aggiungi un esercizio.';
	@override String get emptyTitle => 'Pronto ad allenarti?';
	@override String get emptyDescription => 'Aggiungi un esercizio per iniziare la tua sessione.';
	@override String exercisePosition({required Object current, required Object total}) => '${current} di ${total}';
	@override String setPosition({required Object current, required Object total}) => 'Serie ${current} di ${total}';
	@override String get customExercise => 'Personalizzato';
	@override String get completeSet => 'Completa serie';
	@override String get repUnit => 'rep';
	@override String decreaseValue({required Object field}) => 'Diminuisci ${field}';
	@override String increaseValue({required Object field}) => 'Aumenta ${field}';
	@override String get historyAndProgression => 'Storico e progressione';
	@override String get historySummary => 'Consulta l’ultima sessione e gli obiettivi';
	@override String get progressionSummary => 'Progressione attiva · consulta gli obiettivi';
	@override String get nextUp => 'Prossimo:';
	@override String get switchToFull => 'Passa alla vista completa';
	@override String get restTimer => 'Avvia timer di recupero';
	@override String get setControls => 'Controlli serie';
	@override String get previousSet => 'Serie precedente';
	@override String get nextSet => 'Serie successiva';
	@override String get setKind => 'Tipo di serie';
	@override String get editSet => 'Modifica parametri serie';
	@override String get supersetNotes => 'Note superserie';
	@override String get markAsDone => 'Segna serie come completata';
	@override String get markAsUndone => 'Segna serie come non completata';
}

// Path: ongoingWorkout.toolbox
class Translations$ongoingWorkout$toolbox$it implements Translations$ongoingWorkout$toolbox$en {
	Translations$ongoingWorkout$toolbox$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Strumenti';
}

// Path: ongoingWorkout.updateRoutine
class Translations$ongoingWorkout$updateRoutine$it implements Translations$ongoingWorkout$updateRoutine$en {
	Translations$ongoingWorkout$updateRoutine$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get differenceTitle => 'Aggiorna routine';
	@override String get differenceText => 'Hai modificato l\'allenamento. Vuoi aggiornare la routine di base?';
	@override late final Translations$ongoingWorkout$updateRoutine$differences$it differences = Translations$ongoingWorkout$updateRoutine$differences$it._(_root);
}

// Path: ongoingWorkout.goodJob
class Translations$ongoingWorkout$goodJob$it implements Translations$ongoingWorkout$goodJob$en {
	Translations$ongoingWorkout$goodJob$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ottimo lavoro!';
	@override String get body => 'Ecco delle statistiche sull\'allenamento appena terminato.';
}

// Path: ongoingWorkout.exercisesToSuperset
class Translations$ongoingWorkout$exercisesToSuperset$it implements Translations$ongoingWorkout$exercisesToSuperset$en {
	Translations$ongoingWorkout$exercisesToSuperset$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Crea nuova superserie';
	@override String get errorBannerTitle => 'Impossibile creare superserie';
	@override late final Translations$ongoingWorkout$exercisesToSuperset$errors$it errors = Translations$ongoingWorkout$exercisesToSuperset$errors$it._(_root);
}

// Path: exerciseList.fields
class Translations$exerciseList$fields$it implements Translations$exerciseList$fields$en {
	Translations$exerciseList$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String weight({required Object weight, required Object unit}) => '${weight} ${unit}';
	@override String time({required Object time}) => '${time}';
	@override String reps({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: '0 rip.',
		one: '${n} rip.',
		two: '${n} rip.',
		few: '${n} rip.',
		many: '${n} di rip.',
		other: '${n} rip.',
	);
	@override String distance({required Object distance, required Object unit}) => '${distance} ${unit}';
	@override String rpe({required Object rpe}) => 'RPE ${rpe}';
}

// Path: exerciseList.workoutMuscleCategoriesBarChart
class Translations$exerciseList$workoutMuscleCategoriesBarChart$it implements Translations$exerciseList$workoutMuscleCategoriesBarChart$en {
	Translations$exerciseList$workoutMuscleCategoriesBarChart$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Distribuzione muscolare (per serie effettuate)';
}

// Path: exerciseList.stats
class Translations$exerciseList$stats$it implements Translations$exerciseList$stats$en {
	Translations$exerciseList$stats$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get time => 'Durata';
	@override String get volume => 'Volume';
	@override String get distance => 'Distanza';
	@override String get sets => 'Serie';
}

// Path: exerciseList.workoutWeightDistributionBarChart
class Translations$exerciseList$workoutWeightDistributionBarChart$it implements Translations$exerciseList$workoutWeightDistributionBarChart$en {
	Translations$exerciseList$workoutWeightDistributionBarChart$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Distribuzione muscolare (per peso sollevato)';
}

// Path: exerciseList.workoutEquipmentDistributionBarChart
class Translations$exerciseList$workoutEquipmentDistributionBarChart$it implements Translations$exerciseList$workoutEquipmentDistributionBarChart$en {
	Translations$exerciseList$workoutEquipmentDistributionBarChart$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Distribuzione attrezzatura (per serie effettuate)';
}

// Path: general.dialogs
class Translations$general$dialogs$it implements Translations$general$dialogs$en {
	Translations$general$dialogs$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$general$dialogs$actions$it actions = Translations$general$dialogs$actions$it._(_root);
}

// Path: titleGenerator.title
class Translations$titleGenerator$title$it implements Translations$titleGenerator$title$en {
	Translations$titleGenerator$title$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get zero => '';
	@override String one({required Object p0}) => '${p0}';
	@override String two({required Object p0, required Object p1}) => '${p0} e ${p1}';
	@override String three({required Object p0, required Object p1, required Object p2}) => '${p0}, ${p1} e ${p2}';
	@override String four({required Object p0, required Object p1, required Object p2, required Object p3}) => '${p0}, ${p1}, ${p2} e ${p3}';
	@override String five({required Object p0, required Object p1, required Object p2, required Object p3, required Object p4}) => '${p0}, ${p1}, ${p2}, ${p3} e ${p4}';
	@override String six({required Object p0, required Object p1, required Object p2, required Object p3, required Object p4, required Object p5}) => '${p0}, ${p1}, ${p2}, ${p3}, ${p4} e ${p5}';
}

// Path: weightCalculator.weight
class Translations$weightCalculator$weight$it implements Translations$weightCalculator$weight$en {
	Translations$weightCalculator$weight$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Peso totale';
}

// Path: weightCalculator.weights
class Translations$weightCalculator$weights$it implements Translations$weightCalculator$weights$en {
	Translations$weightCalculator$weights$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Pesi disponibili';
}

// Path: weightCalculator.barbells
class Translations$weightCalculator$barbells$it implements Translations$weightCalculator$barbells$en {
	Translations$weightCalculator$barbells$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Bilanciere';
}

// Path: library.cardio
class Translations$library$cardio$it implements Translations$library$cardio$en {
	Translations$library$cardio$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Cardio';
	@override late final Translations$library$cardio$exercises$it exercises = Translations$library$cardio$exercises$it._(_root);
}

// Path: library.chest
class Translations$library$chest$it implements Translations$library$chest$en {
	Translations$library$chest$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Petto';
	@override late final Translations$library$chest$exercises$it exercises = Translations$library$chest$exercises$it._(_root);
}

// Path: library.biceps
class Translations$library$biceps$it implements Translations$library$biceps$en {
	Translations$library$biceps$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Bicipiti';
	@override late final Translations$library$biceps$exercises$it exercises = Translations$library$biceps$exercises$it._(_root);
}

// Path: library.abs
class Translations$library$abs$it implements Translations$library$abs$en {
	Translations$library$abs$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Addominali';
	@override late final Translations$library$abs$exercises$it exercises = Translations$library$abs$exercises$it._(_root);
}

// Path: library.calves
class Translations$library$calves$it implements Translations$library$calves$en {
	Translations$library$calves$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Polpacci';
	@override late final Translations$library$calves$exercises$it exercises = Translations$library$calves$exercises$it._(_root);
}

// Path: library.quadriceps
class Translations$library$quadriceps$it implements Translations$library$quadriceps$en {
	Translations$library$quadriceps$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Quadricipiti';
	@override late final Translations$library$quadriceps$exercises$it exercises = Translations$library$quadriceps$exercises$it._(_root);
}

// Path: library.hamstrings
class Translations$library$hamstrings$it implements Translations$library$hamstrings$en {
	Translations$library$hamstrings$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Posteriori della coscia';
	@override late final Translations$library$hamstrings$exercises$it exercises = Translations$library$hamstrings$exercises$it._(_root);
}

// Path: library.shoulders
class Translations$library$shoulders$it implements Translations$library$shoulders$en {
	Translations$library$shoulders$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Spalle';
	@override late final Translations$library$shoulders$exercises$it exercises = Translations$library$shoulders$exercises$it._(_root);
}

// Path: library.back
class Translations$library$back$it implements Translations$library$back$en {
	Translations$library$back$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Schiena';
	@override late final Translations$library$back$exercises$it exercises = Translations$library$back$exercises$it._(_root);
	@override late final Translations$library$back$exercise$it exercise = Translations$library$back$exercise$it._(_root);
}

// Path: library.triceps
class Translations$library$triceps$it implements Translations$library$triceps$en {
	Translations$library$triceps$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Tricipiti';
	@override late final Translations$library$triceps$exercises$it exercises = Translations$library$triceps$exercises$it._(_root);
}

// Path: library.custom
class Translations$library$custom$it implements Translations$library$custom$en {
	Translations$library$custom$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Esercizi personalizzati';
}

// Path: library.hips
class Translations$library$hips$it implements Translations$library$hips$en {
	Translations$library$hips$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Anche';
	@override late final Translations$library$hips$exercises$it exercises = Translations$library$hips$exercises$it._(_root);
}

// Path: library.forearms
class Translations$library$forearms$it implements Translations$library$forearms$en {
	Translations$library$forearms$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Avambracci';
	@override late final Translations$library$forearms$exercises$it exercises = Translations$library$forearms$exercises$it._(_root);
}

// Path: library.obliques
class Translations$library$obliques$it implements Translations$library$obliques$en {
	Translations$library$obliques$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$library$obliques$exercises$it exercises = Translations$library$obliques$exercises$it._(_root);
}

// Path: library.other
class Translations$library$other$it implements Translations$library$other$en {
	Translations$library$other$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Altro';
	@override late final Translations$library$other$exercises$it exercises = Translations$library$other$exercises$it._(_root);
}

// Path: library.glutes
class Translations$library$glutes$it implements Translations$library$glutes$en {
	Translations$library$glutes$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Glutei';
	@override late final Translations$library$glutes$exercises$it exercises = Translations$library$glutes$exercises$it._(_root);
}

// Path: historyEditor.exercises
class Translations$historyEditor$exercises$it implements Translations$historyEditor$exercises$en {
	Translations$historyEditor$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get addSuperset => '+ Aggiungi superserie';
	@override String get add => '+ Aggiungi esercizio';
	@override String get reorder => 'Riordina esercizi';
}

// Path: historyEditor.info
class Translations$historyEditor$info$it implements Translations$historyEditor$info$en {
	Translations$historyEditor$info$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get reps => 'Ripetizioni';
	@override String get volume => 'Volume';
}

// Path: historyEditor.actions
class Translations$historyEditor$actions$it implements Translations$historyEditor$actions$en {
	Translations$historyEditor$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get finish => 'Termina modifica';
	@override String get changeWeightUnit => 'Cambia unità di peso';
	@override String get discardChanges => 'Modifiche effettuate';
	@override String get discardChangesContent => 'Questa pagina contiene modifiche non salvate. Vuoi comunque tornare indietro e perdere tutte le modifiche?';
}

// Path: historyEditor.finish
class Translations$historyEditor$finish$it implements Translations$historyEditor$finish$en {
	Translations$historyEditor$finish$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Termina modifica';
	@override late final Translations$historyEditor$finish$fields$it fields = Translations$historyEditor$finish$fields$it._(_root);
}

// Path: importRoutine.errors
class Translations$importRoutine$errors$it implements Translations$importRoutine$errors$en {
	Translations$importRoutine$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$importRoutine$errors$badJson$it badJson = Translations$importRoutine$errors$badJson$it._(_root);
	@override late final Translations$importRoutine$errors$noJson$it noJson = Translations$importRoutine$errors$noJson$it._(_root);
	@override late final Translations$importRoutine$errors$badWorkout$it badWorkout = Translations$importRoutine$errors$badWorkout$it._(_root);
}

// Path: importRoutine.import
class Translations$importRoutine$import$it implements Translations$importRoutine$import$en {
	Translations$importRoutine$import$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Importa';
	@override String get done => 'The routine has been imported.';
}

// Path: me.weight
class Translations$me$weight$it implements Translations$me$weight$en {
	Translations$me$weight$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Peso';
	@override String get none => 'N/D';
	@override late final Translations$me$weight$allData$it allData = Translations$me$weight$allData$it._(_root);
	@override late final Translations$me$weight$measured$it measured = Translations$me$weight$measured$it._(_root);
	@override String get addMeasurement => 'Aggiungi misurazione';
}

// Path: me.addWeight
class Translations$me$addWeight$it implements Translations$me$addWeight$en {
	Translations$me$addWeight$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$me$addWeight$time$it time = Translations$me$addWeight$time$it._(_root);
	@override late final Translations$me$addWeight$weight$it weight = Translations$me$addWeight$weight$it._(_root);
	@override late final Translations$me$addWeight$weightUnit$it weightUnit = Translations$me$addWeight$weightUnit$it._(_root);
	@override late final Translations$me$addWeight$errors$it errors = Translations$me$addWeight$errors$it._(_root);
}

// Path: me.allData
class Translations$me$allData$it implements Translations$me$allData$en {
	Translations$me$allData$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Tutti i dati registrati';
	@override late final Translations$me$allData$removed$it removed = Translations$me$allData$removed$it._(_root);
	@override String get none => 'Nessun dato';
	@override late final Translations$me$allData$predictedWeight$it predictedWeight = Translations$me$allData$predictedWeight$it._(_root);
}

// Path: me.calendar
class Translations$me$calendar$it implements Translations$me$calendar$en {
	Translations$me$calendar$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Calendario';
	@override String get empty => 'Non ti sei allenato questo giorno';
	@override String get streak => 'Serie';
	@override String get rest => 'Riposo';
}

// Path: me.stats
class Translations$me$stats$it implements Translations$me$stats$en {
	Translations$me$stats$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Statistiche';
	@override Map<String, String> get timeFrame => {
		'thirtyDays': 'Ultimi 30 giorni',
		'threeMonths': 'Ultimi 3 mesi',
		'year': 'Ultimo anno',
		'allTime': 'Tutto',
		'sevenDays': 'Ultimi 7 giorni',
	};
	@override late final Translations$me$stats$workouts$it workouts = Translations$me$stats$workouts$it._(_root);
	@override late final Translations$me$stats$duration$it duration = Translations$me$stats$duration$it._(_root);
	@override late final Translations$me$stats$volume$it volume = Translations$me$stats$volume$it._(_root);
	@override late final Translations$me$stats$distance$it distance = Translations$me$stats$distance$it._(_root);
	@override late final Translations$me$stats$sets$it sets = Translations$me$stats$sets$it._(_root);
	@override String get muscleCategory => 'Gruppi muscolari';
	@override String get gymEquipment => 'Attrezzatura';
	@override String get atAGlance => 'Colpo d\'occhio';
	@override String get metrics => 'Metriche';
	@override late final Translations$me$stats$overview$it overview = Translations$me$stats$overview$it._(_root);
	@override late final Translations$me$stats$mainThree$it mainThree = Translations$me$stats$mainThree$it._(_root);
}

// Path: me.workoutDistribution
class Translations$me$workoutDistribution$it implements Translations$me$workoutDistribution$en {
	Translations$me$workoutDistribution$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Distribuzione allenamenti';
}

// Path: me.profile
class Translations$me$profile$it implements Translations$me$profile$en {
	Translations$me$profile$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profilo';
	@override String get logout => 'Esci';
	@override late final Translations$me$profile$edit$it edit = Translations$me$profile$edit$it._(_root);
	@override late final Translations$me$profile$errors$it errors = Translations$me$profile$errors$it._(_root);
}

// Path: me.sync
class Translations$me$sync$it implements Translations$me$sync$en {
	Translations$me$sync$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Modifiche non salvate';
	@override String get subtitle => 'Tocca per sincronizzare le modifiche con il cloud.';
}

// Path: me.trainer
class Translations$me$trainer$it implements Translations$me$trainer$en {
	Translations$me$trainer$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get heading => 'Personal trainer';
	@override String get title => 'Il mio trainer';
	@override String get subtitle => 'Gestisci il collegamento, le schede e le routine condivise.';
}

// Path: timeSeriesChart.noData
class Translations$timeSeriesChart$noData$it implements Translations$timeSeriesChart$noData$en {
	Translations$timeSeriesChart$noData$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Questo grafico non presenta dati';
	@override String get subtitle => 'Avvia qualche allenamento per vedere questi dati.';
}

// Path: routineFormPicker.fields
class Translations$routineFormPicker$fields$it implements Translations$routineFormPicker$fields$en {
	Translations$routineFormPicker$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$routineFormPicker$fields$routine$it routine = Translations$routineFormPicker$fields$routine$it._(_root);
}

// Path: cardioTimer.setUp
class Translations$cardioTimer$setUp$it implements Translations$cardioTimer$setUp$en {
	Translations$cardioTimer$setUp$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impostazioni timer a intervalli';
	@override String get active => 'Tempo di attività';
	@override String get rest => 'Tempo di recupero';
	@override String section({required Object section}) => 'Sezione ${section}';
	@override String get start => 'Avvia timer a intervalli';
	@override String get addSection => '+ Nuova sezione';
	@override late final Translations$cardioTimer$setUp$errors$it errors = Translations$cardioTimer$setUp$errors$it._(_root);
}

// Path: cardioTimer.confirmExit
class Translations$cardioTimer$confirmExit$it implements Translations$cardioTimer$confirmExit$en {
	Translations$cardioTimer$confirmExit$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Esci';
	@override String get message => 'Vuoi davvero uscire? Il progresso attuale sarà cancellato.';
}

// Path: migrations.customToLibraryExercise
class Translations$migrations$customToLibraryExercise$it implements Translations$migrations$customToLibraryExercise$en {
	Translations$migrations$customToLibraryExercise$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$customToLibraryExercise$fields$it fields = Translations$migrations$customToLibraryExercise$fields$it._(_root);
	@override String get title => 'Esercizio personalizzato a esercizio standard';
	@override String get description => 'Sostituisci tutte le occorrenze di un esercizio personalizzato con un esercizio standard compatibile';
	@override late final Translations$migrations$customToLibraryExercise$preview$it preview = Translations$migrations$customToLibraryExercise$preview$it._(_root);
}

// Path: migrations.common
class Translations$migrations$common$it implements Translations$migrations$common$en {
	Translations$migrations$common$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$common$actions$it actions = Translations$migrations$common$actions$it._(_root);
	@override String get preview => 'Anteprima migrazione';
	@override String get migrated => 'Migrazione completata!';
}

// Path: migrations.removeUnusedExercises
class Translations$migrations$removeUnusedExercises$it implements Translations$migrations$removeUnusedExercises$en {
	Translations$migrations$removeUnusedExercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$removeUnusedExercises$preview$it preview = Translations$migrations$removeUnusedExercises$preview$it._(_root);
	@override String get title => 'Rimuovi esercizi inutilizzati';
	@override String get description => 'Pulisci la tua libreria rimuovendo tutti gli esercizi personalizzati che non hai usato';
}

// Path: migrations.removeWeightFromCustomExercise
class Translations$migrations$removeWeightFromCustomExercise$it implements Translations$migrations$removeWeightFromCustomExercise$en {
	Translations$migrations$removeWeightFromCustomExercise$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$removeWeightFromCustomExercise$preview$it preview = Translations$migrations$removeWeightFromCustomExercise$preview$it._(_root);
	@override late final Translations$migrations$removeWeightFromCustomExercise$fields$it fields = Translations$migrations$removeWeightFromCustomExercise$fields$it._(_root);
	@override String get title => 'Rimuovi parametro Peso';
	@override String get description => 'Rimuovi il parametro Peso da un esercizio con "Peso e ripetizioni" dove hai sempre e solo usato il campo Ripetizioni.';
}

// Path: migrations.genericMultiplyWeight
class Translations$migrations$genericMultiplyWeight$it implements Translations$migrations$genericMultiplyWeight$en {
	Translations$migrations$genericMultiplyWeight$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String title({required Object multiplier}) => 'Moltiplica peso di un esercizio per ${multiplier}';
	@override late final Translations$migrations$genericMultiplyWeight$fields$it fields = Translations$migrations$genericMultiplyWeight$fields$it._(_root);
	@override late final Translations$migrations$genericMultiplyWeight$preview$it preview = Translations$migrations$genericMultiplyWeight$preview$it._(_root);
}

// Path: migrations.doubleExerciseWeight
class Translations$migrations$doubleExerciseWeight$it implements Translations$migrations$doubleExerciseWeight$en {
	Translations$migrations$doubleExerciseWeight$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Raddoppia peso dell\'esercizio';
	@override String get description => 'Raddoppia il parametro del peso in tutte le occorrenze di un esercizio.';
}

// Path: migrations.halveExerciseWeight
class Translations$migrations$halveExerciseWeight$it implements Translations$migrations$halveExerciseWeight$en {
	Translations$migrations$halveExerciseWeight$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dimezza peso dell\'esercizio';
	@override String get description => 'Dimezza il parametro del peso in tutte le occorrenze di un esercizio.';
}

// Path: exerciseFormPicker.fields
class Translations$exerciseFormPicker$fields$it implements Translations$exerciseFormPicker$fields$en {
	Translations$exerciseFormPicker$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exerciseFormPicker$fields$exercise$it exercise = Translations$exerciseFormPicker$fields$exercise$it._(_root);
}

// Path: exercises.none
class Translations$exercises$none$it implements Translations$exercises$none$en {
	Translations$exercises$none$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nessun esercizio';
	@override String get subtitle => 'Tocca per deselezionare tutto e tornare indietro';
}

// Path: food.home
class Translations$food$home$it implements Translations$food$home$en {
	Translations$food$home$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get dailyNutritionalValues => 'Valori nutrizionali della giornata';
	@override String get calories => 'Calorie';
	@override String get carbs => 'Carboidrati';
	@override String get protein => 'Proteine';
	@override String get fat => 'Grassi';
	@override String get eaten => 'Consumate';
	@override String get remainingCal => 'Rimanenti';
	@override String get goal => 'Obiettivo';
	@override String get overCal => 'Superate';
}

// Path: food.searchBar
class Translations$food$searchBar$it implements Translations$food$searchBar$en {
	Translations$food$searchBar$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Cerca cronologia o catalogo alimenti…';
	@override String noResults({required Object query}) => 'Nessun riscontro per "${query}".';
	@override String get noHistory => 'Cronologia vuota';
}

// Path: food.add
class Translations$food$add$it implements Translations$food$add$en {
	Translations$food$add$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String nutritionalValuesPerAmountG({required Object amount}) => 'Valori nutrizionali (per ${amount} g / ${amount} ml)';
	@override String get servingSize => 'Porzione';
	@override String get custom => 'Quantità personalizzata';
	@override String get amount => 'Quantità';
	@override String get amountWithClarifiedUnit => 'Quantità (g o ml)';
	@override String get amountEmpty => 'La quantità non può essere vuota.';
	@override String get amountInvalid => 'Inserisci un numero valido.';
	@override String get add => '+ Aggiungi al diario';
	@override String get unnamedServingSize => 'Porzione sconosciuta';
	@override String nutritionalValuesPerAmountWithUnit({required Object amount, required Object unit}) => 'Valori nutrizionali (per ${amount} ${unit})';
	@override late final Translations$food$add$customFood$it customFood = Translations$food$add$customFood$it._(_root);
	@override String get nameEmpty => 'Il nome non può essere vuoto';
	@override String get pieces => 'Pezzi';
}

// Path: food.edit
class Translations$food$edit$it implements Translations$food$edit$en {
	Translations$food$edit$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get edit => 'Salva';
	@override String get copyToToday => 'Copia a oggi';
}

// Path: food.addCustom
class Translations$food$addCustom$it implements Translations$food$addCustom$en {
	Translations$food$addCustom$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aggiungi personalizzato';
}

// Path: food.search
class Translations$food$search$it implements Translations$food$search$en {
	Translations$food$search$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Risultati';
	@override late final Translations$food$search$error$it error = Translations$food$search$error$it._(_root);
}

// Path: food.barcodeReader
class Translations$food$barcodeReader$it implements Translations$food$barcodeReader$en {
	Translations$food$barcodeReader$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Scansiona codice a barre';
	@override late final Translations$food$barcodeReader$scanResult$it scanResult = Translations$food$barcodeReader$scanResult$it._(_root);
	@override String get enterCode => 'Inserisci a mano';
	@override late final Translations$food$barcodeReader$codeField$it codeField = Translations$food$barcodeReader$codeField$it._(_root);
}

// Path: food.addCustomFood
class Translations$food$addCustomFood$it implements Translations$food$addCustomFood$en {
	Translations$food$addCustomFood$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$food$addCustomFood$permission$it permission = Translations$food$addCustomFood$permission$it._(_root);
}

// Path: food.nutritionGoal
class Translations$food$nutritionGoal$it implements Translations$food$nutritionGoal$en {
	Translations$food$nutritionGoal$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$food$nutritionGoal$effect$it effect = Translations$food$nutritionGoal$effect$it._(_root);
}

// Path: food.nutritionGoals
class Translations$food$nutritionGoals$it implements Translations$food$nutritionGoals$en {
	Translations$food$nutritionGoals$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$food$nutritionGoals$change$it change = Translations$food$nutritionGoals$change$it._(_root);
	@override late final Translations$food$nutritionGoals$history$it history = Translations$food$nutritionGoals$history$it._(_root);
}

// Path: food.combine
class Translations$food$combine$it implements Translations$food$combine$en {
	Translations$food$combine$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Crea cibo da combinazione';
}

// Path: food.categoryList
class Translations$food$categoryList$it implements Translations$food$categoryList$en {
	Translations$food$categoryList$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get reorderFailed => 'Impossibile salvare l’ordine delle categorie. Riprova.';
	@override String dailyPercentage({required Object percentage, required Object calories}) => '${percentage}% del totale giornaliero – ${calories}';
	@override String get empty => 'Non hai ancora configurato le categorie';
	@override late final Translations$food$categoryList$unmodifiable$it unmodifiable = Translations$food$categoryList$unmodifiable$it._(_root);
	@override String get title => 'Categorie';
	@override String get add => 'Aggiungi';
}

// Path: food.categoryEditor
class Translations$food$categoryEditor$it implements Translations$food$categoryEditor$en {
	Translations$food$categoryEditor$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$food$categoryEditor$title$it title = Translations$food$categoryEditor$title$it._(_root);
	@override String get name => 'Nome';
	@override String get dailyPercentage => 'Percentuale giornaliera';
	@override late final Translations$food$categoryEditor$fields$it fields = Translations$food$categoryEditor$fields$it._(_root);
	@override String get save => 'Salva';
	@override String get icon => 'Icona';
	@override late final Translations$food$categoryEditor$effect$it effect = Translations$food$categoryEditor$effect$it._(_root);
	@override late final Translations$food$categoryEditor$nonFulfillingSum$it nonFulfillingSum = Translations$food$categoryEditor$nonFulfillingSum$it._(_root);
}

// Path: food.categoryFoods
class Translations$food$categoryFoods$it implements Translations$food$categoryFoods$en {
	Translations$food$categoryFoods$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Non hai ancora aggiunto cibi a questa categoria.';
}

// Path: food.permission
class Translations$food$permission$it implements Translations$food$permission$en {
	Translations$food$permission$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get denied => 'Non siamo stati in grado di ottenere quest\'autorizzazione. Vuoi aprire le impostazioni delle autorizzazioni?';
	@override String get openSettings => 'Apri le impostazioni dell\'app';
	@override String get error => 'Si è verificato un errore.';
}

// Path: food.datePicker
class Translations$food$datePicker$it implements Translations$food$datePicker$en {
	Translations$food$datePicker$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get today => 'Oggi';
}

// Path: food.catalog
class Translations$food$catalog$it implements Translations$food$catalog$en {
	Translations$food$catalog$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get submitAlso => 'Invia anche al catalogo';
	@override String get publicNotice => 'Il contributo diventa pubblico e rimane disponibile anche dopo la cancellazione del tuo account.';
	@override String get loginToSubmit => 'Accedi per inviare alimenti al catalogo. Il salvataggio nel diario rimane disponibile.';
	@override String get queueFailed => 'Alimento pronto per il diario, ma non è stato possibile accodare l’invio al catalogo.';
	@override String get submissions => 'Invii al catalogo';
	@override String get noSubmissions => 'Non hai ancora richiesto invii al catalogo.';
	@override String get loadFailed => 'Impossibile caricare gli invii.';
	@override String get retry => 'Riprova invio';
	@override String get cancel => 'Annulla';
	@override String get report => 'Segnala alimento';
	@override String get loginToReport => 'Accedi per segnalare un alimento.';
	@override String get details => 'Dettagli (facoltativi)';
	@override String get detailsRequired => 'Specifica il motivo della segnalazione.';
	@override String get sendReport => 'Invia segnalazione';
	@override String get reportSent => 'Segnalazione inviata.';
	@override String get reportFailed => 'Invio non riuscito. Riprova più tardi.';
	@override Map<String, String> get reasons => {
		'spam': 'Spam',
		'inappropriate': 'Contenuto non opportuno per Gym Bro',
		'nutrition': 'Valori nutrizionali sbagliati',
		'product': 'Informazioni sul prodotto o barcode sbagliate',
		'duplicate': 'Alimento duplicato',
		'other': 'Altro',
	};
	@override Map<String, String> get statuses => {
		'pending': 'In attesa di invio; riprova automaticamente',
		'sending': 'Invio in corso',
		'failed': 'Invio non riuscito: controlla i dati e riprova',
		'published': 'Pubblicato nel catalogo',
		'duplicate': 'Già presente nel catalogo',
		'correction': 'Correzione inviata per revisione',
		'unavailable': 'Voce non disponibile per la pubblicazione',
		'cancelled': 'Invio annullato',
		'cancelled_unknown': 'Tentativi annullati; un invio precedente potrebbe essere già stato ricevuto',
		'already_present': 'Alimento già presente nel catalogo',
		'uncertain': 'Non è possibile verificare se questo alimento è già nel catalogo.',
	};
}

// Path: food.picker
class Translations$food$picker$it implements Translations$food$picker$en {
	Translations$food$picker$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aggiungi alimento';
	@override String get search => 'Ricerca';
	@override String get barcode => 'Codice a barre';
	@override String get more => 'Altro';
	@override String get added => 'Aggiunti';
	@override String get done => 'Fine';
	@override String get recent => 'Recenti';
	@override String get results => 'Catalogo';
	@override String get empty => 'Nessun alimento trovato';
	@override String get retry => 'Riprova';
	@override String get failed => 'Operazione non riuscita. Riprova.';
	@override String get withBarcode => 'Personalizzato con codice a barre';
	@override String get withoutBarcode => 'Personalizzato senza codice a barre';
	@override String get save => 'Salva';
	@override String get savePrivate => 'Salva per me';
	@override String get share => 'Aggiungi al catalogo';
	@override String get alreadyPresent => 'Alimento già presente nel catalogo';
	@override String get uncertain => 'Non è possibile verificare se questo alimento è già nel catalogo.';
	@override String get queued => 'Condivisione in attesa di invio';
	@override String get published => 'Alimento pubblicato nel catalogo';
	@override String get addedNotice => 'Alimento aggiunto';
	@override String get noAdded => 'Non hai ancora aggiunto alimenti';
	@override String get lookupFailed => 'Impossibile cercare il codice. Riprova oppure inserisci un alimento personalizzato.';
	@override String get custom => 'Inserisci alimento';
	@override String get shareNotice => 'Salva condivide l’alimento nel catalogo pubblico. Salva per me lo mantiene personale.';
	@override String get invalidBarcode => 'Inserisci un codice a barre valido (4–32 cifre).';
	@override String get showMore => 'Mostra altro';
}

// Path: food.recipes
class Translations$food$recipes$it implements Translations$food$recipes$en {
	Translations$food$recipes$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ricette';
	@override String get create => 'Nuova ricetta';
	@override String get edit => 'Modifica ricetta';
	@override String get empty => 'Nessuna ricetta salvata';
	@override String get search => 'Cerca ricette';
	@override String get name => 'Nome';
	@override String get description => 'Descrizione';
	@override String get instructions => 'Istruzioni di cucina';
	@override String get servings => 'Porzioni';
	@override String get ingredients => 'Ingredienti';
	@override String get addIngredient => 'Aggiungi ingrediente';
	@override String get automaticMass => 'Peso degli ingredienti';
	@override String get finalMass => 'Peso finale dopo la cottura (g, facoltativo)';
	@override String get massHint => 'Lascia vuoto per usare la somma degli ingredienti.';
	@override String get total => 'Totale';
	@override String get perServing => 'Per porzione';
	@override String get save => 'Salva';
	@override String get delete => 'Elimina';
	@override String get deletePrompt => 'Eliminare questa ricetta? I pasti già registrati resteranno invariati.';
	@override String get cancel => 'Annulla';
	@override String get confirm => 'Conferma';
	@override String get add => 'Aggiungi al diario';
	@override String get choose => 'Ricetta';
	@override String get grams => 'Grammi';
	@override String get portions => 'Porzioni';
	@override String get equivalentMass => 'Peso equivalente (g, facoltativo)';
	@override String get liquidMass => 'Conversione da ml a g';
	@override String get liquidHint => 'Puoi indicare il peso del liquido in grammi. Se lasci il campo vuoto, verrà usata una conversione di 1 ml = 1 g.';
	@override String get invalid => 'Inserisci un valore positivo valido.';
	@override String get invalidServings => 'Inserisci un numero intero da 1 a 32.';
	@override String get requiredName => 'Inserisci un nome.';
	@override String get requiredIngredients => 'Aggiungi almeno un ingrediente.';
	@override String get failed => 'Operazione non riuscita. Riprova.';
	@override String get accountChanged => 'L’account è cambiato. Riapri la schermata.';
	@override String get editIngredient => 'Modifica ingrediente';
	@override String get discard => 'Scartare le modifiche?';
	@override String get discardBody => 'Le modifiche non salvate andranno perse.';
	@override String get discardAction => 'Scarta';
	@override String get details => 'Dettagli ricetta';
	@override String get yieldTitle => 'Resa e porzioni';
	@override String get nutrition => 'Valori nutrizionali';
	@override String get ingredientsHint => 'Scegli gli alimenti e le quantità per comporre la tua ricetta.';
	@override String get decreaseQuantity => 'Diminuisci quantità';
	@override String get increaseQuantity => 'Aumenta quantità';
}

// Path: equipment.none
class Translations$equipment$none$it implements Translations$equipment$none$en {
	Translations$equipment$none$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Corpo libero';
	@override String get short => 'C. libero';
}

// Path: equipment.barbell
class Translations$equipment$barbell$it implements Translations$equipment$barbell$en {
	Translations$equipment$barbell$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Bilanciere';
	@override String get short => 'Bilanc.';
}

// Path: equipment.dumbbell
class Translations$equipment$dumbbell$it implements Translations$equipment$dumbbell$en {
	Translations$equipment$dumbbell$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Manubri';
	@override String get short => 'Manubri';
}

// Path: equipment.cable
class Translations$equipment$cable$it implements Translations$equipment$cable$en {
	Translations$equipment$cable$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Cavi';
	@override String get short => 'Cavi';
}

// Path: equipment.machine
class Translations$equipment$machine$it implements Translations$equipment$machine$en {
	Translations$equipment$machine$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Macchinario';
	@override String get short => 'Macch.';
}

// Path: equipment.kettlebell
class Translations$equipment$kettlebell$it implements Translations$equipment$kettlebell$en {
	Translations$equipment$kettlebell$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Kettlebell';
	@override String get short => 'Kettleb.';
}

// Path: equipment.plates
class Translations$equipment$plates$it implements Translations$equipment$plates$en {
	Translations$equipment$plates$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Piatti';
	@override String get short => 'Piatti';
}

// Path: equipment.resistanceBand
class Translations$equipment$resistanceBand$it implements Translations$equipment$resistanceBand$en {
	Translations$equipment$resistanceBand$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Banda di resistenza';
	@override String get short => 'B. di res.';
}

// Path: equipment.suspensionBands
class Translations$equipment$suspensionBands$it implements Translations$equipment$suspensionBands$en {
	Translations$equipment$suspensionBands$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Fasce di sospensione';
	@override String get short => 'F. di sosp.';
}

// Path: equipment.landmine
class Translations$equipment$landmine$it implements Translations$equipment$landmine$en {
	Translations$equipment$landmine$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Landmine';
	@override String get short => 'Landmine';
}

// Path: equipment.other
class Translations$equipment$other$it implements Translations$equipment$other$en {
	Translations$equipment$other$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get long => 'Altro';
	@override String get short => 'Altro';
}

// Path: achievements.firstSteps
class Translations$achievements$firstSteps$it implements Translations$achievements$firstSteps$en {
	Translations$achievements$firstSteps$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Primi passi';
	@override late final Translations$achievements$firstSteps$description$it description = Translations$achievements$firstSteps$description$it._(_root);
}

// Path: achievements.foodWatcher
class Translations$achievements$foodWatcher$it implements Translations$achievements$foodWatcher$en {
	Translations$achievements$foodWatcher$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Food blogger';
	@override late final Translations$achievements$foodWatcher$description$it description = Translations$achievements$foodWatcher$description$it._(_root);
}

// Path: achievements.marathoner
class Translations$achievements$marathoner$it implements Translations$achievements$marathoner$en {
	Translations$achievements$marathoner$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Maratoneta';
	@override late final Translations$achievements$marathoner$description$it description = Translations$achievements$marathoner$description$it._(_root);
}

// Path: achievements.earlyBird
class Translations$achievements$earlyBird$it implements Translations$achievements$earlyBird$en {
	Translations$achievements$earlyBird$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mattiniero';
	@override String get description => 'Inizia un allenamento prima delle 8 del mattino';
}

// Path: achievements.nightOwl
class Translations$achievements$nightOwl$it implements Translations$achievements$nightOwl$en {
	Translations$achievements$nightOwl$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notturno';
	@override String get description => 'Inizia un allenamento dopo le 8 di sera';
}

// Path: achievements.realGymBro
class Translations$achievements$realGymBro$it implements Translations$achievements$realGymBro$en {
	Translations$achievements$realGymBro$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vero Gym Bro';
	@override late final Translations$achievements$realGymBro$description$it description = Translations$achievements$realGymBro$description$it._(_root);
}

// Path: achievements.workoutFreak
class Translations$achievements$workoutFreak$it implements Translations$achievements$workoutFreak$en {
	Translations$achievements$workoutFreak$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Maniaco dell\'allenamento';
	@override late final Translations$achievements$workoutFreak$description$it description = Translations$achievements$workoutFreak$description$it._(_root);
}

// Path: achievements.trailblazer
class Translations$achievements$trailblazer$it implements Translations$achievements$trailblazer$en {
	Translations$achievements$trailblazer$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pioniere';
	@override late final Translations$achievements$trailblazer$description$it description = Translations$achievements$trailblazer$description$it._(_root);
}

// Path: achievements.cycleChampion
class Translations$achievements$cycleChampion$it implements Translations$achievements$cycleChampion$en {
	Translations$achievements$cycleChampion$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ciclista campione';
	@override late final Translations$achievements$cycleChampion$description$it description = Translations$achievements$cycleChampion$description$it._(_root);
}

// Path: achievements.professionalWeightlifter
class Translations$achievements$professionalWeightlifter$it implements Translations$achievements$professionalWeightlifter$en {
	Translations$achievements$professionalWeightlifter$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sollevatore di coriandoli';
	@override late final Translations$achievements$professionalWeightlifter$description$it description = Translations$achievements$professionalWeightlifter$description$it._(_root);
}

// Path: achievements.programPlanner
class Translations$achievements$programPlanner$it implements Translations$achievements$programPlanner$en {
	Translations$achievements$programPlanner$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pianificatore compulsivo';
	@override String get description => 'Crea tre routine';
}

// Path: achievements.perfectPlanner
class Translations$achievements$perfectPlanner$it implements Translations$achievements$perfectPlanner$en {
	Translations$achievements$perfectPlanner$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pianificatore perfetto';
	@override String get description => 'Crea una cartella di routine';
}

// Path: achievements.routineMaster
class Translations$achievements$routineMaster$it implements Translations$achievements$routineMaster$en {
	Translations$achievements$routineMaster$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Maestro delle routine';
	@override late final Translations$achievements$routineMaster$description$it description = Translations$achievements$routineMaster$description$it._(_root);
}

// Path: achievements.intensityInnovator
class Translations$achievements$intensityInnovator$it implements Translations$achievements$intensityInnovator$en {
	Translations$achievements$intensityInnovator$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Intensità incendiaria';
	@override String get description => 'Modifica una routine aumentando pesi o ripetizioni';
}

// Path: achievements.completionist
class Translations$achievements$completionist$it implements Translations$achievements$completionist$en {
	Translations$achievements$completionist$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Completista';
	@override String get description => 'Prova almeno una volta tutti gli esercizi della libreria';
}

// Path: achievements.notDrunk
class Translations$achievements$notDrunk$it implements Translations$achievements$notDrunk$en {
	Translations$achievements$notDrunk$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Non sono sbronzo ma brillo!';
	@override String get description => 'Completa un allenamento di domenica mattina superando un record personale di volume o distanza';
}

// Path: achievements.steamedHams
class Translations$achievements$steamedHams$it implements Translations$achievements$steamedHams$en {
	Translations$achievements$steamedHams$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get description => 'Supera un record personale di massimale in un allenamento impiegando meno tempo del solito';
	@override String get title => 'Vitellone al vapore';
}

// Path: achievements.swimsuitSeason
class Translations$achievements$swimsuitSeason$it implements Translations$achievements$swimsuitSeason$en {
	Translations$achievements$swimsuitSeason$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Prova costume';
	@override String get description => 'Accumula 24h di allenamento cardio tra marzo e giugno di un anno';
}

// Path: achievements.pbBreaker
class Translations$achievements$pbBreaker$it implements Translations$achievements$pbBreaker$en {
	Translations$achievements$pbBreaker$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Primato personale';
	@override String get description => 'Supera il massimale di un esercizio';
}

// Path: achievements.sparta
class Translations$achievements$sparta$it implements Translations$achievements$sparta$en {
	Translations$achievements$sparta$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Questa è Sparta';
	@override late final Translations$achievements$sparta$description$it description = Translations$achievements$sparta$description$it._(_root);
}

// Path: achievements.midnightRain
class Translations$achievements$midnightRain$it implements Translations$achievements$midnightRain$en {
	Translations$achievements$midnightRain$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Midnight Rain';
	@override String get description => 'Inizia un allenamento prima di mezzanotte e finiscilo dopo la mezzanotte';
}

// Path: achievements.equipmentSpecialist
class Translations$achievements$equipmentSpecialist$it implements Translations$achievements$equipmentSpecialist$en {
	Translations$achievements$equipmentSpecialist$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get description => 'Crea e segui una routine che utilizza esclusivamente un tipo di attrezzo';
	@override String get title => 'Specialista dell\'attrezzatura';
}

// Path: achievements.bodyweightBeast
class Translations$achievements$bodyweightBeast$it implements Translations$achievements$bodyweightBeast$en {
	Translations$achievements$bodyweightBeast$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get description => 'Crea una routine solo di corpo libero e seguila per almeno un mese';
	@override String get title => 'Controllo corporeo';
}

// Path: workoutGenerator.actions
class Translations$workoutGenerator$actions$it implements Translations$workoutGenerator$actions$en {
	Translations$workoutGenerator$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get generate => 'Genera';
}

// Path: workoutGenerator.success
class Translations$workoutGenerator$success$it implements Translations$workoutGenerator$success$en {
	Translations$workoutGenerator$success$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get undo => 'Annulla';
	@override String get title => 'Allenamento generato con successo';
}

// Path: workoutGenerator.empty
class Translations$workoutGenerator$empty$it implements Translations$workoutGenerator$empty$en {
	Translations$workoutGenerator$empty$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Allenamento vuoto';
	@override String get text => 'Cambia i filtri e riprova';
}

// Path: boutique.package
class Translations$boutique$package$it implements Translations$boutique$package$en {
	Translations$boutique$package$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get install => 'Installa';
	@override String get installed => 'Il pacchetto è stato installato.';
}

// Path: boutique.marketingUpdating
class Translations$boutique$marketingUpdating$it implements Translations$boutique$marketingUpdating$en {
	Translations$boutique$marketingUpdating$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Stiamo rimodernando lo store.';
	@override String get description => 'Torna più tardi per delle schede nuove ed entusiasmanti!';
}

// Path: login.tabs
class Translations$login$tabs$it implements Translations$login$tabs$en {
	Translations$login$tabs$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get signIn => 'Accedi';
	@override String get signUp => 'Registrati';
}

// Path: login.errors
class Translations$login$errors$it implements Translations$login$errors$en {
	Translations$login$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get generic => 'Si è verificato un errore. Riprova tra qualche minuto.';
	@override String get username => 'Lo username deve essere di 3-20 caratteri e può contenere caratteri alfanumerici, trattini e trattini bassi.';
	@override String get usernameTaken => 'Questo username è già in uso.';
	@override String get email => 'Inserisci un indirizzo email valido.';
	@override late final Translations$login$errors$password$it password = Translations$login$errors$password$it._(_root);
	@override String get noInternet => 'Nessuna connessione a Internet.';
	@override String get passwordRequired => 'Inserisci la tua password.';
	@override String get confirmPasswordRequired => 'Ripeti la tua password.';
	@override String get passwordMismatch => 'Le password non coincidono.';
}

// Path: login.fields
class Translations$login$fields$it implements Translations$login$fields$en {
	Translations$login$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$login$fields$email$it email = Translations$login$fields$email$it._(_root);
	@override late final Translations$login$fields$password$it password = Translations$login$fields$password$it._(_root);
	@override late final Translations$login$fields$username$it username = Translations$login$fields$username$it._(_root);
	@override late final Translations$login$fields$confirmPassword$it confirmPassword = Translations$login$fields$confirmPassword$it._(_root);
}

// Path: login.buttons
class Translations$login$buttons$it implements Translations$login$buttons$en {
	Translations$login$buttons$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get signIn => 'Accedi';
	@override String get signUp => 'Registrati';
	@override String get showPassword => 'Mostra password';
	@override String get hidePassword => 'Nascondi password';
	@override String get dismissKeyboard => 'Chiudi tastiera';
}

// Path: login.upsell
class Translations$login$upsell$it implements Translations$login$upsell$en {
	Translations$login$upsell$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Accesso non effettuato';
	@override String get subtitle => 'Accedi per usufruire di allenamenti di gruppo, sincronizzazione su più dispositivi e tanto altro.';
}

// Path: login.verifyEmail
class Translations$login$verifyEmail$it implements Translations$login$verifyEmail$en {
	Translations$login$verifyEmail$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ti abbiamo inviato un\'email di verifica';
	@override String get done => 'Ho verificato la mia email';
	@override String get description => 'Controlla la tua casella di posta elettronica per confermare la tua email. Dopodiché tocca il pulsante sottostante per accedere.';
	@override String get notVerified => 'Verifica il tuo indirizzo email e riprova.';
}

// Path: login.presentation
class Translations$login$presentation$it implements Translations$login$presentation$en {
	Translations$login$presentation$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get signInTitle => 'Accedi a Gym Bro';
	@override String get signInSubtitle => 'Ritrova i tuoi allenamenti e mantieni i tuoi progressi sincronizzati.';
	@override String get signUpTitle => 'Crea il tuo profilo';
	@override String get signUpSubtitle => 'Salva i tuoi progressi e condividi gli allenamenti con i tuoi amici.';
	@override String get passwordRequirements => 'Almeno 8 caratteri, con una maiuscola, una minuscola, un numero e un carattere speciale.';
	@override String get noAccount => 'Non hai un account?';
	@override String get haveAccount => 'Hai già un account?';
}

// Path: login.recovery
class Translations$login$recovery$it implements Translations$login$recovery$en {
	Translations$login$recovery$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get forgot => 'Password dimenticata?';
	@override String get title => 'Recupera la password';
	@override String get description => 'Inserisci la tua email: ti invieremo un link per scegliere una nuova password sul sito di Gym Bro.';
	@override String get send => 'Invia il link';
	@override String get sentTitle => 'Controlla la tua email';
	@override String get sentDescription => 'Se esiste un account associato a questo indirizzo, riceverai un link per reimpostare la password. Dopo averla aggiornata sul sito, torna qui per accedere.';
	@override String get checkSpam => 'Controlla anche la cartella spam. Se non trovi il messaggio, puoi tornare indietro e riprovare.';
	@override String get backToSignIn => 'Torna ad accedere';
	@override String get error => 'Non siamo riusciti a inviare il link. Attendi qualche minuto e riprova.';
}

// Path: sync.conflict
class Translations$sync$conflict$it implements Translations$sync$conflict$en {
	Translations$sync$conflict$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Trovati dati contrastanti';
	@override String get message => 'Premei OK per scaricare i dati nel cloud e sovrascrivere i dati locali. Premi Annulla per cancellare i dati nel cloud e caricare i dati locali.';
}

// Path: sync.overwrite
class Translations$sync$overwrite$it implements Translations$sync$overwrite$en {
	Translations$sync$overwrite$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dati più vecchi';
	@override String get message => 'Vuoi sovrascrivere i dati sul server con i dati locali?';
}

// Path: onboarding.buttons
class Translations$onboarding$buttons$it implements Translations$onboarding$buttons$en {
	Translations$onboarding$buttons$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get skip => 'Salta per ora';
	@override String get next => 'Avanti';
	@override String get done => 'Iniziamo!';
}

// Path: onboarding.welcome
class Translations$onboarding$welcome$it implements Translations$onboarding$welcome$en {
	Translations$onboarding$welcome$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ti diamo il benvenuto a Gym Bro';
	@override String get text => 'Il tuo compagno di allenamento.\nDobbiamo verificare alcune autorizzazioni prima di iniziare.';
}

// Path: onboarding.notifications
class Translations$onboarding$notifications$it implements Translations$onboarding$notifications$en {
	Translations$onboarding$notifications$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notifiche';
	@override String get text => 'Consenti a Gym Bro di inviarti notifiche sui tempi di recupero.';
	@override String get notifications => 'Notifiche';
	@override String get exactAlarm => 'Notifiche immediate (per il tempo di recupero)';
}

// Path: onboarding.camera
class Translations$onboarding$camera$it implements Translations$onboarding$camera$en {
	Translations$onboarding$camera$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Fotocamera e galleria';
	@override String get text => 'Consenti a Gym Bro di accedere alla fotocamera al fine di scansionare i codici a barre nel diario alimentare.';
	@override String get gallery => 'Galleria';
	@override String get camera => 'Fotocamera';
}

// Path: onboarding.done
class Translations$onboarding$done$it implements Translations$onboarding$done$en {
	Translations$onboarding$done$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ecco fatto';
	@override String get text => 'Puoi iniziare i tuoi allenamenti con Gym Bro.';
}

// Path: onboarding.login
class Translations$onboarding$login$it implements Translations$onboarding$login$en {
	Translations$onboarding$login$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Accedi';
	@override String get text => 'Sincronizza i tuoi dati, guarda gli allenamenti dei tuoi amici e molto altro!';
}

// Path: feed.empty
class Translations$feed$empty$it implements Translations$feed$empty$en {
	Translations$feed$empty$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nessuna attività';
	@override String get text => 'Non ci sono ancora attività da mostrare. Inizia un allenamento o sblocca un traguardo per vedere le tue attività qui.';
}

// Path: feed.workout
class Translations$feed$workout$it implements Translations$feed$workout$en {
	Translations$feed$workout$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$feed$workout$title$it title = Translations$feed$workout$title$it._(_root);
	@override late final Translations$feed$workout$subtitle$it subtitle = Translations$feed$workout$subtitle$it._(_root);
}

// Path: feed.achievement
class Translations$feed$achievement$it implements Translations$feed$achievement$en {
	Translations$feed$achievement$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$feed$achievement$title$it title = Translations$feed$achievement$title$it._(_root);
	@override late final Translations$feed$achievement$subtitle$it subtitle = Translations$feed$achievement$subtitle$it._(_root);
}

// Path: feed.userButton
class Translations$feed$userButton$it implements Translations$feed$userButton$en {
	Translations$feed$userButton$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Caricamento profilo utente in corso...';
	@override String get error => 'Impossibile caricare il profilo';
}

// Path: feed.noSync
class Translations$feed$noSync$it implements Translations$feed$noSync$en {
	Translations$feed$noSync$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get text => 'La sincronizzazione è in pausa: non sei connesso a Internet. Potrebbero volerci alcuni minuti. Non preoccuparti, i dati verranno mantenuti in locale e trasferiti in un secondo momento.';
}

// Path: feed.suggestions
class Translations$feed$suggestions$it implements Translations$feed$suggestions$en {
	Translations$feed$suggestions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get start => 'Inizia';
	@override String assignedBy({required Object name}) => 'Assegnata da ${name}';
	@override String get assignedByTrainer => 'Assegnata dal tuo trainer';
}

// Path: feed.loadError
class Translations$feed$loadError$it implements Translations$feed$loadError$en {
	Translations$feed$loadError$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impossibile caricare le attività';
	@override String get text => 'Controlla la connessione e riprova.';
}

// Path: userProfile.cancelRequestConfirmation
class Translations$userProfile$cancelRequestConfirmation$it implements Translations$userProfile$cancelRequestConfirmation$en {
	Translations$userProfile$cancelRequestConfirmation$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Annullare richiesta?';
	@override String get keep => 'Mantieni richiesta';
	@override String get confirm => 'Annulla richiesta';
	@override String get error => 'Impossibile annullare la richiesta di amicizia. Riprova.';
}

// Path: userProfile.unfriendConfirmation
class Translations$userProfile$unfriendConfirmation$it implements Translations$userProfile$unfriendConfirmation$en {
	Translations$userProfile$unfriendConfirmation$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String title({required Object name}) => 'Rimuovere ${name} dagli amici?';
	@override String get subtitle => 'Non apparirà più nel tuo feed, e tu non apparirai nel suo.';
	@override String get confirm => 'Rimuovi';
	@override String get cancel => 'Annulla';
}

// Path: userProfile.stats
class Translations$userProfile$stats$it implements Translations$userProfile$stats$en {
	Translations$userProfile$stats$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get friends => 'Amici';
	@override String get workouts => 'Allenamenti';
	@override String get achievements => 'Traguardi';
}

// Path: userProfile.feed
class Translations$userProfile$feed$it implements Translations$userProfile$feed$en {
	Translations$userProfile$feed$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$userProfile$feed$unavailable$it unavailable = Translations$userProfile$feed$unavailable$it._(_root);
}

// Path: userProfile.edit
class Translations$userProfile$edit$it implements Translations$userProfile$edit$en {
	Translations$userProfile$edit$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Modifica profilo';
	@override String get title => 'Modifica profilo';
	@override String get fullName => 'Nome completo';
	@override String get fullNameHint => 'Inserisci il tuo nome completo';
	@override String get profilePicture => 'Immagine del profilo';
	@override String get changePicture => 'Cambia immagine';
	@override String get removePicture => 'Rimuovi immagine';
	@override String get uploading => 'Caricamento...';
	@override String get saving => 'Salvataggio...';
	@override String get success => 'Profilo aggiornato con successo!';
	@override String get error => 'Errore durante l\'aggiornamento del profilo';
	@override String get cropTitle => 'Ritaglia foto';
	@override String get cropInstructions => 'Trascina e pizzica per posizionare la foto';
	@override String get done => 'Fatto';
}

// Path: userProfile.crop
class Translations$userProfile$crop$it implements Translations$userProfile$crop$en {
	Translations$userProfile$crop$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$userProfile$crop$buttons$it buttons = Translations$userProfile$crop$buttons$it._(_root);
}

// Path: userProfile.error
class Translations$userProfile$error$it implements Translations$userProfile$error$en {
	Translations$userProfile$error$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Errore';
	@override String get retry => 'Riprova';
}

// Path: userProfile.errors
class Translations$userProfile$errors$it implements Translations$userProfile$errors$en {
	Translations$userProfile$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get noInternet => 'Sei offline. Controlla la connessione a Internet e riprova.';
}

// Path: friendRequests.empty
class Translations$friendRequests$empty$it implements Translations$friendRequests$empty$en {
	Translations$friendRequests$empty$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nessuna richiesta';
	@override String get text => 'Non hai richieste di amicizia in sospeso al momento.';
}

// Path: profileSearch.noResults
class Translations$profileSearch$noResults$it implements Translations$profileSearch$noResults$en {
	Translations$profileSearch$noResults$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nessun profilo trovato';
	@override String get text => 'Prova a cercare un nome utente diverso.';
}

// Path: paywall.trialPeriod
class Translations$paywall$trialPeriod$it implements Translations$paywall$trialPeriod$en {
	Translations$paywall$trialPeriod$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String week({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: 'Prova gratuita: ${n} settimana',
		other: 'Prova gratuita: ${n} settimane',
	);
	@override String month({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: 'Prova gratuita: ${n} mese',
		other: 'Prova gratuita: ${n} mesi',
	);
	@override String year({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: 'Prova gratuita: ${n} anno',
		other: 'Prova gratuita: ${n} anni',
	);
	@override String day({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: 'Prova gratuita: ${n} giorno',
		other: 'Prova gratuita: ${n} giorni',
	);
}

// Path: paywall.autoRenewNotice
class Translations$paywall$autoRenewNotice$it implements Translations$paywall$autoRenewNotice$en {
	Translations$paywall$autoRenewNotice$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String week({required Object price}) => 'Rinnovo automatico a ${price} a settimana fino alla disdetta.';
	@override String month({required Object price}) => 'Rinnovo automatico a ${price} al mese fino alla disdetta.';
	@override String year({required Object price}) => 'Rinnovo automatico a ${price} all’anno fino alla disdetta.';
	@override String day({required Object price}) => 'Rinnovo automatico a ${price} al giorno fino alla disdetta.';
}

// Path: paywall.purchaseError
class Translations$paywall$purchaseError$it implements Translations$paywall$purchaseError$en {
	Translations$paywall$purchaseError$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Acquisto non riuscito';
	@override String get subtitle => 'Impossibile completare l’acquisto. Riprova.';
}

// Path: paywall.restoreError
class Translations$paywall$restoreError$it implements Translations$paywall$restoreError$en {
	Translations$paywall$restoreError$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ripristino non riuscito';
	@override String get subtitle => 'Impossibile ripristinare gli acquisti. Riprova.';
}

// Path: paywall.actions
class Translations$paywall$actions$it implements Translations$paywall$actions$en {
	Translations$paywall$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get subscribe => 'Abbonati';
	@override String get restorePurchase => 'Ripristina acquisti';
	@override String get termsOfService => 'Termini di servizio';
	@override String get privacyPolicy => 'Informativa sulla privacy';
}

// Path: exercise.chart.views
class Translations$exercise$chart$views$it implements Translations$exercise$chart$views$en {
	Translations$exercise$chart$views$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get volume => 'Volume';
	@override String get reps => 'Ripetizioni';
	@override String get duration => 'Durata allenamento';
	@override String get time => 'Tempo';
	@override String get distance => 'Distanza';
	@override String get exertion => 'Tasso di esercizio';
	@override String get exertionInfo => 'Il tasso di esercizio stima l\'intensità di un allenamento calcolando la media del peso sollevato e della durata dell\'allenamento.';
}

// Path: exercise.editor.create
class Translations$exercise$editor$create$it implements Translations$exercise$editor$create$en {
	Translations$exercise$editor$create$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Crea esercizio';
}

// Path: exercise.editor.edit
class Translations$exercise$editor$edit$it implements Translations$exercise$editor$edit$en {
	Translations$exercise$editor$edit$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Modifica esercizio';
}

// Path: exercise.editor.fields
class Translations$exercise$editor$fields$it implements Translations$exercise$editor$fields$en {
	Translations$exercise$editor$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exercise$editor$fields$title$it title = Translations$exercise$editor$fields$title$it._(_root);
	@override late final Translations$exercise$editor$fields$parameters$it parameters = Translations$exercise$editor$fields$parameters$it._(_root);
	@override late final Translations$exercise$editor$fields$primaryMuscleGroup$it primaryMuscleGroup = Translations$exercise$editor$fields$primaryMuscleGroup$it._(_root);
	@override late final Translations$exercise$editor$fields$secondaryMuscleGroups$it secondaryMuscleGroups = Translations$exercise$editor$fields$secondaryMuscleGroups$it._(_root);
	@override late final Translations$exercise$editor$fields$notes$it notes = Translations$exercise$editor$fields$notes$it._(_root);
	@override late final Translations$exercise$editor$fields$rpe$it rpe = Translations$exercise$editor$fields$rpe$it._(_root);
	@override late final Translations$exercise$editor$fields$reorderSets$it reorderSets = Translations$exercise$editor$fields$reorderSets$it._(_root);
	@override late final Translations$exercise$editor$fields$gymEquipment$it gymEquipment = Translations$exercise$editor$fields$gymEquipment$it._(_root);
}

// Path: exercise.editor.cannotChangeParameters
class Translations$exercise$editor$cannotChangeParameters$it implements Translations$exercise$editor$cannotChangeParameters$en {
	Translations$exercise$editor$cannotChangeParameters$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Non puoi cambiare i parametri di questo esercizio';
	@override String get text => 'Puoi cambiare i parametri solo degli esercizi che non hai ancora eseguito.';
}

// Path: exercise.editor.setless
class Translations$exercise$editor$setless$it implements Translations$exercise$editor$setless$en {
	Translations$exercise$editor$setless$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Non puoi cambiare i parametri di questo esercizio';
	@override String get text => 'Disabilita l\'opzione "Senza serie" per modificare questo campo.';
}

// Path: exercise.editor.overwriteInWorkout
class Translations$exercise$editor$overwriteInWorkout$it implements Translations$exercise$editor$overwriteInWorkout$en {
	Translations$exercise$editor$overwriteInWorkout$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Questo esercizio fa parte del tuo allenamento in corso';
	@override String get body => 'Puoi modificarlo, ma se cambi i parametri dovrai riempire nuovamente i valori. Vuoi continuare?';
}

// Path: exercise.editor.advanced
class Translations$exercise$editor$advanced$it implements Translations$exercise$editor$advanced$en {
	Translations$exercise$editor$advanced$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exercise$editor$advanced$setless$it setless = Translations$exercise$editor$advanced$setless$it._(_root);
	@override String get title => 'Avanzate';
}

// Path: exercise.picker.errors
class Translations$exercise$picker$errors$it implements Translations$exercise$picker$errors$en {
	Translations$exercise$picker$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Devi selezionare un esercizio.';
}

// Path: exercise.picker.filter
class Translations$exercise$picker$filter$it implements Translations$exercise$picker$filter$en {
	Translations$exercise$picker$filter$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get equipment => 'Attrezzatura';
}

// Path: exercise.info.heaviestWeight
class Translations$exercise$info$heaviestWeight$it implements Translations$exercise$info$heaviestWeight$en {
	Translations$exercise$info$heaviestWeight$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Peso massimo';
}

// Path: exercise.info.best1rm
class Translations$exercise$info$best1rm$it implements Translations$exercise$info$best1rm$en {
	Translations$exercise$info$best1rm$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Miglior massimale';
}

// Path: exercise.info.bestSetVolume
class Translations$exercise$info$bestSetVolume$it implements Translations$exercise$info$bestSetVolume$en {
	Translations$exercise$info$bestSetVolume$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Miglior volume di una serie';
}

// Path: exercise.info.bestSessionVolume
class Translations$exercise$info$bestSessionVolume$it implements Translations$exercise$info$bestSessionVolume$en {
	Translations$exercise$info$bestSessionVolume$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Miglior volume totale di una sessione';
}

// Path: exercise.info.explanationNone
class Translations$exercise$info$explanationNone$it implements Translations$exercise$info$explanationNone$en {
	Translations$exercise$info$explanationNone$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nessuna spiegazione disponibile';
	@override String get description => 'Non c\'è ancora una spiegazione per questo esercizio. Controlla più tardi.';
}

// Path: exercise.continuation.combine
class Translations$exercise$continuation$combine$it implements Translations$exercise$continuation$combine$en {
	Translations$exercise$continuation$combine$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exercise$continuation$combine$confirm$it confirm = Translations$exercise$continuation$combine$confirm$it._(_root);
}

// Path: workouts.actions.delete
class Translations$workouts$actions$delete$it implements Translations$workouts$actions$delete$en {
	Translations$workouts$actions$delete$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Elimina allenamento';
	@override String get text => 'Vuoi davvero eliminare questo allenamento? Quest\'azione non può essere annullata.';
	@override late final Translations$workouts$actions$delete$actions$it actions = Translations$workouts$actions$delete$actions$it._(_root);
	@override String get done => 'L\'allenamento è stato eliminato.';
}

// Path: workouts.actions.edit
class Translations$workouts$actions$edit$it implements Translations$workouts$actions$edit$en {
	Translations$workouts$actions$edit$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Modifica allenamento';
}

// Path: workouts.actions.editContinuation
class Translations$workouts$actions$editContinuation$it implements Translations$workouts$actions$editContinuation$en {
	Translations$workouts$actions$editContinuation$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Modifica continuazione';
}

// Path: workouts.actions.rename
class Translations$workouts$actions$rename$it implements Translations$workouts$actions$rename$en {
	Translations$workouts$actions$rename$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Rinomina allenamento';
	@override late final Translations$workouts$actions$rename$errors$it errors = Translations$workouts$actions$rename$errors$it._(_root);
}

// Path: workouts.actions.changeParent
class Translations$workouts$actions$changeParent$it implements Translations$workouts$actions$changeParent$en {
	Translations$workouts$actions$changeParent$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Cambia routine di base';
	@override late final Translations$workouts$actions$changeParent$options$it options = Translations$workouts$actions$changeParent$options$it._(_root);
}

// Path: workouts.actions.saveAsRoutine
class Translations$workouts$actions$saveAsRoutine$it implements Translations$workouts$actions$saveAsRoutine$en {
	Translations$workouts$actions$saveAsRoutine$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get button => 'Salva come routine';
	@override String get done => 'Allenamento salvato come routine';
}

// Path: workouts.actions.share
class Translations$workouts$actions$share$it implements Translations$workouts$actions$share$en {
	Translations$workouts$actions$share$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get button => 'Condividi questa routine';
	@override late final Translations$workouts$actions$share$alert$it alert = Translations$workouts$actions$share$alert$it._(_root);
}

// Path: routines.actions.delete
class Translations$routines$actions$delete$it implements Translations$routines$actions$delete$en {
	Translations$routines$actions$delete$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Elimina routine';
	@override String get text => 'Vuoi davvero eliminare questa routine? Quest\'azione non può essere annullata.';
	@override late final Translations$routines$actions$delete$actions$it actions = Translations$routines$actions$delete$actions$it._(_root);
	@override String get done => 'La routine è stata eliminata.';
}

// Path: routines.actions.deleteFolder
class Translations$routines$actions$deleteFolder$it implements Translations$routines$actions$deleteFolder$en {
	Translations$routines$actions$deleteFolder$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Elimina cartella';
	@override String get text => 'Vuoi davvero eliminare questa cartella? Quest\'azione non potrà essere annullata. Le routine in questa cartella verranno spostate nella schermata principale.';
}

// Path: routines.editor.exercises
class Translations$routines$editor$exercises$it implements Translations$routines$editor$exercises$en {
	Translations$routines$editor$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Esercizi';
	@override String get add => 'Aggiungi esercizi';
}

// Path: routines.editor.fields
class Translations$routines$editor$fields$it implements Translations$routines$editor$fields$en {
	Translations$routines$editor$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$routines$editor$fields$name$it name = Translations$routines$editor$fields$name$it._(_root);
	@override late final Translations$routines$editor$fields$infobox$it infobox = Translations$routines$editor$fields$infobox$it._(_root);
}

// Path: routines.editor.superset
class Translations$routines$editor$superset$it implements Translations$routines$editor$superset$en {
	Translations$routines$editor$superset$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Superserie';
	@override String get add => 'Aggiungi superserie';
	@override String subtitle({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Superserie senza esercizi',
		one: 'Superserie con un esercizio',
		two: 'Superserie con ${n} esercizi',
		few: 'Superserie con ${n} esercizi',
		many: 'Superserie con ${n} esercizi',
		other: 'Superserie con ${n} esercizi',
	);
	@override String get addExercise => 'Aggiungi esercizi';
	@override late final Translations$routines$editor$superset$remove$it remove = Translations$routines$editor$superset$remove$it._(_root);
}

// Path: history.actions.deleteMultiple
class Translations$history$actions$deleteMultiple$it implements Translations$history$actions$deleteMultiple$en {
	Translations$history$actions$deleteMultiple$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String title({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: 'Rimuovi esercizio',
		two: 'Rimuovi ${n} esercizi',
		few: 'Rimuovi ${n} esercizi',
		many: 'Rimuovi ${n} esercizi',
		other: 'Rimuovi ${n} esercizi',
	);
	@override String text({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: 'Sei sicuro di voler eliminare questo esercizio dalla tua cronologia? Quest\'azione non può essere annullata.',
		two: 'Sei sicuro di voler eliminare questi esercizi dalla tua cronologia? Quest\'azione non può essere annullata.',
		few: 'Sei sicuro di voler eliminare questi esercizi dalla tua cronologia? Quest\'azione non può essere annullata.',
		many: 'Sei sicuro di voler eliminare questi esercizi dalla tua cronologia? Quest\'azione non può essere annullata.',
		other: 'Sei sicuro di voler eliminare questi esercizi dalla tua cronologia? Quest\'azione non può essere annullata.',
	);
	@override late final Translations$history$actions$deleteMultiple$actions$it actions = Translations$history$actions$deleteMultiple$actions$it._(_root);
	@override String done({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		one: 'L\'esercizio è stato eliminato dalla tua cronologia.',
		two: 'Gli esercizi sono stati eliminati dalla tua cronologia.',
		few: 'Gli esercizi sono stati eliminati dalla tua cronologia.',
		many: 'Gli esercizi sono stati eliminati dalla tua cronologia.',
		other: 'Gli esercizi sono stati eliminati dalla tua cronologia.',
	);
}

// Path: settings.options.useDynamicColor
class Translations$settings$options$useDynamicColor$it implements Translations$settings$options$useDynamicColor$en {
	Translations$settings$options$useDynamicColor$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Usa colore dinamico';
}

// Path: settings.options.color
class Translations$settings$options$color$it implements Translations$settings$options$color$en {
	Translations$settings$options$color$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Colore dell\'applicazione';
}

// Path: settings.options.locale
class Translations$settings$options$locale$it implements Translations$settings$options$locale$en {
	Translations$settings$options$locale$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Lingua dell\'applicazione';
	@override late final Translations$settings$options$locale$values$it values = Translations$settings$options$locale$values$it._(_root);
}

// Path: settings.options.weightUnit
class Translations$settings$options$weightUnit$it implements Translations$settings$options$weightUnit$en {
	Translations$settings$options$weightUnit$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Unità di peso';
}

// Path: settings.options.distanceUnit
class Translations$settings$options$distanceUnit$it implements Translations$settings$options$distanceUnit$en {
	Translations$settings$options$distanceUnit$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Unità di distanza';
}

// Path: settings.options.showSuggestedRoutines
class Translations$settings$options$showSuggestedRoutines$it implements Translations$settings$options$showSuggestedRoutines$en {
	Translations$settings$options$showSuggestedRoutines$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Mostra routine suggerite';
}

// Path: settings.options.import
class Translations$settings$options$import$it implements Translations$settings$options$import$en {
	Translations$settings$options$import$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Importa dati';
	@override String get success => 'Dati importati con successo';
	@override late final Translations$settings$options$import$failed$it failed = Translations$settings$options$import$failed$it._(_root);
	@override late final Translations$settings$options$import$utils$it utils = Translations$settings$options$import$utils$it._(_root);
	@override late final Translations$settings$options$import$types$it types = Translations$settings$options$import$types$it._(_root);
}

// Path: settings.options.themeMode
class Translations$settings$options$themeMode$it implements Translations$settings$options$themeMode$en {
	Translations$settings$options$themeMode$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Tema';
	@override Map<String, String> get values => {
		'system': 'Sistema',
		'light': 'Chiaro',
		'dark': 'Scuro',
	};
}

// Path: settings.options.export
class Translations$settings$options$export$it implements Translations$settings$options$export$en {
	Translations$settings$options$export$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Esporta dati (JSON)';
	@override String get filename => 'Dati_GymBro';
	@override late final Translations$settings$options$export$failed$it failed = Translations$settings$options$export$failed$it._(_root);
}

// Path: settings.options.notifications
class Translations$settings$options$notifications$it implements Translations$settings$options$notifications$en {
	Translations$settings$options$notifications$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Stato notifiche';
	@override late final Translations$settings$options$notifications$subtitle$it subtitle = Translations$settings$options$notifications$subtitle$it._(_root);
}

// Path: settings.options.tintExercises
class Translations$settings$options$tintExercises$it implements Translations$settings$options$tintExercises$en {
	Translations$settings$options$tintExercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Colora pagine degli esercizi';
	@override String get subtitle => 'Applica alle pagine degli esercizi il colore della categoria di appartenenza';
}

// Path: settings.options.defaultToSimpleWorkoutView
class Translations$settings$options$defaultToSimpleWorkoutView$it implements Translations$settings$options$defaultToSimpleWorkoutView$en {
	Translations$settings$options$defaultToSimpleWorkoutView$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Usa la vista semplificata dell\'allenamento come predefinita';
	@override String get subtitle => 'Apri la schermata compatta quando avvii o riprendi un allenamento';
}

// Path: settings.options.exportSQL
class Translations$settings$options$exportSQL$it implements Translations$settings$options$exportSQL$en {
	Translations$settings$options$exportSQL$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get text => 'Esporta il file del database di Gym Bro. Non potrai reimportarlo (ma i dati non saranno cancellati).';
	@override String get label => 'Esporta database completo (SQL)';
}

// Path: settings.options.health
class Translations$settings$options$health$it implements Translations$settings$options$health$en {
	Translations$settings$options$health$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Salute e parametri vitali';
}

// Path: settings.colorPicker.heading
class Translations$settings$colorPicker$heading$it implements Translations$settings$colorPicker$heading$en {
	Translations$settings$colorPicker$heading$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String label({required Object color}) => 'Seleziona un colore [${color}]';
}

// Path: settings.advanced.options
class Translations$settings$advanced$options$it implements Translations$settings$advanced$options$en {
	Translations$settings$advanced$options$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$settings$advanced$options$logs$it logs = Translations$settings$advanced$options$logs$it._(_root);
	@override late final Translations$settings$advanced$options$migrations$it migrations = Translations$settings$advanced$options$migrations$it._(_root);
	@override late final Translations$settings$advanced$options$backups$it backups = Translations$settings$advanced$options$backups$it._(_root);
	@override late final Translations$settings$advanced$options$sync$it sync = Translations$settings$advanced$options$sync$it._(_root);
}

// Path: settings.advanced.deleteAccount
class Translations$settings$advanced$deleteAccount$it implements Translations$settings$advanced$deleteAccount$en {
	Translations$settings$advanced$deleteAccount$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Elimina il tuo account';
	@override late final Translations$settings$advanced$deleteAccount$warning$it warning = Translations$settings$advanced$deleteAccount$warning$it._(_root);
	@override late final Translations$settings$advanced$deleteAccount$confirmation$it confirmation = Translations$settings$advanced$deleteAccount$confirmation$it._(_root);
	@override String get deleting => 'Eliminazione in corso...';
}

// Path: ongoingWorkout.actions.short
class Translations$ongoingWorkout$actions$short$it implements Translations$ongoingWorkout$actions$short$en {
	Translations$ongoingWorkout$actions$short$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Annulla';
	@override String get resume => 'Riprendi';
}

// Path: ongoingWorkout.finish.fields
class Translations$ongoingWorkout$finish$fields$it implements Translations$ongoingWorkout$finish$fields$en {
	Translations$ongoingWorkout$finish$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$ongoingWorkout$finish$fields$name$it name = Translations$ongoingWorkout$finish$fields$name$it._(_root);
	@override late final Translations$ongoingWorkout$finish$fields$startingTime$it startingTime = Translations$ongoingWorkout$finish$fields$startingTime$it._(_root);
	@override late final Translations$ongoingWorkout$finish$fields$parent$it parent = Translations$ongoingWorkout$finish$fields$parent$it._(_root);
	@override late final Translations$ongoingWorkout$finish$fields$duration$it duration = Translations$ongoingWorkout$finish$fields$duration$it._(_root);
	@override late final Translations$ongoingWorkout$finish$fields$infobox$it infobox = Translations$ongoingWorkout$finish$fields$infobox$it._(_root);
}

// Path: ongoingWorkout.finish.discard
class Translations$ongoingWorkout$finish$discard$it implements Translations$ongoingWorkout$finish$discard$en {
	Translations$ongoingWorkout$finish$discard$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Scartare le modifiche?';
	@override String get text => 'Le modifiche al riepilogo verranno scartate. L’allenamento rimarrà in corso.';
	@override String get keep => 'Continua a modificare';
	@override String get confirm => 'Scarta modifiche';
}

// Path: ongoingWorkout.cancel.actions
class Translations$ongoingWorkout$cancel$actions$it implements Translations$ongoingWorkout$cancel$actions$en {
	Translations$ongoingWorkout$cancel$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get no => 'Annulla';
	@override String get yes => 'Scarta';
}

// Path: ongoingWorkout.overwrite.actions
class Translations$ongoingWorkout$overwrite$actions$it implements Translations$ongoingWorkout$overwrite$actions$en {
	Translations$ongoingWorkout$overwrite$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get no => 'Annulla';
	@override String get yes => 'Avvia';
}

// Path: ongoingWorkout.updateRoutine.differences
class Translations$ongoingWorkout$updateRoutine$differences$it implements Translations$ongoingWorkout$updateRoutine$differences$en {
	Translations$ongoingWorkout$updateRoutine$differences$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String added({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Nessun esercizio aggiunto',
		one: '1 esercizio aggiunto',
		two: '${n} esercizi aggiunti',
		few: '${n} esercizi aggiunti',
		many: '${n} esercizi aggiunti',
		other: '${n} esercizi aggiunti',
	);
	@override String removed({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Nessun esercizio rimosso',
		one: '1 esercizio rimosso',
		two: '${n} esercizi rimossi',
		few: '${n} esercizi rimossi',
		many: '${n} esercizi rimossi',
		other: '${n} esercizi rimossi',
	);
	@override String changed({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Nessun esercizio modificato',
		one: '1 esercizio modificato',
		two: '${n} esercizi modificati',
		few: '${n} esercizi modificati',
		many: '${n} esercizi modificati',
		other: '${n} esercizi modificati',
	);
	@override String reordered({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n,
		zero: 'Nessun esercizio riordinato',
		one: '1 esercizio riordinato',
		two: '${n} esercizi riordinati',
		few: '${n} esercizi riordinati',
		many: '${n} esercizi riordinati',
		other: '${n} esercizi riordinati',
	);
	@override String get metadata => 'Nome o note della routine modificati';
}

// Path: ongoingWorkout.exercisesToSuperset.errors
class Translations$ongoingWorkout$exercisesToSuperset$errors$it implements Translations$ongoingWorkout$exercisesToSuperset$errors$en {
	Translations$ongoingWorkout$exercisesToSuperset$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get addingNonContiguous => 'Puoi aggiungere solo esercizi vicini l\'un l\'altro';
	@override String get removingMiddle => 'Puoi deselezionare solo il primo o l\'ultimo esercizio.';
	@override String get notExercise => 'Devi selezionare un esercizio.';
	@override String get tooFew => 'Seleziona almeno due esercizi.';
	@override String get differingSets => 'Gli esercizi selezionati devono avere lo stesso numero di serie.';
}

// Path: general.dialogs.actions
class Translations$general$dialogs$actions$it implements Translations$general$dialogs$actions$en {
	Translations$general$dialogs$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get ok => 'OK';
	@override String get cancel => 'Annulla';
	@override String get close => 'Chiudi';
}

// Path: library.cardio.exercises
class Translations$library$cardio$exercises$it implements Translations$library$cardio$exercises$en {
	Translations$library$cardio$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get burpees => 'Burpees';
	@override String get squatThrusts => 'Squat thrust (senza salto)';
	@override String get jumpingJacks => 'Jumping jack';
	@override String get highKnees => 'Corsa sul posto a ginocchia alte';
	@override String get buttKicks => 'Corsa calciata dietro sul posto';
	@override String get skaterJumps => 'Salti laterali del pattinatore';
	@override String get squatJumps => 'Squat con salto';
	@override String get plankJacks => 'Plank jack';
	@override String get aerobics => 'Aerobica';
	@override String get biking => 'Bicicletta';
	@override String get ergometer => 'Cyclette verticale';
	@override String get ergometerHorizontal => 'Cyclette orizzontale';
	@override String get pilates => 'Pilates';
	@override String get running => 'Corsa';
	@override String get treadmill => 'Tapis roulant';
	@override String get zumba => 'Zumba';
	@override String get jumpRope => 'Salto con la corda';
	@override String get rowingMachine => 'Remoergometro';
	@override String get bicycleCrunchesCardio => 'Bicycle crunch a tempo';
	@override String get crunchesTimed => 'Crunch a tempo';
	@override String get straddleJumps => 'Salti a gambe divaricate';
	@override String get forwardAndBackwardSteps => 'Passi avanti e indietro';
	@override String get bearCrawl => 'Camminata dell’orso';
	@override String get ellipticalCycling => 'Pedalata sul cross trainer';
	@override String get burpeeDumbbell => 'Burpee (manubri)';
	@override String get partialKneeBends => 'Piegamenti parziali delle ginocchia';
	@override String get armCycleErgometer => 'Ergometro a braccia';
	@override String get wallSupportedHighKnees => 'Ginocchia alte con appoggio alla parete';
	@override String get burpeeWithJumpingJack => 'Burpee con salto a gambe divaricate';
	@override String get jumpingJackHops => 'Saltelli con apertura di braccia e gambe';
	@override String get pushUpIntoRunningStart => 'Piegamento con partenza in corsa';
	@override String get scissorJumps => 'Salti con scambio delle gambe';
	@override String get squatSemiJump => 'Squat (mezzo, con salto)';
	@override String get shortStrideRunning => 'Corsa a passi corti';
	@override String get skiergDoublePolePull => 'Tirate a doppio bastoncino allo SkiErg';
	@override String get alternatingSkiSteps => 'Passi alternati da sci';
	@override String get explosiveStarJumps => 'Salti esplosivi a stella';
	@override String get kettlebellCircularSwing => 'Swing circolare con kettlebell';
	@override String get ellipticalTrainerWalking => 'Camminata sull’ellittica';
	@override String get lungeWalkingHighKnee => 'Affondo (camminato, ginocchia alte)';
	@override String get inclineTreadmillWalking => 'Camminata in salita sul tapis roulant';
	@override String get stairClimberStepping => 'Salita dei gradini allo stepmill';
	@override String get repeatedSprintIntervals => 'Scatti di corsa ripetuti';
}

// Path: library.chest.exercises
class Translations$library$chest$exercises$it implements Translations$library$chest$exercises$en {
	Translations$library$chest$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get inclineMachineChestPress => 'Chest press inclinata alla macchina';
	@override String get midHeightCableFly => 'Croci ai cavi all’altezza del petto';
	@override String get barbellBenchPressFlat => 'Panca piana (bilanciere)';
	@override String get barbellBenchPressIncline => 'Panca inclinata (bilanciere)';
	@override String get barbellBenchPressDecline => 'Panca declinata (bilanciere)';
	@override String get dumbbellBenchPressFlat => 'Panca piana (manubri)';
	@override String get dumbbellBenchPressIncline => 'Panca inclinata (manubri)';
	@override String get dumbbellBenchPressDecline => 'Panca declinata (manubri)';
	@override String get smithMachineBenchPressFlat => 'Panca piana (Multipower)';
	@override String get smithMachineBenchPressIncline => 'Panca inclinata (Multipower)';
	@override String get smithMachineBenchPressDecline => 'Panca declinata (Multipower)';
	@override String get cableBenchPressFlat => 'Panca piana (cavi)';
	@override String get cableBenchPressIncline => 'Panca inclinata (cavi)';
	@override String get cableBenchPressDecline => 'Panca declinata (cavi)';
	@override String get butterflyMachine => 'Croci alla macchina (pec deck)';
	@override String get dumbbellHexPress => 'Hex press (manubri)';
	@override String get smithMachineHexPress => 'Hex press al Multipower';
	@override String get seatedCableChestFlys => 'Croci ai cavi da seduto';
	@override String get verticalChestPress => 'Chest press (verticale)';
	@override String get cableFlyCrossovers => 'Croci ai cavi alti';
	@override String get pushUps => 'Push-up';
	@override String get pushUpsWeighted => 'Push-up (zavorrati)';
	@override String get cableChestPress => 'Chest press ai cavi';
	@override String get declinePushUps => 'Push-up declinati';
	@override String get lowCableFly => 'Croci ai cavi bassi';
	@override String get inclinePushUps => 'Push-up inclinati';
	@override String get tBarPress => 'Landmine press';
	@override String get inclineBenchFlys => 'Croci su panca inclinata';
	@override String get benchFlys => 'Croci su panca piana';
	@override String get pushUpArcher => 'Piegamenti sulle braccia (arciere)';
	@override String get chestDipAssistedKneeling => 'Dip per il petto (con assistenza, in ginocchio)';
	@override String get pectoralisMajorStretchAssistedSeatedStabilityBall => 'Allungamento del grande pettorale (con assistenza, da seduti, fitball)';
	@override String get chestDipAssistedWideGripKneeling => 'Dip per il petto (con assistenza, presa larga, in ginocchio)';
	@override String get benchPressBand => 'Distensioni su panca (elastico)';
	@override String get chestPressBandOneArmTwisting => 'Distensioni per il petto (elastico, a un braccio, con torsione)';
	@override String get pulloverBarbellDecline => 'Pullover (bilanciere, su panca declinata)';
	@override String get pressBarbellDeclineWideGrip => 'Distensioni (bilanciere, su panca declinata, presa larga)';
	@override String get benchPressBarbellGuillotine => 'Distensioni su panca (bilanciere, alla gola)';
	@override String get benchPressBarbellReverseGripDecline => 'Distensioni su panca (bilanciere, presa supina, su panca declinata)';
	@override String get benchPressBarbellReverseGripIncline => 'Distensioni su panca (bilanciere, presa supina, su panca inclinata)';
	@override String get benchPressBarbellWide => 'Distensioni su panca (bilanciere, ampio)';
	@override String get benchPressBarbellWideReverseGrip => 'Distensioni su panca (bilanciere, ampio, presa supina)';
	@override String get chestStretchBehindHead => 'Allungamento dei pettorali (dietro la testa)';
	@override String get seatedButterflyStretch => 'Allungamento a farfalla da seduti';
	@override String get pressCableDeclineOneArm => 'Distensioni (cavo, su panca declinata, a un braccio)';
	@override String get flyCableIncline => 'Croci per il petto (cavo, su panca inclinata)';
	@override String get flyCableInclineStabilityBall => 'Croci per il petto (cavo, su panca inclinata, fitball)';
	@override String get flyCableLying => 'Croci per il petto (cavo, da sdraiati)';
	@override String get chestFlyCableOneArmDecline => 'Croci per il petto (cavo, a un braccio, su panca declinata)';
	@override String get flyCableOneArmExerciseBall => 'Croci per il petto (cavo, a un braccio, fitball)';
	@override String get flyCableOneArmInclineExerciseBall => 'Croci per il petto (cavo, a un braccio, su panca inclinata, fitball)';
	@override String get pressCableOneArmIncline => 'Distensioni (cavo, a un braccio, su panca inclinata)';
	@override String get pressCableOneArmInclineExerciseBall => 'Distensioni (cavo, a un braccio, su panca inclinata, fitball)';
	@override String get pressCableOneArmExerciseBall => 'Distensioni (cavo, a un braccio, fitball)';
	@override String get pressCableExerciseBall => 'Distensioni (cavo, fitball)';
	@override String get chestAndAnteriorShoulderStretch => 'Allungamento del petto e della spalla anteriore';
	@override String get chestDip => 'Dip per il petto';
	@override String get chestDipStraightBar => 'Dip per il petto (barra dritta)';
	@override String get chestStretchExerciseBall => 'Allungamento dei pettorali (fitball)';
	@override String get pushUpChestTap => 'Piegamenti sulle braccia (con tocco del petto)';
	@override String get pushUpClap => 'Piegamenti sulle braccia (con battito di mani)';
	@override String get pushUpWithAlternatingSideReach => 'Piegamenti con apertura laterale alternata';
	@override String get pushUpDeep => 'Piegamenti sulle braccia (profondo)';
	@override String get pushUpDrop => 'Piegamenti sulle braccia (con caduta)';
	@override String get flyDumbbellDecline => 'Croci per il petto (manubri, su panca declinata)';
	@override String get benchPressDumbbellDeclineNeutralGrip => 'Distensioni su panca (manubri, su panca declinata, presa neutra)';
	@override String get flyDumbbellDeclineOneArm => 'Croci per il petto (manubri, su panca declinata, a un braccio)';
	@override String get flyDumbbellDeclineTwisting => 'Croci per il petto (manubri, su panca declinata, con torsione)';
	@override String get flyDumbbellExerciseBall => 'Croci per il petto (manubri, fitball)';
	@override String get benchPressDumbbellInclineAlternate => 'Distensioni su panca (manubri, su panca inclinata, alternato)';
	@override String get flyDumbbellInclineExerciseBall => 'Croci per il petto (manubri, su panca inclinata, fitball)';
	@override String get benchPressDumbbellInclineNeutralGrip => 'Distensioni su panca (manubri, su panca inclinata, presa neutra)';
	@override String get flyDumbbellInclineOneArm => 'Croci per il petto (manubri, su panca inclinata, a un braccio)';
	@override String get flyDumbbellInclineOneArmExerciseBall => 'Croci per il petto (manubri, su panca inclinata, a un braccio, fitball)';
	@override String get pressDumbbellInclineOneArm => 'Distensioni (manubri, su panca inclinata, a un braccio)';
	@override String get pressDumbbellInclineOneArmExerciseBall => 'Distensioni (manubri, su panca inclinata, a un braccio, fitball)';
	@override String get pressDumbbellInclineExerciseBall => 'Distensioni (manubri, su panca inclinata, fitball)';
	@override String get shoulderRaiseDumbbellIncline => 'Elevazioni scapolari (manubri, su panca inclinata)';
	@override String get flyDumbbellInclineTwisting => 'Croci per il petto (manubri, su panca inclinata, con torsione)';
	@override String get pressDumbbellLyingNeutralGrip => 'Distensioni (manubri, da sdraiati, presa neutra)';
	@override String get pressDumbbellLyingOneArm => 'Distensioni (manubri, da sdraiati, a un braccio)';
	@override String get pulloverDumbbellExerciseBall => 'Pullover (manubri, fitball)';
	@override String get benchPressDumbbellNeutralGrip => 'Distensioni su panca (manubri, presa neutra)';
	@override String get flyDumbbellOneArmBench => 'Croci per il petto (manubri, a un braccio, su panca)';
	@override String get chestFlyDumbbellOneArmExerciseBall => 'Croci per il petto (manubri, a un braccio, fitball)';
	@override String get chestPressDumbbellOneArmDecline => 'Distensioni per il petto (manubri, a un braccio, su panca declinata)';
	@override String get chestPressDumbbellOneArmIncline => 'Distensioni per il petto (manubri, a un braccio, su panca inclinata)';
	@override String get pressDumbbellOneArmExerciseBall => 'Distensioni (manubri, a un braccio, fitball)';
	@override String get pulloverDumbbellOneArmExerciseBall => 'Pullover (manubri, a un braccio, fitball)';
	@override String get pressDumbbellOneArmReverseGrip => 'Distensioni (manubri, a un braccio, presa supina)';
	@override String get flyDumbbellOneLegExerciseBall => 'Croci per il petto (manubri, a una gamba, fitball)';
	@override String get pressDumbbellExerciseBall => 'Distensioni (manubri, fitball)';
	@override String get benchPressDumbbellReverse => 'Distensioni su panca (manubri, inverso)';
	@override String get benchPressDumbbellTwisting => 'Distensioni su panca (manubri, con torsione)';
	@override String get dynamicPectoralStretch => 'Allungamento dinamico dei pettorali';
	@override String get supineElbowPressUp => 'Sollevamenti del busto da supini con spinta sui gomiti';
	@override String get pikePushUpExerciseBall => 'Piegamenti a V (fitball)';
	@override String get flyFloorBarbell => 'Croci per il petto (a terra, bilanciere)';
	@override String get flyHyghtDumbbell => 'Croci per il petto (metodo Hyght, manubri)';
	@override String get pushUpInclineDepthJump => 'Piegamenti sulle braccia (su panca inclinata, con salto in profondità)';
	@override String get pushUpInclineReverseGrip => 'Piegamenti sulle braccia (su panca inclinata, presa supina)';
	@override String get pushUpInclineScapula => 'Piegamenti sulle braccia (su panca inclinata, scapolare)';
	@override String get isometricPalmToPalmChestSqueeze => 'Spinta isometrica dei palmi per i pettorali';
	@override String get isometricPushUpWithSideShifts => 'Piegamento isometrico con spostamenti laterali';
	@override String get pressKettlebellAlternateFloor => 'Distensioni (kettlebell, alternato, a terra)';
	@override String get pressKettlebellExtendedRangeOneArmFloor => 'Distensioni (kettlebell, escursione ampliata, a un braccio, a terra)';
	@override String get floorPressKettlebellOneArm => 'Distensioni da terra (kettlebell, a un braccio)';
	@override String get pushUpKettlebellPlyo => 'Piegamenti sulle braccia (kettlebell, pliometrico)';
	@override String get pushUpKneeling => 'Piegamenti sulle braccia (in ginocchio)';
	@override String get rearBarDips => 'Dip con sbarra dietro il corpo';
	@override String get chestPressLeverDecline => 'Distensioni per il petto (macchina a leva, su panca declinata)';
	@override String get chestPressLeverStanding => 'Distensioni per il petto (macchina a leva, in piedi)';
	@override String get machineChestSqueezePress => 'Distensioni convergenti per il petto alla macchina';
	@override String get medicineBallChestPass => 'Lancio della palla medica dal petto';
	@override String get medicineBallChestThrowFromThreePointStart => 'Lancio dal petto con palla medica da partenza a tre appoggi';
	@override String get repeatedMedicineBallChestPasses => 'Lanci ripetuti dal petto con palla medica';
	@override String get singleMedicineBallChestThrow => 'Lancio singolo dal petto con palla medica';
	@override String get medicineBallChestThrowWithRunOut => 'Lancio dal petto con palla medica e corsa in uscita';
	@override String get pushUpModifiedHindu => 'Piegamenti sulle braccia (hindu modificato)';
	@override String get kneelingPushUpToForearms => 'Piegamenti sulle ginocchia con passaggio agli avambracci';
	@override String get pushUpNarrowExerciseBall => 'Piegamenti sulle braccia (stretto, fitball)';
	@override String get pushUpOutsideLegKick => 'Piegamenti sulle braccia (con calcio verso l’esterno)';
	@override String get pushUpPlyo => 'Piegamenti sulle braccia (pliometrico)';
	@override String get bodyweightPushAndPull => 'Spinte e tirate a corpo libero';
	@override String get pushUpBosuBall => 'Piegamenti sulle braccia (BOSU)';
	@override String get pushUpStabilityBall => 'Piegamenti sulle braccia (fitball)';
	@override String get pushUpWall => 'Piegamenti sulle braccia (alla parete)';
	@override String get pushUpInsideLegKick => 'Piegamenti sulle braccia (con calcio verso l’interno)';
	@override String get pushUpMedicineBall => 'Piegamenti sulle braccia (palla medica)';
	@override String get pushUpLowerArms => 'Piegamenti sulle braccia (sugli avambracci)';
	@override String get pushUpPlus => 'Piegamenti sulle braccia (con protrazione scapolare)';
	@override String get pushUpIntoSidePlank => 'Piegamento con passaggio a plank laterale';
	@override String get chestPressResistanceBandSeated => 'Distensioni per il petto (elastico, da seduti)';
	@override String get seatedRollerReachForward => 'Scivolamenti del rullo in avanti da seduti';
	@override String get seatedStraightArmRollerRaise => 'Sollevamenti del rullo a braccia tese da seduti';
	@override String get pushUpScapula => 'Piegamenti sulle braccia (scapolare)';
	@override String get pushUpWithShoulderTaps => 'Piegamento con tocco delle spalle';
	@override String get pushUpSide => 'Piegamenti sulle braccia (laterale)';
	@override String get pushUpOneArm => 'Piegamenti sulle braccia (a un braccio)';
	@override String get pressSmithDeclineReverseGrip => 'Distensioni (Smith machine, su panca declinata, presa supina)';
	@override String get pressSmithInclineReverseGrip => 'Distensioni (Smith machine, su panca inclinata, presa supina)';
	@override String get inclineSmithMachineHighPull => 'Tirata alta inclinata alla Smith machine';
	@override String get benchPressSmithMachineReverseDeclineCloseGrip => 'Distensioni su panca (Smith machine, inverso, su panca declinata, presa stretta)';
	@override String get pressSmithReverseGrip => 'Distensioni (Smith machine, presa supina)';
	@override String get benchPressSmithWideGrip => 'Distensioni su panca (Smith machine, presa larga)';
	@override String get benchPressSmithWideGripDecline => 'Distensioni su panca (Smith machine, presa larga, su panca declinata)';
	@override String get pushUpSpiderCrawl => 'Piegamenti sulle braccia (con passo del ragno)';
	@override String get pushUpSuperman => 'Piegamenti sulle braccia (Superman)';
	@override String get pushUpSuspended => 'Piegamenti sulle braccia (in sospensione)';
	@override String get pushUpWeightedDrop => 'Piegamenti sulle braccia (con sovraccarico, con caduta)';
	@override String get dipWeightedStraightBar => 'Dip (con sovraccarico, barra dritta)';
	@override String get svendPressWeighted => 'Svend press (con sovraccarico)';
	@override String get pushUpWideHand => 'Piegamenti sulle braccia (ampio, mani)';
	@override String get chestDipWideGripHighParallelBars => 'Dip per il petto (presa larga, alto, alle parallele)';
}

// Path: library.biceps.exercises
class Translations$library$biceps$exercises$it implements Translations$library$biceps$exercises$en {
	Translations$library$biceps$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get behindBodyCableCurl => 'Curl al cavo con braccio dietro al busto';
	@override String get ropeHammerCurl => 'Hammer curl con corda al cavo';
	@override String get inclineDumbbellCurl => 'Curl su panca inclinata (manubri)';
	@override String get barbellBicepsCurl => 'Bicep curl (bilanciere)';
	@override String get spiderCurls => 'Spider curl';
	@override String get singleArmCableHammerCurls => 'Hammer curl ai cavi (braccio singolo)';
	@override String get cableBicepsCurl => 'Bicep curl (cavi)';
	@override String get dumbbellBicepsCurl => 'Bicep curl (manubri)';
	@override String get bicepsCurlMachine => 'Bicep curl (macchina)';
	@override String get hammerCurlDumbbell => 'Hammer curl (manubri)';
	@override String get concentrationCurl => 'Curl concentrati';
	@override String get scottCurl => 'Curl alla panca Scott';
	@override String get dualCableHighCurl => 'Curl ai cavi alti';
	@override String get bicepsCurlBandAlternate => 'Curl per i bicipiti (elastico, alternato)';
	@override String get concentrationCurlBand => 'Curl concentrato (elastico)';
	@override String get bicepsCurlBandOneArmOverhead => 'Curl per i bicipiti (elastico, a un braccio, sopra la testa)';
	@override String get bicepsCurlBarbellAlternate => 'Curl per i bicipiti (bilanciere, alternato)';
	@override String get bicepsCurlBarbellArmBlaster => 'Curl per i bicipiti (bilanciere, arm blaster)';
	@override String get dragCurlBarbell => 'Drag curl (bilanciere)';
	@override String get preacherCurlBarbellLying => 'Curl alla panca Scott (bilanciere, da sdraiati)';
	@override String get preacherCurlBarbell => 'Curl alla panca Scott (bilanciere)';
	@override String get reversePreacherCurlBarbell => 'Curl inverso alla panca Scott (bilanciere)';
	@override String get concentrationCurlBarbellSeatedCloseGrip => 'Curl concentrato (bilanciere, da seduti, presa stretta)';
	@override String get curlBarbellStandingCloseGrip => 'Curl per i bicipiti (bilanciere, in piedi, presa stretta)';
	@override String get concentrationCurlBarbellStanding => 'Curl concentrato (bilanciere, in piedi)';
	@override String get bicepsCurlBarbellStandingWideGrip => 'Curl per i bicipiti (bilanciere, in piedi, presa larga)';
	@override String get legResistedConcentrationCurl => 'Curl concentrato contro la resistenza della gamba';
	@override String get chinUpCloseGrip => 'Trazioni a presa supina (presa stretta)';
	@override String get bicepsCurlBodyweightSideLying => 'Curl per i bicipiti (corpo libero, sdraiati sul fianco)';
	@override String get curlCableCloseGrip => 'Curl per i bicipiti (cavo, presa stretta)';
	@override String get concentrationCurlCable => 'Curl concentrato (cavo)';
	@override String get dragCurlCable => 'Drag curl (cavo)';
	@override String get bicepsCurlCableLying => 'Curl per i bicipiti (cavo, da sdraiati)';
	@override String get curlCableLyingCloseGrip => 'Curl per i bicipiti (cavo, da sdraiati, presa stretta)';
	@override String get curlCableOneArm => 'Curl per i bicipiti (cavo, a un braccio)';
	@override String get preacherCurlCableOneArm => 'Curl alla panca Scott (cavo, a un braccio)';
	@override String get reversePreacherCurlCableOneArm => 'Curl inverso alla panca Scott (cavo, a un braccio)';
	@override String get curlCableOverheadExerciseBall => 'Curl per i bicipiti (cavo, sopra la testa, fitball)';
	@override String get preacherCurlCable => 'Curl alla panca Scott (cavo)';
	@override String get bicepsCurlCablePulldown => 'Curl per i bicipiti (cavo, dall’alto)';
	@override String get reverseCurlCable => 'Curl inverso (cavo)';
	@override String get reversePreacherCurlCable => 'Curl inverso alla panca Scott (cavo)';
	@override String get hammerPreacherCurlCableRope => 'Curl a martello alla panca Scott (cavo, corda)';
	@override String get hammerPreacherCurlCableRopeOneArm => 'Curl a martello alla panca Scott (cavo, corda, a un braccio)';
	@override String get curlCableSeated => 'Curl per i bicipiti (cavo, da seduti)';
	@override String get concentrationCurlCableSeatedOneArm => 'Curl concentrato (cavo, da seduti, a un braccio)';
	@override String get curlCableSeatedOverhead => 'Curl per i bicipiti (cavo, da seduti, sopra la testa)';
	@override String get curlCableSquatting => 'Curl per i bicipiti (cavo, in accosciata)';
	@override String get curlCableStandingInner => 'Curl per i bicipiti (cavo, in piedi, gomiti aperti)';
	@override String get bicepsCurlCableRopeStanding => 'Curl per i bicipiti (cavo, corda, in piedi)';
	@override String get curlCableTwoArmInclineBench => 'Curl per i bicipiti (cavo, a due braccia, su panca inclinata)';
	@override String get bicepsCurlDumbbellAlternate => 'Curl per i bicipiti (manubri, alternato)';
	@override String get bicepsCurlDumbbellAlternateArmBlaster => 'Curl per i bicipiti (manubri, alternato, arm blaster)';
	@override String get hammerPreacherCurlDumbbellAlternate => 'Curl a martello alla panca Scott (manubri, alternato)';
	@override String get preacherCurlDumbbellAlternate => 'Curl alla panca Scott (manubri, alternato)';
	@override String get hammerCurlDumbbellAlternateSeated => 'Curl a martello (manubri, alternato, da seduti)';
	@override String get bicepsCurlDumbbellAlternateLegRaisedExerciseBall => 'Curl per i bicipiti (manubri, alternato, con gamba sollevata, fitball)';
	@override String get bicepsCurlDumbbellAlternateSeatedExerciseBall => 'Curl per i bicipiti (manubri, alternato, da seduti, fitball)';
	@override String get dumbbellCurlWithBowlingLunge => 'Curl con manubri e affondo con gesto da bowling';
	@override String get bicepsCurlDumbbellExerciseBallLegRaised => 'Curl per i bicipiti (manubri, fitball, con gamba sollevata)';
	@override String get bicepsCurlDumbbellStorkStance => 'Curl per i bicipiti (manubri, in equilibrio su una gamba)';
	@override String get bicepsCurlDumbbellArmBlaster => 'Curl per i bicipiti (manubri, arm blaster)';
	@override String get bicepsCurlSquatDumbbell => 'Squat e curl per i bicipiti (manubri)';
	@override String get bicepsCurlDumbbellVSitBosuBall => 'Curl per i bicipiti (manubri, in squadra a V, BOSU)';
	@override String get hammerCurlDumbbellCrossBody => 'Curl a martello (manubri, incrociato)';
	@override String get hammerCurlDumbbellExerciseBall => 'Curl a martello (manubri, fitball)';
	@override String get hammerCurlDumbbellArmBlaster => 'Curl a martello (manubri, arm blaster)';
	@override String get highCurlDumbbell => 'Curl alto (manubri)';
	@override String get preacherCurlDumbbellIncline => 'Curl alla panca Scott (manubri, su panca inclinata)';
	@override String get hammerCurlDumbbellIncline => 'Curl a martello (manubri, su panca inclinata)';
	@override String get innerBicepsCurlDumbbellIncline => 'Curl per i bicipiti con gomiti aperti (manubri, su panca inclinata)';
	@override String get bicepsCurlDumbbellKneelingExerciseBall => 'Curl per i bicipiti (manubri, in ginocchio, fitball)';
	@override String get lungeBicepsCurlDumbbell => 'Affondo e curl per i bicipiti (manubri)';
	@override String get bicepsCurlDumbbellLyingSupine => 'Curl per i bicipiti (manubri, da sdraiati, in posizione supina)';
	@override String get bicepsCurlDumbbellLying => 'Curl per i bicipiti (manubri, da sdraiati)';
	@override String get curlDumbbellLyingWide => 'Curl per i bicipiti (manubri, da sdraiati, ampio)';
	@override String get concentrationCurlDumbbellOneArmStabilityBall => 'Curl concentrato (manubri, a un braccio, fitball)';
	@override String get hammerPreacherCurlDumbbellOneArm => 'Curl a martello alla panca Scott (manubri, a un braccio)';
	@override String get curlDumbbellOneArmProne => 'Curl per i bicipiti (manubri, a un braccio, in posizione prona)';
	@override String get hammerCurlDumbbellOneArmProne => 'Curl a martello (manubri, a un braccio, in posizione prona)';
	@override String get reversePreacherCurlDumbbellOneArm => 'Curl inverso alla panca Scott (manubri, a un braccio)';
	@override String get reverseSpiderCurlDumbbellOneArm => 'Spider curl inverso (manubri, a un braccio)';
	@override String get bicepsCurlDumbbellOneArmSeatedExerciseBall => 'Curl per i bicipiti (manubri, a un braccio, da seduti, fitball)';
	@override String get hammerCurlDumbbellOneArmSeated => 'Curl a martello (manubri, a un braccio, da seduti)';
	@override String get curlDumbbellOneArmStanding => 'Curl per i bicipiti (manubri, a un braccio, in piedi)';
	@override String get hammerCurlDumbbellOneArmStanding => 'Curl a martello (manubri, a un braccio, in piedi)';
	@override String get zottmanPreacherCurlDumbbellOneArm => 'Curl Zottman alla panca Scott (manubri, a un braccio)';
	@override String get hammerPreacherCurlDumbbell => 'Curl a martello alla panca Scott (manubri)';
	@override String get preacherCurlDumbbellExerciseBall => 'Curl alla panca Scott (manubri, fitball)';
	@override String get curlDumbbellProneIncline => 'Curl per i bicipiti (manubri, in posizione prona, su panca inclinata)';
	@override String get hammerCurlDumbbellProneIncline => 'Curl a martello (manubri, in posizione prona, su panca inclinata)';
	@override String get reversePreacherCurlDumbbell => 'Curl inverso alla panca Scott (manubri)';
	@override String get reverseSpiderCurlDumbbell => 'Spider curl inverso (manubri)';
	@override String get hammerCurlDumbbellSeatedAlternateExerciseBall => 'Curl a martello (manubri, da seduti, alternato, fitball)';
	@override String get bicepsCurlDumbbellSeated => 'Curl per i bicipiti (manubri, da seduti)';
	@override String get bicepsCurlDumbbellSeatedExerciseBall => 'Curl per i bicipiti (manubri, da seduti, fitball)';
	@override String get hammerCurlDumbbellSeated => 'Curl a martello (manubri, da seduti)';
	@override String get innerBicepsCurlDumbbellSeated => 'Curl per i bicipiti con gomiti aperti (manubri, da seduti)';
	@override String get bicepsCurlDumbbellSeatedOneArmExerciseBallLegRaised => 'Curl per i bicipiti (manubri, da seduti, a un braccio, fitball, con gamba sollevata)';
	@override String get preacherCurlDumbbellSeated => 'Curl alla panca Scott (manubri, da seduti)';
	@override String get concentrationCurlDumbbellSeatedReverse => 'Curl concentrato (manubri, da seduti, inverso)';
	@override String get hammerCurlAndPressDumbbellStandingAlternate => 'Curl a martello e distensioni (manubri, in piedi, alternato)';
	@override String get concentrationCurlDumbbellStanding => 'Curl concentrato (manubri, in piedi)';
	@override String get innerBicepsCurlDumbbellStanding => 'Curl per i bicipiti con gomiti aperti (manubri, in piedi)';
	@override String get concentrationCurlDumbbellStandingOneArm => 'Curl concentrato (manubri, in piedi, a un braccio)';
	@override String get curlDumbbellStandingOneArmInclineBench => 'Curl per i bicipiti (manubri, in piedi, a un braccio, su panca inclinata)';
	@override String get preacherCurlDumbbellStanding => 'Curl alla panca Scott (manubri, in piedi)';
	@override String get zottmanPreacherCurlDumbbellStanding => 'Curl Zottman alla panca Scott (manubri, in piedi)';
	@override String get stepUpWithBalanceAndDumbbellCurl => 'Salita sul gradino in equilibrio e curl con manubri';
	@override String get bicepsCurlDumbbellWaiter => 'Curl per i bicipiti (manubri, presa a vassoio)';
	@override String get zottmanCurlDumbbell => 'Curl Zottman (manubri)';
	@override String get zottmanPreacherCurlDumbbell => 'Curl Zottman alla panca Scott (manubri)';
	@override String get concentrationCurlEzBarSeatedCloseGrip => 'Curl concentrato (bilanciere EZ, da seduti, presa stretta)';
	@override String get preacherCurlEzBarbellCloseGrip => 'Curl alla panca Scott (bilanciere EZ, presa stretta)';
	@override String get curlEzBarbellCloseGrip => 'Curl per i bicipiti (bilanciere EZ, presa stretta)';
	@override String get curlEzBarbell => 'Curl per i bicipiti (bilanciere EZ)';
	@override String get reverseCurlEzBarbell => 'Curl inverso (bilanciere EZ)';
	@override String get reversePreacherCurlEzBarbell => 'Curl inverso alla panca Scott (bilanciere EZ)';
	@override String get curlEzBarbellSeated => 'Curl per i bicipiti (bilanciere EZ, da seduti)';
	@override String get spiderCurlEzBarbell => 'Spider curl (bilanciere EZ)';
	@override String get bicepsCurlEzBarArmBlaster => 'Curl per i bicipiti (bilanciere EZ, arm blaster)';
	@override String get bicepsCurlEzBarbellStandingWideGrip => 'Curl per i bicipiti (bilanciere EZ, in piedi, presa larga)';
	@override String get cleanKettlebellBottomsUpFromHangPosition => 'Girata (kettlebell, fondo verso l’alto, dalla sospensione)';
	@override String get hangCleanKettlebellDoubleAlternate => 'Girata dalla sospensione (kettlebell, con due kettlebell, alternato)';
	@override String get preacherCurlLeverHammerGrip => 'Curl alla panca Scott (macchina a leva, presa a martello)';
	@override String get preacherCurlLever => 'Curl alla panca Scott (macchina a leva)';
	@override String get reversePreacherCurlLever => 'Curl inverso alla panca Scott (macchina a leva)';
	@override String get hammerCurlOlympicBarbell => 'Curl a martello (bilanciere olimpico)';
	@override String get bicepsCurlResistanceBandSeated => 'Curl per i bicipiti (elastico, da seduti)';
	@override String get bicepsCurlSmithMachine => 'Curl per i bicipiti (Smith machine)';
	@override String get bicepsCurlWeightedSeatedStabilityBall => 'Curl per i bicipiti (con sovraccarico, da seduti, fitball)';
}

// Path: library.abs.exercises
class Translations$library$abs$exercises$it implements Translations$library$abs$exercises$en {
	Translations$library$abs$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get abWheelRollout => 'Ab wheel rollout';
	@override String get hangingKneeRaise => 'Sollevamento delle ginocchia alla sbarra';
	@override String get mountainClimber => 'Mountain climber';
	@override String get highCableWoodchopper => 'Woodchopper al cavo dall’alto';
	@override String get reverseCrunch => 'Crunch inverso';
	@override String get cableCrunch => 'Crunch al cavo';
	@override String get pallofPress => 'Pallof press al cavo';
	@override String get crunches => 'Crunch';
	@override String get kneeRaise => 'Sollevamento delle ginocchia da sdraiati';
	@override String get legRaise => 'Sollevamento delle gambe da sdraiati';
	@override String get crunchMachine => 'Crunch machine';
	@override String get heelsUpCrunch => 'Crunch (caviglie alzate)';
	@override String get fullBodyCrunch => 'Crunch doppio';
	@override String get plank => 'Plank';
	@override String get hollowBodyHold => 'Hollow body hold';
	@override String get russianTwist => 'Russian twist';
	@override String get bicycleCrunches => 'Bicycle crunch';
	@override String get extendedReverseCrunchWithLegExtension => 'Crunch inverso con distensione delle gambe';
	@override String get toeTouches => 'Toe touches';
	@override String get heelTouches => 'Heel touches';
	@override String get deadBugHoldCardio => 'Dead bugs (a tempo)';
	@override String get deadBugHoldStatic => 'Dead bug hold (statico)';
	@override String get deadBugHold => 'Dead bugs';
	@override String get hollowBodyHoldBentKnees => 'Hollow body hold a ginocchia piegate';
	@override String get obliqueCrunches => 'Crunch obliqui';
	@override String get legRaiseParallelBars => 'Sollevamento delle gambe alle parallele';
	@override String get lateralHyperextensions => 'Iperestensioni laterali';
	@override String get sitUp34 => 'Sit-up (tre quarti)';
	@override String get sideBendOnA45Bench => 'Flessioni laterali su panca a 45°';
	@override String get legRaiseHangingStraps => 'Sollevamenti delle gambe (in sospensione alla sbarra, cinghie)';
	@override String get sitUpArmsOverheadFull => 'Sit-up (braccia sopra la testa, completo)';
	@override String get kneeRaiseAssistedHanging => 'Sollevamenti delle ginocchia (con assistenza, in sospensione alla sbarra)';
	@override String get kneeRaiseAssistedHangingThrowDown => 'Sollevamenti delle ginocchia (con assistenza, in sospensione alla sbarra, con spinta verso il basso del partner)';
	@override String get legRaiseAssistedLyingLateralThrowDown => 'Sollevamenti delle gambe (con assistenza, da sdraiati, laterale, con spinta verso il basso del partner)';
	@override String get legRaiseAssistedLyingThrowDown => 'Sollevamenti delle gambe (con assistenza, da sdraiati, con spinta verso il basso del partner)';
	@override String get russianTwistAssistedMotion => 'Torsioni russe (con assistenza, con movimento assistito)';
	@override String get sitUpAssisted => 'Sit-up (con assistenza)';
	@override String get vUpBandAlternate => 'Chiusure a V (elastico, alternato)';
	@override String get rolloutBandAssistedWheel => 'Rollout addominale (elastico, con assistenza, ruota)';
	@override String get bicycleCrunchBand => 'Crunch a bicicletta (elastico)';
	@override String get pallofPressBandHorizontal => 'Pallof press (elastico, orizzontale)';
	@override String get jackknifeSitUpBand => 'Sit-up a libro (elastico)';
	@override String get crunchBandKneelingTwisting => 'Crunch (elastico, in ginocchio, con torsione)';
	@override String get legRaiseBandLyingStraightLeg => 'Sollevamenti delle gambe (elastico, da sdraiati, gambe tese)';
	@override String get sitUpBandPush => 'Sit-up (elastico, con spinta)';
	@override String get twistBandSeated => 'Rotazioni del busto (elastico, da seduti)';
	@override String get crunchBandStanding => 'Crunch (elastico, in piedi)';
	@override String get crunchBandStandingTwisting => 'Crunch (elastico, in piedi, con torsione)';
	@override String get vUpBand => 'Chiusure a V (elastico)';
	@override String get pallofPressBandVertical => 'Pallof press (elastico, verticale)';
	@override String get sitUpBarbellPress => 'Sit-up (bilanciere, con distensione)';
	@override String get rolloutBarbell => 'Rollout addominale (bilanciere)';
	@override String get rolloutBarbellFromBench => 'Rollout addominale (bilanciere, dalla panca)';
	@override String get twistBarbellSeated => 'Rotazioni del busto (bilanciere, da seduti)';
	@override String get sideBendBarbell => 'Flessioni laterali del busto (bilanciere)';
	@override String get legRaiseBarbellSeatedAlternate => 'Sollevamenti delle gambe (bilanciere, da seduti, alternato)';
	@override String get abRolloutBarbellStanding => 'Rollout addominale (bilanciere, in piedi)';
	@override String get twistBarbellStanding => 'Rotazioni del busto (bilanciere, in piedi)';
	@override String get sidePlankBodyweightIncline => 'Plank laterale (corpo libero, su panca inclinata)';
	@override String get reverseCrunchWithVerticalHipLift => 'Crunch inverso con sollevamento verticale del bacino';
	@override String get crossBodyMountainClimber => 'Mountain climber incrociato';
	@override String get plankHipLifts => 'Sollevamenti del bacino in plank';
	@override String get cableRotationalShoulderThrow => 'Rotazione e tirata del cavo sopra la spalla';
	@override String get reverseCrunchCable => 'Crunch inverso (cavo)';
	@override String get russianTwistCableStabilityBall => 'Torsioni russe (cavo, fitball)';
	@override String get crunchCableSeated => 'Crunch (cavo, da seduti)';
	@override String get twistCableSeated => 'Rotazioni del busto (cavo, da seduti)';
	@override String get sideBendCable => 'Flessioni laterali del busto (cavo)';
	@override String get sideBendCableCrunchBosuBall => 'Flessioni laterali del busto (cavo, con flessione del busto, BOSU)';
	@override String get sideCrunchCable => 'Crunch laterale (cavo)';
	@override String get crunchCableStanding => 'Crunch (cavo, in piedi)';
	@override String get crunchCableStandingRope => 'Crunch (cavo, in piedi, corda)';
	@override String get lowToHighCableWoodchop => 'Rotazioni al cavo dal basso verso l’alto';
	@override String get reverseCrunchCableTuck => 'Crunch inverso (cavo, raccolto)';
	@override String get twistCable => 'Rotazioni del busto (cavo)';
	@override String get crabPositionToeTouches => 'Tocchi dei piedi in appoggio posteriore';
	@override String get crunchCrossBody => 'Crunch (incrociato)';
	@override String get crunchHandsOverhead => 'Crunch (mani sopra la testa)';
	@override String get crunchStabilityBall => 'Crunch (fitball)';
	@override String get crunchStabilityBallStraightArm => 'Crunch (fitball, braccia tese)';
	@override String get crunchDecline => 'Crunch (su panca declinata)';
	@override String get sitUpDecline => 'Sit-up (su panca declinata)';
	@override String get sideBendDumbbell => 'Flessioni laterali del busto (manubri)';
	@override String get alternatingElbowToKneeCrunch => 'Crunch alternato gomito-ginocchio';
	@override String get humanFlagHold => 'Tenuta della bandiera';
	@override String get sitUpFlexionLegBentKnee => 'Sit-up (con flessione delle gambe, ginocchia piegate)';
	@override String get sitUpFlexionLegStraightArm => 'Sit-up (con flessione delle gambe, braccia tese)';
	@override String get crunchFrog => 'Crunch (a rana)';
	@override String get plankTrunkRotations => 'Rotazioni del busto in plank';
	@override String get chinUpWithKneeTuck => 'Trazioni supine con raccolta delle ginocchia';
	@override String get sitUpHalf => 'Sit-up (mezzo)';
	@override String get legHipRaiseHanging => 'Sollevamenti di gambe e bacino (in sospensione alla sbarra)';
	@override String get legRaiseHanging => 'Sollevamenti delle gambe (in sospensione alla sbarra)';
	@override String get kneeRaiseHangingOblique => 'Sollevamenti delle ginocchia (in sospensione alla sbarra, obliquo)';
	@override String get hangingPikeRaise => 'Sollevamenti a squadra alla sbarra';
	@override String get legHipRaiseHangingStraightLegTwisting => 'Sollevamenti di gambe e bacino (in sospensione alla sbarra, gambe tese, con torsione)';
	@override String get inchworm => 'Camminata a bruco';
	@override String get legHipRaiseInclineStraightLeg => 'Sollevamenti di gambe e bacino (su panca inclinata, gambe tese)';
	@override String get sitUpInclineTwisting => 'Sit-up (su panca inclinata, con torsione)';
	@override String get jackknifeSitUp => 'Sit-up a libro';
	@override String get sitUpJanda => 'Sit-up (metodo Janda)';
	@override String get windmillKettlebellAdvanced => 'Windmill (kettlebell, avanzato)';
	@override String get pressKettlebellBent => 'Distensioni (kettlebell, inclinato)';
	@override String get windmillKettlebellDouble => 'Windmill (kettlebell, con due kettlebell)';
	@override String get kettlebellFigureEightPass => 'Passaggi del kettlebell a otto tra le gambe';
	@override String get windmillKettlebell => 'Windmill (kettlebell)';
	@override String get seatedKneeTucksOnBench => 'Raccolte delle ginocchia da seduti su panca';
	@override String get crunchKneeTouch => 'Crunch (con tocco delle ginocchia)';
	@override String get kneelingPlankShoulderTaps => 'Tocchi delle spalle in plank sulle ginocchia';
	@override String get lSitFloor => 'L-sit (a terra)';
	@override String get landmineTrunkRotations => 'Rotazioni del busto con landmine';
	@override String get benchKneeTucks => 'Raccolte delle ginocchia su panca';
	@override String get twistLeverKneeling => 'Rotazioni del busto (macchina a leva, in ginocchio)';
	@override String get crunchLeverSeatedChestPad => 'Crunch (macchina a leva, da seduti, con cuscino toracico)';
	@override String get legRaiseLeverSeatedCrunch => 'Sollevamenti delle gambe (macchina a leva, da seduti, con flessione del busto)';
	@override String get lungeTwist => 'Affondo (con torsione)';
	@override String get legHipRaiseLying => 'Sollevamenti di gambe e bacino (da sdraiati)';
	@override String get crunchNegative => 'Crunch (eccentrico)';
	@override String get singleArmMedicineBallSlam => 'Schiacciata della palla medica a un braccio';
	@override String get supinePelvicTilts => 'Retroversioni del bacino da supini';
	@override String get reverseStepWithOverheadReach => 'Passo indietro con allungamento delle braccia sopra la testa';
	@override String get squatPotty => 'Squat (in accosciata profonda)';
	@override String get plankWithOppositeArmAndLegReach => 'Plank con estensione di braccio e gamba opposti';
	@override String get sitUpPrisonerHalf => 'Sit-up (mani dietro la testa, mezzo)';
	@override String get twistProneStabilityBall => 'Rotazioni del busto (in posizione prona, fitball)';
	@override String get stabilityBallKneeTuck => 'Raccolte delle ginocchia sulla fitball';
	@override String get sitUpQuarter => 'Sit-up (un quarto)';
	@override String get reversePlankWithAlternatingLegRaises => 'Plank inverso con sollevamenti alternati delle gambe';
	@override String get bodySawRoller => 'Scivolamenti in plank (rullo)';
	@override String get reverseCrunchRoller => 'Crunch inverso (rullo)';
	@override String get russianTwistBodyweight => 'Torsioni russe';
	@override String get legRaiseSeated => 'Sollevamenti delle gambe (da seduti)';
	@override String get sideCrunchSeatedWall => 'Crunch laterale (da seduti, alla parete)';
	@override String get shoulderTap => 'Tocchi delle spalle in plank';
	@override String get sideBridgeHipLifts => 'Sollevamenti del bacino in ponte laterale';
	@override String get lateralLegRaisesOnParallelBars => 'Sollevamenti laterali delle gambe alle parallele';
	@override String get alternatingCrossBodyToeTouches => 'Tocchi alternati dei piedi con torsione';
	@override String get sitUp => 'Sit-up';
	@override String get sitUpArmsChest => 'Sit-up (braccia incrociate sul petto)';
	@override String get sledgehammerTireStrikes => 'Colpi di mazza sullo pneumatico';
	@override String get diagonalDumbbellTrunkRotations => 'Rotazioni diagonali del busto con manubrio';
	@override String get twistSpine => 'Rotazioni del busto (colonna vertebrale)';
	@override String get crunchStabilityBallHandsBehindHeadFull => 'Crunch (fitball, mani dietro la testa, completo)';
	@override String get rolloutStandingWheel => 'Rollout addominale (in piedi, ruota)';
	@override String get suspensionStrapAbdominalRollout => 'Rollout addominale alle cinghie';
	@override String get reverseCrunchSuspended => 'Crunch inverso (in sospensione)';
	@override String get legRaiseTwisted => 'Sollevamenti delle gambe (con torsione)';
	@override String get vSitFloor => 'Squadra a V (a terra)';
	@override String get crunchWeighted => 'Crunch (con sovraccarico)';
	@override String get sitUpWeightedDecline => 'Sit-up (con sovraccarico, su panca declinata)';
	@override String get plankWeightedFront => 'Plank (con sovraccarico, frontale)';
	@override String get legHipRaiseWeightedHanging => 'Sollevamenti di gambe e bacino (con sovraccarico, in sospensione alla sbarra)';
	@override String get crunchWeightedOverheadStabilityBall => 'Crunch (con sovraccarico, sopra la testa, fitball)';
	@override String get russianTwistWeightedLegsUp => 'Torsioni russe (con sovraccarico, gambe sollevate)';
	@override String get twistWeightedSeatedStabilityBall => 'Rotazioni del busto (con sovraccarico, da seduti, fitball)';
	@override String get sideBendWeightedStabilityBall => 'Flessioni laterali del busto (con sovraccarico, fitball)';
}

// Path: library.calves.exercises
class Translations$library$calves$exercises$it implements Translations$library$calves$exercises$en {
	Translations$library$calves$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get smithMachineCalfRaise => 'Calf raise al Multipower';
	@override String get calfRaiseStanding => 'Calf raise (in piedi)';
	@override String get calfRaiseSeated => 'Calf raise (seduti)';
	@override String get calfPressLegPressMachine => 'Calf press alla leg press';
	@override String get ankleRotations => 'Rotazioni delle caviglie';
	@override String get calvesStretchAssistedLying => 'Allungamento dei polpacci (con assistenza, da sdraiati)';
	@override String get calfRaiseBandOneLeg => 'Sollevamenti sui polpacci (elastico, a una gamba)';
	@override String get reverseCalfRaiseBandOneLeg => 'Sollevamenti delle punte dei piedi (elastico, a una gamba)';
	@override String get calfRaiseBandStanding => 'Sollevamenti sui polpacci (elastico, in piedi)';
	@override String get calfRaiseBarbellFloor => 'Sollevamenti sui polpacci (bilanciere, a terra)';
	@override String get calfRaiseBarbellSeated => 'Sollevamenti sui polpacci (bilanciere, da seduti)';
	@override String get calfRaiseBarbellStanding => 'Sollevamenti sui polpacci (bilanciere, in piedi)';
	@override String get calfRaiseBarbellStandingRockingLeg => 'Sollevamenti sui polpacci (bilanciere, in piedi, con oscillazione sulle punte)';
	@override String get standingBodyweightCalfRaise => 'Sollevamenti sui polpacci in piedi a corpo libero';
	@override String get boxDropWithSingleLegLanding => 'Discesa dal box con atterraggio su una gamba';
	@override String get calfRaiseCableStanding => 'Sollevamenti sui polpacci (cavo, in piedi)';
	@override String get calfRaiseCableStandingOneLeg => 'Sollevamenti sui polpacci (cavo, in piedi, a una gamba)';
	@override String get wallCalfStretch => 'Allungamento dei polpacci alla parete';
	@override String get calfStretchRope => 'Allungamento dei polpacci (corda)';
	@override String get kneeCircles => 'Circonduzioni delle ginocchia';
	@override String get calfRaiseDonkey => 'Sollevamenti sui polpacci (busto flesso)';
	@override String get calfRaiseDumbbellSeated => 'Sollevamenti sui polpacci (manubri, da seduti)';
	@override String get calfRaiseDumbbellSeatedOneLeg => 'Sollevamenti sui polpacci (manubri, da seduti, a una gamba)';
	@override String get calfRaiseDumbbellSeatedOneLegHammerGrip => 'Sollevamenti sui polpacci (manubri, da seduti, a una gamba, presa a martello)';
	@override String get calfRaiseDumbbellSeatedOneLegPalmUp => 'Sollevamenti sui polpacci (manubri, da seduti, a una gamba, palmo verso l’alto)';
	@override String get calfRaiseDumbbellOneLeg => 'Sollevamenti sui polpacci (manubri, a una gamba)';
	@override String get calfRaiseDumbbellStanding => 'Sollevamenti sui polpacci (manubri, in piedi)';
	@override String get calfRaiseExerciseBallWall => 'Sollevamenti sui polpacci (fitball, alla parete)';
	@override String get wallBallCalfRaiseBallBetweenAnkles => 'Sollevamenti sui polpacci alla parete con palla tra le caviglie';
	@override String get wallBallCalfRaiseBallBetweenKnees => 'Sollevamenti sui polpacci alla parete con palla tra le ginocchia';
	@override String get calfRaiseHack => 'Sollevamenti sui polpacci (alla hack machine)';
	@override String get calfRaiseHackOneLeg => 'Sollevamenti sui polpacci (alla hack machine, a una gamba)';
	@override String get calfPressLever => 'Spinte per i polpacci (macchina a leva)';
	@override String get calfRaiseLeverDonkey => 'Sollevamenti sui polpacci (macchina a leva, busto flesso)';
	@override String get rotaryCalfMachinePress => 'Spinte dei polpacci alla macchina rotativa';
	@override String get calfPressLeverSeated => 'Spinte per i polpacci (macchina a leva, da seduti)';
	@override String get seatedSquatCalfRaiseOnLegPress => 'Sollevamenti dei talloni in accosciata alla pressa';
	@override String get calfRaiseLeverStanding => 'Sollevamenti sui polpacci (macchina a leva, in piedi)';
	@override String get calfRaiseOneLegDonkey => 'Sollevamenti sui polpacci (a una gamba, busto flesso)';
	@override String get calfRaiseOneLegFloor => 'Sollevamenti sui polpacci (a una gamba, a terra)';
	@override String get peronealsStretch => 'Allungamento dei peronieri';
	@override String get posteriorTibialisStretch => 'Allungamento del tibiale posteriore';
	@override String get calfStretchSeated => 'Allungamento dei polpacci (da seduti)';
	@override String get calfRaiseSledForwardAngled => 'Sollevamenti sui polpacci (slitta, in avanti, inclinato)';
	@override String get calfPressSledOneLeg => 'Spinte per i polpacci (slitta, a una gamba)';
	@override String get calfRaiseSmithOneLegFloor => 'Sollevamenti sui polpacci (Smith machine, a una gamba, a terra)';
	@override String get toeRaiseSmith => 'Sollevamenti delle punte dei piedi (Smith machine)';
	@override String get calfRaiseSmithSeatedOneLeg => 'Sollevamenti sui polpacci (Smith machine, da seduti, a una gamba)';
	@override String get calfRaiseStandingStaircase => 'Sollevamenti sui polpacci (in piedi, su gradino)';
	@override String get calfStretchStanding => 'Allungamento dei polpacci (in piedi)';
	@override String get calfRaiseWeightedDonkey => 'Sollevamenti sui polpacci (con sovraccarico, busto flesso)';
}

// Path: library.quadriceps.exercises
class Translations$library$quadriceps$exercises$it implements Translations$library$quadriceps$exercises$en {
	Translations$library$quadriceps$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get reverseDumbbellLunges => 'Affondi indietro (manubri)';
	@override String get walkingDumbbellLunges => 'Affondi camminati (manubri)';
	@override String get lateralDumbbellLunges => 'Affondi laterali (manubrio)';
	@override String get sumoDumbbellSquat => 'Squat sumo (manubrio)';
	@override String get singleLegLegPress => 'Leg press a una gamba';
	@override String get smithMachineSquats => 'Squat al Multipower';
	@override String get stepUps => 'Step-up (manubri)';
	@override String get gobletSquats => 'Goblet squat (manubrio)';
	@override String get squatsBarbell => 'Squat (bilanciere)';
	@override String get legPress => 'Leg press';
	@override String get legExtension => 'Leg extension';
	@override String get smithMachineLunges => 'Affondi al Multipower';
	@override String get lunges => 'Affondi con manubri';
	@override String get legPress45deg => 'Leg press (45°)';
	@override String get frontSquats => 'Squat frontali';
	@override String get bulgarianSplitSquats => 'Squat bulgari';
	@override String get bodyweightSquats => 'Squat a corpo libero';
	@override String get hackSquats => 'Hack squat';
	@override String get quadricepsStretchQuadruped => 'Allungamento dei quadricipiti (in quadrupedia)';
	@override String get quadricepsStretchAssistedProne => 'Allungamento dei quadricipiti (con assistenza, in posizione prona)';
	@override String get backwardJump => 'Salto all’indietro';
	@override String get balanceBoardStance => 'Equilibrio sulla tavoletta';
	@override String get splitSquatBandOneArmOneLeg => 'Split squat (elastico, a un braccio, a una gamba)';
	@override String get splitSquatBandOneLeg => 'Split squat (elastico, a una gamba)';
	@override String get squatBand => 'Squat (elastico)';
	@override String get squatRowBand => 'Squat e rematore (elastico)';
	@override String get stepUpBand => 'Salita sul gradino (elastico)';
	@override String get frontSquatBarbellBench => 'Squat frontale (bilanciere, su panca)';
	@override String get squatBarbellBench => 'Squat (bilanciere, su panca)';
	@override String get cleanAndPressBarbell => 'Girata e distensione (bilanciere)';
	@override String get zercherSquatBarbellFull => 'Zercher squat (bilanciere, completo)';
	@override String get hackSquatBarbell => 'Hack squat (bilanciere)';
	@override String get squatBarbellHighBar => 'Squat (bilanciere, bilanciere alto)';
	@override String get jeffersonSquatBarbell => 'Jefferson squat (bilanciere)';
	@override String get jumpSquatBarbell => 'Squat con salto (bilanciere)';
	@override String get lateralLungeBarbell => 'Affondo laterale (bilanciere)';
	@override String get squatBarbellLowBar => 'Squat (bilanciere, bilanciere basso)';
	@override String get lungeBarbell => 'Affondo (bilanciere)';
	@override String get squatBarbellNarrowStance => 'Squat (bilanciere, piedi ravvicinati)';
	@override String get squatBarbellOneLeg => 'Squat (bilanciere, a una gamba)';
	@override String get squatBarbellOverhead => 'Squat (bilanciere, sopra la testa)';
	@override String get rearLungeBarbell => 'Affondo indietro (bilanciere)';
	@override String get splitSquatBarbellSide => 'Split squat (bilanciere, laterale)';
	@override String get splitSquatBarbellOneLeg => 'Split squat (bilanciere, a una gamba)';
	@override String get squatBarbellSpeed => 'Squat (bilanciere, veloce)';
	@override String get splitSquatBarbell => 'Split squat (bilanciere)';
	@override String get squatBarbellKnee => 'Squat (bilanciere, sulle ginocchia)';
	@override String get barbellSquatJumpIntoReverseLunge => 'Squat con salto e affondo indietro con bilanciere';
	@override String get stepUpBarbell => 'Salita sul gradino (bilanciere)';
	@override String get squatBarbellWide => 'Squat (bilanciere, ampio)';
	@override String get zercherSquatBarbell => 'Zercher squat (bilanciere)';
	@override String get jumpSquatBodyweightDrop => 'Squat con salto (corpo libero, con caduta)';
	@override String get chairSupportedQuadricepsStretch => 'Allungamento dei quadricipiti con appoggio su sedia';
	@override String get curtsySquat => 'Squat con incrocio della gamba dietro';
	@override String get squatDumbbellBench => 'Squat (manubri, su panca)';
	@override String get lungeDumbbellContralateralForward => 'Affondo (manubri, in avanti con carico controlaterale)';
	@override String get squatDumbbellPlyo => 'Squat (manubri, pliometrico)';
	@override String get squatDumbbellPistol => 'Squat (manubri, pistol)';
	@override String get squatDumbbell => 'Squat (manubri)';
	@override String get stepUpLungeDumbbell => 'Salita sul gradino e affondo (manubri)';
	@override String get stepUpSplitSquatDumbbell => 'Salita sul gradino e split squat (manubri)';
	@override String get squatDumbbellSupported => 'Squat (manubri, con appoggio)';
	@override String get farmersWalk => 'Camminata del contadino';
	@override String get forwardJump => 'Salto in avanti';
	@override String get lungeForward => 'Affondo (in avanti)';
	@override String get squatFrankenstein => 'Squat (braccia tese in avanti)';
	@override String get kneelingHipFlexorAndQuadricepsStretch => 'Allungamento in ginocchio di flessori dell’anca e quadricipiti';
	@override String get frontSquatKettlebell => 'Squat frontale (kettlebell)';
	@override String get squatKettlebellGoblet => 'Squat (kettlebell, carico al petto)';
	@override String get lungeKettlebellPassThrough => 'Affondo (kettlebell, con passaggio sotto la gamba)';
	@override String get squatKettlebellPistol => 'Squat (kettlebell, pistol)';
	@override String get kettlebellTurkishGetUpThroughSquat => 'Turkish get-up con kettlebell e risalita in squat';
	@override String get jumpSquatKneeling => 'Squat con salto (in ginocchio)';
	@override String get lungeJump => 'Affondo (con salto)';
	@override String get quadsStretchLyingSide => 'Allungamento dei quadricipiti (da sdraiati, laterale)';
	@override String get squatOneLeg => 'Squat (a una gamba)';
	@override String get squatPottySupport => 'Squat (in accosciata profonda, con appoggio)';
	@override String get rapidAlternatingFootTaps => 'Appoggi rapidi alternati dei piedi';
	@override String get legExtensionResistanceBand => 'Estensioni delle gambe (elastico)';
	@override String get squatPistol => 'Squat (pistol)';
	@override String get sissySquat => 'Sissy squat';
	@override String get hackSquatSledCloser => 'Hack squat (slitta, piedi ravvicinati)';
	@override String get squatSledLying => 'Squat (slitta, da sdraiati)';
	@override String get squatSmithChair => 'Squat (Smith machine, su sedia)';
	@override String get frontSquatSmithCleanGrip => 'Squat frontale (Smith machine, presa da girata)';
	@override String get hackSquatSmith => 'Hack squat (Smith machine)';
	@override String get squatSmithLowBar => 'Squat (Smith machine, bilanciere basso)';
	@override String get splitSquatSmithOneLeg => 'Split squat (Smith machine, a una gamba)';
	@override String get lungeSmithSprint => 'Affondo (Smith machine, con spinta da sprint)';
	@override String get squatSmithSumo => 'Squat (Smith machine, sumo)';
	@override String get snatchPull => 'Tirata dello strappo';
	@override String get splitSquat => 'Split squat';
	@override String get squatJerk => 'Spinta in accosciata';
	@override String get squatBosuBall => 'Squat (BOSU)';
	@override String get squatToOverheadReach => 'Squat (con braccia sopra la testa)';
	@override String get squatToOverheadReachTwist => 'Squat (con braccia sopra la testa e torsione)';
	@override String get splitSquatSuspended => 'Split squat (in sospensione)';
	@override String get lungeWalking => 'Affondo (camminato)';
	@override String get squatWeightedCossack => 'Squat (con sovraccarico, cosacco)';
	@override String get weightedLungeWithArmSwing => 'Affondo con sovraccarico e oscillazione delle braccia';
	@override String get sissySquatWeighted => 'Sissy squat (con sovraccarico)';
	@override String get squatWeighted => 'Squat (con sovraccarico)';
	@override String get lungeWeighted => 'Affondo (con sovraccarico)';
}

// Path: library.hamstrings.exercises
class Translations$library$hamstrings$exercises$it implements Translations$library$hamstrings$exercises$en {
	Translations$library$hamstrings$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get singleLegDumbbellRomanianDeadlift => 'Stacco rumeno a una gamba (manubrio)';
	@override String get legCurlStanding => 'Leg curl in piedi alla macchina';
	@override String get nordicCurl => 'Nordic curl';
	@override String get legCurlProne => 'Leg curl (sdraiati)';
	@override String get legCurlSeated => 'Leg curl (seduti)';
	@override String get romanianDeadlift => 'Stacchi rumeni (bilanciere)';
	@override String get romanianDeadliftDumbbell => 'Stacchi rumeni (manubri)';
	@override String get hamstringStretchAssistedProne => 'Allungamento degli ischiocrurali (con assistenza, in posizione prona)';
	@override String get straightLegDeadliftBand => 'Stacco a gambe tese (elastico)';
	@override String get goodMorningBarbell => 'Good morning (bilanciere)';
	@override String get goodMorningBarbellSeated => 'Good morning (bilanciere, da seduti)';
	@override String get goodMorningBarbellStraightLeg => 'Good morning (bilanciere, gambe tese)';
	@override String get straightLegDeadliftBarbell => 'Stacco a gambe tese (bilanciere)';
	@override String get legCurlCableAssistedInverse => 'Flessioni delle gambe (cavo, con assistenza, inverso)';
	@override String get legCurlDumbbellLying => 'Flessioni delle gambe (manubri, da sdraiati)';
	@override String get straightLegDeadliftDumbbell => 'Stacco a gambe tese (manubri)';
	@override String get hamstringStretchExerciseBallSeated => 'Allungamento degli ischiocrurali (fitball, da seduti)';
	@override String get gluteHamRaiseOnBench => 'Sollevamenti glutei-femorali su panca GHD';
	@override String get hamstringStretch => 'Allungamento degli ischiocrurali';
	@override String get hangCleanKettlebell => 'Girata dalla sospensione (kettlebell)';
	@override String get elevatedLegHamstringStretch => 'Allungamento degli ischiocrurali con gamba rialzata';
	@override String get legCurlLeverKneeling => 'Flessioni delle gambe (macchina a leva, in ginocchio)';
	@override String get legCurlLeverLyingTwoOne => 'Flessioni delle gambe (macchina a leva, da sdraiati, eccentrica a una gamba)';
	@override String get goodMorningLeverSeated => 'Good morning (macchina a leva, da seduti)';
	@override String get cleanPower => 'Girata (power)';
	@override String get supineStrapAssistedHamstringStretch => 'Allungamento degli ischiocrurali da supini con cinghia';
	@override String get runnerSHamstringStretch => 'Allungamento degli ischiocrurali in posizione da corridore';
	@override String get seatedWideLegForwardFoldSequence => 'Sequenza di flessioni da seduti a gambe divaricate';
	@override String get singleLegSlidingCurl => 'Flessioni di una gamba con scivolamento del tallone';
	@override String get goodMorningSmithBentKnee => 'Good morning (Smith machine, ginocchia piegate)';
	@override String get strapAssistedHamstringAndCalfStretch => 'Allungamento di ischiocrurali e polpacci con cinghia';
	@override String get legCurlStandingBodyweight => 'Flessioni delle gambe (in piedi)';
	@override String get lungeStretchWithThoracicRotation => 'Allungamento in affondo con rotazione toracica';
}

// Path: library.shoulders.exercises
class Translations$library$shoulders$exercises$it implements Translations$library$shoulders$exercises$en {
	Translations$library$shoulders$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get standingCableReverseFly => 'Croci inverse ai cavi in piedi';
	@override String get cableFrontRaise => 'Alzate frontali al cavo';
	@override String get dumbbellShrugs => 'Scrollate con manubri';
	@override String get facePull => 'Face pull al cavo';
	@override String get shoulderPressMachine => 'Shoulder press (macchina)';
	@override String get latRaisesInclinedBench => 'Alzate laterali (panca inclinata)';
	@override String get latRaisesCable => 'Alzate laterali ai cavi';
	@override String get latRaisesDualCable => 'Alzate laterali ai cavi (entrambe le braccia)';
	@override String get reverseFlysInclinedBench => 'Croci inverse (panca inclinata)';
	@override String get arnoldPress => 'Arnold press';
	@override String get frontDumbbellRaise => 'Alzate frontali con manubri';
	@override String get uprightRow => 'Tirate al mento';
	@override String get pikePushUps => 'Pike push-up';
	@override String get handstandPushUps => 'Flessioni in verticale';
	@override String get bentOverLateralRaises => 'Croci inverse al cavo basso con busto flesso';
	@override String get shoulderPress => 'Shoulder press con manubri';
	@override String get latRaisesDumbbells => 'Alzate laterali (manubri)';
	@override String get deltoidMachine => 'Deltoid machine';
	@override String get shrugsBarbell => 'Scrollate con bilanciere davanti';
	@override String get militaryPressSmithMachine => 'Lento avanti al Multipower';
	@override String get reverseButterfly => 'Croci inverse alla macchina';
	@override String get militaryPressBarbell => 'Lento avanti con bilanciere';
	@override String get frontLateralRaiseBand => 'Alzate frontali e laterali (elastico)';
	@override String get frontRaiseBand => 'Alzate frontali (elastico)';
	@override String get reverseFlyBand => 'Croci inverse (elastico)';
	@override String get shoulderPressBand => 'Distensioni sopra la testa (elastico)';
	@override String get shrugBand => 'Scrollate delle spalle (elastico)';
	@override String get rearDeltRowBandStanding => 'Rematore per i deltoidi posteriori (elastico, in piedi)';
	@override String get overheadPressBandTwisting => 'Distensioni sopra la testa (elastico, con torsione)';
	@override String get yRaiseBand => 'Alzate a Y (elastico)';
	@override String get frontRaiseBarbell => 'Alzate frontali (bilanciere)';
	@override String get frontRaiseAndPulloverBarbell => 'Alzate frontali e pullover (bilanciere)';
	@override String get shoulderPressBarbellIncline => 'Distensioni sopra la testa (bilanciere, su panca inclinata)';
	@override String get snatchBarbellOneArm => 'Strappo (bilanciere, a un braccio)';
	@override String get rearDeltRaiseBarbell => 'Alzate per i deltoidi posteriori (bilanciere)';
	@override String get rearDeltRowBarbell => 'Rematore per i deltoidi posteriori (bilanciere)';
	@override String get militaryPressBarbellSeatedBehindHead => 'Military press (bilanciere, da seduti, dietro la testa)';
	@override String get bradfordPressBarbellSeated => 'Bradford press (bilanciere, da seduti)';
	@override String get barbellSkiStyleHighPull => 'Tirata alta con bilanciere e piccolo salto';
	@override String get bradfordPressBarbellStanding => 'Bradford press (bilanciere, in piedi)';
	@override String get militaryPressBarbellStandingCloseGrip => 'Military press (bilanciere, in piedi, presa stretta)';
	@override String get frontRaiseBarbellStandingOverHead => 'Alzate frontali (bilanciere, in piedi, oltre la testa)';
	@override String get militaryPressBarbellStandingWide => 'Military press (bilanciere, in piedi, ampio)';
	@override String get thrusterBarbell => 'Thruster (bilanciere)';
	@override String get uprightRowBarbellWideGrip => 'Tirate al mento (bilanciere, presa larga)';
	@override String get battlingRopes => 'Onde con le corde';
	@override String get shoulderPressCableAlternate => 'Distensioni sopra la testa (cavo, alternato)';
	@override String get rearDeltRowCableKneelingRope => 'Rematore per i deltoidi posteriori (cavo, in ginocchio, corda)';
	@override String get reverseFlyCableOneArmBentOver => 'Croci inverse (cavo, a un braccio, busto inclinato)';
	@override String get rearDeltRowCableStirrups => 'Rematore per i deltoidi posteriori (cavo, maniglie)';
	@override String get rearDeltRowCableRope => 'Rematore per i deltoidi posteriori (cavo, corda)';
	@override String get rearLateralRaiseCableSeated => 'Alzate per i deltoidi posteriori (cavo, da seduti)';
	@override String get shoulderInternalRotationCableSeated => 'Intrarotazioni della spalla (cavo, da seduti)';
	@override String get shoulderPressCable => 'Distensioni sopra la testa (cavo)';
	@override String get shrugCable => 'Scrollate delle spalle (cavo)';
	@override String get rearDeltRowCableStandingRope => 'Rematore per i deltoidi posteriori (cavo, in piedi, corda)';
	@override String get shoulderExternalRotationCableStanding => 'Extrarotazioni della spalla (cavo, in piedi)';
	@override String get reverseFlyCableSupine => 'Croci inverse (cavo, in posizione supina)';
	@override String get uprightRowCable => 'Tirate al mento (cavo)';
	@override String get pressDumbbellAlternateSide => 'Distensioni (manubri, alternato, laterale)';
	@override String get cubanPressDumbbell => 'Cuban press (manubri)';
	@override String get shrugDumbbellDecline => 'Scrollate delle spalle (manubri, su panca declinata)';
	@override String get lateralRaiseDumbbellFullCan => 'Alzate laterali (manubri, pollici verso l’alto)';
	@override String get shoulderPressDumbbellIncline => 'Distensioni sopra la testa (manubri, su panca inclinata)';
	@override String get shrugDumbbellIncline => 'Scrollate delle spalle (manubri, su panca inclinata)';
	@override String get tRaiseDumbbellIncline => 'Alzate a T (manubri, su panca inclinata)';
	@override String get lateralToFrontRaiseDumbbell => 'Alzate laterali e frontali (manubri)';
	@override String get externalShoulderRotationDumbbellLying => 'Extrarotazioni della spalla (manubri, da sdraiati)';
	@override String get rearDeltRaiseDumbbellLyingFloor => 'Alzate per i deltoidi posteriori (manubri, da sdraiati, a terra)';
	@override String get rearDeltRaiseDumbbellLyingOneArm => 'Alzate per i deltoidi posteriori (manubri, da sdraiati, a un braccio)';
	@override String get reverseFlyDumbbellLyingOneArm => 'Croci inverse (manubri, da sdraiati, a un braccio)';
	@override String get rearDeltRowDumbbellLying => 'Rematore per i deltoidi posteriori (manubri, da sdraiati)';
	@override String get reverseFlyDumbbellLying => 'Croci inverse (manubri, da sdraiati)';
	@override String get lateralRaiseDumbbellOneArm => 'Alzate laterali (manubri, a un braccio)';
	@override String get lateralRaiseDumbbellOneArmSupport => 'Alzate laterali (manubri, a un braccio, con appoggio)';
	@override String get reverseFlyDumbbellOneArmSupport => 'Croci inverse (manubri, a un braccio, con appoggio)';
	@override String get shoulderPressDumbbellOneArm => 'Distensioni sopra la testa (manubri, a un braccio)';
	@override String get uprightRowDumbbellOneArm => 'Tirate al mento (manubri, a un braccio)';
	@override String get pushPressDumbbell => 'Push press (manubri)';
	@override String get reverseFlyDumbbellBentOver => 'Croci inverse (manubri, busto inclinato)';
	@override String get rearDeltRowDumbbell => 'Rematore per i deltoidi posteriori (manubri)';
	@override String get rearLateralRaiseDumbbellSupportHead => 'Alzate per i deltoidi posteriori (manubri, testa appoggiata)';
	@override String get reverseFlyDumbbellRotation => 'Croci inverse (manubri, con rotazione)';
	@override String get scottPressDumbbell => 'Scott press (manubri)';
	@override String get frontRaiseDumbbellSeatedAlternate => 'Alzate frontali (manubri, da seduti, alternato)';
	@override String get shoulderPressDumbbellSeatedAlternate => 'Distensioni sopra la testa (manubri, da seduti, alternato)';
	@override String get lateralRaiseDumbbellSeatedBentArm => 'Alzate laterali (manubri, da seduti, braccia flesse)';
	@override String get bicepsCurlToShoulderPressDumbbellSeated => 'Curl e distensioni sopra la testa (manubri, da seduti)';
	@override String get frontRaiseDumbbellSeated => 'Alzate frontali (manubri, da seduti)';
	@override String get lateralRaiseDumbbellSeated => 'Alzate laterali (manubri, da seduti)';
	@override String get shoulderPressDumbbellSeatedNeutralGrip => 'Distensioni sopra la testa (manubri, da seduti, presa neutra)';
	@override String get lateralRaiseDumbbellSideLyingOneArm => 'Alzate laterali (manubri, sdraiati sul fianco, a un braccio)';
	@override String get reverseFlyDumbbellSidePlank => 'Croci inverse (manubri, in plank laterale)';
	@override String get singleArmOverheadDumbbellCarry => 'Camminata con manubrio sopra la testa a un braccio';
	@override String get overheadPressDumbbellStandingAlternate => 'Distensioni sopra la testa (manubri, in piedi, alternato)';
	@override String get lateralRaiseDumbbellStandingAlternate => 'Alzate laterali (manubri, in piedi, alternato)';
	@override String get standingDumbbellArmCircles => 'Circonduzioni delle braccia in piedi con manubri';
	@override String get frontRaiseDumbbellStandingAboveHead => 'Alzate frontali (manubri, in piedi, oltre la testa)';
	@override String get pressDumbbellStandingOneArmNeutralGrip => 'Distensioni (manubri, in piedi, a un braccio, presa neutra)';
	@override String get overheadPressDumbbellStanding => 'Distensioni sopra la testa (manubri, in piedi)';
	@override String get pressDumbbellStandingNeutralGrip => 'Distensioni (manubri, in piedi, presa neutra)';
	@override String get uprightRowDumbbell => 'Tirate al mento (manubri)';
	@override String get shoulderExternalRotationDumbbellUpright => 'Extrarotazioni della spalla (manubri, busto eretto)';
	@override String get wPressDumbbell => 'Distensioni a W (manubri)';
	@override String get frontRaiseDumbbellSeatedAlternateExerciseBall => 'Alzate frontali (manubri, da seduti, alternato, fitball)';
	@override String get shoulderPressEzBarbell => 'Distensioni sopra la testa (bilanciere EZ)';
	@override String get frogStand => 'Equilibrio a rana sulle mani';
	@override String get fullMalteseHold => 'Tenuta Maltese completa';
	@override String get fullPlancheHold => 'Tenuta planche completa';
	@override String get pushUpFullPlanche => 'Piegamenti sulle braccia (completo, in planche)';
	@override String get handstand => 'Verticale sulle mani';
	@override String get pressKettlebellAlternate => 'Distensioni (kettlebell, alternato)';
	@override String get arnoldPressKettlebell => 'Arnold press (kettlebell)';
	@override String get jerkKettlebellDouble => 'Spinta in slancio (kettlebell, con due kettlebell)';
	@override String get pushPressKettlebellDouble => 'Push press (kettlebell, con due kettlebell)';
	@override String get snatchKettlebellDouble => 'Strappo (kettlebell, con due kettlebell)';
	@override String get cleanAndJerkKettlebellOneArm => 'Slancio (kettlebell, a un braccio)';
	@override String get jerkKettlebellOneArm => 'Spinta in slancio (kettlebell, a un braccio)';
	@override String get militaryPressKettlebellOneArmToSide => 'Military press (kettlebell, a un braccio, verso il lato)';
	@override String get pushPressKettlebellOneArm => 'Push press (kettlebell, a un braccio)';
	@override String get snatchKettlebellOneArm => 'Strappo (kettlebell, a un braccio)';
	@override String get cleanAndPressKettlebellOneArm => 'Girata e distensione (kettlebell, a un braccio)';
	@override String get pressKettlebellSeated => 'Distensioni (kettlebell, da seduti)';
	@override String get militaryPressKettlebellSeatedTwoArm => 'Military press (kettlebell, da seduti, a due braccia)';
	@override String get pressKettlebellSeesaw => 'Distensioni (kettlebell, a bilanciere alternato)';
	@override String get sumoHighPullKettlebell => 'Tirate alte sumo (kettlebell)';
	@override String get thrusterKettlebell => 'Thruster (kettlebell)';
	@override String get cleanKettlebellTwoArm => 'Girata (kettlebell, a due braccia)';
	@override String get militaryPressKettlebellTwoArm => 'Military press (kettlebell, a due braccia)';
	@override String get lateralRaiseLandmine => 'Alzate laterali (landmine)';
	@override String get plancheLean => 'Planche (con sbilanciamento in avanti)';
	@override String get boxingLeftHook => 'Gancio sinistro di pugilato';
	@override String get shrugLeverGripless => 'Scrollate delle spalle (macchina a leva, senza presa delle mani)';
	@override String get shoulderPressLeverOneArm => 'Distensioni sopra la testa (macchina a leva, a un braccio)';
	@override String get reverseFlyLeverSeatedNeutralGrip => 'Croci inverse (macchina a leva, da seduti, presa neutra)';
	@override String get shrugLever => 'Scrollate delle spalle (macchina a leva)';
	@override String get rearDeltoidStretch => 'Allungamento dei deltoidi posteriori';
	@override String get shoulderPressResistanceBandSeated => 'Distensioni sopra la testa (elastico, da seduti)';
	@override String get scapularDips => 'Dip scapolari';
	@override String get scapularPullUp => 'Trazioni scapolari';
	@override String get shrugSmithBack => 'Scrollate delle spalle (Smith machine, posteriore)';
	@override String get pressSmithBehindNeck => 'Distensioni (Smith machine, dietro la nuca)';
	@override String get rearDeltRowSmith => 'Rematore per i deltoidi posteriori (Smith machine)';
	@override String get shoulderPressSmithSeated => 'Distensioni sopra la testa (Smith machine, da seduti)';
	@override String get shoulderPressSmith => 'Distensioni sopra la testa (Smith machine)';
	@override String get shrugSmith => 'Scrollate delle spalle (Smith machine)';
	@override String get militaryPressSmithStandingBehindHead => 'Military press (Smith machine, in piedi, dietro la testa)';
	@override String get uprightRowSmith => 'Tirate al mento (Smith machine)';
	@override String get pressStandingBehindNeck => 'Distensioni (in piedi, dietro la nuca)';
	@override String get straddleMalteseHold => 'Tenuta Maltese a gambe divaricate';
	@override String get straddlePlancheHold => 'Tenuta planche a gambe divaricate';
	@override String get frontRaiseWeighted => 'Alzate frontali (con sovraccarico)';
	@override String get weightedKneelingStepAndSwing => 'Passo in ginocchio con oscillazione del carico';
}

// Path: library.back.exercises
class Translations$library$back$exercises$it implements Translations$library$back$exercises$en {
	Translations$library$back$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get chestSupportedDumbbellRow => 'Rematore con petto appoggiato su panca (manubri)';
	@override String get singleArmCableRow => 'Rematore a un braccio al cavo';
	@override String get ringRow => 'Rematore agli anelli';
	@override String get dumbbellPullover => 'Pullover con manubrio';
	@override String get machineAssistedPullUps => 'Trazioni assistite alla macchina';
	@override String get hyperExtensions => 'Iperestensioni';
	@override String get weightedHyperExtensions => 'Iperestensioni con peso';
	@override String get barbellRow => 'Rematore con bilanciere';
	@override String get triangleBarLatPulldowns => 'Lat machine (con triangolo)';
	@override String get underhandGripLatPulldowns => 'Lat machine (presa supina)';
	@override String get latPulldowns => 'Lat machine';
	@override String get cableSeatedRowTriangleBar => 'Rematore al cavo (con triangolo)';
	@override String get straightArmCablePushdown => 'Pulldown a braccia dritte';
	@override String get deadlift => 'Stacchi';
	@override String get pullUps => 'Trazioni alla sbarra (presa prona)';
	@override String get tBarRow => 'Rematore con bilanciere a T';
	@override String get rowMachine => 'Rematore alla macchina da seduto';
	@override String get latPulldownsNarrowGrip => 'Lat machine (presa stretta)';
	@override String get latPulldownsWideGrip => 'Lat machine (presa larga)';
	@override String get tBarRowWideProneGrip => 'Rematore alla T-bar machine (presa larga prona)';
	@override String get dumbbellRow => 'Rematore con manubrio';
	@override String get chinUps => 'Trazioni alla sbarra (presa supina)';
	@override String get pulldownCableAlternate => 'Pulldown (cavo, alternato)';
	@override String get pullUpArcher => 'Trazioni alla sbarra (arciere)';
	@override String get pullUpAssistedParallelCloseGrip => 'Trazioni alla sbarra (con assistenza, presa parallela, presa stretta)';
	@override String get chinUpAssistedStanding => 'Trazioni a presa supina (con assistenza, in piedi)';
	@override String get pullUpAssistedStanding => 'Trazioni alla sbarra (con assistenza, in piedi)';
	@override String get backExtensionExerciseBall => 'Estensioni della schiena (fitball)';
	@override String get backLever => 'Back lever';
	@override String get chestStretchWithArmsBehindTheBack => 'Allungamento del petto con braccia dietro la schiena';
	@override String get pullUpBandAssisted => 'Trazioni alla sbarra (elastico, con assistenza)';
	@override String get pulldownBandCloseGrip => 'Pulldown (elastico, presa stretta)';
	@override String get pulldownBandFixedBackCloseGrip => 'Pulldown (elastico, schiena stabilizzata, presa stretta)';
	@override String get pulldownBandFixedBackUnderhand => 'Pulldown (elastico, schiena stabilizzata, presa supina)';
	@override String get pulldownBandKneelingOneArm => 'Pulldown (elastico, in ginocchio, a un braccio)';
	@override String get rowBandOneArmStandingLow => 'Rematore (elastico, a un braccio, in piedi, basso)';
	@override String get rowBandOneArmTwistingSeated => 'Rematore (elastico, a un braccio, con torsione, da seduti)';
	@override String get pulldownBandUnderhand => 'Pulldown (elastico, presa supina)';
	@override String get pulloverBarbellBentArm => 'Pullover (bilanciere, braccia flesse)';
	@override String get pulloverBarbellDeclineBentArm => 'Pullover (bilanciere, su panca declinata, braccia flesse)';
	@override String get pulloverBarbellDeclineWideGrip => 'Pullover (bilanciere, su panca declinata, presa larga)';
	@override String get rowBarbellIncline => 'Rematore (bilanciere, su panca inclinata)';
	@override String get bentOverRowBarbellOneArm => 'Rematore a busto inclinato (bilanciere, a un braccio)';
	@override String get pendlayRowBarbell => 'Rematore Pendlay (bilanciere)';
	@override String get pulloverBarbell => 'Pullover (bilanciere)';
	@override String get pulloverToPressBarbell => 'Pullover e distensione (bilanciere)';
	@override String get bentOverRowBarbellReverseGrip => 'Rematore a busto inclinato (bilanciere, presa supina)';
	@override String get benchRowBarbellReverseGripIncline => 'Rematore su panca (bilanciere, presa supina, su panca inclinata)';
	@override String get benchSupportedPullUp => 'Trazioni con appoggio sulla panca';
	@override String get rowBodyweightSquatting => 'Rematore (corpo libero, in accosciata)';
	@override String get rowBodyweightSquattingTowel => 'Rematore (corpo libero, in accosciata, asciugamano)';
	@override String get rowBodyweightStandingCloseGripOneArm => 'Rematore (corpo libero, in piedi, presa stretta, a un braccio)';
	@override String get rowBodyweightStandingCloseGrip => 'Rematore (corpo libero, in piedi, presa stretta)';
	@override String get rowBodyweightStandingOneArm => 'Rematore (corpo libero, in piedi, a un braccio)';
	@override String get rowBodyweightStandingOneArmTowel => 'Rematore (corpo libero, in piedi, a un braccio, asciugamano)';
	@override String get rowBodyweightStanding => 'Rematore (corpo libero, in piedi)';
	@override String get rowBodyweightStandingTowel => 'Rematore (corpo libero, in piedi, asciugamano)';
	@override String get latPulldownCableCrossover => 'Lat machine (cavo, incrociato)';
	@override String get rowCableDeclineSeatedWideGrip => 'Rematore (cavo, su panca declinata, da seduti, presa larga)';
	@override String get rowCableFloorSeatedWideGrip => 'Rematore (cavo, a terra, da seduti, presa larga)';
	@override String get rowCableHighKneeling => 'Rematore (cavo, alto, in ginocchio)';
	@override String get benchRowCableIncline => 'Rematore su panca (cavo, su panca inclinata)';
	@override String get latPulldownCableRope => 'Lat machine (cavo, corda)';
	@override String get rowCableSeated => 'Rematore (cavo, da seduti)';
	@override String get pulloverCableLyingRope => 'Pullover (cavo, da sdraiati, corda)';
	@override String get pulldownCableOneArm => 'Pulldown (cavo, a un braccio)';
	@override String get rowCableOneArmStraightBackHighKneeling => 'Rematore (cavo, a un braccio, schiena dritta, alto, in ginocchio)';
	@override String get rowCablePalmRotational => 'Rematore (cavo, con rotazione della presa)';
	@override String get latPulldownWithCurvedBar => 'Lat machine con barra sagomata';
	@override String get pulldownCableRear => 'Pulldown (cavo, posteriore)';
	@override String get rowCableReverseGripStraightBackSeatedHigh => 'Rematore (cavo, presa supina, schiena dritta, da seduti, alto)';
	@override String get rowCableRopeCrossoverSeated => 'Rematore (cavo, corda, incrociato, da seduti)';
	@override String get rowCableRopeElevatedSeated => 'Rematore (cavo, corda, rialzato, da seduti)';
	@override String get benchRowCableRopeExtensionIncline => 'Rematore su panca (cavo, corda, con estensione, su panca inclinata)';
	@override String get rowCableRopeSeated => 'Rematore (cavo, corda, da seduti)';
	@override String get rowCableSeatedOneArmAlternate => 'Rematore (cavo, da seduti, a un braccio, alternato)';
	@override String get rowCableSeatedWideGrip => 'Rematore (cavo, da seduti, presa larga)';
	@override String get squatRowCableRope => 'Squat e rematore (cavo, corda)';
	@override String get rowCableStandingVBar => 'Rematore (cavo, in piedi, barra a V)';
	@override String get twistRowCableStandingVBar => 'Rematore con torsione (cavo, in piedi, barra a V)';
	@override String get cableKayakRow => 'Rematore al cavo con movimento da kayak';
	@override String get twistRowCableOneArm => 'Rematore con torsione (cavo, a un braccio)';
	@override String get rowCableUpper => 'Rematore (cavo, alto)';
	@override String get pulldownCableWideGripRearBehindNeck => 'Pulldown (cavo, presa larga, posteriore, dietro la nuca)';
	@override String get rowCamberedBarLying => 'Rematore (bilanciere curvo, da sdraiati)';
	@override String get closeNeutralGripPullUp => 'Trazioni a presa neutra stretta';
	@override String get bentOverRowDumbbell => 'Rematore a busto inclinato (manubri)';
	@override String get yRaiseDumbbellIncline => 'Alzate a Y (manubri, su panca inclinata)';
	@override String get bentOverRowDumbbellPalmRotational => 'Rematore a busto inclinato (manubri, con rotazione della presa)';
	@override String get rowDumbbellReverseGripInclineBenchOneArm => 'Rematore (manubri, presa supina, su panca inclinata, a un braccio)';
	@override String get rowDumbbellReverseGripInclineBenchTwoArm => 'Rematore (manubri, presa supina, su panca inclinata, a due braccia)';
	@override String get rowDumbbellReverseGrip => 'Rematore (manubri, presa supina)';
	@override String get bodyweightHipHinge => 'Flessioni del busto con cerniera d’anca a corpo libero';
	@override String get backExtensionExerciseBallStraightArm => 'Estensioni della schiena (fitball, braccia tese)';
	@override String get backExtensionExerciseBallHandsBehindHead => 'Estensioni della schiena (fitball, mani dietro la testa)';
	@override String get backExtensionExerciseBallKneeOffGround => 'Estensioni della schiena (fitball, ginocchia sollevate)';
	@override String get backExtensionExerciseBallRotation => 'Estensioni della schiena (fitball, con rotazione)';
	@override String get seatedBackStretchHuggingABall => 'Allungamento della schiena da seduti abbracciando la fitball';
	@override String get latStretchExerciseBall => 'Allungamento dei dorsali (fitball)';
	@override String get pyramidPositionBackStretchOnBall => 'Allungamento della schiena a piramide sulla fitball';
	@override String get latStretchExerciseBallLyingSide => 'Allungamento dei dorsali (fitball, da sdraiati, laterale)';
	@override String get legRaiseExerciseBallProne => 'Sollevamenti delle gambe (fitball, in posizione prona)';
	@override String get pulloverEzBarLyingBentArm => 'Pullover (bilanciere EZ, da sdraiati, braccia flesse)';
	@override String get bentOverRowEzBarReverseGrip => 'Rematore a busto inclinato (bilanciere EZ, presa supina)';
	@override String get frontLever => 'Front lever';
	@override String get frontLeverReps => 'Front lever (dinamico)';
	@override String get sternumToBarChinUp => 'Trazioni con lo sterno verso la sbarra';
	@override String get invertedRow => 'Rematore inverso';
	@override String get invertedRowBentKnee => 'Rematore inverso (ginocchia piegate)';
	@override String get invertedRowBench => 'Rematore inverso (su panca)';
	@override String get renegadeRowKettlebellAlternate => 'Rematore in plank (kettlebell, alternato)';
	@override String get rowKettlebellAlternate => 'Rematore (kettlebell, alternato)';
	@override String get rowKettlebellOneArm => 'Rematore (kettlebell, a un braccio)';
	@override String get rowKettlebellTwoArm => 'Rematore (kettlebell, a due braccia)';
	@override String get muscleUpKipping => 'Muscle-up (con slancio)';
	@override String get latStretchKneeling => 'Allungamento dei dorsali (in ginocchio)';
	@override String get pullUpL => 'Trazioni alla sbarra (gambe a L)';
	@override String get rowLeverAlternateNarrowGripSeated => 'Rematore (macchina a leva, alternato, presa stretta, da seduti)';
	@override String get chinUpLeverAssisted => 'Trazioni a presa supina (macchina a leva, con assistenza)';
	@override String get backExtensionLever => 'Estensioni della schiena (macchina a leva)';
	@override String get bentOverRowLever => 'Rematore a busto inclinato (macchina a leva)';
	@override String get bentOverRowLeverVBar => 'Rematore a busto inclinato (macchina a leva, barra a V)';
	@override String get pulldownLeverFront => 'Pulldown (macchina a leva, frontale)';
	@override String get rowLeverHigh => 'Rematore (macchina a leva, alto)';
	@override String get bentOverRowLeverOneArm => 'Rematore a busto inclinato (macchina a leva, a un braccio)';
	@override String get rowLeverOneArmLateralHigh => 'Rematore (macchina a leva, a un braccio, laterale, alto)';
	@override String get pulldownLeverOneArmLateralWide => 'Pulldown (macchina a leva, a un braccio, laterale, ampio)';
	@override String get pulloverLever => 'Pullover (macchina a leva)';
	@override String get latPulldownLeverReverseGrip => 'Lat machine (macchina a leva, presa supina)';
	@override String get rowLeverReverseGripVertical => 'Rematore (macchina a leva, presa supina, verticale)';
	@override String get rowLeverReverseTBar => 'Rematore (macchina a leva, inverso, barra a T)';
	@override String get rowLeverTBar => 'Rematore (macchina a leva, barra a T)';
	@override String get rowLeverTBarReverseGrip => 'Rematore (macchina a leva, barra a T, presa supina)';
	@override String get rowLeverOneArm => 'Rematore (macchina a leva, a un braccio)';
	@override String get standingAnchoredRopeRow => 'Rematore in piedi con corda ancorata';
	@override String get seatedSpinalFlexion => 'Flessioni della colonna da seduti';
	@override String get medicineBallCatchAndOverheadToss => 'Presa e lancio sopra la testa della palla medica';
	@override String get overheadMedicineBallSlam => 'Schiacciata a terra della palla medica da sopra la testa';
	@override String get chinUpMixedGrip => 'Trazioni a presa supina (presa mista)';
	@override String get muscleUp => 'Muscle-up';
	@override String get muscleUpVerticalBar => 'Muscle-up (verticale, barra)';
	@override String get neckStretchSide => 'Allungamento del collo (laterale)';
	@override String get singleArmWallLatStretch => 'Allungamento del dorsale a un braccio alla parete';
	@override String get chinUpOneArm => 'Trazioni a presa supina (a un braccio)';
	@override String get rowOneArmTowel => 'Rematore (a un braccio, asciugamano)';
	@override String get pullUpNeutralGrip => 'Trazioni alla sbarra (presa neutra)';
	@override String get pullUpRear => 'Trazioni alla sbarra (posteriore)';
	@override String get rowResistanceBandSeatedStraightBack => 'Rematore (elastico, da seduti, schiena dritta)';
	@override String get pulldownLeverReverseGrip => 'Pulldown (macchina a leva, presa supina)';
	@override String get alternatingFrontAndBackPullUp => 'Trazioni alternate davanti e dietro la testa';
	@override String get backStretchRoller => 'Allungamento della schiena (rullo)';
	@override String get latStretchRollerSide => 'Allungamento dei dorsali (rullo, laterale)';
	@override String get ropeClimbing => 'Salita alla corda';
	@override String get lowerBackStretchSeated => 'Allungamento lombare (da seduti)';
	@override String get latStretchSideLyingFloor => 'Allungamento dei dorsali (sdraiati sul fianco, a terra)';
	@override String get neckStretchSidePush => 'Allungamento del collo (laterale, con spinta)';
	@override String get sideToSideChinUp => 'Trazioni supine con spostamento laterale';
	@override String get skinTheCatRotation => 'Rotazione completa in sospensione alla sbarra';
	@override String get bentOverRowSmith => 'Rematore a busto inclinato (Smith machine)';
	@override String get rowSmithNarrow => 'Rematore (Smith machine, stretto)';
	@override String get rowSmithOneArm => 'Rematore (Smith machine, a un braccio)';
	@override String get bentOverRowSmithReverseGrip => 'Rematore a busto inclinato (Smith machine, presa supina)';
	@override String get proneSphinxStretch => 'Allungamento in posizione della sfinge';
	@override String get spineStretch => 'Allungamento della colonna';
	@override String get standingArcherPull => 'Tirata dell’arciere in piedi';
	@override String get latStretchStandingLateral => 'Allungamento dei dorsali (in piedi, laterale)';
	@override String get pelvicTiltStanding => 'Retroversioni del bacino (in piedi)';
	@override String get pulldownCableNeutralGrip => 'Pulldown (cavo, presa neutra)';
	@override String get forwardFoldReachingBothToes => 'Flessione in avanti verso entrambe le punte dei piedi';
	@override String get upperBackStretch => 'Allungamento della parte alta della schiena';
	@override String get upwardFacingDogStretch => 'Allungamento nella posizione del cane a testa in su';
	@override String get chinUpWeightedCloseGripDipCage => 'Trazioni a presa supina (con sovraccarico, presa stretta, stazione dip)';
	@override String get hyperextensionWeightedStabilityBall => 'Iperestensioni (con sovraccarico, fitball)';
	@override String get muscleUpWeighted => 'Muscle-up (con sovraccarico)';
	@override String get muscleUpWeightedBar => 'Muscle-up (con sovraccarico, barra)';
	@override String get pullUpWeightedOneArm => 'Trazioni alla sbarra (con sovraccarico, a un braccio)';
	@override String get pullUpWeighted => 'Trazioni alla sbarra (con sovraccarico)';
	@override String get pullUpWideGrip => 'Trazioni alla sbarra (presa larga)';
	@override String get pullUpWideGripRear => 'Trazioni alla sbarra (presa larga, posteriore)';
}

// Path: library.back.exercise
class Translations$library$back$exercise$it implements Translations$library$back$exercise$en {
	Translations$library$back$exercise$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get dualLowRowMachine => 'Dual low row machine';
	@override String get dualHighRowMachine => 'Dual high row machine';
}

// Path: library.triceps.exercises
class Translations$library$triceps$exercises$it implements Translations$library$triceps$exercises$en {
	Translations$library$triceps$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get barTricepsPushdown => 'Pushdown dei tricipiti con barra';
	@override String get singleArmTricepsPushdown => 'Pushdown dei tricipiti a un braccio';
	@override String get machineAssistedDips => 'Dip assistiti alla macchina';
	@override String get dips => 'Dip';
	@override String get overheadRopeTricepExtension => 'Estensioni dei tricipiti sopra la testa con corda al cavo';
	@override String get tricepsRopePushdown => 'Pushdown dei tricipiti con corda';
	@override String get tricepKickbacks => 'Kickback per i tricipiti';
	@override String get skullCrushers => 'French press su panca (skull crusher)';
	@override String get benchDips => 'Dip alla panca';
	@override String get diamondPushUps => 'Flessioni a diamante';
	@override String get tricepsMachine => 'Triceps machine';
	@override String get overheadTricepExtension => 'Estensioni dei tricipiti sopra la testa con manubri';
	@override String get tricepsExtensionAssistedStandingTowel => 'Estensioni per i tricipiti (con assistenza, in piedi, asciugamano)';
	@override String get pushUpBandCloseGrip => 'Piegamenti sulle braccia (elastico, presa stretta)';
	@override String get tricepsExtensionBandSide => 'Estensioni per i tricipiti (elastico, laterale)';
	@override String get benchPressBarbellCloseGrip => 'Distensioni su panca (bilanciere, presa stretta)';
	@override String get declineCloseGripPressIntoSkullCrusher => 'Distensioni a presa stretta e skull crusher su panca declinata';
	@override String get benchPressBarbellInclineCloseGrip => 'Distensioni su panca (bilanciere, su panca inclinata, presa stretta)';
	@override String get pressBarbellInclineReverseGrip => 'Distensioni (bilanciere, su panca inclinata, presa supina)';
	@override String get tricepsExtensionBarbellLyingBackOfHead => 'Estensioni per i tricipiti (bilanciere, da sdraiati, dietro la testa)';
	@override String get floorPressBarbellOneArm => 'Distensioni da terra (bilanciere, a un braccio)';
	@override String get pinPressesBarbell => 'Distensioni dai fermi (bilanciere)';
	@override String get benchPressBarbellReverseCloseGrip => 'Distensioni su panca (bilanciere, inverso, presa stretta)';
	@override String get skullcrusherBarbellReverseGrip => 'Skull crusher (bilanciere, presa supina)';
	@override String get tricepsExtensionBarbellSeatedCloseGripBehindNeck => 'Estensioni per i tricipiti (bilanciere, da seduti, presa stretta, dietro la nuca)';
	@override String get tricepsExtensionBarbellSeatedOverhead => 'Estensioni per i tricipiti (bilanciere, da seduti, sopra la testa)';
	@override String get tricepsExtensionBarbellStandingOverhead => 'Estensioni per i tricipiti (bilanciere, in piedi, sopra la testa)';
	@override String get tricepsExtensionBodyweightKneeling => 'Estensioni per i tricipiti (corpo libero, in ginocchio)';
	@override String get tricepsExtensionCableAlternate => 'Estensioni per i tricipiti (cavo, alternato)';
	@override String get extensionCableConcentrationKnee => 'Estensioni per i tricipiti (cavo, concentrato, sulle ginocchia)';
	@override String get tricepsExtensionCableHighPulleyOverhead => 'Estensioni per i tricipiti (cavo, carrucola alta, sopra la testa)';
	@override String get tricepsExtensionCableIncline => 'Estensioni per i tricipiti (cavo, su panca inclinata)';
	@override String get kickbackCable => 'Kickback per i tricipiti (cavo)';
	@override String get tricepsExtensionCableKneeling => 'Estensioni per i tricipiti (cavo, in ginocchio)';
	@override String get tricepsExtensionCableLying => 'Estensioni per i tricipiti (cavo, da sdraiati)';
	@override String get cableRearwardTricepsDrive => 'Spinta dei tricipiti all’indietro al cavo';
	@override String get tricepsPushdownCableReverseGripSzBarArmBlaster => 'Pushdown per i tricipiti (cavo, presa supina, barra EZ, arm blaster)';
	@override String get pushdownCableReverseGrip => 'Pushdown per i tricipiti (cavo, presa supina)';
	@override String get tricepsExtensionCableRopeIncline => 'Estensioni per i tricipiti (cavo, corda, su panca inclinata)';
	@override String get tricepsExtensionCableRopeLyingFloor => 'Estensioni per i tricipiti (cavo, corda, da sdraiati, a terra)';
	@override String get tricepsExtensionCableStandingOneArm => 'Estensioni per i tricipiti (cavo, in piedi, a un braccio)';
	@override String get tricepsExtensionCableStandingReverseGripOneArmOverhead => 'Estensioni per i tricipiti (cavo, in piedi, presa supina, a un braccio, sopra la testa)';
	@override String get tricepsPushdownCableVBar => 'Pushdown per i tricipiti (cavo, barra a V)';
	@override String get tricepsPushdownCableVBarArmBlaster => 'Pushdown per i tricipiti (cavo, barra a V, arm blaster)';
	@override String get tricepsKickbackCableTwoArm => 'Kickback per i tricipiti (cavo, a due braccia)';
	@override String get pushUpCloseGrip => 'Piegamenti sulle braccia (presa stretta)';
	@override String get pushUpCloseGripKnee => 'Piegamenti sulle braccia (presa stretta, sulle ginocchia)';
	@override String get pressDumbbellCloseGrip => 'Distensioni (manubri, presa stretta)';
	@override String get pressDumbbellDeclineOneArmNeutralGrip => 'Distensioni (manubri, su panca declinata, a un braccio, presa neutra)';
	@override String get tricepsExtensionDumbbellDecline => 'Estensioni per i tricipiti (manubri, su panca declinata)';
	@override String get forwardLungeTricepsExtensionDumbbell => 'Affondo avanti ed estensioni dei tricipiti (manubri)';
	@override String get pressDumbbellInclineNeutralGripExerciseBall => 'Distensioni (manubri, su panca inclinata, presa neutra, fitball)';
	@override String get pressDumbbellInclineOneArmNeutralGrip => 'Distensioni (manubri, su panca inclinata, a un braccio, presa neutra)';
	@override String get pressDumbbellInclineOneArmNeutralGripExerciseBall => 'Distensioni (manubri, su panca inclinata, a un braccio, presa neutra, fitball)';
	@override String get tricepsExtensionDumbbellIncline => 'Estensioni per i tricipiti (manubri, su panca inclinata)';
	@override String get tricepsExtensionDumbbellInclineTwoArm => 'Estensioni per i tricipiti (manubri, su panca inclinata, a due braccia)';
	@override String get kickbackDumbbellExerciseBall => 'Kickback per i tricipiti (manubri, fitball)';
	@override String get tricepsExtensionDumbbellLyingAcrossFace => 'Estensioni per i tricipiti (manubri, da sdraiati, davanti al viso)';
	@override String get extensionDumbbellLyingAlternate => 'Estensioni per i tricipiti (manubri, da sdraiati, alternato)';
	@override String get tricepsExtensionDumbbellLying => 'Estensioni per i tricipiti (manubri, da sdraiati)';
	@override String get tricepsExtensionDumbbellLyingOneArmPronated => 'Estensioni per i tricipiti (manubri, da sdraiati, a un braccio, presa prona)';
	@override String get tricepsExtensionDumbbellLyingOneArmSupinated => 'Estensioni per i tricipiti (manubri, da sdraiati, a un braccio, presa supina)';
	@override String get tricepsExtensionDumbbellLyingOneArm => 'Estensioni per i tricipiti (manubri, da sdraiati, a un braccio)';
	@override String get frenchPressDumbbellOneArmExerciseBall => 'French press (manubri, a un braccio, fitball)';
	@override String get pressDumbbellOneArmNeutralGripExerciseBall => 'Distensioni (manubri, a un braccio, presa neutra, fitball)';
	@override String get tricepsExtensionDumbbellOneArmBench => 'Estensioni per i tricipiti (manubri, a un braccio, su panca)';
	@override String get tricepsExtensionDumbbellPronateGrip => 'Estensioni per i tricipiti (manubri, presa prona)';
	@override String get extensionDumbbellSeatedBench => 'Estensioni per i tricipiti (manubri, da seduti, su panca)';
	@override String get kickbackDumbbellSeatedBentOverAlternate => 'Kickback per i tricipiti (manubri, da seduti, busto inclinato, alternato)';
	@override String get kickbackDumbbellSeated => 'Kickback per i tricipiti (manubri, da seduti)';
	@override String get kickbackDumbbellSeatedOneArm => 'Kickback per i tricipiti (manubri, da seduti, a un braccio)';
	@override String get tricepsExtensionDumbbellSeatedReverseGripOneArmOverhead => 'Estensioni per i tricipiti (manubri, da seduti, presa supina, a un braccio, sopra la testa)';
	@override String get tricepsKickbackDumbbellStandingAlternate => 'Kickback per i tricipiti (manubri, in piedi, alternato)';
	@override String get tricepsExtensionDumbbellStandingBentOverOneArm => 'Estensioni per i tricipiti (manubri, in piedi, busto inclinato, a un braccio)';
	@override String get kickbackDumbbellStanding => 'Kickback per i tricipiti (manubri, in piedi)';
	@override String get extensionDumbbellStandingOneArm => 'Estensioni per i tricipiti (manubri, in piedi, a un braccio)';
	@override String get tatePressDumbbell => 'Tate press (manubri)';
	@override String get tricepsKickbackDumbbellStorkStance => 'Kickback per i tricipiti (manubri, in equilibrio su una gamba)';
	@override String get elbowSupportedDips => 'Dip con appoggio sui gomiti';
	@override String get dipExerciseBall => 'Dip (fitball)';
	@override String get tricepsStretchExerciseBallSeated => 'Allungamento dei tricipiti (fitball, da seduti)';
	@override String get tricepsExtensionExerciseBallSupine => 'Estensioni per i tricipiti (fitball, in posizione supina)';
	@override String get frenchPressEzBarExerciseBall => 'French press (bilanciere EZ, fitball)';
	@override String get tricepsExtensionEzBarLyingCloseGripBehindHead => 'Estensioni per i tricipiti (bilanciere EZ, da sdraiati, presa stretta, dietro la testa)';
	@override String get frenchPressEzBarStanding => 'French press (bilanciere EZ, in piedi)';
	@override String get declineEZBarFacePress => 'Estensioni dei gomiti verso il viso con bilanciere EZ su panca declinata';
	@override String get tricepsExtensionEzBarbellDecline => 'Estensioni per i tricipiti (bilanciere EZ, su panca declinata)';
	@override String get tricepsExtensionEzBarbellIncline => 'Estensioni per i tricipiti (bilanciere EZ, su panca inclinata)';
	@override String get tricepsExtensionEzBarbellSeated => 'Estensioni per i tricipiti (bilanciere EZ, da seduti)';
	@override String get benchPressEzBarCloseGrip => 'Distensioni su panca (bilanciere EZ, presa stretta)';
	@override String get forearmTransitionDips => 'Dip con passaggio sugli avambracci';
	@override String get pushUpInclineCloseGrip => 'Piegamenti sulle braccia (su panca inclinata, presa stretta)';
	@override String get tricepsDipLeverOverhand => 'Dip per i tricipiti (macchina a leva, presa prona)';
	@override String get dipLeverSeated => 'Dip (macchina a leva, da seduti)';
	@override String get pushUpMedicineBallCloseGrip => 'Piegamenti sulle braccia (palla medica, presa stretta)';
	@override String get supineMedicineBallChestThrow => 'Lancio della palla medica dal petto da supini';
	@override String get tricepsExtensionOlympicBarbell => 'Estensioni per i tricipiti (bilanciere olimpico)';
	@override String get dipOneArm => 'Dip (a un braccio)';
	@override String get tricepsStretchOverhead => 'Allungamento dei tricipiti (sopra la testa)';
	@override String get pushUpCloseGripOffDumbbell => 'Piegamenti sulle braccia (presa stretta, su appoggio, manubri)';
	@override String get dipReverse => 'Dip (inverso)';
	@override String get dipRing => 'Dip (anelli)';
	@override String get benchPressSmithCloseGrip => 'Distensioni su panca (Smith machine, presa stretta)';
	@override String get benchPressSmithMachineDeclineCloseGrip => 'Distensioni su panca (Smith machine, su panca declinata, presa stretta)';
	@override String get tricepsExtensionSmithMachineIncline => 'Estensioni per i tricipiti (Smith machine, su panca inclinata)';
	@override String get stalderPressToHandstand => 'Salita in verticale in divaricata Stalder';
	@override String get dipThreeBench => 'Dip (tre appoggi, su panca)';
	@override String get tricepsDipFloor => 'Dip per i tricipiti (a terra)';
	@override String get dipWeightedBench => 'Dip (con sovraccarico, su panca)';
	@override String get dipWeightedThreeBench => 'Dip (con sovraccarico, tre appoggi, su panca)';
	@override String get tricepsDipWeighted => 'Dip per i tricipiti (con sovraccarico)';
	@override String get jmPressBarbell => 'JM press (bilanciere)';
	@override String get jmPressEzBarbell => 'JM press (bilanciere EZ)';
}

// Path: library.hips.exercises
class Translations$library$hips$exercises$it implements Translations$library$hips$exercises$en {
	Translations$library$hips$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get hipAdduction => 'Adduzioni dell’anca alla macchina';
	@override String get adductorStretchAssistedSideLying => 'Allungamento degli adduttori (con assistenza, sdraiati sul fianco)';
	@override String get hipAdductionCable => 'Adduzioni dell’anca (cavo)';
	@override String get hipAdductionSideLying => 'Adduzioni dell’anca (sdraiati sul fianco)';
	@override String get hipAdductionSidePlank => 'Adduzioni dell’anca (in plank laterale)';
}

// Path: library.forearms.exercises
class Translations$library$forearms$exercises$it implements Translations$library$forearms$exercises$en {
	Translations$library$forearms$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get wristCurlsBarbell => 'Curl dei polsi (bilanciere)';
	@override String get reverseWristCurlsBarbell => 'Estensioni dei polsi (bilanciere)';
	@override String get wristCurlsDumbbell => 'Curl dei polsi (manubri)';
	@override String get reverseWristCurlsDumbbell => 'Estensioni dei polsi (manubri)';
	@override String get wristRoller => 'Wrist roller';
	@override String get farmerWalk => 'Farmer walk';
	@override String get platePinch => 'Plate pinch';
	@override String get reverseCurls => 'Reverse curl (bilanciere)';
	@override String get reverseCurlsDumbbell => 'Reverse curl (manubri)';
	@override String get dumbbellSingleArmReverseCurl => 'Reverse curl a un braccio (manubrio)';
	@override String get singleArmCableReverseCurl => 'Reverse curl a un braccio al cavo';
	@override String get reverseWristCurlBand => 'Estensioni dei polsi (elastico)';
	@override String get wristCurlBand => 'Flessioni dei polsi (elastico)';
	@override String get wristCurlBarbellStandingBack => 'Flessioni dei polsi (bilanciere, in piedi, posteriore)';
	@override String get reverseWristCurlCable => 'Estensioni dei polsi (cavo)';
	@override String get wristCurlCableStandingBack => 'Flessioni dei polsi (cavo, in piedi, posteriore)';
	@override String get wristCurlCable => 'Flessioni dei polsi (cavo)';
	@override String get dumbbellFingerFlexion => 'Flessioni delle dita con manubrio';
	@override String get pronationDumbbellLying => 'Pronazione dell’avambraccio (manubri, da sdraiati)';
	@override String get pronationDumbbellLyingFloor => 'Pronazione dell’avambraccio (manubri, da sdraiati, a terra)';
	@override String get supinationDumbbellLying => 'Supinazione dell’avambraccio (manubri, da sdraiati)';
	@override String get supinationDumbbellLyingFloor => 'Supinazione dell’avambraccio (manubri, da sdraiati, a terra)';
	@override String get reverseWristCurlDumbbellOneArm => 'Estensioni dei polsi (manubri, a un braccio)';
	@override String get neutralWristCurlDumbbellOneArmSeated => 'Deviazioni radiali dei polsi (manubri, a un braccio, da seduti)';
	@override String get wristCurlDumbbellOneArm => 'Flessioni dei polsi (manubri, a un braccio)';
	@override String get benchSupportedDumbbellRadialDeviation => 'Deviazioni radiali del polso con manubri e appoggio su panca';
	@override String get neutralWristCurlDumbbellBenchOneArm => 'Deviazioni radiali dei polsi (manubri, su panca, a un braccio)';
	@override String get reverseWristCurlDumbbellBenchOneArm => 'Estensioni dei polsi (manubri, su panca, a un braccio)';
	@override String get wristCurlDumbbellBenchOneArm => 'Flessioni dei polsi (manubri, su panca, a un braccio)';
	@override String get seatedDumbbellRadialDeviation => 'Deviazioni radiali dei polsi con manubri da seduti';
	@override String get shoulderExternalRotationDumbbellSeatedOneArm => 'Extrarotazioni della spalla (manubri, da seduti, a un braccio)';
	@override String get fingerFlexionCurls => 'Flessioni delle dita';
	@override String get hangCleanKettlebellAlternate => 'Girata dalla sospensione (kettlebell, alternato)';
	@override String get machineHandGripSqueeze => 'Chiusure della presa alla macchina';
	@override String get wristStretchWithSidePull => 'Allungamento del polso con trazione laterale';
	@override String get wristCurlSmithSeated => 'Flessioni dei polsi (Smith machine, da seduti)';
	@override String get wristCurlSmithStandingBack => 'Flessioni dei polsi (Smith machine, in piedi, posteriore)';
	@override String get weightedHandGripSqueeze => 'Chiusure della presa con resistenza';
	@override String get wristCircles => 'Circonduzioni dei polsi';
}

// Path: library.obliques.exercises
class Translations$library$obliques$exercises$it implements Translations$library$obliques$exercises$en {
	Translations$library$obliques$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get sidewaysPlank => 'Plank laterale';
	@override String get sidewaysPlankReachThrough => 'Plank laterale con rotazione';
}

// Path: library.other.exercises
class Translations$library$other$exercises$it implements Translations$library$other$exercises$en {
	Translations$library$other$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get stretching => 'Stretching';
}

// Path: library.glutes.exercises
class Translations$library$glutes$exercises$it implements Translations$library$glutes$exercises$en {
	Translations$library$glutes$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get singleLegGluteBridge => 'Ponte per i glutei a una gamba';
	@override String get smithMachineHipThrust => 'Hip thrust al Multipower';
	@override String get bandHipAbduction => 'Abduzioni dell’anca con elastico';
	@override String get lateralBandWalk => 'Camminata laterale con elastico';
	@override String get quadrupedGluteKickback => 'Slanci posteriori in quadrupedia';
	@override String get kettlebellSwing => 'Kettlebell swing';
	@override String get cableGluteKickback => 'Slanci posteriori al cavo';
	@override String get machineGluteKickback => 'Slanci posteriori alla macchina';
	@override String get cableHipAbduction => 'Abduzioni dell’anca al cavo';
	@override String get gluteBridge => 'Ponte per i glutei';
	@override String get hipThrust => 'Hip thrust alla macchina';
	@override String get hipAbduction => 'Abduzioni dell’anca alla macchina';
	@override String get clamshells => 'Clamshell per i glutei';
	@override String get hipThrustBarbell => 'Hip thrust (bilanciere)';
	@override String get standingToeTouchCirclesArmsOpen => 'Circonduzioni del busto verso i piedi a braccia aperte';
	@override String get assistedSupineGluteStretch => 'Allungamento dei glutei da supini con assistenza';
	@override String get assistedGluteAndPiriformisStretch => 'Allungamento assistito di glutei e piriforme';
	@override String get hipExtensionBandBentOver => 'Estensioni dell’anca (elastico, busto inclinato)';
	@override String get gluteBridgeBand => 'Ponte per i glutei (elastico)';
	@override String get hipInternalRotationBandLying => 'Rotazioni interne dell’anca (elastico, da sdraiati)';
	@override String get pullThroughBand => 'Pull-through (elastico)';
	@override String get hipInternalRotationBandSeated => 'Rotazioni interne dell’anca (elastico, da seduti)';
	@override String get gluteBridgeBarbell => 'Ponte per i glutei (bilanciere)';
	@override String get gluteBridgeBarbellBench => 'Ponte per i glutei (bilanciere, su panca)';
	@override String get deadliftBarbellOneArmSide => 'Stacco da terra (bilanciere, a un braccio, laterale)';
	@override String get rackPullBarbell => 'Stacco dai supporti (bilanciere)';
	@override String get deadliftBarbellOneLeg => 'Stacco da terra (bilanciere, a una gamba)';
	@override String get deadliftBarbellSumo => 'Stacco da terra (bilanciere, sumo)';
	@override String get standingForwardFoldToToes => 'Flessione del busto verso i piedi';
	@override String get hipExtensionBench => 'Estensioni dell’anca (su panca)';
	@override String get twistBentKneeLying => 'Rotazioni del busto (ginocchia piegate, da sdraiati)';
	@override String get deadliftCable => 'Stacco da terra (cavo)';
	@override String get pullThroughCableRope => 'Pull-through (cavo, corda)';
	@override String get hipExtensionCableStanding => 'Estensioni dell’anca (cavo, in piedi)';
	@override String get cleanDumbbell => 'Girata (manubri)';
	@override String get deadliftDumbbell => 'Stacco da terra (manubri)';
	@override String get snatchDumbbellOneArm => 'Strappo (manubri, a un braccio)';
	@override String get deadliftDumbbellOneLegStepboxSupport => 'Stacco da terra (manubri, a una gamba, con appoggio sullo step)';
	@override String get pullThroughDumbbellSumo => 'Pull-through (manubri, sumo)';
	@override String get hipFlexorStretchExerciseBall => 'Allungamento dei flessori dell’anca (fitball)';
	@override String get proneSingleLegHipRotationOnBall => 'Rotazioni dell’anca a una gamba da proni sulla fitball';
	@override String get ballSupportedDiagonalKickAndLegCurl => 'Calcio diagonale e flessione della gamba sulla fitball';
	@override String get flutterKicks => 'Sforbiciate a gambe tese';
	@override String get gluteBridgeMarch => 'Ponte per i glutei (con marcia)';
	@override String get gluteBridgeTwoLegBench => 'Ponte per i glutei (a due gambe, su panca)';
	@override String get toeTouchCirclesWithHandsClasped => 'Circonduzioni verso i piedi con mani unite';
	@override String get toeTouchCirclesWithReversedHandClasp => 'Circonduzioni verso i piedi con mani intrecciate al contrario';
	@override String get supineKneesToChestStretch => 'Allungamento da supini con ginocchia al petto';
	@override String get supineCrossBodyRotationStretch => 'Allungamento da supini con torsione incrociata';
	@override String get deadliftLever => 'Stacco da terra (macchina a leva)';
	@override String get hipExtensionLever => 'Estensioni dell’anca (macchina a leva)';
	@override String get legPressLeverHorizontalOneLeg => 'Pressa per le gambe (macchina a leva, orizzontale, a una gamba)';
	@override String get reverseHyperextensionLever => 'Iperestensioni inverse (macchina a leva)';
	@override String get wallSitWithAlternatingKneeLifts => 'Seduta alla parete con sollevamenti alternati delle ginocchia';
	@override String get pelvicTiltIntoGluteBridge => 'Retroversione del bacino e ponte per i glutei';
	@override String get pushUpPikeToCobra => 'Piegamenti sulle braccia (da V rovesciata a cobra)';
	@override String get elevatedReverseBridge => 'Ponte inverso con piedi rialzati';
	@override String get hipThrustsResistanceBandKnee => 'Hip thrust (elastico, sulle ginocchia)';
	@override String get hipAbductionResistanceBandSeated => 'Abduzioni dell’anca (elastico, da seduti)';
	@override String get reverseHyperextensionStabilityBall => 'Iperestensioni inverse (fitball)';
	@override String get reverseHyperextensionFlatBench => 'Iperestensioni inverse (panca piana)';
	@override String get rockingFrogAdductorStretch => 'Allungamento a rana degli adduttori con oscillazione';
	@override String get latStretchRollerHip => 'Allungamento dei dorsali (rullo, anca)';
	@override String get hipStretchRoller => 'Allungamento delle anche (rullo)';
	@override String get gluteStretchSeated => 'Allungamento dei glutei (da seduti)';
	@override String get piriformisStretchSeated => 'Allungamento del piriforme (da seduti)';
	@override String get hipAbductionSideBridge => 'Abduzioni dell’anca (in ponte laterale)';
	@override String get hipAbductionSide => 'Abduzioni dell’anca (laterale)';
	@override String get legPressSled45WideStance => 'Pressa per le gambe (slitta, 45°, piedi divaricati)';
	@override String get deadliftSmith => 'Stacco da terra (Smith machine)';
	@override String get legPressSmith => 'Pressa per le gambe (Smith machine)';
	@override String get sideLyingStraightLegHipAbduction => 'Abduzioni dell’anca sul fianco a gamba tesa';
	@override String get swimmerKicks => 'Battute delle gambe da proni';
	@override String get tireTurnover => 'Ribaltamento dello pneumatico';
	@override String get trapBarDeadlift => 'Stacco da terra con trap bar';
	@override String get hipLiftWithRotation => 'Sollevamento del bacino con rotazione';
}

// Path: historyEditor.finish.fields
class Translations$historyEditor$finish$fields$it implements Translations$historyEditor$finish$fields$en {
	Translations$historyEditor$finish$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$historyEditor$finish$fields$name$it name = Translations$historyEditor$finish$fields$name$it._(_root);
	@override late final Translations$historyEditor$finish$fields$startingTime$it startingTime = Translations$historyEditor$finish$fields$startingTime$it._(_root);
	@override late final Translations$historyEditor$finish$fields$parent$it parent = Translations$historyEditor$finish$fields$parent$it._(_root);
	@override late final Translations$historyEditor$finish$fields$duration$it duration = Translations$historyEditor$finish$fields$duration$it._(_root);
	@override late final Translations$historyEditor$finish$fields$infobox$it infobox = Translations$historyEditor$finish$fields$infobox$it._(_root);
}

// Path: importRoutine.errors.badJson
class Translations$importRoutine$errors$badJson$it implements Translations$importRoutine$errors$badJson$en {
	Translations$importRoutine$errors$badJson$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dati danneggiati';
	@override String get body => 'Il link che hai seguito è danneggiato e non può essere aperto.';
}

// Path: importRoutine.errors.noJson
class Translations$importRoutine$errors$noJson$it implements Translations$importRoutine$errors$noJson$en {
	Translations$importRoutine$errors$noJson$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dati mancanti';
	@override String get body => 'Il link che hai seguito è danneggiato e non può essere aperto.';
}

// Path: importRoutine.errors.badWorkout
class Translations$importRoutine$errors$badWorkout$it implements Translations$importRoutine$errors$badWorkout$en {
	Translations$importRoutine$errors$badWorkout$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Allenamento non valido';
	@override String get body => 'Hai seguito un link che porta ad un allenamento non valido. Forse è stato creato da una vecchia versione dell\'app.';
}

// Path: me.weight.allData
class Translations$me$weight$allData$it implements Translations$me$weight$allData$en {
	Translations$me$weight$allData$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Mostra tutti i dati';
}

// Path: me.weight.measured
class Translations$me$weight$measured$it implements Translations$me$weight$measured$en {
	Translations$me$weight$measured$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get never => 'Ultima misurazione: mai';
	@override String date({required Object date}) => 'Ultima misurazione: ${date}';
}

// Path: me.addWeight.time
class Translations$me$addWeight$time$it implements Translations$me$addWeight$time$en {
	Translations$me$addWeight$time$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Data e ora';
}

// Path: me.addWeight.weight
class Translations$me$addWeight$weight$it implements Translations$me$addWeight$weight$en {
	Translations$me$addWeight$weight$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Peso';
}

// Path: me.addWeight.weightUnit
class Translations$me$addWeight$weightUnit$it implements Translations$me$addWeight$weightUnit$en {
	Translations$me$addWeight$weightUnit$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Unità';
}

// Path: me.addWeight.errors
class Translations$me$addWeight$errors$it implements Translations$me$addWeight$errors$en {
	Translations$me$addWeight$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get invalidWeight => 'Inserisci un peso valido';
}

// Path: me.allData.removed
class Translations$me$allData$removed$it implements Translations$me$allData$removed$en {
	Translations$me$allData$removed$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get text => 'Il dato è stato rimosso';
}

// Path: me.allData.predictedWeight
class Translations$me$allData$predictedWeight$it implements Translations$me$allData$predictedWeight$en {
	Translations$me$allData$predictedWeight$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Peso predetto';
	@override late final Translations$me$allData$predictedWeight$dialog$it dialog = Translations$me$allData$predictedWeight$dialog$it._(_root);
}

// Path: me.stats.workouts
class Translations$me$stats$workouts$it implements Translations$me$stats$workouts$en {
	Translations$me$stats$workouts$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Allenamenti';
}

// Path: me.stats.duration
class Translations$me$stats$duration$it implements Translations$me$stats$duration$en {
	Translations$me$stats$duration$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Durata';
}

// Path: me.stats.volume
class Translations$me$stats$volume$it implements Translations$me$stats$volume$en {
	Translations$me$stats$volume$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Volume';
}

// Path: me.stats.distance
class Translations$me$stats$distance$it implements Translations$me$stats$distance$en {
	Translations$me$stats$distance$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Distanza percorsa';
}

// Path: me.stats.sets
class Translations$me$stats$sets$it implements Translations$me$stats$sets$en {
	Translations$me$stats$sets$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Serie';
}

// Path: me.stats.overview
class Translations$me$stats$overview$it implements Translations$me$stats$overview$en {
	Translations$me$stats$overview$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get thisWeek => 'Questa settimana';
	@override String get title => 'Progressi';
	@override String get volume => 'Volume sollevato';
	@override String get personalRecords => 'Record personali';
	@override String get recordCriteria => 'Record di carico: a parità di peso, vale la serie con più ripetizioni.';
	@override String get emptyRecords => 'Completa una serie con peso e ripetizioni per vedere i tuoi record personali.';
	@override String get emptyWeek => 'Nessun volume registrato questa settimana.';
	@override String get loadError => 'Impossibile caricare i progressi';
	@override String get retryDescription => 'Riprova per caricare i tuoi allenamenti.';
}

// Path: me.stats.mainThree
class Translations$me$stats$mainThree$it implements Translations$me$stats$mainThree$en {
	Translations$me$stats$mainThree$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'I big 3';
	@override String get description => 'Visualizza l\'evoluzione dei tuoi massimali (1RM) per i "Big 3" nell\'intervallo di tempo selezionato. Il grafico utilizza il massimale più alto di ogni settimana per visualizzare l\'andamento complessivo dei carichi nei tre esercizi fondamentali del powerlifting.';
	@override late final Translations$me$stats$mainThree$warning$it warning = Translations$me$stats$mainThree$warning$it._(_root);
	@override String bottomTitle({required Object week}) => 'S${week}';
}

// Path: me.profile.edit
class Translations$me$profile$edit$it implements Translations$me$profile$edit$en {
	Translations$me$profile$edit$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Modifica profilo';
}

// Path: me.profile.errors
class Translations$me$profile$errors$it implements Translations$me$profile$errors$en {
	Translations$me$profile$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$me$profile$errors$logout$it logout = Translations$me$profile$errors$logout$it._(_root);
}

// Path: routineFormPicker.fields.routine
class Translations$routineFormPicker$fields$routine$it implements Translations$routineFormPicker$fields$routine$en {
	Translations$routineFormPicker$fields$routine$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$routineFormPicker$fields$routine$options$it options = Translations$routineFormPicker$fields$routine$options$it._(_root);
}

// Path: cardioTimer.setUp.errors
class Translations$cardioTimer$setUp$errors$it implements Translations$cardioTimer$setUp$errors$en {
	Translations$cardioTimer$setUp$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get duration => 'La durata non deve essere vuota.';
	@override String get bothZeros => 'Almeno uno dei tempi deve essere maggiore di zero.';
	@override String get generic => 'Ci sono errori nelle impostazioni. Risolvili e prova di nuovo.';
}

// Path: migrations.customToLibraryExercise.fields
class Translations$migrations$customToLibraryExercise$fields$it implements Translations$migrations$customToLibraryExercise$fields$en {
	Translations$migrations$customToLibraryExercise$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$customToLibraryExercise$fields$from$it from = Translations$migrations$customToLibraryExercise$fields$from$it._(_root);
	@override late final Translations$migrations$customToLibraryExercise$fields$to$it to = Translations$migrations$customToLibraryExercise$fields$to$it._(_root);
}

// Path: migrations.customToLibraryExercise.preview
class Translations$migrations$customToLibraryExercise$preview$it implements Translations$migrations$customToLibraryExercise$preview$en {
	Translations$migrations$customToLibraryExercise$preview$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get from => 'Sostituisci…';
	@override String get to => 'Con…';
	@override String get affectedRoutines => 'Routine influenzate';
	@override String get affectedWorkouts => 'Allenamenti cronologici influenzati';
}

// Path: migrations.common.actions
class Translations$migrations$common$actions$it implements Translations$migrations$common$actions$en {
	Translations$migrations$common$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get next => 'Prossimo step: anteprima';
	@override String get apply => 'Applica migrazione';
}

// Path: migrations.removeUnusedExercises.preview
class Translations$migrations$removeUnusedExercises$preview$it implements Translations$migrations$removeUnusedExercises$preview$en {
	Translations$migrations$removeUnusedExercises$preview$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get noAffected => 'Nessun dato verrebbe modificato.';
	@override String get affectedExercises => 'Esercizi influenzati';
}

// Path: migrations.removeWeightFromCustomExercise.preview
class Translations$migrations$removeWeightFromCustomExercise$preview$it implements Translations$migrations$removeWeightFromCustomExercise$preview$en {
	Translations$migrations$removeWeightFromCustomExercise$preview$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$removeWeightFromCustomExercise$preview$incompatible$it incompatible = Translations$migrations$removeWeightFromCustomExercise$preview$incompatible$it._(_root);
	@override String get selected => 'Esercizio selezionato';
	@override String get affectedRoutines => 'Routine influenzate';
	@override String get affectedWorkouts => 'Allenamenti cronologici influenzati';
}

// Path: migrations.removeWeightFromCustomExercise.fields
class Translations$migrations$removeWeightFromCustomExercise$fields$it implements Translations$migrations$removeWeightFromCustomExercise$fields$en {
	Translations$migrations$removeWeightFromCustomExercise$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$removeWeightFromCustomExercise$fields$exercise$it exercise = Translations$migrations$removeWeightFromCustomExercise$fields$exercise$it._(_root);
}

// Path: migrations.genericMultiplyWeight.fields
class Translations$migrations$genericMultiplyWeight$fields$it implements Translations$migrations$genericMultiplyWeight$fields$en {
	Translations$migrations$genericMultiplyWeight$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$genericMultiplyWeight$fields$exercise$it exercise = Translations$migrations$genericMultiplyWeight$fields$exercise$it._(_root);
}

// Path: migrations.genericMultiplyWeight.preview
class Translations$migrations$genericMultiplyWeight$preview$it implements Translations$migrations$genericMultiplyWeight$preview$en {
	Translations$migrations$genericMultiplyWeight$preview$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$migrations$genericMultiplyWeight$preview$incompatible$it incompatible = Translations$migrations$genericMultiplyWeight$preview$incompatible$it._(_root);
	@override String get selected => 'Esercizio selezionato';
	@override String get affectedRoutines => 'Routine modificate';
	@override String get affectedWorkouts => 'Allenamenti precedenti modificati';
}

// Path: exerciseFormPicker.fields.exercise
class Translations$exerciseFormPicker$fields$exercise$it implements Translations$exerciseFormPicker$fields$exercise$en {
	Translations$exerciseFormPicker$fields$exercise$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exerciseFormPicker$fields$exercise$options$it options = Translations$exerciseFormPicker$fields$exercise$options$it._(_root);
}

// Path: food.add.customFood
class Translations$food$add$customFood$it implements Translations$food$add$customFood$en {
	Translations$food$add$customFood$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get showMore => 'Mostra tutti i campi';
	@override String get title => 'Aggiungi cibo personalizzato';
	@override late final Translations$food$add$customFood$fields$it fields = Translations$food$add$customFood$fields$it._(_root);
}

// Path: food.search.error
class Translations$food$search$error$it implements Translations$food$search$error$en {
	Translations$food$search$error$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get serverError => 'Impossibile contattare il catalogo alimenti. Riprova più tardi.';
	@override String get generic => 'Impossibile contattare il catalogo alimenti. Riprova più tardi.';
}

// Path: food.barcodeReader.scanResult
class Translations$food$barcodeReader$scanResult$it implements Translations$food$barcodeReader$scanResult$en {
	Translations$food$barcodeReader$scanResult$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$food$barcodeReader$scanResult$noProductFound$it noProductFound = Translations$food$barcodeReader$scanResult$noProductFound$it._(_root);
	@override late final Translations$food$barcodeReader$scanResult$error$it error = Translations$food$barcodeReader$scanResult$error$it._(_root);
}

// Path: food.barcodeReader.codeField
class Translations$food$barcodeReader$codeField$it implements Translations$food$barcodeReader$codeField$en {
	Translations$food$barcodeReader$codeField$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Codice a barre';
	@override String get empty => 'Questo campo non può essere vuoto';
}

// Path: food.addCustomFood.permission
class Translations$food$addCustomFood$permission$it implements Translations$food$addCustomFood$permission$en {
	Translations$food$addCustomFood$permission$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Devi concedere le seguenti autorizzazioni';
	@override String get camera => 'Fotocamera (e microfono)';
	@override String get gallery => 'Accesso alla libreria foto (per scansionare i codici a barre nelle foto)';
	@override String get recheck => 'Ricontrolla';
	@override String get openAppSettings => 'Apri impostazioni delle autorizzazioni';
}

// Path: food.nutritionGoal.effect
class Translations$food$nutritionGoal$effect$it implements Translations$food$nutritionGoal$effect$en {
	Translations$food$nutritionGoal$effect$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String from({required Object from}) => 'La modifica verrà applicata a partire dal ${from}.';
	@override String range({required Object from, required Object to}) => 'La modifica verrà applicata dal ${from} al ${to}.';
}

// Path: food.nutritionGoals.change
class Translations$food$nutritionGoals$change$it implements Translations$food$nutritionGoals$change$en {
	Translations$food$nutritionGoals$change$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Imposta obiettivo';
	@override late final Translations$food$nutritionGoals$change$calories$it calories = Translations$food$nutritionGoals$change$calories$it._(_root);
	@override late final Translations$food$nutritionGoals$change$fatPercentage$it fatPercentage = Translations$food$nutritionGoals$change$fatPercentage$it._(_root);
	@override late final Translations$food$nutritionGoals$change$carbsPercentage$it carbsPercentage = Translations$food$nutritionGoals$change$carbsPercentage$it._(_root);
	@override late final Translations$food$nutritionGoals$change$proteinPercentage$it proteinPercentage = Translations$food$nutritionGoals$change$proteinPercentage$it._(_root);
	@override String get save => 'Salva modifiche';
}

// Path: food.nutritionGoals.history
class Translations$food$nutritionGoals$history$it implements Translations$food$nutritionGoals$history$en {
	Translations$food$nutritionGoals$history$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cronologia obiettivi';
	@override String get empty => 'Non ci sono obiettivi';
	@override String get tapToView => 'Tocca per andare al giorno';
	@override String calories({required Object calories}) => 'Calorie giornaliere: ${calories}';
	@override String macros({required Object carbs, required Object protein, required Object fat}) => '${carbs} carboidrati – ${protein} proteine – ${fat} grassi';
}

// Path: food.categoryList.unmodifiable
class Translations$food$categoryList$unmodifiable$it implements Translations$food$categoryList$unmodifiable$en {
	Translations$food$categoryList$unmodifiable$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impossibile modificare';
	@override String get text => 'Puoi modificare solo le categorie nei giorni dopo o durante il giorno corrente.';
}

// Path: food.categoryEditor.title
class Translations$food$categoryEditor$title$it implements Translations$food$categoryEditor$title$en {
	Translations$food$categoryEditor$title$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get add => 'Aggiungi categoria';
	@override String get edit => 'Modifica categoria';
}

// Path: food.categoryEditor.fields
class Translations$food$categoryEditor$fields$it implements Translations$food$categoryEditor$fields$en {
	Translations$food$categoryEditor$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$food$categoryEditor$fields$name$it name = Translations$food$categoryEditor$fields$name$it._(_root);
}

// Path: food.categoryEditor.effect
class Translations$food$categoryEditor$effect$it implements Translations$food$categoryEditor$effect$en {
	Translations$food$categoryEditor$effect$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String from({required Object from}) => 'Eventuali modifiche verranno applicate a partire dal ${from}.';
	@override String range({required Object from, required Object to}) => 'Eventuali modifiche verranno applicate dal ${from} al ${to}.';
	@override String get title => 'Range di applicazione';
}

// Path: food.categoryEditor.nonFulfillingSum
class Translations$food$categoryEditor$nonFulfillingSum$it implements Translations$food$categoryEditor$nonFulfillingSum$en {
	Translations$food$categoryEditor$nonFulfillingSum$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'La somma non è 100%';
}

// Path: achievements.firstSteps.description
class Translations$achievements$firstSteps$description$it implements Translations$achievements$firstSteps$description$en {
	Translations$achievements$firstSteps$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get k1 => 'Completa il tuo primo allenamento';
	@override String get k2 => 'Traccia il tuo primo peso';
	@override String get k3 => 'Traccia il tuo primo pasto';
}

// Path: achievements.foodWatcher.description
class Translations$achievements$foodWatcher$description$it implements Translations$achievements$foodWatcher$description$en {
	Translations$achievements$foodWatcher$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get k1 => 'Traccia i tuoi pasti per 2 giorni di fila';
	@override String get k2 => 'Traccia i tuoi pasti per 7 giorni di fila';
	@override String get k3 => 'Traccia i tuoi pasti per un intero mese di fila';
}

// Path: achievements.marathoner.description
class Translations$achievements$marathoner$description$it implements Translations$achievements$marathoner$description$en {
	Translations$achievements$marathoner$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get k1 => 'Percorri una 5km';
	@override String get k2 => 'Percorri una mezza maratona';
	@override String get k3 => 'Percorri un\'intera maratona';
}

// Path: achievements.realGymBro.description
class Translations$achievements$realGymBro$description$it implements Translations$achievements$realGymBro$description$en {
	Translations$achievements$realGymBro$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get k1 => 'Traccia un totale di 100 ore di allenamenti';
	@override String get k2 => 'Traccia un totale di 500 ore di allenamenti';
	@override String get k3 => 'Traccia un totale di 1000 ore di allenamenti';
}

// Path: achievements.workoutFreak.description
class Translations$achievements$workoutFreak$description$it implements Translations$achievements$workoutFreak$description$en {
	Translations$achievements$workoutFreak$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get k1 => 'Traccia un allenamento al giorno per tutto un mese';
	@override String get k2 => 'Traccia un allenamento al giorno per tutto un anno';
}

// Path: achievements.trailblazer.description
class Translations$achievements$trailblazer$description$it implements Translations$achievements$trailblazer$description$en {
	Translations$achievements$trailblazer$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$achievements$trailblazer$description$k1$it k1 = Translations$achievements$trailblazer$description$k1$it._(_root);
	@override late final Translations$achievements$trailblazer$description$k2$it k2 = Translations$achievements$trailblazer$description$k2$it._(_root);
	@override late final Translations$achievements$trailblazer$description$k3$it k3 = Translations$achievements$trailblazer$description$k3$it._(_root);
}

// Path: achievements.cycleChampion.description
class Translations$achievements$cycleChampion$description$it implements Translations$achievements$cycleChampion$description$en {
	Translations$achievements$cycleChampion$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$achievements$cycleChampion$description$k1$it k1 = Translations$achievements$cycleChampion$description$k1$it._(_root);
	@override late final Translations$achievements$cycleChampion$description$k2$it k2 = Translations$achievements$cycleChampion$description$k2$it._(_root);
	@override late final Translations$achievements$cycleChampion$description$k3$it k3 = Translations$achievements$cycleChampion$description$k3$it._(_root);
}

// Path: achievements.professionalWeightlifter.description
class Translations$achievements$professionalWeightlifter$description$it implements Translations$achievements$professionalWeightlifter$description$en {
	Translations$achievements$professionalWeightlifter$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get k1 => 'Solleva il tuo peso corporeo in una ripetizione';
	@override String get k2 => 'Solleva 1.5x volte il tuo peso corporeo in una ripetizione';
	@override String get k3 => 'Solleva 3x volte il tuo peso corporeo in una ripetizione';
}

// Path: achievements.routineMaster.description
class Translations$achievements$routineMaster$description$it implements Translations$achievements$routineMaster$description$en {
	Translations$achievements$routineMaster$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get k1 => 'Segui una routine per 3 mesi consecutivi';
	@override String get k2 => 'Segui una routine per 6 mesi consecutivi';
	@override String get k3 => 'Segui una routine per 12 mesi consecutivi';
}

// Path: achievements.sparta.description
class Translations$achievements$sparta$description$it implements Translations$achievements$sparta$description$en {
	Translations$achievements$sparta$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$achievements$sparta$description$k1$it k1 = Translations$achievements$sparta$description$k1$it._(_root);
	@override late final Translations$achievements$sparta$description$k2$it k2 = Translations$achievements$sparta$description$k2$it._(_root);
}

// Path: login.errors.password
class Translations$login$errors$password$it implements Translations$login$errors$password$en {
	Translations$login$errors$password$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$login$errors$password$invalid$it invalid = Translations$login$errors$password$invalid$it._(_root);
}

// Path: login.fields.email
class Translations$login$fields$email$it implements Translations$login$fields$email$en {
	Translations$login$fields$email$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Email';
	@override String get hint => 'mario.rossi@example.com';
}

// Path: login.fields.password
class Translations$login$fields$password$it implements Translations$login$fields$password$en {
	Translations$login$fields$password$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Password';
	@override String get hint => 'Password';
}

// Path: login.fields.username
class Translations$login$fields$username$it implements Translations$login$fields$username$en {
	Translations$login$fields$username$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Username';
	@override String get hint => 'Username';
}

// Path: login.fields.confirmPassword
class Translations$login$fields$confirmPassword$it implements Translations$login$fields$confirmPassword$en {
	Translations$login$fields$confirmPassword$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Conferma password';
}

// Path: feed.workout.title
class Translations$feed$workout$title$it implements Translations$feed$workout$title$en {
	Translations$feed$workout$title$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get you => 'Tu';
	@override String get unknown => 'Utente Sconosciuto';
}

// Path: feed.workout.subtitle
class Translations$feed$workout$subtitle$it implements Translations$feed$workout$subtitle$en {
	Translations$feed$workout$subtitle$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get you => 'hai completato un allenamento';
	@override String get friend => 'ha completato un allenamento';
}

// Path: feed.achievement.title
class Translations$feed$achievement$title$it implements Translations$feed$achievement$title$en {
	Translations$feed$achievement$title$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get you => 'Tu';
}

// Path: feed.achievement.subtitle
class Translations$feed$achievement$subtitle$it implements Translations$feed$achievement$subtitle$en {
	Translations$feed$achievement$subtitle$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get you => 'hai sbloccato un traguardo';
	@override String get friend => 'ha sbloccato un traguardo';
}

// Path: userProfile.feed.unavailable
class Translations$userProfile$feed$unavailable$it implements Translations$userProfile$feed$unavailable$en {
	Translations$userProfile$feed$unavailable$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Allenamenti non visibili';
	@override String get description => 'I dati degli allenamenti sono visibili solo agli amici.';
}

// Path: userProfile.crop.buttons
class Translations$userProfile$crop$buttons$it implements Translations$userProfile$crop$buttons$en {
	Translations$userProfile$crop$buttons$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get confirm => 'Ritaglia';
	@override String get cancel => 'Annulla';
}

// Path: exercise.editor.fields.title
class Translations$exercise$editor$fields$title$it implements Translations$exercise$editor$fields$title$en {
	Translations$exercise$editor$fields$title$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Nome esercizio';
	@override late final Translations$exercise$editor$fields$title$errors$it errors = Translations$exercise$editor$fields$title$errors$it._(_root);
}

// Path: exercise.editor.fields.parameters
class Translations$exercise$editor$fields$parameters$it implements Translations$exercise$editor$fields$parameters$en {
	Translations$exercise$editor$fields$parameters$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Parametri';
	@override Map<String, String> get values => {
		'repsNegWeight': 'Peso negativo e ripetizioni',
		'repsWeight': 'Peso e ripetizioni',
		'timeWeight': 'Peso e tempo',
		'time': 'Tempo',
		'freeBodyReps': 'Ripetizioni',
		'distance': 'Distanza',
	};
	@override late final Translations$exercise$editor$fields$parameters$errors$it errors = Translations$exercise$editor$fields$parameters$errors$it._(_root);
}

// Path: exercise.editor.fields.primaryMuscleGroup
class Translations$exercise$editor$fields$primaryMuscleGroup$it implements Translations$exercise$editor$fields$primaryMuscleGroup$en {
	Translations$exercise$editor$fields$primaryMuscleGroup$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Gruppo muscolare primario';
	@override late final Translations$exercise$editor$fields$primaryMuscleGroup$errors$it errors = Translations$exercise$editor$fields$primaryMuscleGroup$errors$it._(_root);
}

// Path: exercise.editor.fields.secondaryMuscleGroups
class Translations$exercise$editor$fields$secondaryMuscleGroups$it implements Translations$exercise$editor$fields$secondaryMuscleGroups$en {
	Translations$exercise$editor$fields$secondaryMuscleGroups$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Gruppi muscolari secondari';
}

// Path: exercise.editor.fields.notes
class Translations$exercise$editor$fields$notes$it implements Translations$exercise$editor$fields$notes$en {
	Translations$exercise$editor$fields$notes$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Note';
	@override String get tapToEdit => 'Tocca per inserire note';
}

// Path: exercise.editor.fields.rpe
class Translations$exercise$editor$fields$rpe$it implements Translations$exercise$editor$fields$rpe$en {
	Translations$exercise$editor$fields$rpe$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get removeRPE => 'Rimuovi RPE';
	@override String get label => 'Imposta RPE';
	@override late final Translations$exercise$editor$fields$rpe$description$it description = Translations$exercise$editor$fields$rpe$description$it._(_root);
	@override List<dynamic> get levels => [
		Translations$exercise$editor$fields$rpe$levels$0$it._(_root),
		Translations$exercise$editor$fields$rpe$levels$1$it._(_root),
		Translations$exercise$editor$fields$rpe$levels$2$it._(_root),
		Translations$exercise$editor$fields$rpe$levels$3$it._(_root),
		Translations$exercise$editor$fields$rpe$levels$4$it._(_root),
		Translations$exercise$editor$fields$rpe$levels$5$it._(_root),
		Translations$exercise$editor$fields$rpe$levels$6$it._(_root),
		Translations$exercise$editor$fields$rpe$levels$7$it._(_root),
		Translations$exercise$editor$fields$rpe$levels$8$it._(_root),
		Translations$exercise$editor$fields$rpe$levels$9$it._(_root),
	];
}

// Path: exercise.editor.fields.reorderSets
class Translations$exercise$editor$fields$reorderSets$it implements Translations$exercise$editor$fields$reorderSets$en {
	Translations$exercise$editor$fields$reorderSets$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Riordina serie';
	@override String get text => 'Trascina le maniglie per riordinare le serie';
}

// Path: exercise.editor.fields.gymEquipment
class Translations$exercise$editor$fields$gymEquipment$it implements Translations$exercise$editor$fields$gymEquipment$en {
	Translations$exercise$editor$fields$gymEquipment$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$exercise$editor$fields$gymEquipment$errors$it errors = Translations$exercise$editor$fields$gymEquipment$errors$it._(_root);
	@override String get label => 'Attrezzatura';
}

// Path: exercise.editor.advanced.setless
class Translations$exercise$editor$advanced$setless$it implements Translations$exercise$editor$advanced$setless$en {
	Translations$exercise$editor$advanced$setless$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get text => 'Disabilita la funzionalità delle serie. Questa opzione rende l\'esercizio un segnaposto nei tuoi allenamenti.';
	@override String get title => 'Senza serie';
}

// Path: exercise.continuation.combine.confirm
class Translations$exercise$continuation$combine$confirm$it implements Translations$exercise$continuation$combine$confirm$en {
	Translations$exercise$continuation$combine$confirm$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unisci allenamenti';
	@override String get body => 'Vuoi davvero unire questi due allenamenti? Quest\'azione non può essere annullata. Inoltre, i vecchi allenamenti non saranno più disponibili.';
}

// Path: workouts.actions.delete.actions
class Translations$workouts$actions$delete$actions$it implements Translations$workouts$actions$delete$actions$en {
	Translations$workouts$actions$delete$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get no => 'Annulla';
	@override String get yes => 'Elimina';
}

// Path: workouts.actions.rename.errors
class Translations$workouts$actions$rename$errors$it implements Translations$workouts$actions$rename$errors$en {
	Translations$workouts$actions$rename$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Il nome non dev\'essere vuoto.';
}

// Path: workouts.actions.changeParent.options
class Translations$workouts$actions$changeParent$options$it implements Translations$workouts$actions$changeParent$options$en {
	Translations$workouts$actions$changeParent$options$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get none => 'Nessuna';
}

// Path: workouts.actions.share.alert
class Translations$workouts$actions$share$alert$it implements Translations$workouts$actions$share$alert$en {
	Translations$workouts$actions$share$alert$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Link generato';
	@override String get body => 'Un link univoco è stato generato. Tocca il pulsante per copiarlo, poi invia il link per condividere questa routine.';
	@override late final Translations$workouts$actions$share$alert$actions$it actions = Translations$workouts$actions$share$alert$actions$it._(_root);
	@override String get noQr => 'Impossibile generare codice QR: routine troppo grande. Usa il link in basso per condividere la tua routine.';
}

// Path: routines.actions.delete.actions
class Translations$routines$actions$delete$actions$it implements Translations$routines$actions$delete$actions$en {
	Translations$routines$actions$delete$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get no => 'Annulla';
	@override String get yes => 'Elimina';
}

// Path: routines.editor.fields.name
class Translations$routines$editor$fields$name$it implements Translations$routines$editor$fields$name$en {
	Translations$routines$editor$fields$name$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Nome della routine';
	@override late final Translations$routines$editor$fields$name$errors$it errors = Translations$routines$editor$fields$name$errors$it._(_root);
}

// Path: routines.editor.fields.infobox
class Translations$routines$editor$fields$infobox$it implements Translations$routines$editor$fields$infobox$en {
	Translations$routines$editor$fields$infobox$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Note';
}

// Path: routines.editor.superset.remove
class Translations$routines$editor$superset$remove$it implements Translations$routines$editor$superset$remove$en {
	Translations$routines$editor$superset$remove$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rimuovi superserie';
	@override String get body => 'Vuoi davvero rimuovere questa superserie? Quest\'azione non può essere annullata.';
}

// Path: history.actions.deleteMultiple.actions
class Translations$history$actions$deleteMultiple$actions$it implements Translations$history$actions$deleteMultiple$actions$en {
	Translations$history$actions$deleteMultiple$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get no => 'Annulla';
	@override String get yes => 'Elimina';
}

// Path: settings.options.locale.values
class Translations$settings$options$locale$values$it implements Translations$settings$options$locale$values$en {
	Translations$settings$options$locale$values$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get system => 'Sistema';
}

// Path: settings.options.import.failed
class Translations$settings$options$import$failed$it implements Translations$settings$options$import$failed$en {
	Translations$settings$options$import$failed$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impossibile importare i dati';
	@override String get copy => 'Il messaggio di errore è stato copiato negli appunti.';
}

// Path: settings.options.import.utils
class Translations$settings$options$import$utils$it implements Translations$settings$options$import$utils$en {
	Translations$settings$options$import$utils$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$settings$options$import$utils$hevy$it hevy = Translations$settings$options$import$utils$hevy$it._(_root);
}

// Path: settings.options.import.types
class Translations$settings$options$import$types$it implements Translations$settings$options$import$types$en {
	Translations$settings$options$import$types$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get gt => 'Gym Bro (JSON)';
	@override String get hevy => 'Hevy (CSV)';
}

// Path: settings.options.export.failed
class Translations$settings$options$export$failed$it implements Translations$settings$options$export$failed$en {
	Translations$settings$options$export$failed$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impossibile esportare i dati';
	@override String get copy => 'Il messaggio di errore è stato copiato negli appunti.';
}

// Path: settings.options.notifications.subtitle
class Translations$settings$options$notifications$subtitle$it implements Translations$settings$options$notifications$subtitle$en {
	Translations$settings$options$notifications$subtitle$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get noExactAlarmPermission => 'Tocca per richiedere il permesso "Promemoria e avvisi" (Android 14+)';
}

// Path: settings.advanced.options.logs
class Translations$settings$advanced$options$logs$it implements Translations$settings$advanced$options$logs$en {
	Translations$settings$advanced$options$logs$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Log';
	@override Map<String, String> get levels => {
		'trace': 'Tutti i log',
		'debug': 'Debug',
		'info': 'Info',
		'warning': 'Avviso',
		'error': 'Errore',
		'fatal': 'Errore fatale',
	};
	@override String get level => 'Livello';
}

// Path: settings.advanced.options.migrations
class Translations$settings$advanced$options$migrations$it implements Translations$settings$advanced$options$migrations$en {
	Translations$settings$advanced$options$migrations$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Migrazioni';
}

// Path: settings.advanced.options.backups
class Translations$settings$advanced$options$backups$it implements Translations$settings$advanced$options$backups$en {
	Translations$settings$advanced$options$backups$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Backup';
	@override late final Translations$settings$advanced$options$backups$restore$it restore = Translations$settings$advanced$options$backups$restore$it._(_root);
	@override String get restoring => 'Ripristino';
	@override String get creating => 'Creazione backup';
	@override late final Translations$settings$advanced$options$backups$delete$it delete = Translations$settings$advanced$options$backups$delete$it._(_root);
	@override String get deleting => 'Eliminazione';
	@override String get create => 'Crea backup';
}

// Path: settings.advanced.options.sync
class Translations$settings$advanced$options$sync$it implements Translations$settings$advanced$options$sync$en {
	Translations$settings$advanced$options$sync$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Stato sincronizzazione';
	@override late final Translations$settings$advanced$options$sync$status$it status = Translations$settings$advanced$options$sync$status$it._(_root);
	@override String lastSync({required Object date}) => 'Ultima sincronizzazione: ${date}';
	@override String get never => 'Mai sincronizzato';
	@override String get notLoggedIn => 'Non hai effettuato l\'accesso';
	@override String get syncNow => 'Sincronizza ora';
	@override String get rateLimited => 'Attendi un minuto prima di sincronizzare di nuovo';
}

// Path: settings.advanced.deleteAccount.warning
class Translations$settings$advanced$deleteAccount$warning$it implements Translations$settings$advanced$deleteAccount$warning$en {
	Translations$settings$advanced$deleteAccount$warning$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vuoi eliminare definitivamente l\'account?';
	@override String get content => 'Perderai immediatamente tutti i tuoi dati. Non potrai annullare questa operazione. Sei sicuro di voler continuare?';
}

// Path: settings.advanced.deleteAccount.confirmation
class Translations$settings$advanced$deleteAccount$confirmation$it implements Translations$settings$advanced$deleteAccount$confirmation$en {
	Translations$settings$advanced$deleteAccount$confirmation$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Conferma eliminazione';
	@override String content({required Object username}) => 'Digita il tuo username (${username}) per procedere.';
	@override String get hint => 'Username';
	@override late final Translations$settings$advanced$deleteAccount$confirmation$error$it error = Translations$settings$advanced$deleteAccount$confirmation$error$it._(_root);
}

// Path: ongoingWorkout.finish.fields.name
class Translations$ongoingWorkout$finish$fields$name$it implements Translations$ongoingWorkout$finish$fields$name$en {
	Translations$ongoingWorkout$finish$fields$name$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Nome allenamento';
	@override late final Translations$ongoingWorkout$finish$fields$name$errors$it errors = Translations$ongoingWorkout$finish$fields$name$errors$it._(_root);
}

// Path: ongoingWorkout.finish.fields.startingTime
class Translations$ongoingWorkout$finish$fields$startingTime$it implements Translations$ongoingWorkout$finish$fields$startingTime$en {
	Translations$ongoingWorkout$finish$fields$startingTime$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Data di avvio';
}

// Path: ongoingWorkout.finish.fields.parent
class Translations$ongoingWorkout$finish$fields$parent$it implements Translations$ongoingWorkout$finish$fields$parent$en {
	Translations$ongoingWorkout$finish$fields$parent$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Routine di riferimento';
	@override late final Translations$ongoingWorkout$finish$fields$parent$options$it options = Translations$ongoingWorkout$finish$fields$parent$options$it._(_root);
	@override String get help => 'Associa questo allenamento a una routine. Le eventuali modifiche alla routine ti saranno chieste dopo il salvataggio.';
}

// Path: ongoingWorkout.finish.fields.duration
class Translations$ongoingWorkout$finish$fields$duration$it implements Translations$ongoingWorkout$finish$fields$duration$en {
	Translations$ongoingWorkout$finish$fields$duration$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Durata';
	@override late final Translations$ongoingWorkout$finish$fields$duration$errors$it errors = Translations$ongoingWorkout$finish$fields$duration$errors$it._(_root);
}

// Path: ongoingWorkout.finish.fields.infobox
class Translations$ongoingWorkout$finish$fields$infobox$it implements Translations$ongoingWorkout$finish$fields$infobox$en {
	Translations$ongoingWorkout$finish$fields$infobox$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Note';
}

// Path: historyEditor.finish.fields.name
class Translations$historyEditor$finish$fields$name$it implements Translations$historyEditor$finish$fields$name$en {
	Translations$historyEditor$finish$fields$name$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Nome';
	@override late final Translations$historyEditor$finish$fields$name$errors$it errors = Translations$historyEditor$finish$fields$name$errors$it._(_root);
}

// Path: historyEditor.finish.fields.startingTime
class Translations$historyEditor$finish$fields$startingTime$it implements Translations$historyEditor$finish$fields$startingTime$en {
	Translations$historyEditor$finish$fields$startingTime$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Data di inizio';
}

// Path: historyEditor.finish.fields.parent
class Translations$historyEditor$finish$fields$parent$it implements Translations$historyEditor$finish$fields$parent$en {
	Translations$historyEditor$finish$fields$parent$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Salva come';
	@override late final Translations$historyEditor$finish$fields$parent$options$it options = Translations$historyEditor$finish$fields$parent$options$it._(_root);
}

// Path: historyEditor.finish.fields.duration
class Translations$historyEditor$finish$fields$duration$it implements Translations$historyEditor$finish$fields$duration$en {
	Translations$historyEditor$finish$fields$duration$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Durata';
	@override late final Translations$historyEditor$finish$fields$duration$errors$it errors = Translations$historyEditor$finish$fields$duration$errors$it._(_root);
}

// Path: historyEditor.finish.fields.infobox
class Translations$historyEditor$finish$fields$infobox$it implements Translations$historyEditor$finish$fields$infobox$en {
	Translations$historyEditor$finish$fields$infobox$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Note';
}

// Path: me.allData.predictedWeight.dialog
class Translations$me$allData$predictedWeight$dialog$it implements Translations$me$allData$predictedWeight$dialog$en {
	Translations$me$allData$predictedWeight$dialog$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Peso predetto';
	@override String get text => 'La predizione del peso è fornita a scopo esclusivamente informativo e non va presa seriamente.';
}

// Path: me.stats.mainThree.warning
class Translations$me$stats$mainThree$warning$it implements Translations$me$stats$mainThree$warning$en {
	Translations$me$stats$mainThree$warning$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nota sul grafico';
	@override String text({required Object exercises}) => 'Affinché i progressi vengano calcolati e visualizzati correttamente nel grafico, utilizza gli esercizi standard della libreria dell\'app anziché creare varianti personalizzate. Nello specifico: ${exercises}.';
}

// Path: me.profile.errors.logout
class Translations$me$profile$errors$logout$it implements Translations$me$profile$errors$logout$en {
	Translations$me$profile$errors$logout$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Si è verificato un errore';
	@override String subtitle({required Object error}) => 'Impossibile effettuare il logout: ${error}';
}

// Path: routineFormPicker.fields.routine.options
class Translations$routineFormPicker$fields$routine$options$it implements Translations$routineFormPicker$fields$routine$options$en {
	Translations$routineFormPicker$fields$routine$options$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get none => 'Nessuna routine selezionata';
	@override String get root => 'Home';
}

// Path: migrations.customToLibraryExercise.fields.from
class Translations$migrations$customToLibraryExercise$fields$from$it implements Translations$migrations$customToLibraryExercise$fields$from$en {
	Translations$migrations$customToLibraryExercise$fields$from$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sostituisci tutte le occorrenze di questo esercizio personalizzato…';
	@override String get label => 'Esercizio personalizzato';
}

// Path: migrations.customToLibraryExercise.fields.to
class Translations$migrations$customToLibraryExercise$fields$to$it implements Translations$migrations$customToLibraryExercise$fields$to$en {
	Translations$migrations$customToLibraryExercise$fields$to$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => '…con questo esercizio standard…';
	@override String get label => 'Esercizio standard';
}

// Path: migrations.removeWeightFromCustomExercise.preview.incompatible
class Translations$migrations$removeWeightFromCustomExercise$preview$incompatible$it implements Translations$migrations$removeWeightFromCustomExercise$preview$incompatible$en {
	Translations$migrations$removeWeightFromCustomExercise$preview$incompatible$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Esercizio non compatibile';
	@override String get text => 'Puoi applicare questa migrazione solo agli esercizi dove non hai mai usato il campo Peso.';
}

// Path: migrations.removeWeightFromCustomExercise.fields.exercise
class Translations$migrations$removeWeightFromCustomExercise$fields$exercise$it implements Translations$migrations$removeWeightFromCustomExercise$fields$exercise$en {
	Translations$migrations$removeWeightFromCustomExercise$fields$exercise$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Esercizio';
	@override String get title => 'Rimuovi il parametro Peso da questo esercizio';
}

// Path: migrations.genericMultiplyWeight.fields.exercise
class Translations$migrations$genericMultiplyWeight$fields$exercise$it implements Translations$migrations$genericMultiplyWeight$fields$exercise$en {
	Translations$migrations$genericMultiplyWeight$fields$exercise$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Moltiplica il peso di questo esercizio...';
	@override String get label => 'Esercizio';
}

// Path: migrations.genericMultiplyWeight.preview.incompatible
class Translations$migrations$genericMultiplyWeight$preview$incompatible$it implements Translations$migrations$genericMultiplyWeight$preview$incompatible$en {
	Translations$migrations$genericMultiplyWeight$preview$incompatible$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Esercizio non compatibile';
	@override String get text => 'Cambia la tua selezione e riprova.';
}

// Path: exerciseFormPicker.fields.exercise.options
class Translations$exerciseFormPicker$fields$exercise$options$it implements Translations$exerciseFormPicker$fields$exercise$options$en {
	Translations$exerciseFormPicker$fields$exercise$options$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get none => 'Nessun esercizio selezionato';
}

// Path: food.add.customFood.fields
class Translations$food$add$customFood$fields$it implements Translations$food$add$customFood$fields$en {
	Translations$food$add$customFood$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nome';
	@override String get brand => 'Marca';
}

// Path: food.barcodeReader.scanResult.noProductFound
class Translations$food$barcodeReader$scanResult$noProductFound$it implements Translations$food$barcodeReader$scanResult$noProductFound$en {
	Translations$food$barcodeReader$scanResult$noProductFound$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String text({required Object barcode}) => 'Nessun prodotto è stato trovato con codice ${barcode}.';
	@override String get title => 'Nessun prodotto';
	@override String get createNew => 'Crea nuovo prodotto';
}

// Path: food.barcodeReader.scanResult.error
class Translations$food$barcodeReader$scanResult$error$it implements Translations$food$barcodeReader$scanResult$error$en {
	Translations$food$barcodeReader$scanResult$error$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Si è verificato un errore';
	@override String get text => 'Impossibile cercare il prodotto.';
}

// Path: food.nutritionGoals.change.calories
class Translations$food$nutritionGoals$change$calories$it implements Translations$food$nutritionGoals$change$calories$en {
	Translations$food$nutritionGoals$change$calories$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Calorie giornaliere';
	@override String get empty => 'Questo valore non può essere vuoto.';
	@override String get invalid => 'Inserisci un numero valido.';
}

// Path: food.nutritionGoals.change.fatPercentage
class Translations$food$nutritionGoals$change$fatPercentage$it implements Translations$food$nutritionGoals$change$fatPercentage$en {
	Translations$food$nutritionGoals$change$fatPercentage$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Grassi (%)';
	@override String get empty => 'Questo valore non può essere vuoto.';
	@override String get invalid => 'Inserisci un numero valido tra 0 e 100.';
}

// Path: food.nutritionGoals.change.carbsPercentage
class Translations$food$nutritionGoals$change$carbsPercentage$it implements Translations$food$nutritionGoals$change$carbsPercentage$en {
	Translations$food$nutritionGoals$change$carbsPercentage$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Carboidrati (%)';
	@override String get empty => 'Questo valore non può essere vuoto.';
	@override String get invalid => 'Inserisci un numero valido tra 0 e 100.';
}

// Path: food.nutritionGoals.change.proteinPercentage
class Translations$food$nutritionGoals$change$proteinPercentage$it implements Translations$food$nutritionGoals$change$proteinPercentage$en {
	Translations$food$nutritionGoals$change$proteinPercentage$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get label => 'Proteine (%)';
	@override String get empty => 'Questo valore non può essere vuoto.';
	@override String get invalid => 'Inserisci un numero valido tra 0 e 100.';
}

// Path: food.categoryEditor.fields.name
class Translations$food$categoryEditor$fields$name$it implements Translations$food$categoryEditor$fields$name$en {
	Translations$food$categoryEditor$fields$name$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$food$categoryEditor$fields$name$errors$it errors = Translations$food$categoryEditor$fields$name$errors$it._(_root);
}

// Path: achievements.trailblazer.description.k1
class Translations$achievements$trailblazer$description$k1$it implements Translations$achievements$trailblazer$description$k1$en {
	Translations$achievements$trailblazer$description$k1$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get km => 'Percorri un totale di 100 km';
	@override String mi({required Object p0}) => 'Percorri un totale di 100 km (${p0})';
}

// Path: achievements.trailblazer.description.k2
class Translations$achievements$trailblazer$description$k2$it implements Translations$achievements$trailblazer$description$k2$en {
	Translations$achievements$trailblazer$description$k2$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get km => 'Percorri un totale di 500 km';
	@override String mi({required Object p0}) => 'Percorri un totale di 500 km (${p0})';
}

// Path: achievements.trailblazer.description.k3
class Translations$achievements$trailblazer$description$k3$it implements Translations$achievements$trailblazer$description$k3$en {
	Translations$achievements$trailblazer$description$k3$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get km => 'Percorri un totale di 1000 km';
	@override String mi({required Object p0}) => 'Percorri un totale di 1000 km (${p0})';
}

// Path: achievements.cycleChampion.description.k1
class Translations$achievements$cycleChampion$description$k1$it implements Translations$achievements$cycleChampion$description$k1$en {
	Translations$achievements$cycleChampion$description$k1$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get km => 'Pedala per un totale di 100 km';
	@override String mi({required Object p0}) => 'Pedala per un totale di 100 km (${p0})';
}

// Path: achievements.cycleChampion.description.k2
class Translations$achievements$cycleChampion$description$k2$it implements Translations$achievements$cycleChampion$description$k2$en {
	Translations$achievements$cycleChampion$description$k2$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get km => 'Pedala per un totale di 500 km';
	@override String mi({required Object p0}) => 'Pedala per un totale di 500 km (${p0})';
}

// Path: achievements.cycleChampion.description.k3
class Translations$achievements$cycleChampion$description$k3$it implements Translations$achievements$cycleChampion$description$k3$en {
	Translations$achievements$cycleChampion$description$k3$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get km => 'Pedala per un totale di 1000 km';
	@override String mi({required Object p0}) => 'Pedala per un totale di 1000 km (${p0})';
}

// Path: achievements.sparta.description.k1
class Translations$achievements$sparta$description$k1$it implements Translations$achievements$sparta$description$k1$en {
	Translations$achievements$sparta$description$k1$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String kg({required Object p0}) => 'Solleva 300 lb (${p0}) in una ripetizione';
	@override String get lb => 'Solleva 300 lb in una ripetizione';
}

// Path: achievements.sparta.description.k2
class Translations$achievements$sparta$description$k2$it implements Translations$achievements$sparta$description$k2$en {
	Translations$achievements$sparta$description$k2$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get kg => 'Solleva 300 kg in una ripetizione';
	@override String lb({required Object p0}) => 'Solleva 300 kg (${p0}) in una ripetizione';
}

// Path: login.errors.password.invalid
class Translations$login$errors$password$invalid$it implements Translations$login$errors$password$invalid$en {
	Translations$login$errors$password$invalid$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get header => 'La password deve:';
	@override String get length => '- Essere lunga almeno 8 caratteri';
	@override String get uppercase => '- Contenere almeno una lettera maiuscola';
	@override String get lowercase => '- Contenere almeno una lettera minuscola';
	@override String get number => '- Contenere almeno un numero';
	@override String get specialCharacter => '- Contenere almeno un carattere speciale';
}

// Path: exercise.editor.fields.title.errors
class Translations$exercise$editor$fields$title$errors$it implements Translations$exercise$editor$fields$title$errors$en {
	Translations$exercise$editor$fields$title$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Il nome non dev\'essere vuoto.';
	@override String get invalid => 'Un esercizio con questo nome esiste già.';
}

// Path: exercise.editor.fields.parameters.errors
class Translations$exercise$editor$fields$parameters$errors$it implements Translations$exercise$editor$fields$parameters$errors$en {
	Translations$exercise$editor$fields$parameters$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Seleziona i parametri di questo esercizio';
}

// Path: exercise.editor.fields.primaryMuscleGroup.errors
class Translations$exercise$editor$fields$primaryMuscleGroup$errors$it implements Translations$exercise$editor$fields$primaryMuscleGroup$errors$en {
	Translations$exercise$editor$fields$primaryMuscleGroup$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Devi selezionare un gruppo muscolare.';
}

// Path: exercise.editor.fields.rpe.description
class Translations$exercise$editor$fields$rpe$description$it implements Translations$exercise$editor$fields$rpe$description$en {
	Translations$exercise$editor$fields$rpe$description$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cos\'è l\'RPE?';
	@override String get text => 'L\'RPE (Rate of Perceived Exertion, tasso di sforzo percepito) è una misurazione soggettiva della difficoltà di un esercizio. Si misura da 1 a 10, dove 1 sta per "sforzo molto basso" e 10 sta per "sforzo massimo". Si può misurare in base alla stima delle ripetizioni rimanenti al termine di una serie (ad esempio, RPE 8 significa che potresti fare altre 2 ripetizioni prima di cedere).';
}

// Path: exercise.editor.fields.rpe.levels.0
class Translations$exercise$editor$fields$rpe$levels$0$it implements Translations$exercise$editor$fields$rpe$levels$0$en {
	Translations$exercise$editor$fields$rpe$levels$0$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 1';
	@override String get text => 'Sforzo molto basso.';
}

// Path: exercise.editor.fields.rpe.levels.1
class Translations$exercise$editor$fields$rpe$levels$1$it implements Translations$exercise$editor$fields$rpe$levels$1$en {
	Translations$exercise$editor$fields$rpe$levels$1$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 2';
	@override String get text => 'Sforzo basso.';
}

// Path: exercise.editor.fields.rpe.levels.2
class Translations$exercise$editor$fields$rpe$levels$2$it implements Translations$exercise$editor$fields$rpe$levels$2$en {
	Translations$exercise$editor$fields$rpe$levels$2$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 3';
	@override String get text => 'Sforzo basso.';
}

// Path: exercise.editor.fields.rpe.levels.3
class Translations$exercise$editor$fields$rpe$levels$3$it implements Translations$exercise$editor$fields$rpe$levels$3$en {
	Translations$exercise$editor$fields$rpe$levels$3$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 4';
	@override String get text => 'Sforzo moderato.';
}

// Path: exercise.editor.fields.rpe.levels.4
class Translations$exercise$editor$fields$rpe$levels$4$it implements Translations$exercise$editor$fields$rpe$levels$4$en {
	Translations$exercise$editor$fields$rpe$levels$4$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 5';
	@override String get text => 'Sforzo moderato.';
}

// Path: exercise.editor.fields.rpe.levels.5
class Translations$exercise$editor$fields$rpe$levels$5$it implements Translations$exercise$editor$fields$rpe$levels$5$en {
	Translations$exercise$editor$fields$rpe$levels$5$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 6';
	@override String get text => 'Sforzo moderatamente elevato.';
}

// Path: exercise.editor.fields.rpe.levels.6
class Translations$exercise$editor$fields$rpe$levels$6$it implements Translations$exercise$editor$fields$rpe$levels$6$en {
	Translations$exercise$editor$fields$rpe$levels$6$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 7';
	@override String get text => 'Sforzo elevato.';
}

// Path: exercise.editor.fields.rpe.levels.7
class Translations$exercise$editor$fields$rpe$levels$7$it implements Translations$exercise$editor$fields$rpe$levels$7$en {
	Translations$exercise$editor$fields$rpe$levels$7$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 8';
	@override String get text => 'Sforzo elevato. Puoi effettuare al massimo 2 ripetizioni in più.';
}

// Path: exercise.editor.fields.rpe.levels.8
class Translations$exercise$editor$fields$rpe$levels$8$it implements Translations$exercise$editor$fields$rpe$levels$8$en {
	Translations$exercise$editor$fields$rpe$levels$8$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 9';
	@override String get text => 'Sforzo molto elevato. Puoi effettuare al massimo un\'altra ripetizione.';
}

// Path: exercise.editor.fields.rpe.levels.9
class Translations$exercise$editor$fields$rpe$levels$9$it implements Translations$exercise$editor$fields$rpe$levels$9$en {
	Translations$exercise$editor$fields$rpe$levels$9$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'RPE 10';
	@override String get text => 'Sforzo massimo. Non puoi effettuare altre ripetizioni.';
}

// Path: exercise.editor.fields.gymEquipment.errors
class Translations$exercise$editor$fields$gymEquipment$errors$it implements Translations$exercise$editor$fields$gymEquipment$errors$en {
	Translations$exercise$editor$fields$gymEquipment$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Seleziona attrezzatura';
}

// Path: workouts.actions.share.alert.actions
class Translations$workouts$actions$share$alert$actions$it implements Translations$workouts$actions$share$alert$actions$en {
	Translations$workouts$actions$share$alert$actions$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Chiudi';
	@override String get share => 'Copia';
	@override String get shareQR => 'Condividi QR';
	@override String get shared => 'Il link è stato copiato.';
}

// Path: routines.editor.fields.name.errors
class Translations$routines$editor$fields$name$errors$it implements Translations$routines$editor$fields$name$errors$en {
	Translations$routines$editor$fields$name$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Il nome non dev\'essere vuoto.';
}

// Path: settings.options.import.utils.hevy
class Translations$settings$options$import$utils$hevy$it implements Translations$settings$options$import$utils$hevy$en {
	Translations$settings$options$import$utils$hevy$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Importato da Hevy';
	@override String get titles => '(Importato da Hevy)';
}

// Path: settings.advanced.options.backups.restore
class Translations$settings$advanced$options$backups$restore$it implements Translations$settings$advanced$options$backups$restore$en {
	Translations$settings$advanced$options$backups$restore$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ripristinare questo backup?';
	@override String get confirm => 'Non potrai annullare quest\'azione. Assicurati di creare un backup ora se vuoi tornare indietro. Ripristinare?';
}

// Path: settings.advanced.options.backups.delete
class Translations$settings$advanced$options$backups$delete$it implements Translations$settings$advanced$options$backups$delete$en {
	Translations$settings$advanced$options$backups$delete$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Eliminare questo backup?';
	@override String get confirm => 'Non potrai annullare questa azione.';
}

// Path: settings.advanced.options.sync.status
class Translations$settings$advanced$options$sync$status$it implements Translations$settings$advanced$options$sync$status$en {
	Translations$settings$advanced$options$sync$status$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get syncing => 'Sincronizzazione in corso...';
	@override String get notSyncing => 'Sincronizzazione terminata';
	@override String get failed => 'Sincronizzazione non riuscita';
}

// Path: settings.advanced.deleteAccount.confirmation.error
class Translations$settings$advanced$deleteAccount$confirmation$error$it implements Translations$settings$advanced$deleteAccount$confirmation$error$en {
	Translations$settings$advanced$deleteAccount$confirmation$error$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get mismatch => 'Digita il tuo username.';
}

// Path: ongoingWorkout.finish.fields.name.errors
class Translations$ongoingWorkout$finish$fields$name$errors$it implements Translations$ongoingWorkout$finish$fields$name$errors$en {
	Translations$ongoingWorkout$finish$fields$name$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Il nome non dev\'essere vuoto.';
}

// Path: ongoingWorkout.finish.fields.parent.options
class Translations$ongoingWorkout$finish$fields$parent$options$it implements Translations$ongoingWorkout$finish$fields$parent$options$en {
	Translations$ongoingWorkout$finish$fields$parent$options$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get none => 'Nessuna routine';
}

// Path: ongoingWorkout.finish.fields.duration.errors
class Translations$ongoingWorkout$finish$fields$duration$errors$it implements Translations$ongoingWorkout$finish$fields$duration$errors$en {
	Translations$ongoingWorkout$finish$fields$duration$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'La durata non dev\'essere zero.';
}

// Path: historyEditor.finish.fields.name.errors
class Translations$historyEditor$finish$fields$name$errors$it implements Translations$historyEditor$finish$fields$name$errors$en {
	Translations$historyEditor$finish$fields$name$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Il nome non dev\'essere vuoto.';
}

// Path: historyEditor.finish.fields.parent.options
class Translations$historyEditor$finish$fields$parent$options$it implements Translations$historyEditor$finish$fields$parent$options$en {
	Translations$historyEditor$finish$fields$parent$options$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get none => 'Nessuna routine';
}

// Path: historyEditor.finish.fields.duration.errors
class Translations$historyEditor$finish$fields$duration$errors$it implements Translations$historyEditor$finish$fields$duration$errors$en {
	Translations$historyEditor$finish$fields$duration$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'La durata non dev\'essere zero.';
}

// Path: food.categoryEditor.fields.name.errors
class Translations$food$categoryEditor$fields$name$errors$it implements Translations$food$categoryEditor$fields$name$errors$en {
	Translations$food$categoryEditor$fields$name$errors$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Il nome non può essere vuoto.';
	@override String get unique => 'C\'è già una categoria con questo nome.';
}

/// The flat map containing all translations for locale <it>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsIt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'Gym Bro',
			'navigation.feed' => 'Feed',
			'navigation.profile' => 'Profilo',
			'navigation.food' => 'Diario',
			'navigation.workouts' => 'Allenati',
			'navigation.pro' => 'PRO',
			'navigation.settings' => 'Impostazioni',
			'appInfo.version' => ({required Object version, required Object build}) => 'Versione ${version} (build ${build})',
			'appInfo.shortDescription' => 'Compagno di allenamenti',
			'appInfo.terms' => 'Termini di servizio',
			'appInfo.privacy' => 'Informativa sulla privacy',
			'set.kind' => 'Tipo serie',
			'set.kindShort.warmUp' => 'R',
			'set.kindShort.drop' => 'D',
			'set.kindShort.failure' => 'C',
			'set.kindShort.failureStripping' => 'S',
			'set.kindLong.normal' => 'Serie normale',
			'set.kindLong.warmUp' => 'Riscaldamento',
			'set.kindLong.drop' => 'Drop set',
			'set.kindLong.failure' => 'A cedimento',
			'set.kindLong.failureStripping' => 'A cedimento con stripping',
			'set.kinds.help.title' => 'Cosa significa?',
			'set.kinds.help.warmUp' => 'Una serie di riscaldamento è una serie leggera di un esercizio che esegui prima delle serie di lavoro effettive. Il suo scopo è preparare i muscoli per il lavoro pesante imminente.',
			'set.kinds.help.normal' => 'Una serie normale è una serie regolare di un esercizio, in cui esegui un certo numero di ripetizioni con un certo peso.',
			'set.kinds.help.drop' => 'Una serie di drop ("Drop set") è una serie in cui abbassi il peso dopo aver raggiunto il cedimento muscolare e continui a eseguire ripetizioni con il peso inferiore.',
			'set.kinds.help.failure' => 'Una serie a cedimento è una serie in cui esegui ripetizioni fino a raggiungere il cedimento muscolare.',
			'set.kinds.help.failureStripping' => 'Una serie a cedimento con stripping è una serie a cedimento che parte immediatamente dalla serie precedente (quindi senza recupero), in cui esegui ripetizioni fino a raggiungere il cedimento muscolare.',
			'exercise.chart.views.volume' => 'Volume',
			'exercise.chart.views.reps' => 'Ripetizioni',
			'exercise.chart.views.duration' => 'Durata allenamento',
			'exercise.chart.views.time' => 'Tempo',
			'exercise.chart.views.distance' => 'Distanza',
			'exercise.chart.views.exertion' => 'Tasso di esercizio',
			'exercise.chart.views.exertionInfo' => 'Il tasso di esercizio stima l\'intensità di un allenamento calcolando la media del peso sollevato e della durata dell\'allenamento.',
			'exercise.fields.restTime' => 'Recupero',
			'exercise.fields.weight' => 'Peso',
			'exercise.fields.time' => 'Tempo',
			'exercise.fields.reps' => 'Ripetizioni',
			'exercise.fields.distance' => 'Distanza',
			'exercise.actions.addSet' => '+ Aggiungi serie',
			'exercise.editor.create.title' => 'Crea esercizio',
			'exercise.editor.edit.title' => 'Modifica esercizio',
			'exercise.editor.fields.title.label' => 'Nome esercizio',
			'exercise.editor.fields.title.errors.empty' => 'Il nome non dev\'essere vuoto.',
			'exercise.editor.fields.title.errors.invalid' => 'Un esercizio con questo nome esiste già.',
			'exercise.editor.fields.parameters.label' => 'Parametri',
			'exercise.editor.fields.parameters.values.repsNegWeight' => 'Peso negativo e ripetizioni',
			'exercise.editor.fields.parameters.values.repsWeight' => 'Peso e ripetizioni',
			'exercise.editor.fields.parameters.values.timeWeight' => 'Peso e tempo',
			'exercise.editor.fields.parameters.values.time' => 'Tempo',
			'exercise.editor.fields.parameters.values.freeBodyReps' => 'Ripetizioni',
			'exercise.editor.fields.parameters.values.distance' => 'Distanza',
			'exercise.editor.fields.parameters.errors.empty' => 'Seleziona i parametri di questo esercizio',
			'exercise.editor.fields.primaryMuscleGroup.label' => 'Gruppo muscolare primario',
			'exercise.editor.fields.primaryMuscleGroup.errors.empty' => 'Devi selezionare un gruppo muscolare.',
			'exercise.editor.fields.secondaryMuscleGroups.label' => 'Gruppi muscolari secondari',
			'exercise.editor.fields.notes.label' => 'Note',
			'exercise.editor.fields.notes.tapToEdit' => 'Tocca per inserire note',
			'exercise.editor.fields.rpe.removeRPE' => 'Rimuovi RPE',
			'exercise.editor.fields.rpe.label' => 'Imposta RPE',
			'exercise.editor.fields.rpe.description.title' => 'Cos\'è l\'RPE?',
			'exercise.editor.fields.rpe.description.text' => 'L\'RPE (Rate of Perceived Exertion, tasso di sforzo percepito) è una misurazione soggettiva della difficoltà di un esercizio. Si misura da 1 a 10, dove 1 sta per "sforzo molto basso" e 10 sta per "sforzo massimo". Si può misurare in base alla stima delle ripetizioni rimanenti al termine di una serie (ad esempio, RPE 8 significa che potresti fare altre 2 ripetizioni prima di cedere).',
			'exercise.editor.fields.rpe.levels.0.title' => 'RPE 1',
			'exercise.editor.fields.rpe.levels.0.text' => 'Sforzo molto basso.',
			'exercise.editor.fields.rpe.levels.1.title' => 'RPE 2',
			'exercise.editor.fields.rpe.levels.1.text' => 'Sforzo basso.',
			'exercise.editor.fields.rpe.levels.2.title' => 'RPE 3',
			'exercise.editor.fields.rpe.levels.2.text' => 'Sforzo basso.',
			'exercise.editor.fields.rpe.levels.3.title' => 'RPE 4',
			'exercise.editor.fields.rpe.levels.3.text' => 'Sforzo moderato.',
			'exercise.editor.fields.rpe.levels.4.title' => 'RPE 5',
			'exercise.editor.fields.rpe.levels.4.text' => 'Sforzo moderato.',
			'exercise.editor.fields.rpe.levels.5.title' => 'RPE 6',
			'exercise.editor.fields.rpe.levels.5.text' => 'Sforzo moderatamente elevato.',
			'exercise.editor.fields.rpe.levels.6.title' => 'RPE 7',
			'exercise.editor.fields.rpe.levels.6.text' => 'Sforzo elevato.',
			'exercise.editor.fields.rpe.levels.7.title' => 'RPE 8',
			'exercise.editor.fields.rpe.levels.7.text' => 'Sforzo elevato. Puoi effettuare al massimo 2 ripetizioni in più.',
			'exercise.editor.fields.rpe.levels.8.title' => 'RPE 9',
			'exercise.editor.fields.rpe.levels.8.text' => 'Sforzo molto elevato. Puoi effettuare al massimo un\'altra ripetizione.',
			'exercise.editor.fields.rpe.levels.9.title' => 'RPE 10',
			'exercise.editor.fields.rpe.levels.9.text' => 'Sforzo massimo. Non puoi effettuare altre ripetizioni.',
			'exercise.editor.fields.reorderSets.title' => 'Riordina serie',
			'exercise.editor.fields.reorderSets.text' => 'Trascina le maniglie per riordinare le serie',
			'exercise.editor.fields.gymEquipment.errors.empty' => 'Seleziona attrezzatura',
			'exercise.editor.fields.gymEquipment.label' => 'Attrezzatura',
			'exercise.editor.cannotChangeParameters.title' => 'Non puoi cambiare i parametri di questo esercizio',
			'exercise.editor.cannotChangeParameters.text' => 'Puoi cambiare i parametri solo degli esercizi che non hai ancora eseguito.',
			'exercise.editor.setless.title' => 'Non puoi cambiare i parametri di questo esercizio',
			'exercise.editor.setless.text' => 'Disabilita l\'opzione "Senza serie" per modificare questo campo.',
			'exercise.editor.overwriteInWorkout.title' => 'Questo esercizio fa parte del tuo allenamento in corso',
			'exercise.editor.overwriteInWorkout.body' => 'Puoi modificarlo, ma se cambi i parametri dovrai riempire nuovamente i valori. Vuoi continuare?',
			'exercise.editor.advanced.setless.text' => 'Disabilita la funzionalità delle serie. Questa opzione rende l\'esercizio un segnaposto nei tuoi allenamenti.',
			'exercise.editor.advanced.setless.title' => 'Senza serie',
			'exercise.editor.advanced.title' => 'Avanzate',
			'exercise.picker.title' => 'Seleziona esercizi',
			'exercise.picker.errors.empty' => 'Devi selezionare un esercizio.',
			'exercise.picker.filter.equipment' => 'Attrezzatura',
			'exercise.custom' => 'Personalizzato',
			'exercise.info.title' => 'Info esercizio',
			'exercise.info.viewWorkout' => 'Vedi allenamento',
			'exercise.info.noHistory' => 'Non ci sono allenamenti per questo esercizio.',
			'exercise.info.heaviestWeight.label' => 'Peso massimo',
			'exercise.info.best1rm.label' => 'Miglior massimale',
			'exercise.info.bestSetVolume.label' => 'Miglior volume di una serie',
			'exercise.info.bestSessionVolume.label' => 'Miglior volume totale di una sessione',
			'exercise.info.usefulData' => 'Dati utili',
			'exercise.info.home' => 'Home',
			'exercise.info.history' => 'Cronologia',
			'exercise.info.explanation' => 'Spiegazione',
			'exercise.info.explanationDisclaimer' => 'Nota che questa spiegazione è fornita a puro scopo informativo, e non sostituisce il parere di un trainer qualificato.',
			'exercise.info.primaryMuscleGroup' => ({required Object muscleGroup}) => 'Gruppo muscolare: ${muscleGroup}',
			'exercise.info.secondaryMuscleGroups' => ({required Object muscleGroups}) => 'Gruppi muscolari secondari: ${muscleGroups}',
			'exercise.info.equipment' => ({required Object equipment}) => 'Attrezzatura: ${equipment}',
			'exercise.info.explanationNone.title' => 'Nessuna spiegazione disponibile',
			'exercise.info.explanationNone.description' => 'Non c\'è ancora una spiegazione per questo esercizio. Controlla più tardi.',
			'exercise.continuation.label' => 'Continuazione',
			'exercise.continuation.description' => 'Tocca per unire i due allenamenti in un\'unica voce.',
			'exercise.continuation.combine.confirm.title' => 'Unisci allenamenti',
			'exercise.continuation.combine.confirm.body' => 'Vuoi davvero unire questi due allenamenti? Quest\'azione non può essere annullata. Inoltre, i vecchi allenamenti non saranno più disponibili.',
			'exercise.delete.title' => 'Elimina esercizio',
			'exercise.delete.body' => 'Vuoi davvero eliminare questo esercizio? Quest\'azione non può essere annullata.',
			'workouts.untitled' => 'Allenamento senza nome',
			'workouts.title' => 'Allenamenti',
			'workouts.actions.delete.title' => 'Elimina allenamento',
			'workouts.actions.delete.text' => 'Vuoi davvero eliminare questo allenamento? Quest\'azione non può essere annullata.',
			'workouts.actions.delete.actions.no' => 'Annulla',
			'workouts.actions.delete.actions.yes' => 'Elimina',
			'workouts.actions.delete.done' => 'L\'allenamento è stato eliminato.',
			'workouts.actions.start' => 'Ripeti allenamento',
			'workouts.actions.edit.label' => 'Modifica allenamento',
			'workouts.actions.editContinuation.label' => 'Modifica continuazione',
			'workouts.actions.rename.label' => 'Rinomina allenamento',
			'workouts.actions.rename.errors.empty' => 'Il nome non dev\'essere vuoto.',
			'workouts.actions.changeParent.label' => 'Cambia routine di base',
			'workouts.actions.changeParent.options.none' => 'Nessuna',
			'workouts.actions.saveAsRoutine.button' => 'Salva come routine',
			'workouts.actions.saveAsRoutine.done' => 'Allenamento salvato come routine',
			'workouts.actions.kContinue' => 'Continua quest\'allenamento',
			'workouts.actions.share.button' => 'Condividi questa routine',
			'workouts.actions.share.alert.title' => 'Link generato',
			'workouts.actions.share.alert.body' => 'Un link univoco è stato generato. Tocca il pulsante per copiarlo, poi invia il link per condividere questa routine.',
			'workouts.actions.share.alert.actions.close' => 'Chiudi',
			'workouts.actions.share.alert.actions.share' => 'Copia',
			'workouts.actions.share.alert.actions.shareQR' => 'Condividi QR',
			'workouts.actions.share.alert.actions.shared' => 'Il link è stato copiato.',
			'workouts.actions.share.alert.noQr' => 'Impossibile generare codice QR: routine troppo grande. Usa il link in basso per condividere la tua routine.',
			'routines.title' => 'Routine',
			'routines.newRoutine' => 'Nuova routine',
			'routines.quickWorkout.title' => 'Allenamento libero',
			'routines.quickWorkout.subtitle' => 'Inizia senza una routine',
			'routines.quickWorkout.proLimit' => 'Hai raggiunto il limite gratuito di allenamenti. Continua con PRO.',
			'routines.actions.delete.title' => 'Elimina routine',
			'routines.actions.delete.text' => 'Vuoi davvero eliminare questa routine? Quest\'azione non può essere annullata.',
			'routines.actions.delete.actions.no' => 'Annulla',
			'routines.actions.delete.actions.yes' => 'Elimina',
			'routines.actions.delete.done' => 'La routine è stata eliminata.',
			'routines.actions.edit' => 'Modifica routine',
			'routines.actions.start' => 'Avvia routine',
			'routines.actions.create' => 'Crea routine',
			'routines.actions.viewHistory' => 'Cronologia',
			'routines.actions.deleteFolder.title' => 'Elimina cartella',
			'routines.actions.deleteFolder.text' => 'Vuoi davvero eliminare questa cartella? Quest\'azione non potrà essere annullata. Le routine in questa cartella verranno spostate nella schermata principale.',
			'routines.editor.exercises.title' => 'Esercizi',
			'routines.editor.exercises.add' => 'Aggiungi esercizi',
			'routines.editor.fields.name.label' => 'Nome della routine',
			'routines.editor.fields.name.errors.empty' => 'Il nome non dev\'essere vuoto.',
			'routines.editor.fields.infobox.label' => 'Note',
			'routines.editor.superset.title' => 'Superserie',
			'routines.editor.superset.add' => 'Aggiungi superserie',
			'routines.editor.superset.subtitle' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Superserie senza esercizi', one: 'Superserie con un esercizio', two: 'Superserie con ${n} esercizi', few: 'Superserie con ${n} esercizi', many: 'Superserie con ${n} esercizi', other: 'Superserie con ${n} esercizi', ),
			'routines.editor.superset.addExercise' => 'Aggiungi esercizi',
			'routines.editor.superset.remove.title' => 'Rimuovi superserie',
			'routines.editor.superset.remove.body' => 'Vuoi davvero rimuovere questa superserie? Quest\'azione non può essere annullata.',
			'routines.newFolder' => 'Nuova cartella',
			'routines.folderNameEmpty' => 'Il nome non dev\'essere vuoto.',
			'routines.folderName' => 'Nome',
			'routines.editFolder' => 'Modifica cartella',
			'routines.dropHere' => 'Rilascia qui',
			'routines.moveToRoot' => 'Rilascia la routine qui per muoverla nella schermata principale.',
			'routines.none' => 'Nessuna routine',
			'routines.pick' => 'Seleziona routine',
			'routines.rootFolder' => 'Home',
			'routines.emptyFolder' => 'Questa cartella è vuota',
			'routines.emptyFolderSubtitle' => 'Tieni premuto e trascina una routine dalla pagina Home per aggiungerla a questa cartella.',
			'routines.folder' => 'Cartella',
			'routines.nullFolder' => 'Cartella eliminata',
			'routines.nullFolderSubtitle' => 'Puoi tornare alla pagina Home.',
			'routines.folderNotes' => 'Note',
			'routines.loadError.title' => 'Impossibile caricare le routine',
			'routines.loadError.text' => 'Riprova per caricare le routine e le cartelle.',
			'history.title' => 'Cronologia',
			'history.empty' => 'Nessun allenamento',
			'history.andMore' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: '…e un altro', two: '…e altri ${n}', few: '…e altri ${n}', many: '…e altri ${n}', other: '…e altri ${n}', ),
			'history.actions.deleteMultiple.title' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: 'Rimuovi esercizio', two: 'Rimuovi ${n} esercizi', few: 'Rimuovi ${n} esercizi', many: 'Rimuovi ${n} esercizi', other: 'Rimuovi ${n} esercizi', ),
			'history.actions.deleteMultiple.text' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: 'Sei sicuro di voler eliminare questo esercizio dalla tua cronologia? Quest\'azione non può essere annullata.', two: 'Sei sicuro di voler eliminare questi esercizi dalla tua cronologia? Quest\'azione non può essere annullata.', few: 'Sei sicuro di voler eliminare questi esercizi dalla tua cronologia? Quest\'azione non può essere annullata.', many: 'Sei sicuro di voler eliminare questi esercizi dalla tua cronologia? Quest\'azione non può essere annullata.', other: 'Sei sicuro di voler eliminare questi esercizi dalla tua cronologia? Quest\'azione non può essere annullata.', ),
			'history.actions.deleteMultiple.actions.no' => 'Annulla',
			'history.actions.deleteMultiple.actions.yes' => 'Elimina',
			'history.actions.deleteMultiple.done' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: 'L\'esercizio è stato eliminato dalla tua cronologia.', two: 'Gli esercizi sono stati eliminati dalla tua cronologia.', few: 'Gli esercizi sono stati eliminati dalla tua cronologia.', many: 'Gli esercizi sono stati eliminati dalla tua cronologia.', other: 'Gli esercizi sono stati eliminati dalla tua cronologia.', ),
			'history.showAll' => 'Mostra tutto',
			'history.search' => 'Cerca allenamenti',
			'settings.title' => 'Impostazioni',
			'settings.options.useDynamicColor.label' => 'Usa colore dinamico',
			'settings.options.color.label' => 'Colore dell\'applicazione',
			'settings.options.locale.label' => 'Lingua dell\'applicazione',
			'settings.options.locale.values.system' => 'Sistema',
			'settings.options.weightUnit.label' => 'Unità di peso',
			'settings.options.distanceUnit.label' => 'Unità di distanza',
			'settings.options.showSuggestedRoutines.label' => 'Mostra routine suggerite',
			'settings.options.import.label' => 'Importa dati',
			'settings.options.import.success' => 'Dati importati con successo',
			'settings.options.import.failed.title' => 'Impossibile importare i dati',
			'settings.options.import.failed.copy' => 'Il messaggio di errore è stato copiato negli appunti.',
			'settings.options.import.utils.hevy.notes' => 'Importato da Hevy',
			'settings.options.import.utils.hevy.titles' => '(Importato da Hevy)',
			'settings.options.import.types.gt' => 'Gym Bro (JSON)',
			'settings.options.import.types.hevy' => 'Hevy (CSV)',
			'settings.options.themeMode.label' => 'Tema',
			'settings.options.themeMode.values.system' => 'Sistema',
			'settings.options.themeMode.values.light' => 'Chiaro',
			'settings.options.themeMode.values.dark' => 'Scuro',
			'settings.options.export.label' => 'Esporta dati (JSON)',
			'settings.options.export.filename' => 'Dati_GymBro',
			'settings.options.export.failed.title' => 'Impossibile esportare i dati',
			'settings.options.export.failed.copy' => 'Il messaggio di errore è stato copiato negli appunti.',
			'settings.options.notifications.label' => 'Stato notifiche',
			'settings.options.notifications.subtitle.noExactAlarmPermission' => 'Tocca per richiedere il permesso "Promemoria e avvisi" (Android 14+)',
			'settings.options.tintExercises.label' => 'Colora pagine degli esercizi',
			'settings.options.tintExercises.subtitle' => 'Applica alle pagine degli esercizi il colore della categoria di appartenenza',
			'settings.options.defaultToSimpleWorkoutView.label' => 'Usa la vista semplificata dell\'allenamento come predefinita',
			'settings.options.defaultToSimpleWorkoutView.subtitle' => 'Apri la schermata compatta quando avvii o riprendi un allenamento',
			'settings.options.exportSQL.text' => 'Esporta il file del database di Gym Bro. Non potrai reimportarlo (ma i dati non saranno cancellati).',
			'settings.options.exportSQL.label' => 'Esporta database completo (SQL)',
			'settings.options.nutritionLanguage' => 'Lingua di ricerca alimenti',
			'settings.options.nutritionCountry' => 'Paese di ricerca alimenti',
			'settings.options.health.label' => 'Salute e parametri vitali',
			'settings.colorPicker.heading.label' => ({required Object color}) => 'Seleziona un colore [${color}]',
			'settings.advanced.title' => 'Impostazioni avanzate',
			'settings.advanced.subtitle' => 'Lasciate ogni speranza, o voi ch\'entrate',
			'settings.advanced.options.logs.title' => 'Log',
			'settings.advanced.options.logs.levels.trace' => 'Tutti i log',
			'settings.advanced.options.logs.levels.debug' => 'Debug',
			'settings.advanced.options.logs.levels.info' => 'Info',
			'settings.advanced.options.logs.levels.warning' => 'Avviso',
			'settings.advanced.options.logs.levels.error' => 'Errore',
			'settings.advanced.options.logs.levels.fatal' => 'Errore fatale',
			'settings.advanced.options.logs.level' => 'Livello',
			'settings.advanced.options.migrations.title' => 'Migrazioni',
			'settings.advanced.options.backups.title' => 'Backup',
			'settings.advanced.options.backups.restore.title' => 'Ripristinare questo backup?',
			'settings.advanced.options.backups.restore.confirm' => 'Non potrai annullare quest\'azione. Assicurati di creare un backup ora se vuoi tornare indietro. Ripristinare?',
			'settings.advanced.options.backups.restoring' => 'Ripristino',
			'settings.advanced.options.backups.creating' => 'Creazione backup',
			'settings.advanced.options.backups.delete.title' => 'Eliminare questo backup?',
			'settings.advanced.options.backups.delete.confirm' => 'Non potrai annullare questa azione.',
			'settings.advanced.options.backups.deleting' => 'Eliminazione',
			'settings.advanced.options.backups.create' => 'Crea backup',
			'settings.advanced.options.sync.title' => 'Stato sincronizzazione',
			'settings.advanced.options.sync.status.syncing' => 'Sincronizzazione in corso...',
			'settings.advanced.options.sync.status.notSyncing' => 'Sincronizzazione terminata',
			'settings.advanced.options.sync.status.failed' => 'Sincronizzazione non riuscita',
			'settings.advanced.options.sync.lastSync' => ({required Object date}) => 'Ultima sincronizzazione: ${date}',
			'settings.advanced.options.sync.never' => 'Mai sincronizzato',
			'settings.advanced.options.sync.notLoggedIn' => 'Non hai effettuato l\'accesso',
			'settings.advanced.options.sync.syncNow' => 'Sincronizza ora',
			'settings.advanced.options.sync.rateLimited' => 'Attendi un minuto prima di sincronizzare di nuovo',
			'settings.advanced.deleteAccount.title' => 'Elimina il tuo account',
			'settings.advanced.deleteAccount.warning.title' => 'Vuoi eliminare definitivamente l\'account?',
			'settings.advanced.deleteAccount.warning.content' => 'Perderai immediatamente tutti i tuoi dati. Non potrai annullare questa operazione. Sei sicuro di voler continuare?',
			'settings.advanced.deleteAccount.confirmation.title' => 'Conferma eliminazione',
			'settings.advanced.deleteAccount.confirmation.content' => ({required Object username}) => 'Digita il tuo username (${username}) per procedere.',
			'settings.advanced.deleteAccount.confirmation.hint' => 'Username',
			'settings.advanced.deleteAccount.confirmation.error.mismatch' => 'Digita il tuo username.',
			'settings.advanced.deleteAccount.deleting' => 'Eliminazione in corso...',
			'settings.panes.appearance' => 'Aspetto',
			'settings.panes.units' => 'Unità',
			'settings.panes.permissions' => 'Autorizzazioni',
			'settings.panes.off' => 'OpenFoodFacts',
			'settings.permissions.tapToRequest' => 'Tocca per richiedere l\'autorizzazione',
			'settings.pro.title' => 'Gestisci il tuo abbonamento',
			'settings.logout' => 'Esci',
			'settings.logoutWarning.title' => 'Vuoi uscire?',
			'settings.logoutWarning.content' => 'Potrai rientrare dalla scheda Profilo.',
			'ongoingWorkout.title' => 'Allenamento',
			'ongoingWorkout.actions.finish' => 'Termina allenamento',
			'ongoingWorkout.actions.cancel' => 'Scarta allenamento',
			'ongoingWorkout.actions.short.cancel' => 'Annulla',
			'ongoingWorkout.actions.short.resume' => 'Riprendi',
			'ongoingWorkout.actions.changeWeightUnit' => 'Cambia unità di peso',
			'ongoingWorkout.actions.changeDistanceUnit' => 'Cambia unità di distanza',
			'ongoingWorkout.exercises.add' => '+ Aggiungi esercizio',
			'ongoingWorkout.exercises.addSuperset' => '+ Aggiungi superserie',
			'ongoingWorkout.exercises.replace' => 'Cambia esercizio…',
			'ongoingWorkout.exercises.reorder' => 'Riordina esercizi…',
			'ongoingWorkout.exercises.reorderSets' => 'Riordina serie…',
			'ongoingWorkout.exercises.remove' => 'Rimuovi esercizio',
			'ongoingWorkout.exercises.addToSuperset' => 'Aggiungi a superserie…',
			'ongoingWorkout.exercises.startCardioTimer' => 'Avvia timer a intervalli',
			'ongoingWorkout.exercises.rpeBadge' => ({required Object rpe}) => 'RPE ${rpe}',
			'ongoingWorkout.exercises.setRPE' => 'Imposta RPE',
			'ongoingWorkout.exercises.generate' => 'Genera',
			'ongoingWorkout.info.time' => 'Tempo',
			'ongoingWorkout.info.reps' => 'Ripetizioni',
			'ongoingWorkout.info.volume' => 'Volume sollevato',
			'ongoingWorkout.info.heartRate' => 'BPM',
			'ongoingWorkout.info.activeEnergy' => 'KCAL',
			'ongoingWorkout.finish.title' => 'Termina allenamento',
			'ongoingWorkout.finish.fields.name.label' => 'Nome allenamento',
			'ongoingWorkout.finish.fields.name.errors.empty' => 'Il nome non dev\'essere vuoto.',
			'ongoingWorkout.finish.fields.startingTime.label' => 'Data di avvio',
			'ongoingWorkout.finish.fields.parent.label' => 'Routine di riferimento',
			'ongoingWorkout.finish.fields.parent.options.none' => 'Nessuna routine',
			'ongoingWorkout.finish.fields.parent.help' => 'Associa questo allenamento a una routine. Le eventuali modifiche alla routine ti saranno chieste dopo il salvataggio.',
			'ongoingWorkout.finish.fields.duration.label' => 'Durata',
			'ongoingWorkout.finish.fields.duration.errors.empty' => 'La durata non dev\'essere zero.',
			'ongoingWorkout.finish.fields.infobox.label' => 'Note',
			'ongoingWorkout.finish.save' => 'Salva allenamento',
			'ongoingWorkout.finish.saving' => 'Salvataggio…',
			'ongoingWorkout.finish.saveError' => 'Impossibile salvare l’allenamento. Riprova: le modifiche sono ancora qui.',
			'ongoingWorkout.finish.discard.title' => 'Scartare le modifiche?',
			'ongoingWorkout.finish.discard.text' => 'Le modifiche al riepilogo verranno scartate. L’allenamento rimarrà in corso.',
			'ongoingWorkout.finish.discard.keep' => 'Continua a modificare',
			'ongoingWorkout.finish.discard.confirm' => 'Scarta modifiche',
			'ongoingWorkout.cancel.title' => 'Scartare l\'allenamento?',
			'ongoingWorkout.cancel.text' => 'Non potrai annullare quest\'azione se cambi idea.',
			'ongoingWorkout.cancel.actions.no' => 'Annulla',
			'ongoingWorkout.cancel.actions.yes' => 'Scarta',
			'ongoingWorkout.overwrite.title' => 'Avviare l\'allenamento?',
			'ongoingWorkout.overwrite.text' => 'L\'allenamento in corso sarà sovrascritto.',
			'ongoingWorkout.overwrite.actions.no' => 'Annulla',
			'ongoingWorkout.overwrite.actions.yes' => 'Avvia',
			'ongoingWorkout.restOver' => 'È scaduto il tempo di recupero!',
			'ongoingWorkout.weightCalculator' => 'Calcolatrice pesi',
			'ongoingWorkout.superset.replaceWithExercise' => 'Cambia con esercizio',
			'ongoingWorkout.superset.remove' => 'Rimuovi superserie',
			'ongoingWorkout.stopwatch.label' => 'Cronometro',
			'ongoingWorkout.stopwatch.start' => 'Avvia',
			'ongoingWorkout.stopwatch.pause' => 'Pausa',
			'ongoingWorkout.stopwatch.reset' => 'Resetta',
			'ongoingWorkout.simple.completedTitle' => 'Allenamento completato',
			'ongoingWorkout.simple.completedDescription' => 'Hai completato tutte le serie. Salva il tuo allenamento o aggiungi un esercizio.',
			'ongoingWorkout.simple.emptyTitle' => 'Pronto ad allenarti?',
			'ongoingWorkout.simple.emptyDescription' => 'Aggiungi un esercizio per iniziare la tua sessione.',
			'ongoingWorkout.simple.exercisePosition' => ({required Object current, required Object total}) => '${current} di ${total}',
			'ongoingWorkout.simple.setPosition' => ({required Object current, required Object total}) => 'Serie ${current} di ${total}',
			'ongoingWorkout.simple.customExercise' => 'Personalizzato',
			'ongoingWorkout.simple.completeSet' => 'Completa serie',
			'ongoingWorkout.simple.repUnit' => 'rep',
			'ongoingWorkout.simple.decreaseValue' => ({required Object field}) => 'Diminuisci ${field}',
			'ongoingWorkout.simple.increaseValue' => ({required Object field}) => 'Aumenta ${field}',
			'ongoingWorkout.simple.historyAndProgression' => 'Storico e progressione',
			'ongoingWorkout.simple.historySummary' => 'Consulta l’ultima sessione e gli obiettivi',
			'ongoingWorkout.simple.progressionSummary' => 'Progressione attiva · consulta gli obiettivi',
			'ongoingWorkout.simple.nextUp' => 'Prossimo:',
			'ongoingWorkout.simple.switchToFull' => 'Passa alla vista completa',
			'ongoingWorkout.simple.restTimer' => 'Avvia timer di recupero',
			'ongoingWorkout.simple.setControls' => 'Controlli serie',
			'ongoingWorkout.simple.previousSet' => 'Serie precedente',
			'ongoingWorkout.simple.nextSet' => 'Serie successiva',
			'ongoingWorkout.simple.setKind' => 'Tipo di serie',
			'ongoingWorkout.simple.editSet' => 'Modifica parametri serie',
			'ongoingWorkout.simple.supersetNotes' => 'Note superserie',
			'ongoingWorkout.simple.markAsDone' => 'Segna serie come completata',
			'ongoingWorkout.simple.markAsUndone' => 'Segna serie come non completata',
			'ongoingWorkout.toolbox.title' => 'Strumenti',
			'ongoingWorkout.updateRoutine.differenceTitle' => 'Aggiorna routine',
			'ongoingWorkout.updateRoutine.differenceText' => 'Hai modificato l\'allenamento. Vuoi aggiornare la routine di base?',
			'ongoingWorkout.updateRoutine.differences.added' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Nessun esercizio aggiunto', one: '1 esercizio aggiunto', two: '${n} esercizi aggiunti', few: '${n} esercizi aggiunti', many: '${n} esercizi aggiunti', other: '${n} esercizi aggiunti', ),
			'ongoingWorkout.updateRoutine.differences.removed' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Nessun esercizio rimosso', one: '1 esercizio rimosso', two: '${n} esercizi rimossi', few: '${n} esercizi rimossi', many: '${n} esercizi rimossi', other: '${n} esercizi rimossi', ),
			'ongoingWorkout.updateRoutine.differences.changed' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Nessun esercizio modificato', one: '1 esercizio modificato', two: '${n} esercizi modificati', few: '${n} esercizi modificati', many: '${n} esercizi modificati', other: '${n} esercizi modificati', ),
			'ongoingWorkout.updateRoutine.differences.reordered' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Nessun esercizio riordinato', one: '1 esercizio riordinato', two: '${n} esercizi riordinati', few: '${n} esercizi riordinati', many: '${n} esercizi riordinati', other: '${n} esercizi riordinati', ),
			'ongoingWorkout.updateRoutine.differences.metadata' => 'Nome o note della routine modificati',
			'ongoingWorkout.goodJob.title' => 'Ottimo lavoro!',
			'ongoingWorkout.goodJob.body' => 'Ecco delle statistiche sull\'allenamento appena terminato.',
			'ongoingWorkout.exercisesToSuperset.title' => 'Crea nuova superserie',
			'ongoingWorkout.exercisesToSuperset.errorBannerTitle' => 'Impossibile creare superserie',
			'ongoingWorkout.exercisesToSuperset.errors.addingNonContiguous' => 'Puoi aggiungere solo esercizi vicini l\'un l\'altro',
			'ongoingWorkout.exercisesToSuperset.errors.removingMiddle' => 'Puoi deselezionare solo il primo o l\'ultimo esercizio.',
			'ongoingWorkout.exercisesToSuperset.errors.notExercise' => 'Devi selezionare un esercizio.',
			'ongoingWorkout.exercisesToSuperset.errors.tooFew' => 'Seleziona almeno due esercizi.',
			'ongoingWorkout.exercisesToSuperset.errors.differingSets' => 'Gli esercizi selezionati devono avere lo stesso numero di serie.',
			'timer.add15s' => '+15s',
			'timer.subtract15s' => '-15s',
			'timer.skip' => 'Salta',
			'exerciseList.restTime' => 'Recupero: ',
			'exerciseList.fields.weight' => ({required Object weight, required Object unit}) => '${weight} ${unit}',
			'exerciseList.fields.time' => ({required Object time}) => '${time}',
			'exerciseList.fields.reps' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: '0 rip.', one: '${n} rip.', two: '${n} rip.', few: '${n} rip.', many: '${n} di rip.', other: '${n} rip.', ),
			'exerciseList.fields.distance' => ({required Object distance, required Object unit}) => '${distance} ${unit}',
			'exerciseList.fields.rpe' => ({required Object rpe}) => 'RPE ${rpe}',
			'exerciseList.workoutMuscleCategoriesBarChart.label' => 'Distribuzione muscolare (per serie effettuate)',
			'exerciseList.stats.time' => 'Durata',
			'exerciseList.stats.volume' => 'Volume',
			'exerciseList.stats.distance' => 'Distanza',
			'exerciseList.stats.sets' => 'Serie',
			'exerciseList.workoutWeightDistributionBarChart.label' => 'Distribuzione muscolare (per peso sollevato)',
			'exerciseList.workoutEquipmentDistributionBarChart.label' => 'Distribuzione attrezzatura (per serie effettuate)',
			'general.dialogs.actions.ok' => 'OK',
			'general.dialogs.actions.cancel' => 'Annulla',
			'general.dialogs.actions.close' => 'Chiudi',
			'general.exercises' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Nessun esercizio', one: '${n} esercizio', two: '${n} esercizi', few: '${n} esercizi', many: '${n} di esercizi', other: '${n} esercizi', ),
			'general.totalTime' => ({required Object time}) => 'Tempo totale: ${time}',
			'general.selected' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Nessuna selezione', one: '1 elemento selezionato', two: '${n} elementi selezionati', few: '${n} elementi selezionati', many: '${n} elementi selezionati', other: '${n} elementi selezionati', ),
			'general.workouts' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Nessun allenamento', one: '${n} allenamento', two: '${n} allenamenti', few: '${n} allenamenti', many: '${n} allenamenti', other: '${n} allenamenti', ),
			'general.routines' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Nessuna routine', one: '${n} routine', two: '${n} routine', few: '${n} routine', many: '${n} routine', other: '${n} routine', ),
			'general.optional' => '(facoltativo)',
			'general.unnamed' => 'Unnamed',
			'muscleGroups.abductors' => 'Abduttori',
			'muscleGroups.abs' => 'Addominali',
			'muscleGroups.adductors' => 'Adductori',
			'muscleGroups.biceps' => 'Bicipiti',
			'muscleGroups.calves' => 'Polpacci',
			'muscleGroups.chest' => 'Petto',
			'muscleGroups.forearm' => 'Avambraccio',
			'muscleGroups.glutes' => 'Glutei',
			'muscleGroups.hamstrings' => 'Femorali',
			'muscleGroups.lats' => 'Gran dorsale',
			'muscleGroups.lowerBack' => 'Schiena bassa',
			'muscleGroups.none' => 'Nessuno',
			'muscleGroups.other' => 'Altro',
			'muscleGroups.quadriceps' => 'Quadricipiti',
			'muscleGroups.shoulders' => 'Spalle',
			'muscleGroups.traps' => 'Trapezoidi',
			'muscleGroups.triceps' => 'Tricipiti',
			'muscleGroups.upperBack' => 'Schiena alta',
			'muscleGroups.thighs' => 'Cosce',
			'muscleGroups.forearms' => 'Avambracci',
			'muscleGroups.hands' => 'Mani',
			'muscleGroups.obliques' => 'Obliqui',
			'muscleGroups.tibialis' => 'Tibiali',
			'muscleCategories.arms' => 'Braccia',
			'muscleCategories.back' => 'Schiena',
			'muscleCategories.chest' => 'Petto',
			'muscleCategories.core' => 'Core',
			'muscleCategories.legs' => 'Gambe',
			'muscleCategories.shoulders' => 'Spalle',
			'titleGenerator.template' => ({required Object muscles}) => 'Allenamento ${muscles}',
			'titleGenerator.title.zero' => '',
			'titleGenerator.title.one' => ({required Object p0}) => '${p0}',
			'titleGenerator.title.two' => ({required Object p0, required Object p1}) => '${p0} e ${p1}',
			'titleGenerator.title.three' => ({required Object p0, required Object p1, required Object p2}) => '${p0}, ${p1} e ${p2}',
			'titleGenerator.title.four' => ({required Object p0, required Object p1, required Object p2, required Object p3}) => '${p0}, ${p1}, ${p2} e ${p3}',
			'titleGenerator.title.five' => ({required Object p0, required Object p1, required Object p2, required Object p3, required Object p4}) => '${p0}, ${p1}, ${p2}, ${p3} e ${p4}',
			'titleGenerator.title.six' => ({required Object p0, required Object p1, required Object p2, required Object p3, required Object p4, required Object p5}) => '${p0}, ${p1}, ${p2}, ${p3}, ${p4} e ${p5}',
			'actions.create' => 'Crea',
			'actions.remove' => 'Rimuovi',
			'actions.edit' => 'Modifica',
			'actions.undo' => 'Annulla',
			'actions.save' => 'Salva',
			'units.kg' => 'kg',
			'units.lb' => 'lbs',
			'units.km' => 'km',
			'units.mi' => 'mi',
			'time.hours' => ({required num n, required Object minutes, required Object seconds, required Object hours}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: '${minutes}:${seconds}', one: '${hours} ora, ${minutes}:${seconds}', two: '${hours} ore, ${minutes}:${seconds}', few: '${hours} ore, ${minutes}:${seconds}', many: '${hours} di ore, ${minutes}:${seconds}', other: '${hours} ore, ${minutes}:${seconds}', ),
			'time.justHours' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: '${n}', one: '${n} ora', two: '${n} ore', few: '${n} ore', many: '${n} di ore', other: '${n} ore', ),
			'time.days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: '0 giorni', one: '1 giorno', two: '2 giorni', few: '${n} giorni', many: '${n} di giorni', other: '${n} giorni', ),
			'time.weeks' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: '0 settimane', one: '1 settimana', two: '2 settimane', few: '${n} settimane', many: '${n} di settimane', other: '${n} settimane', ),
			'locales.en' => 'Inglese',
			'locales.it' => 'Italiano',
			'weightUnits.kg' => 'Chili',
			'weightUnits.lb' => 'Libbre',
			'distanceUnits.km' => 'Chilometri',
			'distanceUnits.mi' => 'Miglia',
			'barbells.normal' => 'Normale',
			'barbells.short' => 'Corto',
			'barbells.ezBar' => 'EZ bar',
			'barbells.none' => 'Nessuno',
			'weightCalculator.weight.label' => 'Peso totale',
			'weightCalculator.weights.label' => 'Pesi disponibili',
			'weightCalculator.barbells.label' => 'Bilanciere',
			'weightCalculator.insert' => 'Inserisci peso',
			'androidNotificationChannel.name' => 'Timer tempo di recupero',
			'androidNotificationChannel.description' => 'Invia una notifica quando il timer del tempo di recupero finisce.',
			'library.title' => 'Libreria',
			'library.cardio.name' => 'Cardio',
			'library.cardio.exercises.burpees' => 'Burpees',
			'library.cardio.exercises.squatThrusts' => 'Squat thrust (senza salto)',
			'library.cardio.exercises.jumpingJacks' => 'Jumping jack',
			'library.cardio.exercises.highKnees' => 'Corsa sul posto a ginocchia alte',
			'library.cardio.exercises.buttKicks' => 'Corsa calciata dietro sul posto',
			'library.cardio.exercises.skaterJumps' => 'Salti laterali del pattinatore',
			'library.cardio.exercises.squatJumps' => 'Squat con salto',
			'library.cardio.exercises.plankJacks' => 'Plank jack',
			'library.cardio.exercises.aerobics' => 'Aerobica',
			'library.cardio.exercises.biking' => 'Bicicletta',
			'library.cardio.exercises.ergometer' => 'Cyclette verticale',
			'library.cardio.exercises.ergometerHorizontal' => 'Cyclette orizzontale',
			'library.cardio.exercises.pilates' => 'Pilates',
			'library.cardio.exercises.running' => 'Corsa',
			'library.cardio.exercises.treadmill' => 'Tapis roulant',
			'library.cardio.exercises.zumba' => 'Zumba',
			'library.cardio.exercises.jumpRope' => 'Salto con la corda',
			'library.cardio.exercises.rowingMachine' => 'Remoergometro',
			'library.cardio.exercises.bicycleCrunchesCardio' => 'Bicycle crunch a tempo',
			'library.cardio.exercises.crunchesTimed' => 'Crunch a tempo',
			'library.cardio.exercises.straddleJumps' => 'Salti a gambe divaricate',
			'library.cardio.exercises.forwardAndBackwardSteps' => 'Passi avanti e indietro',
			'library.cardio.exercises.bearCrawl' => 'Camminata dell’orso',
			'library.cardio.exercises.ellipticalCycling' => 'Pedalata sul cross trainer',
			'library.cardio.exercises.burpeeDumbbell' => 'Burpee (manubri)',
			'library.cardio.exercises.partialKneeBends' => 'Piegamenti parziali delle ginocchia',
			'library.cardio.exercises.armCycleErgometer' => 'Ergometro a braccia',
			'library.cardio.exercises.wallSupportedHighKnees' => 'Ginocchia alte con appoggio alla parete',
			'library.cardio.exercises.burpeeWithJumpingJack' => 'Burpee con salto a gambe divaricate',
			'library.cardio.exercises.jumpingJackHops' => 'Saltelli con apertura di braccia e gambe',
			'library.cardio.exercises.pushUpIntoRunningStart' => 'Piegamento con partenza in corsa',
			'library.cardio.exercises.scissorJumps' => 'Salti con scambio delle gambe',
			'library.cardio.exercises.squatSemiJump' => 'Squat (mezzo, con salto)',
			'library.cardio.exercises.shortStrideRunning' => 'Corsa a passi corti',
			'library.cardio.exercises.skiergDoublePolePull' => 'Tirate a doppio bastoncino allo SkiErg',
			'library.cardio.exercises.alternatingSkiSteps' => 'Passi alternati da sci',
			'library.cardio.exercises.explosiveStarJumps' => 'Salti esplosivi a stella',
			_ => null,
		} ?? switch (path) {
			'library.cardio.exercises.kettlebellCircularSwing' => 'Swing circolare con kettlebell',
			'library.cardio.exercises.ellipticalTrainerWalking' => 'Camminata sull’ellittica',
			'library.cardio.exercises.lungeWalkingHighKnee' => 'Affondo (camminato, ginocchia alte)',
			'library.cardio.exercises.inclineTreadmillWalking' => 'Camminata in salita sul tapis roulant',
			'library.cardio.exercises.stairClimberStepping' => 'Salita dei gradini allo stepmill',
			'library.cardio.exercises.repeatedSprintIntervals' => 'Scatti di corsa ripetuti',
			'library.chest.name' => 'Petto',
			'library.chest.exercises.inclineMachineChestPress' => 'Chest press inclinata alla macchina',
			'library.chest.exercises.midHeightCableFly' => 'Croci ai cavi all’altezza del petto',
			'library.chest.exercises.barbellBenchPressFlat' => 'Panca piana (bilanciere)',
			'library.chest.exercises.barbellBenchPressIncline' => 'Panca inclinata (bilanciere)',
			'library.chest.exercises.barbellBenchPressDecline' => 'Panca declinata (bilanciere)',
			'library.chest.exercises.dumbbellBenchPressFlat' => 'Panca piana (manubri)',
			'library.chest.exercises.dumbbellBenchPressIncline' => 'Panca inclinata (manubri)',
			'library.chest.exercises.dumbbellBenchPressDecline' => 'Panca declinata (manubri)',
			'library.chest.exercises.smithMachineBenchPressFlat' => 'Panca piana (Multipower)',
			'library.chest.exercises.smithMachineBenchPressIncline' => 'Panca inclinata (Multipower)',
			'library.chest.exercises.smithMachineBenchPressDecline' => 'Panca declinata (Multipower)',
			'library.chest.exercises.cableBenchPressFlat' => 'Panca piana (cavi)',
			'library.chest.exercises.cableBenchPressIncline' => 'Panca inclinata (cavi)',
			'library.chest.exercises.cableBenchPressDecline' => 'Panca declinata (cavi)',
			'library.chest.exercises.butterflyMachine' => 'Croci alla macchina (pec deck)',
			'library.chest.exercises.dumbbellHexPress' => 'Hex press (manubri)',
			'library.chest.exercises.smithMachineHexPress' => 'Hex press al Multipower',
			'library.chest.exercises.seatedCableChestFlys' => 'Croci ai cavi da seduto',
			'library.chest.exercises.verticalChestPress' => 'Chest press (verticale)',
			'library.chest.exercises.cableFlyCrossovers' => 'Croci ai cavi alti',
			'library.chest.exercises.pushUps' => 'Push-up',
			'library.chest.exercises.pushUpsWeighted' => 'Push-up (zavorrati)',
			'library.chest.exercises.cableChestPress' => 'Chest press ai cavi',
			'library.chest.exercises.declinePushUps' => 'Push-up declinati',
			'library.chest.exercises.lowCableFly' => 'Croci ai cavi bassi',
			'library.chest.exercises.inclinePushUps' => 'Push-up inclinati',
			'library.chest.exercises.tBarPress' => 'Landmine press',
			'library.chest.exercises.inclineBenchFlys' => 'Croci su panca inclinata',
			'library.chest.exercises.benchFlys' => 'Croci su panca piana',
			'library.chest.exercises.pushUpArcher' => 'Piegamenti sulle braccia (arciere)',
			'library.chest.exercises.chestDipAssistedKneeling' => 'Dip per il petto (con assistenza, in ginocchio)',
			'library.chest.exercises.pectoralisMajorStretchAssistedSeatedStabilityBall' => 'Allungamento del grande pettorale (con assistenza, da seduti, fitball)',
			'library.chest.exercises.chestDipAssistedWideGripKneeling' => 'Dip per il petto (con assistenza, presa larga, in ginocchio)',
			'library.chest.exercises.benchPressBand' => 'Distensioni su panca (elastico)',
			'library.chest.exercises.chestPressBandOneArmTwisting' => 'Distensioni per il petto (elastico, a un braccio, con torsione)',
			'library.chest.exercises.pulloverBarbellDecline' => 'Pullover (bilanciere, su panca declinata)',
			'library.chest.exercises.pressBarbellDeclineWideGrip' => 'Distensioni (bilanciere, su panca declinata, presa larga)',
			'library.chest.exercises.benchPressBarbellGuillotine' => 'Distensioni su panca (bilanciere, alla gola)',
			'library.chest.exercises.benchPressBarbellReverseGripDecline' => 'Distensioni su panca (bilanciere, presa supina, su panca declinata)',
			'library.chest.exercises.benchPressBarbellReverseGripIncline' => 'Distensioni su panca (bilanciere, presa supina, su panca inclinata)',
			'library.chest.exercises.benchPressBarbellWide' => 'Distensioni su panca (bilanciere, ampio)',
			'library.chest.exercises.benchPressBarbellWideReverseGrip' => 'Distensioni su panca (bilanciere, ampio, presa supina)',
			'library.chest.exercises.chestStretchBehindHead' => 'Allungamento dei pettorali (dietro la testa)',
			'library.chest.exercises.seatedButterflyStretch' => 'Allungamento a farfalla da seduti',
			'library.chest.exercises.pressCableDeclineOneArm' => 'Distensioni (cavo, su panca declinata, a un braccio)',
			'library.chest.exercises.flyCableIncline' => 'Croci per il petto (cavo, su panca inclinata)',
			'library.chest.exercises.flyCableInclineStabilityBall' => 'Croci per il petto (cavo, su panca inclinata, fitball)',
			'library.chest.exercises.flyCableLying' => 'Croci per il petto (cavo, da sdraiati)',
			'library.chest.exercises.chestFlyCableOneArmDecline' => 'Croci per il petto (cavo, a un braccio, su panca declinata)',
			'library.chest.exercises.flyCableOneArmExerciseBall' => 'Croci per il petto (cavo, a un braccio, fitball)',
			'library.chest.exercises.flyCableOneArmInclineExerciseBall' => 'Croci per il petto (cavo, a un braccio, su panca inclinata, fitball)',
			'library.chest.exercises.pressCableOneArmIncline' => 'Distensioni (cavo, a un braccio, su panca inclinata)',
			'library.chest.exercises.pressCableOneArmInclineExerciseBall' => 'Distensioni (cavo, a un braccio, su panca inclinata, fitball)',
			'library.chest.exercises.pressCableOneArmExerciseBall' => 'Distensioni (cavo, a un braccio, fitball)',
			'library.chest.exercises.pressCableExerciseBall' => 'Distensioni (cavo, fitball)',
			'library.chest.exercises.chestAndAnteriorShoulderStretch' => 'Allungamento del petto e della spalla anteriore',
			'library.chest.exercises.chestDip' => 'Dip per il petto',
			'library.chest.exercises.chestDipStraightBar' => 'Dip per il petto (barra dritta)',
			'library.chest.exercises.chestStretchExerciseBall' => 'Allungamento dei pettorali (fitball)',
			'library.chest.exercises.pushUpChestTap' => 'Piegamenti sulle braccia (con tocco del petto)',
			'library.chest.exercises.pushUpClap' => 'Piegamenti sulle braccia (con battito di mani)',
			'library.chest.exercises.pushUpWithAlternatingSideReach' => 'Piegamenti con apertura laterale alternata',
			'library.chest.exercises.pushUpDeep' => 'Piegamenti sulle braccia (profondo)',
			'library.chest.exercises.pushUpDrop' => 'Piegamenti sulle braccia (con caduta)',
			'library.chest.exercises.flyDumbbellDecline' => 'Croci per il petto (manubri, su panca declinata)',
			'library.chest.exercises.benchPressDumbbellDeclineNeutralGrip' => 'Distensioni su panca (manubri, su panca declinata, presa neutra)',
			'library.chest.exercises.flyDumbbellDeclineOneArm' => 'Croci per il petto (manubri, su panca declinata, a un braccio)',
			'library.chest.exercises.flyDumbbellDeclineTwisting' => 'Croci per il petto (manubri, su panca declinata, con torsione)',
			'library.chest.exercises.flyDumbbellExerciseBall' => 'Croci per il petto (manubri, fitball)',
			'library.chest.exercises.benchPressDumbbellInclineAlternate' => 'Distensioni su panca (manubri, su panca inclinata, alternato)',
			'library.chest.exercises.flyDumbbellInclineExerciseBall' => 'Croci per il petto (manubri, su panca inclinata, fitball)',
			'library.chest.exercises.benchPressDumbbellInclineNeutralGrip' => 'Distensioni su panca (manubri, su panca inclinata, presa neutra)',
			'library.chest.exercises.flyDumbbellInclineOneArm' => 'Croci per il petto (manubri, su panca inclinata, a un braccio)',
			'library.chest.exercises.flyDumbbellInclineOneArmExerciseBall' => 'Croci per il petto (manubri, su panca inclinata, a un braccio, fitball)',
			'library.chest.exercises.pressDumbbellInclineOneArm' => 'Distensioni (manubri, su panca inclinata, a un braccio)',
			'library.chest.exercises.pressDumbbellInclineOneArmExerciseBall' => 'Distensioni (manubri, su panca inclinata, a un braccio, fitball)',
			'library.chest.exercises.pressDumbbellInclineExerciseBall' => 'Distensioni (manubri, su panca inclinata, fitball)',
			'library.chest.exercises.shoulderRaiseDumbbellIncline' => 'Elevazioni scapolari (manubri, su panca inclinata)',
			'library.chest.exercises.flyDumbbellInclineTwisting' => 'Croci per il petto (manubri, su panca inclinata, con torsione)',
			'library.chest.exercises.pressDumbbellLyingNeutralGrip' => 'Distensioni (manubri, da sdraiati, presa neutra)',
			'library.chest.exercises.pressDumbbellLyingOneArm' => 'Distensioni (manubri, da sdraiati, a un braccio)',
			'library.chest.exercises.pulloverDumbbellExerciseBall' => 'Pullover (manubri, fitball)',
			'library.chest.exercises.benchPressDumbbellNeutralGrip' => 'Distensioni su panca (manubri, presa neutra)',
			'library.chest.exercises.flyDumbbellOneArmBench' => 'Croci per il petto (manubri, a un braccio, su panca)',
			'library.chest.exercises.chestFlyDumbbellOneArmExerciseBall' => 'Croci per il petto (manubri, a un braccio, fitball)',
			'library.chest.exercises.chestPressDumbbellOneArmDecline' => 'Distensioni per il petto (manubri, a un braccio, su panca declinata)',
			'library.chest.exercises.chestPressDumbbellOneArmIncline' => 'Distensioni per il petto (manubri, a un braccio, su panca inclinata)',
			'library.chest.exercises.pressDumbbellOneArmExerciseBall' => 'Distensioni (manubri, a un braccio, fitball)',
			'library.chest.exercises.pulloverDumbbellOneArmExerciseBall' => 'Pullover (manubri, a un braccio, fitball)',
			'library.chest.exercises.pressDumbbellOneArmReverseGrip' => 'Distensioni (manubri, a un braccio, presa supina)',
			'library.chest.exercises.flyDumbbellOneLegExerciseBall' => 'Croci per il petto (manubri, a una gamba, fitball)',
			'library.chest.exercises.pressDumbbellExerciseBall' => 'Distensioni (manubri, fitball)',
			'library.chest.exercises.benchPressDumbbellReverse' => 'Distensioni su panca (manubri, inverso)',
			'library.chest.exercises.benchPressDumbbellTwisting' => 'Distensioni su panca (manubri, con torsione)',
			'library.chest.exercises.dynamicPectoralStretch' => 'Allungamento dinamico dei pettorali',
			'library.chest.exercises.supineElbowPressUp' => 'Sollevamenti del busto da supini con spinta sui gomiti',
			'library.chest.exercises.pikePushUpExerciseBall' => 'Piegamenti a V (fitball)',
			'library.chest.exercises.flyFloorBarbell' => 'Croci per il petto (a terra, bilanciere)',
			'library.chest.exercises.flyHyghtDumbbell' => 'Croci per il petto (metodo Hyght, manubri)',
			'library.chest.exercises.pushUpInclineDepthJump' => 'Piegamenti sulle braccia (su panca inclinata, con salto in profondità)',
			'library.chest.exercises.pushUpInclineReverseGrip' => 'Piegamenti sulle braccia (su panca inclinata, presa supina)',
			'library.chest.exercises.pushUpInclineScapula' => 'Piegamenti sulle braccia (su panca inclinata, scapolare)',
			'library.chest.exercises.isometricPalmToPalmChestSqueeze' => 'Spinta isometrica dei palmi per i pettorali',
			'library.chest.exercises.isometricPushUpWithSideShifts' => 'Piegamento isometrico con spostamenti laterali',
			'library.chest.exercises.pressKettlebellAlternateFloor' => 'Distensioni (kettlebell, alternato, a terra)',
			'library.chest.exercises.pressKettlebellExtendedRangeOneArmFloor' => 'Distensioni (kettlebell, escursione ampliata, a un braccio, a terra)',
			'library.chest.exercises.floorPressKettlebellOneArm' => 'Distensioni da terra (kettlebell, a un braccio)',
			'library.chest.exercises.pushUpKettlebellPlyo' => 'Piegamenti sulle braccia (kettlebell, pliometrico)',
			'library.chest.exercises.pushUpKneeling' => 'Piegamenti sulle braccia (in ginocchio)',
			'library.chest.exercises.rearBarDips' => 'Dip con sbarra dietro il corpo',
			'library.chest.exercises.chestPressLeverDecline' => 'Distensioni per il petto (macchina a leva, su panca declinata)',
			'library.chest.exercises.chestPressLeverStanding' => 'Distensioni per il petto (macchina a leva, in piedi)',
			'library.chest.exercises.machineChestSqueezePress' => 'Distensioni convergenti per il petto alla macchina',
			'library.chest.exercises.medicineBallChestPass' => 'Lancio della palla medica dal petto',
			'library.chest.exercises.medicineBallChestThrowFromThreePointStart' => 'Lancio dal petto con palla medica da partenza a tre appoggi',
			'library.chest.exercises.repeatedMedicineBallChestPasses' => 'Lanci ripetuti dal petto con palla medica',
			'library.chest.exercises.singleMedicineBallChestThrow' => 'Lancio singolo dal petto con palla medica',
			'library.chest.exercises.medicineBallChestThrowWithRunOut' => 'Lancio dal petto con palla medica e corsa in uscita',
			'library.chest.exercises.pushUpModifiedHindu' => 'Piegamenti sulle braccia (hindu modificato)',
			'library.chest.exercises.kneelingPushUpToForearms' => 'Piegamenti sulle ginocchia con passaggio agli avambracci',
			'library.chest.exercises.pushUpNarrowExerciseBall' => 'Piegamenti sulle braccia (stretto, fitball)',
			'library.chest.exercises.pushUpOutsideLegKick' => 'Piegamenti sulle braccia (con calcio verso l’esterno)',
			'library.chest.exercises.pushUpPlyo' => 'Piegamenti sulle braccia (pliometrico)',
			'library.chest.exercises.bodyweightPushAndPull' => 'Spinte e tirate a corpo libero',
			'library.chest.exercises.pushUpBosuBall' => 'Piegamenti sulle braccia (BOSU)',
			'library.chest.exercises.pushUpStabilityBall' => 'Piegamenti sulle braccia (fitball)',
			'library.chest.exercises.pushUpWall' => 'Piegamenti sulle braccia (alla parete)',
			'library.chest.exercises.pushUpInsideLegKick' => 'Piegamenti sulle braccia (con calcio verso l’interno)',
			'library.chest.exercises.pushUpMedicineBall' => 'Piegamenti sulle braccia (palla medica)',
			'library.chest.exercises.pushUpLowerArms' => 'Piegamenti sulle braccia (sugli avambracci)',
			'library.chest.exercises.pushUpPlus' => 'Piegamenti sulle braccia (con protrazione scapolare)',
			'library.chest.exercises.pushUpIntoSidePlank' => 'Piegamento con passaggio a plank laterale',
			'library.chest.exercises.chestPressResistanceBandSeated' => 'Distensioni per il petto (elastico, da seduti)',
			'library.chest.exercises.seatedRollerReachForward' => 'Scivolamenti del rullo in avanti da seduti',
			'library.chest.exercises.seatedStraightArmRollerRaise' => 'Sollevamenti del rullo a braccia tese da seduti',
			'library.chest.exercises.pushUpScapula' => 'Piegamenti sulle braccia (scapolare)',
			'library.chest.exercises.pushUpWithShoulderTaps' => 'Piegamento con tocco delle spalle',
			'library.chest.exercises.pushUpSide' => 'Piegamenti sulle braccia (laterale)',
			'library.chest.exercises.pushUpOneArm' => 'Piegamenti sulle braccia (a un braccio)',
			'library.chest.exercises.pressSmithDeclineReverseGrip' => 'Distensioni (Smith machine, su panca declinata, presa supina)',
			'library.chest.exercises.pressSmithInclineReverseGrip' => 'Distensioni (Smith machine, su panca inclinata, presa supina)',
			'library.chest.exercises.inclineSmithMachineHighPull' => 'Tirata alta inclinata alla Smith machine',
			'library.chest.exercises.benchPressSmithMachineReverseDeclineCloseGrip' => 'Distensioni su panca (Smith machine, inverso, su panca declinata, presa stretta)',
			'library.chest.exercises.pressSmithReverseGrip' => 'Distensioni (Smith machine, presa supina)',
			'library.chest.exercises.benchPressSmithWideGrip' => 'Distensioni su panca (Smith machine, presa larga)',
			'library.chest.exercises.benchPressSmithWideGripDecline' => 'Distensioni su panca (Smith machine, presa larga, su panca declinata)',
			'library.chest.exercises.pushUpSpiderCrawl' => 'Piegamenti sulle braccia (con passo del ragno)',
			'library.chest.exercises.pushUpSuperman' => 'Piegamenti sulle braccia (Superman)',
			'library.chest.exercises.pushUpSuspended' => 'Piegamenti sulle braccia (in sospensione)',
			'library.chest.exercises.pushUpWeightedDrop' => 'Piegamenti sulle braccia (con sovraccarico, con caduta)',
			'library.chest.exercises.dipWeightedStraightBar' => 'Dip (con sovraccarico, barra dritta)',
			'library.chest.exercises.svendPressWeighted' => 'Svend press (con sovraccarico)',
			'library.chest.exercises.pushUpWideHand' => 'Piegamenti sulle braccia (ampio, mani)',
			'library.chest.exercises.chestDipWideGripHighParallelBars' => 'Dip per il petto (presa larga, alto, alle parallele)',
			'library.biceps.name' => 'Bicipiti',
			'library.biceps.exercises.behindBodyCableCurl' => 'Curl al cavo con braccio dietro al busto',
			'library.biceps.exercises.ropeHammerCurl' => 'Hammer curl con corda al cavo',
			'library.biceps.exercises.inclineDumbbellCurl' => 'Curl su panca inclinata (manubri)',
			'library.biceps.exercises.barbellBicepsCurl' => 'Bicep curl (bilanciere)',
			'library.biceps.exercises.spiderCurls' => 'Spider curl',
			'library.biceps.exercises.singleArmCableHammerCurls' => 'Hammer curl ai cavi (braccio singolo)',
			'library.biceps.exercises.cableBicepsCurl' => 'Bicep curl (cavi)',
			'library.biceps.exercises.dumbbellBicepsCurl' => 'Bicep curl (manubri)',
			'library.biceps.exercises.bicepsCurlMachine' => 'Bicep curl (macchina)',
			'library.biceps.exercises.hammerCurlDumbbell' => 'Hammer curl (manubri)',
			'library.biceps.exercises.concentrationCurl' => 'Curl concentrati',
			'library.biceps.exercises.scottCurl' => 'Curl alla panca Scott',
			'library.biceps.exercises.dualCableHighCurl' => 'Curl ai cavi alti',
			'library.biceps.exercises.bicepsCurlBandAlternate' => 'Curl per i bicipiti (elastico, alternato)',
			'library.biceps.exercises.concentrationCurlBand' => 'Curl concentrato (elastico)',
			'library.biceps.exercises.bicepsCurlBandOneArmOverhead' => 'Curl per i bicipiti (elastico, a un braccio, sopra la testa)',
			'library.biceps.exercises.bicepsCurlBarbellAlternate' => 'Curl per i bicipiti (bilanciere, alternato)',
			'library.biceps.exercises.bicepsCurlBarbellArmBlaster' => 'Curl per i bicipiti (bilanciere, arm blaster)',
			'library.biceps.exercises.dragCurlBarbell' => 'Drag curl (bilanciere)',
			'library.biceps.exercises.preacherCurlBarbellLying' => 'Curl alla panca Scott (bilanciere, da sdraiati)',
			'library.biceps.exercises.preacherCurlBarbell' => 'Curl alla panca Scott (bilanciere)',
			'library.biceps.exercises.reversePreacherCurlBarbell' => 'Curl inverso alla panca Scott (bilanciere)',
			'library.biceps.exercises.concentrationCurlBarbellSeatedCloseGrip' => 'Curl concentrato (bilanciere, da seduti, presa stretta)',
			'library.biceps.exercises.curlBarbellStandingCloseGrip' => 'Curl per i bicipiti (bilanciere, in piedi, presa stretta)',
			'library.biceps.exercises.concentrationCurlBarbellStanding' => 'Curl concentrato (bilanciere, in piedi)',
			'library.biceps.exercises.bicepsCurlBarbellStandingWideGrip' => 'Curl per i bicipiti (bilanciere, in piedi, presa larga)',
			'library.biceps.exercises.legResistedConcentrationCurl' => 'Curl concentrato contro la resistenza della gamba',
			'library.biceps.exercises.chinUpCloseGrip' => 'Trazioni a presa supina (presa stretta)',
			'library.biceps.exercises.bicepsCurlBodyweightSideLying' => 'Curl per i bicipiti (corpo libero, sdraiati sul fianco)',
			'library.biceps.exercises.curlCableCloseGrip' => 'Curl per i bicipiti (cavo, presa stretta)',
			'library.biceps.exercises.concentrationCurlCable' => 'Curl concentrato (cavo)',
			'library.biceps.exercises.dragCurlCable' => 'Drag curl (cavo)',
			'library.biceps.exercises.bicepsCurlCableLying' => 'Curl per i bicipiti (cavo, da sdraiati)',
			'library.biceps.exercises.curlCableLyingCloseGrip' => 'Curl per i bicipiti (cavo, da sdraiati, presa stretta)',
			'library.biceps.exercises.curlCableOneArm' => 'Curl per i bicipiti (cavo, a un braccio)',
			'library.biceps.exercises.preacherCurlCableOneArm' => 'Curl alla panca Scott (cavo, a un braccio)',
			'library.biceps.exercises.reversePreacherCurlCableOneArm' => 'Curl inverso alla panca Scott (cavo, a un braccio)',
			'library.biceps.exercises.curlCableOverheadExerciseBall' => 'Curl per i bicipiti (cavo, sopra la testa, fitball)',
			'library.biceps.exercises.preacherCurlCable' => 'Curl alla panca Scott (cavo)',
			'library.biceps.exercises.bicepsCurlCablePulldown' => 'Curl per i bicipiti (cavo, dall’alto)',
			'library.biceps.exercises.reverseCurlCable' => 'Curl inverso (cavo)',
			'library.biceps.exercises.reversePreacherCurlCable' => 'Curl inverso alla panca Scott (cavo)',
			'library.biceps.exercises.hammerPreacherCurlCableRope' => 'Curl a martello alla panca Scott (cavo, corda)',
			'library.biceps.exercises.hammerPreacherCurlCableRopeOneArm' => 'Curl a martello alla panca Scott (cavo, corda, a un braccio)',
			'library.biceps.exercises.curlCableSeated' => 'Curl per i bicipiti (cavo, da seduti)',
			'library.biceps.exercises.concentrationCurlCableSeatedOneArm' => 'Curl concentrato (cavo, da seduti, a un braccio)',
			'library.biceps.exercises.curlCableSeatedOverhead' => 'Curl per i bicipiti (cavo, da seduti, sopra la testa)',
			'library.biceps.exercises.curlCableSquatting' => 'Curl per i bicipiti (cavo, in accosciata)',
			'library.biceps.exercises.curlCableStandingInner' => 'Curl per i bicipiti (cavo, in piedi, gomiti aperti)',
			'library.biceps.exercises.bicepsCurlCableRopeStanding' => 'Curl per i bicipiti (cavo, corda, in piedi)',
			'library.biceps.exercises.curlCableTwoArmInclineBench' => 'Curl per i bicipiti (cavo, a due braccia, su panca inclinata)',
			'library.biceps.exercises.bicepsCurlDumbbellAlternate' => 'Curl per i bicipiti (manubri, alternato)',
			'library.biceps.exercises.bicepsCurlDumbbellAlternateArmBlaster' => 'Curl per i bicipiti (manubri, alternato, arm blaster)',
			'library.biceps.exercises.hammerPreacherCurlDumbbellAlternate' => 'Curl a martello alla panca Scott (manubri, alternato)',
			'library.biceps.exercises.preacherCurlDumbbellAlternate' => 'Curl alla panca Scott (manubri, alternato)',
			'library.biceps.exercises.hammerCurlDumbbellAlternateSeated' => 'Curl a martello (manubri, alternato, da seduti)',
			'library.biceps.exercises.bicepsCurlDumbbellAlternateLegRaisedExerciseBall' => 'Curl per i bicipiti (manubri, alternato, con gamba sollevata, fitball)',
			'library.biceps.exercises.bicepsCurlDumbbellAlternateSeatedExerciseBall' => 'Curl per i bicipiti (manubri, alternato, da seduti, fitball)',
			'library.biceps.exercises.dumbbellCurlWithBowlingLunge' => 'Curl con manubri e affondo con gesto da bowling',
			'library.biceps.exercises.bicepsCurlDumbbellExerciseBallLegRaised' => 'Curl per i bicipiti (manubri, fitball, con gamba sollevata)',
			'library.biceps.exercises.bicepsCurlDumbbellStorkStance' => 'Curl per i bicipiti (manubri, in equilibrio su una gamba)',
			'library.biceps.exercises.bicepsCurlDumbbellArmBlaster' => 'Curl per i bicipiti (manubri, arm blaster)',
			'library.biceps.exercises.bicepsCurlSquatDumbbell' => 'Squat e curl per i bicipiti (manubri)',
			'library.biceps.exercises.bicepsCurlDumbbellVSitBosuBall' => 'Curl per i bicipiti (manubri, in squadra a V, BOSU)',
			'library.biceps.exercises.hammerCurlDumbbellCrossBody' => 'Curl a martello (manubri, incrociato)',
			'library.biceps.exercises.hammerCurlDumbbellExerciseBall' => 'Curl a martello (manubri, fitball)',
			'library.biceps.exercises.hammerCurlDumbbellArmBlaster' => 'Curl a martello (manubri, arm blaster)',
			'library.biceps.exercises.highCurlDumbbell' => 'Curl alto (manubri)',
			'library.biceps.exercises.preacherCurlDumbbellIncline' => 'Curl alla panca Scott (manubri, su panca inclinata)',
			'library.biceps.exercises.hammerCurlDumbbellIncline' => 'Curl a martello (manubri, su panca inclinata)',
			'library.biceps.exercises.innerBicepsCurlDumbbellIncline' => 'Curl per i bicipiti con gomiti aperti (manubri, su panca inclinata)',
			'library.biceps.exercises.bicepsCurlDumbbellKneelingExerciseBall' => 'Curl per i bicipiti (manubri, in ginocchio, fitball)',
			'library.biceps.exercises.lungeBicepsCurlDumbbell' => 'Affondo e curl per i bicipiti (manubri)',
			'library.biceps.exercises.bicepsCurlDumbbellLyingSupine' => 'Curl per i bicipiti (manubri, da sdraiati, in posizione supina)',
			'library.biceps.exercises.bicepsCurlDumbbellLying' => 'Curl per i bicipiti (manubri, da sdraiati)',
			'library.biceps.exercises.curlDumbbellLyingWide' => 'Curl per i bicipiti (manubri, da sdraiati, ampio)',
			'library.biceps.exercises.concentrationCurlDumbbellOneArmStabilityBall' => 'Curl concentrato (manubri, a un braccio, fitball)',
			'library.biceps.exercises.hammerPreacherCurlDumbbellOneArm' => 'Curl a martello alla panca Scott (manubri, a un braccio)',
			'library.biceps.exercises.curlDumbbellOneArmProne' => 'Curl per i bicipiti (manubri, a un braccio, in posizione prona)',
			'library.biceps.exercises.hammerCurlDumbbellOneArmProne' => 'Curl a martello (manubri, a un braccio, in posizione prona)',
			'library.biceps.exercises.reversePreacherCurlDumbbellOneArm' => 'Curl inverso alla panca Scott (manubri, a un braccio)',
			'library.biceps.exercises.reverseSpiderCurlDumbbellOneArm' => 'Spider curl inverso (manubri, a un braccio)',
			'library.biceps.exercises.bicepsCurlDumbbellOneArmSeatedExerciseBall' => 'Curl per i bicipiti (manubri, a un braccio, da seduti, fitball)',
			'library.biceps.exercises.hammerCurlDumbbellOneArmSeated' => 'Curl a martello (manubri, a un braccio, da seduti)',
			'library.biceps.exercises.curlDumbbellOneArmStanding' => 'Curl per i bicipiti (manubri, a un braccio, in piedi)',
			'library.biceps.exercises.hammerCurlDumbbellOneArmStanding' => 'Curl a martello (manubri, a un braccio, in piedi)',
			'library.biceps.exercises.zottmanPreacherCurlDumbbellOneArm' => 'Curl Zottman alla panca Scott (manubri, a un braccio)',
			'library.biceps.exercises.hammerPreacherCurlDumbbell' => 'Curl a martello alla panca Scott (manubri)',
			'library.biceps.exercises.preacherCurlDumbbellExerciseBall' => 'Curl alla panca Scott (manubri, fitball)',
			'library.biceps.exercises.curlDumbbellProneIncline' => 'Curl per i bicipiti (manubri, in posizione prona, su panca inclinata)',
			'library.biceps.exercises.hammerCurlDumbbellProneIncline' => 'Curl a martello (manubri, in posizione prona, su panca inclinata)',
			'library.biceps.exercises.reversePreacherCurlDumbbell' => 'Curl inverso alla panca Scott (manubri)',
			'library.biceps.exercises.reverseSpiderCurlDumbbell' => 'Spider curl inverso (manubri)',
			'library.biceps.exercises.hammerCurlDumbbellSeatedAlternateExerciseBall' => 'Curl a martello (manubri, da seduti, alternato, fitball)',
			'library.biceps.exercises.bicepsCurlDumbbellSeated' => 'Curl per i bicipiti (manubri, da seduti)',
			'library.biceps.exercises.bicepsCurlDumbbellSeatedExerciseBall' => 'Curl per i bicipiti (manubri, da seduti, fitball)',
			'library.biceps.exercises.hammerCurlDumbbellSeated' => 'Curl a martello (manubri, da seduti)',
			'library.biceps.exercises.innerBicepsCurlDumbbellSeated' => 'Curl per i bicipiti con gomiti aperti (manubri, da seduti)',
			'library.biceps.exercises.bicepsCurlDumbbellSeatedOneArmExerciseBallLegRaised' => 'Curl per i bicipiti (manubri, da seduti, a un braccio, fitball, con gamba sollevata)',
			'library.biceps.exercises.preacherCurlDumbbellSeated' => 'Curl alla panca Scott (manubri, da seduti)',
			'library.biceps.exercises.concentrationCurlDumbbellSeatedReverse' => 'Curl concentrato (manubri, da seduti, inverso)',
			'library.biceps.exercises.hammerCurlAndPressDumbbellStandingAlternate' => 'Curl a martello e distensioni (manubri, in piedi, alternato)',
			'library.biceps.exercises.concentrationCurlDumbbellStanding' => 'Curl concentrato (manubri, in piedi)',
			'library.biceps.exercises.innerBicepsCurlDumbbellStanding' => 'Curl per i bicipiti con gomiti aperti (manubri, in piedi)',
			'library.biceps.exercises.concentrationCurlDumbbellStandingOneArm' => 'Curl concentrato (manubri, in piedi, a un braccio)',
			'library.biceps.exercises.curlDumbbellStandingOneArmInclineBench' => 'Curl per i bicipiti (manubri, in piedi, a un braccio, su panca inclinata)',
			'library.biceps.exercises.preacherCurlDumbbellStanding' => 'Curl alla panca Scott (manubri, in piedi)',
			'library.biceps.exercises.zottmanPreacherCurlDumbbellStanding' => 'Curl Zottman alla panca Scott (manubri, in piedi)',
			'library.biceps.exercises.stepUpWithBalanceAndDumbbellCurl' => 'Salita sul gradino in equilibrio e curl con manubri',
			'library.biceps.exercises.bicepsCurlDumbbellWaiter' => 'Curl per i bicipiti (manubri, presa a vassoio)',
			'library.biceps.exercises.zottmanCurlDumbbell' => 'Curl Zottman (manubri)',
			'library.biceps.exercises.zottmanPreacherCurlDumbbell' => 'Curl Zottman alla panca Scott (manubri)',
			'library.biceps.exercises.concentrationCurlEzBarSeatedCloseGrip' => 'Curl concentrato (bilanciere EZ, da seduti, presa stretta)',
			'library.biceps.exercises.preacherCurlEzBarbellCloseGrip' => 'Curl alla panca Scott (bilanciere EZ, presa stretta)',
			'library.biceps.exercises.curlEzBarbellCloseGrip' => 'Curl per i bicipiti (bilanciere EZ, presa stretta)',
			'library.biceps.exercises.curlEzBarbell' => 'Curl per i bicipiti (bilanciere EZ)',
			'library.biceps.exercises.reverseCurlEzBarbell' => 'Curl inverso (bilanciere EZ)',
			'library.biceps.exercises.reversePreacherCurlEzBarbell' => 'Curl inverso alla panca Scott (bilanciere EZ)',
			'library.biceps.exercises.curlEzBarbellSeated' => 'Curl per i bicipiti (bilanciere EZ, da seduti)',
			'library.biceps.exercises.spiderCurlEzBarbell' => 'Spider curl (bilanciere EZ)',
			'library.biceps.exercises.bicepsCurlEzBarArmBlaster' => 'Curl per i bicipiti (bilanciere EZ, arm blaster)',
			'library.biceps.exercises.bicepsCurlEzBarbellStandingWideGrip' => 'Curl per i bicipiti (bilanciere EZ, in piedi, presa larga)',
			'library.biceps.exercises.cleanKettlebellBottomsUpFromHangPosition' => 'Girata (kettlebell, fondo verso l’alto, dalla sospensione)',
			'library.biceps.exercises.hangCleanKettlebellDoubleAlternate' => 'Girata dalla sospensione (kettlebell, con due kettlebell, alternato)',
			'library.biceps.exercises.preacherCurlLeverHammerGrip' => 'Curl alla panca Scott (macchina a leva, presa a martello)',
			'library.biceps.exercises.preacherCurlLever' => 'Curl alla panca Scott (macchina a leva)',
			'library.biceps.exercises.reversePreacherCurlLever' => 'Curl inverso alla panca Scott (macchina a leva)',
			'library.biceps.exercises.hammerCurlOlympicBarbell' => 'Curl a martello (bilanciere olimpico)',
			'library.biceps.exercises.bicepsCurlResistanceBandSeated' => 'Curl per i bicipiti (elastico, da seduti)',
			'library.biceps.exercises.bicepsCurlSmithMachine' => 'Curl per i bicipiti (Smith machine)',
			'library.biceps.exercises.bicepsCurlWeightedSeatedStabilityBall' => 'Curl per i bicipiti (con sovraccarico, da seduti, fitball)',
			'library.abs.name' => 'Addominali',
			'library.abs.exercises.abWheelRollout' => 'Ab wheel rollout',
			'library.abs.exercises.hangingKneeRaise' => 'Sollevamento delle ginocchia alla sbarra',
			'library.abs.exercises.mountainClimber' => 'Mountain climber',
			'library.abs.exercises.highCableWoodchopper' => 'Woodchopper al cavo dall’alto',
			'library.abs.exercises.reverseCrunch' => 'Crunch inverso',
			'library.abs.exercises.cableCrunch' => 'Crunch al cavo',
			'library.abs.exercises.pallofPress' => 'Pallof press al cavo',
			'library.abs.exercises.crunches' => 'Crunch',
			'library.abs.exercises.kneeRaise' => 'Sollevamento delle ginocchia da sdraiati',
			'library.abs.exercises.legRaise' => 'Sollevamento delle gambe da sdraiati',
			'library.abs.exercises.crunchMachine' => 'Crunch machine',
			'library.abs.exercises.heelsUpCrunch' => 'Crunch (caviglie alzate)',
			'library.abs.exercises.fullBodyCrunch' => 'Crunch doppio',
			'library.abs.exercises.plank' => 'Plank',
			'library.abs.exercises.hollowBodyHold' => 'Hollow body hold',
			'library.abs.exercises.russianTwist' => 'Russian twist',
			'library.abs.exercises.bicycleCrunches' => 'Bicycle crunch',
			'library.abs.exercises.extendedReverseCrunchWithLegExtension' => 'Crunch inverso con distensione delle gambe',
			'library.abs.exercises.toeTouches' => 'Toe touches',
			'library.abs.exercises.heelTouches' => 'Heel touches',
			'library.abs.exercises.deadBugHoldCardio' => 'Dead bugs (a tempo)',
			'library.abs.exercises.deadBugHoldStatic' => 'Dead bug hold (statico)',
			'library.abs.exercises.deadBugHold' => 'Dead bugs',
			'library.abs.exercises.hollowBodyHoldBentKnees' => 'Hollow body hold a ginocchia piegate',
			'library.abs.exercises.obliqueCrunches' => 'Crunch obliqui',
			'library.abs.exercises.legRaiseParallelBars' => 'Sollevamento delle gambe alle parallele',
			'library.abs.exercises.lateralHyperextensions' => 'Iperestensioni laterali',
			'library.abs.exercises.sitUp34' => 'Sit-up (tre quarti)',
			'library.abs.exercises.sideBendOnA45Bench' => 'Flessioni laterali su panca a 45°',
			'library.abs.exercises.legRaiseHangingStraps' => 'Sollevamenti delle gambe (in sospensione alla sbarra, cinghie)',
			'library.abs.exercises.sitUpArmsOverheadFull' => 'Sit-up (braccia sopra la testa, completo)',
			'library.abs.exercises.kneeRaiseAssistedHanging' => 'Sollevamenti delle ginocchia (con assistenza, in sospensione alla sbarra)',
			'library.abs.exercises.kneeRaiseAssistedHangingThrowDown' => 'Sollevamenti delle ginocchia (con assistenza, in sospensione alla sbarra, con spinta verso il basso del partner)',
			'library.abs.exercises.legRaiseAssistedLyingLateralThrowDown' => 'Sollevamenti delle gambe (con assistenza, da sdraiati, laterale, con spinta verso il basso del partner)',
			'library.abs.exercises.legRaiseAssistedLyingThrowDown' => 'Sollevamenti delle gambe (con assistenza, da sdraiati, con spinta verso il basso del partner)',
			'library.abs.exercises.russianTwistAssistedMotion' => 'Torsioni russe (con assistenza, con movimento assistito)',
			'library.abs.exercises.sitUpAssisted' => 'Sit-up (con assistenza)',
			'library.abs.exercises.vUpBandAlternate' => 'Chiusure a V (elastico, alternato)',
			'library.abs.exercises.rolloutBandAssistedWheel' => 'Rollout addominale (elastico, con assistenza, ruota)',
			'library.abs.exercises.bicycleCrunchBand' => 'Crunch a bicicletta (elastico)',
			'library.abs.exercises.pallofPressBandHorizontal' => 'Pallof press (elastico, orizzontale)',
			'library.abs.exercises.jackknifeSitUpBand' => 'Sit-up a libro (elastico)',
			'library.abs.exercises.crunchBandKneelingTwisting' => 'Crunch (elastico, in ginocchio, con torsione)',
			'library.abs.exercises.legRaiseBandLyingStraightLeg' => 'Sollevamenti delle gambe (elastico, da sdraiati, gambe tese)',
			'library.abs.exercises.sitUpBandPush' => 'Sit-up (elastico, con spinta)',
			'library.abs.exercises.twistBandSeated' => 'Rotazioni del busto (elastico, da seduti)',
			'library.abs.exercises.crunchBandStanding' => 'Crunch (elastico, in piedi)',
			'library.abs.exercises.crunchBandStandingTwisting' => 'Crunch (elastico, in piedi, con torsione)',
			'library.abs.exercises.vUpBand' => 'Chiusure a V (elastico)',
			'library.abs.exercises.pallofPressBandVertical' => 'Pallof press (elastico, verticale)',
			'library.abs.exercises.sitUpBarbellPress' => 'Sit-up (bilanciere, con distensione)',
			'library.abs.exercises.rolloutBarbell' => 'Rollout addominale (bilanciere)',
			'library.abs.exercises.rolloutBarbellFromBench' => 'Rollout addominale (bilanciere, dalla panca)',
			'library.abs.exercises.twistBarbellSeated' => 'Rotazioni del busto (bilanciere, da seduti)',
			'library.abs.exercises.sideBendBarbell' => 'Flessioni laterali del busto (bilanciere)',
			'library.abs.exercises.legRaiseBarbellSeatedAlternate' => 'Sollevamenti delle gambe (bilanciere, da seduti, alternato)',
			'library.abs.exercises.abRolloutBarbellStanding' => 'Rollout addominale (bilanciere, in piedi)',
			'library.abs.exercises.twistBarbellStanding' => 'Rotazioni del busto (bilanciere, in piedi)',
			'library.abs.exercises.sidePlankBodyweightIncline' => 'Plank laterale (corpo libero, su panca inclinata)',
			'library.abs.exercises.reverseCrunchWithVerticalHipLift' => 'Crunch inverso con sollevamento verticale del bacino',
			'library.abs.exercises.crossBodyMountainClimber' => 'Mountain climber incrociato',
			'library.abs.exercises.plankHipLifts' => 'Sollevamenti del bacino in plank',
			'library.abs.exercises.cableRotationalShoulderThrow' => 'Rotazione e tirata del cavo sopra la spalla',
			'library.abs.exercises.reverseCrunchCable' => 'Crunch inverso (cavo)',
			'library.abs.exercises.russianTwistCableStabilityBall' => 'Torsioni russe (cavo, fitball)',
			'library.abs.exercises.crunchCableSeated' => 'Crunch (cavo, da seduti)',
			'library.abs.exercises.twistCableSeated' => 'Rotazioni del busto (cavo, da seduti)',
			'library.abs.exercises.sideBendCable' => 'Flessioni laterali del busto (cavo)',
			'library.abs.exercises.sideBendCableCrunchBosuBall' => 'Flessioni laterali del busto (cavo, con flessione del busto, BOSU)',
			'library.abs.exercises.sideCrunchCable' => 'Crunch laterale (cavo)',
			'library.abs.exercises.crunchCableStanding' => 'Crunch (cavo, in piedi)',
			'library.abs.exercises.crunchCableStandingRope' => 'Crunch (cavo, in piedi, corda)',
			'library.abs.exercises.lowToHighCableWoodchop' => 'Rotazioni al cavo dal basso verso l’alto',
			'library.abs.exercises.reverseCrunchCableTuck' => 'Crunch inverso (cavo, raccolto)',
			'library.abs.exercises.twistCable' => 'Rotazioni del busto (cavo)',
			'library.abs.exercises.crabPositionToeTouches' => 'Tocchi dei piedi in appoggio posteriore',
			'library.abs.exercises.crunchCrossBody' => 'Crunch (incrociato)',
			'library.abs.exercises.crunchHandsOverhead' => 'Crunch (mani sopra la testa)',
			'library.abs.exercises.crunchStabilityBall' => 'Crunch (fitball)',
			'library.abs.exercises.crunchStabilityBallStraightArm' => 'Crunch (fitball, braccia tese)',
			'library.abs.exercises.crunchDecline' => 'Crunch (su panca declinata)',
			'library.abs.exercises.sitUpDecline' => 'Sit-up (su panca declinata)',
			'library.abs.exercises.sideBendDumbbell' => 'Flessioni laterali del busto (manubri)',
			'library.abs.exercises.alternatingElbowToKneeCrunch' => 'Crunch alternato gomito-ginocchio',
			'library.abs.exercises.humanFlagHold' => 'Tenuta della bandiera',
			'library.abs.exercises.sitUpFlexionLegBentKnee' => 'Sit-up (con flessione delle gambe, ginocchia piegate)',
			'library.abs.exercises.sitUpFlexionLegStraightArm' => 'Sit-up (con flessione delle gambe, braccia tese)',
			'library.abs.exercises.crunchFrog' => 'Crunch (a rana)',
			'library.abs.exercises.plankTrunkRotations' => 'Rotazioni del busto in plank',
			'library.abs.exercises.chinUpWithKneeTuck' => 'Trazioni supine con raccolta delle ginocchia',
			'library.abs.exercises.sitUpHalf' => 'Sit-up (mezzo)',
			'library.abs.exercises.legHipRaiseHanging' => 'Sollevamenti di gambe e bacino (in sospensione alla sbarra)',
			'library.abs.exercises.legRaiseHanging' => 'Sollevamenti delle gambe (in sospensione alla sbarra)',
			'library.abs.exercises.kneeRaiseHangingOblique' => 'Sollevamenti delle ginocchia (in sospensione alla sbarra, obliquo)',
			'library.abs.exercises.hangingPikeRaise' => 'Sollevamenti a squadra alla sbarra',
			'library.abs.exercises.legHipRaiseHangingStraightLegTwisting' => 'Sollevamenti di gambe e bacino (in sospensione alla sbarra, gambe tese, con torsione)',
			'library.abs.exercises.inchworm' => 'Camminata a bruco',
			'library.abs.exercises.legHipRaiseInclineStraightLeg' => 'Sollevamenti di gambe e bacino (su panca inclinata, gambe tese)',
			'library.abs.exercises.sitUpInclineTwisting' => 'Sit-up (su panca inclinata, con torsione)',
			'library.abs.exercises.jackknifeSitUp' => 'Sit-up a libro',
			'library.abs.exercises.sitUpJanda' => 'Sit-up (metodo Janda)',
			'library.abs.exercises.windmillKettlebellAdvanced' => 'Windmill (kettlebell, avanzato)',
			'library.abs.exercises.pressKettlebellBent' => 'Distensioni (kettlebell, inclinato)',
			'library.abs.exercises.windmillKettlebellDouble' => 'Windmill (kettlebell, con due kettlebell)',
			'library.abs.exercises.kettlebellFigureEightPass' => 'Passaggi del kettlebell a otto tra le gambe',
			'library.abs.exercises.windmillKettlebell' => 'Windmill (kettlebell)',
			'library.abs.exercises.seatedKneeTucksOnBench' => 'Raccolte delle ginocchia da seduti su panca',
			'library.abs.exercises.crunchKneeTouch' => 'Crunch (con tocco delle ginocchia)',
			'library.abs.exercises.kneelingPlankShoulderTaps' => 'Tocchi delle spalle in plank sulle ginocchia',
			'library.abs.exercises.lSitFloor' => 'L-sit (a terra)',
			'library.abs.exercises.landmineTrunkRotations' => 'Rotazioni del busto con landmine',
			'library.abs.exercises.benchKneeTucks' => 'Raccolte delle ginocchia su panca',
			'library.abs.exercises.twistLeverKneeling' => 'Rotazioni del busto (macchina a leva, in ginocchio)',
			'library.abs.exercises.crunchLeverSeatedChestPad' => 'Crunch (macchina a leva, da seduti, con cuscino toracico)',
			'library.abs.exercises.legRaiseLeverSeatedCrunch' => 'Sollevamenti delle gambe (macchina a leva, da seduti, con flessione del busto)',
			'library.abs.exercises.lungeTwist' => 'Affondo (con torsione)',
			'library.abs.exercises.legHipRaiseLying' => 'Sollevamenti di gambe e bacino (da sdraiati)',
			'library.abs.exercises.crunchNegative' => 'Crunch (eccentrico)',
			'library.abs.exercises.singleArmMedicineBallSlam' => 'Schiacciata della palla medica a un braccio',
			'library.abs.exercises.supinePelvicTilts' => 'Retroversioni del bacino da supini',
			'library.abs.exercises.reverseStepWithOverheadReach' => 'Passo indietro con allungamento delle braccia sopra la testa',
			'library.abs.exercises.squatPotty' => 'Squat (in accosciata profonda)',
			'library.abs.exercises.plankWithOppositeArmAndLegReach' => 'Plank con estensione di braccio e gamba opposti',
			'library.abs.exercises.sitUpPrisonerHalf' => 'Sit-up (mani dietro la testa, mezzo)',
			'library.abs.exercises.twistProneStabilityBall' => 'Rotazioni del busto (in posizione prona, fitball)',
			'library.abs.exercises.stabilityBallKneeTuck' => 'Raccolte delle ginocchia sulla fitball',
			'library.abs.exercises.sitUpQuarter' => 'Sit-up (un quarto)',
			'library.abs.exercises.reversePlankWithAlternatingLegRaises' => 'Plank inverso con sollevamenti alternati delle gambe',
			'library.abs.exercises.bodySawRoller' => 'Scivolamenti in plank (rullo)',
			'library.abs.exercises.reverseCrunchRoller' => 'Crunch inverso (rullo)',
			'library.abs.exercises.russianTwistBodyweight' => 'Torsioni russe',
			'library.abs.exercises.legRaiseSeated' => 'Sollevamenti delle gambe (da seduti)',
			'library.abs.exercises.sideCrunchSeatedWall' => 'Crunch laterale (da seduti, alla parete)',
			'library.abs.exercises.shoulderTap' => 'Tocchi delle spalle in plank',
			'library.abs.exercises.sideBridgeHipLifts' => 'Sollevamenti del bacino in ponte laterale',
			'library.abs.exercises.lateralLegRaisesOnParallelBars' => 'Sollevamenti laterali delle gambe alle parallele',
			'library.abs.exercises.alternatingCrossBodyToeTouches' => 'Tocchi alternati dei piedi con torsione',
			'library.abs.exercises.sitUp' => 'Sit-up',
			'library.abs.exercises.sitUpArmsChest' => 'Sit-up (braccia incrociate sul petto)',
			'library.abs.exercises.sledgehammerTireStrikes' => 'Colpi di mazza sullo pneumatico',
			'library.abs.exercises.diagonalDumbbellTrunkRotations' => 'Rotazioni diagonali del busto con manubrio',
			'library.abs.exercises.twistSpine' => 'Rotazioni del busto (colonna vertebrale)',
			'library.abs.exercises.crunchStabilityBallHandsBehindHeadFull' => 'Crunch (fitball, mani dietro la testa, completo)',
			'library.abs.exercises.rolloutStandingWheel' => 'Rollout addominale (in piedi, ruota)',
			'library.abs.exercises.suspensionStrapAbdominalRollout' => 'Rollout addominale alle cinghie',
			'library.abs.exercises.reverseCrunchSuspended' => 'Crunch inverso (in sospensione)',
			'library.abs.exercises.legRaiseTwisted' => 'Sollevamenti delle gambe (con torsione)',
			'library.abs.exercises.vSitFloor' => 'Squadra a V (a terra)',
			'library.abs.exercises.crunchWeighted' => 'Crunch (con sovraccarico)',
			'library.abs.exercises.sitUpWeightedDecline' => 'Sit-up (con sovraccarico, su panca declinata)',
			'library.abs.exercises.plankWeightedFront' => 'Plank (con sovraccarico, frontale)',
			'library.abs.exercises.legHipRaiseWeightedHanging' => 'Sollevamenti di gambe e bacino (con sovraccarico, in sospensione alla sbarra)',
			'library.abs.exercises.crunchWeightedOverheadStabilityBall' => 'Crunch (con sovraccarico, sopra la testa, fitball)',
			'library.abs.exercises.russianTwistWeightedLegsUp' => 'Torsioni russe (con sovraccarico, gambe sollevate)',
			'library.abs.exercises.twistWeightedSeatedStabilityBall' => 'Rotazioni del busto (con sovraccarico, da seduti, fitball)',
			'library.abs.exercises.sideBendWeightedStabilityBall' => 'Flessioni laterali del busto (con sovraccarico, fitball)',
			'library.calves.name' => 'Polpacci',
			'library.calves.exercises.smithMachineCalfRaise' => 'Calf raise al Multipower',
			'library.calves.exercises.calfRaiseStanding' => 'Calf raise (in piedi)',
			'library.calves.exercises.calfRaiseSeated' => 'Calf raise (seduti)',
			'library.calves.exercises.calfPressLegPressMachine' => 'Calf press alla leg press',
			'library.calves.exercises.ankleRotations' => 'Rotazioni delle caviglie',
			'library.calves.exercises.calvesStretchAssistedLying' => 'Allungamento dei polpacci (con assistenza, da sdraiati)',
			'library.calves.exercises.calfRaiseBandOneLeg' => 'Sollevamenti sui polpacci (elastico, a una gamba)',
			'library.calves.exercises.reverseCalfRaiseBandOneLeg' => 'Sollevamenti delle punte dei piedi (elastico, a una gamba)',
			'library.calves.exercises.calfRaiseBandStanding' => 'Sollevamenti sui polpacci (elastico, in piedi)',
			'library.calves.exercises.calfRaiseBarbellFloor' => 'Sollevamenti sui polpacci (bilanciere, a terra)',
			'library.calves.exercises.calfRaiseBarbellSeated' => 'Sollevamenti sui polpacci (bilanciere, da seduti)',
			'library.calves.exercises.calfRaiseBarbellStanding' => 'Sollevamenti sui polpacci (bilanciere, in piedi)',
			'library.calves.exercises.calfRaiseBarbellStandingRockingLeg' => 'Sollevamenti sui polpacci (bilanciere, in piedi, con oscillazione sulle punte)',
			'library.calves.exercises.standingBodyweightCalfRaise' => 'Sollevamenti sui polpacci in piedi a corpo libero',
			'library.calves.exercises.boxDropWithSingleLegLanding' => 'Discesa dal box con atterraggio su una gamba',
			'library.calves.exercises.calfRaiseCableStanding' => 'Sollevamenti sui polpacci (cavo, in piedi)',
			'library.calves.exercises.calfRaiseCableStandingOneLeg' => 'Sollevamenti sui polpacci (cavo, in piedi, a una gamba)',
			'library.calves.exercises.wallCalfStretch' => 'Allungamento dei polpacci alla parete',
			'library.calves.exercises.calfStretchRope' => 'Allungamento dei polpacci (corda)',
			'library.calves.exercises.kneeCircles' => 'Circonduzioni delle ginocchia',
			'library.calves.exercises.calfRaiseDonkey' => 'Sollevamenti sui polpacci (busto flesso)',
			'library.calves.exercises.calfRaiseDumbbellSeated' => 'Sollevamenti sui polpacci (manubri, da seduti)',
			'library.calves.exercises.calfRaiseDumbbellSeatedOneLeg' => 'Sollevamenti sui polpacci (manubri, da seduti, a una gamba)',
			'library.calves.exercises.calfRaiseDumbbellSeatedOneLegHammerGrip' => 'Sollevamenti sui polpacci (manubri, da seduti, a una gamba, presa a martello)',
			'library.calves.exercises.calfRaiseDumbbellSeatedOneLegPalmUp' => 'Sollevamenti sui polpacci (manubri, da seduti, a una gamba, palmo verso l’alto)',
			'library.calves.exercises.calfRaiseDumbbellOneLeg' => 'Sollevamenti sui polpacci (manubri, a una gamba)',
			'library.calves.exercises.calfRaiseDumbbellStanding' => 'Sollevamenti sui polpacci (manubri, in piedi)',
			'library.calves.exercises.calfRaiseExerciseBallWall' => 'Sollevamenti sui polpacci (fitball, alla parete)',
			'library.calves.exercises.wallBallCalfRaiseBallBetweenAnkles' => 'Sollevamenti sui polpacci alla parete con palla tra le caviglie',
			'library.calves.exercises.wallBallCalfRaiseBallBetweenKnees' => 'Sollevamenti sui polpacci alla parete con palla tra le ginocchia',
			'library.calves.exercises.calfRaiseHack' => 'Sollevamenti sui polpacci (alla hack machine)',
			'library.calves.exercises.calfRaiseHackOneLeg' => 'Sollevamenti sui polpacci (alla hack machine, a una gamba)',
			'library.calves.exercises.calfPressLever' => 'Spinte per i polpacci (macchina a leva)',
			'library.calves.exercises.calfRaiseLeverDonkey' => 'Sollevamenti sui polpacci (macchina a leva, busto flesso)',
			'library.calves.exercises.rotaryCalfMachinePress' => 'Spinte dei polpacci alla macchina rotativa',
			'library.calves.exercises.calfPressLeverSeated' => 'Spinte per i polpacci (macchina a leva, da seduti)',
			'library.calves.exercises.seatedSquatCalfRaiseOnLegPress' => 'Sollevamenti dei talloni in accosciata alla pressa',
			'library.calves.exercises.calfRaiseLeverStanding' => 'Sollevamenti sui polpacci (macchina a leva, in piedi)',
			'library.calves.exercises.calfRaiseOneLegDonkey' => 'Sollevamenti sui polpacci (a una gamba, busto flesso)',
			'library.calves.exercises.calfRaiseOneLegFloor' => 'Sollevamenti sui polpacci (a una gamba, a terra)',
			'library.calves.exercises.peronealsStretch' => 'Allungamento dei peronieri',
			'library.calves.exercises.posteriorTibialisStretch' => 'Allungamento del tibiale posteriore',
			'library.calves.exercises.calfStretchSeated' => 'Allungamento dei polpacci (da seduti)',
			'library.calves.exercises.calfRaiseSledForwardAngled' => 'Sollevamenti sui polpacci (slitta, in avanti, inclinato)',
			'library.calves.exercises.calfPressSledOneLeg' => 'Spinte per i polpacci (slitta, a una gamba)',
			'library.calves.exercises.calfRaiseSmithOneLegFloor' => 'Sollevamenti sui polpacci (Smith machine, a una gamba, a terra)',
			'library.calves.exercises.toeRaiseSmith' => 'Sollevamenti delle punte dei piedi (Smith machine)',
			'library.calves.exercises.calfRaiseSmithSeatedOneLeg' => 'Sollevamenti sui polpacci (Smith machine, da seduti, a una gamba)',
			'library.calves.exercises.calfRaiseStandingStaircase' => 'Sollevamenti sui polpacci (in piedi, su gradino)',
			'library.calves.exercises.calfStretchStanding' => 'Allungamento dei polpacci (in piedi)',
			'library.calves.exercises.calfRaiseWeightedDonkey' => 'Sollevamenti sui polpacci (con sovraccarico, busto flesso)',
			'library.quadriceps.name' => 'Quadricipiti',
			'library.quadriceps.exercises.reverseDumbbellLunges' => 'Affondi indietro (manubri)',
			'library.quadriceps.exercises.walkingDumbbellLunges' => 'Affondi camminati (manubri)',
			'library.quadriceps.exercises.lateralDumbbellLunges' => 'Affondi laterali (manubrio)',
			'library.quadriceps.exercises.sumoDumbbellSquat' => 'Squat sumo (manubrio)',
			'library.quadriceps.exercises.singleLegLegPress' => 'Leg press a una gamba',
			'library.quadriceps.exercises.smithMachineSquats' => 'Squat al Multipower',
			'library.quadriceps.exercises.stepUps' => 'Step-up (manubri)',
			'library.quadriceps.exercises.gobletSquats' => 'Goblet squat (manubrio)',
			'library.quadriceps.exercises.squatsBarbell' => 'Squat (bilanciere)',
			_ => null,
		} ?? switch (path) {
			'library.quadriceps.exercises.legPress' => 'Leg press',
			'library.quadriceps.exercises.legExtension' => 'Leg extension',
			'library.quadriceps.exercises.smithMachineLunges' => 'Affondi al Multipower',
			'library.quadriceps.exercises.lunges' => 'Affondi con manubri',
			'library.quadriceps.exercises.legPress45deg' => 'Leg press (45°)',
			'library.quadriceps.exercises.frontSquats' => 'Squat frontali',
			'library.quadriceps.exercises.bulgarianSplitSquats' => 'Squat bulgari',
			'library.quadriceps.exercises.bodyweightSquats' => 'Squat a corpo libero',
			'library.quadriceps.exercises.hackSquats' => 'Hack squat',
			'library.quadriceps.exercises.quadricepsStretchQuadruped' => 'Allungamento dei quadricipiti (in quadrupedia)',
			'library.quadriceps.exercises.quadricepsStretchAssistedProne' => 'Allungamento dei quadricipiti (con assistenza, in posizione prona)',
			'library.quadriceps.exercises.backwardJump' => 'Salto all’indietro',
			'library.quadriceps.exercises.balanceBoardStance' => 'Equilibrio sulla tavoletta',
			'library.quadriceps.exercises.splitSquatBandOneArmOneLeg' => 'Split squat (elastico, a un braccio, a una gamba)',
			'library.quadriceps.exercises.splitSquatBandOneLeg' => 'Split squat (elastico, a una gamba)',
			'library.quadriceps.exercises.squatBand' => 'Squat (elastico)',
			'library.quadriceps.exercises.squatRowBand' => 'Squat e rematore (elastico)',
			'library.quadriceps.exercises.stepUpBand' => 'Salita sul gradino (elastico)',
			'library.quadriceps.exercises.frontSquatBarbellBench' => 'Squat frontale (bilanciere, su panca)',
			'library.quadriceps.exercises.squatBarbellBench' => 'Squat (bilanciere, su panca)',
			'library.quadriceps.exercises.cleanAndPressBarbell' => 'Girata e distensione (bilanciere)',
			'library.quadriceps.exercises.zercherSquatBarbellFull' => 'Zercher squat (bilanciere, completo)',
			'library.quadriceps.exercises.hackSquatBarbell' => 'Hack squat (bilanciere)',
			'library.quadriceps.exercises.squatBarbellHighBar' => 'Squat (bilanciere, bilanciere alto)',
			'library.quadriceps.exercises.jeffersonSquatBarbell' => 'Jefferson squat (bilanciere)',
			'library.quadriceps.exercises.jumpSquatBarbell' => 'Squat con salto (bilanciere)',
			'library.quadriceps.exercises.lateralLungeBarbell' => 'Affondo laterale (bilanciere)',
			'library.quadriceps.exercises.squatBarbellLowBar' => 'Squat (bilanciere, bilanciere basso)',
			'library.quadriceps.exercises.lungeBarbell' => 'Affondo (bilanciere)',
			'library.quadriceps.exercises.squatBarbellNarrowStance' => 'Squat (bilanciere, piedi ravvicinati)',
			'library.quadriceps.exercises.squatBarbellOneLeg' => 'Squat (bilanciere, a una gamba)',
			'library.quadriceps.exercises.squatBarbellOverhead' => 'Squat (bilanciere, sopra la testa)',
			'library.quadriceps.exercises.rearLungeBarbell' => 'Affondo indietro (bilanciere)',
			'library.quadriceps.exercises.splitSquatBarbellSide' => 'Split squat (bilanciere, laterale)',
			'library.quadriceps.exercises.splitSquatBarbellOneLeg' => 'Split squat (bilanciere, a una gamba)',
			'library.quadriceps.exercises.squatBarbellSpeed' => 'Squat (bilanciere, veloce)',
			'library.quadriceps.exercises.splitSquatBarbell' => 'Split squat (bilanciere)',
			'library.quadriceps.exercises.squatBarbellKnee' => 'Squat (bilanciere, sulle ginocchia)',
			'library.quadriceps.exercises.barbellSquatJumpIntoReverseLunge' => 'Squat con salto e affondo indietro con bilanciere',
			'library.quadriceps.exercises.stepUpBarbell' => 'Salita sul gradino (bilanciere)',
			'library.quadriceps.exercises.squatBarbellWide' => 'Squat (bilanciere, ampio)',
			'library.quadriceps.exercises.zercherSquatBarbell' => 'Zercher squat (bilanciere)',
			'library.quadriceps.exercises.jumpSquatBodyweightDrop' => 'Squat con salto (corpo libero, con caduta)',
			'library.quadriceps.exercises.chairSupportedQuadricepsStretch' => 'Allungamento dei quadricipiti con appoggio su sedia',
			'library.quadriceps.exercises.curtsySquat' => 'Squat con incrocio della gamba dietro',
			'library.quadriceps.exercises.squatDumbbellBench' => 'Squat (manubri, su panca)',
			'library.quadriceps.exercises.lungeDumbbellContralateralForward' => 'Affondo (manubri, in avanti con carico controlaterale)',
			'library.quadriceps.exercises.squatDumbbellPlyo' => 'Squat (manubri, pliometrico)',
			'library.quadriceps.exercises.squatDumbbellPistol' => 'Squat (manubri, pistol)',
			'library.quadriceps.exercises.squatDumbbell' => 'Squat (manubri)',
			'library.quadriceps.exercises.stepUpLungeDumbbell' => 'Salita sul gradino e affondo (manubri)',
			'library.quadriceps.exercises.stepUpSplitSquatDumbbell' => 'Salita sul gradino e split squat (manubri)',
			'library.quadriceps.exercises.squatDumbbellSupported' => 'Squat (manubri, con appoggio)',
			'library.quadriceps.exercises.farmersWalk' => 'Camminata del contadino',
			'library.quadriceps.exercises.forwardJump' => 'Salto in avanti',
			'library.quadriceps.exercises.lungeForward' => 'Affondo (in avanti)',
			'library.quadriceps.exercises.squatFrankenstein' => 'Squat (braccia tese in avanti)',
			'library.quadriceps.exercises.kneelingHipFlexorAndQuadricepsStretch' => 'Allungamento in ginocchio di flessori dell’anca e quadricipiti',
			'library.quadriceps.exercises.frontSquatKettlebell' => 'Squat frontale (kettlebell)',
			'library.quadriceps.exercises.squatKettlebellGoblet' => 'Squat (kettlebell, carico al petto)',
			'library.quadriceps.exercises.lungeKettlebellPassThrough' => 'Affondo (kettlebell, con passaggio sotto la gamba)',
			'library.quadriceps.exercises.squatKettlebellPistol' => 'Squat (kettlebell, pistol)',
			'library.quadriceps.exercises.kettlebellTurkishGetUpThroughSquat' => 'Turkish get-up con kettlebell e risalita in squat',
			'library.quadriceps.exercises.jumpSquatKneeling' => 'Squat con salto (in ginocchio)',
			'library.quadriceps.exercises.lungeJump' => 'Affondo (con salto)',
			'library.quadriceps.exercises.quadsStretchLyingSide' => 'Allungamento dei quadricipiti (da sdraiati, laterale)',
			'library.quadriceps.exercises.squatOneLeg' => 'Squat (a una gamba)',
			'library.quadriceps.exercises.squatPottySupport' => 'Squat (in accosciata profonda, con appoggio)',
			'library.quadriceps.exercises.rapidAlternatingFootTaps' => 'Appoggi rapidi alternati dei piedi',
			'library.quadriceps.exercises.legExtensionResistanceBand' => 'Estensioni delle gambe (elastico)',
			'library.quadriceps.exercises.squatPistol' => 'Squat (pistol)',
			'library.quadriceps.exercises.sissySquat' => 'Sissy squat',
			'library.quadriceps.exercises.hackSquatSledCloser' => 'Hack squat (slitta, piedi ravvicinati)',
			'library.quadriceps.exercises.squatSledLying' => 'Squat (slitta, da sdraiati)',
			'library.quadriceps.exercises.squatSmithChair' => 'Squat (Smith machine, su sedia)',
			'library.quadriceps.exercises.frontSquatSmithCleanGrip' => 'Squat frontale (Smith machine, presa da girata)',
			'library.quadriceps.exercises.hackSquatSmith' => 'Hack squat (Smith machine)',
			'library.quadriceps.exercises.squatSmithLowBar' => 'Squat (Smith machine, bilanciere basso)',
			'library.quadriceps.exercises.splitSquatSmithOneLeg' => 'Split squat (Smith machine, a una gamba)',
			'library.quadriceps.exercises.lungeSmithSprint' => 'Affondo (Smith machine, con spinta da sprint)',
			'library.quadriceps.exercises.squatSmithSumo' => 'Squat (Smith machine, sumo)',
			'library.quadriceps.exercises.snatchPull' => 'Tirata dello strappo',
			'library.quadriceps.exercises.splitSquat' => 'Split squat',
			'library.quadriceps.exercises.squatJerk' => 'Spinta in accosciata',
			'library.quadriceps.exercises.squatBosuBall' => 'Squat (BOSU)',
			'library.quadriceps.exercises.squatToOverheadReach' => 'Squat (con braccia sopra la testa)',
			'library.quadriceps.exercises.squatToOverheadReachTwist' => 'Squat (con braccia sopra la testa e torsione)',
			'library.quadriceps.exercises.splitSquatSuspended' => 'Split squat (in sospensione)',
			'library.quadriceps.exercises.lungeWalking' => 'Affondo (camminato)',
			'library.quadriceps.exercises.squatWeightedCossack' => 'Squat (con sovraccarico, cosacco)',
			'library.quadriceps.exercises.weightedLungeWithArmSwing' => 'Affondo con sovraccarico e oscillazione delle braccia',
			'library.quadriceps.exercises.sissySquatWeighted' => 'Sissy squat (con sovraccarico)',
			'library.quadriceps.exercises.squatWeighted' => 'Squat (con sovraccarico)',
			'library.quadriceps.exercises.lungeWeighted' => 'Affondo (con sovraccarico)',
			'library.hamstrings.name' => 'Posteriori della coscia',
			'library.hamstrings.exercises.singleLegDumbbellRomanianDeadlift' => 'Stacco rumeno a una gamba (manubrio)',
			'library.hamstrings.exercises.legCurlStanding' => 'Leg curl in piedi alla macchina',
			'library.hamstrings.exercises.nordicCurl' => 'Nordic curl',
			'library.hamstrings.exercises.legCurlProne' => 'Leg curl (sdraiati)',
			'library.hamstrings.exercises.legCurlSeated' => 'Leg curl (seduti)',
			'library.hamstrings.exercises.romanianDeadlift' => 'Stacchi rumeni (bilanciere)',
			'library.hamstrings.exercises.romanianDeadliftDumbbell' => 'Stacchi rumeni (manubri)',
			'library.hamstrings.exercises.hamstringStretchAssistedProne' => 'Allungamento degli ischiocrurali (con assistenza, in posizione prona)',
			'library.hamstrings.exercises.straightLegDeadliftBand' => 'Stacco a gambe tese (elastico)',
			'library.hamstrings.exercises.goodMorningBarbell' => 'Good morning (bilanciere)',
			'library.hamstrings.exercises.goodMorningBarbellSeated' => 'Good morning (bilanciere, da seduti)',
			'library.hamstrings.exercises.goodMorningBarbellStraightLeg' => 'Good morning (bilanciere, gambe tese)',
			'library.hamstrings.exercises.straightLegDeadliftBarbell' => 'Stacco a gambe tese (bilanciere)',
			'library.hamstrings.exercises.legCurlCableAssistedInverse' => 'Flessioni delle gambe (cavo, con assistenza, inverso)',
			'library.hamstrings.exercises.legCurlDumbbellLying' => 'Flessioni delle gambe (manubri, da sdraiati)',
			'library.hamstrings.exercises.straightLegDeadliftDumbbell' => 'Stacco a gambe tese (manubri)',
			'library.hamstrings.exercises.hamstringStretchExerciseBallSeated' => 'Allungamento degli ischiocrurali (fitball, da seduti)',
			'library.hamstrings.exercises.gluteHamRaiseOnBench' => 'Sollevamenti glutei-femorali su panca GHD',
			'library.hamstrings.exercises.hamstringStretch' => 'Allungamento degli ischiocrurali',
			'library.hamstrings.exercises.hangCleanKettlebell' => 'Girata dalla sospensione (kettlebell)',
			'library.hamstrings.exercises.elevatedLegHamstringStretch' => 'Allungamento degli ischiocrurali con gamba rialzata',
			'library.hamstrings.exercises.legCurlLeverKneeling' => 'Flessioni delle gambe (macchina a leva, in ginocchio)',
			'library.hamstrings.exercises.legCurlLeverLyingTwoOne' => 'Flessioni delle gambe (macchina a leva, da sdraiati, eccentrica a una gamba)',
			'library.hamstrings.exercises.goodMorningLeverSeated' => 'Good morning (macchina a leva, da seduti)',
			'library.hamstrings.exercises.cleanPower' => 'Girata (power)',
			'library.hamstrings.exercises.supineStrapAssistedHamstringStretch' => 'Allungamento degli ischiocrurali da supini con cinghia',
			'library.hamstrings.exercises.runnerSHamstringStretch' => 'Allungamento degli ischiocrurali in posizione da corridore',
			'library.hamstrings.exercises.seatedWideLegForwardFoldSequence' => 'Sequenza di flessioni da seduti a gambe divaricate',
			'library.hamstrings.exercises.singleLegSlidingCurl' => 'Flessioni di una gamba con scivolamento del tallone',
			'library.hamstrings.exercises.goodMorningSmithBentKnee' => 'Good morning (Smith machine, ginocchia piegate)',
			'library.hamstrings.exercises.strapAssistedHamstringAndCalfStretch' => 'Allungamento di ischiocrurali e polpacci con cinghia',
			'library.hamstrings.exercises.legCurlStandingBodyweight' => 'Flessioni delle gambe (in piedi)',
			'library.hamstrings.exercises.lungeStretchWithThoracicRotation' => 'Allungamento in affondo con rotazione toracica',
			'library.shoulders.name' => 'Spalle',
			'library.shoulders.exercises.standingCableReverseFly' => 'Croci inverse ai cavi in piedi',
			'library.shoulders.exercises.cableFrontRaise' => 'Alzate frontali al cavo',
			'library.shoulders.exercises.dumbbellShrugs' => 'Scrollate con manubri',
			'library.shoulders.exercises.facePull' => 'Face pull al cavo',
			'library.shoulders.exercises.shoulderPressMachine' => 'Shoulder press (macchina)',
			'library.shoulders.exercises.latRaisesInclinedBench' => 'Alzate laterali (panca inclinata)',
			'library.shoulders.exercises.latRaisesCable' => 'Alzate laterali ai cavi',
			'library.shoulders.exercises.latRaisesDualCable' => 'Alzate laterali ai cavi (entrambe le braccia)',
			'library.shoulders.exercises.reverseFlysInclinedBench' => 'Croci inverse (panca inclinata)',
			'library.shoulders.exercises.arnoldPress' => 'Arnold press',
			'library.shoulders.exercises.frontDumbbellRaise' => 'Alzate frontali con manubri',
			'library.shoulders.exercises.uprightRow' => 'Tirate al mento',
			'library.shoulders.exercises.pikePushUps' => 'Pike push-up',
			'library.shoulders.exercises.handstandPushUps' => 'Flessioni in verticale',
			'library.shoulders.exercises.bentOverLateralRaises' => 'Croci inverse al cavo basso con busto flesso',
			'library.shoulders.exercises.shoulderPress' => 'Shoulder press con manubri',
			'library.shoulders.exercises.latRaisesDumbbells' => 'Alzate laterali (manubri)',
			'library.shoulders.exercises.deltoidMachine' => 'Deltoid machine',
			'library.shoulders.exercises.shrugsBarbell' => 'Scrollate con bilanciere davanti',
			'library.shoulders.exercises.militaryPressSmithMachine' => 'Lento avanti al Multipower',
			'library.shoulders.exercises.reverseButterfly' => 'Croci inverse alla macchina',
			'library.shoulders.exercises.militaryPressBarbell' => 'Lento avanti con bilanciere',
			'library.shoulders.exercises.frontLateralRaiseBand' => 'Alzate frontali e laterali (elastico)',
			'library.shoulders.exercises.frontRaiseBand' => 'Alzate frontali (elastico)',
			'library.shoulders.exercises.reverseFlyBand' => 'Croci inverse (elastico)',
			'library.shoulders.exercises.shoulderPressBand' => 'Distensioni sopra la testa (elastico)',
			'library.shoulders.exercises.shrugBand' => 'Scrollate delle spalle (elastico)',
			'library.shoulders.exercises.rearDeltRowBandStanding' => 'Rematore per i deltoidi posteriori (elastico, in piedi)',
			'library.shoulders.exercises.overheadPressBandTwisting' => 'Distensioni sopra la testa (elastico, con torsione)',
			'library.shoulders.exercises.yRaiseBand' => 'Alzate a Y (elastico)',
			'library.shoulders.exercises.frontRaiseBarbell' => 'Alzate frontali (bilanciere)',
			'library.shoulders.exercises.frontRaiseAndPulloverBarbell' => 'Alzate frontali e pullover (bilanciere)',
			'library.shoulders.exercises.shoulderPressBarbellIncline' => 'Distensioni sopra la testa (bilanciere, su panca inclinata)',
			'library.shoulders.exercises.snatchBarbellOneArm' => 'Strappo (bilanciere, a un braccio)',
			'library.shoulders.exercises.rearDeltRaiseBarbell' => 'Alzate per i deltoidi posteriori (bilanciere)',
			'library.shoulders.exercises.rearDeltRowBarbell' => 'Rematore per i deltoidi posteriori (bilanciere)',
			'library.shoulders.exercises.militaryPressBarbellSeatedBehindHead' => 'Military press (bilanciere, da seduti, dietro la testa)',
			'library.shoulders.exercises.bradfordPressBarbellSeated' => 'Bradford press (bilanciere, da seduti)',
			'library.shoulders.exercises.barbellSkiStyleHighPull' => 'Tirata alta con bilanciere e piccolo salto',
			'library.shoulders.exercises.bradfordPressBarbellStanding' => 'Bradford press (bilanciere, in piedi)',
			'library.shoulders.exercises.militaryPressBarbellStandingCloseGrip' => 'Military press (bilanciere, in piedi, presa stretta)',
			'library.shoulders.exercises.frontRaiseBarbellStandingOverHead' => 'Alzate frontali (bilanciere, in piedi, oltre la testa)',
			'library.shoulders.exercises.militaryPressBarbellStandingWide' => 'Military press (bilanciere, in piedi, ampio)',
			'library.shoulders.exercises.thrusterBarbell' => 'Thruster (bilanciere)',
			'library.shoulders.exercises.uprightRowBarbellWideGrip' => 'Tirate al mento (bilanciere, presa larga)',
			'library.shoulders.exercises.battlingRopes' => 'Onde con le corde',
			'library.shoulders.exercises.shoulderPressCableAlternate' => 'Distensioni sopra la testa (cavo, alternato)',
			'library.shoulders.exercises.rearDeltRowCableKneelingRope' => 'Rematore per i deltoidi posteriori (cavo, in ginocchio, corda)',
			'library.shoulders.exercises.reverseFlyCableOneArmBentOver' => 'Croci inverse (cavo, a un braccio, busto inclinato)',
			'library.shoulders.exercises.rearDeltRowCableStirrups' => 'Rematore per i deltoidi posteriori (cavo, maniglie)',
			'library.shoulders.exercises.rearDeltRowCableRope' => 'Rematore per i deltoidi posteriori (cavo, corda)',
			'library.shoulders.exercises.rearLateralRaiseCableSeated' => 'Alzate per i deltoidi posteriori (cavo, da seduti)',
			'library.shoulders.exercises.shoulderInternalRotationCableSeated' => 'Intrarotazioni della spalla (cavo, da seduti)',
			'library.shoulders.exercises.shoulderPressCable' => 'Distensioni sopra la testa (cavo)',
			'library.shoulders.exercises.shrugCable' => 'Scrollate delle spalle (cavo)',
			'library.shoulders.exercises.rearDeltRowCableStandingRope' => 'Rematore per i deltoidi posteriori (cavo, in piedi, corda)',
			'library.shoulders.exercises.shoulderExternalRotationCableStanding' => 'Extrarotazioni della spalla (cavo, in piedi)',
			'library.shoulders.exercises.reverseFlyCableSupine' => 'Croci inverse (cavo, in posizione supina)',
			'library.shoulders.exercises.uprightRowCable' => 'Tirate al mento (cavo)',
			'library.shoulders.exercises.pressDumbbellAlternateSide' => 'Distensioni (manubri, alternato, laterale)',
			'library.shoulders.exercises.cubanPressDumbbell' => 'Cuban press (manubri)',
			'library.shoulders.exercises.shrugDumbbellDecline' => 'Scrollate delle spalle (manubri, su panca declinata)',
			'library.shoulders.exercises.lateralRaiseDumbbellFullCan' => 'Alzate laterali (manubri, pollici verso l’alto)',
			'library.shoulders.exercises.shoulderPressDumbbellIncline' => 'Distensioni sopra la testa (manubri, su panca inclinata)',
			'library.shoulders.exercises.shrugDumbbellIncline' => 'Scrollate delle spalle (manubri, su panca inclinata)',
			'library.shoulders.exercises.tRaiseDumbbellIncline' => 'Alzate a T (manubri, su panca inclinata)',
			'library.shoulders.exercises.lateralToFrontRaiseDumbbell' => 'Alzate laterali e frontali (manubri)',
			'library.shoulders.exercises.externalShoulderRotationDumbbellLying' => 'Extrarotazioni della spalla (manubri, da sdraiati)',
			'library.shoulders.exercises.rearDeltRaiseDumbbellLyingFloor' => 'Alzate per i deltoidi posteriori (manubri, da sdraiati, a terra)',
			'library.shoulders.exercises.rearDeltRaiseDumbbellLyingOneArm' => 'Alzate per i deltoidi posteriori (manubri, da sdraiati, a un braccio)',
			'library.shoulders.exercises.reverseFlyDumbbellLyingOneArm' => 'Croci inverse (manubri, da sdraiati, a un braccio)',
			'library.shoulders.exercises.rearDeltRowDumbbellLying' => 'Rematore per i deltoidi posteriori (manubri, da sdraiati)',
			'library.shoulders.exercises.reverseFlyDumbbellLying' => 'Croci inverse (manubri, da sdraiati)',
			'library.shoulders.exercises.lateralRaiseDumbbellOneArm' => 'Alzate laterali (manubri, a un braccio)',
			'library.shoulders.exercises.lateralRaiseDumbbellOneArmSupport' => 'Alzate laterali (manubri, a un braccio, con appoggio)',
			'library.shoulders.exercises.reverseFlyDumbbellOneArmSupport' => 'Croci inverse (manubri, a un braccio, con appoggio)',
			'library.shoulders.exercises.shoulderPressDumbbellOneArm' => 'Distensioni sopra la testa (manubri, a un braccio)',
			'library.shoulders.exercises.uprightRowDumbbellOneArm' => 'Tirate al mento (manubri, a un braccio)',
			'library.shoulders.exercises.pushPressDumbbell' => 'Push press (manubri)',
			'library.shoulders.exercises.reverseFlyDumbbellBentOver' => 'Croci inverse (manubri, busto inclinato)',
			'library.shoulders.exercises.rearDeltRowDumbbell' => 'Rematore per i deltoidi posteriori (manubri)',
			'library.shoulders.exercises.rearLateralRaiseDumbbellSupportHead' => 'Alzate per i deltoidi posteriori (manubri, testa appoggiata)',
			'library.shoulders.exercises.reverseFlyDumbbellRotation' => 'Croci inverse (manubri, con rotazione)',
			'library.shoulders.exercises.scottPressDumbbell' => 'Scott press (manubri)',
			'library.shoulders.exercises.frontRaiseDumbbellSeatedAlternate' => 'Alzate frontali (manubri, da seduti, alternato)',
			'library.shoulders.exercises.shoulderPressDumbbellSeatedAlternate' => 'Distensioni sopra la testa (manubri, da seduti, alternato)',
			'library.shoulders.exercises.lateralRaiseDumbbellSeatedBentArm' => 'Alzate laterali (manubri, da seduti, braccia flesse)',
			'library.shoulders.exercises.bicepsCurlToShoulderPressDumbbellSeated' => 'Curl e distensioni sopra la testa (manubri, da seduti)',
			'library.shoulders.exercises.frontRaiseDumbbellSeated' => 'Alzate frontali (manubri, da seduti)',
			'library.shoulders.exercises.lateralRaiseDumbbellSeated' => 'Alzate laterali (manubri, da seduti)',
			'library.shoulders.exercises.shoulderPressDumbbellSeatedNeutralGrip' => 'Distensioni sopra la testa (manubri, da seduti, presa neutra)',
			'library.shoulders.exercises.lateralRaiseDumbbellSideLyingOneArm' => 'Alzate laterali (manubri, sdraiati sul fianco, a un braccio)',
			'library.shoulders.exercises.reverseFlyDumbbellSidePlank' => 'Croci inverse (manubri, in plank laterale)',
			'library.shoulders.exercises.singleArmOverheadDumbbellCarry' => 'Camminata con manubrio sopra la testa a un braccio',
			'library.shoulders.exercises.overheadPressDumbbellStandingAlternate' => 'Distensioni sopra la testa (manubri, in piedi, alternato)',
			'library.shoulders.exercises.lateralRaiseDumbbellStandingAlternate' => 'Alzate laterali (manubri, in piedi, alternato)',
			'library.shoulders.exercises.standingDumbbellArmCircles' => 'Circonduzioni delle braccia in piedi con manubri',
			'library.shoulders.exercises.frontRaiseDumbbellStandingAboveHead' => 'Alzate frontali (manubri, in piedi, oltre la testa)',
			'library.shoulders.exercises.pressDumbbellStandingOneArmNeutralGrip' => 'Distensioni (manubri, in piedi, a un braccio, presa neutra)',
			'library.shoulders.exercises.overheadPressDumbbellStanding' => 'Distensioni sopra la testa (manubri, in piedi)',
			'library.shoulders.exercises.pressDumbbellStandingNeutralGrip' => 'Distensioni (manubri, in piedi, presa neutra)',
			'library.shoulders.exercises.uprightRowDumbbell' => 'Tirate al mento (manubri)',
			'library.shoulders.exercises.shoulderExternalRotationDumbbellUpright' => 'Extrarotazioni della spalla (manubri, busto eretto)',
			'library.shoulders.exercises.wPressDumbbell' => 'Distensioni a W (manubri)',
			'library.shoulders.exercises.frontRaiseDumbbellSeatedAlternateExerciseBall' => 'Alzate frontali (manubri, da seduti, alternato, fitball)',
			'library.shoulders.exercises.shoulderPressEzBarbell' => 'Distensioni sopra la testa (bilanciere EZ)',
			'library.shoulders.exercises.frogStand' => 'Equilibrio a rana sulle mani',
			'library.shoulders.exercises.fullMalteseHold' => 'Tenuta Maltese completa',
			'library.shoulders.exercises.fullPlancheHold' => 'Tenuta planche completa',
			'library.shoulders.exercises.pushUpFullPlanche' => 'Piegamenti sulle braccia (completo, in planche)',
			'library.shoulders.exercises.handstand' => 'Verticale sulle mani',
			'library.shoulders.exercises.pressKettlebellAlternate' => 'Distensioni (kettlebell, alternato)',
			'library.shoulders.exercises.arnoldPressKettlebell' => 'Arnold press (kettlebell)',
			'library.shoulders.exercises.jerkKettlebellDouble' => 'Spinta in slancio (kettlebell, con due kettlebell)',
			'library.shoulders.exercises.pushPressKettlebellDouble' => 'Push press (kettlebell, con due kettlebell)',
			'library.shoulders.exercises.snatchKettlebellDouble' => 'Strappo (kettlebell, con due kettlebell)',
			'library.shoulders.exercises.cleanAndJerkKettlebellOneArm' => 'Slancio (kettlebell, a un braccio)',
			'library.shoulders.exercises.jerkKettlebellOneArm' => 'Spinta in slancio (kettlebell, a un braccio)',
			'library.shoulders.exercises.militaryPressKettlebellOneArmToSide' => 'Military press (kettlebell, a un braccio, verso il lato)',
			'library.shoulders.exercises.pushPressKettlebellOneArm' => 'Push press (kettlebell, a un braccio)',
			'library.shoulders.exercises.snatchKettlebellOneArm' => 'Strappo (kettlebell, a un braccio)',
			'library.shoulders.exercises.cleanAndPressKettlebellOneArm' => 'Girata e distensione (kettlebell, a un braccio)',
			'library.shoulders.exercises.pressKettlebellSeated' => 'Distensioni (kettlebell, da seduti)',
			'library.shoulders.exercises.militaryPressKettlebellSeatedTwoArm' => 'Military press (kettlebell, da seduti, a due braccia)',
			'library.shoulders.exercises.pressKettlebellSeesaw' => 'Distensioni (kettlebell, a bilanciere alternato)',
			'library.shoulders.exercises.sumoHighPullKettlebell' => 'Tirate alte sumo (kettlebell)',
			'library.shoulders.exercises.thrusterKettlebell' => 'Thruster (kettlebell)',
			'library.shoulders.exercises.cleanKettlebellTwoArm' => 'Girata (kettlebell, a due braccia)',
			'library.shoulders.exercises.militaryPressKettlebellTwoArm' => 'Military press (kettlebell, a due braccia)',
			'library.shoulders.exercises.lateralRaiseLandmine' => 'Alzate laterali (landmine)',
			'library.shoulders.exercises.plancheLean' => 'Planche (con sbilanciamento in avanti)',
			'library.shoulders.exercises.boxingLeftHook' => 'Gancio sinistro di pugilato',
			'library.shoulders.exercises.shrugLeverGripless' => 'Scrollate delle spalle (macchina a leva, senza presa delle mani)',
			'library.shoulders.exercises.shoulderPressLeverOneArm' => 'Distensioni sopra la testa (macchina a leva, a un braccio)',
			'library.shoulders.exercises.reverseFlyLeverSeatedNeutralGrip' => 'Croci inverse (macchina a leva, da seduti, presa neutra)',
			'library.shoulders.exercises.shrugLever' => 'Scrollate delle spalle (macchina a leva)',
			'library.shoulders.exercises.rearDeltoidStretch' => 'Allungamento dei deltoidi posteriori',
			'library.shoulders.exercises.shoulderPressResistanceBandSeated' => 'Distensioni sopra la testa (elastico, da seduti)',
			'library.shoulders.exercises.scapularDips' => 'Dip scapolari',
			'library.shoulders.exercises.scapularPullUp' => 'Trazioni scapolari',
			'library.shoulders.exercises.shrugSmithBack' => 'Scrollate delle spalle (Smith machine, posteriore)',
			'library.shoulders.exercises.pressSmithBehindNeck' => 'Distensioni (Smith machine, dietro la nuca)',
			'library.shoulders.exercises.rearDeltRowSmith' => 'Rematore per i deltoidi posteriori (Smith machine)',
			'library.shoulders.exercises.shoulderPressSmithSeated' => 'Distensioni sopra la testa (Smith machine, da seduti)',
			'library.shoulders.exercises.shoulderPressSmith' => 'Distensioni sopra la testa (Smith machine)',
			'library.shoulders.exercises.shrugSmith' => 'Scrollate delle spalle (Smith machine)',
			'library.shoulders.exercises.militaryPressSmithStandingBehindHead' => 'Military press (Smith machine, in piedi, dietro la testa)',
			'library.shoulders.exercises.uprightRowSmith' => 'Tirate al mento (Smith machine)',
			'library.shoulders.exercises.pressStandingBehindNeck' => 'Distensioni (in piedi, dietro la nuca)',
			'library.shoulders.exercises.straddleMalteseHold' => 'Tenuta Maltese a gambe divaricate',
			'library.shoulders.exercises.straddlePlancheHold' => 'Tenuta planche a gambe divaricate',
			'library.shoulders.exercises.frontRaiseWeighted' => 'Alzate frontali (con sovraccarico)',
			'library.shoulders.exercises.weightedKneelingStepAndSwing' => 'Passo in ginocchio con oscillazione del carico',
			'library.back.name' => 'Schiena',
			'library.back.exercises.chestSupportedDumbbellRow' => 'Rematore con petto appoggiato su panca (manubri)',
			'library.back.exercises.singleArmCableRow' => 'Rematore a un braccio al cavo',
			'library.back.exercises.ringRow' => 'Rematore agli anelli',
			'library.back.exercises.dumbbellPullover' => 'Pullover con manubrio',
			'library.back.exercises.machineAssistedPullUps' => 'Trazioni assistite alla macchina',
			'library.back.exercises.hyperExtensions' => 'Iperestensioni',
			'library.back.exercises.weightedHyperExtensions' => 'Iperestensioni con peso',
			'library.back.exercises.barbellRow' => 'Rematore con bilanciere',
			'library.back.exercises.triangleBarLatPulldowns' => 'Lat machine (con triangolo)',
			'library.back.exercises.underhandGripLatPulldowns' => 'Lat machine (presa supina)',
			'library.back.exercises.latPulldowns' => 'Lat machine',
			'library.back.exercises.cableSeatedRowTriangleBar' => 'Rematore al cavo (con triangolo)',
			'library.back.exercises.straightArmCablePushdown' => 'Pulldown a braccia dritte',
			'library.back.exercises.deadlift' => 'Stacchi',
			'library.back.exercises.pullUps' => 'Trazioni alla sbarra (presa prona)',
			'library.back.exercises.tBarRow' => 'Rematore con bilanciere a T',
			'library.back.exercises.rowMachine' => 'Rematore alla macchina da seduto',
			'library.back.exercises.latPulldownsNarrowGrip' => 'Lat machine (presa stretta)',
			'library.back.exercises.latPulldownsWideGrip' => 'Lat machine (presa larga)',
			'library.back.exercises.tBarRowWideProneGrip' => 'Rematore alla T-bar machine (presa larga prona)',
			'library.back.exercises.dumbbellRow' => 'Rematore con manubrio',
			'library.back.exercises.chinUps' => 'Trazioni alla sbarra (presa supina)',
			'library.back.exercises.pulldownCableAlternate' => 'Pulldown (cavo, alternato)',
			'library.back.exercises.pullUpArcher' => 'Trazioni alla sbarra (arciere)',
			'library.back.exercises.pullUpAssistedParallelCloseGrip' => 'Trazioni alla sbarra (con assistenza, presa parallela, presa stretta)',
			'library.back.exercises.chinUpAssistedStanding' => 'Trazioni a presa supina (con assistenza, in piedi)',
			'library.back.exercises.pullUpAssistedStanding' => 'Trazioni alla sbarra (con assistenza, in piedi)',
			'library.back.exercises.backExtensionExerciseBall' => 'Estensioni della schiena (fitball)',
			'library.back.exercises.backLever' => 'Back lever',
			'library.back.exercises.chestStretchWithArmsBehindTheBack' => 'Allungamento del petto con braccia dietro la schiena',
			'library.back.exercises.pullUpBandAssisted' => 'Trazioni alla sbarra (elastico, con assistenza)',
			'library.back.exercises.pulldownBandCloseGrip' => 'Pulldown (elastico, presa stretta)',
			'library.back.exercises.pulldownBandFixedBackCloseGrip' => 'Pulldown (elastico, schiena stabilizzata, presa stretta)',
			'library.back.exercises.pulldownBandFixedBackUnderhand' => 'Pulldown (elastico, schiena stabilizzata, presa supina)',
			'library.back.exercises.pulldownBandKneelingOneArm' => 'Pulldown (elastico, in ginocchio, a un braccio)',
			'library.back.exercises.rowBandOneArmStandingLow' => 'Rematore (elastico, a un braccio, in piedi, basso)',
			'library.back.exercises.rowBandOneArmTwistingSeated' => 'Rematore (elastico, a un braccio, con torsione, da seduti)',
			'library.back.exercises.pulldownBandUnderhand' => 'Pulldown (elastico, presa supina)',
			'library.back.exercises.pulloverBarbellBentArm' => 'Pullover (bilanciere, braccia flesse)',
			'library.back.exercises.pulloverBarbellDeclineBentArm' => 'Pullover (bilanciere, su panca declinata, braccia flesse)',
			'library.back.exercises.pulloverBarbellDeclineWideGrip' => 'Pullover (bilanciere, su panca declinata, presa larga)',
			'library.back.exercises.rowBarbellIncline' => 'Rematore (bilanciere, su panca inclinata)',
			'library.back.exercises.bentOverRowBarbellOneArm' => 'Rematore a busto inclinato (bilanciere, a un braccio)',
			'library.back.exercises.pendlayRowBarbell' => 'Rematore Pendlay (bilanciere)',
			'library.back.exercises.pulloverBarbell' => 'Pullover (bilanciere)',
			'library.back.exercises.pulloverToPressBarbell' => 'Pullover e distensione (bilanciere)',
			'library.back.exercises.bentOverRowBarbellReverseGrip' => 'Rematore a busto inclinato (bilanciere, presa supina)',
			'library.back.exercises.benchRowBarbellReverseGripIncline' => 'Rematore su panca (bilanciere, presa supina, su panca inclinata)',
			'library.back.exercises.benchSupportedPullUp' => 'Trazioni con appoggio sulla panca',
			'library.back.exercises.rowBodyweightSquatting' => 'Rematore (corpo libero, in accosciata)',
			'library.back.exercises.rowBodyweightSquattingTowel' => 'Rematore (corpo libero, in accosciata, asciugamano)',
			'library.back.exercises.rowBodyweightStandingCloseGripOneArm' => 'Rematore (corpo libero, in piedi, presa stretta, a un braccio)',
			'library.back.exercises.rowBodyweightStandingCloseGrip' => 'Rematore (corpo libero, in piedi, presa stretta)',
			'library.back.exercises.rowBodyweightStandingOneArm' => 'Rematore (corpo libero, in piedi, a un braccio)',
			'library.back.exercises.rowBodyweightStandingOneArmTowel' => 'Rematore (corpo libero, in piedi, a un braccio, asciugamano)',
			'library.back.exercises.rowBodyweightStanding' => 'Rematore (corpo libero, in piedi)',
			'library.back.exercises.rowBodyweightStandingTowel' => 'Rematore (corpo libero, in piedi, asciugamano)',
			'library.back.exercises.latPulldownCableCrossover' => 'Lat machine (cavo, incrociato)',
			'library.back.exercises.rowCableDeclineSeatedWideGrip' => 'Rematore (cavo, su panca declinata, da seduti, presa larga)',
			'library.back.exercises.rowCableFloorSeatedWideGrip' => 'Rematore (cavo, a terra, da seduti, presa larga)',
			'library.back.exercises.rowCableHighKneeling' => 'Rematore (cavo, alto, in ginocchio)',
			'library.back.exercises.benchRowCableIncline' => 'Rematore su panca (cavo, su panca inclinata)',
			'library.back.exercises.latPulldownCableRope' => 'Lat machine (cavo, corda)',
			'library.back.exercises.rowCableSeated' => 'Rematore (cavo, da seduti)',
			'library.back.exercises.pulloverCableLyingRope' => 'Pullover (cavo, da sdraiati, corda)',
			'library.back.exercises.pulldownCableOneArm' => 'Pulldown (cavo, a un braccio)',
			'library.back.exercises.rowCableOneArmStraightBackHighKneeling' => 'Rematore (cavo, a un braccio, schiena dritta, alto, in ginocchio)',
			'library.back.exercises.rowCablePalmRotational' => 'Rematore (cavo, con rotazione della presa)',
			'library.back.exercises.latPulldownWithCurvedBar' => 'Lat machine con barra sagomata',
			'library.back.exercises.pulldownCableRear' => 'Pulldown (cavo, posteriore)',
			'library.back.exercises.rowCableReverseGripStraightBackSeatedHigh' => 'Rematore (cavo, presa supina, schiena dritta, da seduti, alto)',
			'library.back.exercises.rowCableRopeCrossoverSeated' => 'Rematore (cavo, corda, incrociato, da seduti)',
			'library.back.exercises.rowCableRopeElevatedSeated' => 'Rematore (cavo, corda, rialzato, da seduti)',
			'library.back.exercises.benchRowCableRopeExtensionIncline' => 'Rematore su panca (cavo, corda, con estensione, su panca inclinata)',
			'library.back.exercises.rowCableRopeSeated' => 'Rematore (cavo, corda, da seduti)',
			'library.back.exercises.rowCableSeatedOneArmAlternate' => 'Rematore (cavo, da seduti, a un braccio, alternato)',
			'library.back.exercises.rowCableSeatedWideGrip' => 'Rematore (cavo, da seduti, presa larga)',
			'library.back.exercises.squatRowCableRope' => 'Squat e rematore (cavo, corda)',
			'library.back.exercises.rowCableStandingVBar' => 'Rematore (cavo, in piedi, barra a V)',
			'library.back.exercises.twistRowCableStandingVBar' => 'Rematore con torsione (cavo, in piedi, barra a V)',
			'library.back.exercises.cableKayakRow' => 'Rematore al cavo con movimento da kayak',
			'library.back.exercises.twistRowCableOneArm' => 'Rematore con torsione (cavo, a un braccio)',
			'library.back.exercises.rowCableUpper' => 'Rematore (cavo, alto)',
			'library.back.exercises.pulldownCableWideGripRearBehindNeck' => 'Pulldown (cavo, presa larga, posteriore, dietro la nuca)',
			'library.back.exercises.rowCamberedBarLying' => 'Rematore (bilanciere curvo, da sdraiati)',
			'library.back.exercises.closeNeutralGripPullUp' => 'Trazioni a presa neutra stretta',
			'library.back.exercises.bentOverRowDumbbell' => 'Rematore a busto inclinato (manubri)',
			'library.back.exercises.yRaiseDumbbellIncline' => 'Alzate a Y (manubri, su panca inclinata)',
			'library.back.exercises.bentOverRowDumbbellPalmRotational' => 'Rematore a busto inclinato (manubri, con rotazione della presa)',
			'library.back.exercises.rowDumbbellReverseGripInclineBenchOneArm' => 'Rematore (manubri, presa supina, su panca inclinata, a un braccio)',
			'library.back.exercises.rowDumbbellReverseGripInclineBenchTwoArm' => 'Rematore (manubri, presa supina, su panca inclinata, a due braccia)',
			'library.back.exercises.rowDumbbellReverseGrip' => 'Rematore (manubri, presa supina)',
			'library.back.exercises.bodyweightHipHinge' => 'Flessioni del busto con cerniera d’anca a corpo libero',
			'library.back.exercises.backExtensionExerciseBallStraightArm' => 'Estensioni della schiena (fitball, braccia tese)',
			'library.back.exercises.backExtensionExerciseBallHandsBehindHead' => 'Estensioni della schiena (fitball, mani dietro la testa)',
			'library.back.exercises.backExtensionExerciseBallKneeOffGround' => 'Estensioni della schiena (fitball, ginocchia sollevate)',
			'library.back.exercises.backExtensionExerciseBallRotation' => 'Estensioni della schiena (fitball, con rotazione)',
			'library.back.exercises.seatedBackStretchHuggingABall' => 'Allungamento della schiena da seduti abbracciando la fitball',
			'library.back.exercises.latStretchExerciseBall' => 'Allungamento dei dorsali (fitball)',
			'library.back.exercises.pyramidPositionBackStretchOnBall' => 'Allungamento della schiena a piramide sulla fitball',
			'library.back.exercises.latStretchExerciseBallLyingSide' => 'Allungamento dei dorsali (fitball, da sdraiati, laterale)',
			'library.back.exercises.legRaiseExerciseBallProne' => 'Sollevamenti delle gambe (fitball, in posizione prona)',
			'library.back.exercises.pulloverEzBarLyingBentArm' => 'Pullover (bilanciere EZ, da sdraiati, braccia flesse)',
			'library.back.exercises.bentOverRowEzBarReverseGrip' => 'Rematore a busto inclinato (bilanciere EZ, presa supina)',
			'library.back.exercises.frontLever' => 'Front lever',
			'library.back.exercises.frontLeverReps' => 'Front lever (dinamico)',
			'library.back.exercises.sternumToBarChinUp' => 'Trazioni con lo sterno verso la sbarra',
			'library.back.exercises.invertedRow' => 'Rematore inverso',
			'library.back.exercises.invertedRowBentKnee' => 'Rematore inverso (ginocchia piegate)',
			'library.back.exercises.invertedRowBench' => 'Rematore inverso (su panca)',
			'library.back.exercises.renegadeRowKettlebellAlternate' => 'Rematore in plank (kettlebell, alternato)',
			'library.back.exercises.rowKettlebellAlternate' => 'Rematore (kettlebell, alternato)',
			'library.back.exercises.rowKettlebellOneArm' => 'Rematore (kettlebell, a un braccio)',
			'library.back.exercises.rowKettlebellTwoArm' => 'Rematore (kettlebell, a due braccia)',
			'library.back.exercises.muscleUpKipping' => 'Muscle-up (con slancio)',
			'library.back.exercises.latStretchKneeling' => 'Allungamento dei dorsali (in ginocchio)',
			'library.back.exercises.pullUpL' => 'Trazioni alla sbarra (gambe a L)',
			'library.back.exercises.rowLeverAlternateNarrowGripSeated' => 'Rematore (macchina a leva, alternato, presa stretta, da seduti)',
			'library.back.exercises.chinUpLeverAssisted' => 'Trazioni a presa supina (macchina a leva, con assistenza)',
			'library.back.exercises.backExtensionLever' => 'Estensioni della schiena (macchina a leva)',
			'library.back.exercises.bentOverRowLever' => 'Rematore a busto inclinato (macchina a leva)',
			'library.back.exercises.bentOverRowLeverVBar' => 'Rematore a busto inclinato (macchina a leva, barra a V)',
			'library.back.exercises.pulldownLeverFront' => 'Pulldown (macchina a leva, frontale)',
			'library.back.exercises.rowLeverHigh' => 'Rematore (macchina a leva, alto)',
			'library.back.exercises.bentOverRowLeverOneArm' => 'Rematore a busto inclinato (macchina a leva, a un braccio)',
			'library.back.exercises.rowLeverOneArmLateralHigh' => 'Rematore (macchina a leva, a un braccio, laterale, alto)',
			'library.back.exercises.pulldownLeverOneArmLateralWide' => 'Pulldown (macchina a leva, a un braccio, laterale, ampio)',
			'library.back.exercises.pulloverLever' => 'Pullover (macchina a leva)',
			'library.back.exercises.latPulldownLeverReverseGrip' => 'Lat machine (macchina a leva, presa supina)',
			'library.back.exercises.rowLeverReverseGripVertical' => 'Rematore (macchina a leva, presa supina, verticale)',
			'library.back.exercises.rowLeverReverseTBar' => 'Rematore (macchina a leva, inverso, barra a T)',
			'library.back.exercises.rowLeverTBar' => 'Rematore (macchina a leva, barra a T)',
			'library.back.exercises.rowLeverTBarReverseGrip' => 'Rematore (macchina a leva, barra a T, presa supina)',
			'library.back.exercises.rowLeverOneArm' => 'Rematore (macchina a leva, a un braccio)',
			'library.back.exercises.standingAnchoredRopeRow' => 'Rematore in piedi con corda ancorata',
			'library.back.exercises.seatedSpinalFlexion' => 'Flessioni della colonna da seduti',
			'library.back.exercises.medicineBallCatchAndOverheadToss' => 'Presa e lancio sopra la testa della palla medica',
			'library.back.exercises.overheadMedicineBallSlam' => 'Schiacciata a terra della palla medica da sopra la testa',
			'library.back.exercises.chinUpMixedGrip' => 'Trazioni a presa supina (presa mista)',
			'library.back.exercises.muscleUp' => 'Muscle-up',
			'library.back.exercises.muscleUpVerticalBar' => 'Muscle-up (verticale, barra)',
			'library.back.exercises.neckStretchSide' => 'Allungamento del collo (laterale)',
			'library.back.exercises.singleArmWallLatStretch' => 'Allungamento del dorsale a un braccio alla parete',
			'library.back.exercises.chinUpOneArm' => 'Trazioni a presa supina (a un braccio)',
			'library.back.exercises.rowOneArmTowel' => 'Rematore (a un braccio, asciugamano)',
			'library.back.exercises.pullUpNeutralGrip' => 'Trazioni alla sbarra (presa neutra)',
			'library.back.exercises.pullUpRear' => 'Trazioni alla sbarra (posteriore)',
			'library.back.exercises.rowResistanceBandSeatedStraightBack' => 'Rematore (elastico, da seduti, schiena dritta)',
			'library.back.exercises.pulldownLeverReverseGrip' => 'Pulldown (macchina a leva, presa supina)',
			'library.back.exercises.alternatingFrontAndBackPullUp' => 'Trazioni alternate davanti e dietro la testa',
			'library.back.exercises.backStretchRoller' => 'Allungamento della schiena (rullo)',
			'library.back.exercises.latStretchRollerSide' => 'Allungamento dei dorsali (rullo, laterale)',
			'library.back.exercises.ropeClimbing' => 'Salita alla corda',
			'library.back.exercises.lowerBackStretchSeated' => 'Allungamento lombare (da seduti)',
			'library.back.exercises.latStretchSideLyingFloor' => 'Allungamento dei dorsali (sdraiati sul fianco, a terra)',
			'library.back.exercises.neckStretchSidePush' => 'Allungamento del collo (laterale, con spinta)',
			'library.back.exercises.sideToSideChinUp' => 'Trazioni supine con spostamento laterale',
			'library.back.exercises.skinTheCatRotation' => 'Rotazione completa in sospensione alla sbarra',
			'library.back.exercises.bentOverRowSmith' => 'Rematore a busto inclinato (Smith machine)',
			'library.back.exercises.rowSmithNarrow' => 'Rematore (Smith machine, stretto)',
			'library.back.exercises.rowSmithOneArm' => 'Rematore (Smith machine, a un braccio)',
			'library.back.exercises.bentOverRowSmithReverseGrip' => 'Rematore a busto inclinato (Smith machine, presa supina)',
			'library.back.exercises.proneSphinxStretch' => 'Allungamento in posizione della sfinge',
			'library.back.exercises.spineStretch' => 'Allungamento della colonna',
			'library.back.exercises.standingArcherPull' => 'Tirata dell’arciere in piedi',
			'library.back.exercises.latStretchStandingLateral' => 'Allungamento dei dorsali (in piedi, laterale)',
			'library.back.exercises.pelvicTiltStanding' => 'Retroversioni del bacino (in piedi)',
			'library.back.exercises.pulldownCableNeutralGrip' => 'Pulldown (cavo, presa neutra)',
			'library.back.exercises.forwardFoldReachingBothToes' => 'Flessione in avanti verso entrambe le punte dei piedi',
			'library.back.exercises.upperBackStretch' => 'Allungamento della parte alta della schiena',
			'library.back.exercises.upwardFacingDogStretch' => 'Allungamento nella posizione del cane a testa in su',
			'library.back.exercises.chinUpWeightedCloseGripDipCage' => 'Trazioni a presa supina (con sovraccarico, presa stretta, stazione dip)',
			'library.back.exercises.hyperextensionWeightedStabilityBall' => 'Iperestensioni (con sovraccarico, fitball)',
			'library.back.exercises.muscleUpWeighted' => 'Muscle-up (con sovraccarico)',
			'library.back.exercises.muscleUpWeightedBar' => 'Muscle-up (con sovraccarico, barra)',
			'library.back.exercises.pullUpWeightedOneArm' => 'Trazioni alla sbarra (con sovraccarico, a un braccio)',
			'library.back.exercises.pullUpWeighted' => 'Trazioni alla sbarra (con sovraccarico)',
			'library.back.exercises.pullUpWideGrip' => 'Trazioni alla sbarra (presa larga)',
			'library.back.exercises.pullUpWideGripRear' => 'Trazioni alla sbarra (presa larga, posteriore)',
			'library.back.exercise.dualLowRowMachine' => 'Dual low row machine',
			'library.back.exercise.dualHighRowMachine' => 'Dual high row machine',
			'library.triceps.name' => 'Tricipiti',
			'library.triceps.exercises.barTricepsPushdown' => 'Pushdown dei tricipiti con barra',
			'library.triceps.exercises.singleArmTricepsPushdown' => 'Pushdown dei tricipiti a un braccio',
			'library.triceps.exercises.machineAssistedDips' => 'Dip assistiti alla macchina',
			'library.triceps.exercises.dips' => 'Dip',
			'library.triceps.exercises.overheadRopeTricepExtension' => 'Estensioni dei tricipiti sopra la testa con corda al cavo',
			'library.triceps.exercises.tricepsRopePushdown' => 'Pushdown dei tricipiti con corda',
			'library.triceps.exercises.tricepKickbacks' => 'Kickback per i tricipiti',
			'library.triceps.exercises.skullCrushers' => 'French press su panca (skull crusher)',
			'library.triceps.exercises.benchDips' => 'Dip alla panca',
			'library.triceps.exercises.diamondPushUps' => 'Flessioni a diamante',
			'library.triceps.exercises.tricepsMachine' => 'Triceps machine',
			'library.triceps.exercises.overheadTricepExtension' => 'Estensioni dei tricipiti sopra la testa con manubri',
			'library.triceps.exercises.tricepsExtensionAssistedStandingTowel' => 'Estensioni per i tricipiti (con assistenza, in piedi, asciugamano)',
			'library.triceps.exercises.pushUpBandCloseGrip' => 'Piegamenti sulle braccia (elastico, presa stretta)',
			'library.triceps.exercises.tricepsExtensionBandSide' => 'Estensioni per i tricipiti (elastico, laterale)',
			'library.triceps.exercises.benchPressBarbellCloseGrip' => 'Distensioni su panca (bilanciere, presa stretta)',
			'library.triceps.exercises.declineCloseGripPressIntoSkullCrusher' => 'Distensioni a presa stretta e skull crusher su panca declinata',
			'library.triceps.exercises.benchPressBarbellInclineCloseGrip' => 'Distensioni su panca (bilanciere, su panca inclinata, presa stretta)',
			'library.triceps.exercises.pressBarbellInclineReverseGrip' => 'Distensioni (bilanciere, su panca inclinata, presa supina)',
			'library.triceps.exercises.tricepsExtensionBarbellLyingBackOfHead' => 'Estensioni per i tricipiti (bilanciere, da sdraiati, dietro la testa)',
			'library.triceps.exercises.floorPressBarbellOneArm' => 'Distensioni da terra (bilanciere, a un braccio)',
			'library.triceps.exercises.pinPressesBarbell' => 'Distensioni dai fermi (bilanciere)',
			'library.triceps.exercises.benchPressBarbellReverseCloseGrip' => 'Distensioni su panca (bilanciere, inverso, presa stretta)',
			'library.triceps.exercises.skullcrusherBarbellReverseGrip' => 'Skull crusher (bilanciere, presa supina)',
			'library.triceps.exercises.tricepsExtensionBarbellSeatedCloseGripBehindNeck' => 'Estensioni per i tricipiti (bilanciere, da seduti, presa stretta, dietro la nuca)',
			'library.triceps.exercises.tricepsExtensionBarbellSeatedOverhead' => 'Estensioni per i tricipiti (bilanciere, da seduti, sopra la testa)',
			'library.triceps.exercises.tricepsExtensionBarbellStandingOverhead' => 'Estensioni per i tricipiti (bilanciere, in piedi, sopra la testa)',
			'library.triceps.exercises.tricepsExtensionBodyweightKneeling' => 'Estensioni per i tricipiti (corpo libero, in ginocchio)',
			'library.triceps.exercises.tricepsExtensionCableAlternate' => 'Estensioni per i tricipiti (cavo, alternato)',
			'library.triceps.exercises.extensionCableConcentrationKnee' => 'Estensioni per i tricipiti (cavo, concentrato, sulle ginocchia)',
			'library.triceps.exercises.tricepsExtensionCableHighPulleyOverhead' => 'Estensioni per i tricipiti (cavo, carrucola alta, sopra la testa)',
			'library.triceps.exercises.tricepsExtensionCableIncline' => 'Estensioni per i tricipiti (cavo, su panca inclinata)',
			'library.triceps.exercises.kickbackCable' => 'Kickback per i tricipiti (cavo)',
			'library.triceps.exercises.tricepsExtensionCableKneeling' => 'Estensioni per i tricipiti (cavo, in ginocchio)',
			'library.triceps.exercises.tricepsExtensionCableLying' => 'Estensioni per i tricipiti (cavo, da sdraiati)',
			'library.triceps.exercises.cableRearwardTricepsDrive' => 'Spinta dei tricipiti all’indietro al cavo',
			'library.triceps.exercises.tricepsPushdownCableReverseGripSzBarArmBlaster' => 'Pushdown per i tricipiti (cavo, presa supina, barra EZ, arm blaster)',
			'library.triceps.exercises.pushdownCableReverseGrip' => 'Pushdown per i tricipiti (cavo, presa supina)',
			'library.triceps.exercises.tricepsExtensionCableRopeIncline' => 'Estensioni per i tricipiti (cavo, corda, su panca inclinata)',
			'library.triceps.exercises.tricepsExtensionCableRopeLyingFloor' => 'Estensioni per i tricipiti (cavo, corda, da sdraiati, a terra)',
			'library.triceps.exercises.tricepsExtensionCableStandingOneArm' => 'Estensioni per i tricipiti (cavo, in piedi, a un braccio)',
			'library.triceps.exercises.tricepsExtensionCableStandingReverseGripOneArmOverhead' => 'Estensioni per i tricipiti (cavo, in piedi, presa supina, a un braccio, sopra la testa)',
			'library.triceps.exercises.tricepsPushdownCableVBar' => 'Pushdown per i tricipiti (cavo, barra a V)',
			'library.triceps.exercises.tricepsPushdownCableVBarArmBlaster' => 'Pushdown per i tricipiti (cavo, barra a V, arm blaster)',
			'library.triceps.exercises.tricepsKickbackCableTwoArm' => 'Kickback per i tricipiti (cavo, a due braccia)',
			'library.triceps.exercises.pushUpCloseGrip' => 'Piegamenti sulle braccia (presa stretta)',
			'library.triceps.exercises.pushUpCloseGripKnee' => 'Piegamenti sulle braccia (presa stretta, sulle ginocchia)',
			_ => null,
		} ?? switch (path) {
			'library.triceps.exercises.pressDumbbellCloseGrip' => 'Distensioni (manubri, presa stretta)',
			'library.triceps.exercises.pressDumbbellDeclineOneArmNeutralGrip' => 'Distensioni (manubri, su panca declinata, a un braccio, presa neutra)',
			'library.triceps.exercises.tricepsExtensionDumbbellDecline' => 'Estensioni per i tricipiti (manubri, su panca declinata)',
			'library.triceps.exercises.forwardLungeTricepsExtensionDumbbell' => 'Affondo avanti ed estensioni dei tricipiti (manubri)',
			'library.triceps.exercises.pressDumbbellInclineNeutralGripExerciseBall' => 'Distensioni (manubri, su panca inclinata, presa neutra, fitball)',
			'library.triceps.exercises.pressDumbbellInclineOneArmNeutralGrip' => 'Distensioni (manubri, su panca inclinata, a un braccio, presa neutra)',
			'library.triceps.exercises.pressDumbbellInclineOneArmNeutralGripExerciseBall' => 'Distensioni (manubri, su panca inclinata, a un braccio, presa neutra, fitball)',
			'library.triceps.exercises.tricepsExtensionDumbbellIncline' => 'Estensioni per i tricipiti (manubri, su panca inclinata)',
			'library.triceps.exercises.tricepsExtensionDumbbellInclineTwoArm' => 'Estensioni per i tricipiti (manubri, su panca inclinata, a due braccia)',
			'library.triceps.exercises.kickbackDumbbellExerciseBall' => 'Kickback per i tricipiti (manubri, fitball)',
			'library.triceps.exercises.tricepsExtensionDumbbellLyingAcrossFace' => 'Estensioni per i tricipiti (manubri, da sdraiati, davanti al viso)',
			'library.triceps.exercises.extensionDumbbellLyingAlternate' => 'Estensioni per i tricipiti (manubri, da sdraiati, alternato)',
			'library.triceps.exercises.tricepsExtensionDumbbellLying' => 'Estensioni per i tricipiti (manubri, da sdraiati)',
			'library.triceps.exercises.tricepsExtensionDumbbellLyingOneArmPronated' => 'Estensioni per i tricipiti (manubri, da sdraiati, a un braccio, presa prona)',
			'library.triceps.exercises.tricepsExtensionDumbbellLyingOneArmSupinated' => 'Estensioni per i tricipiti (manubri, da sdraiati, a un braccio, presa supina)',
			'library.triceps.exercises.tricepsExtensionDumbbellLyingOneArm' => 'Estensioni per i tricipiti (manubri, da sdraiati, a un braccio)',
			'library.triceps.exercises.frenchPressDumbbellOneArmExerciseBall' => 'French press (manubri, a un braccio, fitball)',
			'library.triceps.exercises.pressDumbbellOneArmNeutralGripExerciseBall' => 'Distensioni (manubri, a un braccio, presa neutra, fitball)',
			'library.triceps.exercises.tricepsExtensionDumbbellOneArmBench' => 'Estensioni per i tricipiti (manubri, a un braccio, su panca)',
			'library.triceps.exercises.tricepsExtensionDumbbellPronateGrip' => 'Estensioni per i tricipiti (manubri, presa prona)',
			'library.triceps.exercises.extensionDumbbellSeatedBench' => 'Estensioni per i tricipiti (manubri, da seduti, su panca)',
			'library.triceps.exercises.kickbackDumbbellSeatedBentOverAlternate' => 'Kickback per i tricipiti (manubri, da seduti, busto inclinato, alternato)',
			'library.triceps.exercises.kickbackDumbbellSeated' => 'Kickback per i tricipiti (manubri, da seduti)',
			'library.triceps.exercises.kickbackDumbbellSeatedOneArm' => 'Kickback per i tricipiti (manubri, da seduti, a un braccio)',
			'library.triceps.exercises.tricepsExtensionDumbbellSeatedReverseGripOneArmOverhead' => 'Estensioni per i tricipiti (manubri, da seduti, presa supina, a un braccio, sopra la testa)',
			'library.triceps.exercises.tricepsKickbackDumbbellStandingAlternate' => 'Kickback per i tricipiti (manubri, in piedi, alternato)',
			'library.triceps.exercises.tricepsExtensionDumbbellStandingBentOverOneArm' => 'Estensioni per i tricipiti (manubri, in piedi, busto inclinato, a un braccio)',
			'library.triceps.exercises.kickbackDumbbellStanding' => 'Kickback per i tricipiti (manubri, in piedi)',
			'library.triceps.exercises.extensionDumbbellStandingOneArm' => 'Estensioni per i tricipiti (manubri, in piedi, a un braccio)',
			'library.triceps.exercises.tatePressDumbbell' => 'Tate press (manubri)',
			'library.triceps.exercises.tricepsKickbackDumbbellStorkStance' => 'Kickback per i tricipiti (manubri, in equilibrio su una gamba)',
			'library.triceps.exercises.elbowSupportedDips' => 'Dip con appoggio sui gomiti',
			'library.triceps.exercises.dipExerciseBall' => 'Dip (fitball)',
			'library.triceps.exercises.tricepsStretchExerciseBallSeated' => 'Allungamento dei tricipiti (fitball, da seduti)',
			'library.triceps.exercises.tricepsExtensionExerciseBallSupine' => 'Estensioni per i tricipiti (fitball, in posizione supina)',
			'library.triceps.exercises.frenchPressEzBarExerciseBall' => 'French press (bilanciere EZ, fitball)',
			'library.triceps.exercises.tricepsExtensionEzBarLyingCloseGripBehindHead' => 'Estensioni per i tricipiti (bilanciere EZ, da sdraiati, presa stretta, dietro la testa)',
			'library.triceps.exercises.frenchPressEzBarStanding' => 'French press (bilanciere EZ, in piedi)',
			'library.triceps.exercises.declineEZBarFacePress' => 'Estensioni dei gomiti verso il viso con bilanciere EZ su panca declinata',
			'library.triceps.exercises.tricepsExtensionEzBarbellDecline' => 'Estensioni per i tricipiti (bilanciere EZ, su panca declinata)',
			'library.triceps.exercises.tricepsExtensionEzBarbellIncline' => 'Estensioni per i tricipiti (bilanciere EZ, su panca inclinata)',
			'library.triceps.exercises.tricepsExtensionEzBarbellSeated' => 'Estensioni per i tricipiti (bilanciere EZ, da seduti)',
			'library.triceps.exercises.benchPressEzBarCloseGrip' => 'Distensioni su panca (bilanciere EZ, presa stretta)',
			'library.triceps.exercises.forearmTransitionDips' => 'Dip con passaggio sugli avambracci',
			'library.triceps.exercises.pushUpInclineCloseGrip' => 'Piegamenti sulle braccia (su panca inclinata, presa stretta)',
			'library.triceps.exercises.tricepsDipLeverOverhand' => 'Dip per i tricipiti (macchina a leva, presa prona)',
			'library.triceps.exercises.dipLeverSeated' => 'Dip (macchina a leva, da seduti)',
			'library.triceps.exercises.pushUpMedicineBallCloseGrip' => 'Piegamenti sulle braccia (palla medica, presa stretta)',
			'library.triceps.exercises.supineMedicineBallChestThrow' => 'Lancio della palla medica dal petto da supini',
			'library.triceps.exercises.tricepsExtensionOlympicBarbell' => 'Estensioni per i tricipiti (bilanciere olimpico)',
			'library.triceps.exercises.dipOneArm' => 'Dip (a un braccio)',
			'library.triceps.exercises.tricepsStretchOverhead' => 'Allungamento dei tricipiti (sopra la testa)',
			'library.triceps.exercises.pushUpCloseGripOffDumbbell' => 'Piegamenti sulle braccia (presa stretta, su appoggio, manubri)',
			'library.triceps.exercises.dipReverse' => 'Dip (inverso)',
			'library.triceps.exercises.dipRing' => 'Dip (anelli)',
			'library.triceps.exercises.benchPressSmithCloseGrip' => 'Distensioni su panca (Smith machine, presa stretta)',
			'library.triceps.exercises.benchPressSmithMachineDeclineCloseGrip' => 'Distensioni su panca (Smith machine, su panca declinata, presa stretta)',
			'library.triceps.exercises.tricepsExtensionSmithMachineIncline' => 'Estensioni per i tricipiti (Smith machine, su panca inclinata)',
			'library.triceps.exercises.stalderPressToHandstand' => 'Salita in verticale in divaricata Stalder',
			'library.triceps.exercises.dipThreeBench' => 'Dip (tre appoggi, su panca)',
			'library.triceps.exercises.tricepsDipFloor' => 'Dip per i tricipiti (a terra)',
			'library.triceps.exercises.dipWeightedBench' => 'Dip (con sovraccarico, su panca)',
			'library.triceps.exercises.dipWeightedThreeBench' => 'Dip (con sovraccarico, tre appoggi, su panca)',
			'library.triceps.exercises.tricepsDipWeighted' => 'Dip per i tricipiti (con sovraccarico)',
			'library.triceps.exercises.jmPressBarbell' => 'JM press (bilanciere)',
			'library.triceps.exercises.jmPressEzBarbell' => 'JM press (bilanciere EZ)',
			'library.custom.name' => 'Esercizi personalizzati',
			'library.newCustomExercise' => 'Nuovo esercizio',
			'library.hips.name' => 'Anche',
			'library.hips.exercises.hipAdduction' => 'Adduzioni dell’anca alla macchina',
			'library.hips.exercises.adductorStretchAssistedSideLying' => 'Allungamento degli adduttori (con assistenza, sdraiati sul fianco)',
			'library.hips.exercises.hipAdductionCable' => 'Adduzioni dell’anca (cavo)',
			'library.hips.exercises.hipAdductionSideLying' => 'Adduzioni dell’anca (sdraiati sul fianco)',
			'library.hips.exercises.hipAdductionSidePlank' => 'Adduzioni dell’anca (in plank laterale)',
			'library.forearms.name' => 'Avambracci',
			'library.forearms.exercises.wristCurlsBarbell' => 'Curl dei polsi (bilanciere)',
			'library.forearms.exercises.reverseWristCurlsBarbell' => 'Estensioni dei polsi (bilanciere)',
			'library.forearms.exercises.wristCurlsDumbbell' => 'Curl dei polsi (manubri)',
			'library.forearms.exercises.reverseWristCurlsDumbbell' => 'Estensioni dei polsi (manubri)',
			'library.forearms.exercises.wristRoller' => 'Wrist roller',
			'library.forearms.exercises.farmerWalk' => 'Farmer walk',
			'library.forearms.exercises.platePinch' => 'Plate pinch',
			'library.forearms.exercises.reverseCurls' => 'Reverse curl (bilanciere)',
			'library.forearms.exercises.reverseCurlsDumbbell' => 'Reverse curl (manubri)',
			'library.forearms.exercises.dumbbellSingleArmReverseCurl' => 'Reverse curl a un braccio (manubrio)',
			'library.forearms.exercises.singleArmCableReverseCurl' => 'Reverse curl a un braccio al cavo',
			'library.forearms.exercises.reverseWristCurlBand' => 'Estensioni dei polsi (elastico)',
			'library.forearms.exercises.wristCurlBand' => 'Flessioni dei polsi (elastico)',
			'library.forearms.exercises.wristCurlBarbellStandingBack' => 'Flessioni dei polsi (bilanciere, in piedi, posteriore)',
			'library.forearms.exercises.reverseWristCurlCable' => 'Estensioni dei polsi (cavo)',
			'library.forearms.exercises.wristCurlCableStandingBack' => 'Flessioni dei polsi (cavo, in piedi, posteriore)',
			'library.forearms.exercises.wristCurlCable' => 'Flessioni dei polsi (cavo)',
			'library.forearms.exercises.dumbbellFingerFlexion' => 'Flessioni delle dita con manubrio',
			'library.forearms.exercises.pronationDumbbellLying' => 'Pronazione dell’avambraccio (manubri, da sdraiati)',
			'library.forearms.exercises.pronationDumbbellLyingFloor' => 'Pronazione dell’avambraccio (manubri, da sdraiati, a terra)',
			'library.forearms.exercises.supinationDumbbellLying' => 'Supinazione dell’avambraccio (manubri, da sdraiati)',
			'library.forearms.exercises.supinationDumbbellLyingFloor' => 'Supinazione dell’avambraccio (manubri, da sdraiati, a terra)',
			'library.forearms.exercises.reverseWristCurlDumbbellOneArm' => 'Estensioni dei polsi (manubri, a un braccio)',
			'library.forearms.exercises.neutralWristCurlDumbbellOneArmSeated' => 'Deviazioni radiali dei polsi (manubri, a un braccio, da seduti)',
			'library.forearms.exercises.wristCurlDumbbellOneArm' => 'Flessioni dei polsi (manubri, a un braccio)',
			'library.forearms.exercises.benchSupportedDumbbellRadialDeviation' => 'Deviazioni radiali del polso con manubri e appoggio su panca',
			'library.forearms.exercises.neutralWristCurlDumbbellBenchOneArm' => 'Deviazioni radiali dei polsi (manubri, su panca, a un braccio)',
			'library.forearms.exercises.reverseWristCurlDumbbellBenchOneArm' => 'Estensioni dei polsi (manubri, su panca, a un braccio)',
			'library.forearms.exercises.wristCurlDumbbellBenchOneArm' => 'Flessioni dei polsi (manubri, su panca, a un braccio)',
			'library.forearms.exercises.seatedDumbbellRadialDeviation' => 'Deviazioni radiali dei polsi con manubri da seduti',
			'library.forearms.exercises.shoulderExternalRotationDumbbellSeatedOneArm' => 'Extrarotazioni della spalla (manubri, da seduti, a un braccio)',
			'library.forearms.exercises.fingerFlexionCurls' => 'Flessioni delle dita',
			'library.forearms.exercises.hangCleanKettlebellAlternate' => 'Girata dalla sospensione (kettlebell, alternato)',
			'library.forearms.exercises.machineHandGripSqueeze' => 'Chiusure della presa alla macchina',
			'library.forearms.exercises.wristStretchWithSidePull' => 'Allungamento del polso con trazione laterale',
			'library.forearms.exercises.wristCurlSmithSeated' => 'Flessioni dei polsi (Smith machine, da seduti)',
			'library.forearms.exercises.wristCurlSmithStandingBack' => 'Flessioni dei polsi (Smith machine, in piedi, posteriore)',
			'library.forearms.exercises.weightedHandGripSqueeze' => 'Chiusure della presa con resistenza',
			'library.forearms.exercises.wristCircles' => 'Circonduzioni dei polsi',
			'library.obliques.exercises.sidewaysPlank' => 'Plank laterale',
			'library.obliques.exercises.sidewaysPlankReachThrough' => 'Plank laterale con rotazione',
			'library.other.name' => 'Altro',
			'library.other.exercises.stretching' => 'Stretching',
			'library.glutes.name' => 'Glutei',
			'library.glutes.exercises.singleLegGluteBridge' => 'Ponte per i glutei a una gamba',
			'library.glutes.exercises.smithMachineHipThrust' => 'Hip thrust al Multipower',
			'library.glutes.exercises.bandHipAbduction' => 'Abduzioni dell’anca con elastico',
			'library.glutes.exercises.lateralBandWalk' => 'Camminata laterale con elastico',
			'library.glutes.exercises.quadrupedGluteKickback' => 'Slanci posteriori in quadrupedia',
			'library.glutes.exercises.kettlebellSwing' => 'Kettlebell swing',
			'library.glutes.exercises.cableGluteKickback' => 'Slanci posteriori al cavo',
			'library.glutes.exercises.machineGluteKickback' => 'Slanci posteriori alla macchina',
			'library.glutes.exercises.cableHipAbduction' => 'Abduzioni dell’anca al cavo',
			'library.glutes.exercises.gluteBridge' => 'Ponte per i glutei',
			'library.glutes.exercises.hipThrust' => 'Hip thrust alla macchina',
			'library.glutes.exercises.hipAbduction' => 'Abduzioni dell’anca alla macchina',
			'library.glutes.exercises.clamshells' => 'Clamshell per i glutei',
			'library.glutes.exercises.hipThrustBarbell' => 'Hip thrust (bilanciere)',
			'library.glutes.exercises.standingToeTouchCirclesArmsOpen' => 'Circonduzioni del busto verso i piedi a braccia aperte',
			'library.glutes.exercises.assistedSupineGluteStretch' => 'Allungamento dei glutei da supini con assistenza',
			'library.glutes.exercises.assistedGluteAndPiriformisStretch' => 'Allungamento assistito di glutei e piriforme',
			'library.glutes.exercises.hipExtensionBandBentOver' => 'Estensioni dell’anca (elastico, busto inclinato)',
			'library.glutes.exercises.gluteBridgeBand' => 'Ponte per i glutei (elastico)',
			'library.glutes.exercises.hipInternalRotationBandLying' => 'Rotazioni interne dell’anca (elastico, da sdraiati)',
			'library.glutes.exercises.pullThroughBand' => 'Pull-through (elastico)',
			'library.glutes.exercises.hipInternalRotationBandSeated' => 'Rotazioni interne dell’anca (elastico, da seduti)',
			'library.glutes.exercises.gluteBridgeBarbell' => 'Ponte per i glutei (bilanciere)',
			'library.glutes.exercises.gluteBridgeBarbellBench' => 'Ponte per i glutei (bilanciere, su panca)',
			'library.glutes.exercises.deadliftBarbellOneArmSide' => 'Stacco da terra (bilanciere, a un braccio, laterale)',
			'library.glutes.exercises.rackPullBarbell' => 'Stacco dai supporti (bilanciere)',
			'library.glutes.exercises.deadliftBarbellOneLeg' => 'Stacco da terra (bilanciere, a una gamba)',
			'library.glutes.exercises.deadliftBarbellSumo' => 'Stacco da terra (bilanciere, sumo)',
			'library.glutes.exercises.standingForwardFoldToToes' => 'Flessione del busto verso i piedi',
			'library.glutes.exercises.hipExtensionBench' => 'Estensioni dell’anca (su panca)',
			'library.glutes.exercises.twistBentKneeLying' => 'Rotazioni del busto (ginocchia piegate, da sdraiati)',
			'library.glutes.exercises.deadliftCable' => 'Stacco da terra (cavo)',
			'library.glutes.exercises.pullThroughCableRope' => 'Pull-through (cavo, corda)',
			'library.glutes.exercises.hipExtensionCableStanding' => 'Estensioni dell’anca (cavo, in piedi)',
			'library.glutes.exercises.cleanDumbbell' => 'Girata (manubri)',
			'library.glutes.exercises.deadliftDumbbell' => 'Stacco da terra (manubri)',
			'library.glutes.exercises.snatchDumbbellOneArm' => 'Strappo (manubri, a un braccio)',
			'library.glutes.exercises.deadliftDumbbellOneLegStepboxSupport' => 'Stacco da terra (manubri, a una gamba, con appoggio sullo step)',
			'library.glutes.exercises.pullThroughDumbbellSumo' => 'Pull-through (manubri, sumo)',
			'library.glutes.exercises.hipFlexorStretchExerciseBall' => 'Allungamento dei flessori dell’anca (fitball)',
			'library.glutes.exercises.proneSingleLegHipRotationOnBall' => 'Rotazioni dell’anca a una gamba da proni sulla fitball',
			'library.glutes.exercises.ballSupportedDiagonalKickAndLegCurl' => 'Calcio diagonale e flessione della gamba sulla fitball',
			'library.glutes.exercises.flutterKicks' => 'Sforbiciate a gambe tese',
			'library.glutes.exercises.gluteBridgeMarch' => 'Ponte per i glutei (con marcia)',
			'library.glutes.exercises.gluteBridgeTwoLegBench' => 'Ponte per i glutei (a due gambe, su panca)',
			'library.glutes.exercises.toeTouchCirclesWithHandsClasped' => 'Circonduzioni verso i piedi con mani unite',
			'library.glutes.exercises.toeTouchCirclesWithReversedHandClasp' => 'Circonduzioni verso i piedi con mani intrecciate al contrario',
			'library.glutes.exercises.supineKneesToChestStretch' => 'Allungamento da supini con ginocchia al petto',
			'library.glutes.exercises.supineCrossBodyRotationStretch' => 'Allungamento da supini con torsione incrociata',
			'library.glutes.exercises.deadliftLever' => 'Stacco da terra (macchina a leva)',
			'library.glutes.exercises.hipExtensionLever' => 'Estensioni dell’anca (macchina a leva)',
			'library.glutes.exercises.legPressLeverHorizontalOneLeg' => 'Pressa per le gambe (macchina a leva, orizzontale, a una gamba)',
			'library.glutes.exercises.reverseHyperextensionLever' => 'Iperestensioni inverse (macchina a leva)',
			'library.glutes.exercises.wallSitWithAlternatingKneeLifts' => 'Seduta alla parete con sollevamenti alternati delle ginocchia',
			'library.glutes.exercises.pelvicTiltIntoGluteBridge' => 'Retroversione del bacino e ponte per i glutei',
			'library.glutes.exercises.pushUpPikeToCobra' => 'Piegamenti sulle braccia (da V rovesciata a cobra)',
			'library.glutes.exercises.elevatedReverseBridge' => 'Ponte inverso con piedi rialzati',
			'library.glutes.exercises.hipThrustsResistanceBandKnee' => 'Hip thrust (elastico, sulle ginocchia)',
			'library.glutes.exercises.hipAbductionResistanceBandSeated' => 'Abduzioni dell’anca (elastico, da seduti)',
			'library.glutes.exercises.reverseHyperextensionStabilityBall' => 'Iperestensioni inverse (fitball)',
			'library.glutes.exercises.reverseHyperextensionFlatBench' => 'Iperestensioni inverse (panca piana)',
			'library.glutes.exercises.rockingFrogAdductorStretch' => 'Allungamento a rana degli adduttori con oscillazione',
			'library.glutes.exercises.latStretchRollerHip' => 'Allungamento dei dorsali (rullo, anca)',
			'library.glutes.exercises.hipStretchRoller' => 'Allungamento delle anche (rullo)',
			'library.glutes.exercises.gluteStretchSeated' => 'Allungamento dei glutei (da seduti)',
			'library.glutes.exercises.piriformisStretchSeated' => 'Allungamento del piriforme (da seduti)',
			'library.glutes.exercises.hipAbductionSideBridge' => 'Abduzioni dell’anca (in ponte laterale)',
			'library.glutes.exercises.hipAbductionSide' => 'Abduzioni dell’anca (laterale)',
			'library.glutes.exercises.legPressSled45WideStance' => 'Pressa per le gambe (slitta, 45°, piedi divaricati)',
			'library.glutes.exercises.deadliftSmith' => 'Stacco da terra (Smith machine)',
			'library.glutes.exercises.legPressSmith' => 'Pressa per le gambe (Smith machine)',
			'library.glutes.exercises.sideLyingStraightLegHipAbduction' => 'Abduzioni dell’anca sul fianco a gamba tesa',
			'library.glutes.exercises.swimmerKicks' => 'Battute delle gambe da proni',
			'library.glutes.exercises.tireTurnover' => 'Ribaltamento dello pneumatico',
			'library.glutes.exercises.trapBarDeadlift' => 'Stacco da terra con trap bar',
			'library.glutes.exercises.hipLiftWithRotation' => 'Sollevamento del bacino con rotazione',
			'infobox.label' => 'Note',
			'superset' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, zero: 'Superserie senza esercizi', one: 'Superserie con un esercizio', two: 'Superserie con ${n} esercizi', few: 'Superserie con ${n} esercizi', many: 'Superserie con ${n} esercizi', other: 'Superserie con ${n} esercizi', ),
			'historyEditor.title' => ({required Object name}) => 'Modifica: ${name}',
			'historyEditor.exercises.addSuperset' => '+ Aggiungi superserie',
			'historyEditor.exercises.add' => '+ Aggiungi esercizio',
			'historyEditor.exercises.reorder' => 'Riordina esercizi',
			'historyEditor.info.reps' => 'Ripetizioni',
			'historyEditor.info.volume' => 'Volume',
			'historyEditor.actions.finish' => 'Termina modifica',
			'historyEditor.actions.changeWeightUnit' => 'Cambia unità di peso',
			'historyEditor.actions.discardChanges' => 'Modifiche effettuate',
			'historyEditor.actions.discardChangesContent' => 'Questa pagina contiene modifiche non salvate. Vuoi comunque tornare indietro e perdere tutte le modifiche?',
			'historyEditor.finish.title' => 'Termina modifica',
			'historyEditor.finish.fields.name.label' => 'Nome',
			'historyEditor.finish.fields.name.errors.empty' => 'Il nome non dev\'essere vuoto.',
			'historyEditor.finish.fields.startingTime.label' => 'Data di inizio',
			'historyEditor.finish.fields.parent.label' => 'Salva come',
			'historyEditor.finish.fields.parent.options.none' => 'Nessuna routine',
			'historyEditor.finish.fields.duration.label' => 'Durata',
			'historyEditor.finish.fields.duration.errors.empty' => 'La durata non dev\'essere zero.',
			'historyEditor.finish.fields.infobox.label' => 'Note',
			'importRoutine.title' => 'Importa routine',
			'importRoutine.errors.badJson.title' => 'Dati danneggiati',
			'importRoutine.errors.badJson.body' => 'Il link che hai seguito è danneggiato e non può essere aperto.',
			'importRoutine.errors.noJson.title' => 'Dati mancanti',
			'importRoutine.errors.noJson.body' => 'Il link che hai seguito è danneggiato e non può essere aperto.',
			'importRoutine.errors.badWorkout.title' => 'Allenamento non valido',
			'importRoutine.errors.badWorkout.body' => 'Hai seguito un link che porta ad un allenamento non valido. Forse è stato creato da una vecchia versione dell\'app.',
			'importRoutine.import.label' => 'Importa',
			'importRoutine.import.done' => 'The routine has been imported.',
			'unknownUrl.title' => 'URL sconosciuto',
			'unknownUrl.text' => 'Hai seguito un URL che non porta da nessuna parte.',
			'me.title' => 'Profilo',
			'me.weight.label' => 'Peso',
			'me.weight.none' => 'N/D',
			'me.weight.allData.label' => 'Mostra tutti i dati',
			'me.weight.measured.never' => 'Ultima misurazione: mai',
			'me.weight.measured.date' => ({required Object date}) => 'Ultima misurazione: ${date}',
			'me.weight.addMeasurement' => 'Aggiungi misurazione',
			'me.addWeight.time.label' => 'Data e ora',
			'me.addWeight.weight.label' => 'Peso',
			'me.addWeight.weightUnit.label' => 'Unità',
			'me.addWeight.errors.invalidWeight' => 'Inserisci un peso valido',
			'me.allData.label' => 'Tutti i dati registrati',
			'me.allData.removed.text' => 'Il dato è stato rimosso',
			'me.allData.none' => 'Nessun dato',
			'me.allData.predictedWeight.label' => 'Peso predetto',
			'me.allData.predictedWeight.dialog.title' => 'Peso predetto',
			'me.allData.predictedWeight.dialog.text' => 'La predizione del peso è fornita a scopo esclusivamente informativo e non va presa seriamente.',
			'me.calendar.label' => 'Calendario',
			'me.calendar.empty' => 'Non ti sei allenato questo giorno',
			'me.calendar.streak' => 'Serie',
			'me.calendar.rest' => 'Riposo',
			'me.stats.label' => 'Statistiche',
			'me.stats.timeFrame.thirtyDays' => 'Ultimi 30 giorni',
			'me.stats.timeFrame.threeMonths' => 'Ultimi 3 mesi',
			'me.stats.timeFrame.year' => 'Ultimo anno',
			'me.stats.timeFrame.allTime' => 'Tutto',
			'me.stats.timeFrame.sevenDays' => 'Ultimi 7 giorni',
			'me.stats.workouts.label' => 'Allenamenti',
			'me.stats.duration.label' => 'Durata',
			'me.stats.volume.label' => 'Volume',
			'me.stats.distance.label' => 'Distanza percorsa',
			'me.stats.sets.label' => 'Serie',
			'me.stats.muscleCategory' => 'Gruppi muscolari',
			'me.stats.gymEquipment' => 'Attrezzatura',
			'me.stats.atAGlance' => 'Colpo d\'occhio',
			'me.stats.metrics' => 'Metriche',
			'me.stats.overview.thisWeek' => 'Questa settimana',
			'me.stats.overview.title' => 'Progressi',
			'me.stats.overview.volume' => 'Volume sollevato',
			'me.stats.overview.personalRecords' => 'Record personali',
			'me.stats.overview.recordCriteria' => 'Record di carico: a parità di peso, vale la serie con più ripetizioni.',
			'me.stats.overview.emptyRecords' => 'Completa una serie con peso e ripetizioni per vedere i tuoi record personali.',
			'me.stats.overview.emptyWeek' => 'Nessun volume registrato questa settimana.',
			'me.stats.overview.loadError' => 'Impossibile caricare i progressi',
			'me.stats.overview.retryDescription' => 'Riprova per caricare i tuoi allenamenti.',
			'me.stats.mainThree.label' => 'I big 3',
			'me.stats.mainThree.description' => 'Visualizza l\'evoluzione dei tuoi massimali (1RM) per i "Big 3" nell\'intervallo di tempo selezionato. Il grafico utilizza il massimale più alto di ogni settimana per visualizzare l\'andamento complessivo dei carichi nei tre esercizi fondamentali del powerlifting.',
			'me.stats.mainThree.warning.title' => 'Nota sul grafico',
			'me.stats.mainThree.warning.text' => ({required Object exercises}) => 'Affinché i progressi vengano calcolati e visualizzati correttamente nel grafico, utilizza gli esercizi standard della libreria dell\'app anziché creare varianti personalizzate. Nello specifico: ${exercises}.',
			'me.stats.mainThree.bottomTitle' => ({required Object week}) => 'S${week}',
			'me.workoutDistribution.label' => 'Distribuzione allenamenti',
			'me.profile.title' => 'Profilo',
			'me.profile.logout' => 'Esci',
			'me.profile.edit.title' => 'Modifica profilo',
			'me.profile.errors.logout.title' => 'Si è verificato un errore',
			'me.profile.errors.logout.subtitle' => ({required Object error}) => 'Impossibile effettuare il logout: ${error}',
			'me.sync.label' => 'Modifiche non salvate',
			'me.sync.subtitle' => 'Tocca per sincronizzare le modifiche con il cloud.',
			'me.bodyMeasurements' => 'Misurazioni corporee',
			'me.trainer.heading' => 'Personal trainer',
			'me.trainer.title' => 'Il mio trainer',
			'me.trainer.subtitle' => 'Gestisci il collegamento, le schede e le routine condivise.',
			'richText.highlight' => 'Evidenzia',
			'errorView.shortTitle' => 'Errore',
			'errorView.title' => 'Oh cavolo!',
			'errorView.subtitle' => 'Qualcosa è andato storto.',
			'errorView.body' => 'Se il problema persiste, prova a:\n\n • Riavviare l\'app\n • Assicurarti di avere l\'ultima versione dell\'app\n • Contattare il supporto',
			'errorView.stack' => 'Se il problema persiste, per favore fornisci le seguenti informazioni al supporto:',
			'errorView.noStack' => 'Nessuna informazione disponibile sullo stack.',
			'timeSeriesChart.selectInterval' => 'Seleziona intervallo',
			'timeSeriesChart.interval.threeMonths' => '3 mesi',
			'timeSeriesChart.interval.sixMonths' => '6 mesi',
			'timeSeriesChart.interval.oneYear' => '1 anno',
			'timeSeriesChart.noData.title' => 'Questo grafico non presenta dati',
			'timeSeriesChart.noData.subtitle' => 'Avvia qualche allenamento per vedere questi dati.',
			'androidRequestExactAlarmsPermission.title' => 'Permesso di invio notifiche',
			'androidRequestExactAlarmsPermission.message' => 'Questa applicazione richiede un permesso speciale, "Promemoria e avvisi", sulle versioni di Android a partire da Android 14. Puoi scegliere di rifiutarlo, ma funzionalità come le notifiche di fine recupero non funzioneranno. Vuoi dare il permesso?',
			'routineFormPicker.fields.routine.options.none' => 'Nessuna routine selezionata',
			'routineFormPicker.fields.routine.options.root' => 'Home',
			'cardioTimer.name' => 'Timer a intervalli',
			'cardioTimer.setUp.title' => 'Impostazioni timer a intervalli',
			'cardioTimer.setUp.active' => 'Tempo di attività',
			'cardioTimer.setUp.rest' => 'Tempo di recupero',
			'cardioTimer.setUp.section' => ({required Object section}) => 'Sezione ${section}',
			'cardioTimer.setUp.start' => 'Avvia timer a intervalli',
			'cardioTimer.setUp.addSection' => '+ Nuova sezione',
			'cardioTimer.setUp.errors.duration' => 'La durata non deve essere vuota.',
			'cardioTimer.setUp.errors.bothZeros' => 'Almeno uno dei tempi deve essere maggiore di zero.',
			'cardioTimer.setUp.errors.generic' => 'Ci sono errori nelle impostazioni. Risolvili e prova di nuovo.',
			'cardioTimer.confirmExit.title' => 'Esci',
			'cardioTimer.confirmExit.message' => 'Vuoi davvero uscire? Il progresso attuale sarà cancellato.',
			'migrations.customToLibraryExercise.fields.from.title' => 'Sostituisci tutte le occorrenze di questo esercizio personalizzato…',
			'migrations.customToLibraryExercise.fields.from.label' => 'Esercizio personalizzato',
			'migrations.customToLibraryExercise.fields.to.title' => '…con questo esercizio standard…',
			'migrations.customToLibraryExercise.fields.to.label' => 'Esercizio standard',
			'migrations.customToLibraryExercise.title' => 'Esercizio personalizzato a esercizio standard',
			'migrations.customToLibraryExercise.description' => 'Sostituisci tutte le occorrenze di un esercizio personalizzato con un esercizio standard compatibile',
			'migrations.customToLibraryExercise.preview.from' => 'Sostituisci…',
			'migrations.customToLibraryExercise.preview.to' => 'Con…',
			'migrations.customToLibraryExercise.preview.affectedRoutines' => 'Routine influenzate',
			'migrations.customToLibraryExercise.preview.affectedWorkouts' => 'Allenamenti cronologici influenzati',
			'migrations.common.actions.next' => 'Prossimo step: anteprima',
			'migrations.common.actions.apply' => 'Applica migrazione',
			'migrations.common.preview' => 'Anteprima migrazione',
			'migrations.common.migrated' => 'Migrazione completata!',
			'migrations.title' => 'Migrazioni',
			'migrations.removeUnusedExercises.preview.noAffected' => 'Nessun dato verrebbe modificato.',
			'migrations.removeUnusedExercises.preview.affectedExercises' => 'Esercizi influenzati',
			'migrations.removeUnusedExercises.title' => 'Rimuovi esercizi inutilizzati',
			'migrations.removeUnusedExercises.description' => 'Pulisci la tua libreria rimuovendo tutti gli esercizi personalizzati che non hai usato',
			'migrations.removeWeightFromCustomExercise.preview.incompatible.title' => 'Esercizio non compatibile',
			'migrations.removeWeightFromCustomExercise.preview.incompatible.text' => 'Puoi applicare questa migrazione solo agli esercizi dove non hai mai usato il campo Peso.',
			'migrations.removeWeightFromCustomExercise.preview.selected' => 'Esercizio selezionato',
			'migrations.removeWeightFromCustomExercise.preview.affectedRoutines' => 'Routine influenzate',
			'migrations.removeWeightFromCustomExercise.preview.affectedWorkouts' => 'Allenamenti cronologici influenzati',
			'migrations.removeWeightFromCustomExercise.fields.exercise.label' => 'Esercizio',
			'migrations.removeWeightFromCustomExercise.fields.exercise.title' => 'Rimuovi il parametro Peso da questo esercizio',
			'migrations.removeWeightFromCustomExercise.title' => 'Rimuovi parametro Peso',
			'migrations.removeWeightFromCustomExercise.description' => 'Rimuovi il parametro Peso da un esercizio con "Peso e ripetizioni" dove hai sempre e solo usato il campo Ripetizioni.',
			'migrations.genericMultiplyWeight.title' => ({required Object multiplier}) => 'Moltiplica peso di un esercizio per ${multiplier}',
			'migrations.genericMultiplyWeight.fields.exercise.title' => 'Moltiplica il peso di questo esercizio...',
			'migrations.genericMultiplyWeight.fields.exercise.label' => 'Esercizio',
			'migrations.genericMultiplyWeight.preview.incompatible.title' => 'Esercizio non compatibile',
			'migrations.genericMultiplyWeight.preview.incompatible.text' => 'Cambia la tua selezione e riprova.',
			'migrations.genericMultiplyWeight.preview.selected' => 'Esercizio selezionato',
			'migrations.genericMultiplyWeight.preview.affectedRoutines' => 'Routine modificate',
			'migrations.genericMultiplyWeight.preview.affectedWorkouts' => 'Allenamenti precedenti modificati',
			'migrations.doubleExerciseWeight.title' => 'Raddoppia peso dell\'esercizio',
			'migrations.doubleExerciseWeight.description' => 'Raddoppia il parametro del peso in tutte le occorrenze di un esercizio.',
			'migrations.halveExerciseWeight.title' => 'Dimezza peso dell\'esercizio',
			'migrations.halveExerciseWeight.description' => 'Dimezza il parametro del peso in tutte le occorrenze di un esercizio.',
			'exerciseFormPicker.fields.exercise.options.none' => 'Nessun esercizio selezionato',
			'exercises.none.title' => 'Nessun esercizio',
			'exercises.none.subtitle' => 'Tocca per deselezionare tutto e tornare indietro',
			'food.title' => 'Diario alimentare',
			'food.home.dailyNutritionalValues' => 'Valori nutrizionali della giornata',
			'food.home.calories' => 'Calorie',
			'food.home.carbs' => 'Carboidrati',
			'food.home.protein' => 'Proteine',
			'food.home.fat' => 'Grassi',
			'food.home.eaten' => 'Consumate',
			'food.home.remainingCal' => 'Rimanenti',
			'food.home.goal' => 'Obiettivo',
			'food.home.overCal' => 'Superate',
			'food.searchBar.hint' => 'Cerca cronologia o catalogo alimenti…',
			'food.searchBar.noResults' => ({required Object query}) => 'Nessun riscontro per "${query}".',
			'food.searchBar.noHistory' => 'Cronologia vuota',
			'food.nutriments.calories' => 'Calorie',
			'food.nutriments.fat' => 'Grassi',
			'food.nutriments.saturatedFat' => 'Acidi grassi saturi',
			'food.nutriments.carbs' => 'Carboidrati',
			'food.nutriments.sugar' => 'Zuccheri',
			'food.nutriments.protein' => 'Proteine',
			'food.nutriments.salt' => 'Sale',
			'food.nutriments.sodium' => 'Sodio',
			'food.nutriments.fiber' => 'Fibre',
			'food.nutriments.addedSugars' => 'Zuccheri aggiunti',
			'food.nutriments.proteins' => 'Proteine',
			'food.nutriments.caffeine' => 'Caffeina',
			'food.nutriments.calcium' => 'Calcio',
			'food.nutriments.iron' => 'Ferro',
			'food.nutriments.vitaminC' => 'Vitamina C',
			'food.nutriments.magnesium' => 'Magnesio',
			'food.nutriments.phosphorus' => 'Fosforo',
			'food.nutriments.potassium' => 'Potassio',
			'food.nutriments.zinc' => 'Zinco',
			'food.nutriments.copper' => 'Rame',
			'food.nutriments.selenium' => 'Selenio',
			'food.nutriments.vitaminA' => 'Vitamina A',
			'food.nutriments.vitaminE' => 'Vitamina E',
			'food.nutriments.vitaminD' => 'Vitamina D',
			'food.nutriments.vitaminB1' => 'Vitamina B1',
			'food.nutriments.vitaminB2' => 'Vitamina B2',
			'food.nutriments.vitaminPP' => 'Vitamina PP',
			'food.nutriments.vitaminB6' => 'Vitamina B6',
			'food.nutriments.vitaminB12' => 'Vitamina B12',
			'food.nutriments.vitaminB9' => 'Vitamina B9',
			'food.nutriments.vitaminK' => 'Vitamina K',
			'food.nutriments.cholesterol' => 'Colesterolo',
			'food.nutriments.butyricAcid' => 'Acido butirrico',
			'food.nutriments.caproicAcid' => 'Acido caproico',
			'food.nutriments.caprylicAcid' => 'Acido caprilico',
			'food.nutriments.capricAcid' => 'Acido caprico',
			'food.nutriments.lauricAcid' => 'Acido laurico',
			'food.nutriments.myristicAcid' => 'Acido miristico',
			'food.nutriments.palmiticAcid' => 'Acido palmitico',
			'food.nutriments.stearicAcid' => 'Acido stearico',
			'food.nutriments.oleicAcid' => 'Acido oleico',
			'food.nutriments.linoleicAcid' => 'Acido linoleico',
			'food.nutriments.docosahexaenoicAcid' => 'Acido docosaesaenoico',
			'food.nutriments.eicosapentaenoicAcid' => 'Acido eicosapenaenoico',
			'food.nutriments.erucicAcid' => 'Acido erucico',
			'food.nutriments.monounsaturatedFat' => 'Acidi grassi monoinsaturi',
			'food.nutriments.polyunsaturatedFat' => 'Acidi grassi polinsaturi',
			'food.nutriments.alcohol' => 'Alcol',
			'food.nutriments.pantothenicAcid' => 'Acido pantotenico',
			'food.nutriments.biotin' => 'Biotina',
			'food.nutriments.chloride' => 'Cloruro',
			'food.nutriments.chromium' => 'Cromo',
			'food.nutriments.fluoride' => 'Fluoruro',
			'food.nutriments.iodine' => 'Iodio',
			'food.nutriments.manganese' => 'Manganese',
			'food.nutriments.molybdenum' => 'Molibdeno',
			'food.nutriments.omega3' => 'Omega 3',
			'food.nutriments.omega6' => 'Omega 6',
			'food.nutriments.omega9' => 'Omega 9',
			'food.nutriments.betaCarotene' => 'ß-carotene',
			'food.nutriments.bicarbonate' => 'Bicarbonato',
			'food.nutriments.sugarAlcohol' => 'Polioli',
			'food.nutriments.alphaLinolenicAcid' => 'Acido alfa-linolenico',
			'food.nutriments.arachidicAcid' => 'Acido arachidico',
			'food.nutriments.arachidonicAcid' => 'Acido arachidonico',
			'food.nutriments.behenicAcid' => 'Acido beenico',
			'food.nutriments.ceroticAcid' => 'Acido cerotico',
			'food.nutriments.dihomoGammaLinolenicAcid' => 'Acido diomo-gamma-linolenico',
			'food.nutriments.elaidicAcid' => 'Acido elaidico',
			'food.nutriments.gammaLinolenicAcid' => 'Acido gamma-linolenico',
			'food.nutriments.gondoicAcid' => 'Acido gondoico (acido 11-eicosenoico)',
			'food.nutriments.lignocericAcid' => 'Acido lignocerico',
			'food.nutriments.meadAcid' => 'Acido di Mead',
			'food.nutriments.melissicAcid' => 'Acido melissico',
			'food.nutriments.montanicAcid' => 'Acido montanico',
			'food.nutriments.nervonicAcid' => 'Acido nervonico',
			'food.nutriments.transFat' => 'Acidi grassi trans',
			'food.nutriments.water' => 'Acqua',
			'food.nutrimentUnits.kcal' => 'kcal',
			'food.nutrimentUnits.kj' => 'kJ',
			'food.nutrimentUnits.g' => 'g',
			'food.nutrimentUnits.milliG' => 'mg',
			'food.nutrimentUnits.microG' => 'µg',
			'food.nutrimentUnits.milliL' => 'ml',
			'food.nutrimentUnits.l' => 'L',
			'food.nutrimentUnits.percent' => '%',
			'food.nutrimentUnits.unknown' => 'Sconosciuto',
			'food.add.nutritionalValuesPerAmountG' => ({required Object amount}) => 'Valori nutrizionali (per ${amount} g / ${amount} ml)',
			'food.add.servingSize' => 'Porzione',
			'food.add.custom' => 'Quantità personalizzata',
			'food.add.amount' => 'Quantità',
			'food.add.amountWithClarifiedUnit' => 'Quantità (g o ml)',
			'food.add.amountEmpty' => 'La quantità non può essere vuota.',
			'food.add.amountInvalid' => 'Inserisci un numero valido.',
			'food.add.add' => '+ Aggiungi al diario',
			'food.add.unnamedServingSize' => 'Porzione sconosciuta',
			'food.add.nutritionalValuesPerAmountWithUnit' => ({required Object amount, required Object unit}) => 'Valori nutrizionali (per ${amount} ${unit})',
			'food.add.customFood.showMore' => 'Mostra tutti i campi',
			'food.add.customFood.title' => 'Aggiungi cibo personalizzato',
			'food.add.customFood.fields.name' => 'Nome',
			'food.add.customFood.fields.brand' => 'Marca',
			'food.add.nameEmpty' => 'Il nome non può essere vuoto',
			'food.add.pieces' => 'Pezzi',
			'food.offAttribution' => 'Dati forniti da OpenFoodFacts',
			'food.edit.edit' => 'Salva',
			'food.edit.copyToToday' => 'Copia a oggi',
			'food.addCustom.title' => 'Aggiungi personalizzato',
			'food.search.title' => 'Risultati',
			'food.search.error.serverError' => 'Impossibile contattare il catalogo alimenti. Riprova più tardi.',
			'food.search.error.generic' => 'Impossibile contattare il catalogo alimenti. Riprova più tardi.',
			'food.barcodeReader.title' => 'Scansiona codice a barre',
			'food.barcodeReader.scanResult.noProductFound.text' => ({required Object barcode}) => 'Nessun prodotto è stato trovato con codice ${barcode}.',
			'food.barcodeReader.scanResult.noProductFound.title' => 'Nessun prodotto',
			'food.barcodeReader.scanResult.noProductFound.createNew' => 'Crea nuovo prodotto',
			'food.barcodeReader.scanResult.error.title' => 'Si è verificato un errore',
			'food.barcodeReader.scanResult.error.text' => 'Impossibile cercare il prodotto.',
			'food.barcodeReader.enterCode' => 'Inserisci a mano',
			'food.barcodeReader.codeField.label' => 'Codice a barre',
			'food.barcodeReader.codeField.empty' => 'Questo campo non può essere vuoto',
			'food.addCustomFood.permission.title' => 'Devi concedere le seguenti autorizzazioni',
			'food.addCustomFood.permission.camera' => 'Fotocamera (e microfono)',
			'food.addCustomFood.permission.gallery' => 'Accesso alla libreria foto (per scansionare i codici a barre nelle foto)',
			'food.addCustomFood.permission.recheck' => 'Ricontrolla',
			'food.addCustomFood.permission.openAppSettings' => 'Apri impostazioni delle autorizzazioni',
			'food.nutritionGoal.effect.from' => ({required Object from}) => 'La modifica verrà applicata a partire dal ${from}.',
			'food.nutritionGoal.effect.range' => ({required Object from, required Object to}) => 'La modifica verrà applicata dal ${from} al ${to}.',
			'food.nutritionGoals.change.title' => 'Imposta obiettivo',
			'food.nutritionGoals.change.calories.label' => 'Calorie giornaliere',
			'food.nutritionGoals.change.calories.empty' => 'Questo valore non può essere vuoto.',
			'food.nutritionGoals.change.calories.invalid' => 'Inserisci un numero valido.',
			'food.nutritionGoals.change.fatPercentage.label' => 'Grassi (%)',
			'food.nutritionGoals.change.fatPercentage.empty' => 'Questo valore non può essere vuoto.',
			'food.nutritionGoals.change.fatPercentage.invalid' => 'Inserisci un numero valido tra 0 e 100.',
			'food.nutritionGoals.change.carbsPercentage.label' => 'Carboidrati (%)',
			'food.nutritionGoals.change.carbsPercentage.empty' => 'Questo valore non può essere vuoto.',
			'food.nutritionGoals.change.carbsPercentage.invalid' => 'Inserisci un numero valido tra 0 e 100.',
			'food.nutritionGoals.change.proteinPercentage.label' => 'Proteine (%)',
			'food.nutritionGoals.change.proteinPercentage.empty' => 'Questo valore non può essere vuoto.',
			_ => null,
		} ?? switch (path) {
			'food.nutritionGoals.change.proteinPercentage.invalid' => 'Inserisci un numero valido tra 0 e 100.',
			'food.nutritionGoals.change.save' => 'Salva modifiche',
			'food.nutritionGoals.history.title' => 'Cronologia obiettivi',
			'food.nutritionGoals.history.empty' => 'Non ci sono obiettivi',
			'food.nutritionGoals.history.tapToView' => 'Tocca per andare al giorno',
			'food.nutritionGoals.history.calories' => ({required Object calories}) => 'Calorie giornaliere: ${calories}',
			'food.nutritionGoals.history.macros' => ({required Object carbs, required Object protein, required Object fat}) => '${carbs} carboidrati – ${protein} proteine – ${fat} grassi',
			'food.combine.title' => 'Crea cibo da combinazione',
			'food.removeFavorite' => 'Rimuovi dai preferiti',
			'food.addFavorite' => 'Aggiungi ai preferiti',
			'food.languages.aa' => 'Afar',
			'food.languages.ae' => 'Lingua avestica',
			'food.languages.af' => 'Afrikaans',
			'food.languages.ak' => 'Akan',
			'food.languages.am' => 'Amarico',
			'food.languages.an' => 'Aragonese',
			'food.languages.ar' => 'Arabo',
			'food.languages.as' => 'Assamese',
			'food.languages.av' => 'Avar',
			'food.languages.ay' => 'Aymara',
			'food.languages.az' => 'Azero',
			'food.languages.ba' => 'Bashkir',
			'food.languages.be' => 'Bielorusso',
			'food.languages.bg' => 'Bulgaro',
			'food.languages.bh' => 'Bihari',
			'food.languages.bi' => 'Bislama',
			'food.languages.bm' => 'Bambara',
			'food.languages.bn' => 'Bengalese',
			'food.languages.bo' => 'Tibetano',
			'food.languages.br' => 'Bretone',
			'food.languages.bs' => 'Bosniaco',
			'food.languages.ca' => 'Catalano',
			'food.languages.ce' => 'Ceceno',
			'food.languages.ch' => 'Chamorro',
			'food.languages.co' => 'Corso',
			'food.languages.cr' => 'Cree',
			'food.languages.cs' => 'Ceco',
			'food.languages.cu' => 'Slavo ecclesiastico',
			'food.languages.cv' => 'Chuvash',
			'food.languages.cy' => 'Gallese',
			'food.languages.da' => 'Danese',
			'food.languages.de' => 'Tedesco',
			'food.languages.dv' => 'Maldiviano',
			'food.languages.dz' => 'Dzongkha',
			'food.languages.ee' => 'Ewe',
			'food.languages.el' => 'Greco',
			'food.languages.en' => 'Inglese',
			'food.languages.eo' => 'Esperanto',
			'food.languages.es' => 'Spagnolo',
			'food.languages.et' => 'Estone',
			'food.languages.eu' => 'Basco',
			'food.languages.fa' => 'Persiano',
			'food.languages.ff' => 'Fulah',
			'food.languages.fi' => 'Finnico',
			'food.languages.fj' => 'Fijian',
			'food.languages.fo' => 'Faroese',
			'food.languages.fr' => 'Francese',
			'food.languages.fy' => 'Frisone occidentale',
			'food.languages.ga' => 'Irlandese',
			'food.languages.gd' => 'Gaelico scozzese',
			'food.languages.gl' => 'Galiziano',
			'food.languages.gn' => 'Guarani',
			'food.languages.gu' => 'Gujarati',
			'food.languages.gv' => 'Manx',
			'food.languages.ha' => 'Hausa',
			'food.languages.he' => 'Ebraico',
			'food.languages.hi' => 'Hindi',
			'food.languages.ho' => 'Hiri Motu',
			'food.languages.hr' => 'Croato',
			'food.languages.ht' => 'Creolo haitiano',
			'food.languages.hu' => 'Ungherese',
			'food.languages.hy' => 'Armeno',
			'food.languages.hz' => 'Herero',
			'food.languages.ia' => 'Interlingua',
			'food.languages.id' => 'Indonesiano',
			'food.languages.ie' => 'Interlingue',
			'food.languages.ig' => 'Igbo',
			'food.languages.ii' => 'Nuosu',
			'food.languages.ik' => 'Inupiaq',
			'food.languages.io' => 'Ido',
			'food.languages.is' => 'Islandese',
			'food.languages.it' => 'Italiano',
			'food.languages.iu' => 'Inuktitut',
			'food.languages.ja' => 'Giapponese',
			'food.languages.jv' => 'Giavanese',
			'food.languages.ka' => 'Georgiano',
			'food.languages.kg' => 'Kongo',
			'food.languages.ki' => 'Gikuyu',
			'food.languages.kj' => 'Kwanyama',
			'food.languages.kk' => 'Kazaco',
			'food.languages.kl' => 'Groenlandese',
			'food.languages.km' => 'Khmer',
			'food.languages.kn' => 'Kannada',
			'food.languages.ko' => 'Coreano',
			'food.languages.kr' => 'Kanuri',
			'food.languages.ks' => 'Kashmiri',
			'food.languages.ku' => 'Curdo',
			'food.languages.kv' => 'Komi',
			'food.languages.kw' => 'Cornico',
			'food.languages.ky' => 'Kirghiso',
			'food.languages.la' => 'Latino',
			'food.languages.lb' => 'Lussemburghese',
			'food.languages.lg' => 'Ganda',
			'food.languages.li' => 'Limburgan',
			'food.languages.ln' => 'Lingala',
			'food.languages.lo' => 'Lao',
			'food.languages.lt' => 'Lituano',
			'food.languages.lu' => 'Luba-Katanga',
			'food.languages.lv' => 'Lettone',
			'food.languages.mg' => 'Malagasy',
			'food.languages.mh' => 'Marshallese',
			'food.languages.mi' => 'Maori',
			'food.languages.mk' => 'Macedone',
			'food.languages.ml' => 'Malese',
			'food.languages.mn' => 'Mongolo',
			'food.languages.mo' => 'Moldavo',
			'food.languages.mr' => 'Marathi',
			'food.languages.ms' => 'Malese',
			'food.languages.mt' => 'Maltese',
			'food.languages.my' => 'Burmese',
			'food.languages.na' => 'Nauru',
			'food.languages.nb' => 'Bokmal',
			'food.languages.nd' => 'Ndebele del nord',
			'food.languages.ne' => 'Nepalese',
			'food.languages.ng' => 'Ndonga',
			'food.languages.nl' => 'Olandese',
			'food.languages.nn' => 'Nynorsk',
			'food.languages.no' => 'Norvegese',
			'food.languages.nr' => 'Ndebele del sud',
			'food.languages.nv' => 'Navajo',
			'food.languages.ny' => 'Chichewa',
			'food.languages.oc' => 'Occitano',
			'food.languages.oj' => 'Ojibwe',
			'food.languages.om' => 'Oromo',
			'food.languages.or' => 'Odia',
			'food.languages.os' => 'Osseto',
			'food.languages.pa' => 'Punjabi',
			'food.languages.pi' => 'Pali',
			'food.languages.pl' => 'Polacco',
			'food.languages.ps' => 'Pashto',
			'food.languages.pt' => 'Portoghese',
			'food.languages.qu' => 'Quechua',
			'food.languages.rm' => 'Romancio',
			'food.languages.rn' => 'Kirundi',
			'food.languages.ro' => 'Rumeno',
			'food.languages.ru' => 'Russo',
			'food.languages.rw' => 'Kinyarmanda',
			'food.languages.sa' => 'Sanscrito',
			'food.languages.sc' => 'Sardo',
			'food.languages.sd' => 'Sindhi',
			'food.languages.se' => 'Samish settentrionale',
			'food.languages.sg' => 'Sango',
			'food.languages.si' => 'Cingalese',
			'food.languages.sk' => 'Slovacco',
			'food.languages.sl' => 'Sloveno',
			'food.languages.sm' => 'Samoano',
			'food.languages.sn' => 'Shona',
			'food.languages.so' => 'Somalo',
			'food.languages.sq' => 'Albanese',
			'food.languages.sr' => 'Serbo',
			'food.languages.ss' => 'Swazi',
			'food.languages.st' => 'Sotho',
			'food.languages.su' => 'Sundanese',
			'food.languages.sv' => 'Svedese',
			'food.languages.sw' => 'Swahili',
			'food.languages.ta' => 'Tamil',
			'food.languages.te' => 'Telugu',
			'food.languages.tg' => 'Tajik',
			'food.languages.th' => 'Thailandese',
			'food.languages.ti' => 'Tigrinya',
			'food.languages.tk' => 'Turkmeno',
			'food.languages.tl' => 'Tagalog',
			'food.languages.tn' => 'Tswana',
			'food.languages.to' => 'Tonga',
			'food.languages.tr' => 'Turco',
			'food.languages.ts' => 'Tsonga',
			'food.languages.tt' => 'Tatar',
			'food.languages.tw' => 'Twi',
			'food.languages.ty' => 'Tahitiano',
			'food.languages.ug' => 'Uyghur',
			'food.languages.uk' => 'Ucraino',
			'food.languages.ur' => 'Urdu',
			'food.languages.uz' => 'Uzbeco',
			'food.languages.ve' => 'Venda',
			'food.languages.vi' => 'Vietnamita',
			'food.languages.vo' => 'Volapuk',
			'food.languages.wo' => 'Wolof',
			'food.languages.xh' => 'Xhosa',
			'food.languages.yi' => 'Yiddish',
			'food.languages.yo' => 'Yoruba',
			'food.languages.za' => 'Zhuang',
			'food.languages.zh' => 'Cinese',
			'food.languages.zu' => 'Zulu',
			'food.languages.xx' => 'Lingua sconosciuta',
			'food.languages.world' => 'Mondo (pseudo-lingua)',
			'food.languages.und' => 'Lingua non definita',
			'food.countries.ad' => 'Andorra',
			'food.countries.ae' => 'Emirati Arabi Uniti',
			'food.countries.af' => 'Afghanistan',
			'food.countries.ag' => 'Antigua e Barbuda',
			'food.countries.ai' => 'Anguilla',
			'food.countries.al' => 'Albania',
			'food.countries.am' => 'Armenia',
			'food.countries.ao' => 'Angola',
			'food.countries.aq' => 'Antartide',
			'food.countries.ar' => 'Argentina',
			'food.countries.as' => 'Samoa Americane',
			'food.countries.at' => 'Austria',
			'food.countries.au' => 'Australia',
			'food.countries.aw' => 'Aruba',
			'food.countries.ax' => 'Isole Åland',
			'food.countries.az' => 'Azerbaigian',
			'food.countries.ba' => 'Bosnia e Herzegovina',
			'food.countries.bb' => 'Barbados',
			'food.countries.bd' => 'Bangladesh',
			'food.countries.be' => 'Belgio',
			'food.countries.bf' => 'Burkina Faso',
			'food.countries.bg' => 'Bulgaria',
			'food.countries.bh' => 'Bahrain',
			'food.countries.bi' => 'Burundi',
			'food.countries.bj' => 'Benin',
			'food.countries.bl' => 'San Bartolomeo',
			'food.countries.bm' => 'Bermuda',
			'food.countries.bn' => 'Brunei Darussalam',
			'food.countries.bo' => 'Bolivia (Stato Plurinazionale della)',
			'food.countries.bq' => 'Bonaire, Sint Eustatius e Saba',
			'food.countries.br' => 'Brasile',
			'food.countries.bs' => 'Bahamas',
			'food.countries.bt' => 'Butan',
			'food.countries.bv' => 'Isola Bouvet',
			'food.countries.bw' => 'Botswana',
			'food.countries.by' => 'Bielorussia',
			'food.countries.bz' => 'Belize',
			'food.countries.ca' => 'Canada',
			'food.countries.cc' => 'Isole Cocos (Keeling)',
			'food.countries.cd' => 'Congo, Repubblica Democratica del',
			'food.countries.cf' => 'Repubblica Centrafricana',
			'food.countries.cg' => 'Congo',
			'food.countries.ch' => 'Svizzera',
			'food.countries.ci' => 'Costa d\'Avorio',
			'food.countries.ck' => 'Isole Cook',
			'food.countries.cl' => 'Cile',
			'food.countries.cm' => 'Cameron',
			'food.countries.cn' => 'Cina',
			'food.countries.co' => 'Colombia',
			'food.countries.cr' => 'Costa Rica',
			'food.countries.cu' => 'Cuba',
			'food.countries.cv' => 'Capo Verde',
			'food.countries.cw' => 'Curaçao',
			'food.countries.cx' => 'Isola di Natale',
			'food.countries.cy' => 'Cipro',
			'food.countries.cz' => 'Repubblica Ceca',
			'food.countries.de' => 'Germania',
			'food.countries.dj' => 'Djibouti',
			'food.countries.dk' => 'Danimarca',
			'food.countries.dm' => 'Dominica',
			'food.countries.do' => 'Repubblica Domenicana',
			'food.countries.dz' => 'Algeria',
			'food.countries.ec' => 'Ecuador',
			'food.countries.ee' => 'Estonia',
			'food.countries.eg' => 'Egitto',
			'food.countries.eh' => 'Sahara Occidentale',
			'food.countries.er' => 'Eritrea',
			'food.countries.es' => 'Spagna',
			'food.countries.et' => 'Etiopia',
			'food.countries.fi' => 'Finlandia',
			'food.countries.fj' => 'Fiji',
			'food.countries.fk' => 'Isole Falkland (Malvine)',
			'food.countries.fm' => 'Micronesia (Stati Federati di)',
			'food.countries.fo' => 'Isole Fær Øer',
			'food.countries.fr' => 'Francia',
			'food.countries.ga' => 'Gabon',
			'food.countries.gd' => 'Grenada',
			'food.countries.ge' => 'Georgia',
			'food.countries.gf' => 'Guyana Francese',
			'food.countries.gg' => 'Guernsey',
			'food.countries.gh' => 'Ghana',
			'food.countries.gi' => 'Gibilterra',
			'food.countries.gl' => 'Groenlandia',
			'food.countries.gm' => 'Gambia',
			'food.countries.gn' => 'Guinea',
			'food.countries.gp' => 'Guadalupe',
			'food.countries.gq' => 'Guinea Equatoriale',
			'food.countries.gr' => 'Grecia',
			'food.countries.gs' => 'Georgia del Sud e Isole Sandwich Meridionali',
			'food.countries.gt' => 'Guatemala',
			'food.countries.gu' => 'Guam',
			'food.countries.gw' => 'Guinea-Bissau',
			'food.countries.gy' => 'Guyana',
			'food.countries.hk' => 'Hong Kong',
			'food.countries.hm' => 'Isole Heard e McDonald',
			'food.countries.hn' => 'Honduras',
			'food.countries.hr' => 'Croazia',
			'food.countries.ht' => 'Haiti',
			'food.countries.hu' => 'Ungheria',
			'food.countries.id' => 'Indonesia',
			'food.countries.ie' => 'Irlanda',
			'food.countries.il' => 'Israele',
			'food.countries.im' => 'Isola di Man',
			'food.countries.in' => 'India',
			'food.countries.io' => 'Territorio Britannico dell\'Oceano Indiano',
			'food.countries.iq' => 'Iraq',
			'food.countries.ir' => 'Iran (Repubblica Islamica di)',
			'food.countries.is' => 'Islanda',
			'food.countries.it' => 'Italia',
			'food.countries.je' => 'Jersey',
			'food.countries.jm' => 'Giamaica',
			'food.countries.jo' => 'Giordania',
			'food.countries.jp' => 'Giappone',
			'food.countries.ke' => 'Kenya',
			'food.countries.kg' => 'Kyrgyzstan',
			'food.countries.kh' => 'Cambogia',
			'food.countries.ki' => 'Kiribati',
			'food.countries.km' => 'Comoros',
			'food.countries.kn' => 'Saint Kitts e Nevis',
			'food.countries.kp' => 'Corea (Repubblica Democratica Popolare di)',
			'food.countries.kr' => 'Corea, Repubblica di',
			'food.countries.kw' => 'Kuwait',
			'food.countries.ky' => 'Isole Cayman',
			'food.countries.kz' => 'Kazakhstan',
			'food.countries.la' => 'Laos',
			'food.countries.lb' => 'Libano',
			'food.countries.lc' => 'Santa Lucia',
			'food.countries.li' => 'Liechtenstein',
			'food.countries.lk' => 'Sri Lanka',
			'food.countries.lr' => 'Liberia',
			'food.countries.ls' => 'Lesotho',
			'food.countries.lt' => 'Lituania',
			'food.countries.lu' => 'Lussemburgo',
			'food.countries.lv' => 'Lettonia',
			'food.countries.ly' => 'Libia',
			'food.countries.ma' => 'Marocco',
			'food.countries.mc' => 'Monaco',
			'food.countries.md' => 'Moldavia, Repubblica di',
			'food.countries.me' => 'Montenegro',
			'food.countries.mf' => 'Saint Martin (parte francese)',
			'food.countries.mg' => 'Madagascar',
			'food.countries.mh' => 'Isole Marshall',
			'food.countries.mk' => 'Macedonia del Nord',
			'food.countries.ml' => 'Mali',
			'food.countries.mm' => 'Myanmar',
			'food.countries.mn' => 'Mongolia',
			'food.countries.mo' => 'Macao',
			'food.countries.mp' => 'Commonwealth delle Isole Marianne Settentrionali',
			'food.countries.mq' => 'Martinica',
			'food.countries.mr' => 'Mauritania',
			'food.countries.ms' => 'Montserrat',
			'food.countries.mt' => 'Malta',
			'food.countries.mu' => 'Mauritius',
			'food.countries.mv' => 'Maldive',
			'food.countries.mw' => 'Malawi',
			'food.countries.mx' => 'Messico',
			'food.countries.my' => 'Malesia',
			'food.countries.mz' => 'Mozambico',
			'food.countries.na' => 'Namibia',
			'food.countries.nc' => 'Nuova Caledonia',
			'food.countries.ne' => 'Niger',
			'food.countries.nf' => 'Isola Norfolk',
			'food.countries.ng' => 'Nigeria',
			'food.countries.ni' => 'Nicaragua',
			'food.countries.nl' => 'Paesi bassi',
			'food.countries.no' => 'Norvegia',
			'food.countries.np' => 'Nepal',
			'food.countries.nr' => 'Nauru',
			'food.countries.nu' => 'Niue',
			'food.countries.nz' => 'Nuova zelanda',
			'food.countries.om' => 'Oman',
			'food.countries.pa' => 'Panama',
			'food.countries.pe' => 'Perù',
			'food.countries.pf' => 'Polinesia francese',
			'food.countries.pg' => 'Papua Nuova Guinea',
			'food.countries.ph' => 'Filippine',
			'food.countries.pk' => 'Pakistan',
			'food.countries.pl' => 'Polonia',
			'food.countries.pm' => 'Saint Pierre e Miquelon',
			'food.countries.pn' => 'Pitcairn',
			'food.countries.pr' => 'Porto Rico',
			'food.countries.ps' => 'Palestina, Stato di',
			'food.countries.pt' => 'Portogallo',
			'food.countries.pw' => 'Palau',
			'food.countries.py' => 'Paraguay',
			'food.countries.qa' => 'Qatar',
			'food.countries.re' => 'Réunion',
			'food.countries.ro' => 'Romania',
			'food.countries.rs' => 'Serbia',
			'food.countries.ru' => 'Russia (Federazione Russa)',
			'food.countries.rw' => 'Rwanda',
			'food.countries.sa' => 'Arabia Saudita',
			'food.countries.sb' => 'Isole Solomone',
			'food.countries.sc' => 'Seychelles',
			'food.countries.sd' => 'Sudan',
			'food.countries.se' => 'Svezia',
			'food.countries.sg' => 'Singapore',
			'food.countries.sh' => 'Sant\'Elena, Ascensione e Tristan da Cunha',
			'food.countries.si' => 'Slovenia',
			'food.countries.sj' => 'Svalbard e Jan Mayen',
			'food.countries.sk' => 'Slovacchia',
			'food.countries.sl' => 'Sierra Leone',
			'food.countries.sm' => 'San Marino',
			'food.countries.sn' => 'Senegal',
			'food.countries.so' => 'Somalia',
			'food.countries.sr' => 'Suriname',
			'food.countries.ss' => 'Sud Sudan',
			'food.countries.st' => 'Sao Tome e Principe',
			'food.countries.sv' => 'El Salvador',
			'food.countries.sx' => 'Sint Maarten (parte olandese)',
			'food.countries.sy' => 'Siria, Repubblica Araba di',
			'food.countries.sz' => 'Eswatini',
			'food.countries.tc' => 'Isole Turk e Caicos',
			'food.countries.td' => 'Chad',
			'food.countries.tf' => 'Territori Francesi meridionali',
			'food.countries.tg' => 'Togo',
			'food.countries.th' => 'Thailandia',
			'food.countries.tj' => 'Tajikistan',
			'food.countries.tk' => 'Tokelau',
			'food.countries.tl' => 'Timor-Leste',
			'food.countries.tm' => 'Turkmenistan',
			'food.countries.tn' => 'Tunisia',
			'food.countries.to' => 'Tonga',
			'food.countries.tr' => 'Turchia',
			'food.countries.tt' => 'Trinidad e Tobago',
			'food.countries.tv' => 'Tuvalu',
			'food.countries.tw' => 'Taiwan',
			'food.countries.tz' => 'Tanzania, Repubblica Unita di',
			'food.countries.ua' => 'Ucraina',
			'food.countries.ug' => 'Uganda',
			'food.countries.uk' => 'Regno Unito di Gran Bretagna e Irlanda del Nord',
			'food.countries.um' => 'Isole minori esterne degli Stati Uniti',
			'food.countries.us' => 'Stati Uniti d\'America',
			'food.countries.uy' => 'Uruguay',
			'food.countries.uz' => 'Uzbekistan',
			'food.countries.va' => 'Santa Sede',
			'food.countries.vc' => 'Saint Vincent e Grenadine',
			'food.countries.ve' => 'Venezuela (Repubblica Bolivariana del)',
			'food.countries.vg' => 'Virgin Islands (Britanniche)',
			'food.countries.vi' => 'Virgin Islands (U.S.)',
			'food.countries.vn' => 'Vietnam',
			'food.countries.vu' => 'Vanuatu',
			'food.countries.wf' => 'Wallis e Futuna',
			'food.countries.ws' => 'Samoa',
			'food.countries.ye' => 'Yemen',
			'food.countries.yt' => 'Mayotte',
			'food.countries.za' => 'Sudafrica',
			'food.countries.zm' => 'Zambia',
			'food.countries.zw' => 'Zimbabwe',
			'food.countries.world' => 'Mondo',
			'food.categoryList.reorderFailed' => 'Impossibile salvare l’ordine delle categorie. Riprova.',
			'food.categoryList.dailyPercentage' => ({required Object percentage, required Object calories}) => '${percentage}% del totale giornaliero – ${calories}',
			'food.categoryList.empty' => 'Non hai ancora configurato le categorie',
			'food.categoryList.unmodifiable.title' => 'Impossibile modificare',
			'food.categoryList.unmodifiable.text' => 'Puoi modificare solo le categorie nei giorni dopo o durante il giorno corrente.',
			'food.categoryList.title' => 'Categorie',
			'food.categoryList.add' => 'Aggiungi',
			'food.categoryEditor.title.add' => 'Aggiungi categoria',
			'food.categoryEditor.title.edit' => 'Modifica categoria',
			'food.categoryEditor.name' => 'Nome',
			'food.categoryEditor.dailyPercentage' => 'Percentuale giornaliera',
			'food.categoryEditor.fields.name.errors.empty' => 'Il nome non può essere vuoto.',
			'food.categoryEditor.fields.name.errors.unique' => 'C\'è già una categoria con questo nome.',
			'food.categoryEditor.save' => 'Salva',
			'food.categoryEditor.icon' => 'Icona',
			'food.categoryEditor.effect.from' => ({required Object from}) => 'Eventuali modifiche verranno applicate a partire dal ${from}.',
			'food.categoryEditor.effect.range' => ({required Object from, required Object to}) => 'Eventuali modifiche verranno applicate dal ${from} al ${to}.',
			'food.categoryEditor.effect.title' => 'Range di applicazione',
			'food.categoryEditor.nonFulfillingSum.title' => 'La somma non è 100%',
			'food.categoryFoods.empty' => 'Non hai ancora aggiunto cibi a questa categoria.',
			'food.permission.denied' => 'Non siamo stati in grado di ottenere quest\'autorizzazione. Vuoi aprire le impostazioni delle autorizzazioni?',
			'food.permission.openSettings' => 'Apri le impostazioni dell\'app',
			'food.permission.error' => 'Si è verificato un errore.',
			'food.datePicker.today' => 'Oggi',
			'food.catalog.submitAlso' => 'Invia anche al catalogo',
			'food.catalog.publicNotice' => 'Il contributo diventa pubblico e rimane disponibile anche dopo la cancellazione del tuo account.',
			'food.catalog.loginToSubmit' => 'Accedi per inviare alimenti al catalogo. Il salvataggio nel diario rimane disponibile.',
			'food.catalog.queueFailed' => 'Alimento pronto per il diario, ma non è stato possibile accodare l’invio al catalogo.',
			'food.catalog.submissions' => 'Invii al catalogo',
			'food.catalog.noSubmissions' => 'Non hai ancora richiesto invii al catalogo.',
			'food.catalog.loadFailed' => 'Impossibile caricare gli invii.',
			'food.catalog.retry' => 'Riprova invio',
			'food.catalog.cancel' => 'Annulla',
			'food.catalog.report' => 'Segnala alimento',
			'food.catalog.loginToReport' => 'Accedi per segnalare un alimento.',
			'food.catalog.details' => 'Dettagli (facoltativi)',
			'food.catalog.detailsRequired' => 'Specifica il motivo della segnalazione.',
			'food.catalog.sendReport' => 'Invia segnalazione',
			'food.catalog.reportSent' => 'Segnalazione inviata.',
			'food.catalog.reportFailed' => 'Invio non riuscito. Riprova più tardi.',
			'food.catalog.reasons.spam' => 'Spam',
			'food.catalog.reasons.inappropriate' => 'Contenuto non opportuno per Gym Bro',
			'food.catalog.reasons.nutrition' => 'Valori nutrizionali sbagliati',
			'food.catalog.reasons.product' => 'Informazioni sul prodotto o barcode sbagliate',
			'food.catalog.reasons.duplicate' => 'Alimento duplicato',
			'food.catalog.reasons.other' => 'Altro',
			'food.catalog.statuses.pending' => 'In attesa di invio; riprova automaticamente',
			'food.catalog.statuses.sending' => 'Invio in corso',
			'food.catalog.statuses.failed' => 'Invio non riuscito: controlla i dati e riprova',
			'food.catalog.statuses.published' => 'Pubblicato nel catalogo',
			'food.catalog.statuses.duplicate' => 'Già presente nel catalogo',
			'food.catalog.statuses.correction' => 'Correzione inviata per revisione',
			'food.catalog.statuses.unavailable' => 'Voce non disponibile per la pubblicazione',
			'food.catalog.statuses.cancelled' => 'Invio annullato',
			'food.catalog.statuses.cancelled_unknown' => 'Tentativi annullati; un invio precedente potrebbe essere già stato ricevuto',
			'food.catalog.statuses.already_present' => 'Alimento già presente nel catalogo',
			'food.catalog.statuses.uncertain' => 'Non è possibile verificare se questo alimento è già nel catalogo.',
			'food.picker.title' => 'Aggiungi alimento',
			'food.picker.search' => 'Ricerca',
			'food.picker.barcode' => 'Codice a barre',
			'food.picker.more' => 'Altro',
			'food.picker.added' => 'Aggiunti',
			'food.picker.done' => 'Fine',
			'food.picker.recent' => 'Recenti',
			'food.picker.results' => 'Catalogo',
			'food.picker.empty' => 'Nessun alimento trovato',
			_ => null,
		} ?? switch (path) {
			'food.picker.retry' => 'Riprova',
			'food.picker.failed' => 'Operazione non riuscita. Riprova.',
			'food.picker.withBarcode' => 'Personalizzato con codice a barre',
			'food.picker.withoutBarcode' => 'Personalizzato senza codice a barre',
			'food.picker.save' => 'Salva',
			'food.picker.savePrivate' => 'Salva per me',
			'food.picker.share' => 'Aggiungi al catalogo',
			'food.picker.alreadyPresent' => 'Alimento già presente nel catalogo',
			'food.picker.uncertain' => 'Non è possibile verificare se questo alimento è già nel catalogo.',
			'food.picker.queued' => 'Condivisione in attesa di invio',
			'food.picker.published' => 'Alimento pubblicato nel catalogo',
			'food.picker.addedNotice' => 'Alimento aggiunto',
			'food.picker.noAdded' => 'Non hai ancora aggiunto alimenti',
			'food.picker.lookupFailed' => 'Impossibile cercare il codice. Riprova oppure inserisci un alimento personalizzato.',
			'food.picker.custom' => 'Inserisci alimento',
			'food.picker.shareNotice' => 'Salva condivide l’alimento nel catalogo pubblico. Salva per me lo mantiene personale.',
			'food.picker.invalidBarcode' => 'Inserisci un codice a barre valido (4–32 cifre).',
			'food.picker.showMore' => 'Mostra altro',
			'food.recipes.title' => 'Ricette',
			'food.recipes.create' => 'Nuova ricetta',
			'food.recipes.edit' => 'Modifica ricetta',
			'food.recipes.empty' => 'Nessuna ricetta salvata',
			'food.recipes.search' => 'Cerca ricette',
			'food.recipes.name' => 'Nome',
			'food.recipes.description' => 'Descrizione',
			'food.recipes.instructions' => 'Istruzioni di cucina',
			'food.recipes.servings' => 'Porzioni',
			'food.recipes.ingredients' => 'Ingredienti',
			'food.recipes.addIngredient' => 'Aggiungi ingrediente',
			'food.recipes.automaticMass' => 'Peso degli ingredienti',
			'food.recipes.finalMass' => 'Peso finale dopo la cottura (g, facoltativo)',
			'food.recipes.massHint' => 'Lascia vuoto per usare la somma degli ingredienti.',
			'food.recipes.total' => 'Totale',
			'food.recipes.perServing' => 'Per porzione',
			'food.recipes.save' => 'Salva',
			'food.recipes.delete' => 'Elimina',
			'food.recipes.deletePrompt' => 'Eliminare questa ricetta? I pasti già registrati resteranno invariati.',
			'food.recipes.cancel' => 'Annulla',
			'food.recipes.confirm' => 'Conferma',
			'food.recipes.add' => 'Aggiungi al diario',
			'food.recipes.choose' => 'Ricetta',
			'food.recipes.grams' => 'Grammi',
			'food.recipes.portions' => 'Porzioni',
			'food.recipes.equivalentMass' => 'Peso equivalente (g, facoltativo)',
			'food.recipes.liquidMass' => 'Conversione da ml a g',
			'food.recipes.liquidHint' => 'Puoi indicare il peso del liquido in grammi. Se lasci il campo vuoto, verrà usata una conversione di 1 ml = 1 g.',
			'food.recipes.invalid' => 'Inserisci un valore positivo valido.',
			'food.recipes.invalidServings' => 'Inserisci un numero intero da 1 a 32.',
			'food.recipes.requiredName' => 'Inserisci un nome.',
			'food.recipes.requiredIngredients' => 'Aggiungi almeno un ingrediente.',
			'food.recipes.failed' => 'Operazione non riuscita. Riprova.',
			'food.recipes.accountChanged' => 'L’account è cambiato. Riapri la schermata.',
			'food.recipes.editIngredient' => 'Modifica ingrediente',
			'food.recipes.discard' => 'Scartare le modifiche?',
			'food.recipes.discardBody' => 'Le modifiche non salvate andranno perse.',
			'food.recipes.discardAction' => 'Scarta',
			'food.recipes.details' => 'Dettagli ricetta',
			'food.recipes.yieldTitle' => 'Resa e porzioni',
			'food.recipes.nutrition' => 'Valori nutrizionali',
			'food.recipes.ingredientsHint' => 'Scegli gli alimenti e le quantità per comporre la tua ricetta.',
			'food.recipes.decreaseQuantity' => 'Diminuisci quantità',
			'food.recipes.increaseQuantity' => 'Aumenta quantità',
			'equipment.none.long' => 'Corpo libero',
			'equipment.none.short' => 'C. libero',
			'equipment.barbell.long' => 'Bilanciere',
			'equipment.barbell.short' => 'Bilanc.',
			'equipment.dumbbell.long' => 'Manubri',
			'equipment.dumbbell.short' => 'Manubri',
			'equipment.cable.long' => 'Cavi',
			'equipment.cable.short' => 'Cavi',
			'equipment.machine.long' => 'Macchinario',
			'equipment.machine.short' => 'Macch.',
			'equipment.kettlebell.long' => 'Kettlebell',
			'equipment.kettlebell.short' => 'Kettleb.',
			'equipment.plates.long' => 'Piatti',
			'equipment.plates.short' => 'Piatti',
			'equipment.resistanceBand.long' => 'Banda di resistenza',
			'equipment.resistanceBand.short' => 'B. di res.',
			'equipment.suspensionBands.long' => 'Fasce di sospensione',
			'equipment.suspensionBands.short' => 'F. di sosp.',
			'equipment.landmine.long' => 'Landmine',
			'equipment.landmine.short' => 'Landmine',
			'equipment.other.long' => 'Altro',
			'equipment.other.short' => 'Altro',
			'achievements.title' => 'Conquiste',
			'achievements.locked' => 'Bloccato',
			'achievements.unlockedOn' => ({required Object date}) => 'Sbloccato: ${date}',
			'achievements.history' => 'Cronologia',
			'achievements.firstSteps.title' => 'Primi passi',
			'achievements.firstSteps.description.k1' => 'Completa il tuo primo allenamento',
			'achievements.firstSteps.description.k2' => 'Traccia il tuo primo peso',
			'achievements.firstSteps.description.k3' => 'Traccia il tuo primo pasto',
			'achievements.foodWatcher.title' => 'Food blogger',
			'achievements.foodWatcher.description.k1' => 'Traccia i tuoi pasti per 2 giorni di fila',
			'achievements.foodWatcher.description.k2' => 'Traccia i tuoi pasti per 7 giorni di fila',
			'achievements.foodWatcher.description.k3' => 'Traccia i tuoi pasti per un intero mese di fila',
			'achievements.marathoner.title' => 'Maratoneta',
			'achievements.marathoner.description.k1' => 'Percorri una 5km',
			'achievements.marathoner.description.k2' => 'Percorri una mezza maratona',
			'achievements.marathoner.description.k3' => 'Percorri un\'intera maratona',
			'achievements.earlyBird.title' => 'Mattiniero',
			'achievements.earlyBird.description' => 'Inizia un allenamento prima delle 8 del mattino',
			'achievements.nightOwl.title' => 'Notturno',
			'achievements.nightOwl.description' => 'Inizia un allenamento dopo le 8 di sera',
			'achievements.realGymBro.title' => 'Vero Gym Bro',
			'achievements.realGymBro.description.k1' => 'Traccia un totale di 100 ore di allenamenti',
			'achievements.realGymBro.description.k2' => 'Traccia un totale di 500 ore di allenamenti',
			'achievements.realGymBro.description.k3' => 'Traccia un totale di 1000 ore di allenamenti',
			'achievements.workoutFreak.title' => 'Maniaco dell\'allenamento',
			'achievements.workoutFreak.description.k1' => 'Traccia un allenamento al giorno per tutto un mese',
			'achievements.workoutFreak.description.k2' => 'Traccia un allenamento al giorno per tutto un anno',
			'achievements.trailblazer.title' => 'Pioniere',
			'achievements.trailblazer.description.k1.km' => 'Percorri un totale di 100 km',
			'achievements.trailblazer.description.k1.mi' => ({required Object p0}) => 'Percorri un totale di 100 km (${p0})',
			'achievements.trailblazer.description.k2.km' => 'Percorri un totale di 500 km',
			'achievements.trailblazer.description.k2.mi' => ({required Object p0}) => 'Percorri un totale di 500 km (${p0})',
			'achievements.trailblazer.description.k3.km' => 'Percorri un totale di 1000 km',
			'achievements.trailblazer.description.k3.mi' => ({required Object p0}) => 'Percorri un totale di 1000 km (${p0})',
			'achievements.cycleChampion.title' => 'Ciclista campione',
			'achievements.cycleChampion.description.k1.km' => 'Pedala per un totale di 100 km',
			'achievements.cycleChampion.description.k1.mi' => ({required Object p0}) => 'Pedala per un totale di 100 km (${p0})',
			'achievements.cycleChampion.description.k2.km' => 'Pedala per un totale di 500 km',
			'achievements.cycleChampion.description.k2.mi' => ({required Object p0}) => 'Pedala per un totale di 500 km (${p0})',
			'achievements.cycleChampion.description.k3.km' => 'Pedala per un totale di 1000 km',
			'achievements.cycleChampion.description.k3.mi' => ({required Object p0}) => 'Pedala per un totale di 1000 km (${p0})',
			'achievements.professionalWeightlifter.title' => 'Sollevatore di coriandoli',
			'achievements.professionalWeightlifter.description.k1' => 'Solleva il tuo peso corporeo in una ripetizione',
			'achievements.professionalWeightlifter.description.k2' => 'Solleva 1.5x volte il tuo peso corporeo in una ripetizione',
			'achievements.professionalWeightlifter.description.k3' => 'Solleva 3x volte il tuo peso corporeo in una ripetizione',
			'achievements.programPlanner.title' => 'Pianificatore compulsivo',
			'achievements.programPlanner.description' => 'Crea tre routine',
			'achievements.perfectPlanner.title' => 'Pianificatore perfetto',
			'achievements.perfectPlanner.description' => 'Crea una cartella di routine',
			'achievements.routineMaster.title' => 'Maestro delle routine',
			'achievements.routineMaster.description.k1' => 'Segui una routine per 3 mesi consecutivi',
			'achievements.routineMaster.description.k2' => 'Segui una routine per 6 mesi consecutivi',
			'achievements.routineMaster.description.k3' => 'Segui una routine per 12 mesi consecutivi',
			'achievements.intensityInnovator.title' => 'Intensità incendiaria',
			'achievements.intensityInnovator.description' => 'Modifica una routine aumentando pesi o ripetizioni',
			'achievements.completionist.title' => 'Completista',
			'achievements.completionist.description' => 'Prova almeno una volta tutti gli esercizi della libreria',
			'achievements.notDrunk.title' => 'Non sono sbronzo ma brillo!',
			'achievements.notDrunk.description' => 'Completa un allenamento di domenica mattina superando un record personale di volume o distanza',
			'achievements.steamedHams.description' => 'Supera un record personale di massimale in un allenamento impiegando meno tempo del solito',
			'achievements.steamedHams.title' => 'Vitellone al vapore',
			'achievements.swimsuitSeason.title' => 'Prova costume',
			'achievements.swimsuitSeason.description' => 'Accumula 24h di allenamento cardio tra marzo e giugno di un anno',
			'achievements.pbBreaker.title' => 'Primato personale',
			'achievements.pbBreaker.description' => 'Supera il massimale di un esercizio',
			'achievements.sparta.title' => 'Questa è Sparta',
			'achievements.sparta.description.k1.kg' => ({required Object p0}) => 'Solleva 300 lb (${p0}) in una ripetizione',
			'achievements.sparta.description.k1.lb' => 'Solleva 300 lb in una ripetizione',
			'achievements.sparta.description.k2.kg' => 'Solleva 300 kg in una ripetizione',
			'achievements.sparta.description.k2.lb' => ({required Object p0}) => 'Solleva 300 kg (${p0}) in una ripetizione',
			'achievements.midnightRain.title' => 'Midnight Rain',
			'achievements.midnightRain.description' => 'Inizia un allenamento prima di mezzanotte e finiscilo dopo la mezzanotte',
			'achievements.equipmentSpecialist.description' => 'Crea e segui una routine che utilizza esclusivamente un tipo di attrezzo',
			'achievements.equipmentSpecialist.title' => 'Specialista dell\'attrezzatura',
			'achievements.bodyweightBeast.description' => 'Crea una routine solo di corpo libero e seguila per almeno un mese',
			'achievements.bodyweightBeast.title' => 'Controllo corporeo',
			'workoutGenerator.title' => 'Genera allenamento',
			'workoutGenerator.muscleGroups' => 'Seleziona gruppi muscolari',
			'workoutGenerator.equipment' => 'Seleziona attrezzatura',
			'workoutGenerator.actions.generate' => 'Genera',
			'workoutGenerator.success.undo' => 'Annulla',
			'workoutGenerator.success.title' => 'Allenamento generato con successo',
			'workoutGenerator.empty.title' => 'Allenamento vuoto',
			'workoutGenerator.empty.text' => 'Cambia i filtri e riprova',
			'boutique.title' => 'Schede',
			'boutique.package.install' => 'Installa',
			'boutique.package.installed' => 'Il pacchetto è stato installato.',
			'boutique.errors.unknown' => 'Caricamento fallito. Controlla la connessione a Internet e riprova.',
			'boutique.errors.version' => 'Questa versione dell\'app non è compatibile con lo store di schede. Aggiorna all\'ultima versione dell\'app e riprova.',
			'boutique.marketingUpdating.title' => 'Stiamo rimodernando lo store.',
			'boutique.marketingUpdating.description' => 'Torna più tardi per delle schede nuove ed entusiasmanti!',
			'login.title' => 'Login',
			'login.tabs.signIn' => 'Accedi',
			'login.tabs.signUp' => 'Registrati',
			'login.errors.generic' => 'Si è verificato un errore. Riprova tra qualche minuto.',
			'login.errors.username' => 'Lo username deve essere di 3-20 caratteri e può contenere caratteri alfanumerici, trattini e trattini bassi.',
			'login.errors.usernameTaken' => 'Questo username è già in uso.',
			'login.errors.email' => 'Inserisci un indirizzo email valido.',
			'login.errors.password.invalid.header' => 'La password deve:',
			'login.errors.password.invalid.length' => '- Essere lunga almeno 8 caratteri',
			'login.errors.password.invalid.uppercase' => '- Contenere almeno una lettera maiuscola',
			'login.errors.password.invalid.lowercase' => '- Contenere almeno una lettera minuscola',
			'login.errors.password.invalid.number' => '- Contenere almeno un numero',
			'login.errors.password.invalid.specialCharacter' => '- Contenere almeno un carattere speciale',
			'login.errors.noInternet' => 'Nessuna connessione a Internet.',
			'login.errors.passwordRequired' => 'Inserisci la tua password.',
			'login.errors.confirmPasswordRequired' => 'Ripeti la tua password.',
			'login.errors.passwordMismatch' => 'Le password non coincidono.',
			'login.fields.email.label' => 'Email',
			'login.fields.email.hint' => 'mario.rossi@example.com',
			'login.fields.password.label' => 'Password',
			'login.fields.password.hint' => 'Password',
			'login.fields.username.label' => 'Username',
			'login.fields.username.hint' => 'Username',
			'login.fields.confirmPassword.label' => 'Conferma password',
			'login.buttons.signIn' => 'Accedi',
			'login.buttons.signUp' => 'Registrati',
			'login.buttons.showPassword' => 'Mostra password',
			'login.buttons.hidePassword' => 'Nascondi password',
			'login.buttons.dismissKeyboard' => 'Chiudi tastiera',
			'login.upsell.title' => 'Accesso non effettuato',
			'login.upsell.subtitle' => 'Accedi per usufruire di allenamenti di gruppo, sincronizzazione su più dispositivi e tanto altro.',
			'login.verifyEmail.title' => 'Ti abbiamo inviato un\'email di verifica',
			'login.verifyEmail.done' => 'Ho verificato la mia email',
			'login.verifyEmail.description' => 'Controlla la tua casella di posta elettronica per confermare la tua email. Dopodiché tocca il pulsante sottostante per accedere.',
			'login.verifyEmail.notVerified' => 'Verifica il tuo indirizzo email e riprova.',
			'login.presentation.signInTitle' => 'Accedi a Gym Bro',
			'login.presentation.signInSubtitle' => 'Ritrova i tuoi allenamenti e mantieni i tuoi progressi sincronizzati.',
			'login.presentation.signUpTitle' => 'Crea il tuo profilo',
			'login.presentation.signUpSubtitle' => 'Salva i tuoi progressi e condividi gli allenamenti con i tuoi amici.',
			'login.presentation.passwordRequirements' => 'Almeno 8 caratteri, con una maiuscola, una minuscola, un numero e un carattere speciale.',
			'login.presentation.noAccount' => 'Non hai un account?',
			'login.presentation.haveAccount' => 'Hai già un account?',
			'login.recovery.forgot' => 'Password dimenticata?',
			'login.recovery.title' => 'Recupera la password',
			'login.recovery.description' => 'Inserisci la tua email: ti invieremo un link per scegliere una nuova password sul sito di Gym Bro.',
			'login.recovery.send' => 'Invia il link',
			'login.recovery.sentTitle' => 'Controlla la tua email',
			'login.recovery.sentDescription' => 'Se esiste un account associato a questo indirizzo, riceverai un link per reimpostare la password. Dopo averla aggiornata sul sito, torna qui per accedere.',
			'login.recovery.checkSpam' => 'Controlla anche la cartella spam. Se non trovi il messaggio, puoi tornare indietro e riprovare.',
			'login.recovery.backToSignIn' => 'Torna ad accedere',
			'login.recovery.error' => 'Non siamo riusciti a inviare il link. Attendi qualche minuto e riprova.',
			'sync.conflict.title' => 'Trovati dati contrastanti',
			'sync.conflict.message' => 'Premei OK per scaricare i dati nel cloud e sovrascrivere i dati locali. Premi Annulla per cancellare i dati nel cloud e caricare i dati locali.',
			'sync.overwrite.title' => 'Dati più vecchi',
			'sync.overwrite.message' => 'Vuoi sovrascrivere i dati sul server con i dati locali?',
			'sync.inProgress' => 'Sincronizzo',
			'bodyMeasurement.neck.label' => 'Collo',
			'bodyMeasurement.waist.label' => 'Vita',
			'bodyMeasurement.bodyFat.label' => 'Percentuale di grasso corporeo',
			'bodyMeasurement.shoulder.label' => 'Spalla',
			'bodyMeasurement.chest.label' => 'Petto',
			'bodyMeasurement.leftBicep.label' => 'Bicipite sinistro',
			'bodyMeasurement.rightBicep.label' => 'Bicipite destro',
			'bodyMeasurement.leftForearm.label' => 'Avambraccio sinistro',
			'bodyMeasurement.rightForearm.label' => 'Avambraccio destro',
			'bodyMeasurement.abdomen.label' => 'Addome',
			'bodyMeasurement.hips.label' => 'Anche',
			'bodyMeasurement.leftThigh.label' => 'Coscia sinistra',
			'bodyMeasurement.rightThigh.label' => 'Coscia destra',
			'bodyMeasurement.leftCalf.label' => 'Polpaccio sinistro',
			'bodyMeasurement.rightCalf.label' => 'Polpaccio destro',
			'onboarding.buttons.skip' => 'Salta per ora',
			'onboarding.buttons.next' => 'Avanti',
			'onboarding.buttons.done' => 'Iniziamo!',
			'onboarding.welcome.title' => 'Ti diamo il benvenuto a Gym Bro',
			'onboarding.welcome.text' => 'Il tuo compagno di allenamento.\nDobbiamo verificare alcune autorizzazioni prima di iniziare.',
			'onboarding.notifications.title' => 'Notifiche',
			'onboarding.notifications.text' => 'Consenti a Gym Bro di inviarti notifiche sui tempi di recupero.',
			'onboarding.notifications.notifications' => 'Notifiche',
			'onboarding.notifications.exactAlarm' => 'Notifiche immediate (per il tempo di recupero)',
			'onboarding.camera.title' => 'Fotocamera e galleria',
			'onboarding.camera.text' => 'Consenti a Gym Bro di accedere alla fotocamera al fine di scansionare i codici a barre nel diario alimentare.',
			'onboarding.camera.gallery' => 'Galleria',
			'onboarding.camera.camera' => 'Fotocamera',
			'onboarding.done.title' => 'Ecco fatto',
			'onboarding.done.text' => 'Puoi iniziare i tuoi allenamenti con Gym Bro.',
			'onboarding.login.title' => 'Accedi',
			'onboarding.login.text' => 'Sincronizza i tuoi dati, guarda gli allenamenti dei tuoi amici e molto altro!',
			'nags.routines.title' => 'Stai usando Gym Bro da un po\' di tempo, vero?',
			'nags.routines.subtitle' => 'Con Gym Bro Pro, puoi creare routine illimitate. Diventa un Pro Bro e porta i tuoi allenamenti al livello successivo!',
			'nags.button' => 'Unisciti ora!',
			'nags.library.title' => 'Stai esplorando Gym Bro da un po\' di tempo, vero?',
			'nags.library.subtitle' => 'Con Gym Bro Pro, puoi creare esercizi illimitati. Diventa un Pro Bro e porta i tuoi allenamenti al livello successivo!',
			'nags.history.title' => 'Stai sfruttando Gym Bro da un bel po\' di tempo, sembra!',
			'nags.history.subtitle' => 'Con Gym Bro Pro, puoi iniziare allenamenti illimitati. Diventa un Pro Bro e porta i tuoi allenamenti al livello successivo!',
			'nags.food.title' => 'Aspetta un attimo, non puoi ancora farlo.',
			'nags.food.subtitle' => 'Con la versione Pro, puoi vedere i dati storici dei tuoi pasti. Diventa un Pro Bro e porta la tua nutrizione al livello successivo!',
			'feed.title' => 'Feed',
			'feed.empty.title' => 'Nessuna attività',
			'feed.empty.text' => 'Non ci sono ancora attività da mostrare. Inizia un allenamento o sblocca un traguardo per vedere le tue attività qui.',
			'feed.startWorkout' => 'Scegli un allenamento',
			'feed.workout.title.you' => 'Tu',
			'feed.workout.title.unknown' => 'Utente Sconosciuto',
			'feed.workout.subtitle.you' => 'hai completato un allenamento',
			'feed.workout.subtitle.friend' => 'ha completato un allenamento',
			'feed.achievement.title.you' => 'Tu',
			'feed.achievement.subtitle.you' => 'hai sbloccato un traguardo',
			'feed.achievement.subtitle.friend' => 'ha sbloccato un traguardo',
			'feed.userButton.loading' => 'Caricamento profilo utente in corso...',
			'feed.userButton.error' => 'Impossibile caricare il profilo',
			'feed.noSync.text' => 'La sincronizzazione è in pausa: non sei connesso a Internet. Potrebbero volerci alcuni minuti. Non preoccuparti, i dati verranno mantenuti in locale e trasferiti in un secondo momento.',
			'feed.noMoreData' => 'Hai raggiunto la fine del feed :)',
			'feed.loadMore' => 'Carica altro',
			'feed.suggestedRoutines' => 'Routine suggerite',
			'feed.suggestions.start' => 'Inizia',
			'feed.suggestions.assignedBy' => ({required Object name}) => 'Assegnata da ${name}',
			'feed.suggestions.assignedByTrainer' => 'Assegnata dal tuo trainer',
			'feed.loadError.title' => 'Impossibile caricare le attività',
			'feed.loadError.text' => 'Controlla la connessione e riprova.',
			'workoutPage.title' => 'Allenati',
			'pro.title' => 'PRO',
			'userProfile.title' => 'Profilo',
			'userProfile.addFriend' => 'Aggiungi amico',
			'userProfile.unfriend' => 'Rimuovi amico',
			'userProfile.requestSent' => 'Richiesta inviata',
			'userProfile.cancelRequestConfirmation.title' => 'Annullare richiesta?',
			'userProfile.cancelRequestConfirmation.keep' => 'Mantieni richiesta',
			'userProfile.cancelRequestConfirmation.confirm' => 'Annulla richiesta',
			'userProfile.cancelRequestConfirmation.error' => 'Impossibile annullare la richiesta di amicizia. Riprova.',
			'userProfile.accept' => 'Accetta',
			'userProfile.decline' => 'Rifiuta',
			'userProfile.unfriendConfirmation.title' => ({required Object name}) => 'Rimuovere ${name} dagli amici?',
			'userProfile.unfriendConfirmation.subtitle' => 'Non apparirà più nel tuo feed, e tu non apparirai nel suo.',
			'userProfile.unfriendConfirmation.confirm' => 'Rimuovi',
			'userProfile.unfriendConfirmation.cancel' => 'Annulla',
			'userProfile.reject' => 'Rifiuta',
			'userProfile.stats.friends' => 'Amici',
			'userProfile.stats.workouts' => 'Allenamenti',
			'userProfile.stats.achievements' => 'Traguardi',
			'userProfile.feed.unavailable.title' => 'Allenamenti non visibili',
			'userProfile.feed.unavailable.description' => 'I dati degli allenamenti sono visibili solo agli amici.',
			'userProfile.edit.tooltip' => 'Modifica profilo',
			'userProfile.edit.title' => 'Modifica profilo',
			'userProfile.edit.fullName' => 'Nome completo',
			'userProfile.edit.fullNameHint' => 'Inserisci il tuo nome completo',
			'userProfile.edit.profilePicture' => 'Immagine del profilo',
			'userProfile.edit.changePicture' => 'Cambia immagine',
			'userProfile.edit.removePicture' => 'Rimuovi immagine',
			'userProfile.edit.uploading' => 'Caricamento...',
			'userProfile.edit.saving' => 'Salvataggio...',
			'userProfile.edit.success' => 'Profilo aggiornato con successo!',
			'userProfile.edit.error' => 'Errore durante l\'aggiornamento del profilo',
			'userProfile.edit.cropTitle' => 'Ritaglia foto',
			'userProfile.edit.cropInstructions' => 'Trascina e pizzica per posizionare la foto',
			'userProfile.edit.done' => 'Fatto',
			'userProfile.crop.buttons.confirm' => 'Ritaglia',
			'userProfile.crop.buttons.cancel' => 'Annulla',
			'userProfile.error.title' => 'Errore',
			'userProfile.error.retry' => 'Riprova',
			'userProfile.errors.noInternet' => 'Sei offline. Controlla la connessione a Internet e riprova.',
			'friendRequests.title' => 'Richieste di amicizia',
			'friendRequests.subtitle' => 'ti ha inviato una richiesta di amicizia',
			'friendRequests.empty.title' => 'Nessuna richiesta',
			'friendRequests.empty.text' => 'Non hai richieste di amicizia in sospeso al momento.',
			'profileSearch.title' => 'Cerca profili',
			'profileSearch.searchHint' => 'Cerca nome utente...',
			'profileSearch.noResults.title' => 'Nessun profilo trovato',
			'profileSearch.noResults.text' => 'Prova a cercare un nome utente diverso.',
			'you' => 'Tu',
			'error.title' => 'Si è verificato un errore',
			'error.retry' => 'Riprova',
			'error.logs' => 'Apri log',
			'legacyWorkoutRecovery.title' => 'Allenamento precedente da recuperare',
			'legacyWorkoutRecovery.action' => 'Recupera in questo account',
			'legacyWorkoutRecovery.confirm' => ({required Object account}) => 'Recuperare questo allenamento in ${account}? Diventerà l’allenamento in corso di questo account.',
			'legacyWorkoutRecovery.guest' => 'Ospite',
			'legacyWorkoutRecovery.failed' => 'Impossibile recuperare l’allenamento. Verifica che questo account non abbia un allenamento in corso, poi riprova.',
			'friendsList.loadMore' => 'Carica altri',
			'friendsList.title' => 'Amici',
			'friendsList.empty' => 'Non hai ancora amici',
			'friendsList.emptyDescription' => 'Le amicizie accettate appariranno qui.',
			'friendsList.historyTitle' => ({required Object name}) => 'Traguardi di ${name}',
			'friendsList.historyEmpty' => 'Nessun traguardo ottenuto',
			'friendsList.historyEmptyDescription' => 'I traguardi ottenuti da questo amico appariranno qui.',
			'friendsList.unknownAchievement' => 'Traguardo sconosciuto',
			'friendsList.accessDenied' => 'La cronologia è disponibile solo per i tuoi amici.',
			'social.notifications' => 'Notifiche',
			'social.post' => 'Post',
			'social.comments' => 'Commenti',
			'social.comment' => 'Commenta',
			'social.like' => 'Mi piace',
			'social.unlike' => 'Non mi piace più',
			'social.send' => 'Invia',
			'social.edit' => 'Modifica',
			'social.delete' => 'Elimina',
			'social.more' => 'Carica altri',
			'social.private' => 'Solo io',
			'social.friends' => 'Amici',
			'social.visibility' => 'Visibilità',
			'social.pending' => 'Modifica in attesa di sincronizzazione',
			'social.unpublished' => 'In attesa di pubblicazione',
			'social.unavailable' => 'Contenuto non disponibile',
			'social.error' => 'Operazione non riuscita. Riprova.',
			'social.empty' => 'Non ci sono elementi da mostrare.',
			'social.block' => 'Blocca utente',
			'social.unblock' => 'Sblocca',
			'social.blockedUsers' => 'Utenti bloccati',
			'social.report' => 'Segnala utente',
			'social.reports' => 'Le mie segnalazioni',
			'social.reason' => 'Motivazione (obbligatoria)',
			'social.reportSent' => 'Segnalazione inviata',
			'social.blockConfirm' => 'Bloccare questo utente? L’amicizia e le richieste verranno eliminate.',
			'social.cancel' => 'Annulla',
			'social.confirm' => 'Conferma',
			'social.received' => 'Ricevuta',
			'social.reviewing' => 'In esame',
			'social.resolved' => 'Risolta',
			'social.dismissed' => 'Archiviata',
			'social.friendRequest' => 'Ti ha inviato una richiesta di amicizia',
			'social.friendAccepted' => 'Ha accettato la tua richiesta di amicizia',
			'social.likedPost' => 'Ha messo Mi piace al tuo post',
			'social.commentedPost' => 'Ha commentato il tuo post',
			'social.achievementUnlocked' => 'Ha sbloccato un achievement',
			'social.reportUpdated' => 'Lo stato della tua segnalazione è cambiato',
			'social.accept' => 'Accetta',
			'social.reject' => 'Rifiuta',
			'social.signIn' => 'Accedi per continuare',
			'social.save' => 'Salva',
			'social.push' => 'Notifiche push',
			'social.pushDescription' => 'Richieste, interazioni, achievement e segnalazioni',
			'social.pushDisabled' => 'Push non configurate su questo dispositivo',
			'social.trainerPlan' => 'Il tuo trainer ha pubblicato una scheda o una revisione',
			'hydration.title' => 'Acqua',
			'hydration.drinking' => 'Acqua bevuta',
			'hydration.food' => 'Dagli alimenti',
			'hydration.add' => 'Aggiungi acqua',
			'hydration.custom' => 'Quantità personalizzata',
			'hydration.amount' => 'Quantità (ml)',
			'hydration.time' => 'Orario',
			'hydration.goal' => 'Obiettivo giornaliero (ml)',
			'hydration.setGoal' => 'Imposta obiettivo',
			'hydration.noGoal' => 'Nessun obiettivo impostato',
			'hydration.optionalGoal' => 'Lascia vuoto per rimuovere l’obiettivo',
			'hydration.save' => 'Salva',
			'hydration.cancel' => 'Annulla',
			'hydration.delete' => 'Elimina',
			'hydration.edit' => 'Modifica',
			'hydration.invalid' => 'Inserisci una quantità positiva valida',
			'hydration.future' => 'Scegli un orario nel passato',
			'hydration.connect' => 'Collega a Salute',
			'hydration.disconnect' => 'Disattiva invio a Salute',
			'hydration.disabled' => 'Invio a Salute disattivato',
			'hydration.synced' => 'Acqua sincronizzata con Salute',
			'hydration.pending' => 'Invio a Salute in attesa: controlla i permessi e riprova',
			'hydration.unavailable' => 'Servizio Salute non disponibile',
			'hydration.syncing' => 'Invio a Salute…',
			'hydration.empty' => 'Nessuna acqua bevuta registrata',
			'hydration.error' => 'Impossibile salvare. Riprova.',
			'hydration.natural' => 'Acqua naturale',
			'hydration.sparkling' => 'Acqua frizzante',
			'hydration.cucumber' => 'Cetriolo con buccia, crudo',
			'hydration.tomato' => 'Pomodoro rosso, crudo',
			'hydration.watermelon' => 'Anguria, cruda',
			'hydration.apple' => 'Mela con buccia, cruda',
			'hydration.source' => 'Fonte: USDA SR Legacy',
			'hydration.waterPer100' => 'Acqua (ml per 100 g/ml)',
			'hydration.history' => 'Cronologia acqua',
			'hydration.permissionDenied' => 'L’acqua viene salvata nel diario. Per aggiungerla anche a Salute, consenti l’accesso da Impostazioni → Autorizzazioni.',
			'reports.title' => 'Report progressi',
			'reports.day' => 'Giorno',
			'reports.week' => 'Settimana',
			'reports.month' => 'Mese',
			'reports.training' => 'Allenamento',
			'reports.nutrition' => 'Alimentazione',
			'reports.measurements' => 'Misurazioni corporee',
			'reports.preview' => 'Anteprima report',
			'reports.save' => 'Salva PDF',
			'reports.share' => 'Condividi',
			'reports.reference' => 'Data di riferimento',
			'reports.chooseSection' => 'Seleziona almeno una sezione.',
			'reports.empty' => 'Nessuna registrazione nel periodo.',
			'reports.missing' => 'Nessuna registrazione',
			'reports.unavailable' => 'Non disponibile',
			'reports.error' => 'Impossibile generare il report. Riprova.',
			'reports.exportError' => 'Impossibile esportare il PDF. Riprova.',
			'reports.retry' => 'Riprova',
			'reports.saved' => 'PDF salvato',
			'reports.generated' => 'Generato il',
			'reports.daily' => 'Dettaglio giornaliero',
			'reports.summary' => 'Riepilogo',
			'reports.sessions' => 'Sessioni',
			'reports.sets' => 'Serie completate',
			'reports.reps' => 'Ripetizioni',
			'reports.load' => 'Carico',
			'reports.duration' => 'Durata',
			'reports.distance' => 'Distanza',
			'reports.volume' => 'Volume (carichi positivi × ripetizioni)',
			'reports.exercise' => 'Esercizio',
			'reports.status' => 'Stato',
			'reports.done' => 'Completata',
			'reports.pending' => 'Non completata',
			'reports.superset' => 'Superserie',
			'reports.continuation' => 'Continuazione',
			'reports.food' => 'Alimento / pasto',
			'reports.quantity' => 'Quantità',
			'reports.calories' => 'Calorie',
			'reports.protein' => 'Proteine',
			'reports.carbs' => 'Carboidrati',
			'reports.fat' => 'Grassi',
			'reports.total' => 'Totale',
			'reports.average' => 'Media per giorno registrato',
			'reports.coverage' => 'Giorni con registrazioni',
			'reports.first' => 'Prima',
			'reports.last' => 'Ultima',
			'reports.change' => 'Variazione',
			'reports.value' => 'Valore',
			'reports.date' => 'Data',
			'reports.goal' => 'Obiettivo giornaliero salvato',
			'reports.criteria' => 'Le medie alimentari usano solo i giorni con alimenti registrati, inclusi i valori zero. I totali descrivono gli alimenti registrati, non necessariamente giornate complete. Le registrazioni assenti non equivalgono a zero. I totali di allenamento comprendono solo le serie svolte; il volume include solo carichi positivi con ripetizioni. Le variazioni corporee usano la prima e l’ultima misura effettiva del periodo. Nessuna interpolazione o misura prevista. I grafici corporei mostrano l’ultima misura effettiva di ogni giorno.',
			'reports.partial' => 'Periodo in corso: sono incluse solo le registrazioni disponibili alla generazione.',
			'reports.units' => 'Unità',
			'reports.activityChart' => 'Serie completate per giorno',
			'reports.calorieChart' => 'Calorie registrate per giorno',
			'reports.chartNote' => 'I punti indicano valori registrati. I giorni senza dati restano vuoti, senza interpolazione.',
			'reports.privacy' => 'Report locale · Nessuna valutazione medica o nutrizionale',
			'reports.selection' => 'Contenuto del report',
			'reports.weight' => 'Peso',
			'reports.configureDescription' => 'Crea un report dei tuoi progressi da salvare o condividere con il tuo professionista.',
			'reports.period' => 'Periodo',
			'reports.includedPeriod' => 'Periodo incluso nel report',
			'reports.weekReferenceHint' => 'Scegli un giorno della settimana da includere.',
			'reports.monthReferenceHint' => 'Scegli un giorno del mese da includere.',
			'reports.selectionHint' => 'Scegli una o più sezioni da inserire nel PDF.',
			'reports.previewTitle' => 'Anteprima PDF',
			'plateau.title' => 'Possibili plateau',
			'plateau.intro' => 'Ultime 8 settimane, considerando solo le serie normali completate. A seguire sono riportati suggerimenti basati sull\'analisi dei dati, che non vanno presi come certezza.',
			'plateau.criteria' => 'Servono 6 sedute confrontabili in almeno 28 giorni e 4 settimane di calendario, di cui l’ultima entro 14 giorni, senza pause oltre i 21 giorni. Il riferimento è la mediana delle prime 3 sedute. Viene considerato progresso: +2,5% di carico senza perdere ripetizioni, +1 ripetizione a carico equivalente (±1%) oppure +5% di volume. A corpo libero: +1 ripetizione nella serie migliore o +5% di ripetizioni totali.',
			_ => null,
		} ?? switch (path) {
			'plateau.possiblePlateau' => 'Possibile plateau',
			'plateau.progressing' => 'Nessun possibile plateau rilevato',
			'plateau.insufficientData' => 'Servono più dati: registra almeno 6 sedute confrontabili distribuite su 4 settimane.',
			'plateau.stale' => 'Mancano sedute confrontabili recenti: riprendi a registrare questo esercizio prima di valutarne i progressi.',
			'plateau.unsupported' => 'Non valutato: assistenza, tempo e distanza non offrono metriche confrontabili di carico e ripetizioni.',
			'plateau.incomparable' => 'Non valutato: identità, definizione dell’esercizio o più sedute nello stesso giorno impediscono un confronto affidabile.',
			'plateau.empty' => 'Servono più dati. Registra serie completati per diverse settimane per valutare i progressi.',
			'plateau.period' => 'Periodo',
			'plateau.sessions' => 'Sedute',
			'plateau.sets' => 'Serie normali per seduta',
			'plateau.reference' => 'Riferimento: mediana delle prime 3 sedute',
			'plateau.load' => 'Carico massimo',
			'plateau.reps' => 'Ripetizioni al carico massimo',
			'plateau.bestReps' => 'Ripetizioni massime per serie',
			'plateau.totalReps' => 'Ripetizioni totali',
			'plateau.volume' => 'Volume della seduta',
			'plateau.data' => 'Sedute utilizzate',
			'plateau.other' => 'Altri esercizi',
			'plateau.volumeInfo' => 'Volume = somma di carico × ripetizioni delle serie selezionati. Il corpo libero viene valutato solo tramite le ripetizioni.',
			'progression.title' => 'Progressione guidata',
			'progression.configure' => 'Imposta progressione',
			'progression.remove' => 'Rimuovi progressione',
			'progression.lastTime' => 'Ultima volta',
			'progression.noHistory' => 'Completa una sessione per vedere l\'ultima prestazione',
			'progression.goal' => 'Obiettivo di oggi',
			'progression.double' => 'Doppia progressione',
			'progression.cyclic' => 'Progressione lineare ciclica',
			'progression.minReps' => 'Ripetizioni minime',
			'progression.maxReps' => 'Ripetizioni massime',
			'progression.repsPerStep' => 'Ripetizioni per passo',
			'progression.startingWeight' => 'Peso iniziale',
			'progression.weightPerStep' => 'Aumento del peso per passo',
			'progression.weightPerCycle' => 'Aumento del peso iniziale per ciclo',
			'progression.preview' => 'Prossimi obiettivi',
			'progression.save' => 'Salva',
			'progression.invalid' => 'Controlla i valori e il numero di serie normali',
			'progression.step' => ({required Object cycle, required Object step}) => 'Ciclo ${cycle}, passo ${step}',
			'progression.advance' => 'Avanza manualmente',
			'paywall.title' => 'GymBro Pro',
			'paywall.subtitle' => 'Scegli un abbonamento per sbloccare le funzionalità Pro.',
			'paywall.loadError' => 'Impossibile caricare gli abbonamenti. Riprova.',
			'paywall.empty' => 'Nessun abbonamento disponibile al momento. Riprova più tardi.',
			'paywall.trialPeriod.week' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: 'Prova gratuita: ${n} settimana', other: 'Prova gratuita: ${n} settimane', ),
			'paywall.trialPeriod.month' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: 'Prova gratuita: ${n} mese', other: 'Prova gratuita: ${n} mesi', ),
			'paywall.trialPeriod.year' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: 'Prova gratuita: ${n} anno', other: 'Prova gratuita: ${n} anni', ),
			'paywall.trialPeriod.day' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: 'Prova gratuita: ${n} giorno', other: 'Prova gratuita: ${n} giorni', ),
			'paywall.autoRenewNotice.week' => ({required Object price}) => 'Rinnovo automatico a ${price} a settimana fino alla disdetta.',
			'paywall.autoRenewNotice.month' => ({required Object price}) => 'Rinnovo automatico a ${price} al mese fino alla disdetta.',
			'paywall.autoRenewNotice.year' => ({required Object price}) => 'Rinnovo automatico a ${price} all’anno fino alla disdetta.',
			'paywall.autoRenewNotice.day' => ({required Object price}) => 'Rinnovo automatico a ${price} al giorno fino alla disdetta.',
			'paywall.purchaseError.title' => 'Acquisto non riuscito',
			'paywall.purchaseError.subtitle' => 'Impossibile completare l’acquisto. Riprova.',
			'paywall.restoreError.title' => 'Ripristino non riuscito',
			'paywall.restoreError.subtitle' => 'Impossibile ripristinare gli acquisti. Riprova.',
			'paywall.actions.subscribe' => 'Abbonati',
			'paywall.actions.restorePurchase' => 'Ripristina acquisti',
			'paywall.actions.termsOfService' => 'Termini di servizio',
			'paywall.actions.privacyPolicy' => 'Informativa sulla privacy',
			'routineImport.summary' => 'Contenuto da importare',
			'routineImport.summaryDescription' => 'Importa una copia personale. Il programma condiviso rimarrà invariato.',
			'routineImport.days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: '1 giornata', other: '${n} giornate', ),
			'routineImport.exercises' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: '1 esercizio', other: '${n} esercizi', ),
			'routineImport.sets' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('it'))(n, one: '1 serie', other: '${n} serie', ),
			'routineImport.preview' => 'Anteprima allenamento',
			'routineImport.day' => 'Giornata',
			'routineImport.dayDescription' => 'Scegli una giornata da consultare. Verrà importato il programma completo.',
			'routineImport.programNotes' => 'Note del programma',
			'routineImport.workoutNotes' => 'Note dell’allenamento',
			'routineImport.exerciseList' => 'Esercizi',
			'routineImport.emptyTitle' => 'Nessun esercizio in questa giornata',
			'routineImport.emptyDescription' => 'Questa giornata non contiene ancora esercizi da svolgere.',
			'routineImport.noSets' => 'Nessuna serie prescritta',
			'routineImport.custom' => 'Esercizio personalizzato',
			'routineImport.assistance' => 'Assistenza',
			'routineImport.rest' => ({required Object duration}) => 'Recupero ${duration}',
			'routineImport.setNumber' => ({required Object number}) => 'Serie ${number}',
			'routineImport.seconds' => ({required Object count}) => '${count} s',
			'routineImport.loadingTitle' => 'Apertura del programma condiviso',
			'routineImport.loadingDescription' => 'Caricamento delle giornate e delle prescrizioni.',
			'routineImport.unavailableTitle' => 'Programma non disponibile',
			'routineImport.retry' => 'Riprova',
			'routineImport.proRequired' => 'Per importare le schede condivise è necessario Gym Bro Pro.',
			'routineImport.importing' => 'Importazione…',
			'routineImport.loadError' => 'Si è verificato un problema. Riprova tra poco.',
			'routineImport.networkError' => 'Impossibile connettersi. Controlla la connessione e riprova.',
			_ => null,
		};
	}
}
