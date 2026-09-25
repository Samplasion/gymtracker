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
		'hamstrings': 'Posteriori della coscia',
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
	@override String get startWorkout => 'Inizia un allenamento';
	@override late final Translations$feed$workout$it workout = Translations$feed$workout$it._(_root);
	@override late final Translations$feed$achievement$it achievement = Translations$feed$achievement$it._(_root);
	@override late final Translations$feed$userButton$it userButton = Translations$feed$userButton$it._(_root);
	@override late final Translations$feed$noSync$it noSync = Translations$feed$noSync$it._(_root);
	@override String get noMoreData => 'Hai raggiunto la fine del feed :)';
	@override String get loadMore => 'Carica altro';
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
	@override String get title => 'Allenamento rapido';
	@override String get subtitle => 'Avvia rapidamente un allenamento vuoto';
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
	@override String get hint => 'Cerca cronologia o OpenFoodFacts…';
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
}

// Path: login.fields
class Translations$login$fields$it implements Translations$login$fields$en {
	Translations$login$fields$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override late final Translations$login$fields$email$it email = Translations$login$fields$email$it._(_root);
	@override late final Translations$login$fields$password$it password = Translations$login$fields$password$it._(_root);
	@override late final Translations$login$fields$username$it username = Translations$login$fields$username$it._(_root);
}

// Path: login.buttons
class Translations$login$buttons$it implements Translations$login$buttons$en {
	Translations$login$buttons$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get signIn => 'Accedi';
	@override String get signUp => 'Registrati';
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
}

// Path: feed.noSync
class Translations$feed$noSync$it implements Translations$feed$noSync$en {
	Translations$feed$noSync$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get text => 'La sincronizzazione è in pausa: non sei connesso a Internet. Potrebbero volerci alcuni minuti. Non preoccuparti, i dati verranno mantenuti in locale e trasferiti in un secondo momento.';
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
	@override String get aerobics => 'Aerobica';
	@override String get biking => 'Bicicletta';
	@override String get ergometer => 'Ergometro';
	@override String get ergometerHorizontal => 'Ergometro (orizzontale)';
	@override String get pilates => 'Pilates';
	@override String get running => 'Corsa';
	@override String get treadmill => 'Tapis roulant';
	@override String get zumba => 'Zumba';
	@override String get jumpRope => 'Salto con la corda';
	@override String get rowingMachine => 'Remoergometro';
	@override String get bicycleCrunchesCardio => 'Bicycle crunch a tempo';
	@override String get crunchesTimed => 'Crunch a tempo';
}

// Path: library.chest.exercises
class Translations$library$chest$exercises$it implements Translations$library$chest$exercises$en {
	Translations$library$chest$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get barbellBenchPressFlat => 'Panca piana (bilanciere)';
	@override String get barbellBenchPressIncline => 'Panca inclinata (bilanciere, in avanti)';
	@override String get barbellBenchPressDecline => 'Panca inclinata (bilanciere, all\'indietro)';
	@override String get dumbbellBenchPressFlat => 'Panca piana (manubri)';
	@override String get dumbbellBenchPressIncline => 'Panca inclinata (manubri, in avanti)';
	@override String get dumbbellBenchPressDecline => 'Panca inclinata (manubri, all\'indietro)';
	@override String get smithMachineBenchPressFlat => 'Panca piana (Multipower)';
	@override String get smithMachineBenchPressIncline => 'Panca inclinata (Multipower, in avanti)';
	@override String get smithMachineBenchPressDecline => 'Panca inclinata (Multipower, all\'indietro)';
	@override String get cableBenchPressFlat => 'Panca piana (cavi)';
	@override String get cableBenchPressIncline => 'Panca inclinata (cavi, in avanti)';
	@override String get cableBenchPressDecline => 'Panca inclinata (cavi, all\'indietro)';
	@override String get butterflyMachine => 'Butterfly machine';
	@override String get dumbbellHexPress => 'Hex Press (manubri)';
	@override String get smithMachineHexPress => 'Hex Press al Multipower';
	@override String get seatedCableChestFlys => 'Croci ai cavi da seduto';
	@override String get verticalChestPress => 'Chest press (verticale)';
	@override String get cableFlyCrossovers => 'Croci ai cavi alti';
	@override String get pushUps => 'Push-up';
	@override String get pushUpsWeighted => 'Push-up (zavorrati)';
	@override String get cableChestPress => 'Chest press ai cavi';
	@override String get declinePushUps => 'Push-up declinati';
	@override String get lowCableFly => 'Croci ai cavi bassi';
	@override String get inclinePushUps => 'Push-up inclinati';
	@override String get tBarPress => 'Pressa con bilanciere a T';
	@override String get inclineBenchFlys => 'Croci su panca inclinata';
	@override String get benchFlys => 'Croci su panca piana';
}

