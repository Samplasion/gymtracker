// ignore: dangling_library_doc_comments
/// Flutter icons GymTracker
/// Copyright (C) 2024 by original authors @ fluttericon.com, fontello.com
/// This font was generated by FlutterIcon.com, which is derived from Fontello.
///
/// To use this font, place it in your fonts/ directory and include the
/// following in your pubspec.yaml
///
/// flutter:
///   fonts:
///    - family:  GymTracker
///      fonts:
///       - asset: fonts/GymTracker.ttf
///
///
/// * Font Awesome 5, Copyright (C) 2016 by Dave Gandy
///         Author:    Dave Gandy
///         License:   SIL (https://github.com/FortAwesome/Font-Awesome/blob/master/LICENSE.txt)
///         Homepage:  http://fortawesome.github.com/Font-Awesome/
///
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class CompoundIcon extends StatelessWidget {
  final IconData main;
  final IconData accessory;
  final double mainSize;
  final double accessorySize;
  final double holeSize;

  const CompoundIcon({
    super.key,
    required this.main,
    required this.accessory,
    this.mainSize = 24,
    this.accessorySize = 12,
    this.holeSize = 0.7,
  });

  const CompoundIcon.sized({
    super.key,
    required this.main,
    required this.accessory,
    double size = 24,
    this.holeSize = 0.7,
  })  : mainSize = size,
        accessorySize = size * 0.7;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return RadialGradient(
              center: AlignmentDirectional.bottomEnd
                  .resolve(Directionality.of(context)),
              // radius: 0.37,
              radius: 1,
              colors: [
                Colors.white.withAlpha(0),
                Colors.white,
              ],
              stops: [holeSize, holeSize],
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 4, 4),
            child: Icon(main, size: mainSize),
          ),
        ),
        Positioned.directional(
          textDirection: Directionality.of(context),
          bottom: 0,
          end: -2,
          child: Icon(accessory, size: accessorySize),
        ),
      ],
    );
  }
}

class GTIcons {
  GTIcons._();

  static const _kFontFam = 'GymTracker';
  static const String? _kFontPkg = null;

  static const compound = _GymTrackerCompoundIcons();

  static const IconData _fire =
      IconData(0xf06d, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static const IconData achievements = Icons.emoji_events_rounded;
  static const IconData achievement_locked = Icons.lock_rounded;
  static const IconData add_exercise = Icons.add_rounded;
  static const IconData add_food = Icons.post_add_rounded;
  static const IconData add_superset = Icons.add_circle_rounded;
  static const IconData add_to_faves = Icons.star_border_rounded;
  static const IconData add_to_superset = Icons.group_work_rounded;
  static const IconData advanced = Icons.settings_rounded;
  static const IconData app_icon = Icons.fitness_center_rounded;
  static const IconData appearance = Icons.palette_rounded;
  static const IconData backup = Icons.save_alt_rounded;
  static const IconData breadcrumb_chevron = Icons.chevron_right_rounded;
  static const IconData calendar = Icons.calendar_month_rounded;
  static const IconData camera = Icons.camera_rounded;
  static const IconData cardio = Icons.directions_bike_rounded;
  static const IconData cardio_timer = Icons.alarm_rounded;
  static const IconData checkbox_off = Icons.check_box_outline_blank_rounded;
  static const IconData checkbox_on = Icons.check_box_rounded;
  static const IconData clear = Icons.clear_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData combine = Icons.merge_type_rounded;
  static const IconData continuation = Icons.add_rounded;
  static const IconData create_exercise = Icons.add_rounded;
  static const IconData create_folder = Icons.create_new_folder_rounded;
  static const IconData create_routine = Icons.add_rounded;
  static const IconData custom_exercises = Icons.star_rounded;
  static const IconData debug = Icons.bug_report_rounded;
  static const IconData decrease = Icons.remove_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData delete_forever = Icons.delete_forever_rounded;
  static const IconData distance = Icons.directions_run_rounded;
  static const IconData done = Icons.done_rounded;
  static const IconData drag_handle = Icons.drag_handle;
  static const IconData dropdown = Icons.arrow_drop_down_rounded;
  static const IconData duration = Icons.access_time_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData empty_workout = Icons.timer_rounded;
  static const IconData explanation = Icons.note_alt_outlined;
  static const IconData export = Icons.file_upload_rounded;
  static const IconData favorite = Icons.star_rounded;
  static const IconData filter_list = Icons.filter_list_rounded;
  static const IconData folder_closed = Icons.folder_rounded;
  static const IconData folder_open = Icons.folder_open_rounded;
  static const IconData folder_root = Icons.home_rounded;
  static const IconData food = Icons.fastfood_rounded;
  static const IconData food_categories = Icons.local_dining_rounded;
  static const IconData gallery = Icons.photo_library_rounded;
  static const IconData help = Icons.help_rounded;
  static const IconData highlight = Icons.highlight_rounded;
  static const IconData history = Icons.history_rounded;
  static const IconData home = Icons.home_rounded;
  static const IconData import = Icons.file_download_rounded;
  static const IconData increase = Icons.add_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData info_outline = Icons.info_outline;
  static const IconData keyboard = Icons.keyboard_rounded;
  static const IconData library = Icons.local_library_rounded;
  static const IconData logs = Icons.assignment_rounded;
  static const IconData lt_chevron = Icons.chevron_right_rounded;
  static const IconData migration = Icons.keyboard_double_arrow_right_rounded;
  static const IconData nextDay = Icons.arrow_forward;
  static const IconData no_routine = Icons.circle_outlined;
  static const IconData notes = Icons.note_alt_outlined;
  static const IconData notes_add = Icons.note_add_rounded;
  static const IconData notification_dialog =
      Icons.notification_important_rounded;
  static const IconData nutrition_goal = Icons.outlined_flag_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData permissions = Icons.security_rounded;
  static const IconData previousDay = Icons.arrow_back;
  static const IconData profile = Icons.person_rounded;
  static const IconData remove_from_faves = Icons.star_rounded;
  static const IconData reorder = Icons.compare_arrows_rounded;
  static const IconData replace = Icons.refresh_rounded;
  static const IconData reps = Icons.numbers_rounded;
  static const IconData reset = Icons.replay_rounded;
  static const IconData resume = Icons.play_arrow_rounded;
  static const IconData routines = Icons.fitness_center_rounded;
  static const IconData rpe = Icons.fitness_center_rounded;
  static const IconData save = Icons.save_rounded;
  static const IconData scan_barcode = Icons.qr_code_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData sets = Icons.numbers_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData showDatePicker = Icons.calendar_today;
  static const IconData skip = Icons.skip_next_rounded;
  static const IconData stats = Icons.query_stats_rounded;
  static const IconData stopwatch = Icons.timer_rounded;
  static const IconData streak_rest = Icons.nightlight_round;
  static const IconData streak_weeks = _fire;
  static const IconData superset = Icons.layers_rounded;
  static const IconData time = Icons.timer_rounded;
  static const IconData units = Icons.numbers_rounded;
  static const IconData volume = Icons.line_weight_rounded;
  static const IconData weight_calculator = Icons.calculate_rounded;
  static const IconData weight_down = Icons.trending_down_rounded;
  static const IconData weight_flat = Icons.trending_flat_rounded;
  static const IconData weight_up = Icons.trending_up_rounded;
  static const IconData workout = Icons.fitness_center_rounded;
}

class _GymTrackerCompoundIcons {
  const _GymTrackerCompoundIcons();

  Widget get add_food_category => const CompoundIcon.sized(
        main: GTIcons.food_categories,
        accessory: Icons.add_rounded,
      );
}
