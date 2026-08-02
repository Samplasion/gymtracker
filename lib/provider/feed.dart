import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed.g.dart';

@riverpod
Future<List<FeedItem>> feed(Ref ref) async {
  final feedService = FeedService(Get.find<DatabaseService>());
  return feedService
      .getFeedItems(
        sources: {FeedSource.ownHistory, FeedSource.ownAchievements},
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      )
      .then((result) => result.feed);
}
