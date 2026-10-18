import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncable/syncable.dart';

class TestSyncManager extends SyncManager<GTDatabase> {
  TestSyncManager(
    GTDatabase db,
    SupabaseClient client, {
    Duration syncInterval = const Duration(hours: 1),
  }) : super(
         localDatabase: db,
         supabaseClient: client,
         syncInterval: syncInterval,
         maxRows: 2,
       );
  final errors = <Object>[];
  final finishes = <bool>[];
  @override
  void onSyncError(Object error, StackTrace stack) => errors.add(error);
  @override
  void onSyncFinished({required bool success}) => finishes.add(success);
}

class Backend {
  final rows = <String, Map<String, dynamic>>{};
  Future<void> Function(http.Request)? beforeRequest;
  int failUploads = 0;
  int requestsInFlight = 0;
  int maxRequestsInFlight = 0;
  int uploads = 0;
  late final client = SupabaseClient(
    'https://sync.test',
    'test-key',
    httpClient: MockClient(handle),
  );

  Future<http.Response> handle(http.Request request) async {
    requestsInFlight++;
    if (requestsInFlight > maxRequestsInFlight) {
      maxRequestsInFlight = requestsInFlight;
    }
    try {
      await beforeRequest?.call(request);
      if (request.method == 'POST') {
        uploads++;
        if (failUploads > 0) {
          failUploads--;
          return http.Response(
            '{"message":"temporary failure"}',
            503,
            request: request,
          );
        }
        for (final raw in jsonDecode(request.body) as List) {
          final row = Map<String, dynamic>.from(raw as Map);
          final key = '${row['user_id']}/${row['id']}';
          final old = rows[key];
          if (old == null ||
              DateTime.parse(
                row['updated_at'],
              ).isAfter(DateTime.parse(old['updated_at']))) {
            rows[key] = row;
          }
        }
        return http.Response(
          '[]',
          201,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }
      final query = request.url.queryParameters;
      final owner = query['user_id']!.substring(3);
      final ids = query['id'];
      var selected =
          rows.values.where((row) => row['user_id'] == owner).toList()
            ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
      if (ids != null) {
        final allowed = ids
            .substring(4, ids.length - 1)
            .replaceAll('"', '')
            .split(',');
        selected = selected
            .where((row) => allowed.contains(row['id']))
            .toList();
      }
      selected = selected
          .skip(int.parse(query['offset'] ?? '0'))
          .take(int.parse(query['limit'] ?? '1000'))
          .toList();
      return http.Response(
        jsonEncode(selected),
        200,
        request: request,
        headers: {'content-type': 'application/json'},
      );
    } finally {
      requestsInFlight--;
    }
  }

  void put(String owner, String id, int revision, {String value = '{}'}) {
    rows['$owner/$id'] = {
      'id': id,
      'user_id': owner,
      'updated_at': DateTime.utc(2026, 1, revision).toIso8601String(),
      'deleted': false,
      'json_data': value,
    };
  }
}