// Path: library.biceps.exercises
class Translations$library$biceps$exercises$it implements Translations$library$biceps$exercises$en {
	Translations$library$biceps$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get barbellBicepsCurl => 'Bicep curl (bilanciere)';
	@override String get spiderCurls => 'Spider curl';
	@override String get singleArmCableHammerCurls => 'Hammer curl ai cavi (braccio singolo)';
	@override String get cableBicepsCurl => 'Bicep curl (cavi)';
	@override String get dumbbellBicepsCurl => 'Bicep curl (manubri)';
	@override String get bicepsCurlMachine => 'Bicep curl (macchina)';
	@override String get hammerCurlDumbbell => 'Hammer curl (manubri)';
	@override String get concentrationCurl => 'Curl concentrati';
	@override String get scottCurl => 'Scott curl';
	@override String get dualCableHighCurl => 'Curl ai cavi alti';
}

// Path: library.abs.exercises
class Translations$library$abs$exercises$it implements Translations$library$abs$exercises$en {
	Translations$library$abs$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get crunches => 'Crunch';
	@override String get kneeRaise => 'Sollevamento delle ginocchia';
	@override String get legRaise => 'Sollevamento delle gambe';
	@override String get crunchMachine => 'Crunch machine';
	@override String get heelsUpCrunch => 'Crunch (caviglie alzate)';
	@override String get fullBodyCrunch => 'Full-body crunch';
	@override String get plank => 'Plank';
	@override String get hollowBodyHold => 'Hollow body hold';
	@override String get russianTwist => 'Russian twist';
	@override String get bicycleCrunches => 'Bicycle crunch';
	@override String get extendedReverseCrunchWithLegExtension => 'Crunch inverso con leg extension';
	@override String get toeTouches => 'Toe touches';
	@override String get heelTouches => 'Heel touches';
	@override String get deadBugHoldCardio => 'Dead bug hold (a tempo)';
	@override String get deadBugHold => 'Dead bug hold';
	@override String get hollowBodyHoldBentKnees => 'Bent hollow hold';
	@override String get obliqueCrunches => 'Crunch obliqui';
	@override String get legRaiseParallelBars => 'Sollevamento delle gambe alle parallele';
	@override String get lateralHyperextensions => 'Iperestensioni laterali';
}

// Path: library.calves.exercises
class Translations$library$calves$exercises$it implements Translations$library$calves$exercises$en {
	Translations$library$calves$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get calfRaiseStanding => 'Calf raise (in piedi)';
	@override String get calfRaiseSeated => 'Calf raise (seduti)';
	@override String get calfPressLegPressMachine => 'Pressa dei polpacci (sulla Leg Press machine)';
}

// Path: library.quadriceps.exercises
class Translations$library$quadriceps$exercises$it implements Translations$library$quadriceps$exercises$en {
	Translations$library$quadriceps$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get squatsBarbell => 'Squat (bilanciere)';
	@override String get legPress => 'Leg press';
	@override String get legExtension => 'Leg extension';
	@override String get smithMachineLunges => 'Affondi al Multipower';
	@override String get lunges => 'Affondi';
	@override String get legPress45deg => 'Leg press (45°)';
	@override String get frontSquats => 'Squat frontali';
	@override String get bulgarianSplitSquats => 'Squat bulgari';
	@override String get bodyweightSquats => 'Squat';
	@override String get hackSquats => 'Hack squat';
}

