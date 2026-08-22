import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/workout.dart';

enum FriendRequestStatus { pending, accepted }

class Friend {
  final String id;
  final String username;
  final String? email;
  final String? fullName;

  Friend({
    required this.id,
    required this.username,
    this.email,
    this.fullName,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'full_name': fullName,
      };
}

class FriendRelation {
  final String senderId;
  final String receiverId;
  final FriendRequestStatus status;
  final DateTime createdAt;

  FriendRelation({
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  factory FriendRelation.fromJson(Map<String, dynamic> json) {
    return FriendRelation(
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: FriendRequestStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'sender_id': senderId,
    'receiver_id': receiverId,
    'status': status.name,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}

class FriendPublicData {
  final Friend friend;
  final List<AchievementCompletion> achievements;
  final List<Workout> workouts;
  final int friendCount;

  FriendPublicData({
    required this.friend,
    required this.achievements,
    required this.workouts,
    required this.friendCount,
  });
}
