///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'Gym Bro'
	String get appName => 'Gym Bro';

	late final Translations$navigation$en navigation = Translations$navigation$en._(_root);
	late final Translations$appInfo$en appInfo = Translations$appInfo$en._(_root);
	late final Translations$set$en set = Translations$set$en._(_root);
	late final Translations$exercise$en exercise = Translations$exercise$en._(_root);
	late final Translations$workouts$en workouts = Translations$workouts$en._(_root);
	late final Translations$routines$en routines = Translations$routines$en._(_root);
	late final Translations$history$en history = Translations$history$en._(_root);
	late final Translations$settings$en settings = Translations$settings$en._(_root);
	late final Translations$ongoingWorkout$en ongoingWorkout = Translations$ongoingWorkout$en._(_root);
	late final Translations$timer$en timer = Translations$timer$en._(_root);
	late final Translations$exerciseList$en exerciseList = Translations$exerciseList$en._(_root);
	late final Translations$general$en general = Translations$general$en._(_root);
	Map<String, String> get muscleGroups => {
		'abductors': 'Abductors',
		'abs': 'Abs',
		'adductors': 'Adductors',
		'biceps': 'Biceps',
		'calves': 'Calves',
		'chest': 'Chest',
		'forearm': 'Forearm',
		'glutes': 'Glutes',
		'hamstrings': 'Hamstrings',
		'lats': 'Lats',
		'lowerBack': 'Lower back',
		'none': 'None',
		'other': 'Other',
		'quadriceps': 'Quadriceps',
		'shoulders': 'Shoulders',
		'traps': 'Traps',
		'triceps': 'Triceps',
		'upperBack': 'Upper back',
		'thighs': 'Thighs',
		'forearms': 'Forearms',
		'hands': 'Hands',
		'obliques': 'Obliques',
		'tibialis': 'Tibialis',
	};
	Map<String, String> get muscleCategories => {
		'arms': 'Arms',
		'back': 'Back',
		'chest': 'Chest',
		'core': 'Core',
		'legs': 'Legs',
		'shoulders': 'Shoulders',
	};
	late final Translations$titleGenerator$en titleGenerator = Translations$titleGenerator$en._(_root);
	late final Translations$actions$en actions = Translations$actions$en._(_root);
	Map<String, String> get units => {
		'kg': 'kg',
		'lb': 'lbs',
		'km': 'km',
		'mi': 'mi',
	};
	late final Translations$time$en time = Translations$time$en._(_root);
	Map<String, String> get locales => {
		'en': 'English',
		'it': 'Italian',
	};
	Map<String, String> get weightUnits => {
		'kg': 'Kilograms',
		'lb': 'Pounds',
	};
	Map<String, String> get distanceUnits => {
		'km': 'Kilometers',
		'mi': 'Miles',
	};
	Map<String, String> get barbells => {
		'normal': 'Normal',
		'short': 'Short',
		'ezBar': 'EZ bar',
		'none': 'No bar',
	};
	late final Translations$weightCalculator$en weightCalculator = Translations$weightCalculator$en._(_root);
	late final Translations$androidNotificationChannel$en androidNotificationChannel = Translations$androidNotificationChannel$en._(_root);
	late final Translations$library$en library = Translations$library$en._(_root);
	late final Translations$infobox$en infobox = Translations$infobox$en._(_root);

	/// en: '(zero) {Superset without exercises} (one) {Superset with $n exercise} (two) {Superset with $n exercises} (few) {Superset with $n exercises} (many) {Superset with $n exercises} (other) {Superset with $n exercises}'
	String superset({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'Superset without exercises',
		one: 'Superset with ${n} exercise',
		two: 'Superset with ${n} exercises',
		few: 'Superset with ${n} exercises',
		many: 'Superset with ${n} exercises',
		other: 'Superset with ${n} exercises',
	);

	late final Translations$historyEditor$en historyEditor = Translations$historyEditor$en._(_root);
	late final Translations$importRoutine$en importRoutine = Translations$importRoutine$en._(_root);
	late final Translations$unknownUrl$en unknownUrl = Translations$unknownUrl$en._(_root);
	late final Translations$me$en me = Translations$me$en._(_root);
	late final Translations$richText$en richText = Translations$richText$en._(_root);
	late final Translations$errorView$en errorView = Translations$errorView$en._(_root);
	late final Translations$timeSeriesChart$en timeSeriesChart = Translations$timeSeriesChart$en._(_root);
	late final Translations$androidRequestExactAlarmsPermission$en androidRequestExactAlarmsPermission = Translations$androidRequestExactAlarmsPermission$en._(_root);
	late final Translations$routineFormPicker$en routineFormPicker = Translations$routineFormPicker$en._(_root);
	late final Translations$cardioTimer$en cardioTimer = Translations$cardioTimer$en._(_root);
	late final Translations$migrations$en migrations = Translations$migrations$en._(_root);
	late final Translations$exerciseFormPicker$en exerciseFormPicker = Translations$exerciseFormPicker$en._(_root);
	late final Translations$exercises$en exercises = Translations$exercises$en._(_root);
	late final Translations$food$en food = Translations$food$en._(_root);
	late final Translations$equipment$en equipment = Translations$equipment$en._(_root);
	late final Translations$achievements$en achievements = Translations$achievements$en._(_root);
	late final Translations$workoutGenerator$en workoutGenerator = Translations$workoutGenerator$en._(_root);
	late final Translations$boutique$en boutique = Translations$boutique$en._(_root);
	late final Translations$login$en login = Translations$login$en._(_root);
	late final Translations$sync$en sync = Translations$sync$en._(_root);
	Map<String, dynamic> get bodyMeasurement => {
		'neck': Translations$bodyMeasurement$neck$en._(_root),
		'waist': Translations$bodyMeasurement$waist$en._(_root),
		'bodyFat': Translations$bodyMeasurement$bodyFat$en._(_root),
		'shoulder': Translations$bodyMeasurement$shoulder$en._(_root),
		'chest': Translations$bodyMeasurement$chest$en._(_root),
		'leftBicep': Translations$bodyMeasurement$leftBicep$en._(_root),
		'rightBicep': Translations$bodyMeasurement$rightBicep$en._(_root),
		'leftForearm': Translations$bodyMeasurement$leftForearm$en._(_root),
		'rightForearm': Translations$bodyMeasurement$rightForearm$en._(_root),
		'abdomen': Translations$bodyMeasurement$abdomen$en._(_root),
		'hips': Translations$bodyMeasurement$hips$en._(_root),
		'leftThigh': Translations$bodyMeasurement$leftThigh$en._(_root),
		'rightThigh': Translations$bodyMeasurement$rightThigh$en._(_root),
		'leftCalf': Translations$bodyMeasurement$leftCalf$en._(_root),
		'rightCalf': Translations$bodyMeasurement$rightCalf$en._(_root),
	};
	late final Translations$onboarding$en onboarding = Translations$onboarding$en._(_root);
	Map<String, dynamic> get nags => {
		'routines': Translations$nags$routines$en._(_root),
		'button': 'Join now!',
		'library': Translations$nags$library$en._(_root),
		'history': Translations$nags$history$en._(_root),
		'food': Translations$nags$food$en._(_root),
	};
	late final Translations$feed$en feed = Translations$feed$en._(_root);
	late final Translations$workoutPage$en workoutPage = Translations$workoutPage$en._(_root);
	late final Translations$pro$en pro = Translations$pro$en._(_root);
	late final Translations$userProfile$en userProfile = Translations$userProfile$en._(_root);
	late final Translations$friendRequests$en friendRequests = Translations$friendRequests$en._(_root);
	late final Translations$profileSearch$en profileSearch = Translations$profileSearch$en._(_root);

	/// en: 'You'
	String get you => 'You';

	late final Translations$error$en error = Translations$error$en._(_root);
	late final Translations$legacyWorkoutRecovery$en legacyWorkoutRecovery = Translations$legacyWorkoutRecovery$en._(_root);
	late final Translations$friendsList$en friendsList = Translations$friendsList$en._(_root);
	late final Translations$social$en social = Translations$social$en._(_root);
	late final Translations$hydration$en hydration = Translations$hydration$en._(_root);
	late final Translations$reports$en reports = Translations$reports$en._(_root);
	late final Translations$plateau$en plateau = Translations$plateau$en._(_root);
	late final Translations$progression$en progression = Translations$progression$en._(_root);
	late final Translations$paywall$en paywall = Translations$paywall$en._(_root);
	late final Translations$routineImport$en routineImport = Translations$routineImport$en._(_root);
}

// Path: navigation
class Translations$navigation$en {
	Translations$navigation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Feed'
	String get feed => 'Feed';

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Food'
	String get food => 'Food';

	/// en: 'Train'
	String get workouts => 'Train';

	/// en: 'PRO'
	String get pro => 'PRO';

	/// en: 'Settings'
	String get settings => 'Settings';
}

// Path: appInfo
class Translations$appInfo$en {
	Translations$appInfo$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Version $version (build $build)'
	String version({required Object version, required Object build}) => 'Version ${version} (build ${build})';

	/// en: 'Workout Buddy'
	String get shortDescription => 'Workout Buddy';

	/// en: 'Terms of service'
	String get terms => 'Terms of service';

	/// en: 'Privacy policy'
	String get privacy => 'Privacy policy';
}

// Path: set
class Translations$set$en {
	Translations$set$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Set kind'
	String get kind => 'Set kind';

	late final Translations$set$kindShort$en kindShort = Translations$set$kindShort$en._(_root);
	Map<String, String> get kindLong => {
		'normal': 'Normal set',
		'warmUp': 'Warm-up set',
		'drop': 'Drop set',
		'failure': 'To failure',
		'failureStripping': 'To failure, with stripping',
	};
	late final Translations$set$kinds$en kinds = Translations$set$kinds$en._(_root);
}

// Path: exercise
class Translations$exercise$en {
	Translations$exercise$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exercise$chart$en chart = Translations$exercise$chart$en._(_root);
	late final Translations$exercise$fields$en fields = Translations$exercise$fields$en._(_root);
	late final Translations$exercise$actions$en actions = Translations$exercise$actions$en._(_root);
	late final Translations$exercise$editor$en editor = Translations$exercise$editor$en._(_root);
	late final Translations$exercise$picker$en picker = Translations$exercise$picker$en._(_root);

	/// en: 'Custom'
	String get custom => 'Custom';

	late final Translations$exercise$info$en info = Translations$exercise$info$en._(_root);
	late final Translations$exercise$continuation$en continuation = Translations$exercise$continuation$en._(_root);
	late final Translations$exercise$delete$en delete = Translations$exercise$delete$en._(_root);
}

// Path: workouts
class Translations$workouts$en {
	Translations$workouts$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Untitled workout'
	String get untitled => 'Untitled workout';

	/// en: 'Workouts'
	String get title => 'Workouts';

	late final Translations$workouts$actions$en actions = Translations$workouts$actions$en._(_root);
}

// Path: routines
class Translations$routines$en {
	Translations$routines$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Routines'
	String get title => 'Routines';

	/// en: 'New routine'
	String get newRoutine => 'New routine';

	late final Translations$routines$quickWorkout$en quickWorkout = Translations$routines$quickWorkout$en._(_root);
	late final Translations$routines$actions$en actions = Translations$routines$actions$en._(_root);
	late final Translations$routines$editor$en editor = Translations$routines$editor$en._(_root);

	/// en: 'New folder'
	String get newFolder => 'New folder';

	/// en: 'The name must not be empty.'
	String get folderNameEmpty => 'The name must not be empty.';

	/// en: 'Name'
	String get folderName => 'Name';

	/// en: 'Edit folder'
	String get editFolder => 'Edit folder';

	/// en: 'Drop here'
	String get dropHere => 'Drop here';

	/// en: 'Drop the routine here to move it to the home screen'
	String get moveToRoot => 'Drop the routine here to move it to the home screen';

	/// en: 'No routine'
	String get none => 'No routine';

	/// en: 'Select a routine'
	String get pick => 'Select a routine';

	/// en: 'Home'
	String get rootFolder => 'Home';

	/// en: 'This folder is empty'
	String get emptyFolder => 'This folder is empty';

	/// en: 'Press and hold a routine from the Home page to add it to this folder.'
	String get emptyFolderSubtitle => 'Press and hold a routine from the Home page to add it to this folder.';

	/// en: 'Folder'
	String get folder => 'Folder';

	/// en: 'You've deleted this folder'
	String get nullFolder => 'You\'ve deleted this folder';

	/// en: 'You can go back to the Home page.'
	String get nullFolderSubtitle => 'You can go back to the Home page.';

	/// en: 'Notes'
	String get folderNotes => 'Notes';

	late final Translations$routines$loadError$en loadError = Translations$routines$loadError$en._(_root);
}

// Path: history
class Translations$history$en {
	Translations$history$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'History'
	String get title => 'History';

	/// en: 'No history'
	String get empty => 'No history';

	/// en: '(one) {…and one more exercise} (two) {…and $n more exercises} (few) {…and $n more exercises} (many) {…and $n more exercises} (other) {…and $n more exercises}'
	String andMore({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '…and one more exercise',
		two: '…and ${n} more exercises',
		few: '…and ${n} more exercises',
		many: '…and ${n} more exercises',
		other: '…and ${n} more exercises',
	);

	late final Translations$history$actions$en actions = Translations$history$actions$en._(_root);

	/// en: 'Show all data'
	String get showAll => 'Show all data';

	/// en: 'Search workouts'
	String get search => 'Search workouts';
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$diagnostics$en diagnostics = Translations$settings$diagnostics$en._(_root);

	/// en: 'Settings'
	String get title => 'Settings';

	late final Translations$settings$options$en options = Translations$settings$options$en._(_root);
	late final Translations$settings$colorPicker$en colorPicker = Translations$settings$colorPicker$en._(_root);
	late final Translations$settings$advanced$en advanced = Translations$settings$advanced$en._(_root);
	late final Translations$settings$panes$en panes = Translations$settings$panes$en._(_root);
	late final Translations$settings$permissions$en permissions = Translations$settings$permissions$en._(_root);
	late final Translations$settings$pro$en pro = Translations$settings$pro$en._(_root);

	/// en: 'Sign out'
	String get logout => 'Sign out';

	late final Translations$settings$logoutWarning$en logoutWarning = Translations$settings$logoutWarning$en._(_root);
}

// Path: ongoingWorkout
class Translations$ongoingWorkout$en {
	Translations$ongoingWorkout$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Workout'
	String get title => 'Workout';

	late final Translations$ongoingWorkout$actions$en actions = Translations$ongoingWorkout$actions$en._(_root);
	late final Translations$ongoingWorkout$exercises$en exercises = Translations$ongoingWorkout$exercises$en._(_root);
	late final Translations$ongoingWorkout$info$en info = Translations$ongoingWorkout$info$en._(_root);
	late final Translations$ongoingWorkout$finish$en finish = Translations$ongoingWorkout$finish$en._(_root);
	late final Translations$ongoingWorkout$cancel$en cancel = Translations$ongoingWorkout$cancel$en._(_root);
	late final Translations$ongoingWorkout$overwrite$en overwrite = Translations$ongoingWorkout$overwrite$en._(_root);

	/// en: 'Rest time is over!'
	String get restOver => 'Rest time is over!';

	/// en: 'Weight calculator'
	String get weightCalculator => 'Weight calculator';

	late final Translations$ongoingWorkout$superset$en superset = Translations$ongoingWorkout$superset$en._(_root);
	late final Translations$ongoingWorkout$stopwatch$en stopwatch = Translations$ongoingWorkout$stopwatch$en._(_root);
	late final Translations$ongoingWorkout$simple$en simple = Translations$ongoingWorkout$simple$en._(_root);
	late final Translations$ongoingWorkout$toolbox$en toolbox = Translations$ongoingWorkout$toolbox$en._(_root);
	late final Translations$ongoingWorkout$updateRoutine$en updateRoutine = Translations$ongoingWorkout$updateRoutine$en._(_root);
	late final Translations$ongoingWorkout$goodJob$en goodJob = Translations$ongoingWorkout$goodJob$en._(_root);
	late final Translations$ongoingWorkout$exercisesToSuperset$en exercisesToSuperset = Translations$ongoingWorkout$exercisesToSuperset$en._(_root);
}

// Path: timer
class Translations$timer$en {
	Translations$timer$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '+15s'
	String get add15s => '+15s';

	/// en: '-15s'
	String get subtract15s => '-15s';

	/// en: 'Skip'
	String get skip => 'Skip';
}

// Path: exerciseList
class Translations$exerciseList$en {
	Translations$exerciseList$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Rest time: '
	String get restTime => 'Rest time: ';

	late final Translations$exerciseList$fields$en fields = Translations$exerciseList$fields$en._(_root);
	late final Translations$exerciseList$stats$en stats = Translations$exerciseList$stats$en._(_root);
	late final Translations$exerciseList$workoutMuscleCategoriesBarChart$en workoutMuscleCategoriesBarChart = Translations$exerciseList$workoutMuscleCategoriesBarChart$en._(_root);
	late final Translations$exerciseList$workoutWeightDistributionBarChart$en workoutWeightDistributionBarChart = Translations$exerciseList$workoutWeightDistributionBarChart$en._(_root);
	late final Translations$exerciseList$workoutEquipmentDistributionBarChart$en workoutEquipmentDistributionBarChart = Translations$exerciseList$workoutEquipmentDistributionBarChart$en._(_root);
}

// Path: general
class Translations$general$en {
	Translations$general$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$general$dialogs$en dialogs = Translations$general$dialogs$en._(_root);

	/// en: '(zero) {No exercises} (one) {$n exercise} (two) {$n exercises} (few) {$n exercises} (many) {$n exercises} (other) {$n exercises}'
	String exercises({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'No exercises',
		one: '${n} exercise',
		two: '${n} exercises',
		few: '${n} exercises',
		many: '${n} exercises',
		other: '${n} exercises',
	);

	/// en: 'Total time: $time'
	String totalTime({required Object time}) => 'Total time: ${time}';

	/// en: '(zero) {Nothing selected} (one) {1 selected} (two) {$n selected} (few) {$n selected} (many) {$n selected} (other) {$n selected}'
	String selected({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'Nothing selected',
		one: '1 selected',
		two: '${n} selected',
		few: '${n} selected',
		many: '${n} selected',
		other: '${n} selected',
	);

	/// en: '(zero) {No workouts} (one) {$n workout} (two) {$n workouts} (few) {$n workouts} (many) {$n workouts} (other) {$n workouts}'
	String workouts({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'No workouts',
		one: '${n} workout',
		two: '${n} workouts',
		few: '${n} workouts',
		many: '${n} workouts',
		other: '${n} workouts',
	);

	/// en: '(zero) {No routines} (one) {$n routine} (two) {$n routines} (few) {$n routines} (many) {$n routines} (other) {$n routines}'
	String routines({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'No routines',
		one: '${n} routine',
		two: '${n} routines',
		few: '${n} routines',
		many: '${n} routines',
		other: '${n} routines',
	);

	/// en: '(optional)'
	String get optional => '(optional)';

	/// en: 'Unnamed'
	String get unnamed => 'Unnamed';
}

// Path: titleGenerator
class Translations$titleGenerator$en {
	Translations$titleGenerator$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '$muscles Workout'
	String template({required Object muscles}) => '${muscles} Workout';

	late final Translations$titleGenerator$title$en title = Translations$titleGenerator$title$en._(_root);
}

// Path: actions
class Translations$actions$en {
	Translations$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Remove'
	String get remove => 'Remove';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Undo'
	String get undo => 'Undo';

	/// en: 'Save'
	String get save => 'Save';
}

// Path: time
class Translations$time$en {
	Translations$time$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '(zero) {$minutes:$seconds} (one) {$hours hour, $minutes:$seconds} (two) {$hours hours, $minutes:$seconds} (few) {$hours hours, $minutes:$seconds} (many) {$hours hours, $minutes:$seconds} (other) {$hours hours, $minutes:$seconds}'
	String hours({required num n, required Object minutes, required Object seconds, required Object hours}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: '${minutes}:${seconds}',
		one: '${hours} hour, ${minutes}:${seconds}',
		two: '${hours} hours, ${minutes}:${seconds}',
		few: '${hours} hours, ${minutes}:${seconds}',
		many: '${hours} hours, ${minutes}:${seconds}',
		other: '${hours} hours, ${minutes}:${seconds}',
	);

	/// en: '(zero) {$n} (one) {$n hour} (two) {$n hours} (few) {$n hours} (many) {$n hours} (other) {$n hours}'
	String justHours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: '${n}',
		one: '${n} hour',
		two: '${n} hours',
		few: '${n} hours',
		many: '${n} hours',
		other: '${n} hours',
	);

	/// en: '(zero) {0 days} (one) {1 day} (two) {2 days} (few) {$n days} (many) {$n days} (other) {$n days}'
	String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: '0 days',
		one: '1 day',
		two: '2 days',
		few: '${n} days',
		many: '${n} days',
		other: '${n} days',
	);

	/// en: '(zero) {0 weeks} (one) {1 week} (two) {2 weeks} (few) {$n weeks} (many) {$n weeks} (other) {$n weeks}'
	String weeks({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: '0 weeks',
		one: '1 week',
		two: '2 weeks',
		few: '${n} weeks',
		many: '${n} weeks',
		other: '${n} weeks',
	);
}

// Path: weightCalculator
class Translations$weightCalculator$en {
	Translations$weightCalculator$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$weightCalculator$weight$en weight = Translations$weightCalculator$weight$en._(_root);
	late final Translations$weightCalculator$weights$en weights = Translations$weightCalculator$weights$en._(_root);
	late final Translations$weightCalculator$barbells$en barbells = Translations$weightCalculator$barbells$en._(_root);

	/// en: 'Insert weight'
	String get insert => 'Insert weight';
}

// Path: androidNotificationChannel
class Translations$androidNotificationChannel$en {
	Translations$androidNotificationChannel$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Rest timeout'
	String get name => 'Rest timeout';

	/// en: 'Sends a notification whenever a running rest timer runs out of time.'
	String get description => 'Sends a notification whenever a running rest timer runs out of time.';
}

// Path: library
class Translations$library$en {
	Translations$library$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Library'
	String get title => 'Library';

	late final Translations$library$cardio$en cardio = Translations$library$cardio$en._(_root);
	late final Translations$library$chest$en chest = Translations$library$chest$en._(_root);
	late final Translations$library$biceps$en biceps = Translations$library$biceps$en._(_root);
	late final Translations$library$abs$en abs = Translations$library$abs$en._(_root);
	late final Translations$library$calves$en calves = Translations$library$calves$en._(_root);
	late final Translations$library$quadriceps$en quadriceps = Translations$library$quadriceps$en._(_root);
	late final Translations$library$hamstrings$en hamstrings = Translations$library$hamstrings$en._(_root);
	late final Translations$library$shoulders$en shoulders = Translations$library$shoulders$en._(_root);
	late final Translations$library$back$en back = Translations$library$back$en._(_root);
	late final Translations$library$triceps$en triceps = Translations$library$triceps$en._(_root);

	/// en: 'New exercise'
	String get newCustomExercise => 'New exercise';

	late final Translations$library$custom$en custom = Translations$library$custom$en._(_root);
	late final Translations$library$hips$en hips = Translations$library$hips$en._(_root);
	late final Translations$library$forearms$en forearms = Translations$library$forearms$en._(_root);
	late final Translations$library$obliques$en obliques = Translations$library$obliques$en._(_root);
	late final Translations$library$other$en other = Translations$library$other$en._(_root);
	late final Translations$library$glutes$en glutes = Translations$library$glutes$en._(_root);
}

// Path: infobox
class Translations$infobox$en {
	Translations$infobox$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notes'
	String get label => 'Notes';
}

// Path: historyEditor
class Translations$historyEditor$en {
	Translations$historyEditor$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit: $name'
	String title({required Object name}) => 'Edit: ${name}';

	late final Translations$historyEditor$exercises$en exercises = Translations$historyEditor$exercises$en._(_root);
	late final Translations$historyEditor$info$en info = Translations$historyEditor$info$en._(_root);
	late final Translations$historyEditor$actions$en actions = Translations$historyEditor$actions$en._(_root);
	late final Translations$historyEditor$finish$en finish = Translations$historyEditor$finish$en._(_root);
}

// Path: importRoutine
class Translations$importRoutine$en {
	Translations$importRoutine$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Import routine'
	String get title => 'Import routine';

	late final Translations$importRoutine$errors$en errors = Translations$importRoutine$errors$en._(_root);
	late final Translations$importRoutine$import$en import = Translations$importRoutine$import$en._(_root);
}

// Path: unknownUrl
class Translations$unknownUrl$en {
	Translations$unknownUrl$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unknown URL'
	String get title => 'Unknown URL';

	/// en: 'You followed a URL that doesn't lead anywhere.'
	String get text => 'You followed a URL that doesn\'t lead anywhere.';
}

// Path: me
class Translations$me$en {
	Translations$me$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	late final Translations$me$weight$en weight = Translations$me$weight$en._(_root);
	late final Translations$me$addWeight$en addWeight = Translations$me$addWeight$en._(_root);
	late final Translations$me$allData$en allData = Translations$me$allData$en._(_root);
	late final Translations$me$calendar$en calendar = Translations$me$calendar$en._(_root);
	late final Translations$me$stats$en stats = Translations$me$stats$en._(_root);
	late final Translations$me$workoutDistribution$en workoutDistribution = Translations$me$workoutDistribution$en._(_root);
	late final Translations$me$profile$en profile = Translations$me$profile$en._(_root);
	late final Translations$me$sync$en sync = Translations$me$sync$en._(_root);

	/// en: 'Body measurements'
	String get bodyMeasurements => 'Body measurements';

	late final Translations$me$trainer$en trainer = Translations$me$trainer$en._(_root);
}

// Path: richText
class Translations$richText$en {
	Translations$richText$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Highlight'
	String get highlight => 'Highlight';
}

// Path: errorView
class Translations$errorView$en {
	Translations$errorView$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error'
	String get shortTitle => 'Error';

	/// en: 'Oh snap!'
	String get title => 'Oh snap!';

	/// en: 'An unexpected error occurred.'
	String get subtitle => 'An unexpected error occurred.';

	/// en: 'You can try the following: • Restart the app • Check if you are using the latest version • Contact support'
	String get body => 'You can try the following:\n\n • Restart the app\n • Check if you are using the latest version\n • Contact support';

	/// en: 'If the error persists, please provide the following information to the support team:'
	String get stack => 'If the error persists, please provide the following information to the support team:';

	/// en: 'No stack trace available.'
	String get noStack => 'No stack trace available.';
}

// Path: timeSeriesChart
class Translations$timeSeriesChart$en {
	Translations$timeSeriesChart$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select interval'
	String get selectInterval => 'Select interval';

	Map<String, String> get interval => {
		'threeMonths': '3 months',
		'sixMonths': '6 months',
		'oneYear': '1 year',
	};
	late final Translations$timeSeriesChart$noData$en noData = Translations$timeSeriesChart$noData$en._(_root);
}

// Path: androidRequestExactAlarmsPermission
class Translations$androidRequestExactAlarmsPermission$en {
	Translations$androidRequestExactAlarmsPermission$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notification permission'
	String get title => 'Notification permission';

	/// en: 'This app requires a special "Exact alarms" permission on versions of Android greater than or equal to 14. You can deny it, but features such as rest timer notifications won't work. Would you like to grant this permission?'
	String get message => 'This app requires a special "Exact alarms" permission on versions of Android greater than or equal to 14. You can deny it, but features such as rest timer notifications won\'t work. Would you like to grant this permission?';
}

// Path: routineFormPicker
class Translations$routineFormPicker$en {
	Translations$routineFormPicker$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$routineFormPicker$fields$en fields = Translations$routineFormPicker$fields$en._(_root);
}

// Path: cardioTimer
class Translations$cardioTimer$en {
	Translations$cardioTimer$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Interval timer'
	String get name => 'Interval timer';

	late final Translations$cardioTimer$setUp$en setUp = Translations$cardioTimer$setUp$en._(_root);
	late final Translations$cardioTimer$confirmExit$en confirmExit = Translations$cardioTimer$confirmExit$en._(_root);
}

// Path: migrations
class Translations$migrations$en {
	Translations$migrations$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$customToLibraryExercise$en customToLibraryExercise = Translations$migrations$customToLibraryExercise$en._(_root);
	late final Translations$migrations$common$en common = Translations$migrations$common$en._(_root);

	/// en: 'Migrations'
	String get title => 'Migrations';

	late final Translations$migrations$removeUnusedExercises$en removeUnusedExercises = Translations$migrations$removeUnusedExercises$en._(_root);
	late final Translations$migrations$removeWeightFromCustomExercise$en removeWeightFromCustomExercise = Translations$migrations$removeWeightFromCustomExercise$en._(_root);
	late final Translations$migrations$genericMultiplyWeight$en genericMultiplyWeight = Translations$migrations$genericMultiplyWeight$en._(_root);
	late final Translations$migrations$doubleExerciseWeight$en doubleExerciseWeight = Translations$migrations$doubleExerciseWeight$en._(_root);
	late final Translations$migrations$halveExerciseWeight$en halveExerciseWeight = Translations$migrations$halveExerciseWeight$en._(_root);
}

// Path: exerciseFormPicker
class Translations$exerciseFormPicker$en {
	Translations$exerciseFormPicker$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exerciseFormPicker$fields$en fields = Translations$exerciseFormPicker$fields$en._(_root);
}

// Path: exercises
class Translations$exercises$en {
	Translations$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exercises$none$en none = Translations$exercises$none$en._(_root);
}

// Path: food
class Translations$food$en {
	Translations$food$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Food tracking'
	String get title => 'Food tracking';

	late final Translations$food$home$en home = Translations$food$home$en._(_root);
	late final Translations$food$searchBar$en searchBar = Translations$food$searchBar$en._(_root);
	Map<String, String> get nutriments => {
		'calories': 'Calories',
		'fat': 'Fat',
		'saturatedFat': 'Saturated Fats',
		'carbs': 'Carbs',
		'sugar': 'Sugar',
		'protein': 'Protein',
		'salt': 'Salt',
		'sodium': 'Sodium',
		'fiber': 'Fibers',
		'addedSugars': 'Added Sugars',
		'proteins': 'Proteins',
		'caffeine': 'Caffeine',
		'calcium': 'Calcium',
		'iron': 'Iron',
		'vitaminC': 'Vitamin C',
		'magnesium': 'Magnesium',
		'phosphorus': 'Phosphorus',
		'potassium': 'Potassium',
		'zinc': 'Zinc',
		'copper': 'Copper',
		'selenium': 'Selenium',
		'vitaminA': 'Vitamin A',
		'vitaminE': 'Vitamin E',
		'vitaminD': 'Vitamin D',
		'vitaminB1': 'Vitamin B1',
		'vitaminB2': 'Vitamin B2',
		'vitaminPP': 'Vitamin PP',
		'vitaminB6': 'Vitamin B6',
		'vitaminB12': 'Vitamin B12',
		'vitaminB9': 'Vitamin B9',
		'vitaminK': 'Vitamin K',
		'cholesterol': 'Cholesterol',
		'butyricAcid': 'Butyric Acid',
		'caproicAcid': 'Caproic Acid',
		'caprylicAcid': 'Caprylic Acid',
		'capricAcid': 'Capric Acid',
		'lauricAcid': 'Lauric Acid',
		'myristicAcid': 'Myristic Acid',
		'palmiticAcid': 'Palmitic Acid',
		'stearicAcid': 'Stearic Acid',
		'oleicAcid': 'Oleic Acid',
		'linoleicAcid': 'Linoleic Acid',
		'docosahexaenoicAcid': 'Docosahexaenoic Acid',
		'eicosapentaenoicAcid': 'Eicosapentaenoic Acid',
		'erucicAcid': 'Erucic Acid',
		'monounsaturatedFat': 'Monounsaturated Fats',
		'polyunsaturatedFat': 'Polyunsaturated Fats',
		'alcohol': 'Alcohol',
		'pantothenicAcid': 'Pantothenic Acid',
		'biotin': 'Biotin',
		'chloride': 'Chloride',
		'chromium': 'Chromium',
		'fluoride': 'Fluoride',
		'iodine': 'Iodine',
		'manganese': 'Manganese',
		'molybdenum': 'Molybdenum',
		'omega3': 'Omega 3',
		'omega6': 'Omega 6',
		'omega9': 'Omega 9',
		'betaCarotene': 'ß-Carotene',
		'bicarbonate': 'Bicarbonate',
		'sugarAlcohol': 'Sugar Alcohol (polyol)',
		'alphaLinolenicAcid': 'Alpha Linolenic Acid',
		'arachidicAcid': 'Arachidic Acid',
		'arachidonicAcid': 'Arachidonic Acid',
		'behenicAcid': 'Behenic Acid',
		'ceroticAcid': 'Cerotic Acid',
		'dihomoGammaLinolenicAcid': 'Dihomo-Gamma-Linolenic Acid',
		'elaidicAcid': 'Elaidic Acid',
		'gammaLinolenicAcid': 'Gamma-Linolenic Acid',
		'gondoicAcid': 'Gondoic Acid (11-Eicosenoic acid)',
		'lignocericAcid': 'Lignoceric Acid',
		'meadAcid': 'Mead Acid',
		'melissicAcid': 'Melissic Acid',
		'montanicAcid': 'Montanic Acid',
		'nervonicAcid': 'Nervonic Acid',
		'transFat': 'Trans Fats',
		'water': 'Water',
	};
	Map<String, String> get nutrimentUnits => {
		'kcal': 'kcal',
		'kj': 'kJ',
		'g': 'g',
		'milliG': 'mg',
		'microG': 'µg',
		'milliL': 'mL',
		'l': 'L',
		'percent': '%',
		'unknown': 'Unknown',
	};
	late final Translations$food$add$en add = Translations$food$add$en._(_root);

	/// en: 'Data provided by OpenFoodFacts'
	String get offAttribution => 'Data provided by OpenFoodFacts';

	late final Translations$food$edit$en edit = Translations$food$edit$en._(_root);
	late final Translations$food$addCustom$en addCustom = Translations$food$addCustom$en._(_root);
	late final Translations$food$search$en search = Translations$food$search$en._(_root);
	late final Translations$food$barcodeReader$en barcodeReader = Translations$food$barcodeReader$en._(_root);
	late final Translations$food$addCustomFood$en addCustomFood = Translations$food$addCustomFood$en._(_root);
	late final Translations$food$nutritionGoal$en nutritionGoal = Translations$food$nutritionGoal$en._(_root);
	late final Translations$food$nutritionGoals$en nutritionGoals = Translations$food$nutritionGoals$en._(_root);
	late final Translations$food$combine$en combine = Translations$food$combine$en._(_root);

	/// en: 'Remove from favorites'
	String get removeFavorite => 'Remove from favorites';

	/// en: 'Add to favorites'
	String get addFavorite => 'Add to favorites';

	Map<String, String> get languages => {
		'aa': 'Afar',
		'ae': 'Avestan',
		'af': 'Afrikaans',
		'ak': 'Akan',
		'am': 'Amharic',
		'an': 'Aragonese',
		'ar': 'Arabic',
		'as': 'Assamese',
		'av': 'Avar',
		'ay': 'Aymara',
		'az': 'Azerbaijani',
		'ba': 'Bashkir',
		'be': 'Belarusian',
		'bg': 'Bulgarian',
		'bh': 'Bihari',
		'bi': 'Bislama',
		'bm': 'Bambara',
		'bn': 'Bengali',
		'bo': 'Tibetan',
		'br': 'Breton',
		'bs': 'Bosnian',
		'ca': 'Catalan',
		'ce': 'Chechen',
		'ch': 'Chamorro',
		'co': 'Corsican',
		'cr': 'Cree',
		'cs': 'Czech',
		'cu': 'Church Slavonic',
		'cv': 'Chuvash',
		'cy': 'Welsh',
		'da': 'Danish',
		'de': 'German',
		'dv': 'Maldivian',
		'dz': 'Dzongkha',
		'ee': 'Ewe',
		'el': 'Modern Greek',
		'en': 'English',
		'eo': 'Esperanto',
		'es': 'Spanish',
		'et': 'Estonian',
		'eu': 'Basque',
		'fa': 'Persian',
		'ff': 'Fulah',
		'fi': 'Finnish',
		'fj': 'Fijian',
		'fo': 'Faorese',
		'fr': 'French',
		'fy': 'West Frisian',
		'ga': 'Irish',
		'gd': 'Scottish Gaelic',
		'gl': 'Galician',
		'gn': 'Guarani',
		'gu': 'Gujarati',
		'gv': 'Manx',
		'ha': 'Hausa',
		'he': 'Hebrew',
		'hi': 'Hindi',
		'ho': 'Hiri Motu',
		'hr': 'Croatian',
		'ht': 'Haitian Creole',
		'hu': 'Hungarian',
		'hy': 'Armenian',
		'hz': 'Herero',
		'ia': 'Interlingua',
		'id': 'Indonesian',
		'ie': 'Interlingue',
		'ig': 'Igbo',
		'ii': 'Nuosu',
		'ik': 'Inupiaq',
		'io': 'Ido',
		'is': 'Icelandic',
		'it': 'Italian',
		'iu': 'Inuktitut',
		'ja': 'Japanese',
		'jv': 'Javanese',
		'ka': 'Georgian',
		'kg': 'Kongo',
		'ki': 'Gikuyu',
		'kj': 'Kwanyama',
		'kk': 'Kazakh',
		'kl': 'Greenlandic',
		'km': 'Khmer',
		'kn': 'Kannada',
		'ko': 'Korean',
		'kr': 'Kanuri',
		'ks': 'Kashmiri',
		'ku': 'Kurdish',
		'kv': 'Komi',
		'kw': 'Cornish',
		'ky': 'Kyrgyz',
		'la': 'Latin',
		'lb': 'Luxembourgish',
		'lg': 'Luganda',
		'li': 'Limburgan',
		'ln': 'Lingala',
		'lo': 'Lao',
		'lt': 'Lithuanian',
		'lu': 'Luba-Katanga',
		'lv': 'Latvian',
		'mg': 'Malagasy',
		'mh': 'Marshallese',
		'mi': 'Maori',
		'mk': 'Macedonian',
		'ml': 'Malayalam',
		'mn': 'Mongolian',
		'mo': 'Moldovan',
		'mr': 'Marathi',
		'ms': 'Malay',
		'mt': 'Maltese',
		'my': 'Burmese',
		'na': 'Nauruan',
		'nb': 'Bokmal',
		'nd': 'North Ndbele',
		'ne': 'Nepali',
		'ng': 'Ndonga',
		'nl': 'Dutch',
		'nn': 'Nynorsk',
		'no': 'Norwegian',
		'nr': 'South Ndebele',
		'nv': 'Navajo',
		'ny': 'Chewa',
		'oc': 'Occitan',
		'oj': 'Ojibwe',
		'om': 'Oromo',
		'or': 'Odia',
		'os': 'Ossetian',
		'pa': 'Punjabi',
		'pi': 'Pali',
		'pl': 'Polish',
		'ps': 'Pashto',
		'pt': 'Portuguese',
		'qu': 'Quechua',
		'rm': 'Romansh',
		'rn': 'Kirundi',
		'ro': 'Romanian',
		'ru': 'Russian',
		'rw': 'Kinyarmanda',
		'sa': 'Sanskrit',
		'sc': 'Sardinian',
		'sd': 'Sindhi',
		'se': 'Northern Sami',
		'sg': 'Sango',
		'si': 'Sinhala',
		'sk': 'Slovak',
		'sl': 'Slovenian',
		'sm': 'Samoan',
		'sn': 'Shona',
		'so': 'Somali',
		'sq': 'Albanian',
		'sr': 'Serbian',
		'ss': 'Swazi',
		'st': 'Sotho',
		'su': 'Sundanese',
		'sv': 'Swedish',
		'sw': 'Swahili',
		'ta': 'Tamil',
		'te': 'Telugu',
		'tg': 'Tajik',
		'th': 'Thai',
		'ti': 'Tigrinya',
		'tk': 'Turkmen',
		'tl': 'Tagalog',
		'tn': 'Tswana',
		'to': 'Tonga',
		'tr': 'Turkish',
		'ts': 'Tsonga',
		'tt': 'Tatar',
		'tw': 'Twi',
		'ty': 'Tahitian',
		'ug': 'Uyghur',
		'uk': 'Ukrainian',
		'ur': 'Urdu',
		'uz': 'Uzbek',
		've': 'Venda',
		'vi': 'Vietnamese',
		'vo': 'Volapuk',
		'wo': 'Wolof',
		'xh': 'Xhosa',
		'yi': 'Yiddish',
		'yo': 'Yoruba',
		'za': 'Zhuang',
		'zh': 'Chinese',
		'zu': 'Zulu',
		'xx': 'Unknown language',
		'world': 'World, as pseudo language',
		'und': 'Undefined language',
	};
	Map<String, String> get countries => {
		'ad': 'Andorra',
		'ae': 'United Arab Emirates',
		'af': 'Afghanistan',
		'ag': 'Antigua and Barbuda',
		'ai': 'Anguilla',
		'al': 'Albania',
		'am': 'Armenia',
		'ao': 'Angola',
		'aq': 'Antarctica',
		'ar': 'Argentina',
		'as': 'American Samoa',
		'at': 'Austria',
		'au': 'Australia',
		'aw': 'Aruba',
		'ax': 'Åland Islands',
		'az': 'Azerbaijan',
		'ba': 'Bosnia and Herzegovina',
		'bb': 'Barbados',
		'bd': 'Bangladesh',
		'be': 'Belgium',
		'bf': 'Burkina Faso',
		'bg': 'Bulgaria',
		'bh': 'Bahrain',
		'bi': 'Burundi',
		'bj': 'Benin',
		'bl': 'Saint Barthélemy',
		'bm': 'Bermuda',
		'bn': 'Brunei Darussalam',
		'bo': 'Bolivia (Plurinational State of)',
		'bq': 'Bonaire, Sint Eustatius and Saba',
		'br': 'Brazil',
		'bs': 'Bahamas',
		'bt': 'Bhutan',
		'bv': 'Bouvet Island',
		'bw': 'Botswana',
		'by': 'Belarus',
		'bz': 'Belize',
		'ca': 'Canada',
		'cc': 'Cocos (Keeling) Islands',
		'cd': 'Congo, Democratic Republic of the',
		'cf': 'Central African Republic',
		'cg': 'Congo',
		'ch': 'Switzerland',
		'ci': 'Côte d\'Ivoire',
		'ck': 'Cook Islands',
		'cl': 'Chile',
		'cm': 'Cameroon',
		'cn': 'China',
		'co': 'Colombia',
		'cr': 'Costa Rica',
		'cu': 'Cuba',
		'cv': 'Cabo Verde',
		'cw': 'Curaçao',
		'cx': 'Christmas Island',
		'cy': 'Cyprus',
		'cz': 'Czechia',
		'de': 'Germany',
		'dj': 'Djibouti',
		'dk': 'Denmark',
		'dm': 'Dominica',
		'do': 'Dominican Republic',
		'dz': 'Algeria',
		'ec': 'Ecuador',
		'ee': 'Estonia',
		'eg': 'Egypt',
		'eh': 'Western Sahara',
		'er': 'Eritrea',
		'es': 'Spain',
		'et': 'Ethiopia',
		'fi': 'Finland',
		'fj': 'Fiji',
		'fk': 'Falkland Islands (Malvinas)',
		'fm': 'Micronesia (Federated States of)',
		'fo': 'Faroe Islands',
		'fr': 'France',
		'ga': 'Gabon',
		'gd': 'Grenada',
		'ge': 'Georgia',
		'gf': 'French Guiana',
		'gg': 'Guernsey',
		'gh': 'Ghana',
		'gi': 'Gibraltar',
		'gl': 'Greenland',
		'gm': 'Gambia',
		'gn': 'Guinea',
		'gp': 'Guadeloupe',
		'gq': 'Equatorial Guinea',
		'gr': 'Greece',
		'gs': 'South Georgia and the South Sandwich Islands',
		'gt': 'Guatemala',
		'gu': 'Guam',
		'gw': 'Guinea-Bissau',
		'gy': 'Guyana',
		'hk': 'Hong Kong',
		'hm': 'Heard Island and McDonald Islands',
		'hn': 'Honduras',
		'hr': 'Croatia',
		'ht': 'Haiti',
		'hu': 'Hungary',
		'id': 'Indonesia',
		'ie': 'Ireland',
		'il': 'Israel',
		'im': 'Isle of Man',
		'in': 'India',
		'io': 'British Indian Ocean Territory',
		'iq': 'Iraq',
		'ir': 'Iran (Islamic Republic of)',
		'is': 'Iceland',
		'it': 'Italy',
		'je': 'Jersey',
		'jm': 'Jamaica',
		'jo': 'Jordan',
		'jp': 'Japan',
		'ke': 'Kenya',
		'kg': 'Kyrgyzstan',
		'kh': 'Cambodia',
		'ki': 'Kiribati',
		'km': 'Comoros',
		'kn': 'Saint Kitts and Nevis',
		'kp': 'Korea (Democratic People\'s Republic of)',
		'kr': 'Korea, Republic of',
		'kw': 'Kuwait',
		'ky': 'Cayman Islands',
		'kz': 'Kazakhstan',
		'la': 'Lao People\'s Democratic Republic',
		'lb': 'Lebanon',
		'lc': 'Saint Lucia',
		'li': 'Liechtenstein',
		'lk': 'Sri Lanka',
		'lr': 'Liberia',
		'ls': 'Lesotho',
		'lt': 'Lithuania',
		'lu': 'Luxembourg',
		'lv': 'Latvia',
		'ly': 'Libya',
		'ma': 'Morocco',
		'mc': 'Monaco',
		'md': 'Moldova, Republic of',
		'me': 'Montenegro',
		'mf': 'Saint Martin (French part)',
		'mg': 'Madagascar',
		'mh': 'Marshall Islands',
		'mk': 'North Macedonia',
		'ml': 'Mali',
		'mm': 'Myanmar',
		'mn': 'Mongolia',
		'mo': 'Macao',
		'mp': 'Northern Mariana Islands',
		'mq': 'Martinique',
		'mr': 'Mauritania',
		'ms': 'Montserrat',
		'mt': 'Malta',
		'mu': 'Mauritius',
		'mv': 'Maldives',
		'mw': 'Malawi',
		'mx': 'Mexico',
		'my': 'Malaysia',
		'mz': 'Mozambique',
		'na': 'Namibia',
		'nc': 'New Caledonia',
		'ne': 'Niger',
		'nf': 'Norfolk Island',
		'ng': 'Nigeria',
		'ni': 'Nicaragua',
		'nl': 'Netherlands',
		'no': 'Norway',
		'np': 'Nepal',
		'nr': 'Nauru',
		'nu': 'Niue',
		'nz': 'New Zealand',
		'om': 'Oman',
		'pa': 'Panama',
		'pe': 'Peru',
		'pf': 'French Polynesia',
		'pg': 'Papua New Guinea',
		'ph': 'Philippines',
		'pk': 'Pakistan',
		'pl': 'Poland',
		'pm': 'Saint Pierre and Miquelon',
		'pn': 'Pitcairn',
		'pr': 'Puerto Rico',
		'ps': 'Palestine, State of',
		'pt': 'Portugal',
		'pw': 'Palau',
		'py': 'Paraguay',
		'qa': 'Qatar',
		're': 'Réunion',
		'ro': 'Romania',
		'rs': 'Serbia',
		'ru': 'Russian Federation',
		'rw': 'Rwanda',
		'sa': 'Saudi Arabia',
		'sb': 'Solomon Islands',
		'sc': 'Seychelles',
		'sd': 'Sudan',
		'se': 'Sweden',
		'sg': 'Singapore',
		'sh': 'Saint Helena, Ascension and Tristan da Cunha',
		'si': 'Slovenia',
		'sj': 'Svalbard and Jan Mayen',
		'sk': 'Slovakia',
		'sl': 'Sierra Leone',
		'sm': 'San Marino',
		'sn': 'Senegal',
		'so': 'Somalia',
		'sr': 'Suriname',
		'ss': 'South Sudan',
		'st': 'Sao Tome and Principe',
		'sv': 'El Salvador',
		'sx': 'Sint Maarten (Dutch part)',
		'sy': 'Syrian Arab Republic',
		'sz': 'Eswatini',
		'tc': 'Turks and Caicos Islands',
		'td': 'Chad',
		'tf': 'French Southern Territories',
		'tg': 'Togo',
		'th': 'Thailand',
		'tj': 'Tajikistan',
		'tk': 'Tokelau',
		'tl': 'Timor-Leste',
		'tm': 'Turkmenistan',
		'tn': 'Tunisia',
		'to': 'Tonga',
		'tr': 'Turkey',
		'tt': 'Trinidad and Tobago',
		'tv': 'Tuvalu',
		'tw': 'Taiwan',
		'tz': 'Tanzania, United Republic of',
		'ua': 'Ukraine',
		'ug': 'Uganda',
		'uk': 'United Kingdom of Great Britain and Northern Ireland',
		'um': 'United States Minor Outlying Islands',
		'us': 'United States of America',
		'uy': 'Uruguay',
		'uz': 'Uzbekistan',
		'va': 'Holy See',
		'vc': 'Saint Vincent and the Grenadines',
		've': 'Venezuela (Bolivarian Republic of)',
		'vg': 'Virgin Islands (British)',
		'vi': 'Virgin Islands (U.S.)',
		'vn': 'Viet Nam',
		'vu': 'Vanuatu',
		'wf': 'Wallis and Futuna',
		'ws': 'Samoa',
		'ye': 'Yemen',
		'yt': 'Mayotte',
		'za': 'South Africa',
		'zm': 'Zambia',
		'zw': 'Zimbabwe',
		'world': 'World',
	};
	late final Translations$food$categoryList$en categoryList = Translations$food$categoryList$en._(_root);
	late final Translations$food$categoryEditor$en categoryEditor = Translations$food$categoryEditor$en._(_root);
	late final Translations$food$categoryFoods$en categoryFoods = Translations$food$categoryFoods$en._(_root);
	late final Translations$food$permission$en permission = Translations$food$permission$en._(_root);
	late final Translations$food$datePicker$en datePicker = Translations$food$datePicker$en._(_root);
	late final Translations$food$catalog$en catalog = Translations$food$catalog$en._(_root);
	late final Translations$food$picker$en picker = Translations$food$picker$en._(_root);
	late final Translations$food$recipes$en recipes = Translations$food$recipes$en._(_root);
}

// Path: equipment
class Translations$equipment$en {
	Translations$equipment$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$equipment$none$en none = Translations$equipment$none$en._(_root);
	late final Translations$equipment$barbell$en barbell = Translations$equipment$barbell$en._(_root);
	late final Translations$equipment$dumbbell$en dumbbell = Translations$equipment$dumbbell$en._(_root);
	late final Translations$equipment$cable$en cable = Translations$equipment$cable$en._(_root);
	late final Translations$equipment$machine$en machine = Translations$equipment$machine$en._(_root);
	late final Translations$equipment$kettlebell$en kettlebell = Translations$equipment$kettlebell$en._(_root);
	late final Translations$equipment$plates$en plates = Translations$equipment$plates$en._(_root);
	late final Translations$equipment$resistanceBand$en resistanceBand = Translations$equipment$resistanceBand$en._(_root);
	late final Translations$equipment$suspensionBands$en suspensionBands = Translations$equipment$suspensionBands$en._(_root);
	late final Translations$equipment$landmine$en landmine = Translations$equipment$landmine$en._(_root);
	late final Translations$equipment$other$en other = Translations$equipment$other$en._(_root);
}

// Path: achievements
class Translations$achievements$en {
	Translations$achievements$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Achievements'
	String get title => 'Achievements';

	/// en: 'Locked'
	String get locked => 'Locked';

	/// en: 'Unlocked on: $date'
	String unlockedOn({required Object date}) => 'Unlocked on: ${date}';

	/// en: 'History'
	String get history => 'History';

	late final Translations$achievements$firstSteps$en firstSteps = Translations$achievements$firstSteps$en._(_root);
	late final Translations$achievements$foodWatcher$en foodWatcher = Translations$achievements$foodWatcher$en._(_root);
	late final Translations$achievements$marathoner$en marathoner = Translations$achievements$marathoner$en._(_root);
	late final Translations$achievements$earlyBird$en earlyBird = Translations$achievements$earlyBird$en._(_root);
	late final Translations$achievements$nightOwl$en nightOwl = Translations$achievements$nightOwl$en._(_root);
	late final Translations$achievements$realGymBro$en realGymBro = Translations$achievements$realGymBro$en._(_root);
	late final Translations$achievements$workoutFreak$en workoutFreak = Translations$achievements$workoutFreak$en._(_root);
	late final Translations$achievements$trailblazer$en trailblazer = Translations$achievements$trailblazer$en._(_root);
	late final Translations$achievements$cycleChampion$en cycleChampion = Translations$achievements$cycleChampion$en._(_root);
	late final Translations$achievements$professionalWeightlifter$en professionalWeightlifter = Translations$achievements$professionalWeightlifter$en._(_root);
	late final Translations$achievements$programPlanner$en programPlanner = Translations$achievements$programPlanner$en._(_root);
	late final Translations$achievements$perfectPlanner$en perfectPlanner = Translations$achievements$perfectPlanner$en._(_root);
	late final Translations$achievements$routineMaster$en routineMaster = Translations$achievements$routineMaster$en._(_root);
	late final Translations$achievements$intensityInnovator$en intensityInnovator = Translations$achievements$intensityInnovator$en._(_root);
	late final Translations$achievements$completionist$en completionist = Translations$achievements$completionist$en._(_root);
	late final Translations$achievements$notDrunk$en notDrunk = Translations$achievements$notDrunk$en._(_root);
	late final Translations$achievements$steamedHams$en steamedHams = Translations$achievements$steamedHams$en._(_root);
	late final Translations$achievements$swimsuitSeason$en swimsuitSeason = Translations$achievements$swimsuitSeason$en._(_root);
	late final Translations$achievements$pbBreaker$en pbBreaker = Translations$achievements$pbBreaker$en._(_root);
	late final Translations$achievements$sparta$en sparta = Translations$achievements$sparta$en._(_root);
	late final Translations$achievements$midnightRain$en midnightRain = Translations$achievements$midnightRain$en._(_root);
	late final Translations$achievements$equipmentSpecialist$en equipmentSpecialist = Translations$achievements$equipmentSpecialist$en._(_root);
	late final Translations$achievements$bodyweightBeast$en bodyweightBeast = Translations$achievements$bodyweightBeast$en._(_root);
}

// Path: workoutGenerator
class Translations$workoutGenerator$en {
	Translations$workoutGenerator$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Workout Generator'
	String get title => 'Workout Generator';

	/// en: 'Select muscle groups'
	String get muscleGroups => 'Select muscle groups';

	/// en: 'Select equipment'
	String get equipment => 'Select equipment';

	late final Translations$workoutGenerator$actions$en actions = Translations$workoutGenerator$actions$en._(_root);
	late final Translations$workoutGenerator$success$en success = Translations$workoutGenerator$success$en._(_root);
	late final Translations$workoutGenerator$empty$en empty = Translations$workoutGenerator$empty$en._(_root);
}

// Path: boutique
class Translations$boutique$en {
	Translations$boutique$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Programs'
	String get title => 'Programs';

	late final Translations$boutique$package$en package = Translations$boutique$package$en._(_root);
	Map<String, String> get errors => {
		'unknown': 'Loading failed. Check your Internet connection and retry.',
		'version': 'This version of the app is not compatible with the program shop. Update to the latest version and try again.',
	};
	late final Translations$boutique$marketingUpdating$en marketingUpdating = Translations$boutique$marketingUpdating$en._(_root);
}

// Path: login
class Translations$login$en {
	Translations$login$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get title => 'Login';

	late final Translations$login$tabs$en tabs = Translations$login$tabs$en._(_root);
	late final Translations$login$errors$en errors = Translations$login$errors$en._(_root);
	late final Translations$login$fields$en fields = Translations$login$fields$en._(_root);
	late final Translations$login$buttons$en buttons = Translations$login$buttons$en._(_root);
	late final Translations$login$upsell$en upsell = Translations$login$upsell$en._(_root);
	late final Translations$login$verifyEmail$en verifyEmail = Translations$login$verifyEmail$en._(_root);
	late final Translations$login$presentation$en presentation = Translations$login$presentation$en._(_root);
	late final Translations$login$recovery$en recovery = Translations$login$recovery$en._(_root);
}

// Path: sync
class Translations$sync$en {
	Translations$sync$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$sync$conflict$en conflict = Translations$sync$conflict$en._(_root);
	late final Translations$sync$overwrite$en overwrite = Translations$sync$overwrite$en._(_root);

	/// en: 'Synchronizing'
	String get inProgress => 'Synchronizing';
}

// Path: bodyMeasurement.neck
class Translations$bodyMeasurement$neck$en {
	Translations$bodyMeasurement$neck$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Neck'
	String get label => 'Neck';
}

// Path: bodyMeasurement.waist
class Translations$bodyMeasurement$waist$en {
	Translations$bodyMeasurement$waist$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Waist'
	String get label => 'Waist';
}

// Path: bodyMeasurement.bodyFat
class Translations$bodyMeasurement$bodyFat$en {
	Translations$bodyMeasurement$bodyFat$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Body fat percentage'
	String get label => 'Body fat percentage';
}

// Path: bodyMeasurement.shoulder
class Translations$bodyMeasurement$shoulder$en {
	Translations$bodyMeasurement$shoulder$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Shoulder'
	String get label => 'Shoulder';
}

// Path: bodyMeasurement.chest
class Translations$bodyMeasurement$chest$en {
	Translations$bodyMeasurement$chest$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Chest'
	String get label => 'Chest';
}

// Path: bodyMeasurement.leftBicep
class Translations$bodyMeasurement$leftBicep$en {
	Translations$bodyMeasurement$leftBicep$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Left biceps'
	String get label => 'Left biceps';
}

// Path: bodyMeasurement.rightBicep
class Translations$bodyMeasurement$rightBicep$en {
	Translations$bodyMeasurement$rightBicep$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Right biceps'
	String get label => 'Right biceps';
}

// Path: bodyMeasurement.leftForearm
class Translations$bodyMeasurement$leftForearm$en {
	Translations$bodyMeasurement$leftForearm$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Left forearm'
	String get label => 'Left forearm';
}

// Path: bodyMeasurement.rightForearm
class Translations$bodyMeasurement$rightForearm$en {
	Translations$bodyMeasurement$rightForearm$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Right forearm'
	String get label => 'Right forearm';
}

// Path: bodyMeasurement.abdomen
class Translations$bodyMeasurement$abdomen$en {
	Translations$bodyMeasurement$abdomen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Abdomen'
	String get label => 'Abdomen';
}

// Path: bodyMeasurement.hips
class Translations$bodyMeasurement$hips$en {
	Translations$bodyMeasurement$hips$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Hips'
	String get label => 'Hips';
}

// Path: bodyMeasurement.leftThigh
class Translations$bodyMeasurement$leftThigh$en {
	Translations$bodyMeasurement$leftThigh$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Left thigh'
	String get label => 'Left thigh';
}

// Path: bodyMeasurement.rightThigh
class Translations$bodyMeasurement$rightThigh$en {
	Translations$bodyMeasurement$rightThigh$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Right thigh'
	String get label => 'Right thigh';
}

// Path: bodyMeasurement.leftCalf
class Translations$bodyMeasurement$leftCalf$en {
	Translations$bodyMeasurement$leftCalf$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Left calf'
	String get label => 'Left calf';
}

// Path: bodyMeasurement.rightCalf
class Translations$bodyMeasurement$rightCalf$en {
	Translations$bodyMeasurement$rightCalf$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Right calf'
	String get label => 'Right calf';
}

// Path: onboarding
class Translations$onboarding$en {
	Translations$onboarding$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$onboarding$buttons$en buttons = Translations$onboarding$buttons$en._(_root);
	late final Translations$onboarding$welcome$en welcome = Translations$onboarding$welcome$en._(_root);
	late final Translations$onboarding$notifications$en notifications = Translations$onboarding$notifications$en._(_root);
	late final Translations$onboarding$camera$en camera = Translations$onboarding$camera$en._(_root);
	late final Translations$onboarding$done$en done = Translations$onboarding$done$en._(_root);
	late final Translations$onboarding$login$en login = Translations$onboarding$login$en._(_root);
}

// Path: nags.routines
class Translations$nags$routines$en {
	Translations$nags$routines$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You've been using Gym Bro for a while now'
	String get title => 'You\'ve been using Gym Bro for a while now';

	/// en: 'With the Pro version, you can create unlimited routines. Become a Pro Bro and take your workouts to the next level!'
	String get subtitle => 'With the Pro version, you can create unlimited routines. Become a Pro Bro and take your workouts to the next level!';
}

// Path: nags.library
class Translations$nags$library$en {
	Translations$nags$library$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You've been exploring Gym Bro for a while now.'
	String get title => 'You\'ve been exploring Gym Bro for a while now.';

	/// en: 'With the Pro version, you can create unlimited exercises. Become a Pro Bro and take your workouts to the next level!'
	String get subtitle => 'With the Pro version, you can create unlimited exercises. Become a Pro Bro and take your workouts to the next level!';
}

// Path: nags.history
class Translations$nags$history$en {
	Translations$nags$history$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You've been enjoying Gym Bro for a while now, it appears!'
	String get title => 'You\'ve been enjoying Gym Bro for a while now, it appears!';

	/// en: 'With the Pro version, you can start unlimited workouts. Become a Pro Bro and take your workouts to the next level!'
	String get subtitle => 'With the Pro version, you can start unlimited workouts. Become a Pro Bro and take your workouts to the next level!';
}

// Path: nags.food
class Translations$nags$food$en {
	Translations$nags$food$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Woah, hold on! You can't do that yet.'
	String get title => 'Woah, hold on! You can\'t do that yet.';

	/// en: 'With the Pro version, you can see historical data. Become a Pro Bro and take your nutrition to the next level!'
	String get subtitle => 'With the Pro version, you can see historical data. Become a Pro Bro and take your nutrition to the next level!';
}

// Path: feed
class Translations$feed$en {
	Translations$feed$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Feed'
	String get title => 'Feed';

	late final Translations$feed$empty$en empty = Translations$feed$empty$en._(_root);

	/// en: 'Choose a workout'
	String get startWorkout => 'Choose a workout';

	late final Translations$feed$workout$en workout = Translations$feed$workout$en._(_root);
	late final Translations$feed$achievement$en achievement = Translations$feed$achievement$en._(_root);
	late final Translations$feed$userButton$en userButton = Translations$feed$userButton$en._(_root);
	late final Translations$feed$noSync$en noSync = Translations$feed$noSync$en._(_root);

	/// en: 'You've reached the end of your feed :)'
	String get noMoreData => 'You\'ve reached the end of your feed :)';

	/// en: 'Load more'
	String get loadMore => 'Load more';

	/// en: 'Suggested routines'
	String get suggestedRoutines => 'Suggested routines';

	late final Translations$feed$suggestions$en suggestions = Translations$feed$suggestions$en._(_root);
	late final Translations$feed$loadError$en loadError = Translations$feed$loadError$en._(_root);
}

// Path: workoutPage
class Translations$workoutPage$en {
	Translations$workoutPage$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Work Out'
	String get title => 'Work Out';
}

// Path: pro
class Translations$pro$en {
	Translations$pro$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'PRO'
	String get title => 'PRO';
}

// Path: userProfile
class Translations$userProfile$en {
	Translations$userProfile$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	/// en: 'Add Friend'
	String get addFriend => 'Add Friend';

	/// en: 'Unfriend'
	String get unfriend => 'Unfriend';

	/// en: 'Friend Request Sent'
	String get requestSent => 'Friend Request Sent';

	late final Translations$userProfile$cancelRequestConfirmation$en cancelRequestConfirmation = Translations$userProfile$cancelRequestConfirmation$en._(_root);

	/// en: 'Accept'
	String get accept => 'Accept';

	/// en: 'Decline'
	String get decline => 'Decline';

	late final Translations$userProfile$unfriendConfirmation$en unfriendConfirmation = Translations$userProfile$unfriendConfirmation$en._(_root);

	/// en: 'Reject'
	String get reject => 'Reject';

	late final Translations$userProfile$stats$en stats = Translations$userProfile$stats$en._(_root);
	late final Translations$userProfile$feed$en feed = Translations$userProfile$feed$en._(_root);
	late final Translations$userProfile$edit$en edit = Translations$userProfile$edit$en._(_root);
	late final Translations$userProfile$crop$en crop = Translations$userProfile$crop$en._(_root);
	late final Translations$userProfile$error$en error = Translations$userProfile$error$en._(_root);
	late final Translations$userProfile$errors$en errors = Translations$userProfile$errors$en._(_root);
}

// Path: friendRequests
class Translations$friendRequests$en {
	Translations$friendRequests$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Friend Requests'
	String get title => 'Friend Requests';

	/// en: 'sent you a friend request'
	String get subtitle => 'sent you a friend request';

	late final Translations$friendRequests$empty$en empty = Translations$friendRequests$empty$en._(_root);
}

// Path: profileSearch
class Translations$profileSearch$en {
	Translations$profileSearch$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search Profiles'
	String get title => 'Search Profiles';

	/// en: 'Search username...'
	String get searchHint => 'Search username...';

	late final Translations$profileSearch$noResults$en noResults = Translations$profileSearch$noResults$en._(_root);
}

// Path: error
class Translations$error$en {
	Translations$error$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'An unknown error occurred'
	String get title => 'An unknown error occurred';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: 'Open logs'
	String get logs => 'Open logs';
}

// Path: legacyWorkoutRecovery
class Translations$legacyWorkoutRecovery$en {
	Translations$legacyWorkoutRecovery$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Previous workout to recover'
	String get title => 'Previous workout to recover';

	/// en: 'Recover in this account'
	String get action => 'Recover in this account';

	/// en: 'Recover this workout in ${account}? It will become the ongoing workout for this account.'
	String confirm({required Object account}) => 'Recover this workout in ${account}? It will become the ongoing workout for this account.';

	/// en: 'Guest'
	String get guest => 'Guest';

	/// en: 'The workout could not be recovered. Check that this account has no ongoing workout, then try again.'
	String get failed => 'The workout could not be recovered. Check that this account has no ongoing workout, then try again.';
}

// Path: friendsList
class Translations$friendsList$en {
	Translations$friendsList$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Load more'
	String get loadMore => 'Load more';

	/// en: 'Friends'
	String get title => 'Friends';

	/// en: 'No friends yet'
	String get empty => 'No friends yet';

	/// en: 'Accepted friendships will appear here.'
	String get emptyDescription => 'Accepted friendships will appear here.';

	/// en: '$name’s achievements'
	String historyTitle({required Object name}) => '${name}’s achievements';

	/// en: 'No achievements yet'
	String get historyEmpty => 'No achievements yet';

	/// en: 'This friend’s unlocked achievements will appear here.'
	String get historyEmptyDescription => 'This friend’s unlocked achievements will appear here.';

	/// en: 'Unknown achievement'
	String get unknownAchievement => 'Unknown achievement';

	/// en: 'History is only available for your friends.'
	String get accessDenied => 'History is only available for your friends.';
}

// Path: social
class Translations$social$en {
	Translations$social$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Post'
	String get post => 'Post';

	/// en: 'Comments'
	String get comments => 'Comments';

	/// en: 'Comment'
	String get comment => 'Comment';

	/// en: 'Like'
	String get like => 'Like';

	/// en: 'Unlike'
	String get unlike => 'Unlike';

	/// en: 'Send'
	String get send => 'Send';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Load more'
	String get more => 'Load more';

	/// en: 'Only me'
	String get private => 'Only me';

	/// en: 'Friends'
	String get friends => 'Friends';

	/// en: 'Visibility'
	String get visibility => 'Visibility';

	/// en: 'Change waiting to sync'
	String get pending => 'Change waiting to sync';

	/// en: 'Waiting to publish'
	String get unpublished => 'Waiting to publish';

	/// en: 'Content unavailable'
	String get unavailable => 'Content unavailable';

	/// en: 'Something went wrong. Please try again.'
	String get error => 'Something went wrong. Please try again.';

	/// en: 'There is nothing to show.'
	String get empty => 'There is nothing to show.';

	/// en: 'Block user'
	String get block => 'Block user';

	/// en: 'Unblock'
	String get unblock => 'Unblock';

	/// en: 'Blocked users'
	String get blockedUsers => 'Blocked users';

	/// en: 'Report user'
	String get report => 'Report user';

	/// en: 'My reports'
	String get reports => 'My reports';

	/// en: 'Reason (required)'
	String get reason => 'Reason (required)';

	/// en: 'Report submitted'
	String get reportSent => 'Report submitted';

	/// en: 'Block this user? Your friendship and requests will be removed.'
	String get blockConfirm => 'Block this user? Your friendship and requests will be removed.';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Received'
	String get received => 'Received';

	/// en: 'Under review'
	String get reviewing => 'Under review';

	/// en: 'Resolved'
	String get resolved => 'Resolved';

	/// en: 'Dismissed'
	String get dismissed => 'Dismissed';

	/// en: 'Sent you a friend request'
	String get friendRequest => 'Sent you a friend request';

	/// en: 'Accepted your friend request'
	String get friendAccepted => 'Accepted your friend request';

	/// en: 'Liked your post'
	String get likedPost => 'Liked your post';

	/// en: 'Commented on your post'
	String get commentedPost => 'Commented on your post';

	/// en: 'Unlocked an achievement'
	String get achievementUnlocked => 'Unlocked an achievement';

	/// en: 'Your report status changed'
	String get reportUpdated => 'Your report status changed';

	/// en: 'Accept'
	String get accept => 'Accept';

	/// en: 'Decline'
	String get reject => 'Decline';

	/// en: 'Sign in to continue'
	String get signIn => 'Sign in to continue';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Push notifications'
	String get push => 'Push notifications';

	/// en: 'Requests, interactions, achievements and reports'
	String get pushDescription => 'Requests, interactions, achievements and reports';

	/// en: 'Push notifications are not configured on this device'
	String get pushDisabled => 'Push notifications are not configured on this device';

	/// en: 'Your trainer published a plan or revision'
	String get trainerPlan => 'Your trainer published a plan or revision';
}

// Path: hydration
class Translations$hydration$en {
	Translations$hydration$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Water'
	String get title => 'Water';

	/// en: 'Water drunk'
	String get drinking => 'Water drunk';

	/// en: 'From foods'
	String get food => 'From foods';

	/// en: 'Add water'
	String get add => 'Add water';

	/// en: 'Custom amount'
	String get custom => 'Custom amount';

	/// en: 'Amount (ml)'
	String get amount => 'Amount (ml)';

	/// en: 'Time'
	String get time => 'Time';

	/// en: 'Daily goal (ml)'
	String get goal => 'Daily goal (ml)';

	/// en: 'Set goal'
	String get setGoal => 'Set goal';

	/// en: 'No goal set'
	String get noGoal => 'No goal set';

	/// en: 'Leave blank to remove the goal'
	String get optionalGoal => 'Leave blank to remove the goal';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Enter a valid positive amount'
	String get invalid => 'Enter a valid positive amount';

	/// en: 'Choose a time in the past'
	String get future => 'Choose a time in the past';

	/// en: 'Connect to Health'
	String get connect => 'Connect to Health';

	/// en: 'Disable Health export'
	String get disconnect => 'Disable Health export';

	/// en: 'Health export disabled'
	String get disabled => 'Health export disabled';

	/// en: 'Water synced with Health'
	String get synced => 'Water synced with Health';

	/// en: 'Health export pending: check permissions and retry'
	String get pending => 'Health export pending: check permissions and retry';

	/// en: 'Health service unavailable'
	String get unavailable => 'Health service unavailable';

	/// en: 'Syncing with Health…'
	String get syncing => 'Syncing with Health…';

	/// en: 'No drinking water recorded'
	String get empty => 'No drinking water recorded';

	/// en: 'Unable to save. Try again.'
	String get error => 'Unable to save. Try again.';

	/// en: 'Still water'
	String get natural => 'Still water';

	/// en: 'Sparkling water'
	String get sparkling => 'Sparkling water';

	/// en: 'Cucumber with peel, raw'
	String get cucumber => 'Cucumber with peel, raw';

	/// en: 'Tomato, red, raw'
	String get tomato => 'Tomato, red, raw';

	/// en: 'Watermelon, raw'
	String get watermelon => 'Watermelon, raw';

	/// en: 'Apple with skin, raw'
	String get apple => 'Apple with skin, raw';

	/// en: 'Source: USDA SR Legacy'
	String get source => 'Source: USDA SR Legacy';

	/// en: 'Water (ml per 100 g/ml)'
	String get waterPer100 => 'Water (ml per 100 g/ml)';

	/// en: 'Water history'
	String get history => 'Water history';

	/// en: 'Water is saved in your diary. To also add it to Health, allow access in Settings → Permissions.'
	String get permissionDenied => 'Water is saved in your diary. To also add it to Health, allow access in Settings → Permissions.';
}

// Path: reports
class Translations$reports$en {
	Translations$reports$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Progress reports'
	String get title => 'Progress reports';

	/// en: 'Day'
	String get day => 'Day';

	/// en: 'Week'
	String get week => 'Week';

	/// en: 'Month'
	String get month => 'Month';

	/// en: 'Training'
	String get training => 'Training';

	/// en: 'Nutrition'
	String get nutrition => 'Nutrition';

	/// en: 'Body measurements'
	String get measurements => 'Body measurements';

	/// en: 'Preview report'
	String get preview => 'Preview report';

	/// en: 'Save PDF'
	String get save => 'Save PDF';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Reference date'
	String get reference => 'Reference date';

	/// en: 'Select at least one section.'
	String get chooseSection => 'Select at least one section.';

	/// en: 'No records in this period.'
	String get empty => 'No records in this period.';

	/// en: 'No records'
	String get missing => 'No records';

	/// en: 'Not available'
	String get unavailable => 'Not available';

	/// en: 'Unable to generate the report. Please retry.'
	String get error => 'Unable to generate the report. Please retry.';

	/// en: 'Unable to export the PDF. Please retry.'
	String get exportError => 'Unable to export the PDF. Please retry.';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'PDF saved'
	String get saved => 'PDF saved';

	/// en: 'Generated'
	String get generated => 'Generated';

	/// en: 'Daily detail'
	String get daily => 'Daily detail';

	/// en: 'Summary'
	String get summary => 'Summary';

	/// en: 'Sessions'
	String get sessions => 'Sessions';

	/// en: 'Completed sets'
	String get sets => 'Completed sets';

	/// en: 'Repetitions'
	String get reps => 'Repetitions';

	/// en: 'Load'
	String get load => 'Load';

	/// en: 'Duration'
	String get duration => 'Duration';

	/// en: 'Distance'
	String get distance => 'Distance';

	/// en: 'Volume (positive loads × repetitions)'
	String get volume => 'Volume (positive loads × repetitions)';

	/// en: 'Exercise'
	String get exercise => 'Exercise';

	/// en: 'Status'
	String get status => 'Status';

	/// en: 'Completed'
	String get done => 'Completed';

	/// en: 'Not completed'
	String get pending => 'Not completed';

	/// en: 'Superset'
	String get superset => 'Superset';

	/// en: 'Continuation'
	String get continuation => 'Continuation';

	/// en: 'Food / meal'
	String get food => 'Food / meal';

	/// en: 'Quantity'
	String get quantity => 'Quantity';

	/// en: 'Calories'
	String get calories => 'Calories';

	/// en: 'Protein'
	String get protein => 'Protein';

	/// en: 'Carbohydrates'
	String get carbs => 'Carbohydrates';

	/// en: 'Fat'
	String get fat => 'Fat';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Average per recorded day'
	String get average => 'Average per recorded day';

	/// en: 'Recorded days'
	String get coverage => 'Recorded days';

	/// en: 'First'
	String get first => 'First';

	/// en: 'Last'
	String get last => 'Last';

	/// en: 'Change'
	String get change => 'Change';

	/// en: 'Value'
	String get value => 'Value';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Saved daily goal'
	String get goal => 'Saved daily goal';

	/// en: 'Nutrition averages use days with food records only; zero values are included. Totals describe logged food, not necessarily complete days. Missing records are not zero. Workout totals include completed sets only; volume includes positive repetition loads only. Measurement changes use the first and last actual observations in this period. No interpolation or predicted measurements. Body charts show the last actual measurement of each day.'
	String get criteria => 'Nutrition averages use days with food records only; zero values are included. Totals describe logged food, not necessarily complete days. Missing records are not zero. Workout totals include completed sets only; volume includes positive repetition loads only. Measurement changes use the first and last actual observations in this period. No interpolation or predicted measurements. Body charts show the last actual measurement of each day.';

	/// en: 'Period in progress: only records available at generation are included.'
	String get partial => 'Period in progress: only records available at generation are included.';

	/// en: 'Units'
	String get units => 'Units';

	/// en: 'Completed sets by day'
	String get activityChart => 'Completed sets by day';

	/// en: 'Logged calories by day'
	String get calorieChart => 'Logged calories by day';

	/// en: 'Dots show recorded values. Missing days are left blank; no interpolation.'
	String get chartNote => 'Dots show recorded values. Missing days are left blank; no interpolation.';

	/// en: 'Local report · No medical or nutritional assessment'
	String get privacy => 'Local report · No medical or nutritional assessment';

	/// en: 'Report contents'
	String get selection => 'Report contents';

	/// en: 'Weight'
	String get weight => 'Weight';

	/// en: 'Create a progress report to save or share with your trainer or nutritionist.'
	String get configureDescription => 'Create a progress report to save or share with your trainer or nutritionist.';

	/// en: 'Period'
	String get period => 'Period';

	/// en: 'Period included in the report'
	String get includedPeriod => 'Period included in the report';

	/// en: 'Choose any day in the week to include.'
	String get weekReferenceHint => 'Choose any day in the week to include.';

	/// en: 'Choose any day in the month to include.'
	String get monthReferenceHint => 'Choose any day in the month to include.';

	/// en: 'Choose one or more sections to include in the PDF.'
	String get selectionHint => 'Choose one or more sections to include in the PDF.';

	/// en: 'PDF preview'
	String get previewTitle => 'PDF preview';
}

// Path: plateau
class Translations$plateau$en {
	Translations$plateau$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Possible plateaus'
	String get title => 'Possible plateaus';

	/// en: 'Last 8 weeks, only considering completed normal sets. The following are suggestions based on your data, but they may not be accurate.'
	String get intro => 'Last 8 weeks, only considering completed normal sets. The following are suggestions based on your data, but they may not be accurate.';

	/// en: 'Requires 6 comparable sessions over at least 28 days and 4 calendar weeks, the latest within 14 days, with no gaps over 21 days. The first 3 sessions provide the median reference. Progress means +2.5% load without fewer reps, +1 rep at equivalent load (±1%), or +5% volume. For bodyweight: +1 best-set rep or +5% total reps.'
	String get criteria => 'Requires 6 comparable sessions over at least 28 days and 4 calendar weeks, the latest within 14 days, with no gaps over 21 days. The first 3 sessions provide the median reference. Progress means +2.5% load without fewer reps, +1 rep at equivalent load (±1%), or +5% volume. For bodyweight: +1 best-set rep or +5% total reps.';

	/// en: 'Possible plateau'
	String get possiblePlateau => 'Possible plateau';

	/// en: 'No possible plateau detected'
	String get progressing => 'No possible plateau detected';

	/// en: 'More data needed: record at least 6 comparable sessions over 4 weeks.'
	String get insufficientData => 'More data needed: record at least 6 comparable sessions over 4 weeks.';

	/// en: 'No recent comparable sessions: resume recording this exercise before assessing progress.'
	String get stale => 'No recent comparable sessions: resume recording this exercise before assessing progress.';

	/// en: 'Not assessed: assistance, time and distance do not provide comparable load and repetition metrics.'
	String get unsupported => 'Not assessed: assistance, time and distance do not provide comparable load and repetition metrics.';

	/// en: 'Not assessed: exercise identity, definition or multiple sessions on the same day prevent a reliable comparison.'
	String get incomparable => 'Not assessed: exercise identity, definition or multiple sessions on the same day prevent a reliable comparison.';

	/// en: 'More data needed. Record completed sets across several weeks to assess your progress.'
	String get empty => 'More data needed. Record completed sets across several weeks to assess your progress.';

	/// en: 'Period'
	String get period => 'Period';

	/// en: 'Sessions'
	String get sessions => 'Sessions';

	/// en: 'Normal sets per session'
	String get sets => 'Normal sets per session';

	/// en: 'Reference: median of first 3 sessions'
	String get reference => 'Reference: median of first 3 sessions';

	/// en: 'Maximum load'
	String get load => 'Maximum load';

	/// en: 'Reps at maximum load'
	String get reps => 'Reps at maximum load';

	/// en: 'Maximum reps per set'
	String get bestReps => 'Maximum reps per set';

	/// en: 'Total reps'
	String get totalReps => 'Total reps';

	/// en: 'Session volume'
	String get volume => 'Session volume';

	/// en: 'Sessions used'
	String get data => 'Sessions used';

	/// en: 'Other exercises'
	String get other => 'Other exercises';

	/// en: 'Volume = sum of load × reps for the selected sets. Bodyweight is assessed using repetitions only.'
	String get volumeInfo => 'Volume = sum of load × reps for the selected sets. Bodyweight is assessed using repetitions only.';
}

// Path: progression
class Translations$progression$en {
	Translations$progression$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Guided progression'
	String get title => 'Guided progression';

	/// en: 'Set progression'
	String get configure => 'Set progression';

	/// en: 'Remove progression'
	String get remove => 'Remove progression';

	/// en: 'Last time'
	String get lastTime => 'Last time';

	/// en: 'Complete a session to see your last performance'
	String get noHistory => 'Complete a session to see your last performance';

	/// en: 'Today's goal'
	String get goal => 'Today\'s goal';

	/// en: 'Double progression'
	String get double => 'Double progression';

	/// en: 'Cyclic linear progression'
	String get cyclic => 'Cyclic linear progression';

	/// en: 'Minimum reps'
	String get minReps => 'Minimum reps';

	/// en: 'Maximum reps'
	String get maxReps => 'Maximum reps';

	/// en: 'Reps per step'
	String get repsPerStep => 'Reps per step';

	/// en: 'Starting weight'
	String get startingWeight => 'Starting weight';

	/// en: 'Weight increase per step'
	String get weightPerStep => 'Weight increase per step';

	/// en: 'Starting weight increase per cycle'
	String get weightPerCycle => 'Starting weight increase per cycle';

	/// en: 'Next goals'
	String get preview => 'Next goals';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Check the values and the number of working sets'
	String get invalid => 'Check the values and the number of working sets';

	/// en: 'Cycle $cycle, step $step'
	String step({required Object cycle, required Object step}) => 'Cycle ${cycle}, step ${step}';

	/// en: 'Advance manually'
	String get advance => 'Advance manually';
}

// Path: paywall
class Translations$paywall$en {
	Translations$paywall$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'GymBro Pro'
	String get title => 'GymBro Pro';

	/// en: 'Choose a subscription to unlock Pro features.'
	String get subtitle => 'Choose a subscription to unlock Pro features.';

	/// en: 'Subscriptions could not be loaded. Please try again.'
	String get loadError => 'Subscriptions could not be loaded. Please try again.';

	/// en: 'No subscriptions are available right now. Please try again later.'
	String get empty => 'No subscriptions are available right now. Please try again later.';

	late final Translations$paywall$trialPeriod$en trialPeriod = Translations$paywall$trialPeriod$en._(_root);
	late final Translations$paywall$autoRenewNotice$en autoRenewNotice = Translations$paywall$autoRenewNotice$en._(_root);
	late final Translations$paywall$purchaseError$en purchaseError = Translations$paywall$purchaseError$en._(_root);
	late final Translations$paywall$restoreError$en restoreError = Translations$paywall$restoreError$en._(_root);
	late final Translations$paywall$actions$en actions = Translations$paywall$actions$en._(_root);
}

// Path: routineImport
class Translations$routineImport$en {
	Translations$routineImport$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Program contents'
	String get summary => 'Program contents';

	/// en: 'Import a personal copy. The shared program stays unchanged.'
	String get summaryDescription => 'Import a personal copy. The shared program stays unchanged.';

	/// en: '(one) {1 training day} (other) {$n training days}'
	String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 training day',
		other: '${n} training days',
	);

	/// en: '(one) {1 exercise} (other) {$n exercises}'
	String exercises({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 exercise',
		other: '${n} exercises',
	);

	/// en: '(one) {1 set} (other) {$n sets}'
	String sets({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 set',
		other: '${n} sets',
	);

	/// en: 'Workout preview'
	String get preview => 'Workout preview';

	/// en: 'Training day'
	String get day => 'Training day';

	/// en: 'Choose a day to preview. The whole program will be imported.'
	String get dayDescription => 'Choose a day to preview. The whole program will be imported.';

	/// en: 'Program notes'
	String get programNotes => 'Program notes';

	/// en: 'Workout notes'
	String get workoutNotes => 'Workout notes';

	/// en: 'Exercises'
	String get exerciseList => 'Exercises';

	/// en: 'No exercises in this workout'
	String get emptyTitle => 'No exercises in this workout';

	/// en: 'This day has no prescribed exercises yet.'
	String get emptyDescription => 'This day has no prescribed exercises yet.';

	/// en: 'No sets prescribed'
	String get noSets => 'No sets prescribed';

	/// en: 'Custom exercise'
	String get custom => 'Custom exercise';

	/// en: 'Assistance'
	String get assistance => 'Assistance';

	/// en: '$duration rest'
	String rest({required Object duration}) => '${duration} rest';

	/// en: 'Set $number'
	String setNumber({required Object number}) => 'Set ${number}';

	/// en: '$count s'
	String seconds({required Object count}) => '${count} s';

	/// en: 'Opening shared program'
	String get loadingTitle => 'Opening shared program';

	/// en: 'Loading the workouts and their prescriptions.'
	String get loadingDescription => 'Loading the workouts and their prescriptions.';

	/// en: 'Program unavailable'
	String get unavailableTitle => 'Program unavailable';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: 'Importing shared routines requires Gym Bro Pro.'
	String get proRequired => 'Importing shared routines requires Gym Bro Pro.';

	/// en: 'Importing…'
	String get importing => 'Importing…';

	/// en: 'Something went wrong. Please try again shortly.'
	String get loadError => 'Something went wrong. Please try again shortly.';

	/// en: 'Unable to connect. Check your connection and try again.'
	String get networkError => 'Unable to connect. Check your connection and try again.';
}

// Path: set.kindShort
class Translations$set$kindShort$en {
	Translations$set$kindShort$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'W'
	String get warmUp => 'W';

	/// en: 'D'
	String get drop => 'D';

	/// en: 'F'
	String get failure => 'F';

	/// en: 'S'
	String get failureStripping => 'S';
}

// Path: set.kinds
class Translations$set$kinds$en {
	Translations$set$kinds$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	Map<String, String> get help => {
		'title': 'What\'s this?',
		'warmUp': 'A warm-up set is a light set of an exercise that you perform before the actual working sets. Its purpose is to prepare your muscles for the upcoming heavy work.',
		'normal': 'A normal set is a regular set of an exercise, where you perform a certain amount of reps with a certain weight.',
		'drop': 'A drop set is a set where you drop the weight after reaching failure and continue to perform reps with the lower weight.',
		'failure': 'A failure set is a set where you perform reps until you reach technical failure.',
		'failureStripping': 'A failure set with stripping is a kind of failure set that starts immediately after the previous set (without resting), in which you perform reps until you reach technical failure.',
	};
}

// Path: exercise.chart
class Translations$exercise$chart$en {
	Translations$exercise$chart$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exercise$chart$views$en views = Translations$exercise$chart$views$en._(_root);
}

// Path: exercise.fields
class Translations$exercise$fields$en {
	Translations$exercise$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Rest time'
	String get restTime => 'Rest time';

	/// en: 'Weight'
	String get weight => 'Weight';

	/// en: 'Time'
	String get time => 'Time';

	/// en: 'Reps'
	String get reps => 'Reps';

	/// en: 'Distance'
	String get distance => 'Distance';
}

// Path: exercise.actions
class Translations$exercise$actions$en {
	Translations$exercise$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '+ Add Set'
	String get addSet => '+ Add Set';
}

// Path: exercise.editor
class Translations$exercise$editor$en {
	Translations$exercise$editor$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exercise$editor$create$en create = Translations$exercise$editor$create$en._(_root);
	late final Translations$exercise$editor$edit$en edit = Translations$exercise$editor$edit$en._(_root);
	late final Translations$exercise$editor$fields$en fields = Translations$exercise$editor$fields$en._(_root);
	late final Translations$exercise$editor$cannotChangeParameters$en cannotChangeParameters = Translations$exercise$editor$cannotChangeParameters$en._(_root);
	late final Translations$exercise$editor$setless$en setless = Translations$exercise$editor$setless$en._(_root);
	late final Translations$exercise$editor$overwriteInWorkout$en overwriteInWorkout = Translations$exercise$editor$overwriteInWorkout$en._(_root);
	late final Translations$exercise$editor$advanced$en advanced = Translations$exercise$editor$advanced$en._(_root);
}

// Path: exercise.picker
class Translations$exercise$picker$en {
	Translations$exercise$picker$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select exercises'
	String get title => 'Select exercises';

	late final Translations$exercise$picker$errors$en errors = Translations$exercise$picker$errors$en._(_root);
	late final Translations$exercise$picker$filter$en filter = Translations$exercise$picker$filter$en._(_root);
}

// Path: exercise.info
class Translations$exercise$info$en {
	Translations$exercise$info$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exercise info'
	String get title => 'Exercise info';

	/// en: 'View workout'
	String get viewWorkout => 'View workout';

	/// en: 'You haven't performed this exercise yet.'
	String get noHistory => 'You haven\'t performed this exercise yet.';

	late final Translations$exercise$info$heaviestWeight$en heaviestWeight = Translations$exercise$info$heaviestWeight$en._(_root);
	late final Translations$exercise$info$best1rm$en best1rm = Translations$exercise$info$best1rm$en._(_root);
	late final Translations$exercise$info$bestSetVolume$en bestSetVolume = Translations$exercise$info$bestSetVolume$en._(_root);
	late final Translations$exercise$info$bestSessionVolume$en bestSessionVolume = Translations$exercise$info$bestSessionVolume$en._(_root);

	/// en: 'Useful data'
	String get usefulData => 'Useful data';

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'History'
	String get history => 'History';

	/// en: 'Explanation'
	String get explanation => 'Explanation';

	/// en: 'Note: this explanation is provided for reference only. Always consult a fitness professional.'
	String get explanationDisclaimer => 'Note: this explanation is provided for reference only. Always consult a fitness professional.';

	/// en: 'Muscle group: $muscleGroup'
	String primaryMuscleGroup({required Object muscleGroup}) => 'Muscle group: ${muscleGroup}';

	/// en: 'Secondary muscle groups: $muscleGroups'
	String secondaryMuscleGroups({required Object muscleGroups}) => 'Secondary muscle groups: ${muscleGroups}';

	/// en: 'Equipment: $equipment'
	String equipment({required Object equipment}) => 'Equipment: ${equipment}';

	late final Translations$exercise$info$explanationNone$en explanationNone = Translations$exercise$info$explanationNone$en._(_root);
}

// Path: exercise.continuation
class Translations$exercise$continuation$en {
	Translations$exercise$continuation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Continuation'
	String get label => 'Continuation';

	/// en: 'Tap to combine the two workouts into a single entry.'
	String get description => 'Tap to combine the two workouts into a single entry.';

	late final Translations$exercise$continuation$combine$en combine = Translations$exercise$continuation$combine$en._(_root);
}

// Path: exercise.delete
class Translations$exercise$delete$en {
	Translations$exercise$delete$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete exercise'
	String get title => 'Delete exercise';

	/// en: 'Are you sure you want to delete this exercise? This action cannot be undone.'
	String get body => 'Are you sure you want to delete this exercise? This action cannot be undone.';
}

// Path: workouts.actions
class Translations$workouts$actions$en {
	Translations$workouts$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$workouts$actions$delete$en delete = Translations$workouts$actions$delete$en._(_root);

	/// en: 'Redo this workout'
	String get start => 'Redo this workout';

	late final Translations$workouts$actions$edit$en edit = Translations$workouts$actions$edit$en._(_root);
	late final Translations$workouts$actions$editContinuation$en editContinuation = Translations$workouts$actions$editContinuation$en._(_root);
	late final Translations$workouts$actions$rename$en rename = Translations$workouts$actions$rename$en._(_root);
	late final Translations$workouts$actions$changeParent$en changeParent = Translations$workouts$actions$changeParent$en._(_root);
	late final Translations$workouts$actions$saveAsRoutine$en saveAsRoutine = Translations$workouts$actions$saveAsRoutine$en._(_root);

	/// en: 'Continue this workout'
	String get kContinue => 'Continue this workout';

	late final Translations$workouts$actions$share$en share = Translations$workouts$actions$share$en._(_root);
}

// Path: routines.quickWorkout
class Translations$routines$quickWorkout$en {
	Translations$routines$quickWorkout$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Free workout'
	String get title => 'Free workout';

	/// en: 'Start without a routine'
	String get subtitle => 'Start without a routine';

	/// en: 'You have reached the free workout limit. Continue with PRO.'
	String get proLimit => 'You have reached the free workout limit. Continue with PRO.';
}

// Path: routines.actions
class Translations$routines$actions$en {
	Translations$routines$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$routines$actions$delete$en delete = Translations$routines$actions$delete$en._(_root);

	/// en: 'Edit routine'
	String get edit => 'Edit routine';

	/// en: 'Start routine'
	String get start => 'Start routine';

	/// en: 'Create new routine'
	String get create => 'Create new routine';

	/// en: 'View history'
	String get viewHistory => 'View history';

	late final Translations$routines$actions$deleteFolder$en deleteFolder = Translations$routines$actions$deleteFolder$en._(_root);
}

// Path: routines.editor
class Translations$routines$editor$en {
	Translations$routines$editor$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$routines$editor$exercises$en exercises = Translations$routines$editor$exercises$en._(_root);
	late final Translations$routines$editor$fields$en fields = Translations$routines$editor$fields$en._(_root);
	late final Translations$routines$editor$superset$en superset = Translations$routines$editor$superset$en._(_root);
}

// Path: routines.loadError
class Translations$routines$loadError$en {
	Translations$routines$loadError$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unable to load routines'
	String get title => 'Unable to load routines';

	/// en: 'Try again to load your routines and folders.'
	String get text => 'Try again to load your routines and folders.';
}

// Path: history.actions
class Translations$history$actions$en {
	Translations$history$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$history$actions$deleteMultiple$en deleteMultiple = Translations$history$actions$deleteMultiple$en._(_root);
}

// Path: settings.diagnostics
class Translations$settings$diagnostics$en {
	Translations$settings$diagnostics$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Send diagnostic data'
	String get title => 'Send diagnostic data';

	/// en: 'Share errors, performance data, logs and sampled session recordings to help us improve the app. You can turn this off at any time.'
	String get description => 'Share errors, performance data, logs and sampled session recordings to help us improve the app. You can turn this off at any time.';

	/// en: 'Unable to update your preference. Please try again.'
	String get saveError => 'Unable to update your preference. Please try again.';
}

// Path: settings.options
class Translations$settings$options$en {
	Translations$settings$options$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$options$useDynamicColor$en useDynamicColor = Translations$settings$options$useDynamicColor$en._(_root);
	late final Translations$settings$options$color$en color = Translations$settings$options$color$en._(_root);
	late final Translations$settings$options$locale$en locale = Translations$settings$options$locale$en._(_root);
	late final Translations$settings$options$weightUnit$en weightUnit = Translations$settings$options$weightUnit$en._(_root);
	late final Translations$settings$options$distanceUnit$en distanceUnit = Translations$settings$options$distanceUnit$en._(_root);
	late final Translations$settings$options$showSuggestedRoutines$en showSuggestedRoutines = Translations$settings$options$showSuggestedRoutines$en._(_root);
	late final Translations$settings$options$import$en import = Translations$settings$options$import$en._(_root);
	late final Translations$settings$options$export$en export = Translations$settings$options$export$en._(_root);
	late final Translations$settings$options$themeMode$en themeMode = Translations$settings$options$themeMode$en._(_root);
	late final Translations$settings$options$notifications$en notifications = Translations$settings$options$notifications$en._(_root);
	late final Translations$settings$options$tintExercises$en tintExercises = Translations$settings$options$tintExercises$en._(_root);
	late final Translations$settings$options$defaultToSimpleWorkoutView$en defaultToSimpleWorkoutView = Translations$settings$options$defaultToSimpleWorkoutView$en._(_root);
	late final Translations$settings$options$exportSQL$en exportSQL = Translations$settings$options$exportSQL$en._(_root);

	/// en: 'Food search language'
	String get nutritionLanguage => 'Food search language';

	/// en: 'Food search country'
	String get nutritionCountry => 'Food search country';

	late final Translations$settings$options$health$en health = Translations$settings$options$health$en._(_root);
}

// Path: settings.colorPicker
class Translations$settings$colorPicker$en {
	Translations$settings$colorPicker$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$colorPicker$heading$en heading = Translations$settings$colorPicker$heading$en._(_root);
}

// Path: settings.advanced
class Translations$settings$advanced$en {
	Translations$settings$advanced$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Danger zone'
	String get title => 'Danger zone';

	/// en: 'Here be dragons'
	String get subtitle => 'Here be dragons';

	late final Translations$settings$advanced$options$en options = Translations$settings$advanced$options$en._(_root);
	late final Translations$settings$advanced$deleteAccount$en deleteAccount = Translations$settings$advanced$deleteAccount$en._(_root);
}

// Path: settings.panes
class Translations$settings$panes$en {
	Translations$settings$panes$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Units'
	String get units => 'Units';

	/// en: 'Permissions'
	String get permissions => 'Permissions';

	/// en: 'OpenFoodFacts'
	String get off => 'OpenFoodFacts';
}

// Path: settings.permissions
class Translations$settings$permissions$en {
	Translations$settings$permissions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tap to request permission'
	String get tapToRequest => 'Tap to request permission';
}

// Path: settings.pro
class Translations$settings$pro$en {
	Translations$settings$pro$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Manage your subscription'
	String get title => 'Manage your subscription';
}

// Path: settings.logoutWarning
class Translations$settings$logoutWarning$en {
	Translations$settings$logoutWarning$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign out?'
	String get title => 'Sign out?';

	/// en: 'You can always sign back in from the Profile tab.'
	String get content => 'You can always sign back in from the Profile tab.';
}

// Path: ongoingWorkout.actions
class Translations$ongoingWorkout$actions$en {
	Translations$ongoingWorkout$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Finish workout'
	String get finish => 'Finish workout';

	/// en: 'Cancel workout'
	String get cancel => 'Cancel workout';

	late final Translations$ongoingWorkout$actions$short$en short = Translations$ongoingWorkout$actions$short$en._(_root);

	/// en: 'Change weight unit'
	String get changeWeightUnit => 'Change weight unit';

	/// en: 'Change distance unit'
	String get changeDistanceUnit => 'Change distance unit';
}

// Path: ongoingWorkout.exercises
class Translations$ongoingWorkout$exercises$en {
	Translations$ongoingWorkout$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '+ Add exercise'
	String get add => '+ Add exercise';

	/// en: '+ Add superset'
	String get addSuperset => '+ Add superset';

	/// en: 'Replace exercise…'
	String get replace => 'Replace exercise…';

	/// en: 'Reorder exercises…'
	String get reorder => 'Reorder exercises…';

	/// en: 'Reorder sets…'
	String get reorderSets => 'Reorder sets…';

	/// en: 'Remove exercise'
	String get remove => 'Remove exercise';

	/// en: 'Add to superset…'
	String get addToSuperset => 'Add to superset…';

	/// en: 'Start interval timer'
	String get startCardioTimer => 'Start interval timer';

	/// en: 'RPE $rpe'
	String rpeBadge({required Object rpe}) => 'RPE ${rpe}';

	/// en: 'Set RPE'
	String get setRPE => 'Set RPE';

	/// en: 'Generate'
	String get generate => 'Generate';
}

// Path: ongoingWorkout.info
class Translations$ongoingWorkout$info$en {
	Translations$ongoingWorkout$info$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recording awaiting confirmation'
	String get recordingPending => 'Recording awaiting confirmation';

	/// en: 'Recording unavailable'
	String get recordingUnavailable => 'Recording unavailable';

	/// en: 'Time'
	String get time => 'Time';

	/// en: 'Reps'
	String get reps => 'Reps';

	/// en: 'Lifted weight'
	String get volume => 'Lifted weight';

	/// en: 'BPM'
	String get heartRate => 'BPM';

	/// en: 'KCAL'
	String get activeEnergy => 'KCAL';
}

// Path: ongoingWorkout.finish
class Translations$ongoingWorkout$finish$en {
	Translations$ongoingWorkout$finish$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Finish workout'
	String get title => 'Finish workout';

	late final Translations$ongoingWorkout$finish$fields$en fields = Translations$ongoingWorkout$finish$fields$en._(_root);

	/// en: 'Save workout'
	String get save => 'Save workout';

	/// en: 'Saving…'
	String get saving => 'Saving…';

	/// en: 'Unable to save the workout. Try again: your changes are still here.'
	String get saveError => 'Unable to save the workout. Try again: your changes are still here.';

	late final Translations$ongoingWorkout$finish$discard$en discard = Translations$ongoingWorkout$finish$discard$en._(_root);
}

// Path: ongoingWorkout.cancel
class Translations$ongoingWorkout$cancel$en {
	Translations$ongoingWorkout$cancel$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel workout?'
	String get title => 'Cancel workout?';

	/// en: 'You won't be able to undo this later if you change your mind.'
	String get text => 'You won\'t be able to undo this later if you change your mind.';

	late final Translations$ongoingWorkout$cancel$actions$en actions = Translations$ongoingWorkout$cancel$actions$en._(_root);
}

// Path: ongoingWorkout.overwrite
class Translations$ongoingWorkout$overwrite$en {
	Translations$ongoingWorkout$overwrite$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start workout?'
	String get title => 'Start workout?';

	/// en: 'Your current workout will be overwritten.'
	String get text => 'Your current workout will be overwritten.';

	late final Translations$ongoingWorkout$overwrite$actions$en actions = Translations$ongoingWorkout$overwrite$actions$en._(_root);
}

// Path: ongoingWorkout.superset
class Translations$ongoingWorkout$superset$en {
	Translations$ongoingWorkout$superset$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Replace with exercise'
	String get replaceWithExercise => 'Replace with exercise';

	/// en: 'Remove superset'
	String get remove => 'Remove superset';
}

// Path: ongoingWorkout.stopwatch
class Translations$ongoingWorkout$stopwatch$en {
	Translations$ongoingWorkout$stopwatch$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Stopwatch'
	String get label => 'Stopwatch';

	/// en: 'Start'
	String get start => 'Start';

	/// en: 'Pause'
	String get pause => 'Pause';

	/// en: 'Reset'
	String get reset => 'Reset';
}

// Path: ongoingWorkout.simple
class Translations$ongoingWorkout$simple$en {
	Translations$ongoingWorkout$simple$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Workout complete'
	String get completedTitle => 'Workout complete';

	/// en: 'All sets are complete. Save your workout or add another exercise.'
	String get completedDescription => 'All sets are complete. Save your workout or add another exercise.';

	/// en: 'Ready to train?'
	String get emptyTitle => 'Ready to train?';

	/// en: 'Add an exercise to start your session.'
	String get emptyDescription => 'Add an exercise to start your session.';

	/// en: '$current of $total'
	String exercisePosition({required Object current, required Object total}) => '${current} of ${total}';

	/// en: 'Set $current of $total'
	String setPosition({required Object current, required Object total}) => 'Set ${current} of ${total}';

	/// en: 'Custom'
	String get customExercise => 'Custom';

	/// en: 'Complete set'
	String get completeSet => 'Complete set';

	/// en: 'reps'
	String get repUnit => 'reps';

	/// en: 'Decrease $field'
	String decreaseValue({required Object field}) => 'Decrease ${field}';

	/// en: 'Increase $field'
	String increaseValue({required Object field}) => 'Increase ${field}';

	/// en: 'History and progression'
	String get historyAndProgression => 'History and progression';

	/// en: 'View your last session and targets'
	String get historySummary => 'View your last session and targets';

	/// en: 'Active progression · view targets'
	String get progressionSummary => 'Active progression · view targets';

	/// en: 'Next up:'
	String get nextUp => 'Next up:';

	/// en: 'Switch to full view'
	String get switchToFull => 'Switch to full view';

	/// en: 'Start rest timer'
	String get restTimer => 'Start rest timer';

	/// en: 'Set controls'
	String get setControls => 'Set controls';

	/// en: 'Previous set'
	String get previousSet => 'Previous set';

	/// en: 'Next set'
	String get nextSet => 'Next set';

	/// en: 'Set type'
	String get setKind => 'Set type';

	/// en: 'Edit set parameters'
	String get editSet => 'Edit set parameters';

	/// en: 'Superset notes'
	String get supersetNotes => 'Superset notes';

	/// en: 'Mark set as done'
	String get markAsDone => 'Mark set as done';

	/// en: 'Mark set as not done'
	String get markAsUndone => 'Mark set as not done';
}

// Path: ongoingWorkout.toolbox
class Translations$ongoingWorkout$toolbox$en {
	Translations$ongoingWorkout$toolbox$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tools'
	String get title => 'Tools';
}

// Path: ongoingWorkout.updateRoutine
class Translations$ongoingWorkout$updateRoutine$en {
	Translations$ongoingWorkout$updateRoutine$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Change routine?'
	String get differenceTitle => 'Change routine?';

	/// en: 'You've made changes to the workout. Do you want to save them to the routine?'
	String get differenceText => 'You\'ve made changes to the workout. Do you want to save them to the routine?';

	late final Translations$ongoingWorkout$updateRoutine$differences$en differences = Translations$ongoingWorkout$updateRoutine$differences$en._(_root);
}

// Path: ongoingWorkout.goodJob
class Translations$ongoingWorkout$goodJob$en {
	Translations$ongoingWorkout$goodJob$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Good job!'
	String get title => 'Good job!';

	/// en: 'Here's some statistics about the workout you've just finished.'
	String get body => 'Here\'s some statistics about the workout you\'ve just finished.';
}

// Path: ongoingWorkout.exercisesToSuperset
class Translations$ongoingWorkout$exercisesToSuperset$en {
	Translations$ongoingWorkout$exercisesToSuperset$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create new superset'
	String get title => 'Create new superset';

	/// en: 'Can't create superset'
	String get errorBannerTitle => 'Can\'t create superset';

	late final Translations$ongoingWorkout$exercisesToSuperset$errors$en errors = Translations$ongoingWorkout$exercisesToSuperset$errors$en._(_root);
}

// Path: exerciseList.fields
class Translations$exerciseList$fields$en {
	Translations$exerciseList$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '$weight $unit'
	String weight({required Object weight, required Object unit}) => '${weight} ${unit}';

	/// en: '$time'
	String time({required Object time}) => '${time}';

	/// en: '(zero) {0 reps} (one) {$n rep} (two) {$n reps} (few) {$n reps} (many) {$n reps} (other) {$n reps}'
	String reps({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: '0 reps',
		one: '${n} rep',
		two: '${n} reps',
		few: '${n} reps',
		many: '${n} reps',
		other: '${n} reps',
	);

	/// en: '$distance $unit'
	String distance({required Object distance, required Object unit}) => '${distance} ${unit}';

	/// en: 'RPE $rpe'
	String rpe({required Object rpe}) => 'RPE ${rpe}';
}

// Path: exerciseList.stats
class Translations$exerciseList$stats$en {
	Translations$exerciseList$stats$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Duration'
	String get time => 'Duration';

	/// en: 'Volume'
	String get volume => 'Volume';

	/// en: 'Distance'
	String get distance => 'Distance';

	/// en: 'Sets'
	String get sets => 'Sets';
}

// Path: exerciseList.workoutMuscleCategoriesBarChart
class Translations$exerciseList$workoutMuscleCategoriesBarChart$en {
	Translations$exerciseList$workoutMuscleCategoriesBarChart$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Muscle distribution (by number of sets)'
	String get label => 'Muscle distribution (by number of sets)';
}

// Path: exerciseList.workoutWeightDistributionBarChart
class Translations$exerciseList$workoutWeightDistributionBarChart$en {
	Translations$exerciseList$workoutWeightDistributionBarChart$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Muscle distribution (by lifted weight)'
	String get label => 'Muscle distribution (by lifted weight)';
}

// Path: exerciseList.workoutEquipmentDistributionBarChart
class Translations$exerciseList$workoutEquipmentDistributionBarChart$en {
	Translations$exerciseList$workoutEquipmentDistributionBarChart$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Equipment Distribution (by sets)'
	String get label => 'Equipment Distribution (by sets)';
}

// Path: general.dialogs
class Translations$general$dialogs$en {
	Translations$general$dialogs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$general$dialogs$actions$en actions = Translations$general$dialogs$actions$en._(_root);
}

// Path: titleGenerator.title
class Translations$titleGenerator$title$en {
	Translations$titleGenerator$title$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: ''
	String get zero => '';

	/// en: '$p0'
	String one({required Object p0}) => '${p0}';

	/// en: '$p0 and $p1'
	String two({required Object p0, required Object p1}) => '${p0} and ${p1}';

	/// en: '$p0, $p1, and $p2'
	String three({required Object p0, required Object p1, required Object p2}) => '${p0}, ${p1}, and ${p2}';

	/// en: '$p0, $p1, $p2, and $p3'
	String four({required Object p0, required Object p1, required Object p2, required Object p3}) => '${p0}, ${p1}, ${p2}, and ${p3}';

	/// en: '$p0, $p1, $p2, $p3, and $p4'
	String five({required Object p0, required Object p1, required Object p2, required Object p3, required Object p4}) => '${p0}, ${p1}, ${p2}, ${p3}, and ${p4}';

	/// en: '$p0, $p1, $p2, $p3, $p4, and $p5'
	String six({required Object p0, required Object p1, required Object p2, required Object p3, required Object p4, required Object p5}) => '${p0}, ${p1}, ${p2}, ${p3}, ${p4}, and ${p5}';
}

// Path: weightCalculator.weight
class Translations$weightCalculator$weight$en {
	Translations$weightCalculator$weight$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Total weight'
	String get label => 'Total weight';
}

// Path: weightCalculator.weights
class Translations$weightCalculator$weights$en {
	Translations$weightCalculator$weights$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Available weight plates'
	String get label => 'Available weight plates';
}

// Path: weightCalculator.barbells
class Translations$weightCalculator$barbells$en {
	Translations$weightCalculator$barbells$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Barbell'
	String get label => 'Barbell';
}

// Path: library.cardio
class Translations$library$cardio$en {
	Translations$library$cardio$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cardio'
	String get name => 'Cardio';

	late final Translations$library$cardio$exercises$en exercises = Translations$library$cardio$exercises$en._(_root);
}

// Path: library.chest
class Translations$library$chest$en {
	Translations$library$chest$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Chest'
	String get name => 'Chest';

	late final Translations$library$chest$exercises$en exercises = Translations$library$chest$exercises$en._(_root);
}

// Path: library.biceps
class Translations$library$biceps$en {
	Translations$library$biceps$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Biceps'
	String get name => 'Biceps';

	late final Translations$library$biceps$exercises$en exercises = Translations$library$biceps$exercises$en._(_root);
}

// Path: library.abs
class Translations$library$abs$en {
	Translations$library$abs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Abs'
	String get name => 'Abs';

	late final Translations$library$abs$exercises$en exercises = Translations$library$abs$exercises$en._(_root);
}

// Path: library.calves
class Translations$library$calves$en {
	Translations$library$calves$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Calves'
	String get name => 'Calves';

	late final Translations$library$calves$exercises$en exercises = Translations$library$calves$exercises$en._(_root);
}

// Path: library.quadriceps
class Translations$library$quadriceps$en {
	Translations$library$quadriceps$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Quadriceps'
	String get name => 'Quadriceps';

	late final Translations$library$quadriceps$exercises$en exercises = Translations$library$quadriceps$exercises$en._(_root);
}

// Path: library.hamstrings
class Translations$library$hamstrings$en {
	Translations$library$hamstrings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Hamstrings'
	String get name => 'Hamstrings';

	late final Translations$library$hamstrings$exercises$en exercises = Translations$library$hamstrings$exercises$en._(_root);
}

// Path: library.shoulders
class Translations$library$shoulders$en {
	Translations$library$shoulders$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Shoulders'
	String get name => 'Shoulders';

	late final Translations$library$shoulders$exercises$en exercises = Translations$library$shoulders$exercises$en._(_root);
}

// Path: library.back
class Translations$library$back$en {
	Translations$library$back$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Back'
	String get name => 'Back';

	late final Translations$library$back$exercises$en exercises = Translations$library$back$exercises$en._(_root);
	late final Translations$library$back$exercise$en exercise = Translations$library$back$exercise$en._(_root);
}

// Path: library.triceps
class Translations$library$triceps$en {
	Translations$library$triceps$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Triceps'
	String get name => 'Triceps';

	late final Translations$library$triceps$exercises$en exercises = Translations$library$triceps$exercises$en._(_root);
}

// Path: library.custom
class Translations$library$custom$en {
	Translations$library$custom$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Custom exercises'
	String get name => 'Custom exercises';
}

// Path: library.hips
class Translations$library$hips$en {
	Translations$library$hips$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$library$hips$exercises$en exercises = Translations$library$hips$exercises$en._(_root);

	/// en: 'Hips'
	String get name => 'Hips';
}

// Path: library.forearms
class Translations$library$forearms$en {
	Translations$library$forearms$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Forearms'
	String get name => 'Forearms';

	late final Translations$library$forearms$exercises$en exercises = Translations$library$forearms$exercises$en._(_root);
}

// Path: library.obliques
class Translations$library$obliques$en {
	Translations$library$obliques$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$library$obliques$exercises$en exercises = Translations$library$obliques$exercises$en._(_root);
}

// Path: library.other
class Translations$library$other$en {
	Translations$library$other$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Other'
	String get name => 'Other';

	late final Translations$library$other$exercises$en exercises = Translations$library$other$exercises$en._(_root);
}

// Path: library.glutes
class Translations$library$glutes$en {
	Translations$library$glutes$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$library$glutes$exercises$en exercises = Translations$library$glutes$exercises$en._(_root);

	/// en: 'Glutes'
	String get name => 'Glutes';
}

// Path: historyEditor.exercises
class Translations$historyEditor$exercises$en {
	Translations$historyEditor$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '+ Add superset'
	String get addSuperset => '+ Add superset';

	/// en: '+ Add exercise'
	String get add => '+ Add exercise';

	/// en: 'Reorder exercises'
	String get reorder => 'Reorder exercises';
}

// Path: historyEditor.info
class Translations$historyEditor$info$en {
	Translations$historyEditor$info$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reps'
	String get reps => 'Reps';

	/// en: 'Lifted weight'
	String get volume => 'Lifted weight';
}

// Path: historyEditor.actions
class Translations$historyEditor$actions$en {
	Translations$historyEditor$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Finish editing'
	String get finish => 'Finish editing';

	/// en: 'Change weight unit'
	String get changeWeightUnit => 'Change weight unit';

	/// en: 'Unsaved changes'
	String get discardChanges => 'Unsaved changes';

	/// en: 'This page contains unsaved changes. Do you wish to go back and discard your changes?'
	String get discardChangesContent => 'This page contains unsaved changes. Do you wish to go back and discard your changes?';
}

// Path: historyEditor.finish
class Translations$historyEditor$finish$en {
	Translations$historyEditor$finish$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Finish editing'
	String get title => 'Finish editing';

	late final Translations$historyEditor$finish$fields$en fields = Translations$historyEditor$finish$fields$en._(_root);
}

// Path: importRoutine.errors
class Translations$importRoutine$errors$en {
	Translations$importRoutine$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$importRoutine$errors$badJson$en badJson = Translations$importRoutine$errors$badJson$en._(_root);
	late final Translations$importRoutine$errors$noJson$en noJson = Translations$importRoutine$errors$noJson$en._(_root);
	late final Translations$importRoutine$errors$badWorkout$en badWorkout = Translations$importRoutine$errors$badWorkout$en._(_root);
}

// Path: importRoutine.import
class Translations$importRoutine$import$en {
	Translations$importRoutine$import$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Import'
	String get label => 'Import';

	/// en: 'The routine has been imported.'
	String get done => 'The routine has been imported.';
}

// Path: me.weight
class Translations$me$weight$en {
	Translations$me$weight$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weight'
	String get label => 'Weight';

	/// en: 'N/A'
	String get none => 'N/A';

	late final Translations$me$weight$allData$en allData = Translations$me$weight$allData$en._(_root);
	late final Translations$me$weight$measured$en measured = Translations$me$weight$measured$en._(_root);

	/// en: 'Add measurement'
	String get addMeasurement => 'Add measurement';
}

// Path: me.addWeight
class Translations$me$addWeight$en {
	Translations$me$addWeight$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$me$addWeight$time$en time = Translations$me$addWeight$time$en._(_root);
	late final Translations$me$addWeight$weight$en weight = Translations$me$addWeight$weight$en._(_root);
	late final Translations$me$addWeight$weightUnit$en weightUnit = Translations$me$addWeight$weightUnit$en._(_root);
	late final Translations$me$addWeight$errors$en errors = Translations$me$addWeight$errors$en._(_root);
}

// Path: me.allData
class Translations$me$allData$en {
	Translations$me$allData$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All recorded data'
	String get label => 'All recorded data';

	late final Translations$me$allData$removed$en removed = Translations$me$allData$removed$en._(_root);

	/// en: 'No data'
	String get none => 'No data';

	late final Translations$me$allData$predictedWeight$en predictedWeight = Translations$me$allData$predictedWeight$en._(_root);
}

// Path: me.calendar
class Translations$me$calendar$en {
	Translations$me$calendar$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Calendar'
	String get label => 'Calendar';

	/// en: 'You haven't worked out on this date'
	String get empty => 'You haven\'t worked out on this date';

	/// en: 'Streak'
	String get streak => 'Streak';

	/// en: 'Rest'
	String get rest => 'Rest';
}

// Path: me.stats
class Translations$me$stats$en {
	Translations$me$stats$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Statistics'
	String get label => 'Statistics';

	Map<String, String> get timeFrame => {
		'thirtyDays': 'Last 30 days',
		'threeMonths': 'Last 3 months',
		'year': 'Last year',
		'allTime': 'All time',
		'sevenDays': 'Last 7 days',
	};
	late final Translations$me$stats$workouts$en workouts = Translations$me$stats$workouts$en._(_root);
	late final Translations$me$stats$duration$en duration = Translations$me$stats$duration$en._(_root);
	late final Translations$me$stats$volume$en volume = Translations$me$stats$volume$en._(_root);
	late final Translations$me$stats$distance$en distance = Translations$me$stats$distance$en._(_root);
	late final Translations$me$stats$sets$en sets = Translations$me$stats$sets$en._(_root);

	/// en: 'Muscle groups'
	String get muscleCategory => 'Muscle groups';

	/// en: 'Equipment'
	String get gymEquipment => 'Equipment';

	/// en: 'At a glance'
	String get atAGlance => 'At a glance';

	/// en: 'Metrics'
	String get metrics => 'Metrics';

	late final Translations$me$stats$overview$en overview = Translations$me$stats$overview$en._(_root);
	late final Translations$me$stats$mainThree$en mainThree = Translations$me$stats$mainThree$en._(_root);
}

// Path: me.workoutDistribution
class Translations$me$workoutDistribution$en {
	Translations$me$workoutDistribution$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Workout distribution'
	String get label => 'Workout distribution';
}

// Path: me.profile
class Translations$me$profile$en {
	Translations$me$profile$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	/// en: 'Log out'
	String get logout => 'Log out';

	late final Translations$me$profile$edit$en edit = Translations$me$profile$edit$en._(_root);
	late final Translations$me$profile$errors$en errors = Translations$me$profile$errors$en._(_root);
}

// Path: me.sync
class Translations$me$sync$en {
	Translations$me$sync$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unsynced changes'
	String get label => 'Unsynced changes';

	/// en: 'Tap to sync your changes with the cloud.'
	String get subtitle => 'Tap to sync your changes with the cloud.';
}

// Path: me.trainer
class Translations$me$trainer$en {
	Translations$me$trainer$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Personal trainer'
	String get heading => 'Personal trainer';

	/// en: 'My trainer'
	String get title => 'My trainer';

	/// en: 'Manage your connection, training plans and shared routines.'
	String get subtitle => 'Manage your connection, training plans and shared routines.';
}

// Path: timeSeriesChart.noData
class Translations$timeSeriesChart$noData$en {
	Translations$timeSeriesChart$noData$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This chart contains no data'
	String get title => 'This chart contains no data';

	/// en: 'Start some workouts to see this data'
	String get subtitle => 'Start some workouts to see this data';
}

// Path: routineFormPicker.fields
class Translations$routineFormPicker$fields$en {
	Translations$routineFormPicker$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$routineFormPicker$fields$routine$en routine = Translations$routineFormPicker$fields$routine$en._(_root);
}

// Path: cardioTimer.setUp
class Translations$cardioTimer$setUp$en {
	Translations$cardioTimer$setUp$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Set up interval timer'
	String get title => 'Set up interval timer';

	/// en: 'Active time'
	String get active => 'Active time';

	/// en: 'Rest time'
	String get rest => 'Rest time';

	/// en: 'Section #$section'
	String section({required Object section}) => 'Section #${section}';

	/// en: 'Start interval timer'
	String get start => 'Start interval timer';

	/// en: '+ New section'
	String get addSection => '+ New section';

	late final Translations$cardioTimer$setUp$errors$en errors = Translations$cardioTimer$setUp$errors$en._(_root);
}

// Path: cardioTimer.confirmExit
class Translations$cardioTimer$confirmExit$en {
	Translations$cardioTimer$confirmExit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exit interval timer'
	String get title => 'Exit interval timer';

	/// en: 'Are you sure you want to leave? The current progress will be reset.'
	String get message => 'Are you sure you want to leave? The current progress will be reset.';
}

// Path: migrations.customToLibraryExercise
class Translations$migrations$customToLibraryExercise$en {
	Translations$migrations$customToLibraryExercise$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$customToLibraryExercise$fields$en fields = Translations$migrations$customToLibraryExercise$fields$en._(_root);

	/// en: 'Custom exercise to library exercise'
	String get title => 'Custom exercise to library exercise';

	/// en: 'Replace all occurrences of a custom exercise with a compatible library exercise'
	String get description => 'Replace all occurrences of a custom exercise with a compatible library exercise';

	late final Translations$migrations$customToLibraryExercise$preview$en preview = Translations$migrations$customToLibraryExercise$preview$en._(_root);
}

// Path: migrations.common
class Translations$migrations$common$en {
	Translations$migrations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$common$actions$en actions = Translations$migrations$common$actions$en._(_root);

	/// en: 'Migration preview'
	String get preview => 'Migration preview';

	/// en: 'Migration done!'
	String get migrated => 'Migration done!';
}

// Path: migrations.removeUnusedExercises
class Translations$migrations$removeUnusedExercises$en {
	Translations$migrations$removeUnusedExercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$removeUnusedExercises$preview$en preview = Translations$migrations$removeUnusedExercises$preview$en._(_root);

	/// en: 'Remove unused exercises'
	String get title => 'Remove unused exercises';

	/// en: 'Clean up your library by removing all custom exercises you haven't used'
	String get description => 'Clean up your library by removing all custom exercises you haven\'t used';
}

// Path: migrations.removeWeightFromCustomExercise
class Translations$migrations$removeWeightFromCustomExercise$en {
	Translations$migrations$removeWeightFromCustomExercise$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$removeWeightFromCustomExercise$preview$en preview = Translations$migrations$removeWeightFromCustomExercise$preview$en._(_root);
	late final Translations$migrations$removeWeightFromCustomExercise$fields$en fields = Translations$migrations$removeWeightFromCustomExercise$fields$en._(_root);

	/// en: 'Remove Weight parameter'
	String get title => 'Remove Weight parameter';

	/// en: 'Remove the Weight parameter from an exercise with "Reps and Weight" in which you've only ever used the Reps field.'
	String get description => 'Remove the Weight parameter from an exercise with "Reps and Weight" in which you\'ve only ever used the Reps field.';
}

// Path: migrations.genericMultiplyWeight
class Translations$migrations$genericMultiplyWeight$en {
	Translations$migrations$genericMultiplyWeight$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Multiply exercise weight by $multiplier'
	String title({required Object multiplier}) => 'Multiply exercise weight by ${multiplier}';

	late final Translations$migrations$genericMultiplyWeight$fields$en fields = Translations$migrations$genericMultiplyWeight$fields$en._(_root);
	late final Translations$migrations$genericMultiplyWeight$preview$en preview = Translations$migrations$genericMultiplyWeight$preview$en._(_root);
}

// Path: migrations.doubleExerciseWeight
class Translations$migrations$doubleExerciseWeight$en {
	Translations$migrations$doubleExerciseWeight$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Double exercise weight'
	String get title => 'Double exercise weight';

	/// en: 'Double the weight parameter in all occurrences of an exercise.'
	String get description => 'Double the weight parameter in all occurrences of an exercise.';
}

// Path: migrations.halveExerciseWeight
class Translations$migrations$halveExerciseWeight$en {
	Translations$migrations$halveExerciseWeight$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Halve exercise weight'
	String get title => 'Halve exercise weight';

	/// en: 'Halve the weight parameter in all occurrences of an exercise.'
	String get description => 'Halve the weight parameter in all occurrences of an exercise.';
}

// Path: exerciseFormPicker.fields
class Translations$exerciseFormPicker$fields$en {
	Translations$exerciseFormPicker$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exerciseFormPicker$fields$exercise$en exercise = Translations$exerciseFormPicker$fields$exercise$en._(_root);
}

// Path: exercises.none
class Translations$exercises$none$en {
	Translations$exercises$none$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No exercise'
	String get title => 'No exercise';

	/// en: 'Tap here to deselect everything and go back'
	String get subtitle => 'Tap here to deselect everything and go back';
}

// Path: food.home
class Translations$food$home$en {
	Translations$food$home$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Daily nutritional values'
	String get dailyNutritionalValues => 'Daily nutritional values';

	/// en: 'Calories'
	String get calories => 'Calories';

	/// en: 'Carbs'
	String get carbs => 'Carbs';

	/// en: 'Protein'
	String get protein => 'Protein';

	/// en: 'Fat'
	String get fat => 'Fat';

	/// en: 'Eaten'
	String get eaten => 'Eaten';

	/// en: 'Remaining'
	String get remainingCal => 'Remaining';

	/// en: 'Goal'
	String get goal => 'Goal';

	/// en: 'Over'
	String get overCal => 'Over';
}

// Path: food.searchBar
class Translations$food$searchBar$en {
	Translations$food$searchBar$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search history or food catalog…'
	String get hint => 'Search history or food catalog…';

	/// en: 'No results were found for "$query".'
	String noResults({required Object query}) => 'No results were found for "${query}".';

	/// en: 'No search history'
	String get noHistory => 'No search history';
}

// Path: food.add
class Translations$food$add$en {
	Translations$food$add$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Nutrition facts (per $amount g / $amount ml)'
	String nutritionalValuesPerAmountG({required Object amount}) => 'Nutrition facts (per ${amount} g / ${amount} ml)';

	/// en: 'Serving size'
	String get servingSize => 'Serving size';

	/// en: 'Custom amount'
	String get custom => 'Custom amount';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Amount (g or ml)'
	String get amountWithClarifiedUnit => 'Amount (g or ml)';

	/// en: 'The amount must not be empty'
	String get amountEmpty => 'The amount must not be empty';

	/// en: 'The amount must be a valid number'
	String get amountInvalid => 'The amount must be a valid number';

	/// en: '+ Add to tracker'
	String get add => '+ Add to tracker';

	/// en: 'Unknown serving'
	String get unnamedServingSize => 'Unknown serving';

	/// en: 'Nutrition facts (per $amount $unit)'
	String nutritionalValuesPerAmountWithUnit({required Object amount, required Object unit}) => 'Nutrition facts (per ${amount} ${unit})';

	late final Translations$food$add$customFood$en customFood = Translations$food$add$customFood$en._(_root);

	/// en: 'The name must not be empty'
	String get nameEmpty => 'The name must not be empty';

	/// en: 'Quantity'
	String get pieces => 'Quantity';
}

// Path: food.edit
class Translations$food$edit$en {
	Translations$food$edit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save'
	String get edit => 'Save';

	/// en: 'Copy to today'
	String get copyToToday => 'Copy to today';
}

// Path: food.addCustom
class Translations$food$addCustom$en {
	Translations$food$addCustom$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add custom'
	String get title => 'Add custom';
}

// Path: food.search
class Translations$food$search$en {
	Translations$food$search$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search results'
	String get title => 'Search results';

	late final Translations$food$search$error$en error = Translations$food$search$error$en._(_root);
}

// Path: food.barcodeReader
class Translations$food$barcodeReader$en {
	Translations$food$barcodeReader$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan barcode'
	String get title => 'Scan barcode';

	late final Translations$food$barcodeReader$scanResult$en scanResult = Translations$food$barcodeReader$scanResult$en._(_root);

	/// en: 'Enter barcode by hand'
	String get enterCode => 'Enter barcode by hand';

	late final Translations$food$barcodeReader$codeField$en codeField = Translations$food$barcodeReader$codeField$en._(_root);
}

// Path: food.addCustomFood
class Translations$food$addCustomFood$en {
	Translations$food$addCustomFood$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$food$addCustomFood$permission$en permission = Translations$food$addCustomFood$permission$en._(_root);
}

// Path: food.nutritionGoal
class Translations$food$nutritionGoal$en {
	Translations$food$nutritionGoal$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$food$nutritionGoal$effect$en effect = Translations$food$nutritionGoal$effect$en._(_root);
}

// Path: food.nutritionGoals
class Translations$food$nutritionGoals$en {
	Translations$food$nutritionGoals$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$food$nutritionGoals$change$en change = Translations$food$nutritionGoals$change$en._(_root);
	late final Translations$food$nutritionGoals$history$en history = Translations$food$nutritionGoals$history$en._(_root);
}

// Path: food.combine
class Translations$food$combine$en {
	Translations$food$combine$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create combined food'
	String get title => 'Create combined food';
}

// Path: food.categoryList
class Translations$food$categoryList$en {
	Translations$food$categoryList$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Could not save the category order. Please try again.'
	String get reorderFailed => 'Could not save the category order. Please try again.';

	/// en: '$percentage% of daily total – $calories'
	String dailyPercentage({required Object percentage, required Object calories}) => '${percentage}% of daily total – ${calories}';

	/// en: 'You haven't set up any categories'
	String get empty => 'You haven\'t set up any categories';

	late final Translations$food$categoryList$unmodifiable$en unmodifiable = Translations$food$categoryList$unmodifiable$en._(_root);

	/// en: 'Categories'
	String get title => 'Categories';

	/// en: 'Add'
	String get add => 'Add';
}

// Path: food.categoryEditor
class Translations$food$categoryEditor$en {
	Translations$food$categoryEditor$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$food$categoryEditor$title$en title = Translations$food$categoryEditor$title$en._(_root);

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Daily percentage'
	String get dailyPercentage => 'Daily percentage';

	late final Translations$food$categoryEditor$fields$en fields = Translations$food$categoryEditor$fields$en._(_root);

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Icon'
	String get icon => 'Icon';

	late final Translations$food$categoryEditor$effect$en effect = Translations$food$categoryEditor$effect$en._(_root);
	late final Translations$food$categoryEditor$nonFulfillingSum$en nonFulfillingSum = Translations$food$categoryEditor$nonFulfillingSum$en._(_root);
}

// Path: food.categoryFoods
class Translations$food$categoryFoods$en {
	Translations$food$categoryFoods$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You haven't added foods to this category yet.'
	String get empty => 'You haven\'t added foods to this category yet.';
}

// Path: food.permission
class Translations$food$permission$en {
	Translations$food$permission$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'We weren't able to get this permission. Would you like to open the permission settings?'
	String get denied => 'We weren\'t able to get this permission. Would you like to open the permission settings?';

	/// en: 'Open app settings'
	String get openSettings => 'Open app settings';

	/// en: 'An error has occurred.'
	String get error => 'An error has occurred.';
}

// Path: food.datePicker
class Translations$food$datePicker$en {
	Translations$food$datePicker$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';
}

// Path: food.catalog
class Translations$food$catalog$en {
	Translations$food$catalog$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Also submit to the catalog'
	String get submitAlso => 'Also submit to the catalog';

	/// en: 'Your contribution becomes public and remains available even after your account is deleted.'
	String get publicNotice => 'Your contribution becomes public and remains available even after your account is deleted.';

	/// en: 'Sign in to submit foods to the catalog. Saving to your diary remains available.'
	String get loginToSubmit => 'Sign in to submit foods to the catalog. Saving to your diary remains available.';

	/// en: 'Food is ready for your diary, but the catalog submission could not be queued.'
	String get queueFailed => 'Food is ready for your diary, but the catalog submission could not be queued.';

	/// en: 'Catalog submissions'
	String get submissions => 'Catalog submissions';

	/// en: 'You have not requested any catalog submissions yet.'
	String get noSubmissions => 'You have not requested any catalog submissions yet.';

	/// en: 'Could not load submissions.'
	String get loadFailed => 'Could not load submissions.';

	/// en: 'Retry submission'
	String get retry => 'Retry submission';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Report food'
	String get report => 'Report food';

	/// en: 'Sign in to report a food.'
	String get loginToReport => 'Sign in to report a food.';

	/// en: 'Details (optional)'
	String get details => 'Details (optional)';

	/// en: 'Please explain your report.'
	String get detailsRequired => 'Please explain your report.';

	/// en: 'Send report'
	String get sendReport => 'Send report';

	/// en: 'Report sent.'
	String get reportSent => 'Report sent.';

	/// en: 'Could not send the report. Please try again later.'
	String get reportFailed => 'Could not send the report. Please try again later.';

	Map<String, String> get reasons => {
		'spam': 'Spam',
		'inappropriate': 'Content inappropriate for Gym Bro',
		'nutrition': 'Incorrect nutritional values',
		'product': 'Incorrect product information or barcode',
		'duplicate': 'Duplicate food',
		'other': 'Other',
	};
	Map<String, String> get statuses => {
		'pending': 'Waiting to submit; retries automatically',
		'sending': 'Submitting',
		'failed': 'Submission failed: check the data and retry',
		'published': 'Published in the catalog',
		'duplicate': 'Already in the catalog',
		'correction': 'Correction submitted for review',
		'unavailable': 'Entry unavailable for publication',
		'cancelled': 'Submission cancelled',
		'cancelled_unknown': 'Retries cancelled; an earlier submission may already have been received',
		'already_present': 'Food already in the catalog',
		'uncertain': 'We cannot verify whether this food is already in the catalog.',
	};
}

// Path: food.picker
class Translations$food$picker$en {
	Translations$food$picker$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add food'
	String get title => 'Add food';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Barcode'
	String get barcode => 'Barcode';

	/// en: 'More'
	String get more => 'More';

	/// en: 'Added'
	String get added => 'Added';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Recent'
	String get recent => 'Recent';

	/// en: 'Catalog'
	String get results => 'Catalog';

	/// en: 'No foods found'
	String get empty => 'No foods found';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Operation failed. Please try again.'
	String get failed => 'Operation failed. Please try again.';

	/// en: 'Custom food with barcode'
	String get withBarcode => 'Custom food with barcode';

	/// en: 'Custom food without barcode'
	String get withoutBarcode => 'Custom food without barcode';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Save for me'
	String get savePrivate => 'Save for me';

	/// en: 'Add to catalog'
	String get share => 'Add to catalog';

	/// en: 'Food already in the catalog'
	String get alreadyPresent => 'Food already in the catalog';

	/// en: 'We cannot verify whether this food is already in the catalog.'
	String get uncertain => 'We cannot verify whether this food is already in the catalog.';

	/// en: 'Sharing queued for delivery'
	String get queued => 'Sharing queued for delivery';

	/// en: 'Food published in the catalog'
	String get published => 'Food published in the catalog';

	/// en: 'Food added'
	String get addedNotice => 'Food added';

	/// en: 'No foods added yet'
	String get noAdded => 'No foods added yet';

	/// en: 'Could not look up the barcode. Retry or enter a custom food.'
	String get lookupFailed => 'Could not look up the barcode. Retry or enter a custom food.';

	/// en: 'Enter food'
	String get custom => 'Enter food';

	/// en: 'Save shares this food in the public catalog. Save for me keeps it personal.'
	String get shareNotice => 'Save shares this food in the public catalog. Save for me keeps it personal.';

	/// en: 'Enter a valid barcode (4–32 digits).'
	String get invalidBarcode => 'Enter a valid barcode (4–32 digits).';

	/// en: 'Show more'
	String get showMore => 'Show more';
}

// Path: food.recipes
class Translations$food$recipes$en {
	Translations$food$recipes$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recipes'
	String get title => 'Recipes';

	/// en: 'New recipe'
	String get create => 'New recipe';

	/// en: 'Edit recipe'
	String get edit => 'Edit recipe';

	/// en: 'No saved recipes'
	String get empty => 'No saved recipes';

	/// en: 'Search recipes'
	String get search => 'Search recipes';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Cooking instructions'
	String get instructions => 'Cooking instructions';

	/// en: 'Servings'
	String get servings => 'Servings';

	/// en: 'Ingredients'
	String get ingredients => 'Ingredients';

	/// en: 'Add ingredient'
	String get addIngredient => 'Add ingredient';

	/// en: 'Ingredient weight'
	String get automaticMass => 'Ingredient weight';

	/// en: 'Final cooked weight (g, optional)'
	String get finalMass => 'Final cooked weight (g, optional)';

	/// en: 'Leave empty to use the sum of the ingredient weights.'
	String get massHint => 'Leave empty to use the sum of the ingredient weights.';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Per serving'
	String get perServing => 'Per serving';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Delete this recipe? Previously logged meals will stay unchanged.'
	String get deletePrompt => 'Delete this recipe? Previously logged meals will stay unchanged.';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Add to diary'
	String get add => 'Add to diary';

	/// en: 'Recipe'
	String get choose => 'Recipe';

	/// en: 'Grams'
	String get grams => 'Grams';

	/// en: 'Servings'
	String get portions => 'Servings';

	/// en: 'Equivalent weight (g, optional)'
	String get equivalentMass => 'Equivalent weight (g, optional)';

	/// en: 'Convert ml to g'
	String get liquidMass => 'Convert ml to g';

	/// en: 'You can enter the liquid weight in grams. Leave empty to use a conversion of 1 ml = 1 g.'
	String get liquidHint => 'You can enter the liquid weight in grams. Leave empty to use a conversion of 1 ml = 1 g.';

	/// en: 'Enter a valid positive value.'
	String get invalid => 'Enter a valid positive value.';

	/// en: 'Enter an integer from 1 to 32.'
	String get invalidServings => 'Enter an integer from 1 to 32.';

	/// en: 'Enter a name.'
	String get requiredName => 'Enter a name.';

	/// en: 'Add at least one ingredient.'
	String get requiredIngredients => 'Add at least one ingredient.';

	/// en: 'Could not complete the operation. Try again.'
	String get failed => 'Could not complete the operation. Try again.';

	/// en: 'The account changed. Reopen this screen.'
	String get accountChanged => 'The account changed. Reopen this screen.';

	/// en: 'Edit ingredient'
	String get editIngredient => 'Edit ingredient';

	/// en: 'Discard changes?'
	String get discard => 'Discard changes?';

	/// en: 'Unsaved changes will be lost.'
	String get discardBody => 'Unsaved changes will be lost.';

	/// en: 'Discard'
	String get discardAction => 'Discard';

	/// en: 'Recipe details'
	String get details => 'Recipe details';

	/// en: 'Yield and servings'
	String get yieldTitle => 'Yield and servings';

	/// en: 'Nutrition'
	String get nutrition => 'Nutrition';

	/// en: 'Choose foods and quantities to build your recipe.'
	String get ingredientsHint => 'Choose foods and quantities to build your recipe.';

	/// en: 'Decrease quantity'
	String get decreaseQuantity => 'Decrease quantity';

	/// en: 'Increase quantity'
	String get increaseQuantity => 'Increase quantity';
}

// Path: equipment.none
class Translations$equipment$none$en {
	Translations$equipment$none$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bodyweight'
	String get long => 'Bodyweight';

	/// en: 'Bodywt.'
	String get short => 'Bodywt.';
}

// Path: equipment.barbell
class Translations$equipment$barbell$en {
	Translations$equipment$barbell$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Barbell'
	String get long => 'Barbell';

	/// en: 'Barb.'
	String get short => 'Barb.';
}

// Path: equipment.dumbbell
class Translations$equipment$dumbbell$en {
	Translations$equipment$dumbbell$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dumbbells'
	String get long => 'Dumbbells';

	/// en: 'Dumbb.'
	String get short => 'Dumbb.';
}

// Path: equipment.cable
class Translations$equipment$cable$en {
	Translations$equipment$cable$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cables'
	String get long => 'Cables';

	/// en: 'Cables'
	String get short => 'Cables';
}

// Path: equipment.machine
class Translations$equipment$machine$en {
	Translations$equipment$machine$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Machine'
	String get long => 'Machine';

	/// en: 'Machine'
	String get short => 'Machine';
}

// Path: equipment.kettlebell
class Translations$equipment$kettlebell$en {
	Translations$equipment$kettlebell$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Kettlebell'
	String get long => 'Kettlebell';

	/// en: 'Kettleb.'
	String get short => 'Kettleb.';
}

// Path: equipment.plates
class Translations$equipment$plates$en {
	Translations$equipment$plates$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Plates'
	String get long => 'Plates';

	/// en: 'Plates'
	String get short => 'Plates';
}

// Path: equipment.resistanceBand
class Translations$equipment$resistanceBand$en {
	Translations$equipment$resistanceBand$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Resistance band'
	String get long => 'Resistance band';

	/// en: 'Res. band'
	String get short => 'Res. band';
}

// Path: equipment.suspensionBands
class Translations$equipment$suspensionBands$en {
	Translations$equipment$suspensionBands$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Suspension bands'
	String get long => 'Suspension bands';

	/// en: 'Susp. bands'
	String get short => 'Susp. bands';
}

// Path: equipment.landmine
class Translations$equipment$landmine$en {
	Translations$equipment$landmine$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Landmine platform'
	String get long => 'Landmine platform';

	/// en: 'Landmine'
	String get short => 'Landmine';
}

// Path: equipment.other
class Translations$equipment$other$en {
	Translations$equipment$other$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Other'
	String get long => 'Other';

	/// en: 'Other'
	String get short => 'Other';
}

// Path: achievements.firstSteps
class Translations$achievements$firstSteps$en {
	Translations$achievements$firstSteps$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'First steps'
	String get title => 'First steps';

	late final Translations$achievements$firstSteps$description$en description = Translations$achievements$firstSteps$description$en._(_root);
}

// Path: achievements.foodWatcher
class Translations$achievements$foodWatcher$en {
	Translations$achievements$foodWatcher$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Food blogger'
	String get title => 'Food blogger';

	late final Translations$achievements$foodWatcher$description$en description = Translations$achievements$foodWatcher$description$en._(_root);
}

// Path: achievements.marathoner
class Translations$achievements$marathoner$en {
	Translations$achievements$marathoner$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Marathoner'
	String get title => 'Marathoner';

	late final Translations$achievements$marathoner$description$en description = Translations$achievements$marathoner$description$en._(_root);
}

// Path: achievements.earlyBird
class Translations$achievements$earlyBird$en {
	Translations$achievements$earlyBird$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Early Bird'
	String get title => 'Early Bird';

	/// en: 'Start a workout before 8am'
	String get description => 'Start a workout before 8am';
}

// Path: achievements.nightOwl
class Translations$achievements$nightOwl$en {
	Translations$achievements$nightOwl$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Night Owl'
	String get title => 'Night Owl';

	/// en: 'Start a workout after 8pm'
	String get description => 'Start a workout after 8pm';
}

// Path: achievements.realGymBro
class Translations$achievements$realGymBro$en {
	Translations$achievements$realGymBro$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Real Gym Bro'
	String get title => 'Real Gym Bro';

	late final Translations$achievements$realGymBro$description$en description = Translations$achievements$realGymBro$description$en._(_root);
}

// Path: achievements.workoutFreak
class Translations$achievements$workoutFreak$en {
	Translations$achievements$workoutFreak$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Workout Freak'
	String get title => 'Workout Freak';

	late final Translations$achievements$workoutFreak$description$en description = Translations$achievements$workoutFreak$description$en._(_root);
}

// Path: achievements.trailblazer
class Translations$achievements$trailblazer$en {
	Translations$achievements$trailblazer$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Trailblazer'
	String get title => 'Trailblazer';

	late final Translations$achievements$trailblazer$description$en description = Translations$achievements$trailblazer$description$en._(_root);
}

// Path: achievements.cycleChampion
class Translations$achievements$cycleChampion$en {
	Translations$achievements$cycleChampion$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cycle Champion'
	String get title => 'Cycle Champion';

	late final Translations$achievements$cycleChampion$description$en description = Translations$achievements$cycleChampion$description$en._(_root);
}

// Path: achievements.professionalWeightlifter
class Translations$achievements$professionalWeightlifter$en {
	Translations$achievements$professionalWeightlifter$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Professional Weightlifter'
	String get title => 'Professional Weightlifter';

	late final Translations$achievements$professionalWeightlifter$description$en description = Translations$achievements$professionalWeightlifter$description$en._(_root);
}

// Path: achievements.programPlanner
class Translations$achievements$programPlanner$en {
	Translations$achievements$programPlanner$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Program Planner'
	String get title => 'Program Planner';

	/// en: 'Create three routines'
	String get description => 'Create three routines';
}

// Path: achievements.perfectPlanner
class Translations$achievements$perfectPlanner$en {
	Translations$achievements$perfectPlanner$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Perfect Planner'
	String get title => 'Perfect Planner';

	/// en: 'Create a routine folder'
	String get description => 'Create a routine folder';
}

// Path: achievements.routineMaster
class Translations$achievements$routineMaster$en {
	Translations$achievements$routineMaster$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Routine Master'
	String get title => 'Routine Master';

	late final Translations$achievements$routineMaster$description$en description = Translations$achievements$routineMaster$description$en._(_root);
}

// Path: achievements.intensityInnovator
class Translations$achievements$intensityInnovator$en {
	Translations$achievements$intensityInnovator$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Intensity Innovator'
	String get title => 'Intensity Innovator';

	/// en: 'Update a routine by increasing your weight/reps'
	String get description => 'Update a routine by increasing your weight/reps';
}

// Path: achievements.completionist
class Translations$achievements$completionist$en {
	Translations$achievements$completionist$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Completionist'
	String get title => 'Completionist';

	/// en: 'Try all library exercises at least once'
	String get description => 'Try all library exercises at least once';
}

// Path: achievements.notDrunk
class Translations$achievements$notDrunk$en {
	Translations$achievements$notDrunk$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'I'm not drunk, I swear!'
	String get title => 'I\'m not drunk, I swear!';

	/// en: 'Work out on a Sunday morning breaking a personal best in lifted weight or distance'
	String get description => 'Work out on a Sunday morning breaking a personal best in lifted weight or distance';
}

// Path: achievements.steamedHams
class Translations$achievements$steamedHams$en {
	Translations$achievements$steamedHams$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Set a new one-rep max personal record in a faster-than-usual workout'
	String get description => 'Set a new one-rep max personal record in a faster-than-usual workout';

	/// en: 'Steamed Hams'
	String get title => 'Steamed Hams';
}

// Path: achievements.swimsuitSeason
class Translations$achievements$swimsuitSeason$en {
	Translations$achievements$swimsuitSeason$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Swimsuit Season'
	String get title => 'Swimsuit Season';

	/// en: 'Do a total of 24 hours of cardio exercises from March to June of a year'
	String get description => 'Do a total of 24 hours of cardio exercises from March to June of a year';
}

// Path: achievements.pbBreaker
class Translations$achievements$pbBreaker$en {
	Translations$achievements$pbBreaker$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Personal Best Breaker'
	String get title => 'Personal Best Breaker';

	/// en: 'Set a new one-rep max personal record in one exercise'
	String get description => 'Set a new one-rep max personal record in one exercise';
}

// Path: achievements.sparta
class Translations$achievements$sparta$en {
	Translations$achievements$sparta$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This Is Sparta'
	String get title => 'This Is Sparta';

	late final Translations$achievements$sparta$description$en description = Translations$achievements$sparta$description$en._(_root);
}

// Path: achievements.midnightRain
class Translations$achievements$midnightRain$en {
	Translations$achievements$midnightRain$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start a workout before midnight and end it after midnight'
	String get description => 'Start a workout before midnight and end it after midnight';

	/// en: 'Midnight Rain'
	String get title => 'Midnight Rain';
}

// Path: achievements.equipmentSpecialist
class Translations$achievements$equipmentSpecialist$en {
	Translations$achievements$equipmentSpecialist$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create and follow a routine that exclusively uses specific equipment'
	String get description => 'Create and follow a routine that exclusively uses specific equipment';

	/// en: 'Equipment Specialist'
	String get title => 'Equipment Specialist';
}

// Path: achievements.bodyweightBeast
class Translations$achievements$bodyweightBeast$en {
	Translations$achievements$bodyweightBeast$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bodyweight Beast'
	String get title => 'Bodyweight Beast';

	/// en: 'Create a bodyweight-only routine and follow it for a month'
	String get description => 'Create a bodyweight-only routine and follow it for a month';
}

// Path: workoutGenerator.actions
class Translations$workoutGenerator$actions$en {
	Translations$workoutGenerator$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Generate'
	String get generate => 'Generate';
}

// Path: workoutGenerator.success
class Translations$workoutGenerator$success$en {
	Translations$workoutGenerator$success$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Workout successfully generated'
	String get title => 'Workout successfully generated';

	/// en: 'Undo'
	String get undo => 'Undo';
}

// Path: workoutGenerator.empty
class Translations$workoutGenerator$empty$en {
	Translations$workoutGenerator$empty$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Empty workout'
	String get title => 'Empty workout';

	/// en: 'Change your filters and try again'
	String get text => 'Change your filters and try again';
}

// Path: boutique.package
class Translations$boutique$package$en {
	Translations$boutique$package$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Install'
	String get install => 'Install';

	/// en: 'The package has been installed.'
	String get installed => 'The package has been installed.';
}

// Path: boutique.marketingUpdating
class Translations$boutique$marketingUpdating$en {
	Translations$boutique$marketingUpdating$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'We're modernizing the Routine store.'
	String get title => 'We\'re modernizing the Routine store.';

	/// en: 'Come back later for some exciting new programs!'
	String get description => 'Come back later for some exciting new programs!';
}

// Path: login.tabs
class Translations$login$tabs$en {
	Translations$login$tabs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in'
	String get signIn => 'Sign in';

	/// en: 'Sign up'
	String get signUp => 'Sign up';
}

// Path: login.errors
class Translations$login$errors$en {
	Translations$login$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'An unexpected error has occurred. Try again in a few minutes.'
	String get generic => 'An unexpected error has occurred. Try again in a few minutes.';

	/// en: 'Your username must be 8-10 characters long and can include only alphanumeric characters, hyphens, and underscores.'
	String get username => 'Your username must be 8-10 characters long and can include only alphanumeric characters, hyphens, and underscores.';

	/// en: 'This username is already taken.'
	String get usernameTaken => 'This username is already taken.';

	/// en: 'Enter a valid email address.'
	String get email => 'Enter a valid email address.';

	late final Translations$login$errors$password$en password = Translations$login$errors$password$en._(_root);

	/// en: 'No Internet connection.'
	String get noInternet => 'No Internet connection.';

	/// en: 'Enter your password.'
	String get passwordRequired => 'Enter your password.';

	/// en: 'Enter your password again.'
	String get confirmPasswordRequired => 'Enter your password again.';

	/// en: 'Passwords do not match.'
	String get passwordMismatch => 'Passwords do not match.';
}

// Path: login.fields
class Translations$login$fields$en {
	Translations$login$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$login$fields$email$en email = Translations$login$fields$email$en._(_root);
	late final Translations$login$fields$password$en password = Translations$login$fields$password$en._(_root);
	late final Translations$login$fields$username$en username = Translations$login$fields$username$en._(_root);
	late final Translations$login$fields$confirmPassword$en confirmPassword = Translations$login$fields$confirmPassword$en._(_root);
}

// Path: login.buttons
class Translations$login$buttons$en {
	Translations$login$buttons$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in'
	String get signIn => 'Sign in';

	/// en: 'Sign up'
	String get signUp => 'Sign up';

	/// en: 'Show password'
	String get showPassword => 'Show password';

	/// en: 'Hide password'
	String get hidePassword => 'Hide password';

	/// en: 'Dismiss keyboard'
	String get dismissKeyboard => 'Dismiss keyboard';
}

// Path: login.upsell
class Translations$login$upsell$en {
	Translations$login$upsell$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Not signed in'
	String get title => 'Not signed in';

	/// en: 'Sign in to gain access to group workouts, cross-device synchronization and much more.'
	String get subtitle => 'Sign in to gain access to group workouts, cross-device synchronization and much more.';
}

// Path: login.verifyEmail
class Translations$login$verifyEmail$en {
	Translations$login$verifyEmail$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'We've sent you a verification email'
	String get title => 'We\'ve sent you a verification email';

	/// en: 'Check your inbox to confirm your email. Once you're done, come back and tap the button to sign in.'
	String get description => 'Check your inbox to confirm your email. Once you\'re done, come back and tap the button to sign in.';

	/// en: 'I've verified my email'
	String get done => 'I\'ve verified my email';

	/// en: 'Verify your email address and try again.'
	String get notVerified => 'Verify your email address and try again.';
}

// Path: login.presentation
class Translations$login$presentation$en {
	Translations$login$presentation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in to Gym Bro'
	String get signInTitle => 'Sign in to Gym Bro';

	/// en: 'Pick up your workouts and keep your progress in sync.'
	String get signInSubtitle => 'Pick up your workouts and keep your progress in sync.';

	/// en: 'Create your profile'
	String get signUpTitle => 'Create your profile';

	/// en: 'Save your progress and share workouts with your friends.'
	String get signUpSubtitle => 'Save your progress and share workouts with your friends.';

	/// en: 'At least 8 characters, with an uppercase letter, a lowercase letter, a number and a special character.'
	String get passwordRequirements => 'At least 8 characters, with an uppercase letter, a lowercase letter, a number and a special character.';

	/// en: 'Don’t have an account?'
	String get noAccount => 'Don’t have an account?';

	/// en: 'Already have an account?'
	String get haveAccount => 'Already have an account?';
}

// Path: login.recovery
class Translations$login$recovery$en {
	Translations$login$recovery$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Forgot password?'
	String get forgot => 'Forgot password?';

	/// en: 'Reset your password'
	String get title => 'Reset your password';

	/// en: 'Enter your email and we’ll send you a link to choose a new password on the Gym Bro website.'
	String get description => 'Enter your email and we’ll send you a link to choose a new password on the Gym Bro website.';

	/// en: 'Send reset link'
	String get send => 'Send reset link';

	/// en: 'Check your email'
	String get sentTitle => 'Check your email';

	/// en: 'If an account exists for this address, you’ll receive a password reset link. After updating it on the website, come back here to sign in.'
	String get sentDescription => 'If an account exists for this address, you’ll receive a password reset link. After updating it on the website, come back here to sign in.';

	/// en: 'Check your spam folder too. If you can’t find the message, go back and try again.'
	String get checkSpam => 'Check your spam folder too. If you can’t find the message, go back and try again.';

	/// en: 'Back to sign in'
	String get backToSignIn => 'Back to sign in';

	/// en: 'We couldn’t send the link. Wait a few minutes and try again.'
	String get error => 'We couldn’t send the link. Wait a few minutes and try again.';
}

// Path: sync.conflict
class Translations$sync$conflict$en {
	Translations$sync$conflict$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Conflicting data found'
	String get title => 'Conflicting data found';

	/// en: 'Press OK to download the data in the cloud and overwrite the local data. Press Cancel to erase the data in the cloud and upload the local data.'
	String get message => 'Press OK to download the data in the cloud and overwrite the local data. Press Cancel to erase the data in the cloud and upload the local data.';
}

// Path: sync.overwrite
class Translations$sync$overwrite$en {
	Translations$sync$overwrite$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Older data found'
	String get title => 'Older data found';

	/// en: 'Do you wish to overwrite the data in the cloud with your local data?'
	String get message => 'Do you wish to overwrite the data in the cloud with your local data?';
}

// Path: onboarding.buttons
class Translations$onboarding$buttons$en {
	Translations$onboarding$buttons$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Skip for now'
	String get skip => 'Skip for now';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Let's start!'
	String get done => 'Let\'s start!';
}

// Path: onboarding.welcome
class Translations$onboarding$welcome$en {
	Translations$onboarding$welcome$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome to Gym Bro'
	String get title => 'Welcome to Gym Bro';

	/// en: 'Your workout buddy. We need to check a few permissions before starting.'
	String get text => 'Your workout buddy.\nWe need to check a few permissions before starting.';
}

// Path: onboarding.notifications
class Translations$onboarding$notifications$en {
	Translations$onboarding$notifications$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get title => 'Notifications';

	/// en: 'Allow Gym Bro to send you rest time notifications.'
	String get text => 'Allow Gym Bro to send you rest time notifications.';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Immediate notifications (for rest time)'
	String get exactAlarm => 'Immediate notifications (for rest time)';
}

// Path: onboarding.camera
class Translations$onboarding$camera$en {
	Translations$onboarding$camera$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Camera and gallery'
	String get title => 'Camera and gallery';

	/// en: 'Allow Gym Bro to access your camera in order to scan barcodes in the food tracker.'
	String get text => 'Allow Gym Bro to access your camera in order to scan barcodes in the food tracker.';

	/// en: 'Camera'
	String get camera => 'Camera';

	/// en: 'Gallery'
	String get gallery => 'Gallery';
}

// Path: onboarding.done
class Translations$onboarding$done$en {
	Translations$onboarding$done$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Get started'
	String get title => 'Get started';

	/// en: 'We hope you'll enjoy Gym Bro.'
	String get text => 'We hope you\'ll enjoy Gym Bro.';
}

// Path: onboarding.login
class Translations$onboarding$login$en {
	Translations$onboarding$login$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in'
	String get title => 'Sign in';

	/// en: 'Sync your data, see your friends' workouts, and much more!'
	String get text => 'Sync your data, see your friends\' workouts, and much more!';
}

// Path: feed.empty
class Translations$feed$empty$en {
	Translations$feed$empty$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your feed is empty'
	String get title => 'Your feed is empty';

	/// en: 'Start some workouts or log some meals to see them here.'
	String get text => 'Start some workouts or log some meals to see them here.';
}

// Path: feed.workout
class Translations$feed$workout$en {
	Translations$feed$workout$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$feed$workout$title$en title = Translations$feed$workout$title$en._(_root);
	late final Translations$feed$workout$subtitle$en subtitle = Translations$feed$workout$subtitle$en._(_root);
}

// Path: feed.achievement
class Translations$feed$achievement$en {
	Translations$feed$achievement$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$feed$achievement$title$en title = Translations$feed$achievement$title$en._(_root);
	late final Translations$feed$achievement$subtitle$en subtitle = Translations$feed$achievement$subtitle$en._(_root);
}

// Path: feed.userButton
class Translations$feed$userButton$en {
	Translations$feed$userButton$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading user profile...'
	String get loading => 'Loading user profile...';

	/// en: 'Unable to load profile'
	String get error => 'Unable to load profile';
}

// Path: feed.noSync
class Translations$feed$noSync$en {
	Translations$feed$noSync$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Syncing is paused: you are not connected to the Internet. It may take a few minutes. Don't worry, the data will be kept locally and transferred later.'
	String get text => 'Syncing is paused: you are not connected to the Internet. It may take a few minutes. Don\'t worry, the data will be kept locally and transferred later.';
}

// Path: feed.suggestions
class Translations$feed$suggestions$en {
	Translations$feed$suggestions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start'
	String get start => 'Start';

	/// en: 'Assigned by $name'
	String assignedBy({required Object name}) => 'Assigned by ${name}';

	/// en: 'Assigned by your trainer'
	String get assignedByTrainer => 'Assigned by your trainer';
}

// Path: feed.loadError
class Translations$feed$loadError$en {
	Translations$feed$loadError$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unable to load activities'
	String get title => 'Unable to load activities';

	/// en: 'Check your connection and try again.'
	String get text => 'Check your connection and try again.';
}

// Path: userProfile.cancelRequestConfirmation
class Translations$userProfile$cancelRequestConfirmation$en {
	Translations$userProfile$cancelRequestConfirmation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel friend request?'
	String get title => 'Cancel friend request?';

	/// en: 'Keep request'
	String get keep => 'Keep request';

	/// en: 'Cancel request'
	String get confirm => 'Cancel request';

	/// en: 'Could not cancel the friend request. Please try again.'
	String get error => 'Could not cancel the friend request. Please try again.';
}

// Path: userProfile.unfriendConfirmation
class Translations$userProfile$unfriendConfirmation$en {
	Translations$userProfile$unfriendConfirmation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unfriend $name?'
	String title({required Object name}) => 'Unfriend ${name}?';

	/// en: 'They will no longer appear in your feed, and you won't appear in theirs.'
	String get subtitle => 'They will no longer appear in your feed, and you won\'t appear in theirs.';

	/// en: 'Unfriend'
	String get confirm => 'Unfriend';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: userProfile.stats
class Translations$userProfile$stats$en {
	Translations$userProfile$stats$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Friends'
	String get friends => 'Friends';

	/// en: 'Workouts'
	String get workouts => 'Workouts';

	/// en: 'Achievements'
	String get achievements => 'Achievements';
}

// Path: userProfile.feed
class Translations$userProfile$feed$en {
	Translations$userProfile$feed$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$userProfile$feed$unavailable$en unavailable = Translations$userProfile$feed$unavailable$en._(_root);
}

// Path: userProfile.edit
class Translations$userProfile$edit$en {
	Translations$userProfile$edit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit Profile'
	String get tooltip => 'Edit Profile';

	/// en: 'Edit Profile'
	String get title => 'Edit Profile';

	/// en: 'Full Name'
	String get fullName => 'Full Name';

	/// en: 'Enter your full name'
	String get fullNameHint => 'Enter your full name';

	/// en: 'Profile Picture'
	String get profilePicture => 'Profile Picture';

	/// en: 'Change Picture'
	String get changePicture => 'Change Picture';

	/// en: 'Remove Picture'
	String get removePicture => 'Remove Picture';

	/// en: 'Uploading...'
	String get uploading => 'Uploading...';

	/// en: 'Saving...'
	String get saving => 'Saving...';

	/// en: 'Profile updated successfully!'
	String get success => 'Profile updated successfully!';

	/// en: 'Error updating profile'
	String get error => 'Error updating profile';

	/// en: 'Crop Photo'
	String get cropTitle => 'Crop Photo';

	/// en: 'Drag and pinch to position your photo'
	String get cropInstructions => 'Drag and pinch to position your photo';

	/// en: 'Done'
	String get done => 'Done';
}

// Path: userProfile.crop
class Translations$userProfile$crop$en {
	Translations$userProfile$crop$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$userProfile$crop$buttons$en buttons = Translations$userProfile$crop$buttons$en._(_root);
}

// Path: userProfile.error
class Translations$userProfile$error$en {
	Translations$userProfile$error$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error'
	String get title => 'Error';

	/// en: 'Retry'
	String get retry => 'Retry';
}

// Path: userProfile.errors
class Translations$userProfile$errors$en {
	Translations$userProfile$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You appear to be offline. Check your Internet connection and try again.'
	String get noInternet => 'You appear to be offline. Check your Internet connection and try again.';
}

// Path: friendRequests.empty
class Translations$friendRequests$empty$en {
	Translations$friendRequests$empty$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No friend requests'
	String get title => 'No friend requests';

	/// en: 'You don't have any pending friend requests right now.'
	String get text => 'You don\'t have any pending friend requests right now.';
}

// Path: profileSearch.noResults
class Translations$profileSearch$noResults$en {
	Translations$profileSearch$noResults$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No profiles found'
	String get title => 'No profiles found';

	/// en: 'Try searching for a different username.'
	String get text => 'Try searching for a different username.';
}

// Path: paywall.trialPeriod
class Translations$paywall$trialPeriod$en {
	Translations$paywall$trialPeriod$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '(one) {Free trial: $n week} (other) {Free trial: $n weeks}'
	String week({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Free trial: ${n} week',
		other: 'Free trial: ${n} weeks',
	);

	/// en: '(one) {Free trial: $n month} (other) {Free trial: $n months}'
	String month({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Free trial: ${n} month',
		other: 'Free trial: ${n} months',
	);

	/// en: '(one) {Free trial: $n year} (other) {Free trial: $n years}'
	String year({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Free trial: ${n} year',
		other: 'Free trial: ${n} years',
	);

	/// en: '(one) {Free trial: $n day} (other) {Free trial: $n days}'
	String day({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Free trial: ${n} day',
		other: 'Free trial: ${n} days',
	);
}

// Path: paywall.autoRenewNotice
class Translations$paywall$autoRenewNotice$en {
	Translations$paywall$autoRenewNotice$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Renews automatically at ${price} per week until cancelled.'
	String week({required Object price}) => 'Renews automatically at ${price} per week until cancelled.';

	/// en: 'Renews automatically at ${price} per month until cancelled.'
	String month({required Object price}) => 'Renews automatically at ${price} per month until cancelled.';

	/// en: 'Renews automatically at ${price} per year until cancelled.'
	String year({required Object price}) => 'Renews automatically at ${price} per year until cancelled.';

	/// en: 'Renews automatically at ${price} per day until cancelled.'
	String day({required Object price}) => 'Renews automatically at ${price} per day until cancelled.';
}

// Path: paywall.purchaseError
class Translations$paywall$purchaseError$en {
	Translations$paywall$purchaseError$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Purchase unsuccessful'
	String get title => 'Purchase unsuccessful';

	/// en: 'The purchase could not be completed. Please try again.'
	String get subtitle => 'The purchase could not be completed. Please try again.';
}

// Path: paywall.restoreError
class Translations$paywall$restoreError$en {
	Translations$paywall$restoreError$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Restore unsuccessful'
	String get title => 'Restore unsuccessful';

	/// en: 'Purchases could not be restored. Please try again.'
	String get subtitle => 'Purchases could not be restored. Please try again.';
}

// Path: paywall.actions
class Translations$paywall$actions$en {
	Translations$paywall$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Subscribe'
	String get subscribe => 'Subscribe';

	/// en: 'Restore purchases'
	String get restorePurchase => 'Restore purchases';

	/// en: 'Terms of service'
	String get termsOfService => 'Terms of service';

	/// en: 'Privacy policy'
	String get privacyPolicy => 'Privacy policy';
}

// Path: exercise.chart.views
class Translations$exercise$chart$views$en {
	Translations$exercise$chart$views$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Volume'
	String get volume => 'Volume';

	/// en: 'Reps'
	String get reps => 'Reps';

	/// en: 'Workout Duration'
	String get duration => 'Workout Duration';

	/// en: 'Time'
	String get time => 'Time';

	/// en: 'Distance'
	String get distance => 'Distance';

	/// en: 'Exertion rate'
	String get exertion => 'Exertion rate';

	/// en: 'The rate of exertion estimates the intensity of a workout by calculating the average of the lifted weight and the duration of the workout.'
	String get exertionInfo => 'The rate of exertion estimates the intensity of a workout by calculating the average of the lifted weight and the duration of the workout.';
}

// Path: exercise.editor.create
class Translations$exercise$editor$create$en {
	Translations$exercise$editor$create$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create new exercise'
	String get title => 'Create new exercise';
}

// Path: exercise.editor.edit
class Translations$exercise$editor$edit$en {
	Translations$exercise$editor$edit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit exercise'
	String get title => 'Edit exercise';
}

// Path: exercise.editor.fields
class Translations$exercise$editor$fields$en {
	Translations$exercise$editor$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exercise$editor$fields$title$en title = Translations$exercise$editor$fields$title$en._(_root);
	late final Translations$exercise$editor$fields$parameters$en parameters = Translations$exercise$editor$fields$parameters$en._(_root);
	late final Translations$exercise$editor$fields$primaryMuscleGroup$en primaryMuscleGroup = Translations$exercise$editor$fields$primaryMuscleGroup$en._(_root);
	late final Translations$exercise$editor$fields$secondaryMuscleGroups$en secondaryMuscleGroups = Translations$exercise$editor$fields$secondaryMuscleGroups$en._(_root);
	late final Translations$exercise$editor$fields$notes$en notes = Translations$exercise$editor$fields$notes$en._(_root);
	late final Translations$exercise$editor$fields$rpe$en rpe = Translations$exercise$editor$fields$rpe$en._(_root);
	late final Translations$exercise$editor$fields$reorderSets$en reorderSets = Translations$exercise$editor$fields$reorderSets$en._(_root);
	late final Translations$exercise$editor$fields$gymEquipment$en gymEquipment = Translations$exercise$editor$fields$gymEquipment$en._(_root);
}

// Path: exercise.editor.cannotChangeParameters
class Translations$exercise$editor$cannotChangeParameters$en {
	Translations$exercise$editor$cannotChangeParameters$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You cannot change the parameters of this exercise'
	String get title => 'You cannot change the parameters of this exercise';

	/// en: 'You can only change the parameters of an exercise you haven't performed yet.'
	String get text => 'You can only change the parameters of an exercise you haven\'t performed yet.';
}

// Path: exercise.editor.setless
class Translations$exercise$editor$setless$en {
	Translations$exercise$editor$setless$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You cannot change the parameters of this exercise'
	String get title => 'You cannot change the parameters of this exercise';

	/// en: 'Disable the "No sets" option to enable this field.'
	String get text => 'Disable the "No sets" option to enable this field.';
}

// Path: exercise.editor.overwriteInWorkout
class Translations$exercise$editor$overwriteInWorkout$en {
	Translations$exercise$editor$overwriteInWorkout$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This exercise appears in your ongoing workout'
	String get title => 'This exercise appears in your ongoing workout';

	/// en: 'You can modify it, but if you change the parameters you'll have to fill them in again. Do you want to continue?'
	String get body => 'You can modify it, but if you change the parameters you\'ll have to fill them in again. Do you want to continue?';
}

// Path: exercise.editor.advanced
class Translations$exercise$editor$advanced$en {
	Translations$exercise$editor$advanced$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exercise$editor$advanced$setless$en setless = Translations$exercise$editor$advanced$setless$en._(_root);

	/// en: 'Advanced'
	String get title => 'Advanced';
}

// Path: exercise.picker.errors
class Translations$exercise$picker$errors$en {
	Translations$exercise$picker$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You must select an exercise.'
	String get empty => 'You must select an exercise.';
}

// Path: exercise.picker.filter
class Translations$exercise$picker$filter$en {
	Translations$exercise$picker$filter$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Equipment'
	String get equipment => 'Equipment';
}

// Path: exercise.info.heaviestWeight
class Translations$exercise$info$heaviestWeight$en {
	Translations$exercise$info$heaviestWeight$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Heaviest weight'
	String get label => 'Heaviest weight';
}

// Path: exercise.info.best1rm
class Translations$exercise$info$best1rm$en {
	Translations$exercise$info$best1rm$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Best 1 Rep Max'
	String get label => 'Best 1 Rep Max';
}

// Path: exercise.info.bestSetVolume
class Translations$exercise$info$bestSetVolume$en {
	Translations$exercise$info$bestSetVolume$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Best set volume'
	String get label => 'Best set volume';
}

// Path: exercise.info.bestSessionVolume
class Translations$exercise$info$bestSessionVolume$en {
	Translations$exercise$info$bestSessionVolume$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Best session volume'
	String get label => 'Best session volume';
}

// Path: exercise.info.explanationNone
class Translations$exercise$info$explanationNone$en {
	Translations$exercise$info$explanationNone$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No explanation available'
	String get title => 'No explanation available';

	/// en: 'This exercise does not have an explanation available yet. Please check back later.'
	String get description => 'This exercise does not have an explanation available yet. Please check back later.';
}

// Path: exercise.continuation.combine
class Translations$exercise$continuation$combine$en {
	Translations$exercise$continuation$combine$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exercise$continuation$combine$confirm$en confirm = Translations$exercise$continuation$combine$confirm$en._(_root);
}

// Path: workouts.actions.delete
class Translations$workouts$actions$delete$en {
	Translations$workouts$actions$delete$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete workout'
	String get title => 'Delete workout';

	/// en: 'Are you sure you want to delete this workout? This action cannot be undone.'
	String get text => 'Are you sure you want to delete this workout? This action cannot be undone.';

	late final Translations$workouts$actions$delete$actions$en actions = Translations$workouts$actions$delete$actions$en._(_root);

	/// en: 'The workout has been deleted.'
	String get done => 'The workout has been deleted.';
}

// Path: workouts.actions.edit
class Translations$workouts$actions$edit$en {
	Translations$workouts$actions$edit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit workout'
	String get label => 'Edit workout';
}

// Path: workouts.actions.editContinuation
class Translations$workouts$actions$editContinuation$en {
	Translations$workouts$actions$editContinuation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit workout continuation'
	String get label => 'Edit workout continuation';
}

// Path: workouts.actions.rename
class Translations$workouts$actions$rename$en {
	Translations$workouts$actions$rename$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Rename workout'
	String get label => 'Rename workout';

	late final Translations$workouts$actions$rename$errors$en errors = Translations$workouts$actions$rename$errors$en._(_root);
}

// Path: workouts.actions.changeParent
class Translations$workouts$actions$changeParent$en {
	Translations$workouts$actions$changeParent$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Change base routine'
	String get label => 'Change base routine';

	late final Translations$workouts$actions$changeParent$options$en options = Translations$workouts$actions$changeParent$options$en._(_root);
}

// Path: workouts.actions.saveAsRoutine
class Translations$workouts$actions$saveAsRoutine$en {
	Translations$workouts$actions$saveAsRoutine$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save as routine'
	String get button => 'Save as routine';

	/// en: 'Successfully saved as routine'
	String get done => 'Successfully saved as routine';
}

// Path: workouts.actions.share
class Translations$workouts$actions$share$en {
	Translations$workouts$actions$share$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Share this routine'
	String get button => 'Share this routine';

	late final Translations$workouts$actions$share$alert$en alert = Translations$workouts$actions$share$alert$en._(_root);
}

// Path: routines.actions.delete
class Translations$routines$actions$delete$en {
	Translations$routines$actions$delete$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete routine'
	String get title => 'Delete routine';

	/// en: 'Are you sure you want to delete this routine? This action cannot be undone.'
	String get text => 'Are you sure you want to delete this routine? This action cannot be undone.';

	late final Translations$routines$actions$delete$actions$en actions = Translations$routines$actions$delete$actions$en._(_root);

	/// en: 'The routine has been deleted.'
	String get done => 'The routine has been deleted.';
}

// Path: routines.actions.deleteFolder
class Translations$routines$actions$deleteFolder$en {
	Translations$routines$actions$deleteFolder$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete folder'
	String get title => 'Delete folder';

	/// en: 'Are you sure you wish to delete this folder? This action cannot be undone. The routines in this folder will be moved to the home screen.'
	String get text => 'Are you sure you wish to delete this folder? This action cannot be undone. The routines in this folder will be moved to the home screen.';
}

// Path: routines.editor.exercises
class Translations$routines$editor$exercises$en {
	Translations$routines$editor$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exercises'
	String get title => 'Exercises';

	/// en: 'Add exercises'
	String get add => 'Add exercises';
}

// Path: routines.editor.fields
class Translations$routines$editor$fields$en {
	Translations$routines$editor$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$routines$editor$fields$name$en name = Translations$routines$editor$fields$name$en._(_root);
	late final Translations$routines$editor$fields$infobox$en infobox = Translations$routines$editor$fields$infobox$en._(_root);
}

// Path: routines.editor.superset
class Translations$routines$editor$superset$en {
	Translations$routines$editor$superset$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Superset'
	String get title => 'Superset';

	/// en: 'Add superset'
	String get add => 'Add superset';

	/// en: '(zero) {Superset without exercises} (one) {Superset with $n exercise} (two) {Superset with $n exercises} (few) {Superset with $n exercises} (many) {Superset with $n exercises} (other) {Superset with $n exercises}'
	String subtitle({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'Superset without exercises',
		one: 'Superset with ${n} exercise',
		two: 'Superset with ${n} exercises',
		few: 'Superset with ${n} exercises',
		many: 'Superset with ${n} exercises',
		other: 'Superset with ${n} exercises',
	);

	/// en: 'Add exercises'
	String get addExercise => 'Add exercises';

	late final Translations$routines$editor$superset$remove$en remove = Translations$routines$editor$superset$remove$en._(_root);
}

// Path: history.actions.deleteMultiple
class Translations$history$actions$deleteMultiple$en {
	Translations$history$actions$deleteMultiple$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '(one) {Delete exercise} (two) {Delete $n exercises} (few) {Delete $n exercises} (many) {Delete $n exercises} (other) {Delete $n exercises}'
	String title({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Delete exercise',
		two: 'Delete ${n} exercises',
		few: 'Delete ${n} exercises',
		many: 'Delete ${n} exercises',
		other: 'Delete ${n} exercises',
	);

	/// en: '(one) {Are you sure you want to delete this exercise from your history? This action cannot be undone.} (two) {Are you sure you want to delete these $n exercises from your history? This action cannot be undone.} (few) {Are you sure you want to delete these $n exercises from your history? This action cannot be undone.} (many) {Are you sure you want to delete these $n exercises from your history? This action cannot be undone.} (other) {Are you sure you want to delete these $n exercises from your history? This action cannot be undone.}'
	String text({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Are you sure you want to delete this exercise from your history? This action cannot be undone.',
		two: 'Are you sure you want to delete these ${n} exercises from your history? This action cannot be undone.',
		few: 'Are you sure you want to delete these ${n} exercises from your history? This action cannot be undone.',
		many: 'Are you sure you want to delete these ${n} exercises from your history? This action cannot be undone.',
		other: 'Are you sure you want to delete these ${n} exercises from your history? This action cannot be undone.',
	);

	late final Translations$history$actions$deleteMultiple$actions$en actions = Translations$history$actions$deleteMultiple$actions$en._(_root);

	/// en: '(one) {The exercise has been deleted from your history.} (two) {The exercises have been deleted from your history.} (few) {The exercises have been deleted from your history.} (many) {The exercises have been deleted from your history.} (other) {The exercises have been deleted from your history.}'
	String done({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'The exercise has been deleted from your history.',
		two: 'The exercises have been deleted from your history.',
		few: 'The exercises have been deleted from your history.',
		many: 'The exercises have been deleted from your history.',
		other: 'The exercises have been deleted from your history.',
	);
}

// Path: settings.options.useDynamicColor
class Translations$settings$options$useDynamicColor$en {
	Translations$settings$options$useDynamicColor$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Use dynamic color'
	String get label => 'Use dynamic color';
}

// Path: settings.options.color
class Translations$settings$options$color$en {
	Translations$settings$options$color$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App color'
	String get label => 'App color';
}

// Path: settings.options.locale
class Translations$settings$options$locale$en {
	Translations$settings$options$locale$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App language'
	String get label => 'App language';

	late final Translations$settings$options$locale$values$en values = Translations$settings$options$locale$values$en._(_root);
}

// Path: settings.options.weightUnit
class Translations$settings$options$weightUnit$en {
	Translations$settings$options$weightUnit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weight unit'
	String get label => 'Weight unit';
}

// Path: settings.options.distanceUnit
class Translations$settings$options$distanceUnit$en {
	Translations$settings$options$distanceUnit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Distance unit'
	String get label => 'Distance unit';
}

// Path: settings.options.showSuggestedRoutines
class Translations$settings$options$showSuggestedRoutines$en {
	Translations$settings$options$showSuggestedRoutines$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Show suggested routines'
	String get label => 'Show suggested routines';
}

// Path: settings.options.import
class Translations$settings$options$import$en {
	Translations$settings$options$import$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Successfully imported data'
	String get success => 'Successfully imported data';

	late final Translations$settings$options$import$failed$en failed = Translations$settings$options$import$failed$en._(_root);

	/// en: 'Import data'
	String get label => 'Import data';

	late final Translations$settings$options$import$utils$en utils = Translations$settings$options$import$utils$en._(_root);
	late final Translations$settings$options$import$types$en types = Translations$settings$options$import$types$en._(_root);
}

// Path: settings.options.export
class Translations$settings$options$export$en {
	Translations$settings$options$export$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Export data (JSON)'
	String get label => 'Export data (JSON)';

	/// en: 'GymBro_Data'
	String get filename => 'GymBro_Data';

	late final Translations$settings$options$export$failed$en failed = Translations$settings$options$export$failed$en._(_root);
}

// Path: settings.options.themeMode
class Translations$settings$options$themeMode$en {
	Translations$settings$options$themeMode$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Theme'
	String get label => 'Theme';

	Map<String, String> get values => {
		'system': 'System',
		'light': 'Light',
		'dark': 'Dark',
	};
}

// Path: settings.options.notifications
class Translations$settings$options$notifications$en {
	Translations$settings$options$notifications$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notification status'
	String get label => 'Notification status';

	late final Translations$settings$options$notifications$subtitle$en subtitle = Translations$settings$options$notifications$subtitle$en._(_root);
}

// Path: settings.options.tintExercises
class Translations$settings$options$tintExercises$en {
	Translations$settings$options$tintExercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tint exercise pages'
	String get label => 'Tint exercise pages';

	/// en: 'Apply the category color to exercise and category pages'
	String get subtitle => 'Apply the category color to exercise and category pages';
}

// Path: settings.options.defaultToSimpleWorkoutView
class Translations$settings$options$defaultToSimpleWorkoutView$en {
	Translations$settings$options$defaultToSimpleWorkoutView$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Use simplified workout view by default'
	String get label => 'Use simplified workout view by default';

	/// en: 'Open the compact workout screen when starting or resuming a workout'
	String get subtitle => 'Open the compact workout screen when starting or resuming a workout';
}

// Path: settings.options.exportSQL
class Translations$settings$options$exportSQL$en {
	Translations$settings$options$exportSQL$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Export the full Gym Bro database. It cannot be imported back later (but your data won't be deleted).'
	String get text => 'Export the full Gym Bro database. It cannot be imported back later (but your data won\'t be deleted).';

	/// en: 'Export full database (SQL)'
	String get label => 'Export full database (SQL)';
}

// Path: settings.options.health
class Translations$settings$options$health$en {
	Translations$settings$options$health$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Health and Vitals'
	String get label => 'Health and Vitals';
}

// Path: settings.colorPicker.heading
class Translations$settings$colorPicker$heading$en {
	Translations$settings$colorPicker$heading$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select a color [$color]'
	String label({required Object color}) => 'Select a color [${color}]';
}

// Path: settings.advanced.options
class Translations$settings$advanced$options$en {
	Translations$settings$advanced$options$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$advanced$options$logs$en logs = Translations$settings$advanced$options$logs$en._(_root);
	late final Translations$settings$advanced$options$migrations$en migrations = Translations$settings$advanced$options$migrations$en._(_root);
	late final Translations$settings$advanced$options$backups$en backups = Translations$settings$advanced$options$backups$en._(_root);
	late final Translations$settings$advanced$options$sync$en sync = Translations$settings$advanced$options$sync$en._(_root);
}

// Path: settings.advanced.deleteAccount
class Translations$settings$advanced$deleteAccount$en {
	Translations$settings$advanced$deleteAccount$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete your account'
	String get title => 'Delete your account';

	late final Translations$settings$advanced$deleteAccount$warning$en warning = Translations$settings$advanced$deleteAccount$warning$en._(_root);
	late final Translations$settings$advanced$deleteAccount$confirmation$en confirmation = Translations$settings$advanced$deleteAccount$confirmation$en._(_root);

	/// en: 'Deleting...'
	String get deleting => 'Deleting...';
}

// Path: ongoingWorkout.actions.short
class Translations$ongoingWorkout$actions$short$en {
	Translations$ongoingWorkout$actions$short$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Resume'
	String get resume => 'Resume';
}

// Path: ongoingWorkout.finish.fields
class Translations$ongoingWorkout$finish$fields$en {
	Translations$ongoingWorkout$finish$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$ongoingWorkout$finish$fields$name$en name = Translations$ongoingWorkout$finish$fields$name$en._(_root);
	late final Translations$ongoingWorkout$finish$fields$startingTime$en startingTime = Translations$ongoingWorkout$finish$fields$startingTime$en._(_root);
	late final Translations$ongoingWorkout$finish$fields$parent$en parent = Translations$ongoingWorkout$finish$fields$parent$en._(_root);
	late final Translations$ongoingWorkout$finish$fields$duration$en duration = Translations$ongoingWorkout$finish$fields$duration$en._(_root);
	late final Translations$ongoingWorkout$finish$fields$infobox$en infobox = Translations$ongoingWorkout$finish$fields$infobox$en._(_root);
}

// Path: ongoingWorkout.finish.discard
class Translations$ongoingWorkout$finish$discard$en {
	Translations$ongoingWorkout$finish$discard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Discard changes?'
	String get title => 'Discard changes?';

	/// en: 'Your changes to the summary will be discarded. The workout will remain in progress.'
	String get text => 'Your changes to the summary will be discarded. The workout will remain in progress.';

	/// en: 'Keep editing'
	String get keep => 'Keep editing';

	/// en: 'Discard changes'
	String get confirm => 'Discard changes';
}

// Path: ongoingWorkout.cancel.actions
class Translations$ongoingWorkout$cancel$actions$en {
	Translations$ongoingWorkout$cancel$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Don't cancel'
	String get no => 'Don\'t cancel';

	/// en: 'Cancel workout'
	String get yes => 'Cancel workout';
}

// Path: ongoingWorkout.overwrite.actions
class Translations$ongoingWorkout$overwrite$actions$en {
	Translations$ongoingWorkout$overwrite$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get no => 'Cancel';

	/// en: 'Start'
	String get yes => 'Start';
}

// Path: ongoingWorkout.updateRoutine.differences
class Translations$ongoingWorkout$updateRoutine$differences$en {
	Translations$ongoingWorkout$updateRoutine$differences$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '(zero) {No exercises added} (one) {1 exercise added} (two) {$n exercises added} (few) {$n exercises added} (many) {$n exercises added} (other) {$n exercises added}'
	String added({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'No exercises added',
		one: '1 exercise added',
		two: '${n} exercises added',
		few: '${n} exercises added',
		many: '${n} exercises added',
		other: '${n} exercises added',
	);

	/// en: '(zero) {No exercises removed} (one) {1 exercise removed} (two) {$n exercises removed} (few) {$n exercises removed} (many) {$n exercises removed} (other) {$n exercises removed}'
	String removed({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'No exercises removed',
		one: '1 exercise removed',
		two: '${n} exercises removed',
		few: '${n} exercises removed',
		many: '${n} exercises removed',
		other: '${n} exercises removed',
	);

	/// en: '(zero) {No exercises changed} (one) {1 exercise changed} (two) {$n exercises changed} (few) {$n exercises changed} (many) {$n exercises changed} (other) {$n exercises changed}'
	String changed({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'No exercises changed',
		one: '1 exercise changed',
		two: '${n} exercises changed',
		few: '${n} exercises changed',
		many: '${n} exercises changed',
		other: '${n} exercises changed',
	);

	/// en: '(zero) {No exercises reordered} (one) {1 exercise reordered} (two) {$n exercises reordered} (few) {$n exercises reordered} (many) {$n exercises reordered} (other) {$n exercises reordered}'
	String reordered({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'No exercises reordered',
		one: '1 exercise reordered',
		two: '${n} exercises reordered',
		few: '${n} exercises reordered',
		many: '${n} exercises reordered',
		other: '${n} exercises reordered',
	);

	/// en: 'Routine name or notes changed'
	String get metadata => 'Routine name or notes changed';
}

// Path: ongoingWorkout.exercisesToSuperset.errors
class Translations$ongoingWorkout$exercisesToSuperset$errors$en {
	Translations$ongoingWorkout$exercisesToSuperset$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You can only add exercises that are next to each other.'
	String get addingNonContiguous => 'You can only add exercises that are next to each other.';

	/// en: 'You can only unselect the first or last exercise.'
	String get removingMiddle => 'You can only unselect the first or last exercise.';

	/// en: 'You must select an exercise.'
	String get notExercise => 'You must select an exercise.';

	/// en: 'You must select at least two exercises.'
	String get tooFew => 'You must select at least two exercises.';

	/// en: 'The selected exercises must have the same number of sets.'
	String get differingSets => 'The selected exercises must have the same number of sets.';
}

// Path: general.dialogs.actions
class Translations$general$dialogs$actions$en {
	Translations$general$dialogs$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Close'
	String get close => 'Close';
}

// Path: library.cardio.exercises
class Translations$library$cardio$exercises$en {
	Translations$library$cardio$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Burpees'
	String get burpees => 'Burpees';

	/// en: 'Squat thrusts (without jump)'
	String get squatThrusts => 'Squat thrusts (without jump)';

	/// en: 'Jumping jacks'
	String get jumpingJacks => 'Jumping jacks';

	/// en: 'High knees (running in place)'
	String get highKnees => 'High knees (running in place)';

	/// en: 'Butt kicks (running in place)'
	String get buttKicks => 'Butt kicks (running in place)';

	/// en: 'Skater jumps'
	String get skaterJumps => 'Skater jumps';

	/// en: 'Jump squats'
	String get squatJumps => 'Jump squats';

	/// en: 'Plank jacks'
	String get plankJacks => 'Plank jacks';

	/// en: 'Aerobics'
	String get aerobics => 'Aerobics';

	/// en: 'Biking'
	String get biking => 'Biking';

	/// en: 'Upright exercise bike'
	String get ergometer => 'Upright exercise bike';

	/// en: 'Recumbent exercise bike'
	String get ergometerHorizontal => 'Recumbent exercise bike';

	/// en: 'Pilates'
	String get pilates => 'Pilates';

	/// en: 'Running'
	String get running => 'Running';

	/// en: 'Treadmill'
	String get treadmill => 'Treadmill';

	/// en: 'Zumba'
	String get zumba => 'Zumba';

	/// en: 'Jump rope'
	String get jumpRope => 'Jump rope';

	/// en: 'Rowing machine'
	String get rowingMachine => 'Rowing machine';

	/// en: 'Bicycle crunches (timed)'
	String get bicycleCrunchesCardio => 'Bicycle crunches (timed)';

	/// en: 'Crunches (timed)'
	String get crunchesTimed => 'Crunches (timed)';

	/// en: 'Straddle jumps'
	String get straddleJumps => 'Straddle jumps';

	/// en: 'Forward and backward steps'
	String get forwardAndBackwardSteps => 'Forward and backward steps';

	/// en: 'Bear crawl'
	String get bearCrawl => 'Bear crawl';

	/// en: 'Elliptical cycling'
	String get ellipticalCycling => 'Elliptical cycling';

	/// en: 'Burpee (dumbbell)'
	String get burpeeDumbbell => 'Burpee (dumbbell)';

	/// en: 'Partial knee bends'
	String get partialKneeBends => 'Partial knee bends';

	/// en: 'Arm-cycle ergometer'
	String get armCycleErgometer => 'Arm-cycle ergometer';

	/// en: 'Wall-supported high knees'
	String get wallSupportedHighKnees => 'Wall-supported high knees';

	/// en: 'Burpee with jumping jack'
	String get burpeeWithJumpingJack => 'Burpee with jumping jack';

	/// en: 'Jumping-jack hops'
	String get jumpingJackHops => 'Jumping-jack hops';

	/// en: 'Push-up into running start'
	String get pushUpIntoRunningStart => 'Push-up into running start';

	/// en: 'Scissor jumps'
	String get scissorJumps => 'Scissor jumps';

	/// en: 'Squat (semi, jump)'
	String get squatSemiJump => 'Squat (semi, jump)';

	/// en: 'Short-stride running'
	String get shortStrideRunning => 'Short-stride running';

	/// en: 'SkiErg double-pole pull'
	String get skiergDoublePolePull => 'SkiErg double-pole pull';

	/// en: 'Alternating ski steps'
	String get alternatingSkiSteps => 'Alternating ski steps';

	/// en: 'Explosive star jumps'
	String get explosiveStarJumps => 'Explosive star jumps';

	/// en: 'Kettlebell circular swing'
	String get kettlebellCircularSwing => 'Kettlebell circular swing';

	/// en: 'Elliptical trainer walking'
	String get ellipticalTrainerWalking => 'Elliptical trainer walking';

	/// en: 'Lunge (walking, high knee)'
	String get lungeWalkingHighKnee => 'Lunge (walking, high knee)';

	/// en: 'Incline treadmill walking'
	String get inclineTreadmillWalking => 'Incline treadmill walking';

	/// en: 'Stair-climber stepping'
	String get stairClimberStepping => 'Stair-climber stepping';

	/// en: 'Repeated sprint intervals'
	String get repeatedSprintIntervals => 'Repeated sprint intervals';
}

// Path: library.chest.exercises
class Translations$library$chest$exercises$en {
	Translations$library$chest$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Incline machine chest press'
	String get inclineMachineChestPress => 'Incline machine chest press';

	/// en: 'Chest-height cable fly'
	String get midHeightCableFly => 'Chest-height cable fly';

	/// en: 'Bench press (barbell)'
	String get barbellBenchPressFlat => 'Bench press (barbell)';

	/// en: 'Bench press (barbell, incline)'
	String get barbellBenchPressIncline => 'Bench press (barbell, incline)';

	/// en: 'Bench press (barbell, decline)'
	String get barbellBenchPressDecline => 'Bench press (barbell, decline)';

	/// en: 'Bench press (dumbbell)'
	String get dumbbellBenchPressFlat => 'Bench press (dumbbell)';

	/// en: 'Bench press (dumbbell, incline)'
	String get dumbbellBenchPressIncline => 'Bench press (dumbbell, incline)';

	/// en: 'Bench press (dumbbell, decline)'
	String get dumbbellBenchPressDecline => 'Bench press (dumbbell, decline)';

	/// en: 'Bench press (Smith machine)'
	String get smithMachineBenchPressFlat => 'Bench press (Smith machine)';

	/// en: 'Bench press (Smith machine, incline)'
	String get smithMachineBenchPressIncline => 'Bench press (Smith machine, incline)';

	/// en: 'Bench press (Smith machine, decline)'
	String get smithMachineBenchPressDecline => 'Bench press (Smith machine, decline)';

	/// en: 'Bench press (cables)'
	String get cableBenchPressFlat => 'Bench press (cables)';

	/// en: 'Bench press (cables, incline)'
	String get cableBenchPressIncline => 'Bench press (cables, incline)';

	/// en: 'Bench press (cables, decline)'
	String get cableBenchPressDecline => 'Bench press (cables, decline)';

	/// en: 'Pec deck fly'
	String get butterflyMachine => 'Pec deck fly';

	/// en: 'Dumbbell hex press'
	String get dumbbellHexPress => 'Dumbbell hex press';

	/// en: 'Smith machine hex press'
	String get smithMachineHexPress => 'Smith machine hex press';

	/// en: 'Seated cable chest flyes'
	String get seatedCableChestFlys => 'Seated cable chest flyes';

	/// en: 'Vertical chest press'
	String get verticalChestPress => 'Vertical chest press';

	/// en: 'High cable fly'
	String get cableFlyCrossovers => 'High cable fly';

	/// en: 'Push-ups'
	String get pushUps => 'Push-ups';

	/// en: 'Push-ups (weighted)'
	String get pushUpsWeighted => 'Push-ups (weighted)';

	/// en: 'Cable chest press'
	String get cableChestPress => 'Cable chest press';

	/// en: 'Decline push-ups'
	String get declinePushUps => 'Decline push-ups';

	/// en: 'Low cable fly'
	String get lowCableFly => 'Low cable fly';

	/// en: 'Incline push-ups'
	String get inclinePushUps => 'Incline push-ups';

	/// en: 'Landmine press'
	String get tBarPress => 'Landmine press';

	/// en: 'Incline bench flyes'
	String get inclineBenchFlys => 'Incline bench flyes';

	/// en: 'Bench flyes'
	String get benchFlys => 'Bench flyes';

	/// en: 'Push-up (archer)'
	String get pushUpArcher => 'Push-up (archer)';

	/// en: 'Chest dip (assisted, kneeling)'
	String get chestDipAssistedKneeling => 'Chest dip (assisted, kneeling)';

	/// en: 'Pectoralis major stretch (assisted, seated, stability ball)'
	String get pectoralisMajorStretchAssistedSeatedStabilityBall => 'Pectoralis major stretch (assisted, seated, stability ball)';

	/// en: 'Chest dip (assisted, wide grip, kneeling)'
	String get chestDipAssistedWideGripKneeling => 'Chest dip (assisted, wide grip, kneeling)';

	/// en: 'Bench press (band)'
	String get benchPressBand => 'Bench press (band)';

	/// en: 'Chest press (band, one arm, twisting)'
	String get chestPressBandOneArmTwisting => 'Chest press (band, one arm, twisting)';

	/// en: 'Pullover (barbell, decline)'
	String get pulloverBarbellDecline => 'Pullover (barbell, decline)';

	/// en: 'Press (barbell, decline, wide grip)'
	String get pressBarbellDeclineWideGrip => 'Press (barbell, decline, wide grip)';

	/// en: 'Bench press (barbell, guillotine)'
	String get benchPressBarbellGuillotine => 'Bench press (barbell, guillotine)';

	/// en: 'Bench press (barbell, reverse grip, decline)'
	String get benchPressBarbellReverseGripDecline => 'Bench press (barbell, reverse grip, decline)';

	/// en: 'Bench press (barbell, reverse grip, incline)'
	String get benchPressBarbellReverseGripIncline => 'Bench press (barbell, reverse grip, incline)';

	/// en: 'Bench press (barbell, wide)'
	String get benchPressBarbellWide => 'Bench press (barbell, wide)';

	/// en: 'Bench press (barbell, wide, reverse grip)'
	String get benchPressBarbellWideReverseGrip => 'Bench press (barbell, wide, reverse grip)';

	/// en: 'Chest stretch (behind head)'
	String get chestStretchBehindHead => 'Chest stretch (behind head)';

	/// en: 'Seated butterfly stretch'
	String get seatedButterflyStretch => 'Seated butterfly stretch';

	/// en: 'Press (cable, decline, one arm)'
	String get pressCableDeclineOneArm => 'Press (cable, decline, one arm)';

	/// en: 'Fly (cable, incline)'
	String get flyCableIncline => 'Fly (cable, incline)';

	/// en: 'Fly (cable, incline, stability ball)'
	String get flyCableInclineStabilityBall => 'Fly (cable, incline, stability ball)';

	/// en: 'Fly (cable, lying)'
	String get flyCableLying => 'Fly (cable, lying)';

	/// en: 'Chest fly (cable, one arm, decline)'
	String get chestFlyCableOneArmDecline => 'Chest fly (cable, one arm, decline)';

	/// en: 'Fly (cable, one arm, exercise ball)'
	String get flyCableOneArmExerciseBall => 'Fly (cable, one arm, exercise ball)';

	/// en: 'Fly (cable, one arm, incline, exercise ball)'
	String get flyCableOneArmInclineExerciseBall => 'Fly (cable, one arm, incline, exercise ball)';

	/// en: 'Press (cable, one arm, incline)'
	String get pressCableOneArmIncline => 'Press (cable, one arm, incline)';

	/// en: 'Press (cable, one arm, incline, exercise ball)'
	String get pressCableOneArmInclineExerciseBall => 'Press (cable, one arm, incline, exercise ball)';

	/// en: 'Press (cable, one arm, exercise ball)'
	String get pressCableOneArmExerciseBall => 'Press (cable, one arm, exercise ball)';

	/// en: 'Press (cable, exercise ball)'
	String get pressCableExerciseBall => 'Press (cable, exercise ball)';

	/// en: 'Chest and anterior shoulder stretch'
	String get chestAndAnteriorShoulderStretch => 'Chest and anterior shoulder stretch';

	/// en: 'Chest dip'
	String get chestDip => 'Chest dip';

	/// en: 'Chest dip (straight bar)'
	String get chestDipStraightBar => 'Chest dip (straight bar)';

	/// en: 'Chest stretch (exercise ball)'
	String get chestStretchExerciseBall => 'Chest stretch (exercise ball)';

	/// en: 'Push-up (chest tap)'
	String get pushUpChestTap => 'Push-up (chest tap)';

	/// en: 'Push-up (clap)'
	String get pushUpClap => 'Push-up (clap)';

	/// en: 'Push-up with alternating side reach'
	String get pushUpWithAlternatingSideReach => 'Push-up with alternating side reach';

	/// en: 'Push-up (deep)'
	String get pushUpDeep => 'Push-up (deep)';

	/// en: 'Push-up (drop)'
	String get pushUpDrop => 'Push-up (drop)';

	/// en: 'Fly (dumbbell, decline)'
	String get flyDumbbellDecline => 'Fly (dumbbell, decline)';

	/// en: 'Bench press (dumbbell, decline, neutral grip)'
	String get benchPressDumbbellDeclineNeutralGrip => 'Bench press (dumbbell, decline, neutral grip)';

	/// en: 'Fly (dumbbell, decline, one arm)'
	String get flyDumbbellDeclineOneArm => 'Fly (dumbbell, decline, one arm)';

	/// en: 'Fly (dumbbell, decline, twisting)'
	String get flyDumbbellDeclineTwisting => 'Fly (dumbbell, decline, twisting)';

	/// en: 'Fly (dumbbell, exercise ball)'
	String get flyDumbbellExerciseBall => 'Fly (dumbbell, exercise ball)';

	/// en: 'Bench press (dumbbell, incline, alternate)'
	String get benchPressDumbbellInclineAlternate => 'Bench press (dumbbell, incline, alternate)';

	/// en: 'Fly (dumbbell, incline, exercise ball)'
	String get flyDumbbellInclineExerciseBall => 'Fly (dumbbell, incline, exercise ball)';

	/// en: 'Bench press (dumbbell, incline, neutral grip)'
	String get benchPressDumbbellInclineNeutralGrip => 'Bench press (dumbbell, incline, neutral grip)';

	/// en: 'Fly (dumbbell, incline, one arm)'
	String get flyDumbbellInclineOneArm => 'Fly (dumbbell, incline, one arm)';

	/// en: 'Fly (dumbbell, incline, one arm, exercise ball)'
	String get flyDumbbellInclineOneArmExerciseBall => 'Fly (dumbbell, incline, one arm, exercise ball)';

	/// en: 'Press (dumbbell, incline, one arm)'
	String get pressDumbbellInclineOneArm => 'Press (dumbbell, incline, one arm)';

	/// en: 'Press (dumbbell, incline, one arm, exercise ball)'
	String get pressDumbbellInclineOneArmExerciseBall => 'Press (dumbbell, incline, one arm, exercise ball)';

	/// en: 'Press (dumbbell, incline, exercise ball)'
	String get pressDumbbellInclineExerciseBall => 'Press (dumbbell, incline, exercise ball)';

	/// en: 'Shoulder raise (dumbbell, incline)'
	String get shoulderRaiseDumbbellIncline => 'Shoulder raise (dumbbell, incline)';

	/// en: 'Fly (dumbbell, incline, twisting)'
	String get flyDumbbellInclineTwisting => 'Fly (dumbbell, incline, twisting)';

	/// en: 'Press (dumbbell, lying, neutral grip)'
	String get pressDumbbellLyingNeutralGrip => 'Press (dumbbell, lying, neutral grip)';

	/// en: 'Press (dumbbell, lying, one arm)'
	String get pressDumbbellLyingOneArm => 'Press (dumbbell, lying, one arm)';

	/// en: 'Pullover (dumbbell, exercise ball)'
	String get pulloverDumbbellExerciseBall => 'Pullover (dumbbell, exercise ball)';

	/// en: 'Bench press (dumbbell, neutral grip)'
	String get benchPressDumbbellNeutralGrip => 'Bench press (dumbbell, neutral grip)';

	/// en: 'Fly (dumbbell, one arm, bench)'
	String get flyDumbbellOneArmBench => 'Fly (dumbbell, one arm, bench)';

	/// en: 'Chest fly (dumbbell, one arm, exercise ball)'
	String get chestFlyDumbbellOneArmExerciseBall => 'Chest fly (dumbbell, one arm, exercise ball)';

	/// en: 'Chest press (dumbbell, one arm, decline)'
	String get chestPressDumbbellOneArmDecline => 'Chest press (dumbbell, one arm, decline)';

	/// en: 'Chest press (dumbbell, one arm, incline)'
	String get chestPressDumbbellOneArmIncline => 'Chest press (dumbbell, one arm, incline)';

	/// en: 'Press (dumbbell, one arm, exercise ball)'
	String get pressDumbbellOneArmExerciseBall => 'Press (dumbbell, one arm, exercise ball)';

	/// en: 'Pullover (dumbbell, one arm, exercise ball)'
	String get pulloverDumbbellOneArmExerciseBall => 'Pullover (dumbbell, one arm, exercise ball)';

	/// en: 'Press (dumbbell, one arm, reverse grip)'
	String get pressDumbbellOneArmReverseGrip => 'Press (dumbbell, one arm, reverse grip)';

	/// en: 'Fly (dumbbell, one leg, exercise ball)'
	String get flyDumbbellOneLegExerciseBall => 'Fly (dumbbell, one leg, exercise ball)';

	/// en: 'Press (dumbbell, exercise ball)'
	String get pressDumbbellExerciseBall => 'Press (dumbbell, exercise ball)';

	/// en: 'Bench press (dumbbell, reverse)'
	String get benchPressDumbbellReverse => 'Bench press (dumbbell, reverse)';

	/// en: 'Bench press (dumbbell, twisting)'
	String get benchPressDumbbellTwisting => 'Bench press (dumbbell, twisting)';

	/// en: 'Dynamic pectoral stretch'
	String get dynamicPectoralStretch => 'Dynamic pectoral stretch';

	/// en: 'Supine elbow press-up'
	String get supineElbowPressUp => 'Supine elbow press-up';

	/// en: 'Pike push up (exercise ball)'
	String get pikePushUpExerciseBall => 'Pike push up (exercise ball)';

	/// en: 'Fly (floor, barbell)'
	String get flyFloorBarbell => 'Fly (floor, barbell)';

	/// en: 'Fly (hyght, dumbbell)'
	String get flyHyghtDumbbell => 'Fly (hyght, dumbbell)';

	/// en: 'Push-up (incline, depth jump)'
	String get pushUpInclineDepthJump => 'Push-up (incline, depth jump)';

	/// en: 'Push-up (incline, reverse grip)'
	String get pushUpInclineReverseGrip => 'Push-up (incline, reverse grip)';

	/// en: 'Push-up (incline, scapula)'
	String get pushUpInclineScapula => 'Push-up (incline, scapula)';

	/// en: 'Isometric palm-to-palm chest squeeze'
	String get isometricPalmToPalmChestSqueeze => 'Isometric palm-to-palm chest squeeze';

	/// en: 'Isometric push-up with side shifts'
	String get isometricPushUpWithSideShifts => 'Isometric push-up with side shifts';

	/// en: 'Press (kettlebell, alternate, floor)'
	String get pressKettlebellAlternateFloor => 'Press (kettlebell, alternate, floor)';

	/// en: 'Press (kettlebell, extended range, one arm, floor)'
	String get pressKettlebellExtendedRangeOneArmFloor => 'Press (kettlebell, extended range, one arm, floor)';

	/// en: 'Floor press (kettlebell, one arm)'
	String get floorPressKettlebellOneArm => 'Floor press (kettlebell, one arm)';

	/// en: 'Push-up (kettlebell, plyo)'
	String get pushUpKettlebellPlyo => 'Push-up (kettlebell, plyo)';

	/// en: 'Push-up (kneeling)'
	String get pushUpKneeling => 'Push-up (kneeling)';

	/// en: 'Rear-bar dips'
	String get rearBarDips => 'Rear-bar dips';

	/// en: 'Chest press (lever, decline)'
	String get chestPressLeverDecline => 'Chest press (lever, decline)';

	/// en: 'Chest press (lever, standing)'
	String get chestPressLeverStanding => 'Chest press (lever, standing)';

	/// en: 'Machine chest squeeze press'
	String get machineChestSqueezePress => 'Machine chest squeeze press';

	/// en: 'Medicine-ball chest pass'
	String get medicineBallChestPass => 'Medicine-ball chest pass';

	/// en: 'Medicine-ball chest throw from three-point start'
	String get medicineBallChestThrowFromThreePointStart => 'Medicine-ball chest throw from three-point start';

	/// en: 'Repeated medicine-ball chest passes'
	String get repeatedMedicineBallChestPasses => 'Repeated medicine-ball chest passes';

	/// en: 'Single medicine-ball chest throw'
	String get singleMedicineBallChestThrow => 'Single medicine-ball chest throw';

	/// en: 'Medicine-ball chest throw with run-out'
	String get medicineBallChestThrowWithRunOut => 'Medicine-ball chest throw with run-out';

	/// en: 'Push-up (modified hindu)'
	String get pushUpModifiedHindu => 'Push-up (modified hindu)';

	/// en: 'Kneeling push-up to forearms'
	String get kneelingPushUpToForearms => 'Kneeling push-up to forearms';

	/// en: 'Push-up (narrow, exercise ball)'
	String get pushUpNarrowExerciseBall => 'Push-up (narrow, exercise ball)';

	/// en: 'Push-up (outside leg kick)'
	String get pushUpOutsideLegKick => 'Push-up (outside leg kick)';

	/// en: 'Push-up (plyo)'
	String get pushUpPlyo => 'Push-up (plyo)';

	/// en: 'Bodyweight push-and-pull'
	String get bodyweightPushAndPull => 'Bodyweight push-and-pull';

	/// en: 'Push-up (bosu ball)'
	String get pushUpBosuBall => 'Push-up (bosu ball)';

	/// en: 'Push-up (stability ball)'
	String get pushUpStabilityBall => 'Push-up (stability ball)';

	/// en: 'Push-up (wall)'
	String get pushUpWall => 'Push-up (wall)';

	/// en: 'Push-up (inside leg kick)'
	String get pushUpInsideLegKick => 'Push-up (inside leg kick)';

	/// en: 'Push-up (medicine ball)'
	String get pushUpMedicineBall => 'Push-up (medicine ball)';

	/// en: 'Push-up (lower arms)'
	String get pushUpLowerArms => 'Push-up (lower arms)';

	/// en: 'Push-up (plus)'
	String get pushUpPlus => 'Push-up (plus)';

	/// en: 'Push-up into side plank'
	String get pushUpIntoSidePlank => 'Push-up into side plank';

	/// en: 'Chest press (resistance band, seated)'
	String get chestPressResistanceBandSeated => 'Chest press (resistance band, seated)';

	/// en: 'Seated roller reach-forward'
	String get seatedRollerReachForward => 'Seated roller reach-forward';

	/// en: 'Seated straight-arm roller raise'
	String get seatedStraightArmRollerRaise => 'Seated straight-arm roller raise';

	/// en: 'Push-up (scapula)'
	String get pushUpScapula => 'Push-up (scapula)';

	/// en: 'Push-up with shoulder taps'
	String get pushUpWithShoulderTaps => 'Push-up with shoulder taps';

	/// en: 'Push-up (side)'
	String get pushUpSide => 'Push-up (side)';

	/// en: 'Push-up (one arm)'
	String get pushUpOneArm => 'Push-up (one arm)';

	/// en: 'Press (smith, decline, reverse grip)'
	String get pressSmithDeclineReverseGrip => 'Press (smith, decline, reverse grip)';

	/// en: 'Press (smith, incline, reverse grip)'
	String get pressSmithInclineReverseGrip => 'Press (smith, incline, reverse grip)';

	/// en: 'Incline Smith-machine high pull'
	String get inclineSmithMachineHighPull => 'Incline Smith-machine high pull';

	/// en: 'Bench press (smith machine, reverse, decline, close grip)'
	String get benchPressSmithMachineReverseDeclineCloseGrip => 'Bench press (smith machine, reverse, decline, close grip)';

	/// en: 'Press (smith, reverse grip)'
	String get pressSmithReverseGrip => 'Press (smith, reverse grip)';

	/// en: 'Bench press (smith, wide grip)'
	String get benchPressSmithWideGrip => 'Bench press (smith, wide grip)';

	/// en: 'Bench press (smith, wide grip, decline)'
	String get benchPressSmithWideGripDecline => 'Bench press (smith, wide grip, decline)';

	/// en: 'Push-up (spider crawl)'
	String get pushUpSpiderCrawl => 'Push-up (spider crawl)';

	/// en: 'Push-up (superman)'
	String get pushUpSuperman => 'Push-up (superman)';

	/// en: 'Push-up (suspended)'
	String get pushUpSuspended => 'Push-up (suspended)';

	/// en: 'Push-up (weighted, drop)'
	String get pushUpWeightedDrop => 'Push-up (weighted, drop)';

	/// en: 'Dip (weighted, straight bar)'
	String get dipWeightedStraightBar => 'Dip (weighted, straight bar)';

	/// en: 'Svend press (weighted)'
	String get svendPressWeighted => 'Svend press (weighted)';

	/// en: 'Push-up (wide, hand)'
	String get pushUpWideHand => 'Push-up (wide, hand)';

	/// en: 'Chest dip (wide grip, high, parallel bars)'
	String get chestDipWideGripHighParallelBars => 'Chest dip (wide grip, high, parallel bars)';
}

// Path: library.biceps.exercises
class Translations$library$biceps$exercises$en {
	Translations$library$biceps$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Behind-the-body cable curl'
	String get behindBodyCableCurl => 'Behind-the-body cable curl';

	/// en: 'Cable rope hammer curl'
	String get ropeHammerCurl => 'Cable rope hammer curl';

	/// en: 'Incline dumbbell curl'
	String get inclineDumbbellCurl => 'Incline dumbbell curl';

	/// en: 'Biceps curl (barbell)'
	String get barbellBicepsCurl => 'Biceps curl (barbell)';

	/// en: 'Spider curls'
	String get spiderCurls => 'Spider curls';

	/// en: 'Hammer curls (cable, single arm)'
	String get singleArmCableHammerCurls => 'Hammer curls (cable, single arm)';

	/// en: 'Biceps curl (cable)'
	String get cableBicepsCurl => 'Biceps curl (cable)';

	/// en: 'Biceps curl (dumbbell)'
	String get dumbbellBicepsCurl => 'Biceps curl (dumbbell)';

	/// en: 'Biceps curl (machine)'
	String get bicepsCurlMachine => 'Biceps curl (machine)';

	/// en: 'Hammer curls (dumbbells)'
	String get hammerCurlDumbbell => 'Hammer curls (dumbbells)';

	/// en: 'Concentration curls'
	String get concentrationCurl => 'Concentration curls';

	/// en: 'Preacher curl'
	String get scottCurl => 'Preacher curl';

	/// en: 'Dual-cable high curls'
	String get dualCableHighCurl => 'Dual-cable high curls';

	/// en: 'Biceps curl (band, alternate)'
	String get bicepsCurlBandAlternate => 'Biceps curl (band, alternate)';

	/// en: 'Concentration curl (band)'
	String get concentrationCurlBand => 'Concentration curl (band)';

	/// en: 'Biceps curl (band, one arm, overhead)'
	String get bicepsCurlBandOneArmOverhead => 'Biceps curl (band, one arm, overhead)';

	/// en: 'Biceps curl (barbell, alternate)'
	String get bicepsCurlBarbellAlternate => 'Biceps curl (barbell, alternate)';

	/// en: 'Biceps curl (barbell, arm blaster)'
	String get bicepsCurlBarbellArmBlaster => 'Biceps curl (barbell, arm blaster)';

	/// en: 'Drag curl (barbell)'
	String get dragCurlBarbell => 'Drag curl (barbell)';

	/// en: 'Preacher curl (barbell, lying)'
	String get preacherCurlBarbellLying => 'Preacher curl (barbell, lying)';

	/// en: 'Preacher curl (barbell)'
	String get preacherCurlBarbell => 'Preacher curl (barbell)';

	/// en: 'Reverse preacher curl (barbell)'
	String get reversePreacherCurlBarbell => 'Reverse preacher curl (barbell)';

	/// en: 'Concentration curl (barbell, seated, close grip)'
	String get concentrationCurlBarbellSeatedCloseGrip => 'Concentration curl (barbell, seated, close grip)';

	/// en: 'Curl (barbell, standing, close grip)'
	String get curlBarbellStandingCloseGrip => 'Curl (barbell, standing, close grip)';

	/// en: 'Concentration curl (barbell, standing)'
	String get concentrationCurlBarbellStanding => 'Concentration curl (barbell, standing)';

	/// en: 'Biceps curl (barbell, standing, wide grip)'
	String get bicepsCurlBarbellStandingWideGrip => 'Biceps curl (barbell, standing, wide grip)';

	/// en: 'Leg-resisted concentration curl'
	String get legResistedConcentrationCurl => 'Leg-resisted concentration curl';

	/// en: 'Chin-up (close grip)'
	String get chinUpCloseGrip => 'Chin-up (close grip)';

	/// en: 'Biceps curl (bodyweight, side lying)'
	String get bicepsCurlBodyweightSideLying => 'Biceps curl (bodyweight, side lying)';

	/// en: 'Curl (cable, close grip)'
	String get curlCableCloseGrip => 'Curl (cable, close grip)';

	/// en: 'Concentration curl (cable)'
	String get concentrationCurlCable => 'Concentration curl (cable)';

	/// en: 'Drag curl (cable)'
	String get dragCurlCable => 'Drag curl (cable)';

	/// en: 'Biceps curl (cable, lying)'
	String get bicepsCurlCableLying => 'Biceps curl (cable, lying)';

	/// en: 'Curl (cable, lying, close grip)'
	String get curlCableLyingCloseGrip => 'Curl (cable, lying, close grip)';

	/// en: 'Curl (cable, one arm)'
	String get curlCableOneArm => 'Curl (cable, one arm)';

	/// en: 'Preacher curl (cable, one arm)'
	String get preacherCurlCableOneArm => 'Preacher curl (cable, one arm)';

	/// en: 'Reverse preacher curl (cable, one arm)'
	String get reversePreacherCurlCableOneArm => 'Reverse preacher curl (cable, one arm)';

	/// en: 'Curl (cable, overhead, exercise ball)'
	String get curlCableOverheadExerciseBall => 'Curl (cable, overhead, exercise ball)';

	/// en: 'Preacher curl (cable)'
	String get preacherCurlCable => 'Preacher curl (cable)';

	/// en: 'Biceps curl (cable, pulldown)'
	String get bicepsCurlCablePulldown => 'Biceps curl (cable, pulldown)';

	/// en: 'Reverse curl (cable)'
	String get reverseCurlCable => 'Reverse curl (cable)';

	/// en: 'Reverse preacher curl (cable)'
	String get reversePreacherCurlCable => 'Reverse preacher curl (cable)';

	/// en: 'Hammer preacher curl (cable, rope)'
	String get hammerPreacherCurlCableRope => 'Hammer preacher curl (cable, rope)';

	/// en: 'Hammer preacher curl (cable, rope, one arm)'
	String get hammerPreacherCurlCableRopeOneArm => 'Hammer preacher curl (cable, rope, one arm)';

	/// en: 'Curl (cable, seated)'
	String get curlCableSeated => 'Curl (cable, seated)';

	/// en: 'Concentration curl (cable, seated, one arm)'
	String get concentrationCurlCableSeatedOneArm => 'Concentration curl (cable, seated, one arm)';

	/// en: 'Curl (cable, seated, overhead)'
	String get curlCableSeatedOverhead => 'Curl (cable, seated, overhead)';

	/// en: 'Curl (cable, squatting)'
	String get curlCableSquatting => 'Curl (cable, squatting)';

	/// en: 'Curl (cable, standing, inner)'
	String get curlCableStandingInner => 'Curl (cable, standing, inner)';

	/// en: 'Biceps curl (cable, rope, standing)'
	String get bicepsCurlCableRopeStanding => 'Biceps curl (cable, rope, standing)';

	/// en: 'Curl (cable, two arm, incline bench)'
	String get curlCableTwoArmInclineBench => 'Curl (cable, two arm, incline bench)';

	/// en: 'Biceps curl (dumbbell, alternate)'
	String get bicepsCurlDumbbellAlternate => 'Biceps curl (dumbbell, alternate)';

	/// en: 'Biceps curl (dumbbell, alternate, arm blaster)'
	String get bicepsCurlDumbbellAlternateArmBlaster => 'Biceps curl (dumbbell, alternate, arm blaster)';

	/// en: 'Hammer preacher curl (dumbbell, alternate)'
	String get hammerPreacherCurlDumbbellAlternate => 'Hammer preacher curl (dumbbell, alternate)';

	/// en: 'Preacher curl (dumbbell, alternate)'
	String get preacherCurlDumbbellAlternate => 'Preacher curl (dumbbell, alternate)';

	/// en: 'Hammer curl (dumbbell, alternate, seated)'
	String get hammerCurlDumbbellAlternateSeated => 'Hammer curl (dumbbell, alternate, seated)';

	/// en: 'Biceps curl (dumbbell, alternate, leg raised, exercise ball)'
	String get bicepsCurlDumbbellAlternateLegRaisedExerciseBall => 'Biceps curl (dumbbell, alternate, leg raised, exercise ball)';

	/// en: 'Biceps curl (dumbbell, alternate, seated, exercise ball)'
	String get bicepsCurlDumbbellAlternateSeatedExerciseBall => 'Biceps curl (dumbbell, alternate, seated, exercise ball)';

	/// en: 'Dumbbell curl with bowling lunge'
	String get dumbbellCurlWithBowlingLunge => 'Dumbbell curl with bowling lunge';

	/// en: 'Biceps curl (dumbbell, exercise ball, leg raised)'
	String get bicepsCurlDumbbellExerciseBallLegRaised => 'Biceps curl (dumbbell, exercise ball, leg raised)';

	/// en: 'Biceps curl (dumbbell, stork stance)'
	String get bicepsCurlDumbbellStorkStance => 'Biceps curl (dumbbell, stork stance)';

	/// en: 'Biceps curl (dumbbell, arm blaster)'
	String get bicepsCurlDumbbellArmBlaster => 'Biceps curl (dumbbell, arm blaster)';

	/// en: 'Biceps curl squat (dumbbell)'
	String get bicepsCurlSquatDumbbell => 'Biceps curl squat (dumbbell)';

	/// en: 'Biceps curl (dumbbell, v sit, bosu ball)'
	String get bicepsCurlDumbbellVSitBosuBall => 'Biceps curl (dumbbell, v sit, bosu ball)';

	/// en: 'Hammer curl (dumbbell, cross body)'
	String get hammerCurlDumbbellCrossBody => 'Hammer curl (dumbbell, cross body)';

	/// en: 'Hammer curl (dumbbell, exercise ball)'
	String get hammerCurlDumbbellExerciseBall => 'Hammer curl (dumbbell, exercise ball)';

	/// en: 'Hammer curl (dumbbell, arm blaster)'
	String get hammerCurlDumbbellArmBlaster => 'Hammer curl (dumbbell, arm blaster)';

	/// en: 'High curl (dumbbell)'
	String get highCurlDumbbell => 'High curl (dumbbell)';

	/// en: 'Preacher curl (dumbbell, incline)'
	String get preacherCurlDumbbellIncline => 'Preacher curl (dumbbell, incline)';

	/// en: 'Hammer curl (dumbbell, incline)'
	String get hammerCurlDumbbellIncline => 'Hammer curl (dumbbell, incline)';

	/// en: 'Inner biceps curl (dumbbell, incline)'
	String get innerBicepsCurlDumbbellIncline => 'Inner biceps curl (dumbbell, incline)';

	/// en: 'Biceps curl (dumbbell, kneeling, exercise ball)'
	String get bicepsCurlDumbbellKneelingExerciseBall => 'Biceps curl (dumbbell, kneeling, exercise ball)';

	/// en: 'Lunge biceps curl (dumbbell)'
	String get lungeBicepsCurlDumbbell => 'Lunge biceps curl (dumbbell)';

	/// en: 'Biceps curl (dumbbell, lying, supine)'
	String get bicepsCurlDumbbellLyingSupine => 'Biceps curl (dumbbell, lying, supine)';

	/// en: 'Biceps curl (dumbbell, lying)'
	String get bicepsCurlDumbbellLying => 'Biceps curl (dumbbell, lying)';

	/// en: 'Curl (dumbbell, lying, wide)'
	String get curlDumbbellLyingWide => 'Curl (dumbbell, lying, wide)';

	/// en: 'Concentration curl (dumbbell, one arm, stability ball)'
	String get concentrationCurlDumbbellOneArmStabilityBall => 'Concentration curl (dumbbell, one arm, stability ball)';

	/// en: 'Hammer preacher curl (dumbbell, one arm)'
	String get hammerPreacherCurlDumbbellOneArm => 'Hammer preacher curl (dumbbell, one arm)';

	/// en: 'Curl (dumbbell, one arm, prone)'
	String get curlDumbbellOneArmProne => 'Curl (dumbbell, one arm, prone)';

	/// en: 'Hammer curl (dumbbell, one arm, prone)'
	String get hammerCurlDumbbellOneArmProne => 'Hammer curl (dumbbell, one arm, prone)';

	/// en: 'Reverse preacher curl (dumbbell, one arm)'
	String get reversePreacherCurlDumbbellOneArm => 'Reverse preacher curl (dumbbell, one arm)';

	/// en: 'Reverse spider curl (dumbbell, one arm)'
	String get reverseSpiderCurlDumbbellOneArm => 'Reverse spider curl (dumbbell, one arm)';

	/// en: 'Biceps curl (dumbbell, one arm, seated, exercise ball)'
	String get bicepsCurlDumbbellOneArmSeatedExerciseBall => 'Biceps curl (dumbbell, one arm, seated, exercise ball)';

	/// en: 'Hammer curl (dumbbell, one arm, seated)'
	String get hammerCurlDumbbellOneArmSeated => 'Hammer curl (dumbbell, one arm, seated)';

	/// en: 'Curl (dumbbell, one arm, standing)'
	String get curlDumbbellOneArmStanding => 'Curl (dumbbell, one arm, standing)';

	/// en: 'Hammer curl (dumbbell, one arm, standing)'
	String get hammerCurlDumbbellOneArmStanding => 'Hammer curl (dumbbell, one arm, standing)';

	/// en: 'Zottman preacher curl (dumbbell, one arm)'
	String get zottmanPreacherCurlDumbbellOneArm => 'Zottman preacher curl (dumbbell, one arm)';

	/// en: 'Hammer preacher curl (dumbbell)'
	String get hammerPreacherCurlDumbbell => 'Hammer preacher curl (dumbbell)';

	/// en: 'Preacher curl (dumbbell, exercise ball)'
	String get preacherCurlDumbbellExerciseBall => 'Preacher curl (dumbbell, exercise ball)';

	/// en: 'Curl (dumbbell, prone, incline)'
	String get curlDumbbellProneIncline => 'Curl (dumbbell, prone, incline)';

	/// en: 'Hammer curl (dumbbell, prone, incline)'
	String get hammerCurlDumbbellProneIncline => 'Hammer curl (dumbbell, prone, incline)';

	/// en: 'Reverse preacher curl (dumbbell)'
	String get reversePreacherCurlDumbbell => 'Reverse preacher curl (dumbbell)';

	/// en: 'Reverse spider curl (dumbbell)'
	String get reverseSpiderCurlDumbbell => 'Reverse spider curl (dumbbell)';

	/// en: 'Hammer curl (dumbbell, seated, alternate, exercise ball)'
	String get hammerCurlDumbbellSeatedAlternateExerciseBall => 'Hammer curl (dumbbell, seated, alternate, exercise ball)';

	/// en: 'Biceps curl (dumbbell, seated)'
	String get bicepsCurlDumbbellSeated => 'Biceps curl (dumbbell, seated)';

	/// en: 'Biceps curl (dumbbell, seated, exercise ball)'
	String get bicepsCurlDumbbellSeatedExerciseBall => 'Biceps curl (dumbbell, seated, exercise ball)';

	/// en: 'Hammer curl (dumbbell, seated)'
	String get hammerCurlDumbbellSeated => 'Hammer curl (dumbbell, seated)';

	/// en: 'Inner biceps curl (dumbbell, seated)'
	String get innerBicepsCurlDumbbellSeated => 'Inner biceps curl (dumbbell, seated)';

	/// en: 'Biceps curl (dumbbell, seated, one arm, exercise ball, leg raised)'
	String get bicepsCurlDumbbellSeatedOneArmExerciseBallLegRaised => 'Biceps curl (dumbbell, seated, one arm, exercise ball, leg raised)';

	/// en: 'Preacher curl (dumbbell, seated)'
	String get preacherCurlDumbbellSeated => 'Preacher curl (dumbbell, seated)';

	/// en: 'Concentration curl (dumbbell, seated, reverse)'
	String get concentrationCurlDumbbellSeatedReverse => 'Concentration curl (dumbbell, seated, reverse)';

	/// en: 'Hammer curl and press (dumbbell, standing, alternate)'
	String get hammerCurlAndPressDumbbellStandingAlternate => 'Hammer curl and press (dumbbell, standing, alternate)';

	/// en: 'Concentration curl (dumbbell, standing)'
	String get concentrationCurlDumbbellStanding => 'Concentration curl (dumbbell, standing)';

	/// en: 'Inner biceps curl (dumbbell, standing)'
	String get innerBicepsCurlDumbbellStanding => 'Inner biceps curl (dumbbell, standing)';

	/// en: 'Concentration curl (dumbbell, standing, one arm)'
	String get concentrationCurlDumbbellStandingOneArm => 'Concentration curl (dumbbell, standing, one arm)';

	/// en: 'Curl (dumbbell, standing, one arm, incline bench)'
	String get curlDumbbellStandingOneArmInclineBench => 'Curl (dumbbell, standing, one arm, incline bench)';

	/// en: 'Preacher curl (dumbbell, standing)'
	String get preacherCurlDumbbellStanding => 'Preacher curl (dumbbell, standing)';

	/// en: 'Zottman preacher curl (dumbbell, standing)'
	String get zottmanPreacherCurlDumbbellStanding => 'Zottman preacher curl (dumbbell, standing)';

	/// en: 'Step-up with balance and dumbbell curl'
	String get stepUpWithBalanceAndDumbbellCurl => 'Step-up with balance and dumbbell curl';

	/// en: 'Biceps curl (dumbbell, waiter)'
	String get bicepsCurlDumbbellWaiter => 'Biceps curl (dumbbell, waiter)';

	/// en: 'Zottman curl (dumbbell)'
	String get zottmanCurlDumbbell => 'Zottman curl (dumbbell)';

	/// en: 'Zottman preacher curl (dumbbell)'
	String get zottmanPreacherCurlDumbbell => 'Zottman preacher curl (dumbbell)';

	/// en: 'Concentration curl (ez bar, seated, close grip)'
	String get concentrationCurlEzBarSeatedCloseGrip => 'Concentration curl (ez bar, seated, close grip)';

	/// en: 'Preacher curl (ez barbell, close grip)'
	String get preacherCurlEzBarbellCloseGrip => 'Preacher curl (ez barbell, close grip)';

	/// en: 'Curl (ez barbell, close grip)'
	String get curlEzBarbellCloseGrip => 'Curl (ez barbell, close grip)';

	/// en: 'Curl (ez barbell)'
	String get curlEzBarbell => 'Curl (ez barbell)';

	/// en: 'Reverse curl (ez barbell)'
	String get reverseCurlEzBarbell => 'Reverse curl (ez barbell)';

	/// en: 'Reverse preacher curl (ez barbell)'
	String get reversePreacherCurlEzBarbell => 'Reverse preacher curl (ez barbell)';

	/// en: 'Curl (ez barbell, seated)'
	String get curlEzBarbellSeated => 'Curl (ez barbell, seated)';

	/// en: 'Spider curl (ez barbell)'
	String get spiderCurlEzBarbell => 'Spider curl (ez barbell)';

	/// en: 'Biceps curl (ez bar, arm blaster)'
	String get bicepsCurlEzBarArmBlaster => 'Biceps curl (ez bar, arm blaster)';

	/// en: 'Biceps curl (ez barbell, standing, wide grip)'
	String get bicepsCurlEzBarbellStandingWideGrip => 'Biceps curl (ez barbell, standing, wide grip)';

	/// en: 'Clean (kettlebell, bottoms up, from hang position)'
	String get cleanKettlebellBottomsUpFromHangPosition => 'Clean (kettlebell, bottoms up, from hang position)';

	/// en: 'Hang clean (kettlebell, double, alternate)'
	String get hangCleanKettlebellDoubleAlternate => 'Hang clean (kettlebell, double, alternate)';

	/// en: 'Preacher curl (lever, hammer grip)'
	String get preacherCurlLeverHammerGrip => 'Preacher curl (lever, hammer grip)';

	/// en: 'Preacher curl (lever)'
	String get preacherCurlLever => 'Preacher curl (lever)';

	/// en: 'Reverse preacher curl (lever)'
	String get reversePreacherCurlLever => 'Reverse preacher curl (lever)';

	/// en: 'Hammer curl (olympic barbell)'
	String get hammerCurlOlympicBarbell => 'Hammer curl (olympic barbell)';

	/// en: 'Biceps curl (resistance band, seated)'
	String get bicepsCurlResistanceBandSeated => 'Biceps curl (resistance band, seated)';

	/// en: 'Biceps curl (smith machine)'
	String get bicepsCurlSmithMachine => 'Biceps curl (smith machine)';

	/// en: 'Biceps curl (weighted, seated, stability ball)'
	String get bicepsCurlWeightedSeatedStabilityBall => 'Biceps curl (weighted, seated, stability ball)';
}

// Path: library.abs.exercises
class Translations$library$abs$exercises$en {
	Translations$library$abs$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Ab wheel rollout'
	String get abWheelRollout => 'Ab wheel rollout';

	/// en: 'Hanging knee raise'
	String get hangingKneeRaise => 'Hanging knee raise';

	/// en: 'Mountain climber'
	String get mountainClimber => 'Mountain climber';

	/// en: 'High-to-low cable woodchop'
	String get highCableWoodchopper => 'High-to-low cable woodchop';

	/// en: 'Reverse crunch'
	String get reverseCrunch => 'Reverse crunch';

	/// en: 'Cable crunch'
	String get cableCrunch => 'Cable crunch';

	/// en: 'Cable Pallof press'
	String get pallofPress => 'Cable Pallof press';

	/// en: 'Crunches'
	String get crunches => 'Crunches';

	/// en: 'Lying knee raise'
	String get kneeRaise => 'Lying knee raise';

	/// en: 'Lying leg raise'
	String get legRaise => 'Lying leg raise';

	/// en: 'Crunch (machine)'
	String get crunchMachine => 'Crunch (machine)';

	/// en: 'Heels-up crunches'
	String get heelsUpCrunch => 'Heels-up crunches';

	/// en: 'Double crunch'
	String get fullBodyCrunch => 'Double crunch';

	/// en: 'Plank'
	String get plank => 'Plank';

	/// en: 'Hollow body hold'
	String get hollowBodyHold => 'Hollow body hold';

	/// en: 'Bicycle crunches'
	String get bicycleCrunches => 'Bicycle crunches';

	/// en: 'Reverse crunch with leg extension'
	String get extendedReverseCrunchWithLegExtension => 'Reverse crunch with leg extension';

	/// en: 'Toe touches'
	String get toeTouches => 'Toe touches';

	/// en: 'Russian twist'
	String get russianTwist => 'Russian twist';

	/// en: 'Heel touches'
	String get heelTouches => 'Heel touches';

	/// en: 'Dead bugs (timed)'
	String get deadBugHoldCardio => 'Dead bugs (timed)';

	/// en: 'Dead bug hold (static)'
	String get deadBugHoldStatic => 'Dead bug hold (static)';

	/// en: 'Dead bugs'
	String get deadBugHold => 'Dead bugs';

	/// en: 'Bent-knee hollow body hold'
	String get hollowBodyHoldBentKnees => 'Bent-knee hollow body hold';

	/// en: 'Oblique crunches'
	String get obliqueCrunches => 'Oblique crunches';

	/// en: 'Leg raise (parallel bars)'
	String get legRaiseParallelBars => 'Leg raise (parallel bars)';

	/// en: 'Lateral hyperextensions'
	String get lateralHyperextensions => 'Lateral hyperextensions';

	/// en: 'Sit-up (3/4)'
	String get sitUp34 => 'Sit-up (3/4)';

	/// en: 'Side bend on a 45° bench'
	String get sideBendOnA45Bench => 'Side bend on a 45° bench';

	/// en: 'Leg raise (hanging, straps)'
	String get legRaiseHangingStraps => 'Leg raise (hanging, straps)';

	/// en: 'Sit-up (arms overhead, full)'
	String get sitUpArmsOverheadFull => 'Sit-up (arms overhead, full)';

	/// en: 'Knee raise (assisted, hanging)'
	String get kneeRaiseAssistedHanging => 'Knee raise (assisted, hanging)';

	/// en: 'Knee raise (assisted, hanging, throw down)'
	String get kneeRaiseAssistedHangingThrowDown => 'Knee raise (assisted, hanging, throw down)';

	/// en: 'Leg raise (assisted, lying, lateral, throw down)'
	String get legRaiseAssistedLyingLateralThrowDown => 'Leg raise (assisted, lying, lateral, throw down)';

	/// en: 'Leg raise (assisted, lying, throw down)'
	String get legRaiseAssistedLyingThrowDown => 'Leg raise (assisted, lying, throw down)';

	/// en: 'Russian twist (assisted, motion)'
	String get russianTwistAssistedMotion => 'Russian twist (assisted, motion)';

	/// en: 'Sit-up (assisted)'
	String get sitUpAssisted => 'Sit-up (assisted)';

	/// en: 'V-up (band, alternate)'
	String get vUpBandAlternate => 'V-up (band, alternate)';

	/// en: 'Rollout (band, assisted, wheel)'
	String get rolloutBandAssistedWheel => 'Rollout (band, assisted, wheel)';

	/// en: 'Bicycle crunch (band)'
	String get bicycleCrunchBand => 'Bicycle crunch (band)';

	/// en: 'Pallof press (band, horizontal)'
	String get pallofPressBandHorizontal => 'Pallof press (band, horizontal)';

	/// en: 'Jackknife sit-up (band)'
	String get jackknifeSitUpBand => 'Jackknife sit-up (band)';

	/// en: 'Crunch (band, kneeling, twisting)'
	String get crunchBandKneelingTwisting => 'Crunch (band, kneeling, twisting)';

	/// en: 'Leg raise (band, lying, straight leg)'
	String get legRaiseBandLyingStraightLeg => 'Leg raise (band, lying, straight leg)';

	/// en: 'Sit-up (band, push)'
	String get sitUpBandPush => 'Sit-up (band, push)';

	/// en: 'Twist (band, seated)'
	String get twistBandSeated => 'Twist (band, seated)';

	/// en: 'Crunch (band, standing)'
	String get crunchBandStanding => 'Crunch (band, standing)';

	/// en: 'Crunch (band, standing, twisting)'
	String get crunchBandStandingTwisting => 'Crunch (band, standing, twisting)';

	/// en: 'V-up (band)'
	String get vUpBand => 'V-up (band)';

	/// en: 'Pallof press (band, vertical)'
	String get pallofPressBandVertical => 'Pallof press (band, vertical)';

	/// en: 'Sit-up (barbell, press)'
	String get sitUpBarbellPress => 'Sit-up (barbell, press)';

	/// en: 'Rollout (barbell)'
	String get rolloutBarbell => 'Rollout (barbell)';

	/// en: 'Rollout (barbell, from bench)'
	String get rolloutBarbellFromBench => 'Rollout (barbell, from bench)';

	/// en: 'Twist (barbell, seated)'
	String get twistBarbellSeated => 'Twist (barbell, seated)';

	/// en: 'Side bend (barbell)'
	String get sideBendBarbell => 'Side bend (barbell)';

	/// en: 'Leg raise (barbell, seated, alternate)'
	String get legRaiseBarbellSeatedAlternate => 'Leg raise (barbell, seated, alternate)';

	/// en: 'Ab rollout (barbell, standing)'
	String get abRolloutBarbellStanding => 'Ab rollout (barbell, standing)';

	/// en: 'Twist (barbell, standing)'
	String get twistBarbellStanding => 'Twist (barbell, standing)';

	/// en: 'Side plank (bodyweight, incline)'
	String get sidePlankBodyweightIncline => 'Side plank (bodyweight, incline)';

	/// en: 'Reverse crunch with vertical hip lift'
	String get reverseCrunchWithVerticalHipLift => 'Reverse crunch with vertical hip lift';

	/// en: 'Cross-body mountain climber'
	String get crossBodyMountainClimber => 'Cross-body mountain climber';

	/// en: 'Plank hip lifts'
	String get plankHipLifts => 'Plank hip lifts';

	/// en: 'Cable rotational shoulder throw'
	String get cableRotationalShoulderThrow => 'Cable rotational shoulder throw';

	/// en: 'Reverse crunch (cable)'
	String get reverseCrunchCable => 'Reverse crunch (cable)';

	/// en: 'Russian twist (cable, stability ball)'
	String get russianTwistCableStabilityBall => 'Russian twist (cable, stability ball)';

	/// en: 'Crunch (cable, seated)'
	String get crunchCableSeated => 'Crunch (cable, seated)';

	/// en: 'Twist (cable, seated)'
	String get twistCableSeated => 'Twist (cable, seated)';

	/// en: 'Side bend (cable)'
	String get sideBendCable => 'Side bend (cable)';

	/// en: 'Side bend (cable, crunch, bosu ball)'
	String get sideBendCableCrunchBosuBall => 'Side bend (cable, crunch, bosu ball)';

	/// en: 'Side crunch (cable)'
	String get sideCrunchCable => 'Side crunch (cable)';

	/// en: 'Crunch (cable, standing)'
	String get crunchCableStanding => 'Crunch (cable, standing)';

	/// en: 'Crunch (cable, standing, rope)'
	String get crunchCableStandingRope => 'Crunch (cable, standing, rope)';

	/// en: 'Low-to-high cable woodchop'
	String get lowToHighCableWoodchop => 'Low-to-high cable woodchop';

	/// en: 'Reverse crunch (cable, tuck)'
	String get reverseCrunchCableTuck => 'Reverse crunch (cable, tuck)';

	/// en: 'Twist (cable)'
	String get twistCable => 'Twist (cable)';

	/// en: 'Crab-position toe touches'
	String get crabPositionToeTouches => 'Crab-position toe touches';

	/// en: 'Crunch (cross body)'
	String get crunchCrossBody => 'Crunch (cross body)';

	/// en: 'Crunch (hands overhead)'
	String get crunchHandsOverhead => 'Crunch (hands overhead)';

	/// en: 'Crunch (stability ball)'
	String get crunchStabilityBall => 'Crunch (stability ball)';

	/// en: 'Crunch (stability ball, straight arm)'
	String get crunchStabilityBallStraightArm => 'Crunch (stability ball, straight arm)';

	/// en: 'Crunch (decline)'
	String get crunchDecline => 'Crunch (decline)';

	/// en: 'Sit-up (decline)'
	String get sitUpDecline => 'Sit-up (decline)';

	/// en: 'Side bend (dumbbell)'
	String get sideBendDumbbell => 'Side bend (dumbbell)';

	/// en: 'Alternating elbow-to-knee crunch'
	String get alternatingElbowToKneeCrunch => 'Alternating elbow-to-knee crunch';

	/// en: 'Human flag hold'
	String get humanFlagHold => 'Human flag hold';

	/// en: 'Sit-up (flexion leg, bent knee)'
	String get sitUpFlexionLegBentKnee => 'Sit-up (flexion leg, bent knee)';

	/// en: 'Sit-up (flexion leg, straight arm)'
	String get sitUpFlexionLegStraightArm => 'Sit-up (flexion leg, straight arm)';

	/// en: 'Crunch (frog)'
	String get crunchFrog => 'Crunch (frog)';

	/// en: 'Plank trunk rotations'
	String get plankTrunkRotations => 'Plank trunk rotations';

	/// en: 'Chin-up with knee tuck'
	String get chinUpWithKneeTuck => 'Chin-up with knee tuck';

	/// en: 'Sit-up (half)'
	String get sitUpHalf => 'Sit-up (half)';

	/// en: 'Leg hip raise (hanging)'
	String get legHipRaiseHanging => 'Leg hip raise (hanging)';

	/// en: 'Leg raise (hanging)'
	String get legRaiseHanging => 'Leg raise (hanging)';

	/// en: 'Knee raise (hanging, oblique)'
	String get kneeRaiseHangingOblique => 'Knee raise (hanging, oblique)';

	/// en: 'Hanging pike raise'
	String get hangingPikeRaise => 'Hanging pike raise';

	/// en: 'Leg hip raise (hanging, straight leg, twisting)'
	String get legHipRaiseHangingStraightLegTwisting => 'Leg hip raise (hanging, straight leg, twisting)';

	/// en: 'Inchworm'
	String get inchworm => 'Inchworm';

	/// en: 'Leg hip raise (incline, straight leg)'
	String get legHipRaiseInclineStraightLeg => 'Leg hip raise (incline, straight leg)';

	/// en: 'Sit-up (incline, twisting)'
	String get sitUpInclineTwisting => 'Sit-up (incline, twisting)';

	/// en: 'Jackknife sit-up'
	String get jackknifeSitUp => 'Jackknife sit-up';

	/// en: 'Sit-up (janda)'
	String get sitUpJanda => 'Sit-up (janda)';

	/// en: 'Windmill (kettlebell, advanced)'
	String get windmillKettlebellAdvanced => 'Windmill (kettlebell, advanced)';

	/// en: 'Press (kettlebell, bent)'
	String get pressKettlebellBent => 'Press (kettlebell, bent)';

	/// en: 'Windmill (kettlebell, double)'
	String get windmillKettlebellDouble => 'Windmill (kettlebell, double)';

	/// en: 'Kettlebell figure-eight pass'
	String get kettlebellFigureEightPass => 'Kettlebell figure-eight pass';

	/// en: 'Windmill (kettlebell)'
	String get windmillKettlebell => 'Windmill (kettlebell)';

	/// en: 'Seated knee tucks on bench'
	String get seatedKneeTucksOnBench => 'Seated knee tucks on bench';

	/// en: 'Crunch (knee touch)'
	String get crunchKneeTouch => 'Crunch (knee touch)';

	/// en: 'Kneeling plank shoulder taps'
	String get kneelingPlankShoulderTaps => 'Kneeling plank shoulder taps';

	/// en: 'L-sit (floor)'
	String get lSitFloor => 'L-sit (floor)';

	/// en: 'Landmine trunk rotations'
	String get landmineTrunkRotations => 'Landmine trunk rotations';

	/// en: 'Bench knee tucks'
	String get benchKneeTucks => 'Bench knee tucks';

	/// en: 'Twist (lever, kneeling)'
	String get twistLeverKneeling => 'Twist (lever, kneeling)';

	/// en: 'Crunch (lever, seated, chest pad)'
	String get crunchLeverSeatedChestPad => 'Crunch (lever, seated, chest pad)';

	/// en: 'Leg raise (lever, seated, crunch)'
	String get legRaiseLeverSeatedCrunch => 'Leg raise (lever, seated, crunch)';

	/// en: 'Lunge (twist)'
	String get lungeTwist => 'Lunge (twist)';

	/// en: 'Leg hip raise (lying)'
	String get legHipRaiseLying => 'Leg hip raise (lying)';

	/// en: 'Crunch (negative)'
	String get crunchNegative => 'Crunch (negative)';

	/// en: 'Single-arm medicine-ball slam'
	String get singleArmMedicineBallSlam => 'Single-arm medicine-ball slam';

	/// en: 'Supine pelvic tilts'
	String get supinePelvicTilts => 'Supine pelvic tilts';

	/// en: 'Reverse step with overhead reach'
	String get reverseStepWithOverheadReach => 'Reverse step with overhead reach';

	/// en: 'Squat (potty)'
	String get squatPotty => 'Squat (potty)';

	/// en: 'Plank with opposite arm and leg reach'
	String get plankWithOppositeArmAndLegReach => 'Plank with opposite arm and leg reach';

	/// en: 'Sit-up (prisoner, half)'
	String get sitUpPrisonerHalf => 'Sit-up (prisoner, half)';

	/// en: 'Twist (prone, stability ball)'
	String get twistProneStabilityBall => 'Twist (prone, stability ball)';

	/// en: 'Stability-ball knee tuck'
	String get stabilityBallKneeTuck => 'Stability-ball knee tuck';

	/// en: 'Sit-up (quarter)'
	String get sitUpQuarter => 'Sit-up (quarter)';

	/// en: 'Reverse plank with alternating leg raises'
	String get reversePlankWithAlternatingLegRaises => 'Reverse plank with alternating leg raises';

	/// en: 'Body saw (roller)'
	String get bodySawRoller => 'Body saw (roller)';

	/// en: 'Reverse crunch (roller)'
	String get reverseCrunchRoller => 'Reverse crunch (roller)';

	/// en: 'Russian twist'
	String get russianTwistBodyweight => 'Russian twist';

	/// en: 'Leg raise (seated)'
	String get legRaiseSeated => 'Leg raise (seated)';

	/// en: 'Side crunch (seated, wall)'
	String get sideCrunchSeatedWall => 'Side crunch (seated, wall)';

	/// en: 'Shoulder tap'
	String get shoulderTap => 'Shoulder tap';

	/// en: 'Side-bridge hip lifts'
	String get sideBridgeHipLifts => 'Side-bridge hip lifts';

	/// en: 'Lateral leg raises on parallel bars'
	String get lateralLegRaisesOnParallelBars => 'Lateral leg raises on parallel bars';

	/// en: 'Alternating cross-body toe touches'
	String get alternatingCrossBodyToeTouches => 'Alternating cross-body toe touches';

	/// en: 'Sit-up'
	String get sitUp => 'Sit-up';

	/// en: 'Sit-up (arms chest)'
	String get sitUpArmsChest => 'Sit-up (arms chest)';

	/// en: 'Sledgehammer tire strikes'
	String get sledgehammerTireStrikes => 'Sledgehammer tire strikes';

	/// en: 'Diagonal dumbbell trunk rotations'
	String get diagonalDumbbellTrunkRotations => 'Diagonal dumbbell trunk rotations';

	/// en: 'Twist (spine)'
	String get twistSpine => 'Twist (spine)';

	/// en: 'Crunch (stability ball, hands behind head, full)'
	String get crunchStabilityBallHandsBehindHeadFull => 'Crunch (stability ball, hands behind head, full)';

	/// en: 'Rollout (standing, wheel)'
	String get rolloutStandingWheel => 'Rollout (standing, wheel)';

	/// en: 'Suspension-strap abdominal rollout'
	String get suspensionStrapAbdominalRollout => 'Suspension-strap abdominal rollout';

	/// en: 'Reverse crunch (suspended)'
	String get reverseCrunchSuspended => 'Reverse crunch (suspended)';

	/// en: 'Leg raise (twisted)'
	String get legRaiseTwisted => 'Leg raise (twisted)';

	/// en: 'V-sit (floor)'
	String get vSitFloor => 'V-sit (floor)';

	/// en: 'Crunch (weighted)'
	String get crunchWeighted => 'Crunch (weighted)';

	/// en: 'Sit-up (weighted, decline)'
	String get sitUpWeightedDecline => 'Sit-up (weighted, decline)';

	/// en: 'Plank (weighted, front)'
	String get plankWeightedFront => 'Plank (weighted, front)';

	/// en: 'Leg hip raise (weighted, hanging)'
	String get legHipRaiseWeightedHanging => 'Leg hip raise (weighted, hanging)';

	/// en: 'Crunch (weighted, overhead, stability ball)'
	String get crunchWeightedOverheadStabilityBall => 'Crunch (weighted, overhead, stability ball)';

	/// en: 'Russian twist (weighted, legs up)'
	String get russianTwistWeightedLegsUp => 'Russian twist (weighted, legs up)';

	/// en: 'Twist (weighted, seated, stability ball)'
	String get twistWeightedSeatedStabilityBall => 'Twist (weighted, seated, stability ball)';

	/// en: 'Side bend (weighted, stability ball)'
	String get sideBendWeightedStabilityBall => 'Side bend (weighted, stability ball)';
}

// Path: library.calves.exercises
class Translations$library$calves$exercises$en {
	Translations$library$calves$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Smith machine calf raise'
	String get smithMachineCalfRaise => 'Smith machine calf raise';

	/// en: 'Calf raise (standing)'
	String get calfRaiseStanding => 'Calf raise (standing)';

	/// en: 'Calf raise (seated)'
	String get calfRaiseSeated => 'Calf raise (seated)';

	/// en: 'Calf press on leg press machine'
	String get calfPressLegPressMachine => 'Calf press on leg press machine';

	/// en: 'Ankle rotations'
	String get ankleRotations => 'Ankle rotations';

	/// en: 'Calves stretch (assisted, lying)'
	String get calvesStretchAssistedLying => 'Calves stretch (assisted, lying)';

	/// en: 'Calf raise (band, one leg)'
	String get calfRaiseBandOneLeg => 'Calf raise (band, one leg)';

	/// en: 'Reverse calf raise (band, one leg)'
	String get reverseCalfRaiseBandOneLeg => 'Reverse calf raise (band, one leg)';

	/// en: 'Calf raise (band, standing)'
	String get calfRaiseBandStanding => 'Calf raise (band, standing)';

	/// en: 'Calf raise (barbell, floor)'
	String get calfRaiseBarbellFloor => 'Calf raise (barbell, floor)';

	/// en: 'Calf raise (barbell, seated)'
	String get calfRaiseBarbellSeated => 'Calf raise (barbell, seated)';

	/// en: 'Calf raise (barbell, standing)'
	String get calfRaiseBarbellStanding => 'Calf raise (barbell, standing)';

	/// en: 'Calf raise (barbell, standing, rocking leg)'
	String get calfRaiseBarbellStandingRockingLeg => 'Calf raise (barbell, standing, rocking leg)';

	/// en: 'Standing bodyweight calf raise'
	String get standingBodyweightCalfRaise => 'Standing bodyweight calf raise';

	/// en: 'Box drop with single-leg landing'
	String get boxDropWithSingleLegLanding => 'Box drop with single-leg landing';

	/// en: 'Calf raise (cable, standing)'
	String get calfRaiseCableStanding => 'Calf raise (cable, standing)';

	/// en: 'Calf raise (cable, standing, one leg)'
	String get calfRaiseCableStandingOneLeg => 'Calf raise (cable, standing, one leg)';

	/// en: 'Wall calf stretch'
	String get wallCalfStretch => 'Wall calf stretch';

	/// en: 'Calf stretch (rope)'
	String get calfStretchRope => 'Calf stretch (rope)';

	/// en: 'Knee circles'
	String get kneeCircles => 'Knee circles';

	/// en: 'Calf raise (donkey)'
	String get calfRaiseDonkey => 'Calf raise (donkey)';

	/// en: 'Calf raise (dumbbell, seated)'
	String get calfRaiseDumbbellSeated => 'Calf raise (dumbbell, seated)';

	/// en: 'Calf raise (dumbbell, seated, one leg)'
	String get calfRaiseDumbbellSeatedOneLeg => 'Calf raise (dumbbell, seated, one leg)';

	/// en: 'Calf raise (dumbbell, seated, one leg, hammer grip)'
	String get calfRaiseDumbbellSeatedOneLegHammerGrip => 'Calf raise (dumbbell, seated, one leg, hammer grip)';

	/// en: 'Calf raise (dumbbell, seated, one leg, palm up)'
	String get calfRaiseDumbbellSeatedOneLegPalmUp => 'Calf raise (dumbbell, seated, one leg, palm up)';

	/// en: 'Calf raise (dumbbell, one leg)'
	String get calfRaiseDumbbellOneLeg => 'Calf raise (dumbbell, one leg)';

	/// en: 'Calf raise (dumbbell, standing)'
	String get calfRaiseDumbbellStanding => 'Calf raise (dumbbell, standing)';

	/// en: 'Calf raise (exercise ball, wall)'
	String get calfRaiseExerciseBallWall => 'Calf raise (exercise ball, wall)';

	/// en: 'Wall-ball calf raise, ball between ankles'
	String get wallBallCalfRaiseBallBetweenAnkles => 'Wall-ball calf raise, ball between ankles';

	/// en: 'Wall-ball calf raise, ball between knees'
	String get wallBallCalfRaiseBallBetweenKnees => 'Wall-ball calf raise, ball between knees';

	/// en: 'Calf raise (hack)'
	String get calfRaiseHack => 'Calf raise (hack)';

	/// en: 'Calf raise (hack, one leg)'
	String get calfRaiseHackOneLeg => 'Calf raise (hack, one leg)';

	/// en: 'Calf press (lever)'
	String get calfPressLever => 'Calf press (lever)';

	/// en: 'Calf raise (lever, donkey)'
	String get calfRaiseLeverDonkey => 'Calf raise (lever, donkey)';

	/// en: 'Rotary calf machine press'
	String get rotaryCalfMachinePress => 'Rotary calf machine press';

	/// en: 'Calf press (lever, seated)'
	String get calfPressLeverSeated => 'Calf press (lever, seated)';

	/// en: 'Seated squat calf raise on leg press'
	String get seatedSquatCalfRaiseOnLegPress => 'Seated squat calf raise on leg press';

	/// en: 'Calf raise (lever, standing)'
	String get calfRaiseLeverStanding => 'Calf raise (lever, standing)';

	/// en: 'Calf raise (one leg, donkey)'
	String get calfRaiseOneLegDonkey => 'Calf raise (one leg, donkey)';

	/// en: 'Calf raise (one leg, floor)'
	String get calfRaiseOneLegFloor => 'Calf raise (one leg, floor)';

	/// en: 'Peroneals stretch'
	String get peronealsStretch => 'Peroneals stretch';

	/// en: 'Posterior tibialis stretch'
	String get posteriorTibialisStretch => 'Posterior tibialis stretch';

	/// en: 'Calf stretch (seated)'
	String get calfStretchSeated => 'Calf stretch (seated)';

	/// en: 'Calf raise (sled, forward, angled)'
	String get calfRaiseSledForwardAngled => 'Calf raise (sled, forward, angled)';

	/// en: 'Calf press (sled, one leg)'
	String get calfPressSledOneLeg => 'Calf press (sled, one leg)';

	/// en: 'Calf raise (smith, one leg, floor)'
	String get calfRaiseSmithOneLegFloor => 'Calf raise (smith, one leg, floor)';

	/// en: 'Toe raise (smith)'
	String get toeRaiseSmith => 'Toe raise (smith)';

	/// en: 'Calf raise (smith, seated, one leg)'
	String get calfRaiseSmithSeatedOneLeg => 'Calf raise (smith, seated, one leg)';

	/// en: 'Calf raise (standing, staircase)'
	String get calfRaiseStandingStaircase => 'Calf raise (standing, staircase)';

	/// en: 'Calf stretch (standing)'
	String get calfStretchStanding => 'Calf stretch (standing)';

	/// en: 'Calf raise (weighted, donkey)'
	String get calfRaiseWeightedDonkey => 'Calf raise (weighted, donkey)';
}

// Path: library.quadriceps.exercises
class Translations$library$quadriceps$exercises$en {
	Translations$library$quadriceps$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reverse dumbbell lunges'
	String get reverseDumbbellLunges => 'Reverse dumbbell lunges';

	/// en: 'Walking dumbbell lunges'
	String get walkingDumbbellLunges => 'Walking dumbbell lunges';

	/// en: 'Lateral dumbbell lunges'
	String get lateralDumbbellLunges => 'Lateral dumbbell lunges';

	/// en: 'Dumbbell sumo squat'
	String get sumoDumbbellSquat => 'Dumbbell sumo squat';

	/// en: 'Single-leg leg press'
	String get singleLegLegPress => 'Single-leg leg press';

	/// en: 'Smith machine squat'
	String get smithMachineSquats => 'Smith machine squat';

	/// en: 'Step-ups (dumbbells)'
	String get stepUps => 'Step-ups (dumbbells)';

	/// en: 'Goblet squat (dumbbell)'
	String get gobletSquats => 'Goblet squat (dumbbell)';

	/// en: 'Squats (barbell)'
	String get squatsBarbell => 'Squats (barbell)';

	/// en: 'Leg press'
	String get legPress => 'Leg press';

	/// en: 'Leg extension'
	String get legExtension => 'Leg extension';

	/// en: 'Smith machine lunges'
	String get smithMachineLunges => 'Smith machine lunges';

	/// en: 'Dumbbell lunges'
	String get lunges => 'Dumbbell lunges';

	/// en: 'Leg press (45°)'
	String get legPress45deg => 'Leg press (45°)';

	/// en: 'Front squats'
	String get frontSquats => 'Front squats';

	/// en: 'Bulgarian split squats'
	String get bulgarianSplitSquats => 'Bulgarian split squats';

	/// en: 'Bodyweight squat'
	String get bodyweightSquats => 'Bodyweight squat';

	/// en: 'Hack squats'
	String get hackSquats => 'Hack squats';

	/// en: 'Quadriceps stretch (quadruped)'
	String get quadricepsStretchQuadruped => 'Quadriceps stretch (quadruped)';

	/// en: 'Quadriceps stretch (assisted, prone)'
	String get quadricepsStretchAssistedProne => 'Quadriceps stretch (assisted, prone)';

	/// en: 'Backward jump'
	String get backwardJump => 'Backward jump';

	/// en: 'Balance-board stance'
	String get balanceBoardStance => 'Balance-board stance';

	/// en: 'Split squat (band, one arm, one leg)'
	String get splitSquatBandOneArmOneLeg => 'Split squat (band, one arm, one leg)';

	/// en: 'Split squat (band, one leg)'
	String get splitSquatBandOneLeg => 'Split squat (band, one leg)';

	/// en: 'Squat (band)'
	String get squatBand => 'Squat (band)';

	/// en: 'Squat row (band)'
	String get squatRowBand => 'Squat row (band)';

	/// en: 'Step-up (band)'
	String get stepUpBand => 'Step-up (band)';

	/// en: 'Front squat (barbell, bench)'
	String get frontSquatBarbellBench => 'Front squat (barbell, bench)';

	/// en: 'Squat (barbell, bench)'
	String get squatBarbellBench => 'Squat (barbell, bench)';

	/// en: 'Clean and press (barbell)'
	String get cleanAndPressBarbell => 'Clean and press (barbell)';

	/// en: 'Zercher squat (barbell, full)'
	String get zercherSquatBarbellFull => 'Zercher squat (barbell, full)';

	/// en: 'Hack squat (barbell)'
	String get hackSquatBarbell => 'Hack squat (barbell)';

	/// en: 'Squat (barbell, high bar)'
	String get squatBarbellHighBar => 'Squat (barbell, high bar)';

	/// en: 'Jefferson squat (barbell)'
	String get jeffersonSquatBarbell => 'Jefferson squat (barbell)';

	/// en: 'Jump squat (barbell)'
	String get jumpSquatBarbell => 'Jump squat (barbell)';

	/// en: 'Lateral lunge (barbell)'
	String get lateralLungeBarbell => 'Lateral lunge (barbell)';

	/// en: 'Squat (barbell, low bar)'
	String get squatBarbellLowBar => 'Squat (barbell, low bar)';

	/// en: 'Lunge (barbell)'
	String get lungeBarbell => 'Lunge (barbell)';

	/// en: 'Squat (barbell, narrow stance)'
	String get squatBarbellNarrowStance => 'Squat (barbell, narrow stance)';

	/// en: 'Squat (barbell, one leg)'
	String get squatBarbellOneLeg => 'Squat (barbell, one leg)';

	/// en: 'Squat (barbell, overhead)'
	String get squatBarbellOverhead => 'Squat (barbell, overhead)';

	/// en: 'Rear lunge (barbell)'
	String get rearLungeBarbell => 'Rear lunge (barbell)';

	/// en: 'Split squat (barbell, side)'
	String get splitSquatBarbellSide => 'Split squat (barbell, side)';

	/// en: 'Split squat (barbell, one leg)'
	String get splitSquatBarbellOneLeg => 'Split squat (barbell, one leg)';

	/// en: 'Squat (barbell, speed)'
	String get squatBarbellSpeed => 'Squat (barbell, speed)';

	/// en: 'Split squat (barbell)'
	String get splitSquatBarbell => 'Split squat (barbell)';

	/// en: 'Squat (barbell, knee)'
	String get squatBarbellKnee => 'Squat (barbell, knee)';

	/// en: 'Barbell squat jump into reverse lunge'
	String get barbellSquatJumpIntoReverseLunge => 'Barbell squat jump into reverse lunge';

	/// en: 'Step-up (barbell)'
	String get stepUpBarbell => 'Step-up (barbell)';

	/// en: 'Squat (barbell, wide)'
	String get squatBarbellWide => 'Squat (barbell, wide)';

	/// en: 'Zercher squat (barbell)'
	String get zercherSquatBarbell => 'Zercher squat (barbell)';

	/// en: 'Jump squat (bodyweight, drop)'
	String get jumpSquatBodyweightDrop => 'Jump squat (bodyweight, drop)';

	/// en: 'Chair-supported quadriceps stretch'
	String get chairSupportedQuadricepsStretch => 'Chair-supported quadriceps stretch';

	/// en: 'Curtsy squat'
	String get curtsySquat => 'Curtsy squat';

	/// en: 'Squat (dumbbell, bench)'
	String get squatDumbbellBench => 'Squat (dumbbell, bench)';

	/// en: 'Lunge (dumbbell, contralateral forward)'
	String get lungeDumbbellContralateralForward => 'Lunge (dumbbell, contralateral forward)';

	/// en: 'Squat (dumbbell, plyo)'
	String get squatDumbbellPlyo => 'Squat (dumbbell, plyo)';

	/// en: 'Squat (dumbbell, pistol)'
	String get squatDumbbellPistol => 'Squat (dumbbell, pistol)';

	/// en: 'Squat (dumbbell)'
	String get squatDumbbell => 'Squat (dumbbell)';

	/// en: 'Step up lunge (dumbbell)'
	String get stepUpLungeDumbbell => 'Step up lunge (dumbbell)';

	/// en: 'Step up split squat (dumbbell)'
	String get stepUpSplitSquatDumbbell => 'Step up split squat (dumbbell)';

	/// en: 'Squat (dumbbell, supported)'
	String get squatDumbbellSupported => 'Squat (dumbbell, supported)';

	/// en: 'Farmers walk'
	String get farmersWalk => 'Farmers walk';

	/// en: 'Forward jump'
	String get forwardJump => 'Forward jump';

	/// en: 'Lunge (forward)'
	String get lungeForward => 'Lunge (forward)';

	/// en: 'Squat (frankenstein)'
	String get squatFrankenstein => 'Squat (frankenstein)';

	/// en: 'Kneeling hip-flexor and quadriceps stretch'
	String get kneelingHipFlexorAndQuadricepsStretch => 'Kneeling hip-flexor and quadriceps stretch';

	/// en: 'Front squat (kettlebell)'
	String get frontSquatKettlebell => 'Front squat (kettlebell)';

	/// en: 'Squat (kettlebell, goblet)'
	String get squatKettlebellGoblet => 'Squat (kettlebell, goblet)';

	/// en: 'Lunge (kettlebell, pass through)'
	String get lungeKettlebellPassThrough => 'Lunge (kettlebell, pass through)';

	/// en: 'Squat (kettlebell, pistol)'
	String get squatKettlebellPistol => 'Squat (kettlebell, pistol)';

	/// en: 'Kettlebell Turkish get-up through squat'
	String get kettlebellTurkishGetUpThroughSquat => 'Kettlebell Turkish get-up through squat';

	/// en: 'Jump squat (kneeling)'
	String get jumpSquatKneeling => 'Jump squat (kneeling)';

	/// en: 'Lunge (jump)'
	String get lungeJump => 'Lunge (jump)';

	/// en: 'Quads stretch (lying, side)'
	String get quadsStretchLyingSide => 'Quads stretch (lying, side)';

	/// en: 'Squat (one leg)'
	String get squatOneLeg => 'Squat (one leg)';

	/// en: 'Squat (potty, support)'
	String get squatPottySupport => 'Squat (potty, support)';

	/// en: 'Rapid alternating foot taps'
	String get rapidAlternatingFootTaps => 'Rapid alternating foot taps';

	/// en: 'Leg extension (resistance band)'
	String get legExtensionResistanceBand => 'Leg extension (resistance band)';

	/// en: 'Squat (pistol)'
	String get squatPistol => 'Squat (pistol)';

	/// en: 'Sissy squat'
	String get sissySquat => 'Sissy squat';

	/// en: 'Hack squat (sled, closer)'
	String get hackSquatSledCloser => 'Hack squat (sled, closer)';

	/// en: 'Squat (sled, lying)'
	String get squatSledLying => 'Squat (sled, lying)';

	/// en: 'Squat (smith, chair)'
	String get squatSmithChair => 'Squat (smith, chair)';

	/// en: 'Front squat (smith, clean grip)'
	String get frontSquatSmithCleanGrip => 'Front squat (smith, clean grip)';

	/// en: 'Hack squat (smith)'
	String get hackSquatSmith => 'Hack squat (smith)';

	/// en: 'Squat (smith, low bar)'
	String get squatSmithLowBar => 'Squat (smith, low bar)';

	/// en: 'Split squat (smith, one leg)'
	String get splitSquatSmithOneLeg => 'Split squat (smith, one leg)';

	/// en: 'Lunge (smith, sprint)'
	String get lungeSmithSprint => 'Lunge (smith, sprint)';

	/// en: 'Squat (smith, sumo)'
	String get squatSmithSumo => 'Squat (smith, sumo)';

	/// en: 'Snatch pull'
	String get snatchPull => 'Snatch pull';

	/// en: 'Split squat'
	String get splitSquat => 'Split squat';

	/// en: 'Squat jerk'
	String get squatJerk => 'Squat jerk';

	/// en: 'Squat (bosu ball)'
	String get squatBosuBall => 'Squat (bosu ball)';

	/// en: 'Squat (to overhead reach)'
	String get squatToOverheadReach => 'Squat (to overhead reach)';

	/// en: 'Squat (to overhead reach twist)'
	String get squatToOverheadReachTwist => 'Squat (to overhead reach twist)';

	/// en: 'Split squat (suspended)'
	String get splitSquatSuspended => 'Split squat (suspended)';

	/// en: 'Lunge (walking)'
	String get lungeWalking => 'Lunge (walking)';

	/// en: 'Squat (weighted, cossack)'
	String get squatWeightedCossack => 'Squat (weighted, cossack)';

	/// en: 'Weighted lunge with arm swing'
	String get weightedLungeWithArmSwing => 'Weighted lunge with arm swing';

	/// en: 'Sissy squat (weighted)'
	String get sissySquatWeighted => 'Sissy squat (weighted)';

	/// en: 'Squat (weighted)'
	String get squatWeighted => 'Squat (weighted)';

	/// en: 'Lunge (weighted)'
	String get lungeWeighted => 'Lunge (weighted)';
}

// Path: library.hamstrings.exercises
class Translations$library$hamstrings$exercises$en {
	Translations$library$hamstrings$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Single-leg dumbbell Romanian deadlift'
	String get singleLegDumbbellRomanianDeadlift => 'Single-leg dumbbell Romanian deadlift';

	/// en: 'Standing machine leg curl'
	String get legCurlStanding => 'Standing machine leg curl';

	/// en: 'Nordic curl'
	String get nordicCurl => 'Nordic curl';

	/// en: 'Leg curl (prone)'
	String get legCurlProne => 'Leg curl (prone)';

	/// en: 'Leg curl (seated)'
	String get legCurlSeated => 'Leg curl (seated)';

	/// en: 'Romanian deadlift (barbell)'
	String get romanianDeadlift => 'Romanian deadlift (barbell)';

	/// en: 'Romanian deadlift (dumbbells)'
	String get romanianDeadliftDumbbell => 'Romanian deadlift (dumbbells)';

	/// en: 'Hamstring stretch (assisted, prone)'
	String get hamstringStretchAssistedProne => 'Hamstring stretch (assisted, prone)';

	/// en: 'Straight leg deadlift (band)'
	String get straightLegDeadliftBand => 'Straight leg deadlift (band)';

	/// en: 'Good morning (barbell)'
	String get goodMorningBarbell => 'Good morning (barbell)';

	/// en: 'Good morning (barbell, seated)'
	String get goodMorningBarbellSeated => 'Good morning (barbell, seated)';

	/// en: 'Good morning (barbell, straight leg)'
	String get goodMorningBarbellStraightLeg => 'Good morning (barbell, straight leg)';

	/// en: 'Straight leg deadlift (barbell)'
	String get straightLegDeadliftBarbell => 'Straight leg deadlift (barbell)';

	/// en: 'Leg curl (cable, assisted, inverse)'
	String get legCurlCableAssistedInverse => 'Leg curl (cable, assisted, inverse)';

	/// en: 'Leg curl (dumbbell, lying)'
	String get legCurlDumbbellLying => 'Leg curl (dumbbell, lying)';

	/// en: 'Straight leg deadlift (dumbbell)'
	String get straightLegDeadliftDumbbell => 'Straight leg deadlift (dumbbell)';

	/// en: 'Hamstring stretch (exercise ball, seated)'
	String get hamstringStretchExerciseBallSeated => 'Hamstring stretch (exercise ball, seated)';

	/// en: 'Glute-ham raise on bench'
	String get gluteHamRaiseOnBench => 'Glute-ham raise on bench';

	/// en: 'Hamstring stretch'
	String get hamstringStretch => 'Hamstring stretch';

	/// en: 'Hang clean (kettlebell)'
	String get hangCleanKettlebell => 'Hang clean (kettlebell)';

	/// en: 'Elevated-leg hamstring stretch'
	String get elevatedLegHamstringStretch => 'Elevated-leg hamstring stretch';

	/// en: 'Leg curl (lever, kneeling)'
	String get legCurlLeverKneeling => 'Leg curl (lever, kneeling)';

	/// en: 'Leg curl (lever, lying, two one)'
	String get legCurlLeverLyingTwoOne => 'Leg curl (lever, lying, two one)';

	/// en: 'Good morning (lever, seated)'
	String get goodMorningLeverSeated => 'Good morning (lever, seated)';

	/// en: 'Clean (power)'
	String get cleanPower => 'Clean (power)';

	/// en: 'Supine strap-assisted hamstring stretch'
	String get supineStrapAssistedHamstringStretch => 'Supine strap-assisted hamstring stretch';

	/// en: 'Runner’s hamstring stretch'
	String get runnerSHamstringStretch => 'Runner’s hamstring stretch';

	/// en: 'Seated wide-leg forward-fold sequence'
	String get seatedWideLegForwardFoldSequence => 'Seated wide-leg forward-fold sequence';

	/// en: 'Single-leg sliding curl'
	String get singleLegSlidingCurl => 'Single-leg sliding curl';

	/// en: 'Good morning (smith, bent knee)'
	String get goodMorningSmithBentKnee => 'Good morning (smith, bent knee)';

	/// en: 'Strap-assisted hamstring and calf stretch'
	String get strapAssistedHamstringAndCalfStretch => 'Strap-assisted hamstring and calf stretch';

	/// en: 'Leg curl (standing)'
	String get legCurlStandingBodyweight => 'Leg curl (standing)';

	/// en: 'Lunge stretch with thoracic rotation'
	String get lungeStretchWithThoracicRotation => 'Lunge stretch with thoracic rotation';
}

// Path: library.shoulders.exercises
class Translations$library$shoulders$exercises$en {
	Translations$library$shoulders$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Standing cable reverse fly'
	String get standingCableReverseFly => 'Standing cable reverse fly';

	/// en: 'Cable front raise'
	String get cableFrontRaise => 'Cable front raise';

	/// en: 'Dumbbell shrugs'
	String get dumbbellShrugs => 'Dumbbell shrugs';

	/// en: 'Cable face pull'
	String get facePull => 'Cable face pull';

	/// en: 'Shoulder press (machine)'
	String get shoulderPressMachine => 'Shoulder press (machine)';

	/// en: 'Lateral raises (inclined bench)'
	String get latRaisesInclinedBench => 'Lateral raises (inclined bench)';

	/// en: 'Lateral raises (cable)'
	String get latRaisesCable => 'Lateral raises (cable)';

	/// en: 'Lateral raises (cable, both arms)'
	String get latRaisesDualCable => 'Lateral raises (cable, both arms)';

	/// en: 'Reverse flyes (inclined bench)'
	String get reverseFlysInclinedBench => 'Reverse flyes (inclined bench)';

	/// en: 'Arnold press'
	String get arnoldPress => 'Arnold press';

	/// en: 'Front dumbbell raise'
	String get frontDumbbellRaise => 'Front dumbbell raise';

	/// en: 'Upright row'
	String get uprightRow => 'Upright row';

	/// en: 'Pike push-ups'
	String get pikePushUps => 'Pike push-ups';

	/// en: 'Handstand push-ups'
	String get handstandPushUps => 'Handstand push-ups';

	/// en: 'Bent-over cable reverse fly'
	String get bentOverLateralRaises => 'Bent-over cable reverse fly';

	/// en: 'Dumbbell shoulder press'
	String get shoulderPress => 'Dumbbell shoulder press';

	/// en: 'Lateral raises (dumbbells)'
	String get latRaisesDumbbells => 'Lateral raises (dumbbells)';

	/// en: 'Deltoid machine'
	String get deltoidMachine => 'Deltoid machine';

	/// en: 'Front shrugs (barbell)'
	String get shrugsBarbell => 'Front shrugs (barbell)';

	/// en: 'Smith machine military press'
	String get militaryPressSmithMachine => 'Smith machine military press';

	/// en: 'Reverse pec deck fly'
	String get reverseButterfly => 'Reverse pec deck fly';

	/// en: 'Barbell military press'
	String get militaryPressBarbell => 'Barbell military press';

	/// en: 'Front lateral raise (band)'
	String get frontLateralRaiseBand => 'Front lateral raise (band)';

	/// en: 'Front raise (band)'
	String get frontRaiseBand => 'Front raise (band)';

	/// en: 'Reverse fly (band)'
	String get reverseFlyBand => 'Reverse fly (band)';

	/// en: 'Shoulder press (band)'
	String get shoulderPressBand => 'Shoulder press (band)';

	/// en: 'Shrug (band)'
	String get shrugBand => 'Shrug (band)';

	/// en: 'Rear delt row (band, standing)'
	String get rearDeltRowBandStanding => 'Rear delt row (band, standing)';

	/// en: 'Overhead press (band, twisting)'
	String get overheadPressBandTwisting => 'Overhead press (band, twisting)';

	/// en: 'Y raise (band)'
	String get yRaiseBand => 'Y raise (band)';

	/// en: 'Front raise (barbell)'
	String get frontRaiseBarbell => 'Front raise (barbell)';

	/// en: 'Front raise and pullover (barbell)'
	String get frontRaiseAndPulloverBarbell => 'Front raise and pullover (barbell)';

	/// en: 'Shoulder press (barbell, incline)'
	String get shoulderPressBarbellIncline => 'Shoulder press (barbell, incline)';

	/// en: 'Snatch (barbell, one arm)'
	String get snatchBarbellOneArm => 'Snatch (barbell, one arm)';

	/// en: 'Rear delt raise (barbell)'
	String get rearDeltRaiseBarbell => 'Rear delt raise (barbell)';

	/// en: 'Rear delt row (barbell)'
	String get rearDeltRowBarbell => 'Rear delt row (barbell)';

	/// en: 'Military press (barbell, seated, behind head)'
	String get militaryPressBarbellSeatedBehindHead => 'Military press (barbell, seated, behind head)';

	/// en: 'Bradford press (barbell, seated)'
	String get bradfordPressBarbellSeated => 'Bradford press (barbell, seated)';

	/// en: 'Barbell ski-style high pull'
	String get barbellSkiStyleHighPull => 'Barbell ski-style high pull';

	/// en: 'Bradford press (barbell, standing)'
	String get bradfordPressBarbellStanding => 'Bradford press (barbell, standing)';

	/// en: 'Military press (barbell, standing, close grip)'
	String get militaryPressBarbellStandingCloseGrip => 'Military press (barbell, standing, close grip)';

	/// en: 'Front raise (barbell, standing, over head)'
	String get frontRaiseBarbellStandingOverHead => 'Front raise (barbell, standing, over head)';

	/// en: 'Military press (barbell, standing, wide)'
	String get militaryPressBarbellStandingWide => 'Military press (barbell, standing, wide)';

	/// en: 'Thruster (barbell)'
	String get thrusterBarbell => 'Thruster (barbell)';

	/// en: 'Upright row (barbell, wide grip)'
	String get uprightRowBarbellWideGrip => 'Upright row (barbell, wide grip)';

	/// en: 'Battling ropes'
	String get battlingRopes => 'Battling ropes';

	/// en: 'Shoulder press (cable, alternate)'
	String get shoulderPressCableAlternate => 'Shoulder press (cable, alternate)';

	/// en: 'Rear delt row (cable, kneeling, rope)'
	String get rearDeltRowCableKneelingRope => 'Rear delt row (cable, kneeling, rope)';

	/// en: 'Reverse fly (cable, one arm, bent over)'
	String get reverseFlyCableOneArmBentOver => 'Reverse fly (cable, one arm, bent over)';

	/// en: 'Rear delt row (cable, stirrups)'
	String get rearDeltRowCableStirrups => 'Rear delt row (cable, stirrups)';

	/// en: 'Rear delt row (cable, rope)'
	String get rearDeltRowCableRope => 'Rear delt row (cable, rope)';

	/// en: 'Rear lateral raise (cable, seated)'
	String get rearLateralRaiseCableSeated => 'Rear lateral raise (cable, seated)';

	/// en: 'Shoulder internal rotation (cable, seated)'
	String get shoulderInternalRotationCableSeated => 'Shoulder internal rotation (cable, seated)';

	/// en: 'Shoulder press (cable)'
	String get shoulderPressCable => 'Shoulder press (cable)';

	/// en: 'Shrug (cable)'
	String get shrugCable => 'Shrug (cable)';

	/// en: 'Rear delt row (cable, standing, rope)'
	String get rearDeltRowCableStandingRope => 'Rear delt row (cable, standing, rope)';

	/// en: 'Shoulder external rotation (cable, standing)'
	String get shoulderExternalRotationCableStanding => 'Shoulder external rotation (cable, standing)';

	/// en: 'Reverse fly (cable, supine)'
	String get reverseFlyCableSupine => 'Reverse fly (cable, supine)';

	/// en: 'Upright row (cable)'
	String get uprightRowCable => 'Upright row (cable)';

	/// en: 'Press (dumbbell, alternate, side)'
	String get pressDumbbellAlternateSide => 'Press (dumbbell, alternate, side)';

	/// en: 'Cuban press (dumbbell)'
	String get cubanPressDumbbell => 'Cuban press (dumbbell)';

	/// en: 'Shrug (dumbbell, decline)'
	String get shrugDumbbellDecline => 'Shrug (dumbbell, decline)';

	/// en: 'Lateral raise (dumbbell, full can)'
	String get lateralRaiseDumbbellFullCan => 'Lateral raise (dumbbell, full can)';

	/// en: 'Shoulder press (dumbbell, incline)'
	String get shoulderPressDumbbellIncline => 'Shoulder press (dumbbell, incline)';

	/// en: 'Shrug (dumbbell, incline)'
	String get shrugDumbbellIncline => 'Shrug (dumbbell, incline)';

	/// en: 'T raise (dumbbell, incline)'
	String get tRaiseDumbbellIncline => 'T raise (dumbbell, incline)';

	/// en: 'Lateral to front raise (dumbbell)'
	String get lateralToFrontRaiseDumbbell => 'Lateral to front raise (dumbbell)';

	/// en: 'External shoulder rotation (dumbbell, lying)'
	String get externalShoulderRotationDumbbellLying => 'External shoulder rotation (dumbbell, lying)';

	/// en: 'Rear delt raise (dumbbell, lying, floor)'
	String get rearDeltRaiseDumbbellLyingFloor => 'Rear delt raise (dumbbell, lying, floor)';

	/// en: 'Rear delt raise (dumbbell, lying, one arm)'
	String get rearDeltRaiseDumbbellLyingOneArm => 'Rear delt raise (dumbbell, lying, one arm)';

	/// en: 'Reverse fly (dumbbell, lying, one arm)'
	String get reverseFlyDumbbellLyingOneArm => 'Reverse fly (dumbbell, lying, one arm)';

	/// en: 'Rear delt row (dumbbell, lying)'
	String get rearDeltRowDumbbellLying => 'Rear delt row (dumbbell, lying)';

	/// en: 'Reverse fly (dumbbell, lying)'
	String get reverseFlyDumbbellLying => 'Reverse fly (dumbbell, lying)';

	/// en: 'Lateral raise (dumbbell, one arm)'
	String get lateralRaiseDumbbellOneArm => 'Lateral raise (dumbbell, one arm)';

	/// en: 'Lateral raise (dumbbell, one arm, support)'
	String get lateralRaiseDumbbellOneArmSupport => 'Lateral raise (dumbbell, one arm, support)';

	/// en: 'Reverse fly (dumbbell, one arm, support)'
	String get reverseFlyDumbbellOneArmSupport => 'Reverse fly (dumbbell, one arm, support)';

	/// en: 'Shoulder press (dumbbell, one arm)'
	String get shoulderPressDumbbellOneArm => 'Shoulder press (dumbbell, one arm)';

	/// en: 'Upright row (dumbbell, one arm)'
	String get uprightRowDumbbellOneArm => 'Upright row (dumbbell, one arm)';

	/// en: 'Push press (dumbbell)'
	String get pushPressDumbbell => 'Push press (dumbbell)';

	/// en: 'Reverse fly (dumbbell, bent over)'
	String get reverseFlyDumbbellBentOver => 'Reverse fly (dumbbell, bent over)';

	/// en: 'Rear delt row (dumbbell)'
	String get rearDeltRowDumbbell => 'Rear delt row (dumbbell)';

	/// en: 'Rear lateral raise (dumbbell, support head)'
	String get rearLateralRaiseDumbbellSupportHead => 'Rear lateral raise (dumbbell, support head)';

	/// en: 'Reverse fly (dumbbell, rotation)'
	String get reverseFlyDumbbellRotation => 'Reverse fly (dumbbell, rotation)';

	/// en: 'Scott press (dumbbell)'
	String get scottPressDumbbell => 'Scott press (dumbbell)';

	/// en: 'Front raise (dumbbell, seated, alternate)'
	String get frontRaiseDumbbellSeatedAlternate => 'Front raise (dumbbell, seated, alternate)';

	/// en: 'Shoulder press (dumbbell, seated, alternate)'
	String get shoulderPressDumbbellSeatedAlternate => 'Shoulder press (dumbbell, seated, alternate)';

	/// en: 'Lateral raise (dumbbell, seated, bent arm)'
	String get lateralRaiseDumbbellSeatedBentArm => 'Lateral raise (dumbbell, seated, bent arm)';

	/// en: 'Biceps curl to shoulder press (dumbbell, seated)'
	String get bicepsCurlToShoulderPressDumbbellSeated => 'Biceps curl to shoulder press (dumbbell, seated)';

	/// en: 'Front raise (dumbbell, seated)'
	String get frontRaiseDumbbellSeated => 'Front raise (dumbbell, seated)';

	/// en: 'Lateral raise (dumbbell, seated)'
	String get lateralRaiseDumbbellSeated => 'Lateral raise (dumbbell, seated)';

	/// en: 'Shoulder press (dumbbell, seated, neutral grip)'
	String get shoulderPressDumbbellSeatedNeutralGrip => 'Shoulder press (dumbbell, seated, neutral grip)';

	/// en: 'Lateral raise (dumbbell, side lying, one arm)'
	String get lateralRaiseDumbbellSideLyingOneArm => 'Lateral raise (dumbbell, side lying, one arm)';

	/// en: 'Reverse fly (dumbbell, side plank)'
	String get reverseFlyDumbbellSidePlank => 'Reverse fly (dumbbell, side plank)';

	/// en: 'Single-arm overhead dumbbell carry'
	String get singleArmOverheadDumbbellCarry => 'Single-arm overhead dumbbell carry';

	/// en: 'Overhead press (dumbbell, standing, alternate)'
	String get overheadPressDumbbellStandingAlternate => 'Overhead press (dumbbell, standing, alternate)';

	/// en: 'Lateral raise (dumbbell, standing, alternate)'
	String get lateralRaiseDumbbellStandingAlternate => 'Lateral raise (dumbbell, standing, alternate)';

	/// en: 'Standing dumbbell arm circles'
	String get standingDumbbellArmCircles => 'Standing dumbbell arm circles';

	/// en: 'Front raise (dumbbell, standing, above head)'
	String get frontRaiseDumbbellStandingAboveHead => 'Front raise (dumbbell, standing, above head)';

	/// en: 'Press (dumbbell, standing, one arm, neutral grip)'
	String get pressDumbbellStandingOneArmNeutralGrip => 'Press (dumbbell, standing, one arm, neutral grip)';

	/// en: 'Overhead press (dumbbell, standing)'
	String get overheadPressDumbbellStanding => 'Overhead press (dumbbell, standing)';

	/// en: 'Press (dumbbell, standing, neutral grip)'
	String get pressDumbbellStandingNeutralGrip => 'Press (dumbbell, standing, neutral grip)';

	/// en: 'Upright row (dumbbell)'
	String get uprightRowDumbbell => 'Upright row (dumbbell)';

	/// en: 'Shoulder external rotation (dumbbell, upright)'
	String get shoulderExternalRotationDumbbellUpright => 'Shoulder external rotation (dumbbell, upright)';

	/// en: 'W press (dumbbell)'
	String get wPressDumbbell => 'W press (dumbbell)';

	/// en: 'Front raise (dumbbell, seated, alternate, exercise ball)'
	String get frontRaiseDumbbellSeatedAlternateExerciseBall => 'Front raise (dumbbell, seated, alternate, exercise ball)';

	/// en: 'Shoulder press (ez barbell)'
	String get shoulderPressEzBarbell => 'Shoulder press (ez barbell)';

	/// en: 'Frog stand'
	String get frogStand => 'Frog stand';

	/// en: 'Full Maltese hold'
	String get fullMalteseHold => 'Full Maltese hold';

	/// en: 'Full planche hold'
	String get fullPlancheHold => 'Full planche hold';

	/// en: 'Push-up (full, planche)'
	String get pushUpFullPlanche => 'Push-up (full, planche)';

	/// en: 'Handstand'
	String get handstand => 'Handstand';

	/// en: 'Press (kettlebell, alternate)'
	String get pressKettlebellAlternate => 'Press (kettlebell, alternate)';

	/// en: 'Arnold press (kettlebell)'
	String get arnoldPressKettlebell => 'Arnold press (kettlebell)';

	/// en: 'Jerk (kettlebell, double)'
	String get jerkKettlebellDouble => 'Jerk (kettlebell, double)';

	/// en: 'Push press (kettlebell, double)'
	String get pushPressKettlebellDouble => 'Push press (kettlebell, double)';

	/// en: 'Snatch (kettlebell, double)'
	String get snatchKettlebellDouble => 'Snatch (kettlebell, double)';

	/// en: 'Clean and jerk (kettlebell, one arm)'
	String get cleanAndJerkKettlebellOneArm => 'Clean and jerk (kettlebell, one arm)';

	/// en: 'Jerk (kettlebell, one arm)'
	String get jerkKettlebellOneArm => 'Jerk (kettlebell, one arm)';

	/// en: 'Military press (kettlebell, one arm, to side)'
	String get militaryPressKettlebellOneArmToSide => 'Military press (kettlebell, one arm, to side)';

	/// en: 'Push press (kettlebell, one arm)'
	String get pushPressKettlebellOneArm => 'Push press (kettlebell, one arm)';

	/// en: 'Snatch (kettlebell, one arm)'
	String get snatchKettlebellOneArm => 'Snatch (kettlebell, one arm)';

	/// en: 'Clean and press (kettlebell, one arm)'
	String get cleanAndPressKettlebellOneArm => 'Clean and press (kettlebell, one arm)';

	/// en: 'Press (kettlebell, seated)'
	String get pressKettlebellSeated => 'Press (kettlebell, seated)';

	/// en: 'Military press (kettlebell, seated, two arm)'
	String get militaryPressKettlebellSeatedTwoArm => 'Military press (kettlebell, seated, two arm)';

	/// en: 'Press (kettlebell, seesaw)'
	String get pressKettlebellSeesaw => 'Press (kettlebell, seesaw)';

	/// en: 'Sumo high pull (kettlebell)'
	String get sumoHighPullKettlebell => 'Sumo high pull (kettlebell)';

	/// en: 'Thruster (kettlebell)'
	String get thrusterKettlebell => 'Thruster (kettlebell)';

	/// en: 'Clean (kettlebell, two arm)'
	String get cleanKettlebellTwoArm => 'Clean (kettlebell, two arm)';

	/// en: 'Military press (kettlebell, two arm)'
	String get militaryPressKettlebellTwoArm => 'Military press (kettlebell, two arm)';

	/// en: 'Lateral raise (landmine)'
	String get lateralRaiseLandmine => 'Lateral raise (landmine)';

	/// en: 'Planche (lean)'
	String get plancheLean => 'Planche (lean)';

	/// en: 'Boxing left hook'
	String get boxingLeftHook => 'Boxing left hook';

	/// en: 'Shrug (lever, gripless)'
	String get shrugLeverGripless => 'Shrug (lever, gripless)';

	/// en: 'Shoulder press (lever, one arm)'
	String get shoulderPressLeverOneArm => 'Shoulder press (lever, one arm)';

	/// en: 'Reverse fly (lever, seated, neutral grip)'
	String get reverseFlyLeverSeatedNeutralGrip => 'Reverse fly (lever, seated, neutral grip)';

	/// en: 'Shrug (lever)'
	String get shrugLever => 'Shrug (lever)';

	/// en: 'Rear deltoid stretch'
	String get rearDeltoidStretch => 'Rear deltoid stretch';

	/// en: 'Shoulder press (resistance band, seated)'
	String get shoulderPressResistanceBandSeated => 'Shoulder press (resistance band, seated)';

	/// en: 'Scapular dips'
	String get scapularDips => 'Scapular dips';

	/// en: 'Scapular pull up'
	String get scapularPullUp => 'Scapular pull up';

	/// en: 'Shrug (smith, back)'
	String get shrugSmithBack => 'Shrug (smith, back)';

	/// en: 'Press (smith, behind neck)'
	String get pressSmithBehindNeck => 'Press (smith, behind neck)';

	/// en: 'Rear delt row (smith)'
	String get rearDeltRowSmith => 'Rear delt row (smith)';

	/// en: 'Shoulder press (smith, seated)'
	String get shoulderPressSmithSeated => 'Shoulder press (smith, seated)';

	/// en: 'Shoulder press (smith)'
	String get shoulderPressSmith => 'Shoulder press (smith)';

	/// en: 'Shrug (smith)'
	String get shrugSmith => 'Shrug (smith)';

	/// en: 'Military press (smith, standing, behind head)'
	String get militaryPressSmithStandingBehindHead => 'Military press (smith, standing, behind head)';

	/// en: 'Upright row (smith)'
	String get uprightRowSmith => 'Upright row (smith)';

	/// en: 'Press (standing, behind neck)'
	String get pressStandingBehindNeck => 'Press (standing, behind neck)';

	/// en: 'Straddle Maltese hold'
	String get straddleMalteseHold => 'Straddle Maltese hold';

	/// en: 'Straddle planche hold'
	String get straddlePlancheHold => 'Straddle planche hold';

	/// en: 'Front raise (weighted)'
	String get frontRaiseWeighted => 'Front raise (weighted)';

	/// en: 'Weighted kneeling step and swing'
	String get weightedKneelingStepAndSwing => 'Weighted kneeling step and swing';
}

// Path: library.back.exercises
class Translations$library$back$exercises$en {
	Translations$library$back$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Chest-supported dumbbell row'
	String get chestSupportedDumbbellRow => 'Chest-supported dumbbell row';

	/// en: 'Single-arm cable row'
	String get singleArmCableRow => 'Single-arm cable row';

	/// en: 'Ring row'
	String get ringRow => 'Ring row';

	/// en: 'Dumbbell pullover'
	String get dumbbellPullover => 'Dumbbell pullover';

	/// en: 'Machine-assisted pull-ups'
	String get machineAssistedPullUps => 'Machine-assisted pull-ups';

	/// en: 'Hyperextensions'
	String get hyperExtensions => 'Hyperextensions';

	/// en: 'Hyperextensions (weighted)'
	String get weightedHyperExtensions => 'Hyperextensions (weighted)';

	/// en: 'Barbell row'
	String get barbellRow => 'Barbell row';

	/// en: 'Lat pulldowns (triangle bar)'
	String get triangleBarLatPulldowns => 'Lat pulldowns (triangle bar)';

	/// en: 'Lat pulldowns (underhand grip)'
	String get underhandGripLatPulldowns => 'Lat pulldowns (underhand grip)';

	/// en: 'Lat pulldowns'
	String get latPulldowns => 'Lat pulldowns';

	/// en: 'Cable seated row (triangle bar)'
	String get cableSeatedRowTriangleBar => 'Cable seated row (triangle bar)';

	/// en: 'Straight-arm cable pushdowns'
	String get straightArmCablePushdown => 'Straight-arm cable pushdowns';

	/// en: 'Deadlift'
	String get deadlift => 'Deadlift';

	/// en: 'Pull-ups'
	String get pullUps => 'Pull-ups';

	/// en: 'T-Bar row'
	String get tBarRow => 'T-Bar row';

	/// en: 'Seated row machine'
	String get rowMachine => 'Seated row machine';

	/// en: 'Lat pulldowns (wide grip)'
	String get latPulldownsWideGrip => 'Lat pulldowns (wide grip)';

	/// en: 'Lat pulldowns (narrow grip)'
	String get latPulldownsNarrowGrip => 'Lat pulldowns (narrow grip)';

	/// en: 'T-bar machine row (wide overhand grip)'
	String get tBarRowWideProneGrip => 'T-bar machine row (wide overhand grip)';

	/// en: 'Dumbbell row'
	String get dumbbellRow => 'Dumbbell row';

	/// en: 'Chin-ups'
	String get chinUps => 'Chin-ups';

	/// en: 'Pulldown (cable, alternate)'
	String get pulldownCableAlternate => 'Pulldown (cable, alternate)';

	/// en: 'Pull-up (archer)'
	String get pullUpArcher => 'Pull-up (archer)';

	/// en: 'Pull-up (assisted, parallel, close grip)'
	String get pullUpAssistedParallelCloseGrip => 'Pull-up (assisted, parallel, close grip)';

	/// en: 'Chin-up (assisted, standing)'
	String get chinUpAssistedStanding => 'Chin-up (assisted, standing)';

	/// en: 'Pull-up (assisted, standing)'
	String get pullUpAssistedStanding => 'Pull-up (assisted, standing)';

	/// en: 'Back extension (exercise ball)'
	String get backExtensionExerciseBall => 'Back extension (exercise ball)';

	/// en: 'Back lever'
	String get backLever => 'Back lever';

	/// en: 'Chest stretch with arms behind the back'
	String get chestStretchWithArmsBehindTheBack => 'Chest stretch with arms behind the back';

	/// en: 'Pull-up (band, assisted)'
	String get pullUpBandAssisted => 'Pull-up (band, assisted)';

	/// en: 'Pulldown (band, close grip)'
	String get pulldownBandCloseGrip => 'Pulldown (band, close grip)';

	/// en: 'Pulldown (band, fixed back, close grip)'
	String get pulldownBandFixedBackCloseGrip => 'Pulldown (band, fixed back, close grip)';

	/// en: 'Pulldown (band, fixed back, underhand)'
	String get pulldownBandFixedBackUnderhand => 'Pulldown (band, fixed back, underhand)';

	/// en: 'Pulldown (band, kneeling, one arm)'
	String get pulldownBandKneelingOneArm => 'Pulldown (band, kneeling, one arm)';

	/// en: 'Row (band, one arm, standing, low)'
	String get rowBandOneArmStandingLow => 'Row (band, one arm, standing, low)';

	/// en: 'Row (band, one arm, twisting, seated)'
	String get rowBandOneArmTwistingSeated => 'Row (band, one arm, twisting, seated)';

	/// en: 'Pulldown (band, underhand)'
	String get pulldownBandUnderhand => 'Pulldown (band, underhand)';

	/// en: 'Pullover (barbell, bent arm)'
	String get pulloverBarbellBentArm => 'Pullover (barbell, bent arm)';

	/// en: 'Pullover (barbell, decline, bent arm)'
	String get pulloverBarbellDeclineBentArm => 'Pullover (barbell, decline, bent arm)';

	/// en: 'Pullover (barbell, decline, wide grip)'
	String get pulloverBarbellDeclineWideGrip => 'Pullover (barbell, decline, wide grip)';

	/// en: 'Row (barbell, incline)'
	String get rowBarbellIncline => 'Row (barbell, incline)';

	/// en: 'Bent over row (barbell, one arm)'
	String get bentOverRowBarbellOneArm => 'Bent over row (barbell, one arm)';

	/// en: 'Pendlay row (barbell)'
	String get pendlayRowBarbell => 'Pendlay row (barbell)';

	/// en: 'Pullover (barbell)'
	String get pulloverBarbell => 'Pullover (barbell)';

	/// en: 'Pullover to press (barbell)'
	String get pulloverToPressBarbell => 'Pullover to press (barbell)';

	/// en: 'Bent over row (barbell, reverse grip)'
	String get bentOverRowBarbellReverseGrip => 'Bent over row (barbell, reverse grip)';

	/// en: 'Bench row (barbell, reverse grip, incline)'
	String get benchRowBarbellReverseGripIncline => 'Bench row (barbell, reverse grip, incline)';

	/// en: 'Bench-supported pull-up'
	String get benchSupportedPullUp => 'Bench-supported pull-up';

	/// en: 'Row (bodyweight, squatting)'
	String get rowBodyweightSquatting => 'Row (bodyweight, squatting)';

	/// en: 'Row (bodyweight, squatting, towel)'
	String get rowBodyweightSquattingTowel => 'Row (bodyweight, squatting, towel)';

	/// en: 'Row (bodyweight, standing, close grip, one arm)'
	String get rowBodyweightStandingCloseGripOneArm => 'Row (bodyweight, standing, close grip, one arm)';

	/// en: 'Row (bodyweight, standing, close grip)'
	String get rowBodyweightStandingCloseGrip => 'Row (bodyweight, standing, close grip)';

	/// en: 'Row (bodyweight, standing, one arm)'
	String get rowBodyweightStandingOneArm => 'Row (bodyweight, standing, one arm)';

	/// en: 'Row (bodyweight, standing, one arm, towel)'
	String get rowBodyweightStandingOneArmTowel => 'Row (bodyweight, standing, one arm, towel)';

	/// en: 'Row (bodyweight, standing)'
	String get rowBodyweightStanding => 'Row (bodyweight, standing)';

	/// en: 'Row (bodyweight, standing, towel)'
	String get rowBodyweightStandingTowel => 'Row (bodyweight, standing, towel)';

	/// en: 'Lat pulldown (cable, crossover)'
	String get latPulldownCableCrossover => 'Lat pulldown (cable, crossover)';

	/// en: 'Row (cable, decline, seated, wide grip)'
	String get rowCableDeclineSeatedWideGrip => 'Row (cable, decline, seated, wide grip)';

	/// en: 'Row (cable, floor, seated, wide grip)'
	String get rowCableFloorSeatedWideGrip => 'Row (cable, floor, seated, wide grip)';

	/// en: 'Row (cable, high, kneeling)'
	String get rowCableHighKneeling => 'Row (cable, high, kneeling)';

	/// en: 'Bench row (cable, incline)'
	String get benchRowCableIncline => 'Bench row (cable, incline)';

	/// en: 'Lat pulldown (cable, rope)'
	String get latPulldownCableRope => 'Lat pulldown (cable, rope)';

	/// en: 'Row (cable, seated)'
	String get rowCableSeated => 'Row (cable, seated)';

	/// en: 'Pullover (cable, lying, rope)'
	String get pulloverCableLyingRope => 'Pullover (cable, lying, rope)';

	/// en: 'Pulldown (cable, one arm)'
	String get pulldownCableOneArm => 'Pulldown (cable, one arm)';

	/// en: 'Row (cable, one arm, straight back, high, kneeling)'
	String get rowCableOneArmStraightBackHighKneeling => 'Row (cable, one arm, straight back, high, kneeling)';

	/// en: 'Row (cable, palm rotational)'
	String get rowCablePalmRotational => 'Row (cable, palm rotational)';

	/// en: 'Lat pulldown with curved bar'
	String get latPulldownWithCurvedBar => 'Lat pulldown with curved bar';

	/// en: 'Pulldown (cable, rear)'
	String get pulldownCableRear => 'Pulldown (cable, rear)';

	/// en: 'Row (cable, reverse grip, straight back, seated, high)'
	String get rowCableReverseGripStraightBackSeatedHigh => 'Row (cable, reverse grip, straight back, seated, high)';

	/// en: 'Row (cable, rope, crossover, seated)'
	String get rowCableRopeCrossoverSeated => 'Row (cable, rope, crossover, seated)';

	/// en: 'Row (cable, rope, elevated, seated)'
	String get rowCableRopeElevatedSeated => 'Row (cable, rope, elevated, seated)';

	/// en: 'Bench row (cable, rope, extension, incline)'
	String get benchRowCableRopeExtensionIncline => 'Bench row (cable, rope, extension, incline)';

	/// en: 'Row (cable, rope, seated)'
	String get rowCableRopeSeated => 'Row (cable, rope, seated)';

	/// en: 'Row (cable, seated, one arm, alternate)'
	String get rowCableSeatedOneArmAlternate => 'Row (cable, seated, one arm, alternate)';

	/// en: 'Row (cable, seated, wide grip)'
	String get rowCableSeatedWideGrip => 'Row (cable, seated, wide grip)';

	/// en: 'Squat row (cable, rope)'
	String get squatRowCableRope => 'Squat row (cable, rope)';

	/// en: 'Row (cable, standing, v bar)'
	String get rowCableStandingVBar => 'Row (cable, standing, v bar)';

	/// en: 'Twist row (cable, standing, v bar)'
	String get twistRowCableStandingVBar => 'Twist row (cable, standing, v bar)';

	/// en: 'Cable kayak row'
	String get cableKayakRow => 'Cable kayak row';

	/// en: 'Twist row (cable, one arm)'
	String get twistRowCableOneArm => 'Twist row (cable, one arm)';

	/// en: 'Row (cable, upper)'
	String get rowCableUpper => 'Row (cable, upper)';

	/// en: 'Pulldown (cable, wide grip, rear, behind neck)'
	String get pulldownCableWideGripRearBehindNeck => 'Pulldown (cable, wide grip, rear, behind neck)';

	/// en: 'Row (cambered bar, lying)'
	String get rowCamberedBarLying => 'Row (cambered bar, lying)';

	/// en: 'Close neutral-grip pull-up'
	String get closeNeutralGripPullUp => 'Close neutral-grip pull-up';

	/// en: 'Bent over row (dumbbell)'
	String get bentOverRowDumbbell => 'Bent over row (dumbbell)';

	/// en: 'Y raise (dumbbell, incline)'
	String get yRaiseDumbbellIncline => 'Y raise (dumbbell, incline)';

	/// en: 'Bent over row (dumbbell, palm rotational)'
	String get bentOverRowDumbbellPalmRotational => 'Bent over row (dumbbell, palm rotational)';

	/// en: 'Row (dumbbell, reverse grip, incline bench, one arm)'
	String get rowDumbbellReverseGripInclineBenchOneArm => 'Row (dumbbell, reverse grip, incline bench, one arm)';

	/// en: 'Row (dumbbell, reverse grip, incline bench, two arm)'
	String get rowDumbbellReverseGripInclineBenchTwoArm => 'Row (dumbbell, reverse grip, incline bench, two arm)';

	/// en: 'Row (dumbbell, reverse grip)'
	String get rowDumbbellReverseGrip => 'Row (dumbbell, reverse grip)';

	/// en: 'Bodyweight hip hinge'
	String get bodyweightHipHinge => 'Bodyweight hip hinge';

	/// en: 'Back extension (exercise ball, straight arm)'
	String get backExtensionExerciseBallStraightArm => 'Back extension (exercise ball, straight arm)';

	/// en: 'Back extension (exercise ball, hands behind head)'
	String get backExtensionExerciseBallHandsBehindHead => 'Back extension (exercise ball, hands behind head)';

	/// en: 'Back extension (exercise ball, knee off ground)'
	String get backExtensionExerciseBallKneeOffGround => 'Back extension (exercise ball, knee off ground)';

	/// en: 'Back extension (exercise ball, rotation)'
	String get backExtensionExerciseBallRotation => 'Back extension (exercise ball, rotation)';

	/// en: 'Seated back stretch hugging a ball'
	String get seatedBackStretchHuggingABall => 'Seated back stretch hugging a ball';

	/// en: 'Lat stretch (exercise ball)'
	String get latStretchExerciseBall => 'Lat stretch (exercise ball)';

	/// en: 'Pyramid-position back stretch on ball'
	String get pyramidPositionBackStretchOnBall => 'Pyramid-position back stretch on ball';

	/// en: 'Lat stretch (exercise ball, lying, side)'
	String get latStretchExerciseBallLyingSide => 'Lat stretch (exercise ball, lying, side)';

	/// en: 'Leg raise (exercise ball, prone)'
	String get legRaiseExerciseBallProne => 'Leg raise (exercise ball, prone)';

	/// en: 'Pullover (ez bar, lying, bent arm)'
	String get pulloverEzBarLyingBentArm => 'Pullover (ez bar, lying, bent arm)';

	/// en: 'Bent over row (ez bar, reverse grip)'
	String get bentOverRowEzBarReverseGrip => 'Bent over row (ez bar, reverse grip)';

	/// en: 'Front lever'
	String get frontLever => 'Front lever';

	/// en: 'Front lever (reps)'
	String get frontLeverReps => 'Front lever (reps)';

	/// en: 'Sternum-to-bar chin-up'
	String get sternumToBarChinUp => 'Sternum-to-bar chin-up';

	/// en: 'Inverted row'
	String get invertedRow => 'Inverted row';

	/// en: 'Inverted row (bent knee)'
	String get invertedRowBentKnee => 'Inverted row (bent knee)';

	/// en: 'Inverted row (bench)'
	String get invertedRowBench => 'Inverted row (bench)';

	/// en: 'Renegade row (kettlebell, alternate)'
	String get renegadeRowKettlebellAlternate => 'Renegade row (kettlebell, alternate)';

	/// en: 'Row (kettlebell, alternate)'
	String get rowKettlebellAlternate => 'Row (kettlebell, alternate)';

	/// en: 'Row (kettlebell, one arm)'
	String get rowKettlebellOneArm => 'Row (kettlebell, one arm)';

	/// en: 'Row (kettlebell, two arm)'
	String get rowKettlebellTwoArm => 'Row (kettlebell, two arm)';

	/// en: 'Muscle up (kipping)'
	String get muscleUpKipping => 'Muscle up (kipping)';

	/// en: 'Lat stretch (kneeling)'
	String get latStretchKneeling => 'Lat stretch (kneeling)';

	/// en: 'Pull-up (l)'
	String get pullUpL => 'Pull-up (l)';

	/// en: 'Row (lever, alternate, narrow grip, seated)'
	String get rowLeverAlternateNarrowGripSeated => 'Row (lever, alternate, narrow grip, seated)';

	/// en: 'Chin-up (lever, assisted)'
	String get chinUpLeverAssisted => 'Chin-up (lever, assisted)';

	/// en: 'Back extension (lever)'
	String get backExtensionLever => 'Back extension (lever)';

	/// en: 'Bent over row (lever)'
	String get bentOverRowLever => 'Bent over row (lever)';

	/// en: 'Bent over row (lever, v bar)'
	String get bentOverRowLeverVBar => 'Bent over row (lever, v bar)';

	/// en: 'Pulldown (lever, front)'
	String get pulldownLeverFront => 'Pulldown (lever, front)';

	/// en: 'Row (lever, high)'
	String get rowLeverHigh => 'Row (lever, high)';

	/// en: 'Bent over row (lever, one arm)'
	String get bentOverRowLeverOneArm => 'Bent over row (lever, one arm)';

	/// en: 'Row (lever, one arm, lateral, high)'
	String get rowLeverOneArmLateralHigh => 'Row (lever, one arm, lateral, high)';

	/// en: 'Pulldown (lever, one arm, lateral, wide)'
	String get pulldownLeverOneArmLateralWide => 'Pulldown (lever, one arm, lateral, wide)';

	/// en: 'Pullover (lever)'
	String get pulloverLever => 'Pullover (lever)';

	/// en: 'Lat pulldown (lever, reverse grip)'
	String get latPulldownLeverReverseGrip => 'Lat pulldown (lever, reverse grip)';

	/// en: 'Row (lever, reverse grip, vertical)'
	String get rowLeverReverseGripVertical => 'Row (lever, reverse grip, vertical)';

	/// en: 'Row (lever, reverse, t bar)'
	String get rowLeverReverseTBar => 'Row (lever, reverse, t bar)';

	/// en: 'Row (lever, t bar)'
	String get rowLeverTBar => 'Row (lever, t bar)';

	/// en: 'Row (lever, t bar, reverse grip)'
	String get rowLeverTBarReverseGrip => 'Row (lever, t bar, reverse grip)';

	/// en: 'Row (lever, one arm)'
	String get rowLeverOneArm => 'Row (lever, one arm)';

	/// en: 'Standing anchored-rope row'
	String get standingAnchoredRopeRow => 'Standing anchored-rope row';

	/// en: 'Seated spinal flexion'
	String get seatedSpinalFlexion => 'Seated spinal flexion';

	/// en: 'Medicine-ball catch and overhead toss'
	String get medicineBallCatchAndOverheadToss => 'Medicine-ball catch and overhead toss';

	/// en: 'Overhead medicine-ball slam'
	String get overheadMedicineBallSlam => 'Overhead medicine-ball slam';

	/// en: 'Chin-up (mixed grip)'
	String get chinUpMixedGrip => 'Chin-up (mixed grip)';

	/// en: 'Muscle up'
	String get muscleUp => 'Muscle up';

	/// en: 'Muscle up (vertical, bar)'
	String get muscleUpVerticalBar => 'Muscle up (vertical, bar)';

	/// en: 'Neck stretch (side)'
	String get neckStretchSide => 'Neck stretch (side)';

	/// en: 'Single-arm wall lat stretch'
	String get singleArmWallLatStretch => 'Single-arm wall lat stretch';

	/// en: 'Chin-up (one arm)'
	String get chinUpOneArm => 'Chin-up (one arm)';

	/// en: 'Row (one arm, towel)'
	String get rowOneArmTowel => 'Row (one arm, towel)';

	/// en: 'Pull-up (neutral grip)'
	String get pullUpNeutralGrip => 'Pull-up (neutral grip)';

	/// en: 'Pull-up (rear)'
	String get pullUpRear => 'Pull-up (rear)';

	/// en: 'Row (resistance band, seated, straight back)'
	String get rowResistanceBandSeatedStraightBack => 'Row (resistance band, seated, straight back)';

	/// en: 'Pulldown (lever, reverse grip)'
	String get pulldownLeverReverseGrip => 'Pulldown (lever, reverse grip)';

	/// en: 'Alternating front-and-back pull-up'
	String get alternatingFrontAndBackPullUp => 'Alternating front-and-back pull-up';

	/// en: 'Back stretch (roller)'
	String get backStretchRoller => 'Back stretch (roller)';

	/// en: 'Lat stretch (roller, side)'
	String get latStretchRollerSide => 'Lat stretch (roller, side)';

	/// en: 'Rope climbing'
	String get ropeClimbing => 'Rope climbing';

	/// en: 'Lower back stretch (seated)'
	String get lowerBackStretchSeated => 'Lower back stretch (seated)';

	/// en: 'Lat stretch (side lying, floor)'
	String get latStretchSideLyingFloor => 'Lat stretch (side lying, floor)';

	/// en: 'Neck stretch (side, push)'
	String get neckStretchSidePush => 'Neck stretch (side, push)';

	/// en: 'Side-to-side chin-up'
	String get sideToSideChinUp => 'Side-to-side chin-up';

	/// en: 'Skin-the-cat rotation'
	String get skinTheCatRotation => 'Skin-the-cat rotation';

	/// en: 'Bent over row (smith)'
	String get bentOverRowSmith => 'Bent over row (smith)';

	/// en: 'Row (smith, narrow)'
	String get rowSmithNarrow => 'Row (smith, narrow)';

	/// en: 'Row (smith, one arm)'
	String get rowSmithOneArm => 'Row (smith, one arm)';

	/// en: 'Bent over row (smith, reverse grip)'
	String get bentOverRowSmithReverseGrip => 'Bent over row (smith, reverse grip)';

	/// en: 'Prone sphinx stretch'
	String get proneSphinxStretch => 'Prone sphinx stretch';

	/// en: 'Spine stretch'
	String get spineStretch => 'Spine stretch';

	/// en: 'Standing archer pull'
	String get standingArcherPull => 'Standing archer pull';

	/// en: 'Lat stretch (standing, lateral)'
	String get latStretchStandingLateral => 'Lat stretch (standing, lateral)';

	/// en: 'Pelvic tilt (standing)'
	String get pelvicTiltStanding => 'Pelvic tilt (standing)';

	/// en: 'Pulldown (cable, neutral grip)'
	String get pulldownCableNeutralGrip => 'Pulldown (cable, neutral grip)';

	/// en: 'Forward fold reaching both toes'
	String get forwardFoldReachingBothToes => 'Forward fold reaching both toes';

	/// en: 'Upper back stretch'
	String get upperBackStretch => 'Upper back stretch';

	/// en: 'Upward-facing dog stretch'
	String get upwardFacingDogStretch => 'Upward-facing dog stretch';

	/// en: 'Chin-up (weighted, close grip, dip cage)'
	String get chinUpWeightedCloseGripDipCage => 'Chin-up (weighted, close grip, dip cage)';

	/// en: 'Hyperextension (weighted, stability ball)'
	String get hyperextensionWeightedStabilityBall => 'Hyperextension (weighted, stability ball)';

	/// en: 'Muscle up (weighted)'
	String get muscleUpWeighted => 'Muscle up (weighted)';

	/// en: 'Muscle up (weighted, bar)'
	String get muscleUpWeightedBar => 'Muscle up (weighted, bar)';

	/// en: 'Pull-up (weighted, one arm)'
	String get pullUpWeightedOneArm => 'Pull-up (weighted, one arm)';

	/// en: 'Pull-up (weighted)'
	String get pullUpWeighted => 'Pull-up (weighted)';

	/// en: 'Pull-up (wide grip)'
	String get pullUpWideGrip => 'Pull-up (wide grip)';

	/// en: 'Pull-up (wide grip, rear)'
	String get pullUpWideGripRear => 'Pull-up (wide grip, rear)';
}

// Path: library.back.exercise
class Translations$library$back$exercise$en {
	Translations$library$back$exercise$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dual low row machine'
	String get dualLowRowMachine => 'Dual low row machine';

	/// en: 'Dual high row machine'
	String get dualHighRowMachine => 'Dual high row machine';
}

// Path: library.triceps.exercises
class Translations$library$triceps$exercises$en {
	Translations$library$triceps$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bar triceps pushdown'
	String get barTricepsPushdown => 'Bar triceps pushdown';

	/// en: 'Single-arm triceps pushdown'
	String get singleArmTricepsPushdown => 'Single-arm triceps pushdown';

	/// en: 'Machine-assisted dips'
	String get machineAssistedDips => 'Machine-assisted dips';

	/// en: 'Dips'
	String get dips => 'Dips';

	/// en: 'Overhead rope triceps extension'
	String get overheadRopeTricepExtension => 'Overhead rope triceps extension';

	/// en: 'Triceps rope pushdown'
	String get tricepsRopePushdown => 'Triceps rope pushdown';

	/// en: 'Triceps kickbacks'
	String get tricepKickbacks => 'Triceps kickbacks';

	/// en: 'Skull crushers'
	String get skullCrushers => 'Skull crushers';

	/// en: 'Dips (bench)'
	String get benchDips => 'Dips (bench)';

	/// en: 'Diamond push-ups'
	String get diamondPushUps => 'Diamond push-ups';

	/// en: 'Triceps machine'
	String get tricepsMachine => 'Triceps machine';

	/// en: 'Dumbbell overhead triceps extension'
	String get overheadTricepExtension => 'Dumbbell overhead triceps extension';

	/// en: 'Triceps extension (assisted, standing, towel)'
	String get tricepsExtensionAssistedStandingTowel => 'Triceps extension (assisted, standing, towel)';

	/// en: 'Push-up (band, close grip)'
	String get pushUpBandCloseGrip => 'Push-up (band, close grip)';

	/// en: 'Triceps extension (band, side)'
	String get tricepsExtensionBandSide => 'Triceps extension (band, side)';

	/// en: 'Bench press (barbell, close grip)'
	String get benchPressBarbellCloseGrip => 'Bench press (barbell, close grip)';

	/// en: 'Decline close-grip press into skull crusher'
	String get declineCloseGripPressIntoSkullCrusher => 'Decline close-grip press into skull crusher';

	/// en: 'Bench press (barbell, incline, close grip)'
	String get benchPressBarbellInclineCloseGrip => 'Bench press (barbell, incline, close grip)';

	/// en: 'Press (barbell, incline, reverse grip)'
	String get pressBarbellInclineReverseGrip => 'Press (barbell, incline, reverse grip)';

	/// en: 'Triceps extension (barbell, lying, back of head)'
	String get tricepsExtensionBarbellLyingBackOfHead => 'Triceps extension (barbell, lying, back of head)';

	/// en: 'Floor press (barbell, one arm)'
	String get floorPressBarbellOneArm => 'Floor press (barbell, one arm)';

	/// en: 'Pin presses (barbell)'
	String get pinPressesBarbell => 'Pin presses (barbell)';

	/// en: 'Bench press (barbell, reverse, close grip)'
	String get benchPressBarbellReverseCloseGrip => 'Bench press (barbell, reverse, close grip)';

	/// en: 'Skullcrusher (barbell, reverse grip)'
	String get skullcrusherBarbellReverseGrip => 'Skullcrusher (barbell, reverse grip)';

	/// en: 'Triceps extension (barbell, seated, close grip, behind neck)'
	String get tricepsExtensionBarbellSeatedCloseGripBehindNeck => 'Triceps extension (barbell, seated, close grip, behind neck)';

	/// en: 'Triceps extension (barbell, seated, overhead)'
	String get tricepsExtensionBarbellSeatedOverhead => 'Triceps extension (barbell, seated, overhead)';

	/// en: 'Triceps extension (barbell, standing, overhead)'
	String get tricepsExtensionBarbellStandingOverhead => 'Triceps extension (barbell, standing, overhead)';

	/// en: 'Triceps extension (bodyweight, kneeling)'
	String get tricepsExtensionBodyweightKneeling => 'Triceps extension (bodyweight, kneeling)';

	/// en: 'Triceps extension (cable, alternate)'
	String get tricepsExtensionCableAlternate => 'Triceps extension (cable, alternate)';

	/// en: 'Extension (cable, concentration, knee)'
	String get extensionCableConcentrationKnee => 'Extension (cable, concentration, knee)';

	/// en: 'Triceps extension (cable, high pulley, overhead)'
	String get tricepsExtensionCableHighPulleyOverhead => 'Triceps extension (cable, high pulley, overhead)';

	/// en: 'Triceps extension (cable, incline)'
	String get tricepsExtensionCableIncline => 'Triceps extension (cable, incline)';

	/// en: 'Kickback (cable)'
	String get kickbackCable => 'Kickback (cable)';

	/// en: 'Triceps extension (cable, kneeling)'
	String get tricepsExtensionCableKneeling => 'Triceps extension (cable, kneeling)';

	/// en: 'Triceps extension (cable, lying)'
	String get tricepsExtensionCableLying => 'Triceps extension (cable, lying)';

	/// en: 'Cable rearward triceps drive'
	String get cableRearwardTricepsDrive => 'Cable rearward triceps drive';

	/// en: 'Triceps pushdown (cable, reverse grip, sz bar, arm blaster)'
	String get tricepsPushdownCableReverseGripSzBarArmBlaster => 'Triceps pushdown (cable, reverse grip, sz bar, arm blaster)';

	/// en: 'Pushdown (cable, reverse grip)'
	String get pushdownCableReverseGrip => 'Pushdown (cable, reverse grip)';

	/// en: 'Triceps extension (cable, rope, incline)'
	String get tricepsExtensionCableRopeIncline => 'Triceps extension (cable, rope, incline)';

	/// en: 'Triceps extension (cable, rope, lying, floor)'
	String get tricepsExtensionCableRopeLyingFloor => 'Triceps extension (cable, rope, lying, floor)';

	/// en: 'Triceps extension (cable, standing, one arm)'
	String get tricepsExtensionCableStandingOneArm => 'Triceps extension (cable, standing, one arm)';

	/// en: 'Triceps extension (cable, standing, reverse grip, one arm, overhead)'
	String get tricepsExtensionCableStandingReverseGripOneArmOverhead => 'Triceps extension (cable, standing, reverse grip, one arm, overhead)';

	/// en: 'Triceps pushdown (cable, v bar)'
	String get tricepsPushdownCableVBar => 'Triceps pushdown (cable, v bar)';

	/// en: 'Triceps pushdown (cable, v bar, arm blaster)'
	String get tricepsPushdownCableVBarArmBlaster => 'Triceps pushdown (cable, v bar, arm blaster)';

	/// en: 'Triceps kickback (cable, two arm)'
	String get tricepsKickbackCableTwoArm => 'Triceps kickback (cable, two arm)';

	/// en: 'Push-up (close grip)'
	String get pushUpCloseGrip => 'Push-up (close grip)';

	/// en: 'Push-up (close grip, knee)'
	String get pushUpCloseGripKnee => 'Push-up (close grip, knee)';

	/// en: 'Press (dumbbell, close grip)'
	String get pressDumbbellCloseGrip => 'Press (dumbbell, close grip)';

	/// en: 'Press (dumbbell, decline, one arm, neutral grip)'
	String get pressDumbbellDeclineOneArmNeutralGrip => 'Press (dumbbell, decline, one arm, neutral grip)';

	/// en: 'Triceps extension (dumbbell, decline)'
	String get tricepsExtensionDumbbellDecline => 'Triceps extension (dumbbell, decline)';

	/// en: 'Forward lunge triceps extension (dumbbell)'
	String get forwardLungeTricepsExtensionDumbbell => 'Forward lunge triceps extension (dumbbell)';

	/// en: 'Press (dumbbell, incline, neutral grip, exercise ball)'
	String get pressDumbbellInclineNeutralGripExerciseBall => 'Press (dumbbell, incline, neutral grip, exercise ball)';

	/// en: 'Press (dumbbell, incline, one arm, neutral grip)'
	String get pressDumbbellInclineOneArmNeutralGrip => 'Press (dumbbell, incline, one arm, neutral grip)';

	/// en: 'Press (dumbbell, incline, one arm, neutral grip, exercise ball)'
	String get pressDumbbellInclineOneArmNeutralGripExerciseBall => 'Press (dumbbell, incline, one arm, neutral grip, exercise ball)';

	/// en: 'Triceps extension (dumbbell, incline)'
	String get tricepsExtensionDumbbellIncline => 'Triceps extension (dumbbell, incline)';

	/// en: 'Triceps extension (dumbbell, incline, two arm)'
	String get tricepsExtensionDumbbellInclineTwoArm => 'Triceps extension (dumbbell, incline, two arm)';

	/// en: 'Kickback (dumbbell, exercise ball)'
	String get kickbackDumbbellExerciseBall => 'Kickback (dumbbell, exercise ball)';

	/// en: 'Triceps extension (dumbbell, lying, across face)'
	String get tricepsExtensionDumbbellLyingAcrossFace => 'Triceps extension (dumbbell, lying, across face)';

	/// en: 'Extension (dumbbell, lying, alternate)'
	String get extensionDumbbellLyingAlternate => 'Extension (dumbbell, lying, alternate)';

	/// en: 'Triceps extension (dumbbell, lying)'
	String get tricepsExtensionDumbbellLying => 'Triceps extension (dumbbell, lying)';

	/// en: 'Triceps extension (dumbbell, lying, one arm, pronated)'
	String get tricepsExtensionDumbbellLyingOneArmPronated => 'Triceps extension (dumbbell, lying, one arm, pronated)';

	/// en: 'Triceps extension (dumbbell, lying, one arm, supinated)'
	String get tricepsExtensionDumbbellLyingOneArmSupinated => 'Triceps extension (dumbbell, lying, one arm, supinated)';

	/// en: 'Triceps extension (dumbbell, lying, one arm)'
	String get tricepsExtensionDumbbellLyingOneArm => 'Triceps extension (dumbbell, lying, one arm)';

	/// en: 'French press (dumbbell, one arm, exercise ball)'
	String get frenchPressDumbbellOneArmExerciseBall => 'French press (dumbbell, one arm, exercise ball)';

	/// en: 'Press (dumbbell, one arm, neutral grip, exercise ball)'
	String get pressDumbbellOneArmNeutralGripExerciseBall => 'Press (dumbbell, one arm, neutral grip, exercise ball)';

	/// en: 'Triceps extension (dumbbell, one arm, bench)'
	String get tricepsExtensionDumbbellOneArmBench => 'Triceps extension (dumbbell, one arm, bench)';

	/// en: 'Triceps extension (dumbbell, pronate grip)'
	String get tricepsExtensionDumbbellPronateGrip => 'Triceps extension (dumbbell, pronate grip)';

	/// en: 'Extension (dumbbell, seated, bench)'
	String get extensionDumbbellSeatedBench => 'Extension (dumbbell, seated, bench)';

	/// en: 'Kickback (dumbbell, seated, bent over, alternate)'
	String get kickbackDumbbellSeatedBentOverAlternate => 'Kickback (dumbbell, seated, bent over, alternate)';

	/// en: 'Kickback (dumbbell, seated)'
	String get kickbackDumbbellSeated => 'Kickback (dumbbell, seated)';

	/// en: 'Kickback (dumbbell, seated, one arm)'
	String get kickbackDumbbellSeatedOneArm => 'Kickback (dumbbell, seated, one arm)';

	/// en: 'Triceps extension (dumbbell, seated, reverse grip, one arm, overhead)'
	String get tricepsExtensionDumbbellSeatedReverseGripOneArmOverhead => 'Triceps extension (dumbbell, seated, reverse grip, one arm, overhead)';

	/// en: 'Triceps kickback (dumbbell, standing, alternate)'
	String get tricepsKickbackDumbbellStandingAlternate => 'Triceps kickback (dumbbell, standing, alternate)';

	/// en: 'Triceps extension (dumbbell, standing, bent over, one arm)'
	String get tricepsExtensionDumbbellStandingBentOverOneArm => 'Triceps extension (dumbbell, standing, bent over, one arm)';

	/// en: 'Kickback (dumbbell, standing)'
	String get kickbackDumbbellStanding => 'Kickback (dumbbell, standing)';

	/// en: 'Extension (dumbbell, standing, one arm)'
	String get extensionDumbbellStandingOneArm => 'Extension (dumbbell, standing, one arm)';

	/// en: 'Tate press (dumbbell)'
	String get tatePressDumbbell => 'Tate press (dumbbell)';

	/// en: 'Triceps kickback (dumbbell, stork stance)'
	String get tricepsKickbackDumbbellStorkStance => 'Triceps kickback (dumbbell, stork stance)';

	/// en: 'Elbow-supported dips'
	String get elbowSupportedDips => 'Elbow-supported dips';

	/// en: 'Dip (exercise ball)'
	String get dipExerciseBall => 'Dip (exercise ball)';

	/// en: 'Triceps stretch (exercise ball, seated)'
	String get tricepsStretchExerciseBallSeated => 'Triceps stretch (exercise ball, seated)';

	/// en: 'Triceps extension (exercise ball, supine)'
	String get tricepsExtensionExerciseBallSupine => 'Triceps extension (exercise ball, supine)';

	/// en: 'French press (ez bar, exercise ball)'
	String get frenchPressEzBarExerciseBall => 'French press (ez bar, exercise ball)';

	/// en: 'Triceps extension (ez bar, lying, close grip, behind head)'
	String get tricepsExtensionEzBarLyingCloseGripBehindHead => 'Triceps extension (ez bar, lying, close grip, behind head)';

	/// en: 'French press (ez bar, standing)'
	String get frenchPressEzBarStanding => 'French press (ez bar, standing)';

	/// en: 'Decline EZ-bar face press'
	String get declineEZBarFacePress => 'Decline EZ-bar face press';

	/// en: 'Triceps extension (ez barbell, decline)'
	String get tricepsExtensionEzBarbellDecline => 'Triceps extension (ez barbell, decline)';

	/// en: 'Triceps extension (ez barbell, incline)'
	String get tricepsExtensionEzBarbellIncline => 'Triceps extension (ez barbell, incline)';

	/// en: 'Triceps extension (ez barbell, seated)'
	String get tricepsExtensionEzBarbellSeated => 'Triceps extension (ez barbell, seated)';

	/// en: 'Bench press (ez bar, close grip)'
	String get benchPressEzBarCloseGrip => 'Bench press (ez bar, close grip)';

	/// en: 'Forearm-transition dips'
	String get forearmTransitionDips => 'Forearm-transition dips';

	/// en: 'Push-up (incline, close grip)'
	String get pushUpInclineCloseGrip => 'Push-up (incline, close grip)';

	/// en: 'Triceps dip (lever, overhand)'
	String get tricepsDipLeverOverhand => 'Triceps dip (lever, overhand)';

	/// en: 'Dip (lever, seated)'
	String get dipLeverSeated => 'Dip (lever, seated)';

	/// en: 'Push-up (medicine ball, close grip)'
	String get pushUpMedicineBallCloseGrip => 'Push-up (medicine ball, close grip)';

	/// en: 'Supine medicine-ball chest throw'
	String get supineMedicineBallChestThrow => 'Supine medicine-ball chest throw';

	/// en: 'Triceps extension (olympic barbell)'
	String get tricepsExtensionOlympicBarbell => 'Triceps extension (olympic barbell)';

	/// en: 'Dip (one arm)'
	String get dipOneArm => 'Dip (one arm)';

	/// en: 'Triceps stretch (overhead)'
	String get tricepsStretchOverhead => 'Triceps stretch (overhead)';

	/// en: 'Push-up (close grip, off, dumbbell)'
	String get pushUpCloseGripOffDumbbell => 'Push-up (close grip, off, dumbbell)';

	/// en: 'Dip (reverse)'
	String get dipReverse => 'Dip (reverse)';

	/// en: 'Dip (ring)'
	String get dipRing => 'Dip (ring)';

	/// en: 'Bench press (smith, close grip)'
	String get benchPressSmithCloseGrip => 'Bench press (smith, close grip)';

	/// en: 'Bench press (smith machine, decline, close grip)'
	String get benchPressSmithMachineDeclineCloseGrip => 'Bench press (smith machine, decline, close grip)';

	/// en: 'Triceps extension (smith machine, incline)'
	String get tricepsExtensionSmithMachineIncline => 'Triceps extension (smith machine, incline)';

	/// en: 'Stalder press to handstand'
	String get stalderPressToHandstand => 'Stalder press to handstand';

	/// en: 'Dip (three, bench)'
	String get dipThreeBench => 'Dip (three, bench)';

	/// en: 'Triceps dip (floor)'
	String get tricepsDipFloor => 'Triceps dip (floor)';

	/// en: 'Dip (weighted, bench)'
	String get dipWeightedBench => 'Dip (weighted, bench)';

	/// en: 'Dip (weighted, three, bench)'
	String get dipWeightedThreeBench => 'Dip (weighted, three, bench)';

	/// en: 'Triceps dip (weighted)'
	String get tricepsDipWeighted => 'Triceps dip (weighted)';

	/// en: 'JM press (barbell)'
	String get jmPressBarbell => 'JM press (barbell)';

	/// en: 'JM press (ez barbell)'
	String get jmPressEzBarbell => 'JM press (ez barbell)';
}

// Path: library.hips.exercises
class Translations$library$hips$exercises$en {
	Translations$library$hips$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Machine hip adduction'
	String get hipAdduction => 'Machine hip adduction';

	/// en: 'Adductor stretch (assisted, side lying)'
	String get adductorStretchAssistedSideLying => 'Adductor stretch (assisted, side lying)';

	/// en: 'Hip adduction (cable)'
	String get hipAdductionCable => 'Hip adduction (cable)';

	/// en: 'Hip adduction (side lying)'
	String get hipAdductionSideLying => 'Hip adduction (side lying)';

	/// en: 'Hip adduction (side plank)'
	String get hipAdductionSidePlank => 'Hip adduction (side plank)';
}

// Path: library.forearms.exercises
class Translations$library$forearms$exercises$en {
	Translations$library$forearms$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Wrist curls (barbell)'
	String get wristCurlsBarbell => 'Wrist curls (barbell)';

	/// en: 'Reverse wrist curls (barbell)'
	String get reverseWristCurlsBarbell => 'Reverse wrist curls (barbell)';

	/// en: 'Wrist curls (dumbbell)'
	String get wristCurlsDumbbell => 'Wrist curls (dumbbell)';

	/// en: 'Reverse wrist curls (dumbbell)'
	String get reverseWristCurlsDumbbell => 'Reverse wrist curls (dumbbell)';

	/// en: 'Wrist roller'
	String get wristRoller => 'Wrist roller';

	/// en: 'Farmer’s walk'
	String get farmerWalk => 'Farmer’s walk';

	/// en: 'Plate pinch'
	String get platePinch => 'Plate pinch';

	/// en: 'Reverse curls (barbell)'
	String get reverseCurls => 'Reverse curls (barbell)';

	/// en: 'Reverse curls (dumbbell)'
	String get reverseCurlsDumbbell => 'Reverse curls (dumbbell)';

	/// en: 'Single-arm dumbbell reverse curl'
	String get dumbbellSingleArmReverseCurl => 'Single-arm dumbbell reverse curl';

	/// en: 'Single-arm cable reverse curl'
	String get singleArmCableReverseCurl => 'Single-arm cable reverse curl';

	/// en: 'Reverse wrist curl (band)'
	String get reverseWristCurlBand => 'Reverse wrist curl (band)';

	/// en: 'Wrist curl (band)'
	String get wristCurlBand => 'Wrist curl (band)';

	/// en: 'Wrist curl (barbell, standing, back)'
	String get wristCurlBarbellStandingBack => 'Wrist curl (barbell, standing, back)';

	/// en: 'Reverse wrist curl (cable)'
	String get reverseWristCurlCable => 'Reverse wrist curl (cable)';

	/// en: 'Wrist curl (cable, standing, back)'
	String get wristCurlCableStandingBack => 'Wrist curl (cable, standing, back)';

	/// en: 'Wrist curl (cable)'
	String get wristCurlCable => 'Wrist curl (cable)';

	/// en: 'Dumbbell finger flexion'
	String get dumbbellFingerFlexion => 'Dumbbell finger flexion';

	/// en: 'Pronation (dumbbell, lying)'
	String get pronationDumbbellLying => 'Pronation (dumbbell, lying)';

	/// en: 'Pronation (dumbbell, lying, floor)'
	String get pronationDumbbellLyingFloor => 'Pronation (dumbbell, lying, floor)';

	/// en: 'Supination (dumbbell, lying)'
	String get supinationDumbbellLying => 'Supination (dumbbell, lying)';

	/// en: 'Supination (dumbbell, lying, floor)'
	String get supinationDumbbellLyingFloor => 'Supination (dumbbell, lying, floor)';

	/// en: 'Reverse wrist curl (dumbbell, one arm)'
	String get reverseWristCurlDumbbellOneArm => 'Reverse wrist curl (dumbbell, one arm)';

	/// en: 'Neutral wrist curl (dumbbell, one arm, seated)'
	String get neutralWristCurlDumbbellOneArmSeated => 'Neutral wrist curl (dumbbell, one arm, seated)';

	/// en: 'Wrist curl (dumbbell, one arm)'
	String get wristCurlDumbbellOneArm => 'Wrist curl (dumbbell, one arm)';

	/// en: 'Bench-supported dumbbell radial deviation'
	String get benchSupportedDumbbellRadialDeviation => 'Bench-supported dumbbell radial deviation';

	/// en: 'Neutral wrist curl (dumbbell, bench, one arm)'
	String get neutralWristCurlDumbbellBenchOneArm => 'Neutral wrist curl (dumbbell, bench, one arm)';

	/// en: 'Reverse wrist curl (dumbbell, bench, one arm)'
	String get reverseWristCurlDumbbellBenchOneArm => 'Reverse wrist curl (dumbbell, bench, one arm)';

	/// en: 'Wrist curl (dumbbell, bench, one arm)'
	String get wristCurlDumbbellBenchOneArm => 'Wrist curl (dumbbell, bench, one arm)';

	/// en: 'Seated dumbbell radial deviation'
	String get seatedDumbbellRadialDeviation => 'Seated dumbbell radial deviation';

	/// en: 'Shoulder external rotation (dumbbell, seated, one arm)'
	String get shoulderExternalRotationDumbbellSeatedOneArm => 'Shoulder external rotation (dumbbell, seated, one arm)';

	/// en: 'Finger flexion curls'
	String get fingerFlexionCurls => 'Finger flexion curls';

	/// en: 'Hang clean (kettlebell, alternate)'
	String get hangCleanKettlebellAlternate => 'Hang clean (kettlebell, alternate)';

	/// en: 'Machine hand-grip squeeze'
	String get machineHandGripSqueeze => 'Machine hand-grip squeeze';

	/// en: 'Wrist stretch with side pull'
	String get wristStretchWithSidePull => 'Wrist stretch with side pull';

	/// en: 'Wrist curl (smith, seated)'
	String get wristCurlSmithSeated => 'Wrist curl (smith, seated)';

	/// en: 'Wrist curl (smith, standing, back)'
	String get wristCurlSmithStandingBack => 'Wrist curl (smith, standing, back)';

	/// en: 'Weighted hand-grip squeeze'
	String get weightedHandGripSqueeze => 'Weighted hand-grip squeeze';

	/// en: 'Wrist circles'
	String get wristCircles => 'Wrist circles';
}

// Path: library.obliques.exercises
class Translations$library$obliques$exercises$en {
	Translations$library$obliques$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Side plank'
	String get sidewaysPlank => 'Side plank';

	/// en: 'Side plank reach through'
	String get sidewaysPlankReachThrough => 'Side plank reach through';
}

// Path: library.other.exercises
class Translations$library$other$exercises$en {
	Translations$library$other$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Stretching'
	String get stretching => 'Stretching';
}

// Path: library.glutes.exercises
class Translations$library$glutes$exercises$en {
	Translations$library$glutes$exercises$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Single-leg glute bridge'
	String get singleLegGluteBridge => 'Single-leg glute bridge';

	/// en: 'Smith machine hip thrust'
	String get smithMachineHipThrust => 'Smith machine hip thrust';

	/// en: 'Resistance band hip abduction'
	String get bandHipAbduction => 'Resistance band hip abduction';

	/// en: 'Lateral band walk'
	String get lateralBandWalk => 'Lateral band walk';

	/// en: 'Quadruped glute kickback'
	String get quadrupedGluteKickback => 'Quadruped glute kickback';

	/// en: 'Kettlebell swing'
	String get kettlebellSwing => 'Kettlebell swing';

	/// en: 'Cable glute kickback'
	String get cableGluteKickback => 'Cable glute kickback';

	/// en: 'Machine glute kickback'
	String get machineGluteKickback => 'Machine glute kickback';

	/// en: 'Cable hip abduction'
	String get cableHipAbduction => 'Cable hip abduction';

	/// en: 'Glute bridge'
	String get gluteBridge => 'Glute bridge';

	/// en: 'Machine hip thrust'
	String get hipThrust => 'Machine hip thrust';

	/// en: 'Machine hip abduction'
	String get hipAbduction => 'Machine hip abduction';

	/// en: 'Clamshells'
	String get clamshells => 'Clamshells';

	/// en: 'Hip thrust (barbell)'
	String get hipThrustBarbell => 'Hip thrust (barbell)';

	/// en: 'Standing toe-touch circles, arms open'
	String get standingToeTouchCirclesArmsOpen => 'Standing toe-touch circles, arms open';

	/// en: 'Assisted supine glute stretch'
	String get assistedSupineGluteStretch => 'Assisted supine glute stretch';

	/// en: 'Assisted glute and piriformis stretch'
	String get assistedGluteAndPiriformisStretch => 'Assisted glute and piriformis stretch';

	/// en: 'Hip extension (band, bent over)'
	String get hipExtensionBandBentOver => 'Hip extension (band, bent over)';

	/// en: 'Glute bridge (band)'
	String get gluteBridgeBand => 'Glute bridge (band)';

	/// en: 'Hip internal rotation (band, lying)'
	String get hipInternalRotationBandLying => 'Hip internal rotation (band, lying)';

	/// en: 'Pull through (band)'
	String get pullThroughBand => 'Pull through (band)';

	/// en: 'Hip internal rotation (band, seated)'
	String get hipInternalRotationBandSeated => 'Hip internal rotation (band, seated)';

	/// en: 'Glute bridge (barbell)'
	String get gluteBridgeBarbell => 'Glute bridge (barbell)';

	/// en: 'Glute bridge (barbell, bench)'
	String get gluteBridgeBarbellBench => 'Glute bridge (barbell, bench)';

	/// en: 'Deadlift (barbell, one arm, side)'
	String get deadliftBarbellOneArmSide => 'Deadlift (barbell, one arm, side)';

	/// en: 'Rack pull (barbell)'
	String get rackPullBarbell => 'Rack pull (barbell)';

	/// en: 'Deadlift (barbell, one leg)'
	String get deadliftBarbellOneLeg => 'Deadlift (barbell, one leg)';

	/// en: 'Deadlift (barbell, sumo)'
	String get deadliftBarbellSumo => 'Deadlift (barbell, sumo)';

	/// en: 'Standing forward fold to toes'
	String get standingForwardFoldToToes => 'Standing forward fold to toes';

	/// en: 'Hip extension (bench)'
	String get hipExtensionBench => 'Hip extension (bench)';

	/// en: 'Twist (bent knee, lying)'
	String get twistBentKneeLying => 'Twist (bent knee, lying)';

	/// en: 'Deadlift (cable)'
	String get deadliftCable => 'Deadlift (cable)';

	/// en: 'Pull through (cable, rope)'
	String get pullThroughCableRope => 'Pull through (cable, rope)';

	/// en: 'Hip extension (cable, standing)'
	String get hipExtensionCableStanding => 'Hip extension (cable, standing)';

	/// en: 'Clean (dumbbell)'
	String get cleanDumbbell => 'Clean (dumbbell)';

	/// en: 'Deadlift (dumbbell)'
	String get deadliftDumbbell => 'Deadlift (dumbbell)';

	/// en: 'Snatch (dumbbell, one arm)'
	String get snatchDumbbellOneArm => 'Snatch (dumbbell, one arm)';

	/// en: 'Deadlift (dumbbell, one leg, stepbox support)'
	String get deadliftDumbbellOneLegStepboxSupport => 'Deadlift (dumbbell, one leg, stepbox support)';

	/// en: 'Pull through (dumbbell, sumo)'
	String get pullThroughDumbbellSumo => 'Pull through (dumbbell, sumo)';

	/// en: 'Hip flexor stretch (exercise ball)'
	String get hipFlexorStretchExerciseBall => 'Hip flexor stretch (exercise ball)';

	/// en: 'Prone single-leg hip rotation on ball'
	String get proneSingleLegHipRotationOnBall => 'Prone single-leg hip rotation on ball';

	/// en: 'Ball-supported diagonal kick and leg curl'
	String get ballSupportedDiagonalKickAndLegCurl => 'Ball-supported diagonal kick and leg curl';

	/// en: 'Flutter kicks'
	String get flutterKicks => 'Flutter kicks';

	/// en: 'Glute bridge (march)'
	String get gluteBridgeMarch => 'Glute bridge (march)';

	/// en: 'Glute bridge (two leg, bench)'
	String get gluteBridgeTwoLegBench => 'Glute bridge (two leg, bench)';

	/// en: 'Toe-touch circles with hands clasped'
	String get toeTouchCirclesWithHandsClasped => 'Toe-touch circles with hands clasped';

	/// en: 'Toe-touch circles with reversed hand clasp'
	String get toeTouchCirclesWithReversedHandClasp => 'Toe-touch circles with reversed hand clasp';

	/// en: 'Supine knees-to-chest stretch'
	String get supineKneesToChestStretch => 'Supine knees-to-chest stretch';

	/// en: 'Supine cross-body rotation stretch'
	String get supineCrossBodyRotationStretch => 'Supine cross-body rotation stretch';

	/// en: 'Deadlift (lever)'
	String get deadliftLever => 'Deadlift (lever)';

	/// en: 'Hip extension (lever)'
	String get hipExtensionLever => 'Hip extension (lever)';

	/// en: 'Leg press (lever, horizontal, one leg)'
	String get legPressLeverHorizontalOneLeg => 'Leg press (lever, horizontal, one leg)';

	/// en: 'Reverse hyperextension (lever)'
	String get reverseHyperextensionLever => 'Reverse hyperextension (lever)';

	/// en: 'Wall sit with alternating knee lifts'
	String get wallSitWithAlternatingKneeLifts => 'Wall sit with alternating knee lifts';

	/// en: 'Pelvic tilt into glute bridge'
	String get pelvicTiltIntoGluteBridge => 'Pelvic tilt into glute bridge';

	/// en: 'Push-up (pike to cobra)'
	String get pushUpPikeToCobra => 'Push-up (pike to cobra)';

	/// en: 'Elevated reverse bridge'
	String get elevatedReverseBridge => 'Elevated reverse bridge';

	/// en: 'Hip thrusts (resistance band, knee)'
	String get hipThrustsResistanceBandKnee => 'Hip thrusts (resistance band, knee)';

	/// en: 'Hip abduction (resistance band, seated)'
	String get hipAbductionResistanceBandSeated => 'Hip abduction (resistance band, seated)';

	/// en: 'Reverse hyperextension (stability ball)'
	String get reverseHyperextensionStabilityBall => 'Reverse hyperextension (stability ball)';

	/// en: 'Reverse hyperextension (flat bench)'
	String get reverseHyperextensionFlatBench => 'Reverse hyperextension (flat bench)';

	/// en: 'Rocking frog adductor stretch'
	String get rockingFrogAdductorStretch => 'Rocking frog adductor stretch';

	/// en: 'Lat stretch (roller, hip)'
	String get latStretchRollerHip => 'Lat stretch (roller, hip)';

	/// en: 'Hip stretch (roller)'
	String get hipStretchRoller => 'Hip stretch (roller)';

	/// en: 'Glute stretch (seated)'
	String get gluteStretchSeated => 'Glute stretch (seated)';

	/// en: 'Piriformis stretch (seated)'
	String get piriformisStretchSeated => 'Piriformis stretch (seated)';

	/// en: 'Hip abduction (side bridge)'
	String get hipAbductionSideBridge => 'Hip abduction (side bridge)';

	/// en: 'Hip abduction (side)'
	String get hipAbductionSide => 'Hip abduction (side)';

	/// en: 'Leg press (sled, 45°, wide stance)'
	String get legPressSled45WideStance => 'Leg press (sled, 45°, wide stance)';

	/// en: 'Deadlift (smith)'
	String get deadliftSmith => 'Deadlift (smith)';

	/// en: 'Leg press (smith)'
	String get legPressSmith => 'Leg press (smith)';

	/// en: 'Side-lying straight-leg hip abduction'
	String get sideLyingStraightLegHipAbduction => 'Side-lying straight-leg hip abduction';

	/// en: 'Swimmer kicks'
	String get swimmerKicks => 'Swimmer kicks';

	/// en: 'Tire turnover'
	String get tireTurnover => 'Tire turnover';

	/// en: 'Trap-bar deadlift'
	String get trapBarDeadlift => 'Trap-bar deadlift';

	/// en: 'Hip lift with rotation'
	String get hipLiftWithRotation => 'Hip lift with rotation';
}

// Path: historyEditor.finish.fields
class Translations$historyEditor$finish$fields$en {
	Translations$historyEditor$finish$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$historyEditor$finish$fields$name$en name = Translations$historyEditor$finish$fields$name$en._(_root);
	late final Translations$historyEditor$finish$fields$startingTime$en startingTime = Translations$historyEditor$finish$fields$startingTime$en._(_root);
	late final Translations$historyEditor$finish$fields$parent$en parent = Translations$historyEditor$finish$fields$parent$en._(_root);
	late final Translations$historyEditor$finish$fields$duration$en duration = Translations$historyEditor$finish$fields$duration$en._(_root);
	late final Translations$historyEditor$finish$fields$infobox$en infobox = Translations$historyEditor$finish$fields$infobox$en._(_root);
}

// Path: importRoutine.errors.badJson
class Translations$importRoutine$errors$badJson$en {
	Translations$importRoutine$errors$badJson$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bad data'
	String get title => 'Bad data';

	/// en: 'The link you followed is malformed and cannot be opened.'
	String get body => 'The link you followed is malformed and cannot be opened.';
}

// Path: importRoutine.errors.noJson
class Translations$importRoutine$errors$noJson$en {
	Translations$importRoutine$errors$noJson$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No data'
	String get title => 'No data';

	/// en: 'The link you followed is malformed and cannot be opened.'
	String get body => 'The link you followed is malformed and cannot be opened.';
}

// Path: importRoutine.errors.badWorkout
class Translations$importRoutine$errors$badWorkout$en {
	Translations$importRoutine$errors$badWorkout$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bad workout'
	String get title => 'Bad workout';

	/// en: 'The link you followed leads to a malformed workout. Maybe it was created by an older version of the app.'
	String get body => 'The link you followed leads to a malformed workout. Maybe it was created by an older version of the app.';
}

// Path: me.weight.allData
class Translations$me$weight$allData$en {
	Translations$me$weight$allData$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Show all data'
	String get label => 'Show all data';
}

// Path: me.weight.measured
class Translations$me$weight$measured$en {
	Translations$me$weight$measured$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Last measured: never'
	String get never => 'Last measured: never';

	/// en: 'Last measured: $date'
	String date({required Object date}) => 'Last measured: ${date}';
}

// Path: me.addWeight.time
class Translations$me$addWeight$time$en {
	Translations$me$addWeight$time$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Date and time'
	String get label => 'Date and time';
}

// Path: me.addWeight.weight
class Translations$me$addWeight$weight$en {
	Translations$me$addWeight$weight$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weight'
	String get label => 'Weight';
}

// Path: me.addWeight.weightUnit
class Translations$me$addWeight$weightUnit$en {
	Translations$me$addWeight$weightUnit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unit'
	String get label => 'Unit';
}

// Path: me.addWeight.errors
class Translations$me$addWeight$errors$en {
	Translations$me$addWeight$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter a valid weight'
	String get invalidWeight => 'Enter a valid weight';
}

// Path: me.allData.removed
class Translations$me$allData$removed$en {
	Translations$me$allData$removed$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The data has been removed'
	String get text => 'The data has been removed';
}

// Path: me.allData.predictedWeight
class Translations$me$allData$predictedWeight$en {
	Translations$me$allData$predictedWeight$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Predicted weight'
	String get label => 'Predicted weight';

	late final Translations$me$allData$predictedWeight$dialog$en dialog = Translations$me$allData$predictedWeight$dialog$en._(_root);
}

// Path: me.stats.workouts
class Translations$me$stats$workouts$en {
	Translations$me$stats$workouts$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Workouts'
	String get label => 'Workouts';
}

// Path: me.stats.duration
class Translations$me$stats$duration$en {
	Translations$me$stats$duration$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Duration'
	String get label => 'Duration';
}

// Path: me.stats.volume
class Translations$me$stats$volume$en {
	Translations$me$stats$volume$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Volume'
	String get label => 'Volume';
}

// Path: me.stats.distance
class Translations$me$stats$distance$en {
	Translations$me$stats$distance$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Distance ran'
	String get label => 'Distance ran';
}

// Path: me.stats.sets
class Translations$me$stats$sets$en {
	Translations$me$stats$sets$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sets'
	String get label => 'Sets';
}

// Path: me.stats.overview
class Translations$me$stats$overview$en {
	Translations$me$stats$overview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This week'
	String get thisWeek => 'This week';

	/// en: 'Progress'
	String get title => 'Progress';

	/// en: 'Lifted volume'
	String get volume => 'Lifted volume';

	/// en: 'Personal records'
	String get personalRecords => 'Personal records';

	/// en: 'Load records: at the same weight, the set with more repetitions wins.'
	String get recordCriteria => 'Load records: at the same weight, the set with more repetitions wins.';

	/// en: 'Complete a set with weight and repetitions to see your personal records.'
	String get emptyRecords => 'Complete a set with weight and repetitions to see your personal records.';

	/// en: 'No volume recorded this week.'
	String get emptyWeek => 'No volume recorded this week.';

	/// en: 'Unable to load progress'
	String get loadError => 'Unable to load progress';

	/// en: 'Try again to load your workouts.'
	String get retryDescription => 'Try again to load your workouts.';
}

// Path: me.stats.mainThree
class Translations$me$stats$mainThree$en {
	Translations$me$stats$mainThree$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The Main Three'
	String get label => 'The Main Three';

	/// en: 'View the evolution of your 1RM for the "Main Three" over the selected time frame. The chart uses the highest 1RM of each week to display the overall trend of loads in the three fundamental exercises of powerlifting.'
	String get description => 'View the evolution of your 1RM for the "Main Three" over the selected time frame. The chart uses the highest 1RM of each week to display the overall trend of loads in the three fundamental exercises of powerlifting.';

	late final Translations$me$stats$mainThree$warning$en warning = Translations$me$stats$mainThree$warning$en._(_root);

	/// en: 'W$week'
	String bottomTitle({required Object week}) => 'W${week}';
}

// Path: me.profile.edit
class Translations$me$profile$edit$en {
	Translations$me$profile$edit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit profile'
	String get title => 'Edit profile';
}

// Path: me.profile.errors
class Translations$me$profile$errors$en {
	Translations$me$profile$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$me$profile$errors$logout$en logout = Translations$me$profile$errors$logout$en._(_root);
}

// Path: routineFormPicker.fields.routine
class Translations$routineFormPicker$fields$routine$en {
	Translations$routineFormPicker$fields$routine$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$routineFormPicker$fields$routine$options$en options = Translations$routineFormPicker$fields$routine$options$en._(_root);
}

// Path: cardioTimer.setUp.errors
class Translations$cardioTimer$setUp$errors$en {
	Translations$cardioTimer$setUp$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The duration must not be null.'
	String get duration => 'The duration must not be null.';

	/// en: 'Both times can't be zero.'
	String get bothZeros => 'Both times can\'t be zero.';

	/// en: 'There are errors in the settings. Fix them and try again.'
	String get generic => 'There are errors in the settings. Fix them and try again.';
}

// Path: migrations.customToLibraryExercise.fields
class Translations$migrations$customToLibraryExercise$fields$en {
	Translations$migrations$customToLibraryExercise$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$customToLibraryExercise$fields$from$en from = Translations$migrations$customToLibraryExercise$fields$from$en._(_root);
	late final Translations$migrations$customToLibraryExercise$fields$to$en to = Translations$migrations$customToLibraryExercise$fields$to$en._(_root);
}

// Path: migrations.customToLibraryExercise.preview
class Translations$migrations$customToLibraryExercise$preview$en {
	Translations$migrations$customToLibraryExercise$preview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Replace…'
	String get from => 'Replace…';

	/// en: 'With…'
	String get to => 'With…';

	/// en: 'Affected routines'
	String get affectedRoutines => 'Affected routines';

	/// en: 'Affected workouts in history'
	String get affectedWorkouts => 'Affected workouts in history';
}

// Path: migrations.common.actions
class Translations$migrations$common$actions$en {
	Translations$migrations$common$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Next step: preview'
	String get next => 'Next step: preview';

	/// en: 'Apply migration'
	String get apply => 'Apply migration';
}

// Path: migrations.removeUnusedExercises.preview
class Translations$migrations$removeUnusedExercises$preview$en {
	Translations$migrations$removeUnusedExercises$preview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No data affected.'
	String get noAffected => 'No data affected.';

	/// en: 'Affected exercises'
	String get affectedExercises => 'Affected exercises';
}

// Path: migrations.removeWeightFromCustomExercise.preview
class Translations$migrations$removeWeightFromCustomExercise$preview$en {
	Translations$migrations$removeWeightFromCustomExercise$preview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$removeWeightFromCustomExercise$preview$incompatible$en incompatible = Translations$migrations$removeWeightFromCustomExercise$preview$incompatible$en._(_root);

	/// en: 'Selected exercise'
	String get selected => 'Selected exercise';

	/// en: 'Affected routines'
	String get affectedRoutines => 'Affected routines';

	/// en: 'Affected workouts in history'
	String get affectedWorkouts => 'Affected workouts in history';
}

// Path: migrations.removeWeightFromCustomExercise.fields
class Translations$migrations$removeWeightFromCustomExercise$fields$en {
	Translations$migrations$removeWeightFromCustomExercise$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$removeWeightFromCustomExercise$fields$exercise$en exercise = Translations$migrations$removeWeightFromCustomExercise$fields$exercise$en._(_root);
}

// Path: migrations.genericMultiplyWeight.fields
class Translations$migrations$genericMultiplyWeight$fields$en {
	Translations$migrations$genericMultiplyWeight$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$genericMultiplyWeight$fields$exercise$en exercise = Translations$migrations$genericMultiplyWeight$fields$exercise$en._(_root);
}

// Path: migrations.genericMultiplyWeight.preview
class Translations$migrations$genericMultiplyWeight$preview$en {
	Translations$migrations$genericMultiplyWeight$preview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$migrations$genericMultiplyWeight$preview$incompatible$en incompatible = Translations$migrations$genericMultiplyWeight$preview$incompatible$en._(_root);

	/// en: 'Selected exercise'
	String get selected => 'Selected exercise';

	/// en: 'Affected routines'
	String get affectedRoutines => 'Affected routines';

	/// en: 'Affected history workouts'
	String get affectedWorkouts => 'Affected history workouts';
}

// Path: exerciseFormPicker.fields.exercise
class Translations$exerciseFormPicker$fields$exercise$en {
	Translations$exerciseFormPicker$fields$exercise$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exerciseFormPicker$fields$exercise$options$en options = Translations$exerciseFormPicker$fields$exercise$options$en._(_root);
}

// Path: food.add.customFood
class Translations$food$add$customFood$en {
	Translations$food$add$customFood$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Show all fields'
	String get showMore => 'Show all fields';

	/// en: 'Add custom food'
	String get title => 'Add custom food';

	late final Translations$food$add$customFood$fields$en fields = Translations$food$add$customFood$fields$en._(_root);
}

// Path: food.search.error
class Translations$food$search$error$en {
	Translations$food$search$error$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Could not reach the food catalog. Please try again later.'
	String get serverError => 'Could not reach the food catalog. Please try again later.';

	/// en: 'Could not reach the food catalog. Please try again later.'
	String get generic => 'Could not reach the food catalog. Please try again later.';
}

// Path: food.barcodeReader.scanResult
class Translations$food$barcodeReader$scanResult$en {
	Translations$food$barcodeReader$scanResult$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$food$barcodeReader$scanResult$noProductFound$en noProductFound = Translations$food$barcodeReader$scanResult$noProductFound$en._(_root);
	late final Translations$food$barcodeReader$scanResult$error$en error = Translations$food$barcodeReader$scanResult$error$en._(_root);
}

// Path: food.barcodeReader.codeField
class Translations$food$barcodeReader$codeField$en {
	Translations$food$barcodeReader$codeField$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Barcode'
	String get label => 'Barcode';

	/// en: 'This field must not be empty'
	String get empty => 'This field must not be empty';
}

// Path: food.addCustomFood.permission
class Translations$food$addCustomFood$permission$en {
	Translations$food$addCustomFood$permission$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You need to grant the following permissions'
	String get title => 'You need to grant the following permissions';

	/// en: 'Camera (and microphone)'
	String get camera => 'Camera (and microphone)';

	/// en: 'Photo library access (to scan barcodes in pictures)'
	String get gallery => 'Photo library access (to scan barcodes in pictures)';

	/// en: 'Check again'
	String get recheck => 'Check again';

	/// en: 'Open permission settings'
	String get openAppSettings => 'Open permission settings';
}

// Path: food.nutritionGoal.effect
class Translations$food$nutritionGoal$effect$en {
	Translations$food$nutritionGoal$effect$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This change will take effect from $from onward.'
	String from({required Object from}) => 'This change will take effect from ${from} onward.';

	/// en: 'This change will take effect from $from to $to.'
	String range({required Object from, required Object to}) => 'This change will take effect from ${from} to ${to}.';
}

// Path: food.nutritionGoals.change
class Translations$food$nutritionGoals$change$en {
	Translations$food$nutritionGoals$change$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Set goal'
	String get title => 'Set goal';

	late final Translations$food$nutritionGoals$change$calories$en calories = Translations$food$nutritionGoals$change$calories$en._(_root);
	late final Translations$food$nutritionGoals$change$fatPercentage$en fatPercentage = Translations$food$nutritionGoals$change$fatPercentage$en._(_root);
	late final Translations$food$nutritionGoals$change$carbsPercentage$en carbsPercentage = Translations$food$nutritionGoals$change$carbsPercentage$en._(_root);
	late final Translations$food$nutritionGoals$change$proteinPercentage$en proteinPercentage = Translations$food$nutritionGoals$change$proteinPercentage$en._(_root);

	/// en: 'Save changes'
	String get save => 'Save changes';
}

// Path: food.nutritionGoals.history
class Translations$food$nutritionGoals$history$en {
	Translations$food$nutritionGoals$history$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Goal history'
	String get title => 'Goal history';

	/// en: 'There are no goals.'
	String get empty => 'There are no goals.';

	/// en: 'Tap to view day'
	String get tapToView => 'Tap to view day';

	/// en: 'Daily calories: $calories'
	String calories({required Object calories}) => 'Daily calories: ${calories}';

	/// en: '$carbs carbs – $protein protein – $fat fat'
	String macros({required Object carbs, required Object protein, required Object fat}) => '${carbs} carbs – ${protein} protein – ${fat} fat';
}

// Path: food.categoryList.unmodifiable
class Translations$food$categoryList$unmodifiable$en {
	Translations$food$categoryList$unmodifiable$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unable to edit'
	String get title => 'Unable to edit';

	/// en: 'You can only edit categories on days on or after today's date'
	String get text => 'You can only edit categories on days on or after today\'s date';
}

// Path: food.categoryEditor.title
class Translations$food$categoryEditor$title$en {
	Translations$food$categoryEditor$title$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add category'
	String get add => 'Add category';

	/// en: 'Edit category'
	String get edit => 'Edit category';
}

// Path: food.categoryEditor.fields
class Translations$food$categoryEditor$fields$en {
	Translations$food$categoryEditor$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$food$categoryEditor$fields$name$en name = Translations$food$categoryEditor$fields$name$en._(_root);
}

// Path: food.categoryEditor.effect
class Translations$food$categoryEditor$effect$en {
	Translations$food$categoryEditor$effect$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Any change will take effect from $from onward.'
	String from({required Object from}) => 'Any change will take effect from ${from} onward.';

	/// en: 'Any change will take effect from $from to $to.'
	String range({required Object from, required Object to}) => 'Any change will take effect from ${from} to ${to}.';

	/// en: 'Category effect range'
	String get title => 'Category effect range';
}

// Path: food.categoryEditor.nonFulfillingSum
class Translations$food$categoryEditor$nonFulfillingSum$en {
	Translations$food$categoryEditor$nonFulfillingSum$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The sum doesn't equal 100%'
	String get title => 'The sum doesn\'t equal 100%';
}

// Path: achievements.firstSteps.description
class Translations$achievements$firstSteps$description$en {
	Translations$achievements$firstSteps$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Complete your first workout'
	String get k1 => 'Complete your first workout';

	/// en: 'Log your first weight'
	String get k2 => 'Log your first weight';

	/// en: 'Log your first meal'
	String get k3 => 'Log your first meal';
}

// Path: achievements.foodWatcher.description
class Translations$achievements$foodWatcher$description$en {
	Translations$achievements$foodWatcher$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log your meals two days in a row'
	String get k1 => 'Log your meals two days in a row';

	/// en: 'Log your meals a week in a row'
	String get k2 => 'Log your meals a week in a row';

	/// en: 'Log your meals a month in a row'
	String get k3 => 'Log your meals a month in a row';
}

// Path: achievements.marathoner.description
class Translations$achievements$marathoner$description$en {
	Translations$achievements$marathoner$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Run or bike a 5km'
	String get k1 => 'Run or bike a 5km';

	/// en: 'Run or bike a half marathon'
	String get k2 => 'Run or bike a half marathon';

	/// en: 'Run or bike a full marathon'
	String get k3 => 'Run or bike a full marathon';
}

// Path: achievements.realGymBro.description
class Translations$achievements$realGymBro$description$en {
	Translations$achievements$realGymBro$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log a total of 100 hours worth of workouts'
	String get k1 => 'Log a total of 100 hours worth of workouts';

	/// en: 'Log a total of 500 hours worth of workouts'
	String get k2 => 'Log a total of 500 hours worth of workouts';

	/// en: 'Log a total of 1000 hours worth of workouts'
	String get k3 => 'Log a total of 1000 hours worth of workouts';
}

// Path: achievements.workoutFreak.description
class Translations$achievements$workoutFreak$description$en {
	Translations$achievements$workoutFreak$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log a workout every day of the month'
	String get k1 => 'Log a workout every day of the month';

	/// en: 'Log a workout every day of the year'
	String get k2 => 'Log a workout every day of the year';
}

// Path: achievements.trailblazer.description
class Translations$achievements$trailblazer$description$en {
	Translations$achievements$trailblazer$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$achievements$trailblazer$description$k1$en k1 = Translations$achievements$trailblazer$description$k1$en._(_root);
	late final Translations$achievements$trailblazer$description$k2$en k2 = Translations$achievements$trailblazer$description$k2$en._(_root);
	late final Translations$achievements$trailblazer$description$k3$en k3 = Translations$achievements$trailblazer$description$k3$en._(_root);
}

// Path: achievements.cycleChampion.description
class Translations$achievements$cycleChampion$description$en {
	Translations$achievements$cycleChampion$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$achievements$cycleChampion$description$k1$en k1 = Translations$achievements$cycleChampion$description$k1$en._(_root);
	late final Translations$achievements$cycleChampion$description$k2$en k2 = Translations$achievements$cycleChampion$description$k2$en._(_root);
	late final Translations$achievements$cycleChampion$description$k3$en k3 = Translations$achievements$cycleChampion$description$k3$en._(_root);
}

// Path: achievements.professionalWeightlifter.description
class Translations$achievements$professionalWeightlifter$description$en {
	Translations$achievements$professionalWeightlifter$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lift your body weight in a single rep'
	String get k1 => 'Lift your body weight in a single rep';

	/// en: 'Lift 1.5x your body weight in a single rep'
	String get k2 => 'Lift 1.5x your body weight in a single rep';

	/// en: 'Lift 3x your body weight in a single rep'
	String get k3 => 'Lift 3x your body weight in a single rep';
}

// Path: achievements.routineMaster.description
class Translations$achievements$routineMaster$description$en {
	Translations$achievements$routineMaster$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Follow a routine for 3 consecutive months'
	String get k1 => 'Follow a routine for 3 consecutive months';

	/// en: 'Follow a routine for 6 consecutive months'
	String get k2 => 'Follow a routine for 6 consecutive months';

	/// en: 'Follow a routine for 12 consecutive months'
	String get k3 => 'Follow a routine for 12 consecutive months';
}

// Path: achievements.sparta.description
class Translations$achievements$sparta$description$en {
	Translations$achievements$sparta$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$achievements$sparta$description$k1$en k1 = Translations$achievements$sparta$description$k1$en._(_root);
	late final Translations$achievements$sparta$description$k2$en k2 = Translations$achievements$sparta$description$k2$en._(_root);
}

// Path: login.errors.password
class Translations$login$errors$password$en {
	Translations$login$errors$password$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$login$errors$password$invalid$en invalid = Translations$login$errors$password$invalid$en._(_root);
}

// Path: login.fields.email
class Translations$login$fields$email$en {
	Translations$login$fields$email$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email'
	String get label => 'Email';

	/// en: 'john.doe@example.com'
	String get hint => 'john.doe@example.com';
}

// Path: login.fields.password
class Translations$login$fields$password$en {
	Translations$login$fields$password$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Password'
	String get label => 'Password';

	/// en: 'Password'
	String get hint => 'Password';
}

// Path: login.fields.username
class Translations$login$fields$username$en {
	Translations$login$fields$username$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Username'
	String get label => 'Username';

	/// en: 'Username'
	String get hint => 'Username';
}

// Path: login.fields.confirmPassword
class Translations$login$fields$confirmPassword$en {
	Translations$login$fields$confirmPassword$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Confirm password'
	String get label => 'Confirm password';
}

// Path: feed.workout.title
class Translations$feed$workout$title$en {
	Translations$feed$workout$title$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You'
	String get you => 'You';

	/// en: 'Unknown User'
	String get unknown => 'Unknown User';
}

// Path: feed.workout.subtitle
class Translations$feed$workout$subtitle$en {
	Translations$feed$workout$subtitle$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'completed a workout'
	String get you => 'completed a workout';

	/// en: 'completed a workout'
	String get friend => 'completed a workout';
}

// Path: feed.achievement.title
class Translations$feed$achievement$title$en {
	Translations$feed$achievement$title$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You'
	String get you => 'You';
}

// Path: feed.achievement.subtitle
class Translations$feed$achievement$subtitle$en {
	Translations$feed$achievement$subtitle$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'unlocked an achievement'
	String get you => 'unlocked an achievement';

	/// en: 'unlocked an achievement'
	String get friend => 'unlocked an achievement';
}

// Path: userProfile.feed.unavailable
class Translations$userProfile$feed$unavailable$en {
	Translations$userProfile$feed$unavailable$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Workouts not visible'
	String get title => 'Workouts not visible';

	/// en: 'Workout data is only visible to friends.'
	String get description => 'Workout data is only visible to friends.';
}

// Path: userProfile.crop.buttons
class Translations$userProfile$crop$buttons$en {
	Translations$userProfile$crop$buttons$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Crop'
	String get confirm => 'Crop';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: exercise.editor.fields.title
class Translations$exercise$editor$fields$title$en {
	Translations$exercise$editor$fields$title$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exercise name'
	String get label => 'Exercise name';

	late final Translations$exercise$editor$fields$title$errors$en errors = Translations$exercise$editor$fields$title$errors$en._(_root);
}

// Path: exercise.editor.fields.parameters
class Translations$exercise$editor$fields$parameters$en {
	Translations$exercise$editor$fields$parameters$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Parameters'
	String get label => 'Parameters';

	Map<String, String> get values => {
		'repsNegWeight': 'Negative weight & reps',
		'repsWeight': 'Weight & reps',
		'timeWeight': 'Weight & time',
		'time': 'Time',
		'freeBodyReps': 'Reps',
		'distance': 'Distance',
	};
	late final Translations$exercise$editor$fields$parameters$errors$en errors = Translations$exercise$editor$fields$parameters$errors$en._(_root);
}

// Path: exercise.editor.fields.primaryMuscleGroup
class Translations$exercise$editor$fields$primaryMuscleGroup$en {
	Translations$exercise$editor$fields$primaryMuscleGroup$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Primary muscle group'
	String get label => 'Primary muscle group';

	late final Translations$exercise$editor$fields$primaryMuscleGroup$errors$en errors = Translations$exercise$editor$fields$primaryMuscleGroup$errors$en._(_root);
}

// Path: exercise.editor.fields.secondaryMuscleGroups
class Translations$exercise$editor$fields$secondaryMuscleGroups$en {
	Translations$exercise$editor$fields$secondaryMuscleGroups$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Other muscle groups'
	String get label => 'Other muscle groups';
}

// Path: exercise.editor.fields.notes
class Translations$exercise$editor$fields$notes$en {
	Translations$exercise$editor$fields$notes$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notes'
	String get label => 'Notes';

	/// en: 'Tap to enter notes'
	String get tapToEdit => 'Tap to enter notes';
}

// Path: exercise.editor.fields.rpe
class Translations$exercise$editor$fields$rpe$en {
	Translations$exercise$editor$fields$rpe$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Remove RPE'
	String get removeRPE => 'Remove RPE';

	/// en: 'Set RPE'
	String get label => 'Set RPE';

	late final Translations$exercise$editor$fields$rpe$description$en description = Translations$exercise$editor$fields$rpe$description$en._(_root);
	List<dynamic> get levels => [
		Translations$exercise$editor$fields$rpe$levels$0$en._(_root),
		Translations$exercise$editor$fields$rpe$levels$1$en._(_root),
		Translations$exercise$editor$fields$rpe$levels$2$en._(_root),
		Translations$exercise$editor$fields$rpe$levels$3$en._(_root),
		Translations$exercise$editor$fields$rpe$levels$4$en._(_root),
		Translations$exercise$editor$fields$rpe$levels$5$en._(_root),
		Translations$exercise$editor$fields$rpe$levels$6$en._(_root),
		Translations$exercise$editor$fields$rpe$levels$7$en._(_root),
		Translations$exercise$editor$fields$rpe$levels$8$en._(_root),
		Translations$exercise$editor$fields$rpe$levels$9$en._(_root),
	];
}

// Path: exercise.editor.fields.reorderSets
class Translations$exercise$editor$fields$reorderSets$en {
	Translations$exercise$editor$fields$reorderSets$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reorder sets'
	String get title => 'Reorder sets';

	/// en: 'Drag the handles to reorder the sets'
	String get text => 'Drag the handles to reorder the sets';
}

// Path: exercise.editor.fields.gymEquipment
class Translations$exercise$editor$fields$gymEquipment$en {
	Translations$exercise$editor$fields$gymEquipment$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$exercise$editor$fields$gymEquipment$errors$en errors = Translations$exercise$editor$fields$gymEquipment$errors$en._(_root);

	/// en: 'Equipment'
	String get label => 'Equipment';
}

// Path: exercise.editor.advanced.setless
class Translations$exercise$editor$advanced$setless$en {
	Translations$exercise$editor$advanced$setless$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No sets'
	String get title => 'No sets';

	/// en: 'Disable set functionality for this exercise. This option effectively makes this a placeholder exercise in your workouts.'
	String get text => 'Disable set functionality for this exercise. This option effectively makes this a placeholder exercise in your workouts.';
}

// Path: exercise.continuation.combine.confirm
class Translations$exercise$continuation$combine$confirm$en {
	Translations$exercise$continuation$combine$confirm$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Combine workouts'
	String get title => 'Combine workouts';

	/// en: 'Are you sure you want to combine these workouts? This action cannot be undone, and the old workouts will be deleted.'
	String get body => 'Are you sure you want to combine these workouts? This action cannot be undone, and the old workouts will be deleted.';
}

// Path: workouts.actions.delete.actions
class Translations$workouts$actions$delete$actions$en {
	Translations$workouts$actions$delete$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get no => 'Cancel';

	/// en: 'Delete'
	String get yes => 'Delete';
}

// Path: workouts.actions.rename.errors
class Translations$workouts$actions$rename$errors$en {
	Translations$workouts$actions$rename$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The name must not be empty.'
	String get empty => 'The name must not be empty.';
}

// Path: workouts.actions.changeParent.options
class Translations$workouts$actions$changeParent$options$en {
	Translations$workouts$actions$changeParent$options$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No routine'
	String get none => 'No routine';
}

// Path: workouts.actions.share.alert
class Translations$workouts$actions$share$alert$en {
	Translations$workouts$actions$share$alert$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Link generated'
	String get title => 'Link generated';

	/// en: 'A unique link has been generated. Click the button below to copy it, and send it to share the routine.'
	String get body => 'A unique link has been generated. Click the button below to copy it, and send it to share the routine.';

	late final Translations$workouts$actions$share$alert$actions$en actions = Translations$workouts$actions$share$alert$actions$en._(_root);

	/// en: 'Unable to generate QR code: routine is too large. Use link below to share your routine.'
	String get noQr => 'Unable to generate QR code: routine is too large. Use link below to share your routine.';
}

// Path: routines.actions.delete.actions
class Translations$routines$actions$delete$actions$en {
	Translations$routines$actions$delete$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get no => 'Cancel';

	/// en: 'Delete'
	String get yes => 'Delete';
}

// Path: routines.editor.fields.name
class Translations$routines$editor$fields$name$en {
	Translations$routines$editor$fields$name$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Routine name'
	String get label => 'Routine name';

	late final Translations$routines$editor$fields$name$errors$en errors = Translations$routines$editor$fields$name$errors$en._(_root);
}

// Path: routines.editor.fields.infobox
class Translations$routines$editor$fields$infobox$en {
	Translations$routines$editor$fields$infobox$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notes'
	String get label => 'Notes';
}

// Path: routines.editor.superset.remove
class Translations$routines$editor$superset$remove$en {
	Translations$routines$editor$superset$remove$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Remove superset'
	String get title => 'Remove superset';

	/// en: 'Are you sure you want to remove this superset? This action cannot be undone.'
	String get body => 'Are you sure you want to remove this superset? This action cannot be undone.';
}

// Path: history.actions.deleteMultiple.actions
class Translations$history$actions$deleteMultiple$actions$en {
	Translations$history$actions$deleteMultiple$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get no => 'Cancel';

	/// en: 'Delete'
	String get yes => 'Delete';
}

// Path: settings.options.locale.values
class Translations$settings$options$locale$values$en {
	Translations$settings$options$locale$values$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'System'
	String get system => 'System';
}

// Path: settings.options.import.failed
class Translations$settings$options$import$failed$en {
	Translations$settings$options$import$failed$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to import data'
	String get title => 'Failed to import data';

	/// en: 'The error message has been copied to the clipboard.'
	String get copy => 'The error message has been copied to the clipboard.';
}

// Path: settings.options.import.utils
class Translations$settings$options$import$utils$en {
	Translations$settings$options$import$utils$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$options$import$utils$hevy$en hevy = Translations$settings$options$import$utils$hevy$en._(_root);
}

// Path: settings.options.import.types
class Translations$settings$options$import$types$en {
	Translations$settings$options$import$types$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Gym Bro (JSON)'
	String get gt => 'Gym Bro (JSON)';

	/// en: 'Hevy (CSV)'
	String get hevy => 'Hevy (CSV)';
}

// Path: settings.options.export.failed
class Translations$settings$options$export$failed$en {
	Translations$settings$options$export$failed$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to export data'
	String get title => 'Failed to export data';

	/// en: 'The error message has been copied to the clipboard.'
	String get copy => 'The error message has been copied to the clipboard.';
}

// Path: settings.options.notifications.subtitle
class Translations$settings$options$notifications$subtitle$en {
	Translations$settings$options$notifications$subtitle$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tap to request "Exact alarms" permission (Android 14+)'
	String get noExactAlarmPermission => 'Tap to request "Exact alarms" permission (Android 14+)';
}

// Path: settings.advanced.options.logs
class Translations$settings$advanced$options$logs$en {
	Translations$settings$advanced$options$logs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Logs'
	String get title => 'Logs';

	Map<String, String> get levels => {
		'trace': 'Trace',
		'debug': 'Debug',
		'info': 'Info',
		'warning': 'Warning',
		'error': 'Error',
		'fatal': 'Fatal',
	};

	/// en: 'Level'
	String get level => 'Level';
}

// Path: settings.advanced.options.migrations
class Translations$settings$advanced$options$migrations$en {
	Translations$settings$advanced$options$migrations$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Migrations'
	String get title => 'Migrations';
}

// Path: settings.advanced.options.backups
class Translations$settings$advanced$options$backups$en {
	Translations$settings$advanced$options$backups$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Backups'
	String get title => 'Backups';

	late final Translations$settings$advanced$options$backups$restore$en restore = Translations$settings$advanced$options$backups$restore$en._(_root);

	/// en: 'Restoring'
	String get restoring => 'Restoring';

	/// en: 'Create backup'
	String get create => 'Create backup';

	/// en: 'Backing up'
	String get creating => 'Backing up';

	late final Translations$settings$advanced$options$backups$delete$en delete = Translations$settings$advanced$options$backups$delete$en._(_root);

	/// en: 'Deleting'
	String get deleting => 'Deleting';
}

// Path: settings.advanced.options.sync
class Translations$settings$advanced$options$sync$en {
	Translations$settings$advanced$options$sync$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sync status'
	String get title => 'Sync status';

	late final Translations$settings$advanced$options$sync$status$en status = Translations$settings$advanced$options$sync$status$en._(_root);

	/// en: 'Last sync: $date'
	String lastSync({required Object date}) => 'Last sync: ${date}';

	/// en: 'Never synced'
	String get never => 'Never synced';

	/// en: 'Not logged in'
	String get notLoggedIn => 'Not logged in';

	/// en: 'Sync now'
	String get syncNow => 'Sync now';

	/// en: 'Please wait a minute before syncing again'
	String get rateLimited => 'Please wait a minute before syncing again';
}

// Path: settings.advanced.deleteAccount.warning
class Translations$settings$advanced$deleteAccount$warning$en {
	Translations$settings$advanced$deleteAccount$warning$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Permanently delete your account?'
	String get title => 'Permanently delete your account?';

	/// en: 'You will instantly lose all your data. You won't be able to undo this. Are you sure you want to continue?'
	String get content => 'You will instantly lose all your data. You won\'t be able to undo this. Are you sure you want to continue?';
}

// Path: settings.advanced.deleteAccount.confirmation
class Translations$settings$advanced$deleteAccount$confirmation$en {
	Translations$settings$advanced$deleteAccount$confirmation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Confirm deletion'
	String get title => 'Confirm deletion';

	/// en: 'Type your username ($username) to proceed.'
	String content({required Object username}) => 'Type your username (${username}) to proceed.';

	/// en: 'Username'
	String get hint => 'Username';

	late final Translations$settings$advanced$deleteAccount$confirmation$error$en error = Translations$settings$advanced$deleteAccount$confirmation$error$en._(_root);
}

// Path: ongoingWorkout.finish.fields.name
class Translations$ongoingWorkout$finish$fields$name$en {
	Translations$ongoingWorkout$finish$fields$name$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Workout name'
	String get label => 'Workout name';

	late final Translations$ongoingWorkout$finish$fields$name$errors$en errors = Translations$ongoingWorkout$finish$fields$name$errors$en._(_root);
}

// Path: ongoingWorkout.finish.fields.startingTime
class Translations$ongoingWorkout$finish$fields$startingTime$en {
	Translations$ongoingWorkout$finish$fields$startingTime$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Starting time'
	String get label => 'Starting time';
}

// Path: ongoingWorkout.finish.fields.parent
class Translations$ongoingWorkout$finish$fields$parent$en {
	Translations$ongoingWorkout$finish$fields$parent$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reference routine'
	String get label => 'Reference routine';

	late final Translations$ongoingWorkout$finish$fields$parent$options$en options = Translations$ongoingWorkout$finish$fields$parent$options$en._(_root);

	/// en: 'Link this workout to a routine. You will be asked about any routine updates after saving.'
	String get help => 'Link this workout to a routine. You will be asked about any routine updates after saving.';
}

// Path: ongoingWorkout.finish.fields.duration
class Translations$ongoingWorkout$finish$fields$duration$en {
	Translations$ongoingWorkout$finish$fields$duration$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Duration'
	String get label => 'Duration';

	late final Translations$ongoingWorkout$finish$fields$duration$errors$en errors = Translations$ongoingWorkout$finish$fields$duration$errors$en._(_root);
}

// Path: ongoingWorkout.finish.fields.infobox
class Translations$ongoingWorkout$finish$fields$infobox$en {
	Translations$ongoingWorkout$finish$fields$infobox$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notes'
	String get label => 'Notes';
}

// Path: historyEditor.finish.fields.name
class Translations$historyEditor$finish$fields$name$en {
	Translations$historyEditor$finish$fields$name$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Name'
	String get label => 'Name';

	late final Translations$historyEditor$finish$fields$name$errors$en errors = Translations$historyEditor$finish$fields$name$errors$en._(_root);
}

// Path: historyEditor.finish.fields.startingTime
class Translations$historyEditor$finish$fields$startingTime$en {
	Translations$historyEditor$finish$fields$startingTime$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Starting time'
	String get label => 'Starting time';
}

// Path: historyEditor.finish.fields.parent
class Translations$historyEditor$finish$fields$parent$en {
	Translations$historyEditor$finish$fields$parent$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Categorize under'
	String get label => 'Categorize under';

	late final Translations$historyEditor$finish$fields$parent$options$en options = Translations$historyEditor$finish$fields$parent$options$en._(_root);
}

// Path: historyEditor.finish.fields.duration
class Translations$historyEditor$finish$fields$duration$en {
	Translations$historyEditor$finish$fields$duration$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Duration'
	String get label => 'Duration';

	late final Translations$historyEditor$finish$fields$duration$errors$en errors = Translations$historyEditor$finish$fields$duration$errors$en._(_root);
}

// Path: historyEditor.finish.fields.infobox
class Translations$historyEditor$finish$fields$infobox$en {
	Translations$historyEditor$finish$fields$infobox$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notes'
	String get label => 'Notes';
}

// Path: me.allData.predictedWeight.dialog
class Translations$me$allData$predictedWeight$dialog$en {
	Translations$me$allData$predictedWeight$dialog$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Predicted weight'
	String get title => 'Predicted weight';

	/// en: 'The predicted weight is provided for informative purposes only and should not be taken seriously.'
	String get text => 'The predicted weight is provided for informative purposes only and should not be taken seriously.';
}

// Path: me.stats.mainThree.warning
class Translations$me$stats$mainThree$warning$en {
	Translations$me$stats$mainThree$warning$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'A note on the chart'
	String get title => 'A note on the chart';

	/// en: 'To ensure your progress is calculated and displayed correctly in the chart, use the standard exercises from the app library rather than creating custom variations. Specifically: $exercises.'
	String text({required Object exercises}) => 'To ensure your progress is calculated and displayed correctly in the chart, use the standard exercises from the app library rather than creating custom variations. Specifically: ${exercises}.';
}

// Path: me.profile.errors.logout
class Translations$me$profile$errors$logout$en {
	Translations$me$profile$errors$logout$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'An error occurred while logging out'
	String get title => 'An error occurred while logging out';

	/// en: 'Couldn't log out: $error'
	String subtitle({required Object error}) => 'Couldn\'t log out: ${error}';
}

// Path: routineFormPicker.fields.routine.options
class Translations$routineFormPicker$fields$routine$options$en {
	Translations$routineFormPicker$fields$routine$options$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No routine selected'
	String get none => 'No routine selected';

	/// en: 'Home'
	String get root => 'Home';
}

// Path: migrations.customToLibraryExercise.fields.from
class Translations$migrations$customToLibraryExercise$fields$from$en {
	Translations$migrations$customToLibraryExercise$fields$from$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Replace all occurrences of this custom exercise…'
	String get title => 'Replace all occurrences of this custom exercise…';

	/// en: 'Custom exercise'
	String get label => 'Custom exercise';
}

// Path: migrations.customToLibraryExercise.fields.to
class Translations$migrations$customToLibraryExercise$fields$to$en {
	Translations$migrations$customToLibraryExercise$fields$to$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '…with this library exercise…'
	String get title => '…with this library exercise…';

	/// en: 'Library exercise'
	String get label => 'Library exercise';
}

// Path: migrations.removeWeightFromCustomExercise.preview.incompatible
class Translations$migrations$removeWeightFromCustomExercise$preview$incompatible$en {
	Translations$migrations$removeWeightFromCustomExercise$preview$incompatible$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Incompatible exercise'
	String get title => 'Incompatible exercise';

	/// en: 'You can only apply this migration to exercises in which you haven't ever used a weight.'
	String get text => 'You can only apply this migration to exercises in which you haven\'t ever used a weight.';
}

// Path: migrations.removeWeightFromCustomExercise.fields.exercise
class Translations$migrations$removeWeightFromCustomExercise$fields$exercise$en {
	Translations$migrations$removeWeightFromCustomExercise$fields$exercise$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exercise'
	String get label => 'Exercise';

	/// en: 'Remove the Weight parameter from this exercise'
	String get title => 'Remove the Weight parameter from this exercise';
}

// Path: migrations.genericMultiplyWeight.fields.exercise
class Translations$migrations$genericMultiplyWeight$fields$exercise$en {
	Translations$migrations$genericMultiplyWeight$fields$exercise$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Multiply the weight of this exercise...'
	String get title => 'Multiply the weight of this exercise...';

	/// en: 'Exercise'
	String get label => 'Exercise';
}

// Path: migrations.genericMultiplyWeight.preview.incompatible
class Translations$migrations$genericMultiplyWeight$preview$incompatible$en {
	Translations$migrations$genericMultiplyWeight$preview$incompatible$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Incompatible exercise'
	String get title => 'Incompatible exercise';

	/// en: 'Change your selection and try again.'
	String get text => 'Change your selection and try again.';
}

// Path: exerciseFormPicker.fields.exercise.options
class Translations$exerciseFormPicker$fields$exercise$options$en {
	Translations$exerciseFormPicker$fields$exercise$options$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No exercise selected'
	String get none => 'No exercise selected';
}

// Path: food.add.customFood.fields
class Translations$food$add$customFood$fields$en {
	Translations$food$add$customFood$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Brand'
	String get brand => 'Brand';
}

// Path: food.barcodeReader.scanResult.noProductFound
class Translations$food$barcodeReader$scanResult$noProductFound$en {
	Translations$food$barcodeReader$scanResult$noProductFound$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No product found with barcode $barcode.'
	String text({required Object barcode}) => 'No product found with barcode ${barcode}.';

	/// en: 'No product found'
	String get title => 'No product found';

	/// en: 'Create new'
	String get createNew => 'Create new';
}

// Path: food.barcodeReader.scanResult.error
class Translations$food$barcodeReader$scanResult$error$en {
	Translations$food$barcodeReader$scanResult$error$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'An error occurred'
	String get title => 'An error occurred';

	/// en: 'Unable to search for barcode.'
	String get text => 'Unable to search for barcode.';
}

// Path: food.nutritionGoals.change.calories
class Translations$food$nutritionGoals$change$calories$en {
	Translations$food$nutritionGoals$change$calories$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Daily calories'
	String get label => 'Daily calories';

	/// en: 'This value must not be empty.'
	String get empty => 'This value must not be empty.';

	/// en: 'Enter a valid value.'
	String get invalid => 'Enter a valid value.';
}

// Path: food.nutritionGoals.change.fatPercentage
class Translations$food$nutritionGoals$change$fatPercentage$en {
	Translations$food$nutritionGoals$change$fatPercentage$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Fat (%)'
	String get label => 'Fat (%)';

	/// en: 'This value must not be empty.'
	String get empty => 'This value must not be empty.';

	/// en: 'You must enter a valid number 0-100.'
	String get invalid => 'You must enter a valid number 0-100.';
}

// Path: food.nutritionGoals.change.carbsPercentage
class Translations$food$nutritionGoals$change$carbsPercentage$en {
	Translations$food$nutritionGoals$change$carbsPercentage$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Carbs (%)'
	String get label => 'Carbs (%)';

	/// en: 'This value must not be empty.'
	String get empty => 'This value must not be empty.';

	/// en: 'You must enter a valid number 0-100.'
	String get invalid => 'You must enter a valid number 0-100.';
}

// Path: food.nutritionGoals.change.proteinPercentage
class Translations$food$nutritionGoals$change$proteinPercentage$en {
	Translations$food$nutritionGoals$change$proteinPercentage$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Protein (%)'
	String get label => 'Protein (%)';

	/// en: 'This value must not be empty.'
	String get empty => 'This value must not be empty.';

	/// en: 'You must enter a valid number 0-100.'
	String get invalid => 'You must enter a valid number 0-100.';
}

// Path: food.categoryEditor.fields.name
class Translations$food$categoryEditor$fields$name$en {
	Translations$food$categoryEditor$fields$name$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$food$categoryEditor$fields$name$errors$en errors = Translations$food$categoryEditor$fields$name$errors$en._(_root);
}

// Path: achievements.trailblazer.description.k1
class Translations$achievements$trailblazer$description$k1$en {
	Translations$achievements$trailblazer$description$k1$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Run or bike a total of 100 km'
	String get km => 'Run or bike a total of 100 km';

	/// en: 'Run or bike a total of 100 km ($p0)'
	String mi({required Object p0}) => 'Run or bike a total of 100 km (${p0})';
}

// Path: achievements.trailblazer.description.k2
class Translations$achievements$trailblazer$description$k2$en {
	Translations$achievements$trailblazer$description$k2$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Run or bike a total of 500 km'
	String get km => 'Run or bike a total of 500 km';

	/// en: 'Run or bike a total of 500 km ($p0)'
	String mi({required Object p0}) => 'Run or bike a total of 500 km (${p0})';
}

// Path: achievements.trailblazer.description.k3
class Translations$achievements$trailblazer$description$k3$en {
	Translations$achievements$trailblazer$description$k3$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Run or bike a total of 1000 km'
	String get km => 'Run or bike a total of 1000 km';

	/// en: 'Run or bike a total of 1000 km ($p0)'
	String mi({required Object p0}) => 'Run or bike a total of 1000 km (${p0})';
}

// Path: achievements.cycleChampion.description.k1
class Translations$achievements$cycleChampion$description$k1$en {
	Translations$achievements$cycleChampion$description$k1$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cycle a total of 100km'
	String get km => 'Cycle a total of 100km';

	/// en: 'Cycle a total of 100km ($p0)'
	String mi({required Object p0}) => 'Cycle a total of 100km (${p0})';
}

// Path: achievements.cycleChampion.description.k2
class Translations$achievements$cycleChampion$description$k2$en {
	Translations$achievements$cycleChampion$description$k2$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cycle a total of 500km'
	String get km => 'Cycle a total of 500km';

	/// en: 'Cycle a total of 500km ($p0)'
	String mi({required Object p0}) => 'Cycle a total of 500km (${p0})';
}

// Path: achievements.cycleChampion.description.k3
class Translations$achievements$cycleChampion$description$k3$en {
	Translations$achievements$cycleChampion$description$k3$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cycle a total of 1000km'
	String get km => 'Cycle a total of 1000km';

	/// en: 'Cycle a total of 1000km ($p0)'
	String mi({required Object p0}) => 'Cycle a total of 1000km (${p0})';
}

// Path: achievements.sparta.description.k1
class Translations$achievements$sparta$description$k1$en {
	Translations$achievements$sparta$description$k1$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lift 300 lbs ($p0) in one rep'
	String kg({required Object p0}) => 'Lift 300 lbs (${p0}) in one rep';

	/// en: 'Lift 300 lbs in one rep'
	String get lb => 'Lift 300 lbs in one rep';
}

// Path: achievements.sparta.description.k2
class Translations$achievements$sparta$description$k2$en {
	Translations$achievements$sparta$description$k2$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lift 300 kg in one rep'
	String get kg => 'Lift 300 kg in one rep';

	/// en: 'Lift 300 kg ($p0) in one rep'
	String lb({required Object p0}) => 'Lift 300 kg (${p0}) in one rep';
}

// Path: login.errors.password.invalid
class Translations$login$errors$password$invalid$en {
	Translations$login$errors$password$invalid$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your password must:'
	String get header => 'Your password must:';

	/// en: '- Be at least 8 characters long'
	String get length => '- Be at least 8 characters long';

	/// en: '- Contain at least one uppercase character'
	String get uppercase => '- Contain at least one uppercase character';

	/// en: '- Contain at least one lowercase character'
	String get lowercase => '- Contain at least one lowercase character';

	/// en: '- Contain at least one number'
	String get number => '- Contain at least one number';

	/// en: '- Contain at least one special character'
	String get specialCharacter => '- Contain at least one special character';
}

// Path: exercise.editor.fields.title.errors
class Translations$exercise$editor$fields$title$errors$en {
	Translations$exercise$editor$fields$title$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The name must not be empty.'
	String get empty => 'The name must not be empty.';

	/// en: 'An exercise with this name already exists.'
	String get invalid => 'An exercise with this name already exists.';
}

// Path: exercise.editor.fields.parameters.errors
class Translations$exercise$editor$fields$parameters$errors$en {
	Translations$exercise$editor$fields$parameters$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select the parameters of this exercise'
	String get empty => 'Select the parameters of this exercise';
}

// Path: exercise.editor.fields.primaryMuscleGroup.errors
class Translations$exercise$editor$fields$primaryMuscleGroup$errors$en {
	Translations$exercise$editor$fields$primaryMuscleGroup$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You must select a muscle group.'
	String get empty => 'You must select a muscle group.';
}

// Path: exercise.editor.fields.rpe.description
class Translations$exercise$editor$fields$rpe$description$en {
	Translations$exercise$editor$fields$rpe$description$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What is RPE?'
	String get title => 'What is RPE?';

	/// en: 'Rate of Perceived Exertion (RPE) is a subjective measure of how hard an exercise feels to you. It's a scale from 1 to 10, where 1 is very light effort and 10 is maximum effort. You can measure it by estimating how many more reps you could perform before reaching failure. For example, if you could perform 3 more reps before failure, the RPE would be 7.'
	String get text => 'Rate of Perceived Exertion (RPE) is a subjective measure of how hard an exercise feels to you. It\'s a scale from 1 to 10, where 1 is very light effort and 10 is maximum effort. You can measure it by estimating how many more reps you could perform before reaching failure. For example, if you could perform 3 more reps before failure, the RPE would be 7.';
}

// Path: exercise.editor.fields.rpe.levels.0
class Translations$exercise$editor$fields$rpe$levels$0$en {
	Translations$exercise$editor$fields$rpe$levels$0$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 1'
	String get title => 'RPE 1';

	/// en: 'Very light effort.'
	String get text => 'Very light effort.';
}

// Path: exercise.editor.fields.rpe.levels.1
class Translations$exercise$editor$fields$rpe$levels$1$en {
	Translations$exercise$editor$fields$rpe$levels$1$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 2'
	String get title => 'RPE 2';

	/// en: 'Light effort.'
	String get text => 'Light effort.';
}

// Path: exercise.editor.fields.rpe.levels.2
class Translations$exercise$editor$fields$rpe$levels$2$en {
	Translations$exercise$editor$fields$rpe$levels$2$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 3'
	String get title => 'RPE 3';

	/// en: 'Moderately light effort.'
	String get text => 'Moderately light effort.';
}

// Path: exercise.editor.fields.rpe.levels.3
class Translations$exercise$editor$fields$rpe$levels$3$en {
	Translations$exercise$editor$fields$rpe$levels$3$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 4'
	String get title => 'RPE 4';

	/// en: 'Moderate effort.'
	String get text => 'Moderate effort.';
}

// Path: exercise.editor.fields.rpe.levels.4
class Translations$exercise$editor$fields$rpe$levels$4$en {
	Translations$exercise$editor$fields$rpe$levels$4$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 5'
	String get title => 'RPE 5';

	/// en: 'Moderate effort.'
	String get text => 'Moderate effort.';
}

// Path: exercise.editor.fields.rpe.levels.5
class Translations$exercise$editor$fields$rpe$levels$5$en {
	Translations$exercise$editor$fields$rpe$levels$5$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 6'
	String get title => 'RPE 6';

	/// en: 'Moderate to hard effort.'
	String get text => 'Moderate to hard effort.';
}

// Path: exercise.editor.fields.rpe.levels.6
class Translations$exercise$editor$fields$rpe$levels$6$en {
	Translations$exercise$editor$fields$rpe$levels$6$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 7'
	String get title => 'RPE 7';

	/// en: 'Hard effort.'
	String get text => 'Hard effort.';
}

// Path: exercise.editor.fields.rpe.levels.7
class Translations$exercise$editor$fields$rpe$levels$7$en {
	Translations$exercise$editor$fields$rpe$levels$7$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 8'
	String get title => 'RPE 8';

	/// en: 'Hard effort. You can perform at most 2 more reps.'
	String get text => 'Hard effort. You can perform at most 2 more reps.';
}

// Path: exercise.editor.fields.rpe.levels.8
class Translations$exercise$editor$fields$rpe$levels$8$en {
	Translations$exercise$editor$fields$rpe$levels$8$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 9'
	String get title => 'RPE 9';

	/// en: 'Very hard effort. You can perform at most 1 more rep.'
	String get text => 'Very hard effort. You can perform at most 1 more rep.';
}

// Path: exercise.editor.fields.rpe.levels.9
class Translations$exercise$editor$fields$rpe$levels$9$en {
	Translations$exercise$editor$fields$rpe$levels$9$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RPE 10'
	String get title => 'RPE 10';

	/// en: 'Maximum effort. You cannot perform any more reps.'
	String get text => 'Maximum effort. You cannot perform any more reps.';
}

// Path: exercise.editor.fields.gymEquipment.errors
class Translations$exercise$editor$fields$gymEquipment$errors$en {
	Translations$exercise$editor$fields$gymEquipment$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select equipment'
	String get empty => 'Select equipment';
}

// Path: workouts.actions.share.alert.actions
class Translations$workouts$actions$share$alert$actions$en {
	Translations$workouts$actions$share$alert$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Copy'
	String get share => 'Copy';

	/// en: 'Share QR code'
	String get shareQR => 'Share QR code';

	/// en: 'The link has been copied.'
	String get shared => 'The link has been copied.';
}

// Path: routines.editor.fields.name.errors
class Translations$routines$editor$fields$name$errors$en {
	Translations$routines$editor$fields$name$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The name must not be empty.'
	String get empty => 'The name must not be empty.';
}

// Path: settings.options.import.utils.hevy
class Translations$settings$options$import$utils$hevy$en {
	Translations$settings$options$import$utils$hevy$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '(Hevy Import)'
	String get titles => '(Hevy Import)';

	/// en: 'Imported from Hevy'
	String get notes => 'Imported from Hevy';
}

// Path: settings.advanced.options.backups.restore
class Translations$settings$advanced$options$backups$restore$en {
	Translations$settings$advanced$options$backups$restore$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Restore this backup?'
	String get title => 'Restore this backup?';

	/// en: 'You won't be able to undo this action. Be sure to create a backup now if you ever wish to go back. Restore?'
	String get confirm => 'You won\'t be able to undo this action. Be sure to create a backup now if you ever wish to go back. Restore?';
}

// Path: settings.advanced.options.backups.delete
class Translations$settings$advanced$options$backups$delete$en {
	Translations$settings$advanced$options$backups$delete$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete backup?'
	String get title => 'Delete backup?';

	/// en: 'This action cannot be undone.'
	String get confirm => 'This action cannot be undone.';
}

// Path: settings.advanced.options.sync.status
class Translations$settings$advanced$options$sync$status$en {
	Translations$settings$advanced$options$sync$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Syncing...'
	String get syncing => 'Syncing...';

	/// en: 'Not syncing'
	String get notSyncing => 'Not syncing';

	/// en: 'Sync failed'
	String get failed => 'Sync failed';
}

// Path: settings.advanced.deleteAccount.confirmation.error
class Translations$settings$advanced$deleteAccount$confirmation$error$en {
	Translations$settings$advanced$deleteAccount$confirmation$error$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Type your username.'
	String get mismatch => 'Type your username.';
}

// Path: ongoingWorkout.finish.fields.name.errors
class Translations$ongoingWorkout$finish$fields$name$errors$en {
	Translations$ongoingWorkout$finish$fields$name$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The name must not be empty.'
	String get empty => 'The name must not be empty.';
}

// Path: ongoingWorkout.finish.fields.parent.options
class Translations$ongoingWorkout$finish$fields$parent$options$en {
	Translations$ongoingWorkout$finish$fields$parent$options$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No routine'
	String get none => 'No routine';
}

// Path: ongoingWorkout.finish.fields.duration.errors
class Translations$ongoingWorkout$finish$fields$duration$errors$en {
	Translations$ongoingWorkout$finish$fields$duration$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The duration must not be zero.'
	String get empty => 'The duration must not be zero.';
}

// Path: historyEditor.finish.fields.name.errors
class Translations$historyEditor$finish$fields$name$errors$en {
	Translations$historyEditor$finish$fields$name$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The name must not be empty.'
	String get empty => 'The name must not be empty.';
}

// Path: historyEditor.finish.fields.parent.options
class Translations$historyEditor$finish$fields$parent$options$en {
	Translations$historyEditor$finish$fields$parent$options$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No routine'
	String get none => 'No routine';
}

// Path: historyEditor.finish.fields.duration.errors
class Translations$historyEditor$finish$fields$duration$errors$en {
	Translations$historyEditor$finish$fields$duration$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The duration must not be zero.'
	String get empty => 'The duration must not be zero.';
}

// Path: food.categoryEditor.fields.name.errors
class Translations$food$categoryEditor$fields$name$errors$en {
	Translations$food$categoryEditor$fields$name$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The name must not be empty.'
	String get empty => 'The name must not be empty.';

	/// en: 'There is already a category with this name.'
	String get unique => 'There is already a category with this name.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'Gym Bro',
			'navigation.feed' => 'Feed',
			'navigation.profile' => 'Profile',
			'navigation.food' => 'Food',
			'navigation.workouts' => 'Train',
			'navigation.pro' => 'PRO',
			'navigation.settings' => 'Settings',
			'appInfo.version' => ({required Object version, required Object build}) => 'Version ${version} (build ${build})',
			'appInfo.shortDescription' => 'Workout Buddy',
			'appInfo.terms' => 'Terms of service',
			'appInfo.privacy' => 'Privacy policy',
			'set.kind' => 'Set kind',
			'set.kindShort.warmUp' => 'W',
			'set.kindShort.drop' => 'D',
			'set.kindShort.failure' => 'F',
			'set.kindShort.failureStripping' => 'S',
			'set.kindLong.normal' => 'Normal set',
			'set.kindLong.warmUp' => 'Warm-up set',
			'set.kindLong.drop' => 'Drop set',
			'set.kindLong.failure' => 'To failure',
			'set.kindLong.failureStripping' => 'To failure, with stripping',
			'set.kinds.help.title' => 'What\'s this?',
			'set.kinds.help.warmUp' => 'A warm-up set is a light set of an exercise that you perform before the actual working sets. Its purpose is to prepare your muscles for the upcoming heavy work.',
			'set.kinds.help.normal' => 'A normal set is a regular set of an exercise, where you perform a certain amount of reps with a certain weight.',
			'set.kinds.help.drop' => 'A drop set is a set where you drop the weight after reaching failure and continue to perform reps with the lower weight.',
			'set.kinds.help.failure' => 'A failure set is a set where you perform reps until you reach technical failure.',
			'set.kinds.help.failureStripping' => 'A failure set with stripping is a kind of failure set that starts immediately after the previous set (without resting), in which you perform reps until you reach technical failure.',
			'exercise.chart.views.volume' => 'Volume',
			'exercise.chart.views.reps' => 'Reps',
			'exercise.chart.views.duration' => 'Workout Duration',
			'exercise.chart.views.time' => 'Time',
			'exercise.chart.views.distance' => 'Distance',
			'exercise.chart.views.exertion' => 'Exertion rate',
			'exercise.chart.views.exertionInfo' => 'The rate of exertion estimates the intensity of a workout by calculating the average of the lifted weight and the duration of the workout.',
			'exercise.fields.restTime' => 'Rest time',
			'exercise.fields.weight' => 'Weight',
			'exercise.fields.time' => 'Time',
			'exercise.fields.reps' => 'Reps',
			'exercise.fields.distance' => 'Distance',
			'exercise.actions.addSet' => '+ Add Set',
			'exercise.editor.create.title' => 'Create new exercise',
			'exercise.editor.edit.title' => 'Edit exercise',
			'exercise.editor.fields.title.label' => 'Exercise name',
			'exercise.editor.fields.title.errors.empty' => 'The name must not be empty.',
			'exercise.editor.fields.title.errors.invalid' => 'An exercise with this name already exists.',
			'exercise.editor.fields.parameters.label' => 'Parameters',
			'exercise.editor.fields.parameters.values.repsNegWeight' => 'Negative weight & reps',
			'exercise.editor.fields.parameters.values.repsWeight' => 'Weight & reps',
			'exercise.editor.fields.parameters.values.timeWeight' => 'Weight & time',
			'exercise.editor.fields.parameters.values.time' => 'Time',
			'exercise.editor.fields.parameters.values.freeBodyReps' => 'Reps',
			'exercise.editor.fields.parameters.values.distance' => 'Distance',
			'exercise.editor.fields.parameters.errors.empty' => 'Select the parameters of this exercise',
			'exercise.editor.fields.primaryMuscleGroup.label' => 'Primary muscle group',
			'exercise.editor.fields.primaryMuscleGroup.errors.empty' => 'You must select a muscle group.',
			'exercise.editor.fields.secondaryMuscleGroups.label' => 'Other muscle groups',
			'exercise.editor.fields.notes.label' => 'Notes',
			'exercise.editor.fields.notes.tapToEdit' => 'Tap to enter notes',
			'exercise.editor.fields.rpe.removeRPE' => 'Remove RPE',
			'exercise.editor.fields.rpe.label' => 'Set RPE',
			'exercise.editor.fields.rpe.description.title' => 'What is RPE?',
			'exercise.editor.fields.rpe.description.text' => 'Rate of Perceived Exertion (RPE) is a subjective measure of how hard an exercise feels to you. It\'s a scale from 1 to 10, where 1 is very light effort and 10 is maximum effort. You can measure it by estimating how many more reps you could perform before reaching failure. For example, if you could perform 3 more reps before failure, the RPE would be 7.',
			'exercise.editor.fields.rpe.levels.0.title' => 'RPE 1',
			'exercise.editor.fields.rpe.levels.0.text' => 'Very light effort.',
			'exercise.editor.fields.rpe.levels.1.title' => 'RPE 2',
			'exercise.editor.fields.rpe.levels.1.text' => 'Light effort.',
			'exercise.editor.fields.rpe.levels.2.title' => 'RPE 3',
			'exercise.editor.fields.rpe.levels.2.text' => 'Moderately light effort.',
			'exercise.editor.fields.rpe.levels.3.title' => 'RPE 4',
			'exercise.editor.fields.rpe.levels.3.text' => 'Moderate effort.',
			'exercise.editor.fields.rpe.levels.4.title' => 'RPE 5',
			'exercise.editor.fields.rpe.levels.4.text' => 'Moderate effort.',
			'exercise.editor.fields.rpe.levels.5.title' => 'RPE 6',
			'exercise.editor.fields.rpe.levels.5.text' => 'Moderate to hard effort.',
			'exercise.editor.fields.rpe.levels.6.title' => 'RPE 7',
			'exercise.editor.fields.rpe.levels.6.text' => 'Hard effort.',
			'exercise.editor.fields.rpe.levels.7.title' => 'RPE 8',
			'exercise.editor.fields.rpe.levels.7.text' => 'Hard effort. You can perform at most 2 more reps.',
			'exercise.editor.fields.rpe.levels.8.title' => 'RPE 9',
			'exercise.editor.fields.rpe.levels.8.text' => 'Very hard effort. You can perform at most 1 more rep.',
			'exercise.editor.fields.rpe.levels.9.title' => 'RPE 10',
			'exercise.editor.fields.rpe.levels.9.text' => 'Maximum effort. You cannot perform any more reps.',
			'exercise.editor.fields.reorderSets.title' => 'Reorder sets',
			'exercise.editor.fields.reorderSets.text' => 'Drag the handles to reorder the sets',
			'exercise.editor.fields.gymEquipment.errors.empty' => 'Select equipment',
			'exercise.editor.fields.gymEquipment.label' => 'Equipment',
			'exercise.editor.cannotChangeParameters.title' => 'You cannot change the parameters of this exercise',
			'exercise.editor.cannotChangeParameters.text' => 'You can only change the parameters of an exercise you haven\'t performed yet.',
			'exercise.editor.setless.title' => 'You cannot change the parameters of this exercise',
			'exercise.editor.setless.text' => 'Disable the "No sets" option to enable this field.',
			'exercise.editor.overwriteInWorkout.title' => 'This exercise appears in your ongoing workout',
			'exercise.editor.overwriteInWorkout.body' => 'You can modify it, but if you change the parameters you\'ll have to fill them in again. Do you want to continue?',
			'exercise.editor.advanced.setless.title' => 'No sets',
			'exercise.editor.advanced.setless.text' => 'Disable set functionality for this exercise. This option effectively makes this a placeholder exercise in your workouts.',
			'exercise.editor.advanced.title' => 'Advanced',
			'exercise.picker.title' => 'Select exercises',
			'exercise.picker.errors.empty' => 'You must select an exercise.',
			'exercise.picker.filter.equipment' => 'Equipment',
			'exercise.custom' => 'Custom',
			'exercise.info.title' => 'Exercise info',
			'exercise.info.viewWorkout' => 'View workout',
			'exercise.info.noHistory' => 'You haven\'t performed this exercise yet.',
			'exercise.info.heaviestWeight.label' => 'Heaviest weight',
			'exercise.info.best1rm.label' => 'Best 1 Rep Max',
			'exercise.info.bestSetVolume.label' => 'Best set volume',
			'exercise.info.bestSessionVolume.label' => 'Best session volume',
			'exercise.info.usefulData' => 'Useful data',
			'exercise.info.home' => 'Home',
			'exercise.info.history' => 'History',
			'exercise.info.explanation' => 'Explanation',
			'exercise.info.explanationDisclaimer' => 'Note: this explanation is provided for reference only. Always consult a fitness professional.',
			'exercise.info.primaryMuscleGroup' => ({required Object muscleGroup}) => 'Muscle group: ${muscleGroup}',
			'exercise.info.secondaryMuscleGroups' => ({required Object muscleGroups}) => 'Secondary muscle groups: ${muscleGroups}',
			'exercise.info.equipment' => ({required Object equipment}) => 'Equipment: ${equipment}',
			'exercise.info.explanationNone.title' => 'No explanation available',
			'exercise.info.explanationNone.description' => 'This exercise does not have an explanation available yet. Please check back later.',
			'exercise.continuation.label' => 'Continuation',
			'exercise.continuation.description' => 'Tap to combine the two workouts into a single entry.',
			'exercise.continuation.combine.confirm.title' => 'Combine workouts',
			'exercise.continuation.combine.confirm.body' => 'Are you sure you want to combine these workouts? This action cannot be undone, and the old workouts will be deleted.',
			'exercise.delete.title' => 'Delete exercise',
			'exercise.delete.body' => 'Are you sure you want to delete this exercise? This action cannot be undone.',
			'workouts.untitled' => 'Untitled workout',
			'workouts.title' => 'Workouts',
			'workouts.actions.delete.title' => 'Delete workout',
			'workouts.actions.delete.text' => 'Are you sure you want to delete this workout? This action cannot be undone.',
			'workouts.actions.delete.actions.no' => 'Cancel',
			'workouts.actions.delete.actions.yes' => 'Delete',
			'workouts.actions.delete.done' => 'The workout has been deleted.',
			'workouts.actions.start' => 'Redo this workout',
			'workouts.actions.edit.label' => 'Edit workout',
			'workouts.actions.editContinuation.label' => 'Edit workout continuation',
			'workouts.actions.rename.label' => 'Rename workout',
			'workouts.actions.rename.errors.empty' => 'The name must not be empty.',
			'workouts.actions.changeParent.label' => 'Change base routine',
			'workouts.actions.changeParent.options.none' => 'No routine',
			'workouts.actions.saveAsRoutine.button' => 'Save as routine',
			'workouts.actions.saveAsRoutine.done' => 'Successfully saved as routine',
			'workouts.actions.kContinue' => 'Continue this workout',
			'workouts.actions.share.button' => 'Share this routine',
			'workouts.actions.share.alert.title' => 'Link generated',
			'workouts.actions.share.alert.body' => 'A unique link has been generated. Click the button below to copy it, and send it to share the routine.',
			'workouts.actions.share.alert.actions.close' => 'Close',
			'workouts.actions.share.alert.actions.share' => 'Copy',
			'workouts.actions.share.alert.actions.shareQR' => 'Share QR code',
			'workouts.actions.share.alert.actions.shared' => 'The link has been copied.',
			'workouts.actions.share.alert.noQr' => 'Unable to generate QR code: routine is too large. Use link below to share your routine.',
			'routines.title' => 'Routines',
			'routines.newRoutine' => 'New routine',
			'routines.quickWorkout.title' => 'Free workout',
			'routines.quickWorkout.subtitle' => 'Start without a routine',
			'routines.quickWorkout.proLimit' => 'You have reached the free workout limit. Continue with PRO.',
			'routines.actions.delete.title' => 'Delete routine',
			'routines.actions.delete.text' => 'Are you sure you want to delete this routine? This action cannot be undone.',
			'routines.actions.delete.actions.no' => 'Cancel',
			'routines.actions.delete.actions.yes' => 'Delete',
			'routines.actions.delete.done' => 'The routine has been deleted.',
			'routines.actions.edit' => 'Edit routine',
			'routines.actions.start' => 'Start routine',
			'routines.actions.create' => 'Create new routine',
			'routines.actions.viewHistory' => 'View history',
			'routines.actions.deleteFolder.title' => 'Delete folder',
			'routines.actions.deleteFolder.text' => 'Are you sure you wish to delete this folder? This action cannot be undone. The routines in this folder will be moved to the home screen.',
			'routines.editor.exercises.title' => 'Exercises',
			'routines.editor.exercises.add' => 'Add exercises',
			'routines.editor.fields.name.label' => 'Routine name',
			'routines.editor.fields.name.errors.empty' => 'The name must not be empty.',
			'routines.editor.fields.infobox.label' => 'Notes',
			'routines.editor.superset.title' => 'Superset',
			'routines.editor.superset.add' => 'Add superset',
			'routines.editor.superset.subtitle' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'Superset without exercises', one: 'Superset with ${n} exercise', two: 'Superset with ${n} exercises', few: 'Superset with ${n} exercises', many: 'Superset with ${n} exercises', other: 'Superset with ${n} exercises', ), 
			'routines.editor.superset.addExercise' => 'Add exercises',
			'routines.editor.superset.remove.title' => 'Remove superset',
			'routines.editor.superset.remove.body' => 'Are you sure you want to remove this superset? This action cannot be undone.',
			'routines.newFolder' => 'New folder',
			'routines.folderNameEmpty' => 'The name must not be empty.',
			'routines.folderName' => 'Name',
			'routines.editFolder' => 'Edit folder',
			'routines.dropHere' => 'Drop here',
			'routines.moveToRoot' => 'Drop the routine here to move it to the home screen',
			'routines.none' => 'No routine',
			'routines.pick' => 'Select a routine',
			'routines.rootFolder' => 'Home',
			'routines.emptyFolder' => 'This folder is empty',
			'routines.emptyFolderSubtitle' => 'Press and hold a routine from the Home page to add it to this folder.',
			'routines.folder' => 'Folder',
			'routines.nullFolder' => 'You\'ve deleted this folder',
			'routines.nullFolderSubtitle' => 'You can go back to the Home page.',
			'routines.folderNotes' => 'Notes',
			'routines.loadError.title' => 'Unable to load routines',
			'routines.loadError.text' => 'Try again to load your routines and folders.',
			'history.title' => 'History',
			'history.empty' => 'No history',
			'history.andMore' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '…and one more exercise', two: '…and ${n} more exercises', few: '…and ${n} more exercises', many: '…and ${n} more exercises', other: '…and ${n} more exercises', ), 
			'history.actions.deleteMultiple.title' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Delete exercise', two: 'Delete ${n} exercises', few: 'Delete ${n} exercises', many: 'Delete ${n} exercises', other: 'Delete ${n} exercises', ), 
			'history.actions.deleteMultiple.text' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Are you sure you want to delete this exercise from your history? This action cannot be undone.', two: 'Are you sure you want to delete these ${n} exercises from your history? This action cannot be undone.', few: 'Are you sure you want to delete these ${n} exercises from your history? This action cannot be undone.', many: 'Are you sure you want to delete these ${n} exercises from your history? This action cannot be undone.', other: 'Are you sure you want to delete these ${n} exercises from your history? This action cannot be undone.', ), 
			'history.actions.deleteMultiple.actions.no' => 'Cancel',
			'history.actions.deleteMultiple.actions.yes' => 'Delete',
			'history.actions.deleteMultiple.done' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'The exercise has been deleted from your history.', two: 'The exercises have been deleted from your history.', few: 'The exercises have been deleted from your history.', many: 'The exercises have been deleted from your history.', other: 'The exercises have been deleted from your history.', ), 
			'history.showAll' => 'Show all data',
			'history.search' => 'Search workouts',
			'settings.diagnostics.title' => 'Send diagnostic data',
			'settings.diagnostics.description' => 'Share errors, performance data, logs and sampled session recordings to help us improve the app. You can turn this off at any time.',
			'settings.diagnostics.saveError' => 'Unable to update your preference. Please try again.',
			'settings.title' => 'Settings',
			'settings.options.useDynamicColor.label' => 'Use dynamic color',
			'settings.options.color.label' => 'App color',
			'settings.options.locale.label' => 'App language',
			'settings.options.locale.values.system' => 'System',
			'settings.options.weightUnit.label' => 'Weight unit',
			'settings.options.distanceUnit.label' => 'Distance unit',
			'settings.options.showSuggestedRoutines.label' => 'Show suggested routines',
			'settings.options.import.success' => 'Successfully imported data',
			'settings.options.import.failed.title' => 'Failed to import data',
			'settings.options.import.failed.copy' => 'The error message has been copied to the clipboard.',
			'settings.options.import.label' => 'Import data',
			'settings.options.import.utils.hevy.titles' => '(Hevy Import)',
			'settings.options.import.utils.hevy.notes' => 'Imported from Hevy',
			'settings.options.import.types.gt' => 'Gym Bro (JSON)',
			'settings.options.import.types.hevy' => 'Hevy (CSV)',
			'settings.options.export.label' => 'Export data (JSON)',
			'settings.options.export.filename' => 'GymBro_Data',
			'settings.options.export.failed.title' => 'Failed to export data',
			'settings.options.export.failed.copy' => 'The error message has been copied to the clipboard.',
			'settings.options.themeMode.label' => 'Theme',
			'settings.options.themeMode.values.system' => 'System',
			'settings.options.themeMode.values.light' => 'Light',
			'settings.options.themeMode.values.dark' => 'Dark',
			'settings.options.notifications.label' => 'Notification status',
			'settings.options.notifications.subtitle.noExactAlarmPermission' => 'Tap to request "Exact alarms" permission (Android 14+)',
			'settings.options.tintExercises.label' => 'Tint exercise pages',
			'settings.options.tintExercises.subtitle' => 'Apply the category color to exercise and category pages',
			'settings.options.defaultToSimpleWorkoutView.label' => 'Use simplified workout view by default',
			'settings.options.defaultToSimpleWorkoutView.subtitle' => 'Open the compact workout screen when starting or resuming a workout',
			'settings.options.exportSQL.text' => 'Export the full Gym Bro database. It cannot be imported back later (but your data won\'t be deleted).',
			'settings.options.exportSQL.label' => 'Export full database (SQL)',
			'settings.options.nutritionLanguage' => 'Food search language',
			'settings.options.nutritionCountry' => 'Food search country',
			'settings.options.health.label' => 'Health and Vitals',
			'settings.colorPicker.heading.label' => ({required Object color}) => 'Select a color [${color}]',
			'settings.advanced.title' => 'Danger zone',
			'settings.advanced.subtitle' => 'Here be dragons',
			'settings.advanced.options.logs.title' => 'Logs',
			'settings.advanced.options.logs.levels.trace' => 'Trace',
			'settings.advanced.options.logs.levels.debug' => 'Debug',
			'settings.advanced.options.logs.levels.info' => 'Info',
			'settings.advanced.options.logs.levels.warning' => 'Warning',
			'settings.advanced.options.logs.levels.error' => 'Error',
			'settings.advanced.options.logs.levels.fatal' => 'Fatal',
			'settings.advanced.options.logs.level' => 'Level',
			'settings.advanced.options.migrations.title' => 'Migrations',
			'settings.advanced.options.backups.title' => 'Backups',
			'settings.advanced.options.backups.restore.title' => 'Restore this backup?',
			'settings.advanced.options.backups.restore.confirm' => 'You won\'t be able to undo this action. Be sure to create a backup now if you ever wish to go back. Restore?',
			'settings.advanced.options.backups.restoring' => 'Restoring',
			'settings.advanced.options.backups.create' => 'Create backup',
			'settings.advanced.options.backups.creating' => 'Backing up',
			'settings.advanced.options.backups.delete.title' => 'Delete backup?',
			'settings.advanced.options.backups.delete.confirm' => 'This action cannot be undone.',
			'settings.advanced.options.backups.deleting' => 'Deleting',
			'settings.advanced.options.sync.title' => 'Sync status',
			'settings.advanced.options.sync.status.syncing' => 'Syncing...',
			'settings.advanced.options.sync.status.notSyncing' => 'Not syncing',
			'settings.advanced.options.sync.status.failed' => 'Sync failed',
			'settings.advanced.options.sync.lastSync' => ({required Object date}) => 'Last sync: ${date}',
			'settings.advanced.options.sync.never' => 'Never synced',
			'settings.advanced.options.sync.notLoggedIn' => 'Not logged in',
			'settings.advanced.options.sync.syncNow' => 'Sync now',
			'settings.advanced.options.sync.rateLimited' => 'Please wait a minute before syncing again',
			'settings.advanced.deleteAccount.title' => 'Delete your account',
			'settings.advanced.deleteAccount.warning.title' => 'Permanently delete your account?',
			'settings.advanced.deleteAccount.warning.content' => 'You will instantly lose all your data. You won\'t be able to undo this. Are you sure you want to continue?',
			'settings.advanced.deleteAccount.confirmation.title' => 'Confirm deletion',
			'settings.advanced.deleteAccount.confirmation.content' => ({required Object username}) => 'Type your username (${username}) to proceed.',
			'settings.advanced.deleteAccount.confirmation.hint' => 'Username',
			'settings.advanced.deleteAccount.confirmation.error.mismatch' => 'Type your username.',
			'settings.advanced.deleteAccount.deleting' => 'Deleting...',
			'settings.panes.appearance' => 'Appearance',
			'settings.panes.units' => 'Units',
			'settings.panes.permissions' => 'Permissions',
			'settings.panes.off' => 'OpenFoodFacts',
			'settings.permissions.tapToRequest' => 'Tap to request permission',
			'settings.pro.title' => 'Manage your subscription',
			'settings.logout' => 'Sign out',
			'settings.logoutWarning.title' => 'Sign out?',
			'settings.logoutWarning.content' => 'You can always sign back in from the Profile tab.',
			'ongoingWorkout.title' => 'Workout',
			'ongoingWorkout.actions.finish' => 'Finish workout',
			'ongoingWorkout.actions.cancel' => 'Cancel workout',
			'ongoingWorkout.actions.short.cancel' => 'Cancel',
			'ongoingWorkout.actions.short.resume' => 'Resume',
			'ongoingWorkout.actions.changeWeightUnit' => 'Change weight unit',
			'ongoingWorkout.actions.changeDistanceUnit' => 'Change distance unit',
			'ongoingWorkout.exercises.add' => '+ Add exercise',
			'ongoingWorkout.exercises.addSuperset' => '+ Add superset',
			'ongoingWorkout.exercises.replace' => 'Replace exercise…',
			'ongoingWorkout.exercises.reorder' => 'Reorder exercises…',
			'ongoingWorkout.exercises.reorderSets' => 'Reorder sets…',
			'ongoingWorkout.exercises.remove' => 'Remove exercise',
			'ongoingWorkout.exercises.addToSuperset' => 'Add to superset…',
			'ongoingWorkout.exercises.startCardioTimer' => 'Start interval timer',
			'ongoingWorkout.exercises.rpeBadge' => ({required Object rpe}) => 'RPE ${rpe}',
			'ongoingWorkout.exercises.setRPE' => 'Set RPE',
			'ongoingWorkout.exercises.generate' => 'Generate',
			'ongoingWorkout.info.recordingPending' => 'Recording awaiting confirmation',
			'ongoingWorkout.info.recordingUnavailable' => 'Recording unavailable',
			'ongoingWorkout.info.time' => 'Time',
			'ongoingWorkout.info.reps' => 'Reps',
			'ongoingWorkout.info.volume' => 'Lifted weight',
			'ongoingWorkout.info.heartRate' => 'BPM',
			'ongoingWorkout.info.activeEnergy' => 'KCAL',
			'ongoingWorkout.finish.title' => 'Finish workout',
			'ongoingWorkout.finish.fields.name.label' => 'Workout name',
			'ongoingWorkout.finish.fields.name.errors.empty' => 'The name must not be empty.',
			'ongoingWorkout.finish.fields.startingTime.label' => 'Starting time',
			'ongoingWorkout.finish.fields.parent.label' => 'Reference routine',
			'ongoingWorkout.finish.fields.parent.options.none' => 'No routine',
			'ongoingWorkout.finish.fields.parent.help' => 'Link this workout to a routine. You will be asked about any routine updates after saving.',
			'ongoingWorkout.finish.fields.duration.label' => 'Duration',
			'ongoingWorkout.finish.fields.duration.errors.empty' => 'The duration must not be zero.',
			'ongoingWorkout.finish.fields.infobox.label' => 'Notes',
			'ongoingWorkout.finish.save' => 'Save workout',
			'ongoingWorkout.finish.saving' => 'Saving…',
			'ongoingWorkout.finish.saveError' => 'Unable to save the workout. Try again: your changes are still here.',
			'ongoingWorkout.finish.discard.title' => 'Discard changes?',
			'ongoingWorkout.finish.discard.text' => 'Your changes to the summary will be discarded. The workout will remain in progress.',
			'ongoingWorkout.finish.discard.keep' => 'Keep editing',
			'ongoingWorkout.finish.discard.confirm' => 'Discard changes',
			'ongoingWorkout.cancel.title' => 'Cancel workout?',
			'ongoingWorkout.cancel.text' => 'You won\'t be able to undo this later if you change your mind.',
			'ongoingWorkout.cancel.actions.no' => 'Don\'t cancel',
			'ongoingWorkout.cancel.actions.yes' => 'Cancel workout',
			'ongoingWorkout.overwrite.title' => 'Start workout?',
			'ongoingWorkout.overwrite.text' => 'Your current workout will be overwritten.',
			'ongoingWorkout.overwrite.actions.no' => 'Cancel',
			'ongoingWorkout.overwrite.actions.yes' => 'Start',
			'ongoingWorkout.restOver' => 'Rest time is over!',
			'ongoingWorkout.weightCalculator' => 'Weight calculator',
			'ongoingWorkout.superset.replaceWithExercise' => 'Replace with exercise',
			'ongoingWorkout.superset.remove' => 'Remove superset',
			'ongoingWorkout.stopwatch.label' => 'Stopwatch',
			'ongoingWorkout.stopwatch.start' => 'Start',
			'ongoingWorkout.stopwatch.pause' => 'Pause',
			'ongoingWorkout.stopwatch.reset' => 'Reset',
			'ongoingWorkout.simple.completedTitle' => 'Workout complete',
			'ongoingWorkout.simple.completedDescription' => 'All sets are complete. Save your workout or add another exercise.',
			'ongoingWorkout.simple.emptyTitle' => 'Ready to train?',
			'ongoingWorkout.simple.emptyDescription' => 'Add an exercise to start your session.',
			'ongoingWorkout.simple.exercisePosition' => ({required Object current, required Object total}) => '${current} of ${total}',
			'ongoingWorkout.simple.setPosition' => ({required Object current, required Object total}) => 'Set ${current} of ${total}',
			'ongoingWorkout.simple.customExercise' => 'Custom',
			'ongoingWorkout.simple.completeSet' => 'Complete set',
			'ongoingWorkout.simple.repUnit' => 'reps',
			'ongoingWorkout.simple.decreaseValue' => ({required Object field}) => 'Decrease ${field}',
			'ongoingWorkout.simple.increaseValue' => ({required Object field}) => 'Increase ${field}',
			'ongoingWorkout.simple.historyAndProgression' => 'History and progression',
			'ongoingWorkout.simple.historySummary' => 'View your last session and targets',
			'ongoingWorkout.simple.progressionSummary' => 'Active progression · view targets',
			'ongoingWorkout.simple.nextUp' => 'Next up:',
			'ongoingWorkout.simple.switchToFull' => 'Switch to full view',
			'ongoingWorkout.simple.restTimer' => 'Start rest timer',
			'ongoingWorkout.simple.setControls' => 'Set controls',
			'ongoingWorkout.simple.previousSet' => 'Previous set',
			'ongoingWorkout.simple.nextSet' => 'Next set',
			'ongoingWorkout.simple.setKind' => 'Set type',
			'ongoingWorkout.simple.editSet' => 'Edit set parameters',
			'ongoingWorkout.simple.supersetNotes' => 'Superset notes',
			'ongoingWorkout.simple.markAsDone' => 'Mark set as done',
			'ongoingWorkout.simple.markAsUndone' => 'Mark set as not done',
			'ongoingWorkout.toolbox.title' => 'Tools',
			'ongoingWorkout.updateRoutine.differenceTitle' => 'Change routine?',
			'ongoingWorkout.updateRoutine.differenceText' => 'You\'ve made changes to the workout. Do you want to save them to the routine?',
			'ongoingWorkout.updateRoutine.differences.added' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No exercises added', one: '1 exercise added', two: '${n} exercises added', few: '${n} exercises added', many: '${n} exercises added', other: '${n} exercises added', ), 
			'ongoingWorkout.updateRoutine.differences.removed' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No exercises removed', one: '1 exercise removed', two: '${n} exercises removed', few: '${n} exercises removed', many: '${n} exercises removed', other: '${n} exercises removed', ), 
			'ongoingWorkout.updateRoutine.differences.changed' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No exercises changed', one: '1 exercise changed', two: '${n} exercises changed', few: '${n} exercises changed', many: '${n} exercises changed', other: '${n} exercises changed', ), 
			'ongoingWorkout.updateRoutine.differences.reordered' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No exercises reordered', one: '1 exercise reordered', two: '${n} exercises reordered', few: '${n} exercises reordered', many: '${n} exercises reordered', other: '${n} exercises reordered', ), 
			'ongoingWorkout.updateRoutine.differences.metadata' => 'Routine name or notes changed',
			'ongoingWorkout.goodJob.title' => 'Good job!',
			'ongoingWorkout.goodJob.body' => 'Here\'s some statistics about the workout you\'ve just finished.',
			'ongoingWorkout.exercisesToSuperset.title' => 'Create new superset',
			'ongoingWorkout.exercisesToSuperset.errorBannerTitle' => 'Can\'t create superset',
			'ongoingWorkout.exercisesToSuperset.errors.addingNonContiguous' => 'You can only add exercises that are next to each other.',
			'ongoingWorkout.exercisesToSuperset.errors.removingMiddle' => 'You can only unselect the first or last exercise.',
			'ongoingWorkout.exercisesToSuperset.errors.notExercise' => 'You must select an exercise.',
			'ongoingWorkout.exercisesToSuperset.errors.tooFew' => 'You must select at least two exercises.',
			'ongoingWorkout.exercisesToSuperset.errors.differingSets' => 'The selected exercises must have the same number of sets.',
			'timer.add15s' => '+15s',
			'timer.subtract15s' => '-15s',
			'timer.skip' => 'Skip',
			'exerciseList.restTime' => 'Rest time: ',
			'exerciseList.fields.weight' => ({required Object weight, required Object unit}) => '${weight} ${unit}',
			'exerciseList.fields.time' => ({required Object time}) => '${time}',
			'exerciseList.fields.reps' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: '0 reps', one: '${n} rep', two: '${n} reps', few: '${n} reps', many: '${n} reps', other: '${n} reps', ), 
			'exerciseList.fields.distance' => ({required Object distance, required Object unit}) => '${distance} ${unit}',
			'exerciseList.fields.rpe' => ({required Object rpe}) => 'RPE ${rpe}',
			'exerciseList.stats.time' => 'Duration',
			'exerciseList.stats.volume' => 'Volume',
			'exerciseList.stats.distance' => 'Distance',
			'exerciseList.stats.sets' => 'Sets',
			'exerciseList.workoutMuscleCategoriesBarChart.label' => 'Muscle distribution (by number of sets)',
			'exerciseList.workoutWeightDistributionBarChart.label' => 'Muscle distribution (by lifted weight)',
			'exerciseList.workoutEquipmentDistributionBarChart.label' => 'Equipment Distribution (by sets)',
			'general.dialogs.actions.ok' => 'OK',
			'general.dialogs.actions.cancel' => 'Cancel',
			'general.dialogs.actions.close' => 'Close',
			'general.exercises' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No exercises', one: '${n} exercise', two: '${n} exercises', few: '${n} exercises', many: '${n} exercises', other: '${n} exercises', ), 
			'general.totalTime' => ({required Object time}) => 'Total time: ${time}',
			'general.selected' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'Nothing selected', one: '1 selected', two: '${n} selected', few: '${n} selected', many: '${n} selected', other: '${n} selected', ), 
			'general.workouts' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No workouts', one: '${n} workout', two: '${n} workouts', few: '${n} workouts', many: '${n} workouts', other: '${n} workouts', ), 
			'general.routines' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No routines', one: '${n} routine', two: '${n} routines', few: '${n} routines', many: '${n} routines', other: '${n} routines', ), 
			'general.optional' => '(optional)',
			'general.unnamed' => 'Unnamed',
			'muscleGroups.abductors' => 'Abductors',
			'muscleGroups.abs' => 'Abs',
			'muscleGroups.adductors' => 'Adductors',
			'muscleGroups.biceps' => 'Biceps',
			'muscleGroups.calves' => 'Calves',
			'muscleGroups.chest' => 'Chest',
			'muscleGroups.forearm' => 'Forearm',
			'muscleGroups.glutes' => 'Glutes',
			'muscleGroups.hamstrings' => 'Hamstrings',
			'muscleGroups.lats' => 'Lats',
			'muscleGroups.lowerBack' => 'Lower back',
			'muscleGroups.none' => 'None',
			'muscleGroups.other' => 'Other',
			'muscleGroups.quadriceps' => 'Quadriceps',
			'muscleGroups.shoulders' => 'Shoulders',
			'muscleGroups.traps' => 'Traps',
			'muscleGroups.triceps' => 'Triceps',
			'muscleGroups.upperBack' => 'Upper back',
			'muscleGroups.thighs' => 'Thighs',
			'muscleGroups.forearms' => 'Forearms',
			'muscleGroups.hands' => 'Hands',
			'muscleGroups.obliques' => 'Obliques',
			'muscleGroups.tibialis' => 'Tibialis',
			'muscleCategories.arms' => 'Arms',
			'muscleCategories.back' => 'Back',
			'muscleCategories.chest' => 'Chest',
			'muscleCategories.core' => 'Core',
			'muscleCategories.legs' => 'Legs',
			'muscleCategories.shoulders' => 'Shoulders',
			'titleGenerator.template' => ({required Object muscles}) => '${muscles} Workout',
			'titleGenerator.title.zero' => '',
			'titleGenerator.title.one' => ({required Object p0}) => '${p0}',
			'titleGenerator.title.two' => ({required Object p0, required Object p1}) => '${p0} and ${p1}',
			'titleGenerator.title.three' => ({required Object p0, required Object p1, required Object p2}) => '${p0}, ${p1}, and ${p2}',
			'titleGenerator.title.four' => ({required Object p0, required Object p1, required Object p2, required Object p3}) => '${p0}, ${p1}, ${p2}, and ${p3}',
			'titleGenerator.title.five' => ({required Object p0, required Object p1, required Object p2, required Object p3, required Object p4}) => '${p0}, ${p1}, ${p2}, ${p3}, and ${p4}',
			'titleGenerator.title.six' => ({required Object p0, required Object p1, required Object p2, required Object p3, required Object p4, required Object p5}) => '${p0}, ${p1}, ${p2}, ${p3}, ${p4}, and ${p5}',
			'actions.create' => 'Create',
			'actions.remove' => 'Remove',
			'actions.edit' => 'Edit',
			'actions.undo' => 'Undo',
			'actions.save' => 'Save',
			'units.kg' => 'kg',
			'units.lb' => 'lbs',
			'units.km' => 'km',
			'units.mi' => 'mi',
			'time.hours' => ({required num n, required Object minutes, required Object seconds, required Object hours}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: '${minutes}:${seconds}', one: '${hours} hour, ${minutes}:${seconds}', two: '${hours} hours, ${minutes}:${seconds}', few: '${hours} hours, ${minutes}:${seconds}', many: '${hours} hours, ${minutes}:${seconds}', other: '${hours} hours, ${minutes}:${seconds}', ), 
			'time.justHours' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: '${n}', one: '${n} hour', two: '${n} hours', few: '${n} hours', many: '${n} hours', other: '${n} hours', ), 
			'time.days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: '0 days', one: '1 day', two: '2 days', few: '${n} days', many: '${n} days', other: '${n} days', ), 
			'time.weeks' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: '0 weeks', one: '1 week', two: '2 weeks', few: '${n} weeks', many: '${n} weeks', other: '${n} weeks', ), 
			'locales.en' => 'English',
			'locales.it' => 'Italian',
			'weightUnits.kg' => 'Kilograms',
			'weightUnits.lb' => 'Pounds',
			'distanceUnits.km' => 'Kilometers',
			'distanceUnits.mi' => 'Miles',
			'barbells.normal' => 'Normal',
			'barbells.short' => 'Short',
			'barbells.ezBar' => 'EZ bar',
			'barbells.none' => 'No bar',
			'weightCalculator.weight.label' => 'Total weight',
			'weightCalculator.weights.label' => 'Available weight plates',
			'weightCalculator.barbells.label' => 'Barbell',
			'weightCalculator.insert' => 'Insert weight',
			'androidNotificationChannel.name' => 'Rest timeout',
			'androidNotificationChannel.description' => 'Sends a notification whenever a running rest timer runs out of time.',
			'library.title' => 'Library',
			'library.cardio.name' => 'Cardio',
			'library.cardio.exercises.burpees' => 'Burpees',
			'library.cardio.exercises.squatThrusts' => 'Squat thrusts (without jump)',
			'library.cardio.exercises.jumpingJacks' => 'Jumping jacks',
			'library.cardio.exercises.highKnees' => 'High knees (running in place)',
			'library.cardio.exercises.buttKicks' => 'Butt kicks (running in place)',
			'library.cardio.exercises.skaterJumps' => 'Skater jumps',
			'library.cardio.exercises.squatJumps' => 'Jump squats',
			'library.cardio.exercises.plankJacks' => 'Plank jacks',
			'library.cardio.exercises.aerobics' => 'Aerobics',
			'library.cardio.exercises.biking' => 'Biking',
			'library.cardio.exercises.ergometer' => 'Upright exercise bike',
			'library.cardio.exercises.ergometerHorizontal' => 'Recumbent exercise bike',
			'library.cardio.exercises.pilates' => 'Pilates',
			'library.cardio.exercises.running' => 'Running',
			'library.cardio.exercises.treadmill' => 'Treadmill',
			'library.cardio.exercises.zumba' => 'Zumba',
			'library.cardio.exercises.jumpRope' => 'Jump rope',
			'library.cardio.exercises.rowingMachine' => 'Rowing machine',
			'library.cardio.exercises.bicycleCrunchesCardio' => 'Bicycle crunches (timed)',
			'library.cardio.exercises.crunchesTimed' => 'Crunches (timed)',
			'library.cardio.exercises.straddleJumps' => 'Straddle jumps',
			'library.cardio.exercises.forwardAndBackwardSteps' => 'Forward and backward steps',
			'library.cardio.exercises.bearCrawl' => 'Bear crawl',
			'library.cardio.exercises.ellipticalCycling' => 'Elliptical cycling',
			'library.cardio.exercises.burpeeDumbbell' => 'Burpee (dumbbell)',
			'library.cardio.exercises.partialKneeBends' => 'Partial knee bends',
			'library.cardio.exercises.armCycleErgometer' => 'Arm-cycle ergometer',
			'library.cardio.exercises.wallSupportedHighKnees' => 'Wall-supported high knees',
			'library.cardio.exercises.burpeeWithJumpingJack' => 'Burpee with jumping jack',
			'library.cardio.exercises.jumpingJackHops' => 'Jumping-jack hops',
			'library.cardio.exercises.pushUpIntoRunningStart' => 'Push-up into running start',
			'library.cardio.exercises.scissorJumps' => 'Scissor jumps',
			_ => null,
		} ?? switch (path) {
			'library.cardio.exercises.squatSemiJump' => 'Squat (semi, jump)',
			'library.cardio.exercises.shortStrideRunning' => 'Short-stride running',
			'library.cardio.exercises.skiergDoublePolePull' => 'SkiErg double-pole pull',
			'library.cardio.exercises.alternatingSkiSteps' => 'Alternating ski steps',
			'library.cardio.exercises.explosiveStarJumps' => 'Explosive star jumps',
			'library.cardio.exercises.kettlebellCircularSwing' => 'Kettlebell circular swing',
			'library.cardio.exercises.ellipticalTrainerWalking' => 'Elliptical trainer walking',
			'library.cardio.exercises.lungeWalkingHighKnee' => 'Lunge (walking, high knee)',
			'library.cardio.exercises.inclineTreadmillWalking' => 'Incline treadmill walking',
			'library.cardio.exercises.stairClimberStepping' => 'Stair-climber stepping',
			'library.cardio.exercises.repeatedSprintIntervals' => 'Repeated sprint intervals',
			'library.chest.name' => 'Chest',
			'library.chest.exercises.inclineMachineChestPress' => 'Incline machine chest press',
			'library.chest.exercises.midHeightCableFly' => 'Chest-height cable fly',
			'library.chest.exercises.barbellBenchPressFlat' => 'Bench press (barbell)',
			'library.chest.exercises.barbellBenchPressIncline' => 'Bench press (barbell, incline)',
			'library.chest.exercises.barbellBenchPressDecline' => 'Bench press (barbell, decline)',
			'library.chest.exercises.dumbbellBenchPressFlat' => 'Bench press (dumbbell)',
			'library.chest.exercises.dumbbellBenchPressIncline' => 'Bench press (dumbbell, incline)',
			'library.chest.exercises.dumbbellBenchPressDecline' => 'Bench press (dumbbell, decline)',
			'library.chest.exercises.smithMachineBenchPressFlat' => 'Bench press (Smith machine)',
			'library.chest.exercises.smithMachineBenchPressIncline' => 'Bench press (Smith machine, incline)',
			'library.chest.exercises.smithMachineBenchPressDecline' => 'Bench press (Smith machine, decline)',
			'library.chest.exercises.cableBenchPressFlat' => 'Bench press (cables)',
			'library.chest.exercises.cableBenchPressIncline' => 'Bench press (cables, incline)',
			'library.chest.exercises.cableBenchPressDecline' => 'Bench press (cables, decline)',
			'library.chest.exercises.butterflyMachine' => 'Pec deck fly',
			'library.chest.exercises.dumbbellHexPress' => 'Dumbbell hex press',
			'library.chest.exercises.smithMachineHexPress' => 'Smith machine hex press',
			'library.chest.exercises.seatedCableChestFlys' => 'Seated cable chest flyes',
			'library.chest.exercises.verticalChestPress' => 'Vertical chest press',
			'library.chest.exercises.cableFlyCrossovers' => 'High cable fly',
			'library.chest.exercises.pushUps' => 'Push-ups',
			'library.chest.exercises.pushUpsWeighted' => 'Push-ups (weighted)',
			'library.chest.exercises.cableChestPress' => 'Cable chest press',
			'library.chest.exercises.declinePushUps' => 'Decline push-ups',
			'library.chest.exercises.lowCableFly' => 'Low cable fly',
			'library.chest.exercises.inclinePushUps' => 'Incline push-ups',
			'library.chest.exercises.tBarPress' => 'Landmine press',
			'library.chest.exercises.inclineBenchFlys' => 'Incline bench flyes',
			'library.chest.exercises.benchFlys' => 'Bench flyes',
			'library.chest.exercises.pushUpArcher' => 'Push-up (archer)',
			'library.chest.exercises.chestDipAssistedKneeling' => 'Chest dip (assisted, kneeling)',
			'library.chest.exercises.pectoralisMajorStretchAssistedSeatedStabilityBall' => 'Pectoralis major stretch (assisted, seated, stability ball)',
			'library.chest.exercises.chestDipAssistedWideGripKneeling' => 'Chest dip (assisted, wide grip, kneeling)',
			'library.chest.exercises.benchPressBand' => 'Bench press (band)',
			'library.chest.exercises.chestPressBandOneArmTwisting' => 'Chest press (band, one arm, twisting)',
			'library.chest.exercises.pulloverBarbellDecline' => 'Pullover (barbell, decline)',
			'library.chest.exercises.pressBarbellDeclineWideGrip' => 'Press (barbell, decline, wide grip)',
			'library.chest.exercises.benchPressBarbellGuillotine' => 'Bench press (barbell, guillotine)',
			'library.chest.exercises.benchPressBarbellReverseGripDecline' => 'Bench press (barbell, reverse grip, decline)',
			'library.chest.exercises.benchPressBarbellReverseGripIncline' => 'Bench press (barbell, reverse grip, incline)',
			'library.chest.exercises.benchPressBarbellWide' => 'Bench press (barbell, wide)',
			'library.chest.exercises.benchPressBarbellWideReverseGrip' => 'Bench press (barbell, wide, reverse grip)',
			'library.chest.exercises.chestStretchBehindHead' => 'Chest stretch (behind head)',
			'library.chest.exercises.seatedButterflyStretch' => 'Seated butterfly stretch',
			'library.chest.exercises.pressCableDeclineOneArm' => 'Press (cable, decline, one arm)',
			'library.chest.exercises.flyCableIncline' => 'Fly (cable, incline)',
			'library.chest.exercises.flyCableInclineStabilityBall' => 'Fly (cable, incline, stability ball)',
			'library.chest.exercises.flyCableLying' => 'Fly (cable, lying)',
			'library.chest.exercises.chestFlyCableOneArmDecline' => 'Chest fly (cable, one arm, decline)',
			'library.chest.exercises.flyCableOneArmExerciseBall' => 'Fly (cable, one arm, exercise ball)',
			'library.chest.exercises.flyCableOneArmInclineExerciseBall' => 'Fly (cable, one arm, incline, exercise ball)',
			'library.chest.exercises.pressCableOneArmIncline' => 'Press (cable, one arm, incline)',
			'library.chest.exercises.pressCableOneArmInclineExerciseBall' => 'Press (cable, one arm, incline, exercise ball)',
			'library.chest.exercises.pressCableOneArmExerciseBall' => 'Press (cable, one arm, exercise ball)',
			'library.chest.exercises.pressCableExerciseBall' => 'Press (cable, exercise ball)',
			'library.chest.exercises.chestAndAnteriorShoulderStretch' => 'Chest and anterior shoulder stretch',
			'library.chest.exercises.chestDip' => 'Chest dip',
			'library.chest.exercises.chestDipStraightBar' => 'Chest dip (straight bar)',
			'library.chest.exercises.chestStretchExerciseBall' => 'Chest stretch (exercise ball)',
			'library.chest.exercises.pushUpChestTap' => 'Push-up (chest tap)',
			'library.chest.exercises.pushUpClap' => 'Push-up (clap)',
			'library.chest.exercises.pushUpWithAlternatingSideReach' => 'Push-up with alternating side reach',
			'library.chest.exercises.pushUpDeep' => 'Push-up (deep)',
			'library.chest.exercises.pushUpDrop' => 'Push-up (drop)',
			'library.chest.exercises.flyDumbbellDecline' => 'Fly (dumbbell, decline)',
			'library.chest.exercises.benchPressDumbbellDeclineNeutralGrip' => 'Bench press (dumbbell, decline, neutral grip)',
			'library.chest.exercises.flyDumbbellDeclineOneArm' => 'Fly (dumbbell, decline, one arm)',
			'library.chest.exercises.flyDumbbellDeclineTwisting' => 'Fly (dumbbell, decline, twisting)',
			'library.chest.exercises.flyDumbbellExerciseBall' => 'Fly (dumbbell, exercise ball)',
			'library.chest.exercises.benchPressDumbbellInclineAlternate' => 'Bench press (dumbbell, incline, alternate)',
			'library.chest.exercises.flyDumbbellInclineExerciseBall' => 'Fly (dumbbell, incline, exercise ball)',
			'library.chest.exercises.benchPressDumbbellInclineNeutralGrip' => 'Bench press (dumbbell, incline, neutral grip)',
			'library.chest.exercises.flyDumbbellInclineOneArm' => 'Fly (dumbbell, incline, one arm)',
			'library.chest.exercises.flyDumbbellInclineOneArmExerciseBall' => 'Fly (dumbbell, incline, one arm, exercise ball)',
			'library.chest.exercises.pressDumbbellInclineOneArm' => 'Press (dumbbell, incline, one arm)',
			'library.chest.exercises.pressDumbbellInclineOneArmExerciseBall' => 'Press (dumbbell, incline, one arm, exercise ball)',
			'library.chest.exercises.pressDumbbellInclineExerciseBall' => 'Press (dumbbell, incline, exercise ball)',
			'library.chest.exercises.shoulderRaiseDumbbellIncline' => 'Shoulder raise (dumbbell, incline)',
			'library.chest.exercises.flyDumbbellInclineTwisting' => 'Fly (dumbbell, incline, twisting)',
			'library.chest.exercises.pressDumbbellLyingNeutralGrip' => 'Press (dumbbell, lying, neutral grip)',
			'library.chest.exercises.pressDumbbellLyingOneArm' => 'Press (dumbbell, lying, one arm)',
			'library.chest.exercises.pulloverDumbbellExerciseBall' => 'Pullover (dumbbell, exercise ball)',
			'library.chest.exercises.benchPressDumbbellNeutralGrip' => 'Bench press (dumbbell, neutral grip)',
			'library.chest.exercises.flyDumbbellOneArmBench' => 'Fly (dumbbell, one arm, bench)',
			'library.chest.exercises.chestFlyDumbbellOneArmExerciseBall' => 'Chest fly (dumbbell, one arm, exercise ball)',
			'library.chest.exercises.chestPressDumbbellOneArmDecline' => 'Chest press (dumbbell, one arm, decline)',
			'library.chest.exercises.chestPressDumbbellOneArmIncline' => 'Chest press (dumbbell, one arm, incline)',
			'library.chest.exercises.pressDumbbellOneArmExerciseBall' => 'Press (dumbbell, one arm, exercise ball)',
			'library.chest.exercises.pulloverDumbbellOneArmExerciseBall' => 'Pullover (dumbbell, one arm, exercise ball)',
			'library.chest.exercises.pressDumbbellOneArmReverseGrip' => 'Press (dumbbell, one arm, reverse grip)',
			'library.chest.exercises.flyDumbbellOneLegExerciseBall' => 'Fly (dumbbell, one leg, exercise ball)',
			'library.chest.exercises.pressDumbbellExerciseBall' => 'Press (dumbbell, exercise ball)',
			'library.chest.exercises.benchPressDumbbellReverse' => 'Bench press (dumbbell, reverse)',
			'library.chest.exercises.benchPressDumbbellTwisting' => 'Bench press (dumbbell, twisting)',
			'library.chest.exercises.dynamicPectoralStretch' => 'Dynamic pectoral stretch',
			'library.chest.exercises.supineElbowPressUp' => 'Supine elbow press-up',
			'library.chest.exercises.pikePushUpExerciseBall' => 'Pike push up (exercise ball)',
			'library.chest.exercises.flyFloorBarbell' => 'Fly (floor, barbell)',
			'library.chest.exercises.flyHyghtDumbbell' => 'Fly (hyght, dumbbell)',
			'library.chest.exercises.pushUpInclineDepthJump' => 'Push-up (incline, depth jump)',
			'library.chest.exercises.pushUpInclineReverseGrip' => 'Push-up (incline, reverse grip)',
			'library.chest.exercises.pushUpInclineScapula' => 'Push-up (incline, scapula)',
			'library.chest.exercises.isometricPalmToPalmChestSqueeze' => 'Isometric palm-to-palm chest squeeze',
			'library.chest.exercises.isometricPushUpWithSideShifts' => 'Isometric push-up with side shifts',
			'library.chest.exercises.pressKettlebellAlternateFloor' => 'Press (kettlebell, alternate, floor)',
			'library.chest.exercises.pressKettlebellExtendedRangeOneArmFloor' => 'Press (kettlebell, extended range, one arm, floor)',
			'library.chest.exercises.floorPressKettlebellOneArm' => 'Floor press (kettlebell, one arm)',
			'library.chest.exercises.pushUpKettlebellPlyo' => 'Push-up (kettlebell, plyo)',
			'library.chest.exercises.pushUpKneeling' => 'Push-up (kneeling)',
			'library.chest.exercises.rearBarDips' => 'Rear-bar dips',
			'library.chest.exercises.chestPressLeverDecline' => 'Chest press (lever, decline)',
			'library.chest.exercises.chestPressLeverStanding' => 'Chest press (lever, standing)',
			'library.chest.exercises.machineChestSqueezePress' => 'Machine chest squeeze press',
			'library.chest.exercises.medicineBallChestPass' => 'Medicine-ball chest pass',
			'library.chest.exercises.medicineBallChestThrowFromThreePointStart' => 'Medicine-ball chest throw from three-point start',
			'library.chest.exercises.repeatedMedicineBallChestPasses' => 'Repeated medicine-ball chest passes',
			'library.chest.exercises.singleMedicineBallChestThrow' => 'Single medicine-ball chest throw',
			'library.chest.exercises.medicineBallChestThrowWithRunOut' => 'Medicine-ball chest throw with run-out',
			'library.chest.exercises.pushUpModifiedHindu' => 'Push-up (modified hindu)',
			'library.chest.exercises.kneelingPushUpToForearms' => 'Kneeling push-up to forearms',
			'library.chest.exercises.pushUpNarrowExerciseBall' => 'Push-up (narrow, exercise ball)',
			'library.chest.exercises.pushUpOutsideLegKick' => 'Push-up (outside leg kick)',
			'library.chest.exercises.pushUpPlyo' => 'Push-up (plyo)',
			'library.chest.exercises.bodyweightPushAndPull' => 'Bodyweight push-and-pull',
			'library.chest.exercises.pushUpBosuBall' => 'Push-up (bosu ball)',
			'library.chest.exercises.pushUpStabilityBall' => 'Push-up (stability ball)',
			'library.chest.exercises.pushUpWall' => 'Push-up (wall)',
			'library.chest.exercises.pushUpInsideLegKick' => 'Push-up (inside leg kick)',
			'library.chest.exercises.pushUpMedicineBall' => 'Push-up (medicine ball)',
			'library.chest.exercises.pushUpLowerArms' => 'Push-up (lower arms)',
			'library.chest.exercises.pushUpPlus' => 'Push-up (plus)',
			'library.chest.exercises.pushUpIntoSidePlank' => 'Push-up into side plank',
			'library.chest.exercises.chestPressResistanceBandSeated' => 'Chest press (resistance band, seated)',
			'library.chest.exercises.seatedRollerReachForward' => 'Seated roller reach-forward',
			'library.chest.exercises.seatedStraightArmRollerRaise' => 'Seated straight-arm roller raise',
			'library.chest.exercises.pushUpScapula' => 'Push-up (scapula)',
			'library.chest.exercises.pushUpWithShoulderTaps' => 'Push-up with shoulder taps',
			'library.chest.exercises.pushUpSide' => 'Push-up (side)',
			'library.chest.exercises.pushUpOneArm' => 'Push-up (one arm)',
			'library.chest.exercises.pressSmithDeclineReverseGrip' => 'Press (smith, decline, reverse grip)',
			'library.chest.exercises.pressSmithInclineReverseGrip' => 'Press (smith, incline, reverse grip)',
			'library.chest.exercises.inclineSmithMachineHighPull' => 'Incline Smith-machine high pull',
			'library.chest.exercises.benchPressSmithMachineReverseDeclineCloseGrip' => 'Bench press (smith machine, reverse, decline, close grip)',
			'library.chest.exercises.pressSmithReverseGrip' => 'Press (smith, reverse grip)',
			'library.chest.exercises.benchPressSmithWideGrip' => 'Bench press (smith, wide grip)',
			'library.chest.exercises.benchPressSmithWideGripDecline' => 'Bench press (smith, wide grip, decline)',
			'library.chest.exercises.pushUpSpiderCrawl' => 'Push-up (spider crawl)',
			'library.chest.exercises.pushUpSuperman' => 'Push-up (superman)',
			'library.chest.exercises.pushUpSuspended' => 'Push-up (suspended)',
			'library.chest.exercises.pushUpWeightedDrop' => 'Push-up (weighted, drop)',
			'library.chest.exercises.dipWeightedStraightBar' => 'Dip (weighted, straight bar)',
			'library.chest.exercises.svendPressWeighted' => 'Svend press (weighted)',
			'library.chest.exercises.pushUpWideHand' => 'Push-up (wide, hand)',
			'library.chest.exercises.chestDipWideGripHighParallelBars' => 'Chest dip (wide grip, high, parallel bars)',
			'library.biceps.name' => 'Biceps',
			'library.biceps.exercises.behindBodyCableCurl' => 'Behind-the-body cable curl',
			'library.biceps.exercises.ropeHammerCurl' => 'Cable rope hammer curl',
			'library.biceps.exercises.inclineDumbbellCurl' => 'Incline dumbbell curl',
			'library.biceps.exercises.barbellBicepsCurl' => 'Biceps curl (barbell)',
			'library.biceps.exercises.spiderCurls' => 'Spider curls',
			'library.biceps.exercises.singleArmCableHammerCurls' => 'Hammer curls (cable, single arm)',
			'library.biceps.exercises.cableBicepsCurl' => 'Biceps curl (cable)',
			'library.biceps.exercises.dumbbellBicepsCurl' => 'Biceps curl (dumbbell)',
			'library.biceps.exercises.bicepsCurlMachine' => 'Biceps curl (machine)',
			'library.biceps.exercises.hammerCurlDumbbell' => 'Hammer curls (dumbbells)',
			'library.biceps.exercises.concentrationCurl' => 'Concentration curls',
			'library.biceps.exercises.scottCurl' => 'Preacher curl',
			'library.biceps.exercises.dualCableHighCurl' => 'Dual-cable high curls',
			'library.biceps.exercises.bicepsCurlBandAlternate' => 'Biceps curl (band, alternate)',
			'library.biceps.exercises.concentrationCurlBand' => 'Concentration curl (band)',
			'library.biceps.exercises.bicepsCurlBandOneArmOverhead' => 'Biceps curl (band, one arm, overhead)',
			'library.biceps.exercises.bicepsCurlBarbellAlternate' => 'Biceps curl (barbell, alternate)',
			'library.biceps.exercises.bicepsCurlBarbellArmBlaster' => 'Biceps curl (barbell, arm blaster)',
			'library.biceps.exercises.dragCurlBarbell' => 'Drag curl (barbell)',
			'library.biceps.exercises.preacherCurlBarbellLying' => 'Preacher curl (barbell, lying)',
			'library.biceps.exercises.preacherCurlBarbell' => 'Preacher curl (barbell)',
			'library.biceps.exercises.reversePreacherCurlBarbell' => 'Reverse preacher curl (barbell)',
			'library.biceps.exercises.concentrationCurlBarbellSeatedCloseGrip' => 'Concentration curl (barbell, seated, close grip)',
			'library.biceps.exercises.curlBarbellStandingCloseGrip' => 'Curl (barbell, standing, close grip)',
			'library.biceps.exercises.concentrationCurlBarbellStanding' => 'Concentration curl (barbell, standing)',
			'library.biceps.exercises.bicepsCurlBarbellStandingWideGrip' => 'Biceps curl (barbell, standing, wide grip)',
			'library.biceps.exercises.legResistedConcentrationCurl' => 'Leg-resisted concentration curl',
			'library.biceps.exercises.chinUpCloseGrip' => 'Chin-up (close grip)',
			'library.biceps.exercises.bicepsCurlBodyweightSideLying' => 'Biceps curl (bodyweight, side lying)',
			'library.biceps.exercises.curlCableCloseGrip' => 'Curl (cable, close grip)',
			'library.biceps.exercises.concentrationCurlCable' => 'Concentration curl (cable)',
			'library.biceps.exercises.dragCurlCable' => 'Drag curl (cable)',
			'library.biceps.exercises.bicepsCurlCableLying' => 'Biceps curl (cable, lying)',
			'library.biceps.exercises.curlCableLyingCloseGrip' => 'Curl (cable, lying, close grip)',
			'library.biceps.exercises.curlCableOneArm' => 'Curl (cable, one arm)',
			'library.biceps.exercises.preacherCurlCableOneArm' => 'Preacher curl (cable, one arm)',
			'library.biceps.exercises.reversePreacherCurlCableOneArm' => 'Reverse preacher curl (cable, one arm)',
			'library.biceps.exercises.curlCableOverheadExerciseBall' => 'Curl (cable, overhead, exercise ball)',
			'library.biceps.exercises.preacherCurlCable' => 'Preacher curl (cable)',
			'library.biceps.exercises.bicepsCurlCablePulldown' => 'Biceps curl (cable, pulldown)',
			'library.biceps.exercises.reverseCurlCable' => 'Reverse curl (cable)',
			'library.biceps.exercises.reversePreacherCurlCable' => 'Reverse preacher curl (cable)',
			'library.biceps.exercises.hammerPreacherCurlCableRope' => 'Hammer preacher curl (cable, rope)',
			'library.biceps.exercises.hammerPreacherCurlCableRopeOneArm' => 'Hammer preacher curl (cable, rope, one arm)',
			'library.biceps.exercises.curlCableSeated' => 'Curl (cable, seated)',
			'library.biceps.exercises.concentrationCurlCableSeatedOneArm' => 'Concentration curl (cable, seated, one arm)',
			'library.biceps.exercises.curlCableSeatedOverhead' => 'Curl (cable, seated, overhead)',
			'library.biceps.exercises.curlCableSquatting' => 'Curl (cable, squatting)',
			'library.biceps.exercises.curlCableStandingInner' => 'Curl (cable, standing, inner)',
			'library.biceps.exercises.bicepsCurlCableRopeStanding' => 'Biceps curl (cable, rope, standing)',
			'library.biceps.exercises.curlCableTwoArmInclineBench' => 'Curl (cable, two arm, incline bench)',
			'library.biceps.exercises.bicepsCurlDumbbellAlternate' => 'Biceps curl (dumbbell, alternate)',
			'library.biceps.exercises.bicepsCurlDumbbellAlternateArmBlaster' => 'Biceps curl (dumbbell, alternate, arm blaster)',
			'library.biceps.exercises.hammerPreacherCurlDumbbellAlternate' => 'Hammer preacher curl (dumbbell, alternate)',
			'library.biceps.exercises.preacherCurlDumbbellAlternate' => 'Preacher curl (dumbbell, alternate)',
			'library.biceps.exercises.hammerCurlDumbbellAlternateSeated' => 'Hammer curl (dumbbell, alternate, seated)',
			'library.biceps.exercises.bicepsCurlDumbbellAlternateLegRaisedExerciseBall' => 'Biceps curl (dumbbell, alternate, leg raised, exercise ball)',
			'library.biceps.exercises.bicepsCurlDumbbellAlternateSeatedExerciseBall' => 'Biceps curl (dumbbell, alternate, seated, exercise ball)',
			'library.biceps.exercises.dumbbellCurlWithBowlingLunge' => 'Dumbbell curl with bowling lunge',
			'library.biceps.exercises.bicepsCurlDumbbellExerciseBallLegRaised' => 'Biceps curl (dumbbell, exercise ball, leg raised)',
			'library.biceps.exercises.bicepsCurlDumbbellStorkStance' => 'Biceps curl (dumbbell, stork stance)',
			'library.biceps.exercises.bicepsCurlDumbbellArmBlaster' => 'Biceps curl (dumbbell, arm blaster)',
			'library.biceps.exercises.bicepsCurlSquatDumbbell' => 'Biceps curl squat (dumbbell)',
			'library.biceps.exercises.bicepsCurlDumbbellVSitBosuBall' => 'Biceps curl (dumbbell, v sit, bosu ball)',
			'library.biceps.exercises.hammerCurlDumbbellCrossBody' => 'Hammer curl (dumbbell, cross body)',
			'library.biceps.exercises.hammerCurlDumbbellExerciseBall' => 'Hammer curl (dumbbell, exercise ball)',
			'library.biceps.exercises.hammerCurlDumbbellArmBlaster' => 'Hammer curl (dumbbell, arm blaster)',
			'library.biceps.exercises.highCurlDumbbell' => 'High curl (dumbbell)',
			'library.biceps.exercises.preacherCurlDumbbellIncline' => 'Preacher curl (dumbbell, incline)',
			'library.biceps.exercises.hammerCurlDumbbellIncline' => 'Hammer curl (dumbbell, incline)',
			'library.biceps.exercises.innerBicepsCurlDumbbellIncline' => 'Inner biceps curl (dumbbell, incline)',
			'library.biceps.exercises.bicepsCurlDumbbellKneelingExerciseBall' => 'Biceps curl (dumbbell, kneeling, exercise ball)',
			'library.biceps.exercises.lungeBicepsCurlDumbbell' => 'Lunge biceps curl (dumbbell)',
			'library.biceps.exercises.bicepsCurlDumbbellLyingSupine' => 'Biceps curl (dumbbell, lying, supine)',
			'library.biceps.exercises.bicepsCurlDumbbellLying' => 'Biceps curl (dumbbell, lying)',
			'library.biceps.exercises.curlDumbbellLyingWide' => 'Curl (dumbbell, lying, wide)',
			'library.biceps.exercises.concentrationCurlDumbbellOneArmStabilityBall' => 'Concentration curl (dumbbell, one arm, stability ball)',
			'library.biceps.exercises.hammerPreacherCurlDumbbellOneArm' => 'Hammer preacher curl (dumbbell, one arm)',
			'library.biceps.exercises.curlDumbbellOneArmProne' => 'Curl (dumbbell, one arm, prone)',
			'library.biceps.exercises.hammerCurlDumbbellOneArmProne' => 'Hammer curl (dumbbell, one arm, prone)',
			'library.biceps.exercises.reversePreacherCurlDumbbellOneArm' => 'Reverse preacher curl (dumbbell, one arm)',
			'library.biceps.exercises.reverseSpiderCurlDumbbellOneArm' => 'Reverse spider curl (dumbbell, one arm)',
			'library.biceps.exercises.bicepsCurlDumbbellOneArmSeatedExerciseBall' => 'Biceps curl (dumbbell, one arm, seated, exercise ball)',
			'library.biceps.exercises.hammerCurlDumbbellOneArmSeated' => 'Hammer curl (dumbbell, one arm, seated)',
			'library.biceps.exercises.curlDumbbellOneArmStanding' => 'Curl (dumbbell, one arm, standing)',
			'library.biceps.exercises.hammerCurlDumbbellOneArmStanding' => 'Hammer curl (dumbbell, one arm, standing)',
			'library.biceps.exercises.zottmanPreacherCurlDumbbellOneArm' => 'Zottman preacher curl (dumbbell, one arm)',
			'library.biceps.exercises.hammerPreacherCurlDumbbell' => 'Hammer preacher curl (dumbbell)',
			'library.biceps.exercises.preacherCurlDumbbellExerciseBall' => 'Preacher curl (dumbbell, exercise ball)',
			'library.biceps.exercises.curlDumbbellProneIncline' => 'Curl (dumbbell, prone, incline)',
			'library.biceps.exercises.hammerCurlDumbbellProneIncline' => 'Hammer curl (dumbbell, prone, incline)',
			'library.biceps.exercises.reversePreacherCurlDumbbell' => 'Reverse preacher curl (dumbbell)',
			'library.biceps.exercises.reverseSpiderCurlDumbbell' => 'Reverse spider curl (dumbbell)',
			'library.biceps.exercises.hammerCurlDumbbellSeatedAlternateExerciseBall' => 'Hammer curl (dumbbell, seated, alternate, exercise ball)',
			'library.biceps.exercises.bicepsCurlDumbbellSeated' => 'Biceps curl (dumbbell, seated)',
			'library.biceps.exercises.bicepsCurlDumbbellSeatedExerciseBall' => 'Biceps curl (dumbbell, seated, exercise ball)',
			'library.biceps.exercises.hammerCurlDumbbellSeated' => 'Hammer curl (dumbbell, seated)',
			'library.biceps.exercises.innerBicepsCurlDumbbellSeated' => 'Inner biceps curl (dumbbell, seated)',
			'library.biceps.exercises.bicepsCurlDumbbellSeatedOneArmExerciseBallLegRaised' => 'Biceps curl (dumbbell, seated, one arm, exercise ball, leg raised)',
			'library.biceps.exercises.preacherCurlDumbbellSeated' => 'Preacher curl (dumbbell, seated)',
			'library.biceps.exercises.concentrationCurlDumbbellSeatedReverse' => 'Concentration curl (dumbbell, seated, reverse)',
			'library.biceps.exercises.hammerCurlAndPressDumbbellStandingAlternate' => 'Hammer curl and press (dumbbell, standing, alternate)',
			'library.biceps.exercises.concentrationCurlDumbbellStanding' => 'Concentration curl (dumbbell, standing)',
			'library.biceps.exercises.innerBicepsCurlDumbbellStanding' => 'Inner biceps curl (dumbbell, standing)',
			'library.biceps.exercises.concentrationCurlDumbbellStandingOneArm' => 'Concentration curl (dumbbell, standing, one arm)',
			'library.biceps.exercises.curlDumbbellStandingOneArmInclineBench' => 'Curl (dumbbell, standing, one arm, incline bench)',
			'library.biceps.exercises.preacherCurlDumbbellStanding' => 'Preacher curl (dumbbell, standing)',
			'library.biceps.exercises.zottmanPreacherCurlDumbbellStanding' => 'Zottman preacher curl (dumbbell, standing)',
			'library.biceps.exercises.stepUpWithBalanceAndDumbbellCurl' => 'Step-up with balance and dumbbell curl',
			'library.biceps.exercises.bicepsCurlDumbbellWaiter' => 'Biceps curl (dumbbell, waiter)',
			'library.biceps.exercises.zottmanCurlDumbbell' => 'Zottman curl (dumbbell)',
			'library.biceps.exercises.zottmanPreacherCurlDumbbell' => 'Zottman preacher curl (dumbbell)',
			'library.biceps.exercises.concentrationCurlEzBarSeatedCloseGrip' => 'Concentration curl (ez bar, seated, close grip)',
			'library.biceps.exercises.preacherCurlEzBarbellCloseGrip' => 'Preacher curl (ez barbell, close grip)',
			'library.biceps.exercises.curlEzBarbellCloseGrip' => 'Curl (ez barbell, close grip)',
			'library.biceps.exercises.curlEzBarbell' => 'Curl (ez barbell)',
			'library.biceps.exercises.reverseCurlEzBarbell' => 'Reverse curl (ez barbell)',
			'library.biceps.exercises.reversePreacherCurlEzBarbell' => 'Reverse preacher curl (ez barbell)',
			'library.biceps.exercises.curlEzBarbellSeated' => 'Curl (ez barbell, seated)',
			'library.biceps.exercises.spiderCurlEzBarbell' => 'Spider curl (ez barbell)',
			'library.biceps.exercises.bicepsCurlEzBarArmBlaster' => 'Biceps curl (ez bar, arm blaster)',
			'library.biceps.exercises.bicepsCurlEzBarbellStandingWideGrip' => 'Biceps curl (ez barbell, standing, wide grip)',
			'library.biceps.exercises.cleanKettlebellBottomsUpFromHangPosition' => 'Clean (kettlebell, bottoms up, from hang position)',
			'library.biceps.exercises.hangCleanKettlebellDoubleAlternate' => 'Hang clean (kettlebell, double, alternate)',
			'library.biceps.exercises.preacherCurlLeverHammerGrip' => 'Preacher curl (lever, hammer grip)',
			'library.biceps.exercises.preacherCurlLever' => 'Preacher curl (lever)',
			'library.biceps.exercises.reversePreacherCurlLever' => 'Reverse preacher curl (lever)',
			'library.biceps.exercises.hammerCurlOlympicBarbell' => 'Hammer curl (olympic barbell)',
			'library.biceps.exercises.bicepsCurlResistanceBandSeated' => 'Biceps curl (resistance band, seated)',
			'library.biceps.exercises.bicepsCurlSmithMachine' => 'Biceps curl (smith machine)',
			'library.biceps.exercises.bicepsCurlWeightedSeatedStabilityBall' => 'Biceps curl (weighted, seated, stability ball)',
			'library.abs.name' => 'Abs',
			'library.abs.exercises.abWheelRollout' => 'Ab wheel rollout',
			'library.abs.exercises.hangingKneeRaise' => 'Hanging knee raise',
			'library.abs.exercises.mountainClimber' => 'Mountain climber',
			'library.abs.exercises.highCableWoodchopper' => 'High-to-low cable woodchop',
			'library.abs.exercises.reverseCrunch' => 'Reverse crunch',
			'library.abs.exercises.cableCrunch' => 'Cable crunch',
			'library.abs.exercises.pallofPress' => 'Cable Pallof press',
			'library.abs.exercises.crunches' => 'Crunches',
			'library.abs.exercises.kneeRaise' => 'Lying knee raise',
			'library.abs.exercises.legRaise' => 'Lying leg raise',
			'library.abs.exercises.crunchMachine' => 'Crunch (machine)',
			'library.abs.exercises.heelsUpCrunch' => 'Heels-up crunches',
			'library.abs.exercises.fullBodyCrunch' => 'Double crunch',
			'library.abs.exercises.plank' => 'Plank',
			'library.abs.exercises.hollowBodyHold' => 'Hollow body hold',
			'library.abs.exercises.bicycleCrunches' => 'Bicycle crunches',
			'library.abs.exercises.extendedReverseCrunchWithLegExtension' => 'Reverse crunch with leg extension',
			'library.abs.exercises.toeTouches' => 'Toe touches',
			'library.abs.exercises.russianTwist' => 'Russian twist',
			'library.abs.exercises.heelTouches' => 'Heel touches',
			'library.abs.exercises.deadBugHoldCardio' => 'Dead bugs (timed)',
			'library.abs.exercises.deadBugHoldStatic' => 'Dead bug hold (static)',
			'library.abs.exercises.deadBugHold' => 'Dead bugs',
			'library.abs.exercises.hollowBodyHoldBentKnees' => 'Bent-knee hollow body hold',
			'library.abs.exercises.obliqueCrunches' => 'Oblique crunches',
			'library.abs.exercises.legRaiseParallelBars' => 'Leg raise (parallel bars)',
			'library.abs.exercises.lateralHyperextensions' => 'Lateral hyperextensions',
			'library.abs.exercises.sitUp34' => 'Sit-up (3/4)',
			'library.abs.exercises.sideBendOnA45Bench' => 'Side bend on a 45° bench',
			'library.abs.exercises.legRaiseHangingStraps' => 'Leg raise (hanging, straps)',
			'library.abs.exercises.sitUpArmsOverheadFull' => 'Sit-up (arms overhead, full)',
			'library.abs.exercises.kneeRaiseAssistedHanging' => 'Knee raise (assisted, hanging)',
			'library.abs.exercises.kneeRaiseAssistedHangingThrowDown' => 'Knee raise (assisted, hanging, throw down)',
			'library.abs.exercises.legRaiseAssistedLyingLateralThrowDown' => 'Leg raise (assisted, lying, lateral, throw down)',
			'library.abs.exercises.legRaiseAssistedLyingThrowDown' => 'Leg raise (assisted, lying, throw down)',
			'library.abs.exercises.russianTwistAssistedMotion' => 'Russian twist (assisted, motion)',
			'library.abs.exercises.sitUpAssisted' => 'Sit-up (assisted)',
			'library.abs.exercises.vUpBandAlternate' => 'V-up (band, alternate)',
			'library.abs.exercises.rolloutBandAssistedWheel' => 'Rollout (band, assisted, wheel)',
			'library.abs.exercises.bicycleCrunchBand' => 'Bicycle crunch (band)',
			'library.abs.exercises.pallofPressBandHorizontal' => 'Pallof press (band, horizontal)',
			'library.abs.exercises.jackknifeSitUpBand' => 'Jackknife sit-up (band)',
			'library.abs.exercises.crunchBandKneelingTwisting' => 'Crunch (band, kneeling, twisting)',
			'library.abs.exercises.legRaiseBandLyingStraightLeg' => 'Leg raise (band, lying, straight leg)',
			'library.abs.exercises.sitUpBandPush' => 'Sit-up (band, push)',
			'library.abs.exercises.twistBandSeated' => 'Twist (band, seated)',
			'library.abs.exercises.crunchBandStanding' => 'Crunch (band, standing)',
			'library.abs.exercises.crunchBandStandingTwisting' => 'Crunch (band, standing, twisting)',
			'library.abs.exercises.vUpBand' => 'V-up (band)',
			'library.abs.exercises.pallofPressBandVertical' => 'Pallof press (band, vertical)',
			'library.abs.exercises.sitUpBarbellPress' => 'Sit-up (barbell, press)',
			'library.abs.exercises.rolloutBarbell' => 'Rollout (barbell)',
			'library.abs.exercises.rolloutBarbellFromBench' => 'Rollout (barbell, from bench)',
			'library.abs.exercises.twistBarbellSeated' => 'Twist (barbell, seated)',
			'library.abs.exercises.sideBendBarbell' => 'Side bend (barbell)',
			'library.abs.exercises.legRaiseBarbellSeatedAlternate' => 'Leg raise (barbell, seated, alternate)',
			'library.abs.exercises.abRolloutBarbellStanding' => 'Ab rollout (barbell, standing)',
			'library.abs.exercises.twistBarbellStanding' => 'Twist (barbell, standing)',
			'library.abs.exercises.sidePlankBodyweightIncline' => 'Side plank (bodyweight, incline)',
			'library.abs.exercises.reverseCrunchWithVerticalHipLift' => 'Reverse crunch with vertical hip lift',
			'library.abs.exercises.crossBodyMountainClimber' => 'Cross-body mountain climber',
			'library.abs.exercises.plankHipLifts' => 'Plank hip lifts',
			'library.abs.exercises.cableRotationalShoulderThrow' => 'Cable rotational shoulder throw',
			'library.abs.exercises.reverseCrunchCable' => 'Reverse crunch (cable)',
			'library.abs.exercises.russianTwistCableStabilityBall' => 'Russian twist (cable, stability ball)',
			'library.abs.exercises.crunchCableSeated' => 'Crunch (cable, seated)',
			'library.abs.exercises.twistCableSeated' => 'Twist (cable, seated)',
			'library.abs.exercises.sideBendCable' => 'Side bend (cable)',
			'library.abs.exercises.sideBendCableCrunchBosuBall' => 'Side bend (cable, crunch, bosu ball)',
			'library.abs.exercises.sideCrunchCable' => 'Side crunch (cable)',
			'library.abs.exercises.crunchCableStanding' => 'Crunch (cable, standing)',
			'library.abs.exercises.crunchCableStandingRope' => 'Crunch (cable, standing, rope)',
			'library.abs.exercises.lowToHighCableWoodchop' => 'Low-to-high cable woodchop',
			'library.abs.exercises.reverseCrunchCableTuck' => 'Reverse crunch (cable, tuck)',
			'library.abs.exercises.twistCable' => 'Twist (cable)',
			'library.abs.exercises.crabPositionToeTouches' => 'Crab-position toe touches',
			'library.abs.exercises.crunchCrossBody' => 'Crunch (cross body)',
			'library.abs.exercises.crunchHandsOverhead' => 'Crunch (hands overhead)',
			'library.abs.exercises.crunchStabilityBall' => 'Crunch (stability ball)',
			'library.abs.exercises.crunchStabilityBallStraightArm' => 'Crunch (stability ball, straight arm)',
			'library.abs.exercises.crunchDecline' => 'Crunch (decline)',
			'library.abs.exercises.sitUpDecline' => 'Sit-up (decline)',
			'library.abs.exercises.sideBendDumbbell' => 'Side bend (dumbbell)',
			'library.abs.exercises.alternatingElbowToKneeCrunch' => 'Alternating elbow-to-knee crunch',
			'library.abs.exercises.humanFlagHold' => 'Human flag hold',
			'library.abs.exercises.sitUpFlexionLegBentKnee' => 'Sit-up (flexion leg, bent knee)',
			'library.abs.exercises.sitUpFlexionLegStraightArm' => 'Sit-up (flexion leg, straight arm)',
			'library.abs.exercises.crunchFrog' => 'Crunch (frog)',
			'library.abs.exercises.plankTrunkRotations' => 'Plank trunk rotations',
			'library.abs.exercises.chinUpWithKneeTuck' => 'Chin-up with knee tuck',
			'library.abs.exercises.sitUpHalf' => 'Sit-up (half)',
			'library.abs.exercises.legHipRaiseHanging' => 'Leg hip raise (hanging)',
			'library.abs.exercises.legRaiseHanging' => 'Leg raise (hanging)',
			'library.abs.exercises.kneeRaiseHangingOblique' => 'Knee raise (hanging, oblique)',
			'library.abs.exercises.hangingPikeRaise' => 'Hanging pike raise',
			'library.abs.exercises.legHipRaiseHangingStraightLegTwisting' => 'Leg hip raise (hanging, straight leg, twisting)',
			'library.abs.exercises.inchworm' => 'Inchworm',
			'library.abs.exercises.legHipRaiseInclineStraightLeg' => 'Leg hip raise (incline, straight leg)',
			'library.abs.exercises.sitUpInclineTwisting' => 'Sit-up (incline, twisting)',
			'library.abs.exercises.jackknifeSitUp' => 'Jackknife sit-up',
			'library.abs.exercises.sitUpJanda' => 'Sit-up (janda)',
			'library.abs.exercises.windmillKettlebellAdvanced' => 'Windmill (kettlebell, advanced)',
			'library.abs.exercises.pressKettlebellBent' => 'Press (kettlebell, bent)',
			'library.abs.exercises.windmillKettlebellDouble' => 'Windmill (kettlebell, double)',
			'library.abs.exercises.kettlebellFigureEightPass' => 'Kettlebell figure-eight pass',
			'library.abs.exercises.windmillKettlebell' => 'Windmill (kettlebell)',
			'library.abs.exercises.seatedKneeTucksOnBench' => 'Seated knee tucks on bench',
			'library.abs.exercises.crunchKneeTouch' => 'Crunch (knee touch)',
			'library.abs.exercises.kneelingPlankShoulderTaps' => 'Kneeling plank shoulder taps',
			'library.abs.exercises.lSitFloor' => 'L-sit (floor)',
			'library.abs.exercises.landmineTrunkRotations' => 'Landmine trunk rotations',
			'library.abs.exercises.benchKneeTucks' => 'Bench knee tucks',
			'library.abs.exercises.twistLeverKneeling' => 'Twist (lever, kneeling)',
			'library.abs.exercises.crunchLeverSeatedChestPad' => 'Crunch (lever, seated, chest pad)',
			'library.abs.exercises.legRaiseLeverSeatedCrunch' => 'Leg raise (lever, seated, crunch)',
			'library.abs.exercises.lungeTwist' => 'Lunge (twist)',
			'library.abs.exercises.legHipRaiseLying' => 'Leg hip raise (lying)',
			'library.abs.exercises.crunchNegative' => 'Crunch (negative)',
			'library.abs.exercises.singleArmMedicineBallSlam' => 'Single-arm medicine-ball slam',
			'library.abs.exercises.supinePelvicTilts' => 'Supine pelvic tilts',
			'library.abs.exercises.reverseStepWithOverheadReach' => 'Reverse step with overhead reach',
			'library.abs.exercises.squatPotty' => 'Squat (potty)',
			'library.abs.exercises.plankWithOppositeArmAndLegReach' => 'Plank with opposite arm and leg reach',
			'library.abs.exercises.sitUpPrisonerHalf' => 'Sit-up (prisoner, half)',
			'library.abs.exercises.twistProneStabilityBall' => 'Twist (prone, stability ball)',
			'library.abs.exercises.stabilityBallKneeTuck' => 'Stability-ball knee tuck',
			'library.abs.exercises.sitUpQuarter' => 'Sit-up (quarter)',
			'library.abs.exercises.reversePlankWithAlternatingLegRaises' => 'Reverse plank with alternating leg raises',
			'library.abs.exercises.bodySawRoller' => 'Body saw (roller)',
			'library.abs.exercises.reverseCrunchRoller' => 'Reverse crunch (roller)',
			'library.abs.exercises.russianTwistBodyweight' => 'Russian twist',
			'library.abs.exercises.legRaiseSeated' => 'Leg raise (seated)',
			'library.abs.exercises.sideCrunchSeatedWall' => 'Side crunch (seated, wall)',
			'library.abs.exercises.shoulderTap' => 'Shoulder tap',
			'library.abs.exercises.sideBridgeHipLifts' => 'Side-bridge hip lifts',
			'library.abs.exercises.lateralLegRaisesOnParallelBars' => 'Lateral leg raises on parallel bars',
			'library.abs.exercises.alternatingCrossBodyToeTouches' => 'Alternating cross-body toe touches',
			'library.abs.exercises.sitUp' => 'Sit-up',
			'library.abs.exercises.sitUpArmsChest' => 'Sit-up (arms chest)',
			'library.abs.exercises.sledgehammerTireStrikes' => 'Sledgehammer tire strikes',
			'library.abs.exercises.diagonalDumbbellTrunkRotations' => 'Diagonal dumbbell trunk rotations',
			'library.abs.exercises.twistSpine' => 'Twist (spine)',
			'library.abs.exercises.crunchStabilityBallHandsBehindHeadFull' => 'Crunch (stability ball, hands behind head, full)',
			'library.abs.exercises.rolloutStandingWheel' => 'Rollout (standing, wheel)',
			'library.abs.exercises.suspensionStrapAbdominalRollout' => 'Suspension-strap abdominal rollout',
			'library.abs.exercises.reverseCrunchSuspended' => 'Reverse crunch (suspended)',
			'library.abs.exercises.legRaiseTwisted' => 'Leg raise (twisted)',
			'library.abs.exercises.vSitFloor' => 'V-sit (floor)',
			'library.abs.exercises.crunchWeighted' => 'Crunch (weighted)',
			'library.abs.exercises.sitUpWeightedDecline' => 'Sit-up (weighted, decline)',
			'library.abs.exercises.plankWeightedFront' => 'Plank (weighted, front)',
			'library.abs.exercises.legHipRaiseWeightedHanging' => 'Leg hip raise (weighted, hanging)',
			'library.abs.exercises.crunchWeightedOverheadStabilityBall' => 'Crunch (weighted, overhead, stability ball)',
			'library.abs.exercises.russianTwistWeightedLegsUp' => 'Russian twist (weighted, legs up)',
			'library.abs.exercises.twistWeightedSeatedStabilityBall' => 'Twist (weighted, seated, stability ball)',
			'library.abs.exercises.sideBendWeightedStabilityBall' => 'Side bend (weighted, stability ball)',
			'library.calves.name' => 'Calves',
			'library.calves.exercises.smithMachineCalfRaise' => 'Smith machine calf raise',
			'library.calves.exercises.calfRaiseStanding' => 'Calf raise (standing)',
			'library.calves.exercises.calfRaiseSeated' => 'Calf raise (seated)',
			'library.calves.exercises.calfPressLegPressMachine' => 'Calf press on leg press machine',
			'library.calves.exercises.ankleRotations' => 'Ankle rotations',
			'library.calves.exercises.calvesStretchAssistedLying' => 'Calves stretch (assisted, lying)',
			'library.calves.exercises.calfRaiseBandOneLeg' => 'Calf raise (band, one leg)',
			'library.calves.exercises.reverseCalfRaiseBandOneLeg' => 'Reverse calf raise (band, one leg)',
			'library.calves.exercises.calfRaiseBandStanding' => 'Calf raise (band, standing)',
			'library.calves.exercises.calfRaiseBarbellFloor' => 'Calf raise (barbell, floor)',
			'library.calves.exercises.calfRaiseBarbellSeated' => 'Calf raise (barbell, seated)',
			'library.calves.exercises.calfRaiseBarbellStanding' => 'Calf raise (barbell, standing)',
			'library.calves.exercises.calfRaiseBarbellStandingRockingLeg' => 'Calf raise (barbell, standing, rocking leg)',
			'library.calves.exercises.standingBodyweightCalfRaise' => 'Standing bodyweight calf raise',
			'library.calves.exercises.boxDropWithSingleLegLanding' => 'Box drop with single-leg landing',
			'library.calves.exercises.calfRaiseCableStanding' => 'Calf raise (cable, standing)',
			'library.calves.exercises.calfRaiseCableStandingOneLeg' => 'Calf raise (cable, standing, one leg)',
			'library.calves.exercises.wallCalfStretch' => 'Wall calf stretch',
			'library.calves.exercises.calfStretchRope' => 'Calf stretch (rope)',
			'library.calves.exercises.kneeCircles' => 'Knee circles',
			'library.calves.exercises.calfRaiseDonkey' => 'Calf raise (donkey)',
			'library.calves.exercises.calfRaiseDumbbellSeated' => 'Calf raise (dumbbell, seated)',
			'library.calves.exercises.calfRaiseDumbbellSeatedOneLeg' => 'Calf raise (dumbbell, seated, one leg)',
			'library.calves.exercises.calfRaiseDumbbellSeatedOneLegHammerGrip' => 'Calf raise (dumbbell, seated, one leg, hammer grip)',
			'library.calves.exercises.calfRaiseDumbbellSeatedOneLegPalmUp' => 'Calf raise (dumbbell, seated, one leg, palm up)',
			'library.calves.exercises.calfRaiseDumbbellOneLeg' => 'Calf raise (dumbbell, one leg)',
			'library.calves.exercises.calfRaiseDumbbellStanding' => 'Calf raise (dumbbell, standing)',
			'library.calves.exercises.calfRaiseExerciseBallWall' => 'Calf raise (exercise ball, wall)',
			'library.calves.exercises.wallBallCalfRaiseBallBetweenAnkles' => 'Wall-ball calf raise, ball between ankles',
			'library.calves.exercises.wallBallCalfRaiseBallBetweenKnees' => 'Wall-ball calf raise, ball between knees',
			'library.calves.exercises.calfRaiseHack' => 'Calf raise (hack)',
			'library.calves.exercises.calfRaiseHackOneLeg' => 'Calf raise (hack, one leg)',
			'library.calves.exercises.calfPressLever' => 'Calf press (lever)',
			'library.calves.exercises.calfRaiseLeverDonkey' => 'Calf raise (lever, donkey)',
			'library.calves.exercises.rotaryCalfMachinePress' => 'Rotary calf machine press',
			'library.calves.exercises.calfPressLeverSeated' => 'Calf press (lever, seated)',
			'library.calves.exercises.seatedSquatCalfRaiseOnLegPress' => 'Seated squat calf raise on leg press',
			'library.calves.exercises.calfRaiseLeverStanding' => 'Calf raise (lever, standing)',
			'library.calves.exercises.calfRaiseOneLegDonkey' => 'Calf raise (one leg, donkey)',
			'library.calves.exercises.calfRaiseOneLegFloor' => 'Calf raise (one leg, floor)',
			'library.calves.exercises.peronealsStretch' => 'Peroneals stretch',
			'library.calves.exercises.posteriorTibialisStretch' => 'Posterior tibialis stretch',
			'library.calves.exercises.calfStretchSeated' => 'Calf stretch (seated)',
			'library.calves.exercises.calfRaiseSledForwardAngled' => 'Calf raise (sled, forward, angled)',
			'library.calves.exercises.calfPressSledOneLeg' => 'Calf press (sled, one leg)',
			'library.calves.exercises.calfRaiseSmithOneLegFloor' => 'Calf raise (smith, one leg, floor)',
			'library.calves.exercises.toeRaiseSmith' => 'Toe raise (smith)',
			'library.calves.exercises.calfRaiseSmithSeatedOneLeg' => 'Calf raise (smith, seated, one leg)',
			'library.calves.exercises.calfRaiseStandingStaircase' => 'Calf raise (standing, staircase)',
			'library.calves.exercises.calfStretchStanding' => 'Calf stretch (standing)',
			'library.calves.exercises.calfRaiseWeightedDonkey' => 'Calf raise (weighted, donkey)',
			'library.quadriceps.name' => 'Quadriceps',
			'library.quadriceps.exercises.reverseDumbbellLunges' => 'Reverse dumbbell lunges',
			'library.quadriceps.exercises.walkingDumbbellLunges' => 'Walking dumbbell lunges',
			'library.quadriceps.exercises.lateralDumbbellLunges' => 'Lateral dumbbell lunges',
			'library.quadriceps.exercises.sumoDumbbellSquat' => 'Dumbbell sumo squat',
			_ => null,
		} ?? switch (path) {
			'library.quadriceps.exercises.singleLegLegPress' => 'Single-leg leg press',
			'library.quadriceps.exercises.smithMachineSquats' => 'Smith machine squat',
			'library.quadriceps.exercises.stepUps' => 'Step-ups (dumbbells)',
			'library.quadriceps.exercises.gobletSquats' => 'Goblet squat (dumbbell)',
			'library.quadriceps.exercises.squatsBarbell' => 'Squats (barbell)',
			'library.quadriceps.exercises.legPress' => 'Leg press',
			'library.quadriceps.exercises.legExtension' => 'Leg extension',
			'library.quadriceps.exercises.smithMachineLunges' => 'Smith machine lunges',
			'library.quadriceps.exercises.lunges' => 'Dumbbell lunges',
			'library.quadriceps.exercises.legPress45deg' => 'Leg press (45°)',
			'library.quadriceps.exercises.frontSquats' => 'Front squats',
			'library.quadriceps.exercises.bulgarianSplitSquats' => 'Bulgarian split squats',
			'library.quadriceps.exercises.bodyweightSquats' => 'Bodyweight squat',
			'library.quadriceps.exercises.hackSquats' => 'Hack squats',
			'library.quadriceps.exercises.quadricepsStretchQuadruped' => 'Quadriceps stretch (quadruped)',
			'library.quadriceps.exercises.quadricepsStretchAssistedProne' => 'Quadriceps stretch (assisted, prone)',
			'library.quadriceps.exercises.backwardJump' => 'Backward jump',
			'library.quadriceps.exercises.balanceBoardStance' => 'Balance-board stance',
			'library.quadriceps.exercises.splitSquatBandOneArmOneLeg' => 'Split squat (band, one arm, one leg)',
			'library.quadriceps.exercises.splitSquatBandOneLeg' => 'Split squat (band, one leg)',
			'library.quadriceps.exercises.squatBand' => 'Squat (band)',
			'library.quadriceps.exercises.squatRowBand' => 'Squat row (band)',
			'library.quadriceps.exercises.stepUpBand' => 'Step-up (band)',
			'library.quadriceps.exercises.frontSquatBarbellBench' => 'Front squat (barbell, bench)',
			'library.quadriceps.exercises.squatBarbellBench' => 'Squat (barbell, bench)',
			'library.quadriceps.exercises.cleanAndPressBarbell' => 'Clean and press (barbell)',
			'library.quadriceps.exercises.zercherSquatBarbellFull' => 'Zercher squat (barbell, full)',
			'library.quadriceps.exercises.hackSquatBarbell' => 'Hack squat (barbell)',
			'library.quadriceps.exercises.squatBarbellHighBar' => 'Squat (barbell, high bar)',
			'library.quadriceps.exercises.jeffersonSquatBarbell' => 'Jefferson squat (barbell)',
			'library.quadriceps.exercises.jumpSquatBarbell' => 'Jump squat (barbell)',
			'library.quadriceps.exercises.lateralLungeBarbell' => 'Lateral lunge (barbell)',
			'library.quadriceps.exercises.squatBarbellLowBar' => 'Squat (barbell, low bar)',
			'library.quadriceps.exercises.lungeBarbell' => 'Lunge (barbell)',
			'library.quadriceps.exercises.squatBarbellNarrowStance' => 'Squat (barbell, narrow stance)',
			'library.quadriceps.exercises.squatBarbellOneLeg' => 'Squat (barbell, one leg)',
			'library.quadriceps.exercises.squatBarbellOverhead' => 'Squat (barbell, overhead)',
			'library.quadriceps.exercises.rearLungeBarbell' => 'Rear lunge (barbell)',
			'library.quadriceps.exercises.splitSquatBarbellSide' => 'Split squat (barbell, side)',
			'library.quadriceps.exercises.splitSquatBarbellOneLeg' => 'Split squat (barbell, one leg)',
			'library.quadriceps.exercises.squatBarbellSpeed' => 'Squat (barbell, speed)',
			'library.quadriceps.exercises.splitSquatBarbell' => 'Split squat (barbell)',
			'library.quadriceps.exercises.squatBarbellKnee' => 'Squat (barbell, knee)',
			'library.quadriceps.exercises.barbellSquatJumpIntoReverseLunge' => 'Barbell squat jump into reverse lunge',
			'library.quadriceps.exercises.stepUpBarbell' => 'Step-up (barbell)',
			'library.quadriceps.exercises.squatBarbellWide' => 'Squat (barbell, wide)',
			'library.quadriceps.exercises.zercherSquatBarbell' => 'Zercher squat (barbell)',
			'library.quadriceps.exercises.jumpSquatBodyweightDrop' => 'Jump squat (bodyweight, drop)',
			'library.quadriceps.exercises.chairSupportedQuadricepsStretch' => 'Chair-supported quadriceps stretch',
			'library.quadriceps.exercises.curtsySquat' => 'Curtsy squat',
			'library.quadriceps.exercises.squatDumbbellBench' => 'Squat (dumbbell, bench)',
			'library.quadriceps.exercises.lungeDumbbellContralateralForward' => 'Lunge (dumbbell, contralateral forward)',
			'library.quadriceps.exercises.squatDumbbellPlyo' => 'Squat (dumbbell, plyo)',
			'library.quadriceps.exercises.squatDumbbellPistol' => 'Squat (dumbbell, pistol)',
			'library.quadriceps.exercises.squatDumbbell' => 'Squat (dumbbell)',
			'library.quadriceps.exercises.stepUpLungeDumbbell' => 'Step up lunge (dumbbell)',
			'library.quadriceps.exercises.stepUpSplitSquatDumbbell' => 'Step up split squat (dumbbell)',
			'library.quadriceps.exercises.squatDumbbellSupported' => 'Squat (dumbbell, supported)',
			'library.quadriceps.exercises.farmersWalk' => 'Farmers walk',
			'library.quadriceps.exercises.forwardJump' => 'Forward jump',
			'library.quadriceps.exercises.lungeForward' => 'Lunge (forward)',
			'library.quadriceps.exercises.squatFrankenstein' => 'Squat (frankenstein)',
			'library.quadriceps.exercises.kneelingHipFlexorAndQuadricepsStretch' => 'Kneeling hip-flexor and quadriceps stretch',
			'library.quadriceps.exercises.frontSquatKettlebell' => 'Front squat (kettlebell)',
			'library.quadriceps.exercises.squatKettlebellGoblet' => 'Squat (kettlebell, goblet)',
			'library.quadriceps.exercises.lungeKettlebellPassThrough' => 'Lunge (kettlebell, pass through)',
			'library.quadriceps.exercises.squatKettlebellPistol' => 'Squat (kettlebell, pistol)',
			'library.quadriceps.exercises.kettlebellTurkishGetUpThroughSquat' => 'Kettlebell Turkish get-up through squat',
			'library.quadriceps.exercises.jumpSquatKneeling' => 'Jump squat (kneeling)',
			'library.quadriceps.exercises.lungeJump' => 'Lunge (jump)',
			'library.quadriceps.exercises.quadsStretchLyingSide' => 'Quads stretch (lying, side)',
			'library.quadriceps.exercises.squatOneLeg' => 'Squat (one leg)',
			'library.quadriceps.exercises.squatPottySupport' => 'Squat (potty, support)',
			'library.quadriceps.exercises.rapidAlternatingFootTaps' => 'Rapid alternating foot taps',
			'library.quadriceps.exercises.legExtensionResistanceBand' => 'Leg extension (resistance band)',
			'library.quadriceps.exercises.squatPistol' => 'Squat (pistol)',
			'library.quadriceps.exercises.sissySquat' => 'Sissy squat',
			'library.quadriceps.exercises.hackSquatSledCloser' => 'Hack squat (sled, closer)',
			'library.quadriceps.exercises.squatSledLying' => 'Squat (sled, lying)',
			'library.quadriceps.exercises.squatSmithChair' => 'Squat (smith, chair)',
			'library.quadriceps.exercises.frontSquatSmithCleanGrip' => 'Front squat (smith, clean grip)',
			'library.quadriceps.exercises.hackSquatSmith' => 'Hack squat (smith)',
			'library.quadriceps.exercises.squatSmithLowBar' => 'Squat (smith, low bar)',
			'library.quadriceps.exercises.splitSquatSmithOneLeg' => 'Split squat (smith, one leg)',
			'library.quadriceps.exercises.lungeSmithSprint' => 'Lunge (smith, sprint)',
			'library.quadriceps.exercises.squatSmithSumo' => 'Squat (smith, sumo)',
			'library.quadriceps.exercises.snatchPull' => 'Snatch pull',
			'library.quadriceps.exercises.splitSquat' => 'Split squat',
			'library.quadriceps.exercises.squatJerk' => 'Squat jerk',
			'library.quadriceps.exercises.squatBosuBall' => 'Squat (bosu ball)',
			'library.quadriceps.exercises.squatToOverheadReach' => 'Squat (to overhead reach)',
			'library.quadriceps.exercises.squatToOverheadReachTwist' => 'Squat (to overhead reach twist)',
			'library.quadriceps.exercises.splitSquatSuspended' => 'Split squat (suspended)',
			'library.quadriceps.exercises.lungeWalking' => 'Lunge (walking)',
			'library.quadriceps.exercises.squatWeightedCossack' => 'Squat (weighted, cossack)',
			'library.quadriceps.exercises.weightedLungeWithArmSwing' => 'Weighted lunge with arm swing',
			'library.quadriceps.exercises.sissySquatWeighted' => 'Sissy squat (weighted)',
			'library.quadriceps.exercises.squatWeighted' => 'Squat (weighted)',
			'library.quadriceps.exercises.lungeWeighted' => 'Lunge (weighted)',
			'library.hamstrings.name' => 'Hamstrings',
			'library.hamstrings.exercises.singleLegDumbbellRomanianDeadlift' => 'Single-leg dumbbell Romanian deadlift',
			'library.hamstrings.exercises.legCurlStanding' => 'Standing machine leg curl',
			'library.hamstrings.exercises.nordicCurl' => 'Nordic curl',
			'library.hamstrings.exercises.legCurlProne' => 'Leg curl (prone)',
			'library.hamstrings.exercises.legCurlSeated' => 'Leg curl (seated)',
			'library.hamstrings.exercises.romanianDeadlift' => 'Romanian deadlift (barbell)',
			'library.hamstrings.exercises.romanianDeadliftDumbbell' => 'Romanian deadlift (dumbbells)',
			'library.hamstrings.exercises.hamstringStretchAssistedProne' => 'Hamstring stretch (assisted, prone)',
			'library.hamstrings.exercises.straightLegDeadliftBand' => 'Straight leg deadlift (band)',
			'library.hamstrings.exercises.goodMorningBarbell' => 'Good morning (barbell)',
			'library.hamstrings.exercises.goodMorningBarbellSeated' => 'Good morning (barbell, seated)',
			'library.hamstrings.exercises.goodMorningBarbellStraightLeg' => 'Good morning (barbell, straight leg)',
			'library.hamstrings.exercises.straightLegDeadliftBarbell' => 'Straight leg deadlift (barbell)',
			'library.hamstrings.exercises.legCurlCableAssistedInverse' => 'Leg curl (cable, assisted, inverse)',
			'library.hamstrings.exercises.legCurlDumbbellLying' => 'Leg curl (dumbbell, lying)',
			'library.hamstrings.exercises.straightLegDeadliftDumbbell' => 'Straight leg deadlift (dumbbell)',
			'library.hamstrings.exercises.hamstringStretchExerciseBallSeated' => 'Hamstring stretch (exercise ball, seated)',
			'library.hamstrings.exercises.gluteHamRaiseOnBench' => 'Glute-ham raise on bench',
			'library.hamstrings.exercises.hamstringStretch' => 'Hamstring stretch',
			'library.hamstrings.exercises.hangCleanKettlebell' => 'Hang clean (kettlebell)',
			'library.hamstrings.exercises.elevatedLegHamstringStretch' => 'Elevated-leg hamstring stretch',
			'library.hamstrings.exercises.legCurlLeverKneeling' => 'Leg curl (lever, kneeling)',
			'library.hamstrings.exercises.legCurlLeverLyingTwoOne' => 'Leg curl (lever, lying, two one)',
			'library.hamstrings.exercises.goodMorningLeverSeated' => 'Good morning (lever, seated)',
			'library.hamstrings.exercises.cleanPower' => 'Clean (power)',
			'library.hamstrings.exercises.supineStrapAssistedHamstringStretch' => 'Supine strap-assisted hamstring stretch',
			'library.hamstrings.exercises.runnerSHamstringStretch' => 'Runner’s hamstring stretch',
			'library.hamstrings.exercises.seatedWideLegForwardFoldSequence' => 'Seated wide-leg forward-fold sequence',
			'library.hamstrings.exercises.singleLegSlidingCurl' => 'Single-leg sliding curl',
			'library.hamstrings.exercises.goodMorningSmithBentKnee' => 'Good morning (smith, bent knee)',
			'library.hamstrings.exercises.strapAssistedHamstringAndCalfStretch' => 'Strap-assisted hamstring and calf stretch',
			'library.hamstrings.exercises.legCurlStandingBodyweight' => 'Leg curl (standing)',
			'library.hamstrings.exercises.lungeStretchWithThoracicRotation' => 'Lunge stretch with thoracic rotation',
			'library.shoulders.name' => 'Shoulders',
			'library.shoulders.exercises.standingCableReverseFly' => 'Standing cable reverse fly',
			'library.shoulders.exercises.cableFrontRaise' => 'Cable front raise',
			'library.shoulders.exercises.dumbbellShrugs' => 'Dumbbell shrugs',
			'library.shoulders.exercises.facePull' => 'Cable face pull',
			'library.shoulders.exercises.shoulderPressMachine' => 'Shoulder press (machine)',
			'library.shoulders.exercises.latRaisesInclinedBench' => 'Lateral raises (inclined bench)',
			'library.shoulders.exercises.latRaisesCable' => 'Lateral raises (cable)',
			'library.shoulders.exercises.latRaisesDualCable' => 'Lateral raises (cable, both arms)',
			'library.shoulders.exercises.reverseFlysInclinedBench' => 'Reverse flyes (inclined bench)',
			'library.shoulders.exercises.arnoldPress' => 'Arnold press',
			'library.shoulders.exercises.frontDumbbellRaise' => 'Front dumbbell raise',
			'library.shoulders.exercises.uprightRow' => 'Upright row',
			'library.shoulders.exercises.pikePushUps' => 'Pike push-ups',
			'library.shoulders.exercises.handstandPushUps' => 'Handstand push-ups',
			'library.shoulders.exercises.bentOverLateralRaises' => 'Bent-over cable reverse fly',
			'library.shoulders.exercises.shoulderPress' => 'Dumbbell shoulder press',
			'library.shoulders.exercises.latRaisesDumbbells' => 'Lateral raises (dumbbells)',
			'library.shoulders.exercises.deltoidMachine' => 'Deltoid machine',
			'library.shoulders.exercises.shrugsBarbell' => 'Front shrugs (barbell)',
			'library.shoulders.exercises.militaryPressSmithMachine' => 'Smith machine military press',
			'library.shoulders.exercises.reverseButterfly' => 'Reverse pec deck fly',
			'library.shoulders.exercises.militaryPressBarbell' => 'Barbell military press',
			'library.shoulders.exercises.frontLateralRaiseBand' => 'Front lateral raise (band)',
			'library.shoulders.exercises.frontRaiseBand' => 'Front raise (band)',
			'library.shoulders.exercises.reverseFlyBand' => 'Reverse fly (band)',
			'library.shoulders.exercises.shoulderPressBand' => 'Shoulder press (band)',
			'library.shoulders.exercises.shrugBand' => 'Shrug (band)',
			'library.shoulders.exercises.rearDeltRowBandStanding' => 'Rear delt row (band, standing)',
			'library.shoulders.exercises.overheadPressBandTwisting' => 'Overhead press (band, twisting)',
			'library.shoulders.exercises.yRaiseBand' => 'Y raise (band)',
			'library.shoulders.exercises.frontRaiseBarbell' => 'Front raise (barbell)',
			'library.shoulders.exercises.frontRaiseAndPulloverBarbell' => 'Front raise and pullover (barbell)',
			'library.shoulders.exercises.shoulderPressBarbellIncline' => 'Shoulder press (barbell, incline)',
			'library.shoulders.exercises.snatchBarbellOneArm' => 'Snatch (barbell, one arm)',
			'library.shoulders.exercises.rearDeltRaiseBarbell' => 'Rear delt raise (barbell)',
			'library.shoulders.exercises.rearDeltRowBarbell' => 'Rear delt row (barbell)',
			'library.shoulders.exercises.militaryPressBarbellSeatedBehindHead' => 'Military press (barbell, seated, behind head)',
			'library.shoulders.exercises.bradfordPressBarbellSeated' => 'Bradford press (barbell, seated)',
			'library.shoulders.exercises.barbellSkiStyleHighPull' => 'Barbell ski-style high pull',
			'library.shoulders.exercises.bradfordPressBarbellStanding' => 'Bradford press (barbell, standing)',
			'library.shoulders.exercises.militaryPressBarbellStandingCloseGrip' => 'Military press (barbell, standing, close grip)',
			'library.shoulders.exercises.frontRaiseBarbellStandingOverHead' => 'Front raise (barbell, standing, over head)',
			'library.shoulders.exercises.militaryPressBarbellStandingWide' => 'Military press (barbell, standing, wide)',
			'library.shoulders.exercises.thrusterBarbell' => 'Thruster (barbell)',
			'library.shoulders.exercises.uprightRowBarbellWideGrip' => 'Upright row (barbell, wide grip)',
			'library.shoulders.exercises.battlingRopes' => 'Battling ropes',
			'library.shoulders.exercises.shoulderPressCableAlternate' => 'Shoulder press (cable, alternate)',
			'library.shoulders.exercises.rearDeltRowCableKneelingRope' => 'Rear delt row (cable, kneeling, rope)',
			'library.shoulders.exercises.reverseFlyCableOneArmBentOver' => 'Reverse fly (cable, one arm, bent over)',
			'library.shoulders.exercises.rearDeltRowCableStirrups' => 'Rear delt row (cable, stirrups)',
			'library.shoulders.exercises.rearDeltRowCableRope' => 'Rear delt row (cable, rope)',
			'library.shoulders.exercises.rearLateralRaiseCableSeated' => 'Rear lateral raise (cable, seated)',
			'library.shoulders.exercises.shoulderInternalRotationCableSeated' => 'Shoulder internal rotation (cable, seated)',
			'library.shoulders.exercises.shoulderPressCable' => 'Shoulder press (cable)',
			'library.shoulders.exercises.shrugCable' => 'Shrug (cable)',
			'library.shoulders.exercises.rearDeltRowCableStandingRope' => 'Rear delt row (cable, standing, rope)',
			'library.shoulders.exercises.shoulderExternalRotationCableStanding' => 'Shoulder external rotation (cable, standing)',
			'library.shoulders.exercises.reverseFlyCableSupine' => 'Reverse fly (cable, supine)',
			'library.shoulders.exercises.uprightRowCable' => 'Upright row (cable)',
			'library.shoulders.exercises.pressDumbbellAlternateSide' => 'Press (dumbbell, alternate, side)',
			'library.shoulders.exercises.cubanPressDumbbell' => 'Cuban press (dumbbell)',
			'library.shoulders.exercises.shrugDumbbellDecline' => 'Shrug (dumbbell, decline)',
			'library.shoulders.exercises.lateralRaiseDumbbellFullCan' => 'Lateral raise (dumbbell, full can)',
			'library.shoulders.exercises.shoulderPressDumbbellIncline' => 'Shoulder press (dumbbell, incline)',
			'library.shoulders.exercises.shrugDumbbellIncline' => 'Shrug (dumbbell, incline)',
			'library.shoulders.exercises.tRaiseDumbbellIncline' => 'T raise (dumbbell, incline)',
			'library.shoulders.exercises.lateralToFrontRaiseDumbbell' => 'Lateral to front raise (dumbbell)',
			'library.shoulders.exercises.externalShoulderRotationDumbbellLying' => 'External shoulder rotation (dumbbell, lying)',
			'library.shoulders.exercises.rearDeltRaiseDumbbellLyingFloor' => 'Rear delt raise (dumbbell, lying, floor)',
			'library.shoulders.exercises.rearDeltRaiseDumbbellLyingOneArm' => 'Rear delt raise (dumbbell, lying, one arm)',
			'library.shoulders.exercises.reverseFlyDumbbellLyingOneArm' => 'Reverse fly (dumbbell, lying, one arm)',
			'library.shoulders.exercises.rearDeltRowDumbbellLying' => 'Rear delt row (dumbbell, lying)',
			'library.shoulders.exercises.reverseFlyDumbbellLying' => 'Reverse fly (dumbbell, lying)',
			'library.shoulders.exercises.lateralRaiseDumbbellOneArm' => 'Lateral raise (dumbbell, one arm)',
			'library.shoulders.exercises.lateralRaiseDumbbellOneArmSupport' => 'Lateral raise (dumbbell, one arm, support)',
			'library.shoulders.exercises.reverseFlyDumbbellOneArmSupport' => 'Reverse fly (dumbbell, one arm, support)',
			'library.shoulders.exercises.shoulderPressDumbbellOneArm' => 'Shoulder press (dumbbell, one arm)',
			'library.shoulders.exercises.uprightRowDumbbellOneArm' => 'Upright row (dumbbell, one arm)',
			'library.shoulders.exercises.pushPressDumbbell' => 'Push press (dumbbell)',
			'library.shoulders.exercises.reverseFlyDumbbellBentOver' => 'Reverse fly (dumbbell, bent over)',
			'library.shoulders.exercises.rearDeltRowDumbbell' => 'Rear delt row (dumbbell)',
			'library.shoulders.exercises.rearLateralRaiseDumbbellSupportHead' => 'Rear lateral raise (dumbbell, support head)',
			'library.shoulders.exercises.reverseFlyDumbbellRotation' => 'Reverse fly (dumbbell, rotation)',
			'library.shoulders.exercises.scottPressDumbbell' => 'Scott press (dumbbell)',
			'library.shoulders.exercises.frontRaiseDumbbellSeatedAlternate' => 'Front raise (dumbbell, seated, alternate)',
			'library.shoulders.exercises.shoulderPressDumbbellSeatedAlternate' => 'Shoulder press (dumbbell, seated, alternate)',
			'library.shoulders.exercises.lateralRaiseDumbbellSeatedBentArm' => 'Lateral raise (dumbbell, seated, bent arm)',
			'library.shoulders.exercises.bicepsCurlToShoulderPressDumbbellSeated' => 'Biceps curl to shoulder press (dumbbell, seated)',
			'library.shoulders.exercises.frontRaiseDumbbellSeated' => 'Front raise (dumbbell, seated)',
			'library.shoulders.exercises.lateralRaiseDumbbellSeated' => 'Lateral raise (dumbbell, seated)',
			'library.shoulders.exercises.shoulderPressDumbbellSeatedNeutralGrip' => 'Shoulder press (dumbbell, seated, neutral grip)',
			'library.shoulders.exercises.lateralRaiseDumbbellSideLyingOneArm' => 'Lateral raise (dumbbell, side lying, one arm)',
			'library.shoulders.exercises.reverseFlyDumbbellSidePlank' => 'Reverse fly (dumbbell, side plank)',
			'library.shoulders.exercises.singleArmOverheadDumbbellCarry' => 'Single-arm overhead dumbbell carry',
			'library.shoulders.exercises.overheadPressDumbbellStandingAlternate' => 'Overhead press (dumbbell, standing, alternate)',
			'library.shoulders.exercises.lateralRaiseDumbbellStandingAlternate' => 'Lateral raise (dumbbell, standing, alternate)',
			'library.shoulders.exercises.standingDumbbellArmCircles' => 'Standing dumbbell arm circles',
			'library.shoulders.exercises.frontRaiseDumbbellStandingAboveHead' => 'Front raise (dumbbell, standing, above head)',
			'library.shoulders.exercises.pressDumbbellStandingOneArmNeutralGrip' => 'Press (dumbbell, standing, one arm, neutral grip)',
			'library.shoulders.exercises.overheadPressDumbbellStanding' => 'Overhead press (dumbbell, standing)',
			'library.shoulders.exercises.pressDumbbellStandingNeutralGrip' => 'Press (dumbbell, standing, neutral grip)',
			'library.shoulders.exercises.uprightRowDumbbell' => 'Upright row (dumbbell)',
			'library.shoulders.exercises.shoulderExternalRotationDumbbellUpright' => 'Shoulder external rotation (dumbbell, upright)',
			'library.shoulders.exercises.wPressDumbbell' => 'W press (dumbbell)',
			'library.shoulders.exercises.frontRaiseDumbbellSeatedAlternateExerciseBall' => 'Front raise (dumbbell, seated, alternate, exercise ball)',
			'library.shoulders.exercises.shoulderPressEzBarbell' => 'Shoulder press (ez barbell)',
			'library.shoulders.exercises.frogStand' => 'Frog stand',
			'library.shoulders.exercises.fullMalteseHold' => 'Full Maltese hold',
			'library.shoulders.exercises.fullPlancheHold' => 'Full planche hold',
			'library.shoulders.exercises.pushUpFullPlanche' => 'Push-up (full, planche)',
			'library.shoulders.exercises.handstand' => 'Handstand',
			'library.shoulders.exercises.pressKettlebellAlternate' => 'Press (kettlebell, alternate)',
			'library.shoulders.exercises.arnoldPressKettlebell' => 'Arnold press (kettlebell)',
			'library.shoulders.exercises.jerkKettlebellDouble' => 'Jerk (kettlebell, double)',
			'library.shoulders.exercises.pushPressKettlebellDouble' => 'Push press (kettlebell, double)',
			'library.shoulders.exercises.snatchKettlebellDouble' => 'Snatch (kettlebell, double)',
			'library.shoulders.exercises.cleanAndJerkKettlebellOneArm' => 'Clean and jerk (kettlebell, one arm)',
			'library.shoulders.exercises.jerkKettlebellOneArm' => 'Jerk (kettlebell, one arm)',
			'library.shoulders.exercises.militaryPressKettlebellOneArmToSide' => 'Military press (kettlebell, one arm, to side)',
			'library.shoulders.exercises.pushPressKettlebellOneArm' => 'Push press (kettlebell, one arm)',
			'library.shoulders.exercises.snatchKettlebellOneArm' => 'Snatch (kettlebell, one arm)',
			'library.shoulders.exercises.cleanAndPressKettlebellOneArm' => 'Clean and press (kettlebell, one arm)',
			'library.shoulders.exercises.pressKettlebellSeated' => 'Press (kettlebell, seated)',
			'library.shoulders.exercises.militaryPressKettlebellSeatedTwoArm' => 'Military press (kettlebell, seated, two arm)',
			'library.shoulders.exercises.pressKettlebellSeesaw' => 'Press (kettlebell, seesaw)',
			'library.shoulders.exercises.sumoHighPullKettlebell' => 'Sumo high pull (kettlebell)',
			'library.shoulders.exercises.thrusterKettlebell' => 'Thruster (kettlebell)',
			'library.shoulders.exercises.cleanKettlebellTwoArm' => 'Clean (kettlebell, two arm)',
			'library.shoulders.exercises.militaryPressKettlebellTwoArm' => 'Military press (kettlebell, two arm)',
			'library.shoulders.exercises.lateralRaiseLandmine' => 'Lateral raise (landmine)',
			'library.shoulders.exercises.plancheLean' => 'Planche (lean)',
			'library.shoulders.exercises.boxingLeftHook' => 'Boxing left hook',
			'library.shoulders.exercises.shrugLeverGripless' => 'Shrug (lever, gripless)',
			'library.shoulders.exercises.shoulderPressLeverOneArm' => 'Shoulder press (lever, one arm)',
			'library.shoulders.exercises.reverseFlyLeverSeatedNeutralGrip' => 'Reverse fly (lever, seated, neutral grip)',
			'library.shoulders.exercises.shrugLever' => 'Shrug (lever)',
			'library.shoulders.exercises.rearDeltoidStretch' => 'Rear deltoid stretch',
			'library.shoulders.exercises.shoulderPressResistanceBandSeated' => 'Shoulder press (resistance band, seated)',
			'library.shoulders.exercises.scapularDips' => 'Scapular dips',
			'library.shoulders.exercises.scapularPullUp' => 'Scapular pull up',
			'library.shoulders.exercises.shrugSmithBack' => 'Shrug (smith, back)',
			'library.shoulders.exercises.pressSmithBehindNeck' => 'Press (smith, behind neck)',
			'library.shoulders.exercises.rearDeltRowSmith' => 'Rear delt row (smith)',
			'library.shoulders.exercises.shoulderPressSmithSeated' => 'Shoulder press (smith, seated)',
			'library.shoulders.exercises.shoulderPressSmith' => 'Shoulder press (smith)',
			'library.shoulders.exercises.shrugSmith' => 'Shrug (smith)',
			'library.shoulders.exercises.militaryPressSmithStandingBehindHead' => 'Military press (smith, standing, behind head)',
			'library.shoulders.exercises.uprightRowSmith' => 'Upright row (smith)',
			'library.shoulders.exercises.pressStandingBehindNeck' => 'Press (standing, behind neck)',
			'library.shoulders.exercises.straddleMalteseHold' => 'Straddle Maltese hold',
			'library.shoulders.exercises.straddlePlancheHold' => 'Straddle planche hold',
			'library.shoulders.exercises.frontRaiseWeighted' => 'Front raise (weighted)',
			'library.shoulders.exercises.weightedKneelingStepAndSwing' => 'Weighted kneeling step and swing',
			'library.back.name' => 'Back',
			'library.back.exercises.chestSupportedDumbbellRow' => 'Chest-supported dumbbell row',
			'library.back.exercises.singleArmCableRow' => 'Single-arm cable row',
			'library.back.exercises.ringRow' => 'Ring row',
			'library.back.exercises.dumbbellPullover' => 'Dumbbell pullover',
			'library.back.exercises.machineAssistedPullUps' => 'Machine-assisted pull-ups',
			'library.back.exercises.hyperExtensions' => 'Hyperextensions',
			'library.back.exercises.weightedHyperExtensions' => 'Hyperextensions (weighted)',
			'library.back.exercises.barbellRow' => 'Barbell row',
			'library.back.exercises.triangleBarLatPulldowns' => 'Lat pulldowns (triangle bar)',
			'library.back.exercises.underhandGripLatPulldowns' => 'Lat pulldowns (underhand grip)',
			'library.back.exercises.latPulldowns' => 'Lat pulldowns',
			'library.back.exercises.cableSeatedRowTriangleBar' => 'Cable seated row (triangle bar)',
			'library.back.exercises.straightArmCablePushdown' => 'Straight-arm cable pushdowns',
			'library.back.exercises.deadlift' => 'Deadlift',
			'library.back.exercises.pullUps' => 'Pull-ups',
			'library.back.exercises.tBarRow' => 'T-Bar row',
			'library.back.exercises.rowMachine' => 'Seated row machine',
			'library.back.exercises.latPulldownsWideGrip' => 'Lat pulldowns (wide grip)',
			'library.back.exercises.latPulldownsNarrowGrip' => 'Lat pulldowns (narrow grip)',
			'library.back.exercises.tBarRowWideProneGrip' => 'T-bar machine row (wide overhand grip)',
			'library.back.exercises.dumbbellRow' => 'Dumbbell row',
			'library.back.exercises.chinUps' => 'Chin-ups',
			'library.back.exercises.pulldownCableAlternate' => 'Pulldown (cable, alternate)',
			'library.back.exercises.pullUpArcher' => 'Pull-up (archer)',
			'library.back.exercises.pullUpAssistedParallelCloseGrip' => 'Pull-up (assisted, parallel, close grip)',
			'library.back.exercises.chinUpAssistedStanding' => 'Chin-up (assisted, standing)',
			'library.back.exercises.pullUpAssistedStanding' => 'Pull-up (assisted, standing)',
			'library.back.exercises.backExtensionExerciseBall' => 'Back extension (exercise ball)',
			'library.back.exercises.backLever' => 'Back lever',
			'library.back.exercises.chestStretchWithArmsBehindTheBack' => 'Chest stretch with arms behind the back',
			'library.back.exercises.pullUpBandAssisted' => 'Pull-up (band, assisted)',
			'library.back.exercises.pulldownBandCloseGrip' => 'Pulldown (band, close grip)',
			'library.back.exercises.pulldownBandFixedBackCloseGrip' => 'Pulldown (band, fixed back, close grip)',
			'library.back.exercises.pulldownBandFixedBackUnderhand' => 'Pulldown (band, fixed back, underhand)',
			'library.back.exercises.pulldownBandKneelingOneArm' => 'Pulldown (band, kneeling, one arm)',
			'library.back.exercises.rowBandOneArmStandingLow' => 'Row (band, one arm, standing, low)',
			'library.back.exercises.rowBandOneArmTwistingSeated' => 'Row (band, one arm, twisting, seated)',
			'library.back.exercises.pulldownBandUnderhand' => 'Pulldown (band, underhand)',
			'library.back.exercises.pulloverBarbellBentArm' => 'Pullover (barbell, bent arm)',
			'library.back.exercises.pulloverBarbellDeclineBentArm' => 'Pullover (barbell, decline, bent arm)',
			'library.back.exercises.pulloverBarbellDeclineWideGrip' => 'Pullover (barbell, decline, wide grip)',
			'library.back.exercises.rowBarbellIncline' => 'Row (barbell, incline)',
			'library.back.exercises.bentOverRowBarbellOneArm' => 'Bent over row (barbell, one arm)',
			'library.back.exercises.pendlayRowBarbell' => 'Pendlay row (barbell)',
			'library.back.exercises.pulloverBarbell' => 'Pullover (barbell)',
			'library.back.exercises.pulloverToPressBarbell' => 'Pullover to press (barbell)',
			'library.back.exercises.bentOverRowBarbellReverseGrip' => 'Bent over row (barbell, reverse grip)',
			'library.back.exercises.benchRowBarbellReverseGripIncline' => 'Bench row (barbell, reverse grip, incline)',
			'library.back.exercises.benchSupportedPullUp' => 'Bench-supported pull-up',
			'library.back.exercises.rowBodyweightSquatting' => 'Row (bodyweight, squatting)',
			'library.back.exercises.rowBodyweightSquattingTowel' => 'Row (bodyweight, squatting, towel)',
			'library.back.exercises.rowBodyweightStandingCloseGripOneArm' => 'Row (bodyweight, standing, close grip, one arm)',
			'library.back.exercises.rowBodyweightStandingCloseGrip' => 'Row (bodyweight, standing, close grip)',
			'library.back.exercises.rowBodyweightStandingOneArm' => 'Row (bodyweight, standing, one arm)',
			'library.back.exercises.rowBodyweightStandingOneArmTowel' => 'Row (bodyweight, standing, one arm, towel)',
			'library.back.exercises.rowBodyweightStanding' => 'Row (bodyweight, standing)',
			'library.back.exercises.rowBodyweightStandingTowel' => 'Row (bodyweight, standing, towel)',
			'library.back.exercises.latPulldownCableCrossover' => 'Lat pulldown (cable, crossover)',
			'library.back.exercises.rowCableDeclineSeatedWideGrip' => 'Row (cable, decline, seated, wide grip)',
			'library.back.exercises.rowCableFloorSeatedWideGrip' => 'Row (cable, floor, seated, wide grip)',
			'library.back.exercises.rowCableHighKneeling' => 'Row (cable, high, kneeling)',
			'library.back.exercises.benchRowCableIncline' => 'Bench row (cable, incline)',
			'library.back.exercises.latPulldownCableRope' => 'Lat pulldown (cable, rope)',
			'library.back.exercises.rowCableSeated' => 'Row (cable, seated)',
			'library.back.exercises.pulloverCableLyingRope' => 'Pullover (cable, lying, rope)',
			'library.back.exercises.pulldownCableOneArm' => 'Pulldown (cable, one arm)',
			'library.back.exercises.rowCableOneArmStraightBackHighKneeling' => 'Row (cable, one arm, straight back, high, kneeling)',
			'library.back.exercises.rowCablePalmRotational' => 'Row (cable, palm rotational)',
			'library.back.exercises.latPulldownWithCurvedBar' => 'Lat pulldown with curved bar',
			'library.back.exercises.pulldownCableRear' => 'Pulldown (cable, rear)',
			'library.back.exercises.rowCableReverseGripStraightBackSeatedHigh' => 'Row (cable, reverse grip, straight back, seated, high)',
			'library.back.exercises.rowCableRopeCrossoverSeated' => 'Row (cable, rope, crossover, seated)',
			'library.back.exercises.rowCableRopeElevatedSeated' => 'Row (cable, rope, elevated, seated)',
			'library.back.exercises.benchRowCableRopeExtensionIncline' => 'Bench row (cable, rope, extension, incline)',
			'library.back.exercises.rowCableRopeSeated' => 'Row (cable, rope, seated)',
			'library.back.exercises.rowCableSeatedOneArmAlternate' => 'Row (cable, seated, one arm, alternate)',
			'library.back.exercises.rowCableSeatedWideGrip' => 'Row (cable, seated, wide grip)',
			'library.back.exercises.squatRowCableRope' => 'Squat row (cable, rope)',
			'library.back.exercises.rowCableStandingVBar' => 'Row (cable, standing, v bar)',
			'library.back.exercises.twistRowCableStandingVBar' => 'Twist row (cable, standing, v bar)',
			'library.back.exercises.cableKayakRow' => 'Cable kayak row',
			'library.back.exercises.twistRowCableOneArm' => 'Twist row (cable, one arm)',
			'library.back.exercises.rowCableUpper' => 'Row (cable, upper)',
			'library.back.exercises.pulldownCableWideGripRearBehindNeck' => 'Pulldown (cable, wide grip, rear, behind neck)',
			'library.back.exercises.rowCamberedBarLying' => 'Row (cambered bar, lying)',
			'library.back.exercises.closeNeutralGripPullUp' => 'Close neutral-grip pull-up',
			'library.back.exercises.bentOverRowDumbbell' => 'Bent over row (dumbbell)',
			'library.back.exercises.yRaiseDumbbellIncline' => 'Y raise (dumbbell, incline)',
			'library.back.exercises.bentOverRowDumbbellPalmRotational' => 'Bent over row (dumbbell, palm rotational)',
			'library.back.exercises.rowDumbbellReverseGripInclineBenchOneArm' => 'Row (dumbbell, reverse grip, incline bench, one arm)',
			'library.back.exercises.rowDumbbellReverseGripInclineBenchTwoArm' => 'Row (dumbbell, reverse grip, incline bench, two arm)',
			'library.back.exercises.rowDumbbellReverseGrip' => 'Row (dumbbell, reverse grip)',
			'library.back.exercises.bodyweightHipHinge' => 'Bodyweight hip hinge',
			'library.back.exercises.backExtensionExerciseBallStraightArm' => 'Back extension (exercise ball, straight arm)',
			'library.back.exercises.backExtensionExerciseBallHandsBehindHead' => 'Back extension (exercise ball, hands behind head)',
			'library.back.exercises.backExtensionExerciseBallKneeOffGround' => 'Back extension (exercise ball, knee off ground)',
			'library.back.exercises.backExtensionExerciseBallRotation' => 'Back extension (exercise ball, rotation)',
			'library.back.exercises.seatedBackStretchHuggingABall' => 'Seated back stretch hugging a ball',
			'library.back.exercises.latStretchExerciseBall' => 'Lat stretch (exercise ball)',
			'library.back.exercises.pyramidPositionBackStretchOnBall' => 'Pyramid-position back stretch on ball',
			'library.back.exercises.latStretchExerciseBallLyingSide' => 'Lat stretch (exercise ball, lying, side)',
			'library.back.exercises.legRaiseExerciseBallProne' => 'Leg raise (exercise ball, prone)',
			'library.back.exercises.pulloverEzBarLyingBentArm' => 'Pullover (ez bar, lying, bent arm)',
			'library.back.exercises.bentOverRowEzBarReverseGrip' => 'Bent over row (ez bar, reverse grip)',
			'library.back.exercises.frontLever' => 'Front lever',
			'library.back.exercises.frontLeverReps' => 'Front lever (reps)',
			'library.back.exercises.sternumToBarChinUp' => 'Sternum-to-bar chin-up',
			'library.back.exercises.invertedRow' => 'Inverted row',
			'library.back.exercises.invertedRowBentKnee' => 'Inverted row (bent knee)',
			'library.back.exercises.invertedRowBench' => 'Inverted row (bench)',
			'library.back.exercises.renegadeRowKettlebellAlternate' => 'Renegade row (kettlebell, alternate)',
			'library.back.exercises.rowKettlebellAlternate' => 'Row (kettlebell, alternate)',
			'library.back.exercises.rowKettlebellOneArm' => 'Row (kettlebell, one arm)',
			'library.back.exercises.rowKettlebellTwoArm' => 'Row (kettlebell, two arm)',
			'library.back.exercises.muscleUpKipping' => 'Muscle up (kipping)',
			'library.back.exercises.latStretchKneeling' => 'Lat stretch (kneeling)',
			'library.back.exercises.pullUpL' => 'Pull-up (l)',
			'library.back.exercises.rowLeverAlternateNarrowGripSeated' => 'Row (lever, alternate, narrow grip, seated)',
			'library.back.exercises.chinUpLeverAssisted' => 'Chin-up (lever, assisted)',
			'library.back.exercises.backExtensionLever' => 'Back extension (lever)',
			'library.back.exercises.bentOverRowLever' => 'Bent over row (lever)',
			'library.back.exercises.bentOverRowLeverVBar' => 'Bent over row (lever, v bar)',
			'library.back.exercises.pulldownLeverFront' => 'Pulldown (lever, front)',
			'library.back.exercises.rowLeverHigh' => 'Row (lever, high)',
			'library.back.exercises.bentOverRowLeverOneArm' => 'Bent over row (lever, one arm)',
			'library.back.exercises.rowLeverOneArmLateralHigh' => 'Row (lever, one arm, lateral, high)',
			'library.back.exercises.pulldownLeverOneArmLateralWide' => 'Pulldown (lever, one arm, lateral, wide)',
			'library.back.exercises.pulloverLever' => 'Pullover (lever)',
			'library.back.exercises.latPulldownLeverReverseGrip' => 'Lat pulldown (lever, reverse grip)',
			'library.back.exercises.rowLeverReverseGripVertical' => 'Row (lever, reverse grip, vertical)',
			'library.back.exercises.rowLeverReverseTBar' => 'Row (lever, reverse, t bar)',
			'library.back.exercises.rowLeverTBar' => 'Row (lever, t bar)',
			'library.back.exercises.rowLeverTBarReverseGrip' => 'Row (lever, t bar, reverse grip)',
			'library.back.exercises.rowLeverOneArm' => 'Row (lever, one arm)',
			'library.back.exercises.standingAnchoredRopeRow' => 'Standing anchored-rope row',
			'library.back.exercises.seatedSpinalFlexion' => 'Seated spinal flexion',
			'library.back.exercises.medicineBallCatchAndOverheadToss' => 'Medicine-ball catch and overhead toss',
			'library.back.exercises.overheadMedicineBallSlam' => 'Overhead medicine-ball slam',
			'library.back.exercises.chinUpMixedGrip' => 'Chin-up (mixed grip)',
			'library.back.exercises.muscleUp' => 'Muscle up',
			'library.back.exercises.muscleUpVerticalBar' => 'Muscle up (vertical, bar)',
			'library.back.exercises.neckStretchSide' => 'Neck stretch (side)',
			'library.back.exercises.singleArmWallLatStretch' => 'Single-arm wall lat stretch',
			'library.back.exercises.chinUpOneArm' => 'Chin-up (one arm)',
			'library.back.exercises.rowOneArmTowel' => 'Row (one arm, towel)',
			'library.back.exercises.pullUpNeutralGrip' => 'Pull-up (neutral grip)',
			'library.back.exercises.pullUpRear' => 'Pull-up (rear)',
			'library.back.exercises.rowResistanceBandSeatedStraightBack' => 'Row (resistance band, seated, straight back)',
			'library.back.exercises.pulldownLeverReverseGrip' => 'Pulldown (lever, reverse grip)',
			'library.back.exercises.alternatingFrontAndBackPullUp' => 'Alternating front-and-back pull-up',
			'library.back.exercises.backStretchRoller' => 'Back stretch (roller)',
			'library.back.exercises.latStretchRollerSide' => 'Lat stretch (roller, side)',
			'library.back.exercises.ropeClimbing' => 'Rope climbing',
			'library.back.exercises.lowerBackStretchSeated' => 'Lower back stretch (seated)',
			'library.back.exercises.latStretchSideLyingFloor' => 'Lat stretch (side lying, floor)',
			'library.back.exercises.neckStretchSidePush' => 'Neck stretch (side, push)',
			'library.back.exercises.sideToSideChinUp' => 'Side-to-side chin-up',
			'library.back.exercises.skinTheCatRotation' => 'Skin-the-cat rotation',
			'library.back.exercises.bentOverRowSmith' => 'Bent over row (smith)',
			'library.back.exercises.rowSmithNarrow' => 'Row (smith, narrow)',
			'library.back.exercises.rowSmithOneArm' => 'Row (smith, one arm)',
			'library.back.exercises.bentOverRowSmithReverseGrip' => 'Bent over row (smith, reverse grip)',
			'library.back.exercises.proneSphinxStretch' => 'Prone sphinx stretch',
			'library.back.exercises.spineStretch' => 'Spine stretch',
			'library.back.exercises.standingArcherPull' => 'Standing archer pull',
			'library.back.exercises.latStretchStandingLateral' => 'Lat stretch (standing, lateral)',
			'library.back.exercises.pelvicTiltStanding' => 'Pelvic tilt (standing)',
			'library.back.exercises.pulldownCableNeutralGrip' => 'Pulldown (cable, neutral grip)',
			'library.back.exercises.forwardFoldReachingBothToes' => 'Forward fold reaching both toes',
			'library.back.exercises.upperBackStretch' => 'Upper back stretch',
			'library.back.exercises.upwardFacingDogStretch' => 'Upward-facing dog stretch',
			'library.back.exercises.chinUpWeightedCloseGripDipCage' => 'Chin-up (weighted, close grip, dip cage)',
			'library.back.exercises.hyperextensionWeightedStabilityBall' => 'Hyperextension (weighted, stability ball)',
			'library.back.exercises.muscleUpWeighted' => 'Muscle up (weighted)',
			'library.back.exercises.muscleUpWeightedBar' => 'Muscle up (weighted, bar)',
			'library.back.exercises.pullUpWeightedOneArm' => 'Pull-up (weighted, one arm)',
			'library.back.exercises.pullUpWeighted' => 'Pull-up (weighted)',
			'library.back.exercises.pullUpWideGrip' => 'Pull-up (wide grip)',
			'library.back.exercises.pullUpWideGripRear' => 'Pull-up (wide grip, rear)',
			'library.back.exercise.dualLowRowMachine' => 'Dual low row machine',
			'library.back.exercise.dualHighRowMachine' => 'Dual high row machine',
			'library.triceps.name' => 'Triceps',
			'library.triceps.exercises.barTricepsPushdown' => 'Bar triceps pushdown',
			'library.triceps.exercises.singleArmTricepsPushdown' => 'Single-arm triceps pushdown',
			'library.triceps.exercises.machineAssistedDips' => 'Machine-assisted dips',
			'library.triceps.exercises.dips' => 'Dips',
			'library.triceps.exercises.overheadRopeTricepExtension' => 'Overhead rope triceps extension',
			'library.triceps.exercises.tricepsRopePushdown' => 'Triceps rope pushdown',
			'library.triceps.exercises.tricepKickbacks' => 'Triceps kickbacks',
			'library.triceps.exercises.skullCrushers' => 'Skull crushers',
			'library.triceps.exercises.benchDips' => 'Dips (bench)',
			'library.triceps.exercises.diamondPushUps' => 'Diamond push-ups',
			'library.triceps.exercises.tricepsMachine' => 'Triceps machine',
			'library.triceps.exercises.overheadTricepExtension' => 'Dumbbell overhead triceps extension',
			'library.triceps.exercises.tricepsExtensionAssistedStandingTowel' => 'Triceps extension (assisted, standing, towel)',
			'library.triceps.exercises.pushUpBandCloseGrip' => 'Push-up (band, close grip)',
			'library.triceps.exercises.tricepsExtensionBandSide' => 'Triceps extension (band, side)',
			'library.triceps.exercises.benchPressBarbellCloseGrip' => 'Bench press (barbell, close grip)',
			'library.triceps.exercises.declineCloseGripPressIntoSkullCrusher' => 'Decline close-grip press into skull crusher',
			'library.triceps.exercises.benchPressBarbellInclineCloseGrip' => 'Bench press (barbell, incline, close grip)',
			'library.triceps.exercises.pressBarbellInclineReverseGrip' => 'Press (barbell, incline, reverse grip)',
			'library.triceps.exercises.tricepsExtensionBarbellLyingBackOfHead' => 'Triceps extension (barbell, lying, back of head)',
			'library.triceps.exercises.floorPressBarbellOneArm' => 'Floor press (barbell, one arm)',
			'library.triceps.exercises.pinPressesBarbell' => 'Pin presses (barbell)',
			'library.triceps.exercises.benchPressBarbellReverseCloseGrip' => 'Bench press (barbell, reverse, close grip)',
			'library.triceps.exercises.skullcrusherBarbellReverseGrip' => 'Skullcrusher (barbell, reverse grip)',
			'library.triceps.exercises.tricepsExtensionBarbellSeatedCloseGripBehindNeck' => 'Triceps extension (barbell, seated, close grip, behind neck)',
			'library.triceps.exercises.tricepsExtensionBarbellSeatedOverhead' => 'Triceps extension (barbell, seated, overhead)',
			'library.triceps.exercises.tricepsExtensionBarbellStandingOverhead' => 'Triceps extension (barbell, standing, overhead)',
			'library.triceps.exercises.tricepsExtensionBodyweightKneeling' => 'Triceps extension (bodyweight, kneeling)',
			'library.triceps.exercises.tricepsExtensionCableAlternate' => 'Triceps extension (cable, alternate)',
			'library.triceps.exercises.extensionCableConcentrationKnee' => 'Extension (cable, concentration, knee)',
			'library.triceps.exercises.tricepsExtensionCableHighPulleyOverhead' => 'Triceps extension (cable, high pulley, overhead)',
			'library.triceps.exercises.tricepsExtensionCableIncline' => 'Triceps extension (cable, incline)',
			'library.triceps.exercises.kickbackCable' => 'Kickback (cable)',
			'library.triceps.exercises.tricepsExtensionCableKneeling' => 'Triceps extension (cable, kneeling)',
			'library.triceps.exercises.tricepsExtensionCableLying' => 'Triceps extension (cable, lying)',
			'library.triceps.exercises.cableRearwardTricepsDrive' => 'Cable rearward triceps drive',
			'library.triceps.exercises.tricepsPushdownCableReverseGripSzBarArmBlaster' => 'Triceps pushdown (cable, reverse grip, sz bar, arm blaster)',
			'library.triceps.exercises.pushdownCableReverseGrip' => 'Pushdown (cable, reverse grip)',
			'library.triceps.exercises.tricepsExtensionCableRopeIncline' => 'Triceps extension (cable, rope, incline)',
			'library.triceps.exercises.tricepsExtensionCableRopeLyingFloor' => 'Triceps extension (cable, rope, lying, floor)',
			'library.triceps.exercises.tricepsExtensionCableStandingOneArm' => 'Triceps extension (cable, standing, one arm)',
			'library.triceps.exercises.tricepsExtensionCableStandingReverseGripOneArmOverhead' => 'Triceps extension (cable, standing, reverse grip, one arm, overhead)',
			_ => null,
		} ?? switch (path) {
			'library.triceps.exercises.tricepsPushdownCableVBar' => 'Triceps pushdown (cable, v bar)',
			'library.triceps.exercises.tricepsPushdownCableVBarArmBlaster' => 'Triceps pushdown (cable, v bar, arm blaster)',
			'library.triceps.exercises.tricepsKickbackCableTwoArm' => 'Triceps kickback (cable, two arm)',
			'library.triceps.exercises.pushUpCloseGrip' => 'Push-up (close grip)',
			'library.triceps.exercises.pushUpCloseGripKnee' => 'Push-up (close grip, knee)',
			'library.triceps.exercises.pressDumbbellCloseGrip' => 'Press (dumbbell, close grip)',
			'library.triceps.exercises.pressDumbbellDeclineOneArmNeutralGrip' => 'Press (dumbbell, decline, one arm, neutral grip)',
			'library.triceps.exercises.tricepsExtensionDumbbellDecline' => 'Triceps extension (dumbbell, decline)',
			'library.triceps.exercises.forwardLungeTricepsExtensionDumbbell' => 'Forward lunge triceps extension (dumbbell)',
			'library.triceps.exercises.pressDumbbellInclineNeutralGripExerciseBall' => 'Press (dumbbell, incline, neutral grip, exercise ball)',
			'library.triceps.exercises.pressDumbbellInclineOneArmNeutralGrip' => 'Press (dumbbell, incline, one arm, neutral grip)',
			'library.triceps.exercises.pressDumbbellInclineOneArmNeutralGripExerciseBall' => 'Press (dumbbell, incline, one arm, neutral grip, exercise ball)',
			'library.triceps.exercises.tricepsExtensionDumbbellIncline' => 'Triceps extension (dumbbell, incline)',
			'library.triceps.exercises.tricepsExtensionDumbbellInclineTwoArm' => 'Triceps extension (dumbbell, incline, two arm)',
			'library.triceps.exercises.kickbackDumbbellExerciseBall' => 'Kickback (dumbbell, exercise ball)',
			'library.triceps.exercises.tricepsExtensionDumbbellLyingAcrossFace' => 'Triceps extension (dumbbell, lying, across face)',
			'library.triceps.exercises.extensionDumbbellLyingAlternate' => 'Extension (dumbbell, lying, alternate)',
			'library.triceps.exercises.tricepsExtensionDumbbellLying' => 'Triceps extension (dumbbell, lying)',
			'library.triceps.exercises.tricepsExtensionDumbbellLyingOneArmPronated' => 'Triceps extension (dumbbell, lying, one arm, pronated)',
			'library.triceps.exercises.tricepsExtensionDumbbellLyingOneArmSupinated' => 'Triceps extension (dumbbell, lying, one arm, supinated)',
			'library.triceps.exercises.tricepsExtensionDumbbellLyingOneArm' => 'Triceps extension (dumbbell, lying, one arm)',
			'library.triceps.exercises.frenchPressDumbbellOneArmExerciseBall' => 'French press (dumbbell, one arm, exercise ball)',
			'library.triceps.exercises.pressDumbbellOneArmNeutralGripExerciseBall' => 'Press (dumbbell, one arm, neutral grip, exercise ball)',
			'library.triceps.exercises.tricepsExtensionDumbbellOneArmBench' => 'Triceps extension (dumbbell, one arm, bench)',
			'library.triceps.exercises.tricepsExtensionDumbbellPronateGrip' => 'Triceps extension (dumbbell, pronate grip)',
			'library.triceps.exercises.extensionDumbbellSeatedBench' => 'Extension (dumbbell, seated, bench)',
			'library.triceps.exercises.kickbackDumbbellSeatedBentOverAlternate' => 'Kickback (dumbbell, seated, bent over, alternate)',
			'library.triceps.exercises.kickbackDumbbellSeated' => 'Kickback (dumbbell, seated)',
			'library.triceps.exercises.kickbackDumbbellSeatedOneArm' => 'Kickback (dumbbell, seated, one arm)',
			'library.triceps.exercises.tricepsExtensionDumbbellSeatedReverseGripOneArmOverhead' => 'Triceps extension (dumbbell, seated, reverse grip, one arm, overhead)',
			'library.triceps.exercises.tricepsKickbackDumbbellStandingAlternate' => 'Triceps kickback (dumbbell, standing, alternate)',
			'library.triceps.exercises.tricepsExtensionDumbbellStandingBentOverOneArm' => 'Triceps extension (dumbbell, standing, bent over, one arm)',
			'library.triceps.exercises.kickbackDumbbellStanding' => 'Kickback (dumbbell, standing)',
			'library.triceps.exercises.extensionDumbbellStandingOneArm' => 'Extension (dumbbell, standing, one arm)',
			'library.triceps.exercises.tatePressDumbbell' => 'Tate press (dumbbell)',
			'library.triceps.exercises.tricepsKickbackDumbbellStorkStance' => 'Triceps kickback (dumbbell, stork stance)',
			'library.triceps.exercises.elbowSupportedDips' => 'Elbow-supported dips',
			'library.triceps.exercises.dipExerciseBall' => 'Dip (exercise ball)',
			'library.triceps.exercises.tricepsStretchExerciseBallSeated' => 'Triceps stretch (exercise ball, seated)',
			'library.triceps.exercises.tricepsExtensionExerciseBallSupine' => 'Triceps extension (exercise ball, supine)',
			'library.triceps.exercises.frenchPressEzBarExerciseBall' => 'French press (ez bar, exercise ball)',
			'library.triceps.exercises.tricepsExtensionEzBarLyingCloseGripBehindHead' => 'Triceps extension (ez bar, lying, close grip, behind head)',
			'library.triceps.exercises.frenchPressEzBarStanding' => 'French press (ez bar, standing)',
			'library.triceps.exercises.declineEZBarFacePress' => 'Decline EZ-bar face press',
			'library.triceps.exercises.tricepsExtensionEzBarbellDecline' => 'Triceps extension (ez barbell, decline)',
			'library.triceps.exercises.tricepsExtensionEzBarbellIncline' => 'Triceps extension (ez barbell, incline)',
			'library.triceps.exercises.tricepsExtensionEzBarbellSeated' => 'Triceps extension (ez barbell, seated)',
			'library.triceps.exercises.benchPressEzBarCloseGrip' => 'Bench press (ez bar, close grip)',
			'library.triceps.exercises.forearmTransitionDips' => 'Forearm-transition dips',
			'library.triceps.exercises.pushUpInclineCloseGrip' => 'Push-up (incline, close grip)',
			'library.triceps.exercises.tricepsDipLeverOverhand' => 'Triceps dip (lever, overhand)',
			'library.triceps.exercises.dipLeverSeated' => 'Dip (lever, seated)',
			'library.triceps.exercises.pushUpMedicineBallCloseGrip' => 'Push-up (medicine ball, close grip)',
			'library.triceps.exercises.supineMedicineBallChestThrow' => 'Supine medicine-ball chest throw',
			'library.triceps.exercises.tricepsExtensionOlympicBarbell' => 'Triceps extension (olympic barbell)',
			'library.triceps.exercises.dipOneArm' => 'Dip (one arm)',
			'library.triceps.exercises.tricepsStretchOverhead' => 'Triceps stretch (overhead)',
			'library.triceps.exercises.pushUpCloseGripOffDumbbell' => 'Push-up (close grip, off, dumbbell)',
			'library.triceps.exercises.dipReverse' => 'Dip (reverse)',
			'library.triceps.exercises.dipRing' => 'Dip (ring)',
			'library.triceps.exercises.benchPressSmithCloseGrip' => 'Bench press (smith, close grip)',
			'library.triceps.exercises.benchPressSmithMachineDeclineCloseGrip' => 'Bench press (smith machine, decline, close grip)',
			'library.triceps.exercises.tricepsExtensionSmithMachineIncline' => 'Triceps extension (smith machine, incline)',
			'library.triceps.exercises.stalderPressToHandstand' => 'Stalder press to handstand',
			'library.triceps.exercises.dipThreeBench' => 'Dip (three, bench)',
			'library.triceps.exercises.tricepsDipFloor' => 'Triceps dip (floor)',
			'library.triceps.exercises.dipWeightedBench' => 'Dip (weighted, bench)',
			'library.triceps.exercises.dipWeightedThreeBench' => 'Dip (weighted, three, bench)',
			'library.triceps.exercises.tricepsDipWeighted' => 'Triceps dip (weighted)',
			'library.triceps.exercises.jmPressBarbell' => 'JM press (barbell)',
			'library.triceps.exercises.jmPressEzBarbell' => 'JM press (ez barbell)',
			'library.newCustomExercise' => 'New exercise',
			'library.custom.name' => 'Custom exercises',
			'library.hips.exercises.hipAdduction' => 'Machine hip adduction',
			'library.hips.exercises.adductorStretchAssistedSideLying' => 'Adductor stretch (assisted, side lying)',
			'library.hips.exercises.hipAdductionCable' => 'Hip adduction (cable)',
			'library.hips.exercises.hipAdductionSideLying' => 'Hip adduction (side lying)',
			'library.hips.exercises.hipAdductionSidePlank' => 'Hip adduction (side plank)',
			'library.hips.name' => 'Hips',
			'library.forearms.name' => 'Forearms',
			'library.forearms.exercises.wristCurlsBarbell' => 'Wrist curls (barbell)',
			'library.forearms.exercises.reverseWristCurlsBarbell' => 'Reverse wrist curls (barbell)',
			'library.forearms.exercises.wristCurlsDumbbell' => 'Wrist curls (dumbbell)',
			'library.forearms.exercises.reverseWristCurlsDumbbell' => 'Reverse wrist curls (dumbbell)',
			'library.forearms.exercises.wristRoller' => 'Wrist roller',
			'library.forearms.exercises.farmerWalk' => 'Farmer’s walk',
			'library.forearms.exercises.platePinch' => 'Plate pinch',
			'library.forearms.exercises.reverseCurls' => 'Reverse curls (barbell)',
			'library.forearms.exercises.reverseCurlsDumbbell' => 'Reverse curls (dumbbell)',
			'library.forearms.exercises.dumbbellSingleArmReverseCurl' => 'Single-arm dumbbell reverse curl',
			'library.forearms.exercises.singleArmCableReverseCurl' => 'Single-arm cable reverse curl',
			'library.forearms.exercises.reverseWristCurlBand' => 'Reverse wrist curl (band)',
			'library.forearms.exercises.wristCurlBand' => 'Wrist curl (band)',
			'library.forearms.exercises.wristCurlBarbellStandingBack' => 'Wrist curl (barbell, standing, back)',
			'library.forearms.exercises.reverseWristCurlCable' => 'Reverse wrist curl (cable)',
			'library.forearms.exercises.wristCurlCableStandingBack' => 'Wrist curl (cable, standing, back)',
			'library.forearms.exercises.wristCurlCable' => 'Wrist curl (cable)',
			'library.forearms.exercises.dumbbellFingerFlexion' => 'Dumbbell finger flexion',
			'library.forearms.exercises.pronationDumbbellLying' => 'Pronation (dumbbell, lying)',
			'library.forearms.exercises.pronationDumbbellLyingFloor' => 'Pronation (dumbbell, lying, floor)',
			'library.forearms.exercises.supinationDumbbellLying' => 'Supination (dumbbell, lying)',
			'library.forearms.exercises.supinationDumbbellLyingFloor' => 'Supination (dumbbell, lying, floor)',
			'library.forearms.exercises.reverseWristCurlDumbbellOneArm' => 'Reverse wrist curl (dumbbell, one arm)',
			'library.forearms.exercises.neutralWristCurlDumbbellOneArmSeated' => 'Neutral wrist curl (dumbbell, one arm, seated)',
			'library.forearms.exercises.wristCurlDumbbellOneArm' => 'Wrist curl (dumbbell, one arm)',
			'library.forearms.exercises.benchSupportedDumbbellRadialDeviation' => 'Bench-supported dumbbell radial deviation',
			'library.forearms.exercises.neutralWristCurlDumbbellBenchOneArm' => 'Neutral wrist curl (dumbbell, bench, one arm)',
			'library.forearms.exercises.reverseWristCurlDumbbellBenchOneArm' => 'Reverse wrist curl (dumbbell, bench, one arm)',
			'library.forearms.exercises.wristCurlDumbbellBenchOneArm' => 'Wrist curl (dumbbell, bench, one arm)',
			'library.forearms.exercises.seatedDumbbellRadialDeviation' => 'Seated dumbbell radial deviation',
			'library.forearms.exercises.shoulderExternalRotationDumbbellSeatedOneArm' => 'Shoulder external rotation (dumbbell, seated, one arm)',
			'library.forearms.exercises.fingerFlexionCurls' => 'Finger flexion curls',
			'library.forearms.exercises.hangCleanKettlebellAlternate' => 'Hang clean (kettlebell, alternate)',
			'library.forearms.exercises.machineHandGripSqueeze' => 'Machine hand-grip squeeze',
			'library.forearms.exercises.wristStretchWithSidePull' => 'Wrist stretch with side pull',
			'library.forearms.exercises.wristCurlSmithSeated' => 'Wrist curl (smith, seated)',
			'library.forearms.exercises.wristCurlSmithStandingBack' => 'Wrist curl (smith, standing, back)',
			'library.forearms.exercises.weightedHandGripSqueeze' => 'Weighted hand-grip squeeze',
			'library.forearms.exercises.wristCircles' => 'Wrist circles',
			'library.obliques.exercises.sidewaysPlank' => 'Side plank',
			'library.obliques.exercises.sidewaysPlankReachThrough' => 'Side plank reach through',
			'library.other.name' => 'Other',
			'library.other.exercises.stretching' => 'Stretching',
			'library.glutes.exercises.singleLegGluteBridge' => 'Single-leg glute bridge',
			'library.glutes.exercises.smithMachineHipThrust' => 'Smith machine hip thrust',
			'library.glutes.exercises.bandHipAbduction' => 'Resistance band hip abduction',
			'library.glutes.exercises.lateralBandWalk' => 'Lateral band walk',
			'library.glutes.exercises.quadrupedGluteKickback' => 'Quadruped glute kickback',
			'library.glutes.exercises.kettlebellSwing' => 'Kettlebell swing',
			'library.glutes.exercises.cableGluteKickback' => 'Cable glute kickback',
			'library.glutes.exercises.machineGluteKickback' => 'Machine glute kickback',
			'library.glutes.exercises.cableHipAbduction' => 'Cable hip abduction',
			'library.glutes.exercises.gluteBridge' => 'Glute bridge',
			'library.glutes.exercises.hipThrust' => 'Machine hip thrust',
			'library.glutes.exercises.hipAbduction' => 'Machine hip abduction',
			'library.glutes.exercises.clamshells' => 'Clamshells',
			'library.glutes.exercises.hipThrustBarbell' => 'Hip thrust (barbell)',
			'library.glutes.exercises.standingToeTouchCirclesArmsOpen' => 'Standing toe-touch circles, arms open',
			'library.glutes.exercises.assistedSupineGluteStretch' => 'Assisted supine glute stretch',
			'library.glutes.exercises.assistedGluteAndPiriformisStretch' => 'Assisted glute and piriformis stretch',
			'library.glutes.exercises.hipExtensionBandBentOver' => 'Hip extension (band, bent over)',
			'library.glutes.exercises.gluteBridgeBand' => 'Glute bridge (band)',
			'library.glutes.exercises.hipInternalRotationBandLying' => 'Hip internal rotation (band, lying)',
			'library.glutes.exercises.pullThroughBand' => 'Pull through (band)',
			'library.glutes.exercises.hipInternalRotationBandSeated' => 'Hip internal rotation (band, seated)',
			'library.glutes.exercises.gluteBridgeBarbell' => 'Glute bridge (barbell)',
			'library.glutes.exercises.gluteBridgeBarbellBench' => 'Glute bridge (barbell, bench)',
			'library.glutes.exercises.deadliftBarbellOneArmSide' => 'Deadlift (barbell, one arm, side)',
			'library.glutes.exercises.rackPullBarbell' => 'Rack pull (barbell)',
			'library.glutes.exercises.deadliftBarbellOneLeg' => 'Deadlift (barbell, one leg)',
			'library.glutes.exercises.deadliftBarbellSumo' => 'Deadlift (barbell, sumo)',
			'library.glutes.exercises.standingForwardFoldToToes' => 'Standing forward fold to toes',
			'library.glutes.exercises.hipExtensionBench' => 'Hip extension (bench)',
			'library.glutes.exercises.twistBentKneeLying' => 'Twist (bent knee, lying)',
			'library.glutes.exercises.deadliftCable' => 'Deadlift (cable)',
			'library.glutes.exercises.pullThroughCableRope' => 'Pull through (cable, rope)',
			'library.glutes.exercises.hipExtensionCableStanding' => 'Hip extension (cable, standing)',
			'library.glutes.exercises.cleanDumbbell' => 'Clean (dumbbell)',
			'library.glutes.exercises.deadliftDumbbell' => 'Deadlift (dumbbell)',
			'library.glutes.exercises.snatchDumbbellOneArm' => 'Snatch (dumbbell, one arm)',
			'library.glutes.exercises.deadliftDumbbellOneLegStepboxSupport' => 'Deadlift (dumbbell, one leg, stepbox support)',
			'library.glutes.exercises.pullThroughDumbbellSumo' => 'Pull through (dumbbell, sumo)',
			'library.glutes.exercises.hipFlexorStretchExerciseBall' => 'Hip flexor stretch (exercise ball)',
			'library.glutes.exercises.proneSingleLegHipRotationOnBall' => 'Prone single-leg hip rotation on ball',
			'library.glutes.exercises.ballSupportedDiagonalKickAndLegCurl' => 'Ball-supported diagonal kick and leg curl',
			'library.glutes.exercises.flutterKicks' => 'Flutter kicks',
			'library.glutes.exercises.gluteBridgeMarch' => 'Glute bridge (march)',
			'library.glutes.exercises.gluteBridgeTwoLegBench' => 'Glute bridge (two leg, bench)',
			'library.glutes.exercises.toeTouchCirclesWithHandsClasped' => 'Toe-touch circles with hands clasped',
			'library.glutes.exercises.toeTouchCirclesWithReversedHandClasp' => 'Toe-touch circles with reversed hand clasp',
			'library.glutes.exercises.supineKneesToChestStretch' => 'Supine knees-to-chest stretch',
			'library.glutes.exercises.supineCrossBodyRotationStretch' => 'Supine cross-body rotation stretch',
			'library.glutes.exercises.deadliftLever' => 'Deadlift (lever)',
			'library.glutes.exercises.hipExtensionLever' => 'Hip extension (lever)',
			'library.glutes.exercises.legPressLeverHorizontalOneLeg' => 'Leg press (lever, horizontal, one leg)',
			'library.glutes.exercises.reverseHyperextensionLever' => 'Reverse hyperextension (lever)',
			'library.glutes.exercises.wallSitWithAlternatingKneeLifts' => 'Wall sit with alternating knee lifts',
			'library.glutes.exercises.pelvicTiltIntoGluteBridge' => 'Pelvic tilt into glute bridge',
			'library.glutes.exercises.pushUpPikeToCobra' => 'Push-up (pike to cobra)',
			'library.glutes.exercises.elevatedReverseBridge' => 'Elevated reverse bridge',
			'library.glutes.exercises.hipThrustsResistanceBandKnee' => 'Hip thrusts (resistance band, knee)',
			'library.glutes.exercises.hipAbductionResistanceBandSeated' => 'Hip abduction (resistance band, seated)',
			'library.glutes.exercises.reverseHyperextensionStabilityBall' => 'Reverse hyperextension (stability ball)',
			'library.glutes.exercises.reverseHyperextensionFlatBench' => 'Reverse hyperextension (flat bench)',
			'library.glutes.exercises.rockingFrogAdductorStretch' => 'Rocking frog adductor stretch',
			'library.glutes.exercises.latStretchRollerHip' => 'Lat stretch (roller, hip)',
			'library.glutes.exercises.hipStretchRoller' => 'Hip stretch (roller)',
			'library.glutes.exercises.gluteStretchSeated' => 'Glute stretch (seated)',
			'library.glutes.exercises.piriformisStretchSeated' => 'Piriformis stretch (seated)',
			'library.glutes.exercises.hipAbductionSideBridge' => 'Hip abduction (side bridge)',
			'library.glutes.exercises.hipAbductionSide' => 'Hip abduction (side)',
			'library.glutes.exercises.legPressSled45WideStance' => 'Leg press (sled, 45°, wide stance)',
			'library.glutes.exercises.deadliftSmith' => 'Deadlift (smith)',
			'library.glutes.exercises.legPressSmith' => 'Leg press (smith)',
			'library.glutes.exercises.sideLyingStraightLegHipAbduction' => 'Side-lying straight-leg hip abduction',
			'library.glutes.exercises.swimmerKicks' => 'Swimmer kicks',
			'library.glutes.exercises.tireTurnover' => 'Tire turnover',
			'library.glutes.exercises.trapBarDeadlift' => 'Trap-bar deadlift',
			'library.glutes.exercises.hipLiftWithRotation' => 'Hip lift with rotation',
			'library.glutes.name' => 'Glutes',
			'infobox.label' => 'Notes',
			'superset' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'Superset without exercises', one: 'Superset with ${n} exercise', two: 'Superset with ${n} exercises', few: 'Superset with ${n} exercises', many: 'Superset with ${n} exercises', other: 'Superset with ${n} exercises', ), 
			'historyEditor.title' => ({required Object name}) => 'Edit: ${name}',
			'historyEditor.exercises.addSuperset' => '+ Add superset',
			'historyEditor.exercises.add' => '+ Add exercise',
			'historyEditor.exercises.reorder' => 'Reorder exercises',
			'historyEditor.info.reps' => 'Reps',
			'historyEditor.info.volume' => 'Lifted weight',
			'historyEditor.actions.finish' => 'Finish editing',
			'historyEditor.actions.changeWeightUnit' => 'Change weight unit',
			'historyEditor.actions.discardChanges' => 'Unsaved changes',
			'historyEditor.actions.discardChangesContent' => 'This page contains unsaved changes. Do you wish to go back and discard your changes?',
			'historyEditor.finish.title' => 'Finish editing',
			'historyEditor.finish.fields.name.label' => 'Name',
			'historyEditor.finish.fields.name.errors.empty' => 'The name must not be empty.',
			'historyEditor.finish.fields.startingTime.label' => 'Starting time',
			'historyEditor.finish.fields.parent.label' => 'Categorize under',
			'historyEditor.finish.fields.parent.options.none' => 'No routine',
			'historyEditor.finish.fields.duration.label' => 'Duration',
			'historyEditor.finish.fields.duration.errors.empty' => 'The duration must not be zero.',
			'historyEditor.finish.fields.infobox.label' => 'Notes',
			'importRoutine.title' => 'Import routine',
			'importRoutine.errors.badJson.title' => 'Bad data',
			'importRoutine.errors.badJson.body' => 'The link you followed is malformed and cannot be opened.',
			'importRoutine.errors.noJson.title' => 'No data',
			'importRoutine.errors.noJson.body' => 'The link you followed is malformed and cannot be opened.',
			'importRoutine.errors.badWorkout.title' => 'Bad workout',
			'importRoutine.errors.badWorkout.body' => 'The link you followed leads to a malformed workout. Maybe it was created by an older version of the app.',
			'importRoutine.import.label' => 'Import',
			'importRoutine.import.done' => 'The routine has been imported.',
			'unknownUrl.title' => 'Unknown URL',
			'unknownUrl.text' => 'You followed a URL that doesn\'t lead anywhere.',
			'me.title' => 'Profile',
			'me.weight.label' => 'Weight',
			'me.weight.none' => 'N/A',
			'me.weight.allData.label' => 'Show all data',
			'me.weight.measured.never' => 'Last measured: never',
			'me.weight.measured.date' => ({required Object date}) => 'Last measured: ${date}',
			'me.weight.addMeasurement' => 'Add measurement',
			'me.addWeight.time.label' => 'Date and time',
			'me.addWeight.weight.label' => 'Weight',
			'me.addWeight.weightUnit.label' => 'Unit',
			'me.addWeight.errors.invalidWeight' => 'Enter a valid weight',
			'me.allData.label' => 'All recorded data',
			'me.allData.removed.text' => 'The data has been removed',
			'me.allData.none' => 'No data',
			'me.allData.predictedWeight.label' => 'Predicted weight',
			'me.allData.predictedWeight.dialog.title' => 'Predicted weight',
			'me.allData.predictedWeight.dialog.text' => 'The predicted weight is provided for informative purposes only and should not be taken seriously.',
			'me.calendar.label' => 'Calendar',
			'me.calendar.empty' => 'You haven\'t worked out on this date',
			'me.calendar.streak' => 'Streak',
			'me.calendar.rest' => 'Rest',
			'me.stats.label' => 'Statistics',
			'me.stats.timeFrame.thirtyDays' => 'Last 30 days',
			'me.stats.timeFrame.threeMonths' => 'Last 3 months',
			'me.stats.timeFrame.year' => 'Last year',
			'me.stats.timeFrame.allTime' => 'All time',
			'me.stats.timeFrame.sevenDays' => 'Last 7 days',
			'me.stats.workouts.label' => 'Workouts',
			'me.stats.duration.label' => 'Duration',
			'me.stats.volume.label' => 'Volume',
			'me.stats.distance.label' => 'Distance ran',
			'me.stats.sets.label' => 'Sets',
			'me.stats.muscleCategory' => 'Muscle groups',
			'me.stats.gymEquipment' => 'Equipment',
			'me.stats.atAGlance' => 'At a glance',
			'me.stats.metrics' => 'Metrics',
			'me.stats.overview.thisWeek' => 'This week',
			'me.stats.overview.title' => 'Progress',
			'me.stats.overview.volume' => 'Lifted volume',
			'me.stats.overview.personalRecords' => 'Personal records',
			'me.stats.overview.recordCriteria' => 'Load records: at the same weight, the set with more repetitions wins.',
			'me.stats.overview.emptyRecords' => 'Complete a set with weight and repetitions to see your personal records.',
			'me.stats.overview.emptyWeek' => 'No volume recorded this week.',
			'me.stats.overview.loadError' => 'Unable to load progress',
			'me.stats.overview.retryDescription' => 'Try again to load your workouts.',
			'me.stats.mainThree.label' => 'The Main Three',
			'me.stats.mainThree.description' => 'View the evolution of your 1RM for the "Main Three" over the selected time frame. The chart uses the highest 1RM of each week to display the overall trend of loads in the three fundamental exercises of powerlifting.',
			'me.stats.mainThree.warning.title' => 'A note on the chart',
			'me.stats.mainThree.warning.text' => ({required Object exercises}) => 'To ensure your progress is calculated and displayed correctly in the chart, use the standard exercises from the app library rather than creating custom variations. Specifically: ${exercises}.',
			'me.stats.mainThree.bottomTitle' => ({required Object week}) => 'W${week}',
			'me.workoutDistribution.label' => 'Workout distribution',
			'me.profile.title' => 'Profile',
			'me.profile.logout' => 'Log out',
			'me.profile.edit.title' => 'Edit profile',
			'me.profile.errors.logout.title' => 'An error occurred while logging out',
			'me.profile.errors.logout.subtitle' => ({required Object error}) => 'Couldn\'t log out: ${error}',
			'me.sync.label' => 'Unsynced changes',
			'me.sync.subtitle' => 'Tap to sync your changes with the cloud.',
			'me.bodyMeasurements' => 'Body measurements',
			'me.trainer.heading' => 'Personal trainer',
			'me.trainer.title' => 'My trainer',
			'me.trainer.subtitle' => 'Manage your connection, training plans and shared routines.',
			'richText.highlight' => 'Highlight',
			'errorView.shortTitle' => 'Error',
			'errorView.title' => 'Oh snap!',
			'errorView.subtitle' => 'An unexpected error occurred.',
			'errorView.body' => 'You can try the following:\n\n • Restart the app\n • Check if you are using the latest version\n • Contact support',
			'errorView.stack' => 'If the error persists, please provide the following information to the support team:',
			'errorView.noStack' => 'No stack trace available.',
			'timeSeriesChart.selectInterval' => 'Select interval',
			'timeSeriesChart.interval.threeMonths' => '3 months',
			'timeSeriesChart.interval.sixMonths' => '6 months',
			'timeSeriesChart.interval.oneYear' => '1 year',
			'timeSeriesChart.noData.title' => 'This chart contains no data',
			'timeSeriesChart.noData.subtitle' => 'Start some workouts to see this data',
			'androidRequestExactAlarmsPermission.title' => 'Notification permission',
			'androidRequestExactAlarmsPermission.message' => 'This app requires a special "Exact alarms" permission on versions of Android greater than or equal to 14. You can deny it, but features such as rest timer notifications won\'t work. Would you like to grant this permission?',
			'routineFormPicker.fields.routine.options.none' => 'No routine selected',
			'routineFormPicker.fields.routine.options.root' => 'Home',
			'cardioTimer.name' => 'Interval timer',
			'cardioTimer.setUp.title' => 'Set up interval timer',
			'cardioTimer.setUp.active' => 'Active time',
			'cardioTimer.setUp.rest' => 'Rest time',
			'cardioTimer.setUp.section' => ({required Object section}) => 'Section #${section}',
			'cardioTimer.setUp.start' => 'Start interval timer',
			'cardioTimer.setUp.addSection' => '+ New section',
			'cardioTimer.setUp.errors.duration' => 'The duration must not be null.',
			'cardioTimer.setUp.errors.bothZeros' => 'Both times can\'t be zero.',
			'cardioTimer.setUp.errors.generic' => 'There are errors in the settings. Fix them and try again.',
			'cardioTimer.confirmExit.title' => 'Exit interval timer',
			'cardioTimer.confirmExit.message' => 'Are you sure you want to leave? The current progress will be reset.',
			'migrations.customToLibraryExercise.fields.from.title' => 'Replace all occurrences of this custom exercise…',
			'migrations.customToLibraryExercise.fields.from.label' => 'Custom exercise',
			'migrations.customToLibraryExercise.fields.to.title' => '…with this library exercise…',
			'migrations.customToLibraryExercise.fields.to.label' => 'Library exercise',
			'migrations.customToLibraryExercise.title' => 'Custom exercise to library exercise',
			'migrations.customToLibraryExercise.description' => 'Replace all occurrences of a custom exercise with a compatible library exercise',
			'migrations.customToLibraryExercise.preview.from' => 'Replace…',
			'migrations.customToLibraryExercise.preview.to' => 'With…',
			'migrations.customToLibraryExercise.preview.affectedRoutines' => 'Affected routines',
			'migrations.customToLibraryExercise.preview.affectedWorkouts' => 'Affected workouts in history',
			'migrations.common.actions.next' => 'Next step: preview',
			'migrations.common.actions.apply' => 'Apply migration',
			'migrations.common.preview' => 'Migration preview',
			'migrations.common.migrated' => 'Migration done!',
			'migrations.title' => 'Migrations',
			'migrations.removeUnusedExercises.preview.noAffected' => 'No data affected.',
			'migrations.removeUnusedExercises.preview.affectedExercises' => 'Affected exercises',
			'migrations.removeUnusedExercises.title' => 'Remove unused exercises',
			'migrations.removeUnusedExercises.description' => 'Clean up your library by removing all custom exercises you haven\'t used',
			'migrations.removeWeightFromCustomExercise.preview.incompatible.title' => 'Incompatible exercise',
			'migrations.removeWeightFromCustomExercise.preview.incompatible.text' => 'You can only apply this migration to exercises in which you haven\'t ever used a weight.',
			'migrations.removeWeightFromCustomExercise.preview.selected' => 'Selected exercise',
			'migrations.removeWeightFromCustomExercise.preview.affectedRoutines' => 'Affected routines',
			'migrations.removeWeightFromCustomExercise.preview.affectedWorkouts' => 'Affected workouts in history',
			'migrations.removeWeightFromCustomExercise.fields.exercise.label' => 'Exercise',
			'migrations.removeWeightFromCustomExercise.fields.exercise.title' => 'Remove the Weight parameter from this exercise',
			'migrations.removeWeightFromCustomExercise.title' => 'Remove Weight parameter',
			'migrations.removeWeightFromCustomExercise.description' => 'Remove the Weight parameter from an exercise with "Reps and Weight" in which you\'ve only ever used the Reps field.',
			'migrations.genericMultiplyWeight.title' => ({required Object multiplier}) => 'Multiply exercise weight by ${multiplier}',
			'migrations.genericMultiplyWeight.fields.exercise.title' => 'Multiply the weight of this exercise...',
			'migrations.genericMultiplyWeight.fields.exercise.label' => 'Exercise',
			'migrations.genericMultiplyWeight.preview.incompatible.title' => 'Incompatible exercise',
			'migrations.genericMultiplyWeight.preview.incompatible.text' => 'Change your selection and try again.',
			'migrations.genericMultiplyWeight.preview.selected' => 'Selected exercise',
			'migrations.genericMultiplyWeight.preview.affectedRoutines' => 'Affected routines',
			'migrations.genericMultiplyWeight.preview.affectedWorkouts' => 'Affected history workouts',
			'migrations.doubleExerciseWeight.title' => 'Double exercise weight',
			'migrations.doubleExerciseWeight.description' => 'Double the weight parameter in all occurrences of an exercise.',
			'migrations.halveExerciseWeight.title' => 'Halve exercise weight',
			'migrations.halveExerciseWeight.description' => 'Halve the weight parameter in all occurrences of an exercise.',
			'exerciseFormPicker.fields.exercise.options.none' => 'No exercise selected',
			'exercises.none.title' => 'No exercise',
			'exercises.none.subtitle' => 'Tap here to deselect everything and go back',
			'food.title' => 'Food tracking',
			'food.home.dailyNutritionalValues' => 'Daily nutritional values',
			'food.home.calories' => 'Calories',
			'food.home.carbs' => 'Carbs',
			'food.home.protein' => 'Protein',
			'food.home.fat' => 'Fat',
			'food.home.eaten' => 'Eaten',
			'food.home.remainingCal' => 'Remaining',
			'food.home.goal' => 'Goal',
			'food.home.overCal' => 'Over',
			'food.searchBar.hint' => 'Search history or food catalog…',
			'food.searchBar.noResults' => ({required Object query}) => 'No results were found for "${query}".',
			'food.searchBar.noHistory' => 'No search history',
			'food.nutriments.calories' => 'Calories',
			'food.nutriments.fat' => 'Fat',
			'food.nutriments.saturatedFat' => 'Saturated Fats',
			'food.nutriments.carbs' => 'Carbs',
			'food.nutriments.sugar' => 'Sugar',
			'food.nutriments.protein' => 'Protein',
			'food.nutriments.salt' => 'Salt',
			'food.nutriments.sodium' => 'Sodium',
			'food.nutriments.fiber' => 'Fibers',
			'food.nutriments.addedSugars' => 'Added Sugars',
			'food.nutriments.proteins' => 'Proteins',
			'food.nutriments.caffeine' => 'Caffeine',
			'food.nutriments.calcium' => 'Calcium',
			'food.nutriments.iron' => 'Iron',
			'food.nutriments.vitaminC' => 'Vitamin C',
			'food.nutriments.magnesium' => 'Magnesium',
			'food.nutriments.phosphorus' => 'Phosphorus',
			'food.nutriments.potassium' => 'Potassium',
			'food.nutriments.zinc' => 'Zinc',
			'food.nutriments.copper' => 'Copper',
			'food.nutriments.selenium' => 'Selenium',
			'food.nutriments.vitaminA' => 'Vitamin A',
			'food.nutriments.vitaminE' => 'Vitamin E',
			'food.nutriments.vitaminD' => 'Vitamin D',
			'food.nutriments.vitaminB1' => 'Vitamin B1',
			'food.nutriments.vitaminB2' => 'Vitamin B2',
			'food.nutriments.vitaminPP' => 'Vitamin PP',
			'food.nutriments.vitaminB6' => 'Vitamin B6',
			'food.nutriments.vitaminB12' => 'Vitamin B12',
			'food.nutriments.vitaminB9' => 'Vitamin B9',
			'food.nutriments.vitaminK' => 'Vitamin K',
			'food.nutriments.cholesterol' => 'Cholesterol',
			'food.nutriments.butyricAcid' => 'Butyric Acid',
			'food.nutriments.caproicAcid' => 'Caproic Acid',
			'food.nutriments.caprylicAcid' => 'Caprylic Acid',
			'food.nutriments.capricAcid' => 'Capric Acid',
			'food.nutriments.lauricAcid' => 'Lauric Acid',
			'food.nutriments.myristicAcid' => 'Myristic Acid',
			'food.nutriments.palmiticAcid' => 'Palmitic Acid',
			'food.nutriments.stearicAcid' => 'Stearic Acid',
			'food.nutriments.oleicAcid' => 'Oleic Acid',
			'food.nutriments.linoleicAcid' => 'Linoleic Acid',
			'food.nutriments.docosahexaenoicAcid' => 'Docosahexaenoic Acid',
			'food.nutriments.eicosapentaenoicAcid' => 'Eicosapentaenoic Acid',
			'food.nutriments.erucicAcid' => 'Erucic Acid',
			'food.nutriments.monounsaturatedFat' => 'Monounsaturated Fats',
			'food.nutriments.polyunsaturatedFat' => 'Polyunsaturated Fats',
			'food.nutriments.alcohol' => 'Alcohol',
			'food.nutriments.pantothenicAcid' => 'Pantothenic Acid',
			'food.nutriments.biotin' => 'Biotin',
			'food.nutriments.chloride' => 'Chloride',
			'food.nutriments.chromium' => 'Chromium',
			'food.nutriments.fluoride' => 'Fluoride',
			'food.nutriments.iodine' => 'Iodine',
			'food.nutriments.manganese' => 'Manganese',
			'food.nutriments.molybdenum' => 'Molybdenum',
			'food.nutriments.omega3' => 'Omega 3',
			'food.nutriments.omega6' => 'Omega 6',
			'food.nutriments.omega9' => 'Omega 9',
			'food.nutriments.betaCarotene' => 'ß-Carotene',
			'food.nutriments.bicarbonate' => 'Bicarbonate',
			'food.nutriments.sugarAlcohol' => 'Sugar Alcohol (polyol)',
			'food.nutriments.alphaLinolenicAcid' => 'Alpha Linolenic Acid',
			'food.nutriments.arachidicAcid' => 'Arachidic Acid',
			'food.nutriments.arachidonicAcid' => 'Arachidonic Acid',
			'food.nutriments.behenicAcid' => 'Behenic Acid',
			'food.nutriments.ceroticAcid' => 'Cerotic Acid',
			'food.nutriments.dihomoGammaLinolenicAcid' => 'Dihomo-Gamma-Linolenic Acid',
			'food.nutriments.elaidicAcid' => 'Elaidic Acid',
			'food.nutriments.gammaLinolenicAcid' => 'Gamma-Linolenic Acid',
			'food.nutriments.gondoicAcid' => 'Gondoic Acid (11-Eicosenoic acid)',
			'food.nutriments.lignocericAcid' => 'Lignoceric Acid',
			'food.nutriments.meadAcid' => 'Mead Acid',
			'food.nutriments.melissicAcid' => 'Melissic Acid',
			'food.nutriments.montanicAcid' => 'Montanic Acid',
			'food.nutriments.nervonicAcid' => 'Nervonic Acid',
			'food.nutriments.transFat' => 'Trans Fats',
			'food.nutriments.water' => 'Water',
			'food.nutrimentUnits.kcal' => 'kcal',
			'food.nutrimentUnits.kj' => 'kJ',
			'food.nutrimentUnits.g' => 'g',
			'food.nutrimentUnits.milliG' => 'mg',
			'food.nutrimentUnits.microG' => 'µg',
			'food.nutrimentUnits.milliL' => 'mL',
			'food.nutrimentUnits.l' => 'L',
			'food.nutrimentUnits.percent' => '%',
			'food.nutrimentUnits.unknown' => 'Unknown',
			'food.add.nutritionalValuesPerAmountG' => ({required Object amount}) => 'Nutrition facts (per ${amount} g / ${amount} ml)',
			'food.add.servingSize' => 'Serving size',
			'food.add.custom' => 'Custom amount',
			'food.add.amount' => 'Amount',
			'food.add.amountWithClarifiedUnit' => 'Amount (g or ml)',
			'food.add.amountEmpty' => 'The amount must not be empty',
			'food.add.amountInvalid' => 'The amount must be a valid number',
			'food.add.add' => '+ Add to tracker',
			'food.add.unnamedServingSize' => 'Unknown serving',
			'food.add.nutritionalValuesPerAmountWithUnit' => ({required Object amount, required Object unit}) => 'Nutrition facts (per ${amount} ${unit})',
			'food.add.customFood.showMore' => 'Show all fields',
			'food.add.customFood.title' => 'Add custom food',
			'food.add.customFood.fields.name' => 'Name',
			'food.add.customFood.fields.brand' => 'Brand',
			'food.add.nameEmpty' => 'The name must not be empty',
			'food.add.pieces' => 'Quantity',
			'food.offAttribution' => 'Data provided by OpenFoodFacts',
			'food.edit.edit' => 'Save',
			'food.edit.copyToToday' => 'Copy to today',
			'food.addCustom.title' => 'Add custom',
			'food.search.title' => 'Search results',
			'food.search.error.serverError' => 'Could not reach the food catalog. Please try again later.',
			'food.search.error.generic' => 'Could not reach the food catalog. Please try again later.',
			'food.barcodeReader.title' => 'Scan barcode',
			'food.barcodeReader.scanResult.noProductFound.text' => ({required Object barcode}) => 'No product found with barcode ${barcode}.',
			'food.barcodeReader.scanResult.noProductFound.title' => 'No product found',
			'food.barcodeReader.scanResult.noProductFound.createNew' => 'Create new',
			'food.barcodeReader.scanResult.error.title' => 'An error occurred',
			'food.barcodeReader.scanResult.error.text' => 'Unable to search for barcode.',
			'food.barcodeReader.enterCode' => 'Enter barcode by hand',
			'food.barcodeReader.codeField.label' => 'Barcode',
			'food.barcodeReader.codeField.empty' => 'This field must not be empty',
			'food.addCustomFood.permission.title' => 'You need to grant the following permissions',
			'food.addCustomFood.permission.camera' => 'Camera (and microphone)',
			'food.addCustomFood.permission.gallery' => 'Photo library access (to scan barcodes in pictures)',
			'food.addCustomFood.permission.recheck' => 'Check again',
			'food.addCustomFood.permission.openAppSettings' => 'Open permission settings',
			'food.nutritionGoal.effect.from' => ({required Object from}) => 'This change will take effect from ${from} onward.',
			'food.nutritionGoal.effect.range' => ({required Object from, required Object to}) => 'This change will take effect from ${from} to ${to}.',
			'food.nutritionGoals.change.title' => 'Set goal',
			'food.nutritionGoals.change.calories.label' => 'Daily calories',
			'food.nutritionGoals.change.calories.empty' => 'This value must not be empty.',
			'food.nutritionGoals.change.calories.invalid' => 'Enter a valid value.',
			'food.nutritionGoals.change.fatPercentage.label' => 'Fat (%)',
			'food.nutritionGoals.change.fatPercentage.empty' => 'This value must not be empty.',
			'food.nutritionGoals.change.fatPercentage.invalid' => 'You must enter a valid number 0-100.',
			_ => null,
		} ?? switch (path) {
			'food.nutritionGoals.change.carbsPercentage.label' => 'Carbs (%)',
			'food.nutritionGoals.change.carbsPercentage.empty' => 'This value must not be empty.',
			'food.nutritionGoals.change.carbsPercentage.invalid' => 'You must enter a valid number 0-100.',
			'food.nutritionGoals.change.proteinPercentage.label' => 'Protein (%)',
			'food.nutritionGoals.change.proteinPercentage.empty' => 'This value must not be empty.',
			'food.nutritionGoals.change.proteinPercentage.invalid' => 'You must enter a valid number 0-100.',
			'food.nutritionGoals.change.save' => 'Save changes',
			'food.nutritionGoals.history.title' => 'Goal history',
			'food.nutritionGoals.history.empty' => 'There are no goals.',
			'food.nutritionGoals.history.tapToView' => 'Tap to view day',
			'food.nutritionGoals.history.calories' => ({required Object calories}) => 'Daily calories: ${calories}',
			'food.nutritionGoals.history.macros' => ({required Object carbs, required Object protein, required Object fat}) => '${carbs} carbs – ${protein} protein – ${fat} fat',
			'food.combine.title' => 'Create combined food',
			'food.removeFavorite' => 'Remove from favorites',
			'food.addFavorite' => 'Add to favorites',
			'food.languages.aa' => 'Afar',
			'food.languages.ae' => 'Avestan',
			'food.languages.af' => 'Afrikaans',
			'food.languages.ak' => 'Akan',
			'food.languages.am' => 'Amharic',
			'food.languages.an' => 'Aragonese',
			'food.languages.ar' => 'Arabic',
			'food.languages.as' => 'Assamese',
			'food.languages.av' => 'Avar',
			'food.languages.ay' => 'Aymara',
			'food.languages.az' => 'Azerbaijani',
			'food.languages.ba' => 'Bashkir',
			'food.languages.be' => 'Belarusian',
			'food.languages.bg' => 'Bulgarian',
			'food.languages.bh' => 'Bihari',
			'food.languages.bi' => 'Bislama',
			'food.languages.bm' => 'Bambara',
			'food.languages.bn' => 'Bengali',
			'food.languages.bo' => 'Tibetan',
			'food.languages.br' => 'Breton',
			'food.languages.bs' => 'Bosnian',
			'food.languages.ca' => 'Catalan',
			'food.languages.ce' => 'Chechen',
			'food.languages.ch' => 'Chamorro',
			'food.languages.co' => 'Corsican',
			'food.languages.cr' => 'Cree',
			'food.languages.cs' => 'Czech',
			'food.languages.cu' => 'Church Slavonic',
			'food.languages.cv' => 'Chuvash',
			'food.languages.cy' => 'Welsh',
			'food.languages.da' => 'Danish',
			'food.languages.de' => 'German',
			'food.languages.dv' => 'Maldivian',
			'food.languages.dz' => 'Dzongkha',
			'food.languages.ee' => 'Ewe',
			'food.languages.el' => 'Modern Greek',
			'food.languages.en' => 'English',
			'food.languages.eo' => 'Esperanto',
			'food.languages.es' => 'Spanish',
			'food.languages.et' => 'Estonian',
			'food.languages.eu' => 'Basque',
			'food.languages.fa' => 'Persian',
			'food.languages.ff' => 'Fulah',
			'food.languages.fi' => 'Finnish',
			'food.languages.fj' => 'Fijian',
			'food.languages.fo' => 'Faorese',
			'food.languages.fr' => 'French',
			'food.languages.fy' => 'West Frisian',
			'food.languages.ga' => 'Irish',
			'food.languages.gd' => 'Scottish Gaelic',
			'food.languages.gl' => 'Galician',
			'food.languages.gn' => 'Guarani',
			'food.languages.gu' => 'Gujarati',
			'food.languages.gv' => 'Manx',
			'food.languages.ha' => 'Hausa',
			'food.languages.he' => 'Hebrew',
			'food.languages.hi' => 'Hindi',
			'food.languages.ho' => 'Hiri Motu',
			'food.languages.hr' => 'Croatian',
			'food.languages.ht' => 'Haitian Creole',
			'food.languages.hu' => 'Hungarian',
			'food.languages.hy' => 'Armenian',
			'food.languages.hz' => 'Herero',
			'food.languages.ia' => 'Interlingua',
			'food.languages.id' => 'Indonesian',
			'food.languages.ie' => 'Interlingue',
			'food.languages.ig' => 'Igbo',
			'food.languages.ii' => 'Nuosu',
			'food.languages.ik' => 'Inupiaq',
			'food.languages.io' => 'Ido',
			'food.languages.is' => 'Icelandic',
			'food.languages.it' => 'Italian',
			'food.languages.iu' => 'Inuktitut',
			'food.languages.ja' => 'Japanese',
			'food.languages.jv' => 'Javanese',
			'food.languages.ka' => 'Georgian',
			'food.languages.kg' => 'Kongo',
			'food.languages.ki' => 'Gikuyu',
			'food.languages.kj' => 'Kwanyama',
			'food.languages.kk' => 'Kazakh',
			'food.languages.kl' => 'Greenlandic',
			'food.languages.km' => 'Khmer',
			'food.languages.kn' => 'Kannada',
			'food.languages.ko' => 'Korean',
			'food.languages.kr' => 'Kanuri',
			'food.languages.ks' => 'Kashmiri',
			'food.languages.ku' => 'Kurdish',
			'food.languages.kv' => 'Komi',
			'food.languages.kw' => 'Cornish',
			'food.languages.ky' => 'Kyrgyz',
			'food.languages.la' => 'Latin',
			'food.languages.lb' => 'Luxembourgish',
			'food.languages.lg' => 'Luganda',
			'food.languages.li' => 'Limburgan',
			'food.languages.ln' => 'Lingala',
			'food.languages.lo' => 'Lao',
			'food.languages.lt' => 'Lithuanian',
			'food.languages.lu' => 'Luba-Katanga',
			'food.languages.lv' => 'Latvian',
			'food.languages.mg' => 'Malagasy',
			'food.languages.mh' => 'Marshallese',
			'food.languages.mi' => 'Maori',
			'food.languages.mk' => 'Macedonian',
			'food.languages.ml' => 'Malayalam',
			'food.languages.mn' => 'Mongolian',
			'food.languages.mo' => 'Moldovan',
			'food.languages.mr' => 'Marathi',
			'food.languages.ms' => 'Malay',
			'food.languages.mt' => 'Maltese',
			'food.languages.my' => 'Burmese',
			'food.languages.na' => 'Nauruan',
			'food.languages.nb' => 'Bokmal',
			'food.languages.nd' => 'North Ndbele',
			'food.languages.ne' => 'Nepali',
			'food.languages.ng' => 'Ndonga',
			'food.languages.nl' => 'Dutch',
			'food.languages.nn' => 'Nynorsk',
			'food.languages.no' => 'Norwegian',
			'food.languages.nr' => 'South Ndebele',
			'food.languages.nv' => 'Navajo',
			'food.languages.ny' => 'Chewa',
			'food.languages.oc' => 'Occitan',
			'food.languages.oj' => 'Ojibwe',
			'food.languages.om' => 'Oromo',
			'food.languages.or' => 'Odia',
			'food.languages.os' => 'Ossetian',
			'food.languages.pa' => 'Punjabi',
			'food.languages.pi' => 'Pali',
			'food.languages.pl' => 'Polish',
			'food.languages.ps' => 'Pashto',
			'food.languages.pt' => 'Portuguese',
			'food.languages.qu' => 'Quechua',
			'food.languages.rm' => 'Romansh',
			'food.languages.rn' => 'Kirundi',
			'food.languages.ro' => 'Romanian',
			'food.languages.ru' => 'Russian',
			'food.languages.rw' => 'Kinyarmanda',
			'food.languages.sa' => 'Sanskrit',
			'food.languages.sc' => 'Sardinian',
			'food.languages.sd' => 'Sindhi',
			'food.languages.se' => 'Northern Sami',
			'food.languages.sg' => 'Sango',
			'food.languages.si' => 'Sinhala',
			'food.languages.sk' => 'Slovak',
			'food.languages.sl' => 'Slovenian',
			'food.languages.sm' => 'Samoan',
			'food.languages.sn' => 'Shona',
			'food.languages.so' => 'Somali',
			'food.languages.sq' => 'Albanian',
			'food.languages.sr' => 'Serbian',
			'food.languages.ss' => 'Swazi',
			'food.languages.st' => 'Sotho',
			'food.languages.su' => 'Sundanese',
			'food.languages.sv' => 'Swedish',
			'food.languages.sw' => 'Swahili',
			'food.languages.ta' => 'Tamil',
			'food.languages.te' => 'Telugu',
			'food.languages.tg' => 'Tajik',
			'food.languages.th' => 'Thai',
			'food.languages.ti' => 'Tigrinya',
			'food.languages.tk' => 'Turkmen',
			'food.languages.tl' => 'Tagalog',
			'food.languages.tn' => 'Tswana',
			'food.languages.to' => 'Tonga',
			'food.languages.tr' => 'Turkish',
			'food.languages.ts' => 'Tsonga',
			'food.languages.tt' => 'Tatar',
			'food.languages.tw' => 'Twi',
			'food.languages.ty' => 'Tahitian',
			'food.languages.ug' => 'Uyghur',
			'food.languages.uk' => 'Ukrainian',
			'food.languages.ur' => 'Urdu',
			'food.languages.uz' => 'Uzbek',
			'food.languages.ve' => 'Venda',
			'food.languages.vi' => 'Vietnamese',
			'food.languages.vo' => 'Volapuk',
			'food.languages.wo' => 'Wolof',
			'food.languages.xh' => 'Xhosa',
			'food.languages.yi' => 'Yiddish',
			'food.languages.yo' => 'Yoruba',
			'food.languages.za' => 'Zhuang',
			'food.languages.zh' => 'Chinese',
			'food.languages.zu' => 'Zulu',
			'food.languages.xx' => 'Unknown language',
			'food.languages.world' => 'World, as pseudo language',
			'food.languages.und' => 'Undefined language',
			'food.countries.ad' => 'Andorra',
			'food.countries.ae' => 'United Arab Emirates',
			'food.countries.af' => 'Afghanistan',
			'food.countries.ag' => 'Antigua and Barbuda',
			'food.countries.ai' => 'Anguilla',
			'food.countries.al' => 'Albania',
			'food.countries.am' => 'Armenia',
			'food.countries.ao' => 'Angola',
			'food.countries.aq' => 'Antarctica',
			'food.countries.ar' => 'Argentina',
			'food.countries.as' => 'American Samoa',
			'food.countries.at' => 'Austria',
			'food.countries.au' => 'Australia',
			'food.countries.aw' => 'Aruba',
			'food.countries.ax' => 'Åland Islands',
			'food.countries.az' => 'Azerbaijan',
			'food.countries.ba' => 'Bosnia and Herzegovina',
			'food.countries.bb' => 'Barbados',
			'food.countries.bd' => 'Bangladesh',
			'food.countries.be' => 'Belgium',
			'food.countries.bf' => 'Burkina Faso',
			'food.countries.bg' => 'Bulgaria',
			'food.countries.bh' => 'Bahrain',
			'food.countries.bi' => 'Burundi',
			'food.countries.bj' => 'Benin',
			'food.countries.bl' => 'Saint Barthélemy',
			'food.countries.bm' => 'Bermuda',
			'food.countries.bn' => 'Brunei Darussalam',
			'food.countries.bo' => 'Bolivia (Plurinational State of)',
			'food.countries.bq' => 'Bonaire, Sint Eustatius and Saba',
			'food.countries.br' => 'Brazil',
			'food.countries.bs' => 'Bahamas',
			'food.countries.bt' => 'Bhutan',
			'food.countries.bv' => 'Bouvet Island',
			'food.countries.bw' => 'Botswana',
			'food.countries.by' => 'Belarus',
			'food.countries.bz' => 'Belize',
			'food.countries.ca' => 'Canada',
			'food.countries.cc' => 'Cocos (Keeling) Islands',
			'food.countries.cd' => 'Congo, Democratic Republic of the',
			'food.countries.cf' => 'Central African Republic',
			'food.countries.cg' => 'Congo',
			'food.countries.ch' => 'Switzerland',
			'food.countries.ci' => 'Côte d\'Ivoire',
			'food.countries.ck' => 'Cook Islands',
			'food.countries.cl' => 'Chile',
			'food.countries.cm' => 'Cameroon',
			'food.countries.cn' => 'China',
			'food.countries.co' => 'Colombia',
			'food.countries.cr' => 'Costa Rica',
			'food.countries.cu' => 'Cuba',
			'food.countries.cv' => 'Cabo Verde',
			'food.countries.cw' => 'Curaçao',
			'food.countries.cx' => 'Christmas Island',
			'food.countries.cy' => 'Cyprus',
			'food.countries.cz' => 'Czechia',
			'food.countries.de' => 'Germany',
			'food.countries.dj' => 'Djibouti',
			'food.countries.dk' => 'Denmark',
			'food.countries.dm' => 'Dominica',
			'food.countries.do' => 'Dominican Republic',
			'food.countries.dz' => 'Algeria',
			'food.countries.ec' => 'Ecuador',
			'food.countries.ee' => 'Estonia',
			'food.countries.eg' => 'Egypt',
			'food.countries.eh' => 'Western Sahara',
			'food.countries.er' => 'Eritrea',
			'food.countries.es' => 'Spain',
			'food.countries.et' => 'Ethiopia',
			'food.countries.fi' => 'Finland',
			'food.countries.fj' => 'Fiji',
			'food.countries.fk' => 'Falkland Islands (Malvinas)',
			'food.countries.fm' => 'Micronesia (Federated States of)',
			'food.countries.fo' => 'Faroe Islands',
			'food.countries.fr' => 'France',
			'food.countries.ga' => 'Gabon',
			'food.countries.gd' => 'Grenada',
			'food.countries.ge' => 'Georgia',
			'food.countries.gf' => 'French Guiana',
			'food.countries.gg' => 'Guernsey',
			'food.countries.gh' => 'Ghana',
			'food.countries.gi' => 'Gibraltar',
			'food.countries.gl' => 'Greenland',
			'food.countries.gm' => 'Gambia',
			'food.countries.gn' => 'Guinea',
			'food.countries.gp' => 'Guadeloupe',
			'food.countries.gq' => 'Equatorial Guinea',
			'food.countries.gr' => 'Greece',
			'food.countries.gs' => 'South Georgia and the South Sandwich Islands',
			'food.countries.gt' => 'Guatemala',
			'food.countries.gu' => 'Guam',
			'food.countries.gw' => 'Guinea-Bissau',
			'food.countries.gy' => 'Guyana',
			'food.countries.hk' => 'Hong Kong',
			'food.countries.hm' => 'Heard Island and McDonald Islands',
			'food.countries.hn' => 'Honduras',
			'food.countries.hr' => 'Croatia',
			'food.countries.ht' => 'Haiti',
			'food.countries.hu' => 'Hungary',
			'food.countries.id' => 'Indonesia',
			'food.countries.ie' => 'Ireland',
			'food.countries.il' => 'Israel',
			'food.countries.im' => 'Isle of Man',
			'food.countries.in' => 'India',
			'food.countries.io' => 'British Indian Ocean Territory',
			'food.countries.iq' => 'Iraq',
			'food.countries.ir' => 'Iran (Islamic Republic of)',
			'food.countries.is' => 'Iceland',
			'food.countries.it' => 'Italy',
			'food.countries.je' => 'Jersey',
			'food.countries.jm' => 'Jamaica',
			'food.countries.jo' => 'Jordan',
			'food.countries.jp' => 'Japan',
			'food.countries.ke' => 'Kenya',
			'food.countries.kg' => 'Kyrgyzstan',
			'food.countries.kh' => 'Cambodia',
			'food.countries.ki' => 'Kiribati',
			'food.countries.km' => 'Comoros',
			'food.countries.kn' => 'Saint Kitts and Nevis',
			'food.countries.kp' => 'Korea (Democratic People\'s Republic of)',
			'food.countries.kr' => 'Korea, Republic of',
			'food.countries.kw' => 'Kuwait',
			'food.countries.ky' => 'Cayman Islands',
			'food.countries.kz' => 'Kazakhstan',
			'food.countries.la' => 'Lao People\'s Democratic Republic',
			'food.countries.lb' => 'Lebanon',
			'food.countries.lc' => 'Saint Lucia',
			'food.countries.li' => 'Liechtenstein',
			'food.countries.lk' => 'Sri Lanka',
			'food.countries.lr' => 'Liberia',
			'food.countries.ls' => 'Lesotho',
			'food.countries.lt' => 'Lithuania',
			'food.countries.lu' => 'Luxembourg',
			'food.countries.lv' => 'Latvia',
			'food.countries.ly' => 'Libya',
			'food.countries.ma' => 'Morocco',
			'food.countries.mc' => 'Monaco',
			'food.countries.md' => 'Moldova, Republic of',
			'food.countries.me' => 'Montenegro',
			'food.countries.mf' => 'Saint Martin (French part)',
			'food.countries.mg' => 'Madagascar',
			'food.countries.mh' => 'Marshall Islands',
			'food.countries.mk' => 'North Macedonia',
			'food.countries.ml' => 'Mali',
			'food.countries.mm' => 'Myanmar',
			'food.countries.mn' => 'Mongolia',
			'food.countries.mo' => 'Macao',
			'food.countries.mp' => 'Northern Mariana Islands',
			'food.countries.mq' => 'Martinique',
			'food.countries.mr' => 'Mauritania',
			'food.countries.ms' => 'Montserrat',
			'food.countries.mt' => 'Malta',
			'food.countries.mu' => 'Mauritius',
			'food.countries.mv' => 'Maldives',
			'food.countries.mw' => 'Malawi',
			'food.countries.mx' => 'Mexico',
			'food.countries.my' => 'Malaysia',
			'food.countries.mz' => 'Mozambique',
			'food.countries.na' => 'Namibia',
			'food.countries.nc' => 'New Caledonia',
			'food.countries.ne' => 'Niger',
			'food.countries.nf' => 'Norfolk Island',
			'food.countries.ng' => 'Nigeria',
			'food.countries.ni' => 'Nicaragua',
			'food.countries.nl' => 'Netherlands',
			'food.countries.no' => 'Norway',
			'food.countries.np' => 'Nepal',
			'food.countries.nr' => 'Nauru',
			'food.countries.nu' => 'Niue',
			'food.countries.nz' => 'New Zealand',
			'food.countries.om' => 'Oman',
			'food.countries.pa' => 'Panama',
			'food.countries.pe' => 'Peru',
			'food.countries.pf' => 'French Polynesia',
			'food.countries.pg' => 'Papua New Guinea',
			'food.countries.ph' => 'Philippines',
			'food.countries.pk' => 'Pakistan',
			'food.countries.pl' => 'Poland',
			'food.countries.pm' => 'Saint Pierre and Miquelon',
			'food.countries.pn' => 'Pitcairn',
			'food.countries.pr' => 'Puerto Rico',
			'food.countries.ps' => 'Palestine, State of',
			'food.countries.pt' => 'Portugal',
			'food.countries.pw' => 'Palau',
			'food.countries.py' => 'Paraguay',
			'food.countries.qa' => 'Qatar',
			'food.countries.re' => 'Réunion',
			'food.countries.ro' => 'Romania',
			'food.countries.rs' => 'Serbia',
			'food.countries.ru' => 'Russian Federation',
			'food.countries.rw' => 'Rwanda',
			'food.countries.sa' => 'Saudi Arabia',
			'food.countries.sb' => 'Solomon Islands',
			'food.countries.sc' => 'Seychelles',
			'food.countries.sd' => 'Sudan',
			'food.countries.se' => 'Sweden',
			'food.countries.sg' => 'Singapore',
			'food.countries.sh' => 'Saint Helena, Ascension and Tristan da Cunha',
			'food.countries.si' => 'Slovenia',
			'food.countries.sj' => 'Svalbard and Jan Mayen',
			'food.countries.sk' => 'Slovakia',
			'food.countries.sl' => 'Sierra Leone',
			'food.countries.sm' => 'San Marino',
			'food.countries.sn' => 'Senegal',
			'food.countries.so' => 'Somalia',
			'food.countries.sr' => 'Suriname',
			'food.countries.ss' => 'South Sudan',
			'food.countries.st' => 'Sao Tome and Principe',
			'food.countries.sv' => 'El Salvador',
			'food.countries.sx' => 'Sint Maarten (Dutch part)',
			'food.countries.sy' => 'Syrian Arab Republic',
			'food.countries.sz' => 'Eswatini',
			'food.countries.tc' => 'Turks and Caicos Islands',
			'food.countries.td' => 'Chad',
			'food.countries.tf' => 'French Southern Territories',
			'food.countries.tg' => 'Togo',
			'food.countries.th' => 'Thailand',
			'food.countries.tj' => 'Tajikistan',
			'food.countries.tk' => 'Tokelau',
			'food.countries.tl' => 'Timor-Leste',
			'food.countries.tm' => 'Turkmenistan',
			'food.countries.tn' => 'Tunisia',
			'food.countries.to' => 'Tonga',
			'food.countries.tr' => 'Turkey',
			'food.countries.tt' => 'Trinidad and Tobago',
			'food.countries.tv' => 'Tuvalu',
			'food.countries.tw' => 'Taiwan',
			'food.countries.tz' => 'Tanzania, United Republic of',
			'food.countries.ua' => 'Ukraine',
			'food.countries.ug' => 'Uganda',
			'food.countries.uk' => 'United Kingdom of Great Britain and Northern Ireland',
			'food.countries.um' => 'United States Minor Outlying Islands',
			'food.countries.us' => 'United States of America',
			'food.countries.uy' => 'Uruguay',
			'food.countries.uz' => 'Uzbekistan',
			'food.countries.va' => 'Holy See',
			'food.countries.vc' => 'Saint Vincent and the Grenadines',
			'food.countries.ve' => 'Venezuela (Bolivarian Republic of)',
			'food.countries.vg' => 'Virgin Islands (British)',
			'food.countries.vi' => 'Virgin Islands (U.S.)',
			'food.countries.vn' => 'Viet Nam',
			'food.countries.vu' => 'Vanuatu',
			'food.countries.wf' => 'Wallis and Futuna',
			'food.countries.ws' => 'Samoa',
			'food.countries.ye' => 'Yemen',
			'food.countries.yt' => 'Mayotte',
			'food.countries.za' => 'South Africa',
			'food.countries.zm' => 'Zambia',
			'food.countries.zw' => 'Zimbabwe',
			'food.countries.world' => 'World',
			'food.categoryList.reorderFailed' => 'Could not save the category order. Please try again.',
			'food.categoryList.dailyPercentage' => ({required Object percentage, required Object calories}) => '${percentage}% of daily total – ${calories}',
			'food.categoryList.empty' => 'You haven\'t set up any categories',
			'food.categoryList.unmodifiable.title' => 'Unable to edit',
			'food.categoryList.unmodifiable.text' => 'You can only edit categories on days on or after today\'s date',
			'food.categoryList.title' => 'Categories',
			'food.categoryList.add' => 'Add',
			'food.categoryEditor.title.add' => 'Add category',
			'food.categoryEditor.title.edit' => 'Edit category',
			'food.categoryEditor.name' => 'Name',
			'food.categoryEditor.dailyPercentage' => 'Daily percentage',
			'food.categoryEditor.fields.name.errors.empty' => 'The name must not be empty.',
			'food.categoryEditor.fields.name.errors.unique' => 'There is already a category with this name.',
			'food.categoryEditor.save' => 'Save',
			'food.categoryEditor.icon' => 'Icon',
			'food.categoryEditor.effect.from' => ({required Object from}) => 'Any change will take effect from ${from} onward.',
			'food.categoryEditor.effect.range' => ({required Object from, required Object to}) => 'Any change will take effect from ${from} to ${to}.',
			'food.categoryEditor.effect.title' => 'Category effect range',
			'food.categoryEditor.nonFulfillingSum.title' => 'The sum doesn\'t equal 100%',
			'food.categoryFoods.empty' => 'You haven\'t added foods to this category yet.',
			'food.permission.denied' => 'We weren\'t able to get this permission. Would you like to open the permission settings?',
			'food.permission.openSettings' => 'Open app settings',
			'food.permission.error' => 'An error has occurred.',
			'food.datePicker.today' => 'Today',
			'food.catalog.submitAlso' => 'Also submit to the catalog',
			'food.catalog.publicNotice' => 'Your contribution becomes public and remains available even after your account is deleted.',
			'food.catalog.loginToSubmit' => 'Sign in to submit foods to the catalog. Saving to your diary remains available.',
			'food.catalog.queueFailed' => 'Food is ready for your diary, but the catalog submission could not be queued.',
			'food.catalog.submissions' => 'Catalog submissions',
			'food.catalog.noSubmissions' => 'You have not requested any catalog submissions yet.',
			'food.catalog.loadFailed' => 'Could not load submissions.',
			'food.catalog.retry' => 'Retry submission',
			'food.catalog.cancel' => 'Cancel',
			'food.catalog.report' => 'Report food',
			'food.catalog.loginToReport' => 'Sign in to report a food.',
			'food.catalog.details' => 'Details (optional)',
			'food.catalog.detailsRequired' => 'Please explain your report.',
			'food.catalog.sendReport' => 'Send report',
			'food.catalog.reportSent' => 'Report sent.',
			'food.catalog.reportFailed' => 'Could not send the report. Please try again later.',
			'food.catalog.reasons.spam' => 'Spam',
			'food.catalog.reasons.inappropriate' => 'Content inappropriate for Gym Bro',
			'food.catalog.reasons.nutrition' => 'Incorrect nutritional values',
			'food.catalog.reasons.product' => 'Incorrect product information or barcode',
			'food.catalog.reasons.duplicate' => 'Duplicate food',
			'food.catalog.reasons.other' => 'Other',
			'food.catalog.statuses.pending' => 'Waiting to submit; retries automatically',
			'food.catalog.statuses.sending' => 'Submitting',
			'food.catalog.statuses.failed' => 'Submission failed: check the data and retry',
			'food.catalog.statuses.published' => 'Published in the catalog',
			'food.catalog.statuses.duplicate' => 'Already in the catalog',
			'food.catalog.statuses.correction' => 'Correction submitted for review',
			'food.catalog.statuses.unavailable' => 'Entry unavailable for publication',
			'food.catalog.statuses.cancelled' => 'Submission cancelled',
			'food.catalog.statuses.cancelled_unknown' => 'Retries cancelled; an earlier submission may already have been received',
			'food.catalog.statuses.already_present' => 'Food already in the catalog',
			'food.catalog.statuses.uncertain' => 'We cannot verify whether this food is already in the catalog.',
			'food.picker.title' => 'Add food',
			'food.picker.search' => 'Search',
			'food.picker.barcode' => 'Barcode',
			'food.picker.more' => 'More',
			_ => null,
		} ?? switch (path) {
			'food.picker.added' => 'Added',
			'food.picker.done' => 'Done',
			'food.picker.recent' => 'Recent',
			'food.picker.results' => 'Catalog',
			'food.picker.empty' => 'No foods found',
			'food.picker.retry' => 'Retry',
			'food.picker.failed' => 'Operation failed. Please try again.',
			'food.picker.withBarcode' => 'Custom food with barcode',
			'food.picker.withoutBarcode' => 'Custom food without barcode',
			'food.picker.save' => 'Save',
			'food.picker.savePrivate' => 'Save for me',
			'food.picker.share' => 'Add to catalog',
			'food.picker.alreadyPresent' => 'Food already in the catalog',
			'food.picker.uncertain' => 'We cannot verify whether this food is already in the catalog.',
			'food.picker.queued' => 'Sharing queued for delivery',
			'food.picker.published' => 'Food published in the catalog',
			'food.picker.addedNotice' => 'Food added',
			'food.picker.noAdded' => 'No foods added yet',
			'food.picker.lookupFailed' => 'Could not look up the barcode. Retry or enter a custom food.',
			'food.picker.custom' => 'Enter food',
			'food.picker.shareNotice' => 'Save shares this food in the public catalog. Save for me keeps it personal.',
			'food.picker.invalidBarcode' => 'Enter a valid barcode (4–32 digits).',
			'food.picker.showMore' => 'Show more',
			'food.recipes.title' => 'Recipes',
			'food.recipes.create' => 'New recipe',
			'food.recipes.edit' => 'Edit recipe',
			'food.recipes.empty' => 'No saved recipes',
			'food.recipes.search' => 'Search recipes',
			'food.recipes.name' => 'Name',
			'food.recipes.description' => 'Description',
			'food.recipes.instructions' => 'Cooking instructions',
			'food.recipes.servings' => 'Servings',
			'food.recipes.ingredients' => 'Ingredients',
			'food.recipes.addIngredient' => 'Add ingredient',
			'food.recipes.automaticMass' => 'Ingredient weight',
			'food.recipes.finalMass' => 'Final cooked weight (g, optional)',
			'food.recipes.massHint' => 'Leave empty to use the sum of the ingredient weights.',
			'food.recipes.total' => 'Total',
			'food.recipes.perServing' => 'Per serving',
			'food.recipes.save' => 'Save',
			'food.recipes.delete' => 'Delete',
			'food.recipes.deletePrompt' => 'Delete this recipe? Previously logged meals will stay unchanged.',
			'food.recipes.cancel' => 'Cancel',
			'food.recipes.confirm' => 'Confirm',
			'food.recipes.add' => 'Add to diary',
			'food.recipes.choose' => 'Recipe',
			'food.recipes.grams' => 'Grams',
			'food.recipes.portions' => 'Servings',
			'food.recipes.equivalentMass' => 'Equivalent weight (g, optional)',
			'food.recipes.liquidMass' => 'Convert ml to g',
			'food.recipes.liquidHint' => 'You can enter the liquid weight in grams. Leave empty to use a conversion of 1 ml = 1 g.',
			'food.recipes.invalid' => 'Enter a valid positive value.',
			'food.recipes.invalidServings' => 'Enter an integer from 1 to 32.',
			'food.recipes.requiredName' => 'Enter a name.',
			'food.recipes.requiredIngredients' => 'Add at least one ingredient.',
			'food.recipes.failed' => 'Could not complete the operation. Try again.',
			'food.recipes.accountChanged' => 'The account changed. Reopen this screen.',
			'food.recipes.editIngredient' => 'Edit ingredient',
			'food.recipes.discard' => 'Discard changes?',
			'food.recipes.discardBody' => 'Unsaved changes will be lost.',
			'food.recipes.discardAction' => 'Discard',
			'food.recipes.details' => 'Recipe details',
			'food.recipes.yieldTitle' => 'Yield and servings',
			'food.recipes.nutrition' => 'Nutrition',
			'food.recipes.ingredientsHint' => 'Choose foods and quantities to build your recipe.',
			'food.recipes.decreaseQuantity' => 'Decrease quantity',
			'food.recipes.increaseQuantity' => 'Increase quantity',
			'equipment.none.long' => 'Bodyweight',
			'equipment.none.short' => 'Bodywt.',
			'equipment.barbell.long' => 'Barbell',
			'equipment.barbell.short' => 'Barb.',
			'equipment.dumbbell.long' => 'Dumbbells',
			'equipment.dumbbell.short' => 'Dumbb.',
			'equipment.cable.long' => 'Cables',
			'equipment.cable.short' => 'Cables',
			'equipment.machine.long' => 'Machine',
			'equipment.machine.short' => 'Machine',
			'equipment.kettlebell.long' => 'Kettlebell',
			'equipment.kettlebell.short' => 'Kettleb.',
			'equipment.plates.long' => 'Plates',
			'equipment.plates.short' => 'Plates',
			'equipment.resistanceBand.long' => 'Resistance band',
			'equipment.resistanceBand.short' => 'Res. band',
			'equipment.suspensionBands.long' => 'Suspension bands',
			'equipment.suspensionBands.short' => 'Susp. bands',
			'equipment.landmine.long' => 'Landmine platform',
			'equipment.landmine.short' => 'Landmine',
			'equipment.other.long' => 'Other',
			'equipment.other.short' => 'Other',
			'achievements.title' => 'Achievements',
			'achievements.locked' => 'Locked',
			'achievements.unlockedOn' => ({required Object date}) => 'Unlocked on: ${date}',
			'achievements.history' => 'History',
			'achievements.firstSteps.title' => 'First steps',
			'achievements.firstSteps.description.k1' => 'Complete your first workout',
			'achievements.firstSteps.description.k2' => 'Log your first weight',
			'achievements.firstSteps.description.k3' => 'Log your first meal',
			'achievements.foodWatcher.title' => 'Food blogger',
			'achievements.foodWatcher.description.k1' => 'Log your meals two days in a row',
			'achievements.foodWatcher.description.k2' => 'Log your meals a week in a row',
			'achievements.foodWatcher.description.k3' => 'Log your meals a month in a row',
			'achievements.marathoner.title' => 'Marathoner',
			'achievements.marathoner.description.k1' => 'Run or bike a 5km',
			'achievements.marathoner.description.k2' => 'Run or bike a half marathon',
			'achievements.marathoner.description.k3' => 'Run or bike a full marathon',
			'achievements.earlyBird.title' => 'Early Bird',
			'achievements.earlyBird.description' => 'Start a workout before 8am',
			'achievements.nightOwl.title' => 'Night Owl',
			'achievements.nightOwl.description' => 'Start a workout after 8pm',
			'achievements.realGymBro.title' => 'Real Gym Bro',
			'achievements.realGymBro.description.k1' => 'Log a total of 100 hours worth of workouts',
			'achievements.realGymBro.description.k2' => 'Log a total of 500 hours worth of workouts',
			'achievements.realGymBro.description.k3' => 'Log a total of 1000 hours worth of workouts',
			'achievements.workoutFreak.title' => 'Workout Freak',
			'achievements.workoutFreak.description.k1' => 'Log a workout every day of the month',
			'achievements.workoutFreak.description.k2' => 'Log a workout every day of the year',
			'achievements.trailblazer.title' => 'Trailblazer',
			'achievements.trailblazer.description.k1.km' => 'Run or bike a total of 100 km',
			'achievements.trailblazer.description.k1.mi' => ({required Object p0}) => 'Run or bike a total of 100 km (${p0})',
			'achievements.trailblazer.description.k2.km' => 'Run or bike a total of 500 km',
			'achievements.trailblazer.description.k2.mi' => ({required Object p0}) => 'Run or bike a total of 500 km (${p0})',
			'achievements.trailblazer.description.k3.km' => 'Run or bike a total of 1000 km',
			'achievements.trailblazer.description.k3.mi' => ({required Object p0}) => 'Run or bike a total of 1000 km (${p0})',
			'achievements.cycleChampion.title' => 'Cycle Champion',
			'achievements.cycleChampion.description.k1.km' => 'Cycle a total of 100km',
			'achievements.cycleChampion.description.k1.mi' => ({required Object p0}) => 'Cycle a total of 100km (${p0})',
			'achievements.cycleChampion.description.k2.km' => 'Cycle a total of 500km',
			'achievements.cycleChampion.description.k2.mi' => ({required Object p0}) => 'Cycle a total of 500km (${p0})',
			'achievements.cycleChampion.description.k3.km' => 'Cycle a total of 1000km',
			'achievements.cycleChampion.description.k3.mi' => ({required Object p0}) => 'Cycle a total of 1000km (${p0})',
			'achievements.professionalWeightlifter.title' => 'Professional Weightlifter',
			'achievements.professionalWeightlifter.description.k1' => 'Lift your body weight in a single rep',
			'achievements.professionalWeightlifter.description.k2' => 'Lift 1.5x your body weight in a single rep',
			'achievements.professionalWeightlifter.description.k3' => 'Lift 3x your body weight in a single rep',
			'achievements.programPlanner.title' => 'Program Planner',
			'achievements.programPlanner.description' => 'Create three routines',
			'achievements.perfectPlanner.title' => 'Perfect Planner',
			'achievements.perfectPlanner.description' => 'Create a routine folder',
			'achievements.routineMaster.title' => 'Routine Master',
			'achievements.routineMaster.description.k1' => 'Follow a routine for 3 consecutive months',
			'achievements.routineMaster.description.k2' => 'Follow a routine for 6 consecutive months',
			'achievements.routineMaster.description.k3' => 'Follow a routine for 12 consecutive months',
			'achievements.intensityInnovator.title' => 'Intensity Innovator',
			'achievements.intensityInnovator.description' => 'Update a routine by increasing your weight/reps',
			'achievements.completionist.title' => 'Completionist',
			'achievements.completionist.description' => 'Try all library exercises at least once',
			'achievements.notDrunk.title' => 'I\'m not drunk, I swear!',
			'achievements.notDrunk.description' => 'Work out on a Sunday morning breaking a personal best in lifted weight or distance',
			'achievements.steamedHams.description' => 'Set a new one-rep max personal record in a faster-than-usual workout',
			'achievements.steamedHams.title' => 'Steamed Hams',
			'achievements.swimsuitSeason.title' => 'Swimsuit Season',
			'achievements.swimsuitSeason.description' => 'Do a total of 24 hours of cardio exercises from March to June of a year',
			'achievements.pbBreaker.title' => 'Personal Best Breaker',
			'achievements.pbBreaker.description' => 'Set a new one-rep max personal record in one exercise',
			'achievements.sparta.title' => 'This Is Sparta',
			'achievements.sparta.description.k1.kg' => ({required Object p0}) => 'Lift 300 lbs (${p0}) in one rep',
			'achievements.sparta.description.k1.lb' => 'Lift 300 lbs in one rep',
			'achievements.sparta.description.k2.kg' => 'Lift 300 kg in one rep',
			'achievements.sparta.description.k2.lb' => ({required Object p0}) => 'Lift 300 kg (${p0}) in one rep',
			'achievements.midnightRain.description' => 'Start a workout before midnight and end it after midnight',
			'achievements.midnightRain.title' => 'Midnight Rain',
			'achievements.equipmentSpecialist.description' => 'Create and follow a routine that exclusively uses specific equipment',
			'achievements.equipmentSpecialist.title' => 'Equipment Specialist',
			'achievements.bodyweightBeast.title' => 'Bodyweight Beast',
			'achievements.bodyweightBeast.description' => 'Create a bodyweight-only routine and follow it for a month',
			'workoutGenerator.title' => 'Workout Generator',
			'workoutGenerator.muscleGroups' => 'Select muscle groups',
			'workoutGenerator.equipment' => 'Select equipment',
			'workoutGenerator.actions.generate' => 'Generate',
			'workoutGenerator.success.title' => 'Workout successfully generated',
			'workoutGenerator.success.undo' => 'Undo',
			'workoutGenerator.empty.title' => 'Empty workout',
			'workoutGenerator.empty.text' => 'Change your filters and try again',
			'boutique.title' => 'Programs',
			'boutique.package.install' => 'Install',
			'boutique.package.installed' => 'The package has been installed.',
			'boutique.errors.unknown' => 'Loading failed. Check your Internet connection and retry.',
			'boutique.errors.version' => 'This version of the app is not compatible with the program shop. Update to the latest version and try again.',
			'boutique.marketingUpdating.title' => 'We\'re modernizing the Routine store.',
			'boutique.marketingUpdating.description' => 'Come back later for some exciting new programs!',
			'login.title' => 'Login',
			'login.tabs.signIn' => 'Sign in',
			'login.tabs.signUp' => 'Sign up',
			'login.errors.generic' => 'An unexpected error has occurred. Try again in a few minutes.',
			'login.errors.username' => 'Your username must be 8-10 characters long and can include only alphanumeric characters, hyphens, and underscores.',
			'login.errors.usernameTaken' => 'This username is already taken.',
			'login.errors.email' => 'Enter a valid email address.',
			'login.errors.password.invalid.header' => 'Your password must:',
			'login.errors.password.invalid.length' => '- Be at least 8 characters long',
			'login.errors.password.invalid.uppercase' => '- Contain at least one uppercase character',
			'login.errors.password.invalid.lowercase' => '- Contain at least one lowercase character',
			'login.errors.password.invalid.number' => '- Contain at least one number',
			'login.errors.password.invalid.specialCharacter' => '- Contain at least one special character',
			'login.errors.noInternet' => 'No Internet connection.',
			'login.errors.passwordRequired' => 'Enter your password.',
			'login.errors.confirmPasswordRequired' => 'Enter your password again.',
			'login.errors.passwordMismatch' => 'Passwords do not match.',
			'login.fields.email.label' => 'Email',
			'login.fields.email.hint' => 'john.doe@example.com',
			'login.fields.password.label' => 'Password',
			'login.fields.password.hint' => 'Password',
			'login.fields.username.label' => 'Username',
			'login.fields.username.hint' => 'Username',
			'login.fields.confirmPassword.label' => 'Confirm password',
			'login.buttons.signIn' => 'Sign in',
			'login.buttons.signUp' => 'Sign up',
			'login.buttons.showPassword' => 'Show password',
			'login.buttons.hidePassword' => 'Hide password',
			'login.buttons.dismissKeyboard' => 'Dismiss keyboard',
			'login.upsell.title' => 'Not signed in',
			'login.upsell.subtitle' => 'Sign in to gain access to group workouts, cross-device synchronization and much more.',
			'login.verifyEmail.title' => 'We\'ve sent you a verification email',
			'login.verifyEmail.description' => 'Check your inbox to confirm your email. Once you\'re done, come back and tap the button to sign in.',
			'login.verifyEmail.done' => 'I\'ve verified my email',
			'login.verifyEmail.notVerified' => 'Verify your email address and try again.',
			'login.presentation.signInTitle' => 'Sign in to Gym Bro',
			'login.presentation.signInSubtitle' => 'Pick up your workouts and keep your progress in sync.',
			'login.presentation.signUpTitle' => 'Create your profile',
			'login.presentation.signUpSubtitle' => 'Save your progress and share workouts with your friends.',
			'login.presentation.passwordRequirements' => 'At least 8 characters, with an uppercase letter, a lowercase letter, a number and a special character.',
			'login.presentation.noAccount' => 'Don’t have an account?',
			'login.presentation.haveAccount' => 'Already have an account?',
			'login.recovery.forgot' => 'Forgot password?',
			'login.recovery.title' => 'Reset your password',
			'login.recovery.description' => 'Enter your email and we’ll send you a link to choose a new password on the Gym Bro website.',
			'login.recovery.send' => 'Send reset link',
			'login.recovery.sentTitle' => 'Check your email',
			'login.recovery.sentDescription' => 'If an account exists for this address, you’ll receive a password reset link. After updating it on the website, come back here to sign in.',
			'login.recovery.checkSpam' => 'Check your spam folder too. If you can’t find the message, go back and try again.',
			'login.recovery.backToSignIn' => 'Back to sign in',
			'login.recovery.error' => 'We couldn’t send the link. Wait a few minutes and try again.',
			'sync.conflict.title' => 'Conflicting data found',
			'sync.conflict.message' => 'Press OK to download the data in the cloud and overwrite the local data. Press Cancel to erase the data in the cloud and upload the local data.',
			'sync.overwrite.title' => 'Older data found',
			'sync.overwrite.message' => 'Do you wish to overwrite the data in the cloud with your local data?',
			'sync.inProgress' => 'Synchronizing',
			'bodyMeasurement.neck.label' => 'Neck',
			'bodyMeasurement.waist.label' => 'Waist',
			'bodyMeasurement.bodyFat.label' => 'Body fat percentage',
			'bodyMeasurement.shoulder.label' => 'Shoulder',
			'bodyMeasurement.chest.label' => 'Chest',
			'bodyMeasurement.leftBicep.label' => 'Left biceps',
			'bodyMeasurement.rightBicep.label' => 'Right biceps',
			'bodyMeasurement.leftForearm.label' => 'Left forearm',
			'bodyMeasurement.rightForearm.label' => 'Right forearm',
			'bodyMeasurement.abdomen.label' => 'Abdomen',
			'bodyMeasurement.hips.label' => 'Hips',
			'bodyMeasurement.leftThigh.label' => 'Left thigh',
			'bodyMeasurement.rightThigh.label' => 'Right thigh',
			'bodyMeasurement.leftCalf.label' => 'Left calf',
			'bodyMeasurement.rightCalf.label' => 'Right calf',
			'onboarding.buttons.skip' => 'Skip for now',
			'onboarding.buttons.next' => 'Next',
			'onboarding.buttons.done' => 'Let\'s start!',
			'onboarding.welcome.title' => 'Welcome to Gym Bro',
			'onboarding.welcome.text' => 'Your workout buddy.\nWe need to check a few permissions before starting.',
			'onboarding.notifications.title' => 'Notifications',
			'onboarding.notifications.text' => 'Allow Gym Bro to send you rest time notifications.',
			'onboarding.notifications.notifications' => 'Notifications',
			'onboarding.notifications.exactAlarm' => 'Immediate notifications (for rest time)',
			'onboarding.camera.title' => 'Camera and gallery',
			'onboarding.camera.text' => 'Allow Gym Bro to access your camera in order to scan barcodes in the food tracker.',
			'onboarding.camera.camera' => 'Camera',
			'onboarding.camera.gallery' => 'Gallery',
			'onboarding.done.title' => 'Get started',
			'onboarding.done.text' => 'We hope you\'ll enjoy Gym Bro.',
			'onboarding.login.title' => 'Sign in',
			'onboarding.login.text' => 'Sync your data, see your friends\' workouts, and much more!',
			'nags.routines.title' => 'You\'ve been using Gym Bro for a while now',
			'nags.routines.subtitle' => 'With the Pro version, you can create unlimited routines. Become a Pro Bro and take your workouts to the next level!',
			'nags.button' => 'Join now!',
			'nags.library.title' => 'You\'ve been exploring Gym Bro for a while now.',
			'nags.library.subtitle' => 'With the Pro version, you can create unlimited exercises. Become a Pro Bro and take your workouts to the next level!',
			'nags.history.title' => 'You\'ve been enjoying Gym Bro for a while now, it appears!',
			'nags.history.subtitle' => 'With the Pro version, you can start unlimited workouts. Become a Pro Bro and take your workouts to the next level!',
			'nags.food.title' => 'Woah, hold on! You can\'t do that yet.',
			'nags.food.subtitle' => 'With the Pro version, you can see historical data. Become a Pro Bro and take your nutrition to the next level!',
			'feed.title' => 'Feed',
			'feed.empty.title' => 'Your feed is empty',
			'feed.empty.text' => 'Start some workouts or log some meals to see them here.',
			'feed.startWorkout' => 'Choose a workout',
			'feed.workout.title.you' => 'You',
			'feed.workout.title.unknown' => 'Unknown User',
			'feed.workout.subtitle.you' => 'completed a workout',
			'feed.workout.subtitle.friend' => 'completed a workout',
			'feed.achievement.title.you' => 'You',
			'feed.achievement.subtitle.you' => 'unlocked an achievement',
			'feed.achievement.subtitle.friend' => 'unlocked an achievement',
			'feed.userButton.loading' => 'Loading user profile...',
			'feed.userButton.error' => 'Unable to load profile',
			'feed.noSync.text' => 'Syncing is paused: you are not connected to the Internet. It may take a few minutes. Don\'t worry, the data will be kept locally and transferred later.',
			'feed.noMoreData' => 'You\'ve reached the end of your feed :)',
			'feed.loadMore' => 'Load more',
			'feed.suggestedRoutines' => 'Suggested routines',
			'feed.suggestions.start' => 'Start',
			'feed.suggestions.assignedBy' => ({required Object name}) => 'Assigned by ${name}',
			'feed.suggestions.assignedByTrainer' => 'Assigned by your trainer',
			'feed.loadError.title' => 'Unable to load activities',
			'feed.loadError.text' => 'Check your connection and try again.',
			'workoutPage.title' => 'Work Out',
			'pro.title' => 'PRO',
			'userProfile.title' => 'Profile',
			'userProfile.addFriend' => 'Add Friend',
			'userProfile.unfriend' => 'Unfriend',
			'userProfile.requestSent' => 'Friend Request Sent',
			'userProfile.cancelRequestConfirmation.title' => 'Cancel friend request?',
			'userProfile.cancelRequestConfirmation.keep' => 'Keep request',
			'userProfile.cancelRequestConfirmation.confirm' => 'Cancel request',
			'userProfile.cancelRequestConfirmation.error' => 'Could not cancel the friend request. Please try again.',
			'userProfile.accept' => 'Accept',
			'userProfile.decline' => 'Decline',
			'userProfile.unfriendConfirmation.title' => ({required Object name}) => 'Unfriend ${name}?',
			'userProfile.unfriendConfirmation.subtitle' => 'They will no longer appear in your feed, and you won\'t appear in theirs.',
			'userProfile.unfriendConfirmation.confirm' => 'Unfriend',
			'userProfile.unfriendConfirmation.cancel' => 'Cancel',
			'userProfile.reject' => 'Reject',
			'userProfile.stats.friends' => 'Friends',
			'userProfile.stats.workouts' => 'Workouts',
			'userProfile.stats.achievements' => 'Achievements',
			'userProfile.feed.unavailable.title' => 'Workouts not visible',
			'userProfile.feed.unavailable.description' => 'Workout data is only visible to friends.',
			'userProfile.edit.tooltip' => 'Edit Profile',
			'userProfile.edit.title' => 'Edit Profile',
			'userProfile.edit.fullName' => 'Full Name',
			'userProfile.edit.fullNameHint' => 'Enter your full name',
			'userProfile.edit.profilePicture' => 'Profile Picture',
			'userProfile.edit.changePicture' => 'Change Picture',
			'userProfile.edit.removePicture' => 'Remove Picture',
			'userProfile.edit.uploading' => 'Uploading...',
			'userProfile.edit.saving' => 'Saving...',
			'userProfile.edit.success' => 'Profile updated successfully!',
			'userProfile.edit.error' => 'Error updating profile',
			'userProfile.edit.cropTitle' => 'Crop Photo',
			'userProfile.edit.cropInstructions' => 'Drag and pinch to position your photo',
			'userProfile.edit.done' => 'Done',
			'userProfile.crop.buttons.confirm' => 'Crop',
			'userProfile.crop.buttons.cancel' => 'Cancel',
			'userProfile.error.title' => 'Error',
			'userProfile.error.retry' => 'Retry',
			'userProfile.errors.noInternet' => 'You appear to be offline. Check your Internet connection and try again.',
			'friendRequests.title' => 'Friend Requests',
			'friendRequests.subtitle' => 'sent you a friend request',
			'friendRequests.empty.title' => 'No friend requests',
			'friendRequests.empty.text' => 'You don\'t have any pending friend requests right now.',
			'profileSearch.title' => 'Search Profiles',
			'profileSearch.searchHint' => 'Search username...',
			'profileSearch.noResults.title' => 'No profiles found',
			'profileSearch.noResults.text' => 'Try searching for a different username.',
			'you' => 'You',
			'error.title' => 'An unknown error occurred',
			'error.retry' => 'Try again',
			'error.logs' => 'Open logs',
			'legacyWorkoutRecovery.title' => 'Previous workout to recover',
			'legacyWorkoutRecovery.action' => 'Recover in this account',
			'legacyWorkoutRecovery.confirm' => ({required Object account}) => 'Recover this workout in ${account}? It will become the ongoing workout for this account.',
			'legacyWorkoutRecovery.guest' => 'Guest',
			'legacyWorkoutRecovery.failed' => 'The workout could not be recovered. Check that this account has no ongoing workout, then try again.',
			'friendsList.loadMore' => 'Load more',
			'friendsList.title' => 'Friends',
			'friendsList.empty' => 'No friends yet',
			'friendsList.emptyDescription' => 'Accepted friendships will appear here.',
			'friendsList.historyTitle' => ({required Object name}) => '${name}’s achievements',
			'friendsList.historyEmpty' => 'No achievements yet',
			'friendsList.historyEmptyDescription' => 'This friend’s unlocked achievements will appear here.',
			'friendsList.unknownAchievement' => 'Unknown achievement',
			'friendsList.accessDenied' => 'History is only available for your friends.',
			'social.notifications' => 'Notifications',
			'social.post' => 'Post',
			'social.comments' => 'Comments',
			'social.comment' => 'Comment',
			'social.like' => 'Like',
			'social.unlike' => 'Unlike',
			'social.send' => 'Send',
			'social.edit' => 'Edit',
			'social.delete' => 'Delete',
			'social.more' => 'Load more',
			'social.private' => 'Only me',
			'social.friends' => 'Friends',
			'social.visibility' => 'Visibility',
			'social.pending' => 'Change waiting to sync',
			'social.unpublished' => 'Waiting to publish',
			'social.unavailable' => 'Content unavailable',
			'social.error' => 'Something went wrong. Please try again.',
			'social.empty' => 'There is nothing to show.',
			'social.block' => 'Block user',
			'social.unblock' => 'Unblock',
			'social.blockedUsers' => 'Blocked users',
			'social.report' => 'Report user',
			'social.reports' => 'My reports',
			'social.reason' => 'Reason (required)',
			'social.reportSent' => 'Report submitted',
			'social.blockConfirm' => 'Block this user? Your friendship and requests will be removed.',
			'social.cancel' => 'Cancel',
			'social.confirm' => 'Confirm',
			'social.received' => 'Received',
			'social.reviewing' => 'Under review',
			'social.resolved' => 'Resolved',
			'social.dismissed' => 'Dismissed',
			'social.friendRequest' => 'Sent you a friend request',
			'social.friendAccepted' => 'Accepted your friend request',
			'social.likedPost' => 'Liked your post',
			'social.commentedPost' => 'Commented on your post',
			'social.achievementUnlocked' => 'Unlocked an achievement',
			'social.reportUpdated' => 'Your report status changed',
			'social.accept' => 'Accept',
			'social.reject' => 'Decline',
			'social.signIn' => 'Sign in to continue',
			'social.save' => 'Save',
			'social.push' => 'Push notifications',
			'social.pushDescription' => 'Requests, interactions, achievements and reports',
			'social.pushDisabled' => 'Push notifications are not configured on this device',
			'social.trainerPlan' => 'Your trainer published a plan or revision',
			'hydration.title' => 'Water',
			'hydration.drinking' => 'Water drunk',
			'hydration.food' => 'From foods',
			'hydration.add' => 'Add water',
			'hydration.custom' => 'Custom amount',
			'hydration.amount' => 'Amount (ml)',
			'hydration.time' => 'Time',
			'hydration.goal' => 'Daily goal (ml)',
			'hydration.setGoal' => 'Set goal',
			'hydration.noGoal' => 'No goal set',
			'hydration.optionalGoal' => 'Leave blank to remove the goal',
			'hydration.save' => 'Save',
			'hydration.cancel' => 'Cancel',
			'hydration.delete' => 'Delete',
			'hydration.edit' => 'Edit',
			'hydration.invalid' => 'Enter a valid positive amount',
			'hydration.future' => 'Choose a time in the past',
			'hydration.connect' => 'Connect to Health',
			'hydration.disconnect' => 'Disable Health export',
			'hydration.disabled' => 'Health export disabled',
			'hydration.synced' => 'Water synced with Health',
			'hydration.pending' => 'Health export pending: check permissions and retry',
			'hydration.unavailable' => 'Health service unavailable',
			'hydration.syncing' => 'Syncing with Health…',
			'hydration.empty' => 'No drinking water recorded',
			'hydration.error' => 'Unable to save. Try again.',
			'hydration.natural' => 'Still water',
			'hydration.sparkling' => 'Sparkling water',
			'hydration.cucumber' => 'Cucumber with peel, raw',
			'hydration.tomato' => 'Tomato, red, raw',
			'hydration.watermelon' => 'Watermelon, raw',
			'hydration.apple' => 'Apple with skin, raw',
			'hydration.source' => 'Source: USDA SR Legacy',
			'hydration.waterPer100' => 'Water (ml per 100 g/ml)',
			'hydration.history' => 'Water history',
			'hydration.permissionDenied' => 'Water is saved in your diary. To also add it to Health, allow access in Settings → Permissions.',
			'reports.title' => 'Progress reports',
			'reports.day' => 'Day',
			'reports.week' => 'Week',
			'reports.month' => 'Month',
			'reports.training' => 'Training',
			'reports.nutrition' => 'Nutrition',
			'reports.measurements' => 'Body measurements',
			'reports.preview' => 'Preview report',
			'reports.save' => 'Save PDF',
			'reports.share' => 'Share',
			'reports.reference' => 'Reference date',
			'reports.chooseSection' => 'Select at least one section.',
			'reports.empty' => 'No records in this period.',
			'reports.missing' => 'No records',
			'reports.unavailable' => 'Not available',
			'reports.error' => 'Unable to generate the report. Please retry.',
			'reports.exportError' => 'Unable to export the PDF. Please retry.',
			'reports.retry' => 'Retry',
			'reports.saved' => 'PDF saved',
			'reports.generated' => 'Generated',
			'reports.daily' => 'Daily detail',
			'reports.summary' => 'Summary',
			'reports.sessions' => 'Sessions',
			'reports.sets' => 'Completed sets',
			'reports.reps' => 'Repetitions',
			'reports.load' => 'Load',
			'reports.duration' => 'Duration',
			'reports.distance' => 'Distance',
			'reports.volume' => 'Volume (positive loads × repetitions)',
			'reports.exercise' => 'Exercise',
			'reports.status' => 'Status',
			'reports.done' => 'Completed',
			'reports.pending' => 'Not completed',
			'reports.superset' => 'Superset',
			'reports.continuation' => 'Continuation',
			'reports.food' => 'Food / meal',
			'reports.quantity' => 'Quantity',
			'reports.calories' => 'Calories',
			'reports.protein' => 'Protein',
			'reports.carbs' => 'Carbohydrates',
			'reports.fat' => 'Fat',
			'reports.total' => 'Total',
			'reports.average' => 'Average per recorded day',
			'reports.coverage' => 'Recorded days',
			'reports.first' => 'First',
			'reports.last' => 'Last',
			'reports.change' => 'Change',
			'reports.value' => 'Value',
			'reports.date' => 'Date',
			'reports.goal' => 'Saved daily goal',
			'reports.criteria' => 'Nutrition averages use days with food records only; zero values are included. Totals describe logged food, not necessarily complete days. Missing records are not zero. Workout totals include completed sets only; volume includes positive repetition loads only. Measurement changes use the first and last actual observations in this period. No interpolation or predicted measurements. Body charts show the last actual measurement of each day.',
			'reports.partial' => 'Period in progress: only records available at generation are included.',
			'reports.units' => 'Units',
			'reports.activityChart' => 'Completed sets by day',
			'reports.calorieChart' => 'Logged calories by day',
			'reports.chartNote' => 'Dots show recorded values. Missing days are left blank; no interpolation.',
			'reports.privacy' => 'Local report · No medical or nutritional assessment',
			'reports.selection' => 'Report contents',
			'reports.weight' => 'Weight',
			'reports.configureDescription' => 'Create a progress report to save or share with your trainer or nutritionist.',
			'reports.period' => 'Period',
			'reports.includedPeriod' => 'Period included in the report',
			'reports.weekReferenceHint' => 'Choose any day in the week to include.',
			'reports.monthReferenceHint' => 'Choose any day in the month to include.',
			_ => null,
		} ?? switch (path) {
			'reports.selectionHint' => 'Choose one or more sections to include in the PDF.',
			'reports.previewTitle' => 'PDF preview',
			'plateau.title' => 'Possible plateaus',
			'plateau.intro' => 'Last 8 weeks, only considering completed normal sets. The following are suggestions based on your data, but they may not be accurate.',
			'plateau.criteria' => 'Requires 6 comparable sessions over at least 28 days and 4 calendar weeks, the latest within 14 days, with no gaps over 21 days. The first 3 sessions provide the median reference. Progress means +2.5% load without fewer reps, +1 rep at equivalent load (±1%), or +5% volume. For bodyweight: +1 best-set rep or +5% total reps.',
			'plateau.possiblePlateau' => 'Possible plateau',
			'plateau.progressing' => 'No possible plateau detected',
			'plateau.insufficientData' => 'More data needed: record at least 6 comparable sessions over 4 weeks.',
			'plateau.stale' => 'No recent comparable sessions: resume recording this exercise before assessing progress.',
			'plateau.unsupported' => 'Not assessed: assistance, time and distance do not provide comparable load and repetition metrics.',
			'plateau.incomparable' => 'Not assessed: exercise identity, definition or multiple sessions on the same day prevent a reliable comparison.',
			'plateau.empty' => 'More data needed. Record completed sets across several weeks to assess your progress.',
			'plateau.period' => 'Period',
			'plateau.sessions' => 'Sessions',
			'plateau.sets' => 'Normal sets per session',
			'plateau.reference' => 'Reference: median of first 3 sessions',
			'plateau.load' => 'Maximum load',
			'plateau.reps' => 'Reps at maximum load',
			'plateau.bestReps' => 'Maximum reps per set',
			'plateau.totalReps' => 'Total reps',
			'plateau.volume' => 'Session volume',
			'plateau.data' => 'Sessions used',
			'plateau.other' => 'Other exercises',
			'plateau.volumeInfo' => 'Volume = sum of load × reps for the selected sets. Bodyweight is assessed using repetitions only.',
			'progression.title' => 'Guided progression',
			'progression.configure' => 'Set progression',
			'progression.remove' => 'Remove progression',
			'progression.lastTime' => 'Last time',
			'progression.noHistory' => 'Complete a session to see your last performance',
			'progression.goal' => 'Today\'s goal',
			'progression.double' => 'Double progression',
			'progression.cyclic' => 'Cyclic linear progression',
			'progression.minReps' => 'Minimum reps',
			'progression.maxReps' => 'Maximum reps',
			'progression.repsPerStep' => 'Reps per step',
			'progression.startingWeight' => 'Starting weight',
			'progression.weightPerStep' => 'Weight increase per step',
			'progression.weightPerCycle' => 'Starting weight increase per cycle',
			'progression.preview' => 'Next goals',
			'progression.save' => 'Save',
			'progression.invalid' => 'Check the values and the number of working sets',
			'progression.step' => ({required Object cycle, required Object step}) => 'Cycle ${cycle}, step ${step}',
			'progression.advance' => 'Advance manually',
			'paywall.title' => 'GymBro Pro',
			'paywall.subtitle' => 'Choose a subscription to unlock Pro features.',
			'paywall.loadError' => 'Subscriptions could not be loaded. Please try again.',
			'paywall.empty' => 'No subscriptions are available right now. Please try again later.',
			'paywall.trialPeriod.week' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Free trial: ${n} week', other: 'Free trial: ${n} weeks', ), 
			'paywall.trialPeriod.month' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Free trial: ${n} month', other: 'Free trial: ${n} months', ), 
			'paywall.trialPeriod.year' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Free trial: ${n} year', other: 'Free trial: ${n} years', ), 
			'paywall.trialPeriod.day' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Free trial: ${n} day', other: 'Free trial: ${n} days', ), 
			'paywall.autoRenewNotice.week' => ({required Object price}) => 'Renews automatically at ${price} per week until cancelled.',
			'paywall.autoRenewNotice.month' => ({required Object price}) => 'Renews automatically at ${price} per month until cancelled.',
			'paywall.autoRenewNotice.year' => ({required Object price}) => 'Renews automatically at ${price} per year until cancelled.',
			'paywall.autoRenewNotice.day' => ({required Object price}) => 'Renews automatically at ${price} per day until cancelled.',
			'paywall.purchaseError.title' => 'Purchase unsuccessful',
			'paywall.purchaseError.subtitle' => 'The purchase could not be completed. Please try again.',
			'paywall.restoreError.title' => 'Restore unsuccessful',
			'paywall.restoreError.subtitle' => 'Purchases could not be restored. Please try again.',
			'paywall.actions.subscribe' => 'Subscribe',
			'paywall.actions.restorePurchase' => 'Restore purchases',
			'paywall.actions.termsOfService' => 'Terms of service',
			'paywall.actions.privacyPolicy' => 'Privacy policy',
			'routineImport.summary' => 'Program contents',
			'routineImport.summaryDescription' => 'Import a personal copy. The shared program stays unchanged.',
			'routineImport.days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 training day', other: '${n} training days', ), 
			'routineImport.exercises' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 exercise', other: '${n} exercises', ), 
			'routineImport.sets' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 set', other: '${n} sets', ), 
			'routineImport.preview' => 'Workout preview',
			'routineImport.day' => 'Training day',
			'routineImport.dayDescription' => 'Choose a day to preview. The whole program will be imported.',
			'routineImport.programNotes' => 'Program notes',
			'routineImport.workoutNotes' => 'Workout notes',
			'routineImport.exerciseList' => 'Exercises',
			'routineImport.emptyTitle' => 'No exercises in this workout',
			'routineImport.emptyDescription' => 'This day has no prescribed exercises yet.',
			'routineImport.noSets' => 'No sets prescribed',
			'routineImport.custom' => 'Custom exercise',
			'routineImport.assistance' => 'Assistance',
			'routineImport.rest' => ({required Object duration}) => '${duration} rest',
			'routineImport.setNumber' => ({required Object number}) => 'Set ${number}',
			'routineImport.seconds' => ({required Object count}) => '${count} s',
			'routineImport.loadingTitle' => 'Opening shared program',
			'routineImport.loadingDescription' => 'Loading the workouts and their prescriptions.',
			'routineImport.unavailableTitle' => 'Program unavailable',
			'routineImport.retry' => 'Try again',
			'routineImport.proRequired' => 'Importing shared routines requires Gym Bro Pro.',
			'routineImport.importing' => 'Importing…',
			'routineImport.loadError' => 'Something went wrong. Please try again shortly.',
			'routineImport.networkError' => 'Unable to connect. Check your connection and try again.',
			_ => null,
		};
	}
}