// Path: library.hamstrings.exercises
class Translations$library$hamstrings$exercises$it implements Translations$library$hamstrings$exercises$en {
	Translations$library$hamstrings$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get legCurlProne => 'Leg curl (sdraiati)';
	@override String get legCurlSeated => 'Leg curl (seduti)';
	@override String get romanianDeadlift => 'Stacchi rumeni';
	@override String get romanianDeadliftDumbbell => 'Stacchi romeni (manubri)';
}

// Path: library.shoulders.exercises
class Translations$library$shoulders$exercises$it implements Translations$library$shoulders$exercises$en {
	Translations$library$shoulders$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get shoulderPressMachine => 'Shoulder press (macchina)';
	@override String get latRaisesInclinedBench => 'Alzate laterali (panca inclinata)';
	@override String get latRaisesCable => 'Alzate laterali ai cavi';
	@override String get latRaisesDualCable => 'Alzate laterali ai cavi (entrambe le braccia)';
	@override String get reverseFlysInclinedBench => 'Croci inverse (panca inclinata)';
	@override String get arnoldPress => 'Arnold press';
	@override String get frontDumbbellRaise => 'Sollevamento frontale dei manubri';
	@override String get uprightRow => 'Vogatore verticale';
	@override String get pikePushUps => 'Pike push-up';
	@override String get handstandPushUps => 'Flessioni in verticale';
	@override String get bentOverLateralRaises => 'Alzate laterali al cavo basso con busto a 90°';
	@override String get shoulderPress => 'Shoulder press';
	@override String get latRaisesDumbbells => 'Alzate laterali (manubri)';
	@override String get deltoidMachine => 'Deltoid machine';
	@override String get shrugsBarbell => 'Scrollate con bilanciere davanti';
	@override String get militaryPressSmithMachine => 'Lento avanti al multipower';
	@override String get reverseButterfly => 'Reverse butterfly machine';
	@override String get militaryPressBarbell => 'Lento avanti con bilanciere';
}

// Path: library.back.exercises
class Translations$library$back$exercises$it implements Translations$library$back$exercises$en {
	Translations$library$back$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get hyperExtensions => 'Iperestensioni';
	@override String get weightedHyperExtensions => 'Iperestensioni con peso';
	@override String get barbellRow => 'Rematore col bilanciere';
	@override String get triangleBarLatPulldowns => 'Lat machine (con triangolo)';
	@override String get underhandGripLatPulldowns => 'Lat machine (presa supina)';
	@override String get latPulldowns => 'Lat machine';
	@override String get cableSeatedRowTriangleBar => 'Rematore al cavo (con triangolo)';
	@override String get straightArmCablePushdown => 'Pulldown a braccia dritte';
	@override String get deadlift => 'Stacchi';
	@override String get pullUps => 'Pull-up';
	@override String get tBarRow => 'Rematore con bilanciere a T';
	@override String get rowMachine => 'Vogatore (macchinario)';
	@override String get latPulldownsNarrowGrip => 'Lat machine (presa stretta)';
	@override String get latPulldownsWideGrip => 'Lat machine (presa larga)';
	@override String get tBarRowWideProneGrip => 'Rematore T-Bar machine (presa larga prona)';
	@override String get dumbbellRow => 'Rematore con manubrio';
	@override String get chinUps => 'Chin up';
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
	@override String get dips => 'Dip';
	@override String get overheadRopeTricepExtension => 'Estensione dei tricipiti sopra la testa';
	@override String get tricepsRopePushdown => 'Pushdown dei tricipiti con corda';
	@override String get tricepKickbacks => 'Kickback per i tricipiti';
	@override String get skullCrushers => 'Skull Crushers';
	@override String get benchDips => 'Dip alla panca';
	@override String get diamondPushUps => 'Flessioni a diamante';
	@override String get tricepsMachine => 'Triceps machine';
	@override String get overheadTricepExtension => 'Estensione verticale dei tricipiti con manubri';
}

