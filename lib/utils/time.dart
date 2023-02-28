// Throughout this file, [seconds] refers to a number
// that encodes mm:ss as mmss, mmm:ss as mmmss and so on.

String stringifyTime(int seconds) {
  final mins = (seconds ~/ 100) + ((seconds % 100) ~/ 60);
  final secs = (seconds % 100) % 60;
  return "$mins:$secs";
}

int parseTime(String time) {
  assert(RegExp(r'^\d{2,}:\d{2}$').hasMatch(time),
      'The string must be in the format "[mm+]:[ss]"');
  final mins = int.parse(time.split(":").first);
  final secs = int.parse(time.split(":").last);
  return mins * 100 + secs;
}

Duration timeToDuration(int seconds) {
  final mins = (seconds ~/ 100);
  final secs = (seconds % 100);
  return Duration(minutes: mins, seconds: secs);
}
