import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/provider/friend.dart';

void main() {
  group("Friend Model Tests", () {
    test("Friend serialization", () {
      final friend = Friend(
        id: "user_1",
        username: "fit_warrior",
        email: "warrior@example.com",
        fullName: "Fit Warrior",
      );
      final json = friend.toJson();
      expect(json["id"], "user_1");
      expect(json["username"], "fit_warrior");
      expect(json["email"], "warrior@example.com");
      expect(json["full_name"], "Fit Warrior");

      final parsed = Friend.fromJson(json);
      expect(parsed.id, "user_1");
      expect(parsed.username, "fit_warrior");
      expect(parsed.email, "warrior@example.com");
      expect(parsed.fullName, "Fit Warrior");
    });

    test("FriendRelation serialization", () {
      final relation = FriendRelation(
        senderId: "user_1",
        receiverId: "user_2",
        status: FriendRequestStatus.pending,
        createdAt: DateTime.utc(2026, 8, 3, 12, 0, 0),
      );

      final json = relation.toJson();
      expect(json["sender_id"], "user_1");
      expect(json["receiver_id"], "user_2");
      expect(json["status"], "pending");
      expect(json["created_at"], "2026-08-03T12:00:00.000Z");

      final parsed = FriendRelation.fromJson(json);
      expect(parsed.senderId, "user_1");
      expect(parsed.receiverId, "user_2");
      expect(parsed.status, FriendRequestStatus.pending);
      expect(parsed.createdAt.toIso8601String(), "2026-08-03T12:00:00.000Z");
    });

    test("FriendState copyWith", () {
      final friend1 = Friend(id: "1", username: "user1");
      final friend2 = Friend(id: "2", username: "user2");
      final state = FriendState(
        friends: [friend1],
        pendingReceived: [],
        pendingSent: [],
      );

      final newState = state.copyWith(friends: [friend1, friend2]);
      expect(newState.friends.length, 2);
      expect(newState.pendingReceived.isEmpty, true);
    });

    test("FriendPublicData holds friendCount", () {
      final friend = Friend(id: "1", username: "user1");
      final publicData = FriendPublicData(
        friend: friend,
        achievements: [],
        workouts: [],
        friendCount: 5,
      );

      expect(publicData.friendCount, 5);
      expect(publicData.friend.username, "user1");
    });
  });
}