// Path: library.hips.exercises
class Translations$library$hips$exercises$it implements Translations$library$hips$exercises$en {
	Translations$library$hips$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get hipAdduction => 'Hip adduction';
}

// Path: library.forearms.exercises
class Translations$library$forearms$exercises$it implements Translations$library$forearms$exercises$en {
	Translations$library$forearms$exercises$it._(this._root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get wristCurlsBarbell => 'Curl dei polsi (bilanciere)';
	@override String get reverseWristCurlsBarbell => 'Curl dei polsi rovesciato (bilanciere)';
	@override String get wristCurlsDumbbell => 'Curl dei polsi (manubri)';
	@override String get reverseWristCurlsDumbbell => 'Curl dei polsi rovesciato (manubri)';
	@override String get wristRoller => 'Wrist roller';
	@override String get farmerWalk => 'Farmer Walk';
	@override String get platePinch => 'Plate pinch';
	@override String get reverseCurls => 'Reverse curl (bilanciere)';
	@override String get reverseCurlsDumbbell => 'Reverse curl (manubri)';
	@override String get cableSingleArmReverseCurl => 'Reverse curl a braccio singolo al cavo';
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
	@override String get gluteBridge => 'Ponte per i glutei';
	@override String get hipThrust => 'Hip thrust';
	@override String get hipAbduction => 'Hip abduction';
	@override String get clamshells => 'Clamshell per i glutei';
	@override String get hipThrustBarbell => 'Hip thrust (bilanciere)';
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
	@override String get serverError => 'Il server OpenFoodFacts non ha fornito una risposta. Riprova più tardi.';
	@override String get generic => 'Si è verificato un errore durante la comunicazione con il server OpenFoodFacts. Riprova più tardi.';
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
	@override String get label => 'Salva come';
	@override late final Translations$ongoingWorkout$finish$fields$parent$options$it options = Translations$ongoingWorkout$finish$fields$parent$options$it._(_root);
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
			'routines.quickWorkout.title' => 'Allenamento rapido',
			'routines.quickWorkout.subtitle' => 'Avvia rapidamente un allenamento vuoto',
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
			'ongoingWorkout.finish.fields.parent.label' => 'Salva come',
			'ongoingWorkout.finish.fields.parent.options.none' => 'Nessuna routine',
			'ongoingWorkout.finish.fields.duration.label' => 'Durata',
			'ongoingWorkout.finish.fields.duration.errors.empty' => 'La durata non dev\'essere zero.',
			'ongoingWorkout.finish.fields.infobox.label' => 'Note',
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
			'muscleGroups.hamstrings' => 'Posteriori della coscia',
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
			'library.cardio.exercises.aerobics' => 'Aerobica',
			'library.cardio.exercises.biking' => 'Bicicletta',
			'library.cardio.exercises.ergometer' => 'Ergometro',
			'library.cardio.exercises.ergometerHorizontal' => 'Ergometro (orizzontale)',
			'library.cardio.exercises.pilates' => 'Pilates',
			'library.cardio.exercises.running' => 'Corsa',
			'library.cardio.exercises.treadmill' => 'Tapis roulant',
			'library.cardio.exercises.zumba' => 'Zumba',
			'library.cardio.exercises.jumpRope' => 'Salto con la corda',
			'library.cardio.exercises.rowingMachine' => 'Remoergometro',
			'library.cardio.exercises.bicycleCrunchesCardio' => 'Bicycle crunch a tempo',
			'library.cardio.exercises.crunchesTimed' => 'Crunch a tempo',
			'library.chest.name' => 'Petto',
			'library.chest.exercises.barbellBenchPressFlat' => 'Panca piana (bilanciere)',
			'library.chest.exercises.barbellBenchPressIncline' => 'Panca inclinata (bilanciere, in avanti)',
			'library.chest.exercises.barbellBenchPressDecline' => 'Panca inclinata (bilanciere, all\'indietro)',
			'library.chest.exercises.dumbbellBenchPressFlat' => 'Panca piana (manubri)',
			'library.chest.exercises.dumbbellBenchPressIncline' => 'Panca inclinata (manubri, in avanti)',
			'library.chest.exercises.dumbbellBenchPressDecline' => 'Panca inclinata (manubri, all\'indietro)',
			'library.chest.exercises.smithMachineBenchPressFlat' => 'Panca piana (Multipower)',
			'library.chest.exercises.smithMachineBenchPressIncline' => 'Panca inclinata (Multipower, in avanti)',
			'library.chest.exercises.smithMachineBenchPressDecline' => 'Panca inclinata (Multipower, all\'indietro)',
			'library.chest.exercises.cableBenchPressFlat' => 'Panca piana (cavi)',
			'library.chest.exercises.cableBenchPressIncline' => 'Panca inclinata (cavi, in avanti)',
			'library.chest.exercises.cableBenchPressDecline' => 'Panca inclinata (cavi, all\'indietro)',
			'library.chest.exercises.butterflyMachine' => 'Butterfly machine',
			'library.chest.exercises.dumbbellHexPress' => 'Hex Press (manubri)',
			'library.chest.exercises.smithMachineHexPress' => 'Hex Press al Multipower',
			'library.chest.exercises.seatedCableChestFlys' => 'Croci ai cavi da seduto',
			'library.chest.exercises.verticalChestPress' => 'Chest press (verticale)',
			'library.chest.exercises.cableFlyCrossovers' => 'Croci ai cavi alti',
			'library.chest.exercises.pushUps' => 'Push-up',
			'library.chest.exercises.pushUpsWeighted' => 'Push-up (zavorrati)',
			'library.chest.exercises.cableChestPress' => 'Chest press ai cavi',
			'library.chest.exercises.declinePushUps' => 'Push-up declinati',
			'library.chest.exercises.lowCableFly' => 'Croci ai cavi bassi',
			'library.chest.exercises.inclinePushUps' => 'Push-up inclinati',
			'library.chest.exercises.tBarPress' => 'Pressa con bilanciere a T',
			'library.chest.exercises.inclineBenchFlys' => 'Croci su panca inclinata',
			'library.chest.exercises.benchFlys' => 'Croci su panca piana',
			'library.biceps.name' => 'Bicipiti',
			'library.biceps.exercises.barbellBicepsCurl' => 'Bicep curl (bilanciere)',
			'library.biceps.exercises.spiderCurls' => 'Spider curl',
			'library.biceps.exercises.singleArmCableHammerCurls' => 'Hammer curl ai cavi (braccio singolo)',
			'library.biceps.exercises.cableBicepsCurl' => 'Bicep curl (cavi)',
			'library.biceps.exercises.dumbbellBicepsCurl' => 'Bicep curl (manubri)',
			'library.biceps.exercises.bicepsCurlMachine' => 'Bicep curl (macchina)',
			'library.biceps.exercises.hammerCurlDumbbell' => 'Hammer curl (manubri)',
			'library.biceps.exercises.concentrationCurl' => 'Curl concentrati',
			'library.biceps.exercises.scottCurl' => 'Scott curl',
			'library.biceps.exercises.dualCableHighCurl' => 'Curl ai cavi alti',
			'library.abs.name' => 'Addominali',
			'library.abs.exercises.crunches' => 'Crunch',
			'library.abs.exercises.kneeRaise' => 'Sollevamento delle ginocchia',
			'library.abs.exercises.legRaise' => 'Sollevamento delle gambe',
			'library.abs.exercises.crunchMachine' => 'Crunch machine',
			'library.abs.exercises.heelsUpCrunch' => 'Crunch (caviglie alzate)',
			'library.abs.exercises.fullBodyCrunch' => 'Full-body crunch',
			'library.abs.exercises.plank' => 'Plank',
			'library.abs.exercises.hollowBodyHold' => 'Hollow body hold',
			'library.abs.exercises.russianTwist' => 'Russian twist',
			'library.abs.exercises.bicycleCrunches' => 'Bicycle crunch',
			'library.abs.exercises.extendedReverseCrunchWithLegExtension' => 'Crunch inverso con leg extension',
			'library.abs.exercises.toeTouches' => 'Toe touches',
			'library.abs.exercises.heelTouches' => 'Heel touches',
			'library.abs.exercises.deadBugHoldCardio' => 'Dead bug hold (a tempo)',
			'library.abs.exercises.deadBugHold' => 'Dead bug hold',
			'library.abs.exercises.hollowBodyHoldBentKnees' => 'Bent hollow hold',
			'library.abs.exercises.obliqueCrunches' => 'Crunch obliqui',
			'library.abs.exercises.legRaiseParallelBars' => 'Sollevamento delle gambe alle parallele',
			'library.abs.exercises.lateralHyperextensions' => 'Iperestensioni laterali',
			_ => null,
		} ?? switch (path) {
			'library.calves.name' => 'Polpacci',
			'library.calves.exercises.calfRaiseStanding' => 'Calf raise (in piedi)',
			'library.calves.exercises.calfRaiseSeated' => 'Calf raise (seduti)',
			'library.calves.exercises.calfPressLegPressMachine' => 'Pressa dei polpacci (sulla Leg Press machine)',
			'library.quadriceps.name' => 'Quadricipiti',
			'library.quadriceps.exercises.squatsBarbell' => 'Squat (bilanciere)',
			'library.quadriceps.exercises.legPress' => 'Leg press',
			'library.quadriceps.exercises.legExtension' => 'Leg extension',
			'library.quadriceps.exercises.smithMachineLunges' => 'Affondi al Multipower',
			'library.quadriceps.exercises.lunges' => 'Affondi',
			'library.quadriceps.exercises.legPress45deg' => 'Leg press (45°)',
			'library.quadriceps.exercises.frontSquats' => 'Squat frontali',
			'library.quadriceps.exercises.bulgarianSplitSquats' => 'Squat bulgari',
			'library.quadriceps.exercises.bodyweightSquats' => 'Squat',
			'library.quadriceps.exercises.hackSquats' => 'Hack squat',
			'library.hamstrings.name' => 'Posteriori della coscia',
			'library.hamstrings.exercises.legCurlProne' => 'Leg curl (sdraiati)',
			'library.hamstrings.exercises.legCurlSeated' => 'Leg curl (seduti)',
			'library.hamstrings.exercises.romanianDeadlift' => 'Stacchi rumeni',
			'library.hamstrings.exercises.romanianDeadliftDumbbell' => 'Stacchi romeni (manubri)',
			'library.shoulders.name' => 'Spalle',
			'library.shoulders.exercises.shoulderPressMachine' => 'Shoulder press (macchina)',
			'library.shoulders.exercises.latRaisesInclinedBench' => 'Alzate laterali (panca inclinata)',
			'library.shoulders.exercises.latRaisesCable' => 'Alzate laterali ai cavi',
			'library.shoulders.exercises.latRaisesDualCable' => 'Alzate laterali ai cavi (entrambe le braccia)',
			'library.shoulders.exercises.reverseFlysInclinedBench' => 'Croci inverse (panca inclinata)',
			'library.shoulders.exercises.arnoldPress' => 'Arnold press',
			'library.shoulders.exercises.frontDumbbellRaise' => 'Sollevamento frontale dei manubri',
			'library.shoulders.exercises.uprightRow' => 'Vogatore verticale',
			'library.shoulders.exercises.pikePushUps' => 'Pike push-up',
			'library.shoulders.exercises.handstandPushUps' => 'Flessioni in verticale',
			'library.shoulders.exercises.bentOverLateralRaises' => 'Alzate laterali al cavo basso con busto a 90°',
			'library.shoulders.exercises.shoulderPress' => 'Shoulder press',
			'library.shoulders.exercises.latRaisesDumbbells' => 'Alzate laterali (manubri)',
			'library.shoulders.exercises.deltoidMachine' => 'Deltoid machine',
			'library.shoulders.exercises.shrugsBarbell' => 'Scrollate con bilanciere davanti',
			'library.shoulders.exercises.militaryPressSmithMachine' => 'Lento avanti al multipower',
			'library.shoulders.exercises.reverseButterfly' => 'Reverse butterfly machine',
			'library.shoulders.exercises.militaryPressBarbell' => 'Lento avanti con bilanciere',
			'library.back.name' => 'Schiena',
			'library.back.exercises.hyperExtensions' => 'Iperestensioni',
			'library.back.exercises.weightedHyperExtensions' => 'Iperestensioni con peso',
			'library.back.exercises.barbellRow' => 'Rematore col bilanciere',
			'library.back.exercises.triangleBarLatPulldowns' => 'Lat machine (con triangolo)',
			'library.back.exercises.underhandGripLatPulldowns' => 'Lat machine (presa supina)',
			'library.back.exercises.latPulldowns' => 'Lat machine',
			'library.back.exercises.cableSeatedRowTriangleBar' => 'Rematore al cavo (con triangolo)',
			'library.back.exercises.straightArmCablePushdown' => 'Pulldown a braccia dritte',
			'library.back.exercises.deadlift' => 'Stacchi',
			'library.back.exercises.pullUps' => 'Pull-up',
			'library.back.exercises.tBarRow' => 'Rematore con bilanciere a T',
			'library.back.exercises.rowMachine' => 'Vogatore (macchinario)',
			'library.back.exercises.latPulldownsNarrowGrip' => 'Lat machine (presa stretta)',
			'library.back.exercises.latPulldownsWideGrip' => 'Lat machine (presa larga)',
			'library.back.exercises.tBarRowWideProneGrip' => 'Rematore T-Bar machine (presa larga prona)',
			'library.back.exercises.dumbbellRow' => 'Rematore con manubrio',
			'library.back.exercises.chinUps' => 'Chin up',
			'library.back.exercise.dualLowRowMachine' => 'Dual low row machine',
			'library.back.exercise.dualHighRowMachine' => 'Dual high row machine',
			'library.triceps.name' => 'Tricipiti',
			'library.triceps.exercises.dips' => 'Dip',
			'library.triceps.exercises.overheadRopeTricepExtension' => 'Estensione dei tricipiti sopra la testa',
			'library.triceps.exercises.tricepsRopePushdown' => 'Pushdown dei tricipiti con corda',
			'library.triceps.exercises.tricepKickbacks' => 'Kickback per i tricipiti',
			'library.triceps.exercises.skullCrushers' => 'Skull Crushers',
			'library.triceps.exercises.benchDips' => 'Dip alla panca',
			'library.triceps.exercises.diamondPushUps' => 'Flessioni a diamante',
			'library.triceps.exercises.tricepsMachine' => 'Triceps machine',
			'library.triceps.exercises.overheadTricepExtension' => 'Estensione verticale dei tricipiti con manubri',
			'library.custom.name' => 'Esercizi personalizzati',
			'library.newCustomExercise' => 'Nuovo esercizio',
			'library.hips.name' => 'Anche',
			'library.hips.exercises.hipAdduction' => 'Hip adduction',
			'library.forearms.name' => 'Avambracci',
			'library.forearms.exercises.wristCurlsBarbell' => 'Curl dei polsi (bilanciere)',
			'library.forearms.exercises.reverseWristCurlsBarbell' => 'Curl dei polsi rovesciato (bilanciere)',
			'library.forearms.exercises.wristCurlsDumbbell' => 'Curl dei polsi (manubri)',
			'library.forearms.exercises.reverseWristCurlsDumbbell' => 'Curl dei polsi rovesciato (manubri)',
			'library.forearms.exercises.wristRoller' => 'Wrist roller',
			'library.forearms.exercises.farmerWalk' => 'Farmer Walk',
			'library.forearms.exercises.platePinch' => 'Plate pinch',
			'library.forearms.exercises.reverseCurls' => 'Reverse curl (bilanciere)',
			'library.forearms.exercises.reverseCurlsDumbbell' => 'Reverse curl (manubri)',
			'library.forearms.exercises.cableSingleArmReverseCurl' => 'Reverse curl a braccio singolo al cavo',
			'library.obliques.exercises.sidewaysPlank' => 'Plank laterale',
			'library.obliques.exercises.sidewaysPlankReachThrough' => 'Plank laterale con rotazione',
			'library.other.name' => 'Altro',
			'library.other.exercises.stretching' => 'Stretching',
			'library.glutes.name' => 'Glutei',
			'library.glutes.exercises.gluteBridge' => 'Ponte per i glutei',
			'library.glutes.exercises.hipThrust' => 'Hip thrust',
			'library.glutes.exercises.hipAbduction' => 'Hip abduction',
			'library.glutes.exercises.clamshells' => 'Clamshell per i glutei',
			'library.glutes.exercises.hipThrustBarbell' => 'Hip thrust (bilanciere)',
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
			'food.home.calories' => 'Calorie',
			'food.home.carbs' => 'Carboidrati',
			'food.home.protein' => 'Proteine',
			'food.home.fat' => 'Grassi',
			'food.home.eaten' => 'Consumate',
			'food.home.remainingCal' => 'Rimanenti',
			'food.home.goal' => 'Obiettivo',
			'food.home.overCal' => 'Superate',
			'food.searchBar.hint' => 'Cerca cronologia o OpenFoodFacts…',
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
			'food.search.error.serverError' => 'Il server OpenFoodFacts non ha fornito una risposta. Riprova più tardi.',
			'food.search.error.generic' => 'Si è verificato un errore durante la comunicazione con il server OpenFoodFacts. Riprova più tardi.',
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
			_ => null,
		} ?? switch (path) {
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
			'login.fields.email.label' => 'Email',
			'login.fields.email.hint' => 'mario.rossi@example.com',
			'login.fields.password.label' => 'Password',
			'login.fields.password.hint' => 'Password',
			'login.fields.username.label' => 'Username',
			'login.fields.username.hint' => 'Username',
			'login.buttons.signIn' => 'Accedi',
			'login.buttons.signUp' => 'Registrati',
			'login.upsell.title' => 'Accesso non effettuato',
			'login.upsell.subtitle' => 'Accedi per usufruire di allenamenti di gruppo, sincronizzazione su più dispositivi e tanto altro.',
			'login.verifyEmail.title' => 'Ti abbiamo inviato un\'email di verifica',
			'login.verifyEmail.done' => 'Ho verificato la mia email',
			'login.verifyEmail.description' => 'Controlla la tua casella di posta elettronica per confermare la tua email. Dopodiché tocca il pulsante sottostante per accedere.',
			'login.verifyEmail.notVerified' => 'Verifica il tuo indirizzo email e riprova.',
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
			_ => null,
		} ?? switch (path) {
			'bodyMeasurement.leftCalf.label' => 'Polpaccio sinistro',
			'bodyMeasurement.rightCalf.label' => 'Polpaccio destro',
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
			'feed.startWorkout' => 'Inizia un allenamento',
			'feed.workout.title.you' => 'Tu',
			'feed.workout.title.unknown' => 'Utente Sconosciuto',
			'feed.workout.subtitle.you' => 'hai completato un allenamento',
			'feed.workout.subtitle.friend' => 'ha completato un allenamento',
			'feed.achievement.title.you' => 'Tu',
			'feed.achievement.subtitle.you' => 'hai sbloccato un traguardo',
			'feed.achievement.subtitle.friend' => 'ha sbloccato un traguardo',
			'feed.userButton.loading' => 'Caricamento profilo utente in corso...',
			'feed.noSync.text' => 'La sincronizzazione è in pausa: non sei connesso a Internet. Potrebbero volerci alcuni minuti. Non preoccuparti, i dati verranno mantenuti in locale e trasferiti in un secondo momento.',
			'feed.noMoreData' => 'Hai raggiunto la fine del feed :)',
			'feed.loadMore' => 'Carica altro',
			'workoutPage.title' => 'Allenati',
			'pro.title' => 'PRO',
			'userProfile.title' => 'Profilo',
			'userProfile.addFriend' => 'Aggiungi amico',
			'userProfile.unfriend' => 'Rimuovi amico',
			'userProfile.requestSent' => 'Richiesta inviata',
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
			_ => null,
		};
	}
}
