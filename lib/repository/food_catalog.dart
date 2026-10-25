import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:uuid/uuid.dart';

/// Metadata is kept on search results, never in the serialized diary snapshot.
class CatalogFood extends VagueFood {
  final String catalogId;
  final int version;

  CatalogFood._(this.catalogId, this.version, VagueFood value)
    : super(
        name: value.name,
        brand: value.brand,
        barcode: value.barcode,
        nutritionalValuesPer100g: value.nutritionalValuesPer100g,
        servingSizes: value.servingSizes,
        unit: value.unit,
        downloadedFromOFF: value.downloadedFromOFF,
      );

  factory CatalogFood.fromRow(Map<String, dynamic> row) => CatalogFood._(
    row['id'] as String,
    (row['version'] as num).toInt(),
    VagueFood.fromJson(Map<String, dynamic>.from(row['food'])),
  );
}

class CatalogSubmissionRequest {
  final String operationId;
  final String owner;
  final Map<String, dynamic> definition;
  final String status;
  final String? error;
  final int attempts;

  CatalogSubmissionRequest(Map<String, dynamic> row)
    : operationId = row['operation_id'] as String,
      owner = row['owner'] as String,
      definition = jsonDecode(row['definition'] as String),
      status = row['status'] as String,
      error = row['error'] as String?,
      attempts = row['attempts'] as int;
}

class CatalogOutbox {
  CatalogOutbox(this.db);
  final GTDatabase db;

  Future<String> enqueue(String owner, VagueFood food) async {
    if (db.currentUserId != owner) throw StateError('Account changed');
    // Nutrients are already expressed per 100 g, or per 100 ml when unit is ml.
    // Never send Food.nutritionalValues: those totals include amount and pieces.
    // Serving sizes remain optional portions, not the nutritional reference basis.
    final definition = VagueFood(
      name: food.name,
      brand: food.brand,
      barcode: food.barcode,
      unit: food.unit,
      servingSizes: food.servingSizes,
      nutritionalValuesPer100g: food.nutritionalValuesPer100g,
    ).toJson();
    final id = const Uuid().v4();
    await db
        .into(db.catalogSubmissions)
        .insert(
          CatalogSubmissionsCompanion.insert(
            operationId: id,
            owner: owner,
            definition: jsonEncode(definition),
            nextAttempt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  Stream<List<CatalogSubmissionRequest>> watch(String owner) => db
      .customSelect(
        'SELECT * FROM catalog_submissions WHERE owner=? ORDER BY created_at DESC,operation_id',
        variables: [Variable(owner)],
        readsFrom: {db.catalogSubmissions},
      )
      .watch()
      .map(
        (rows) => rows.map((r) => CatalogSubmissionRequest(r.data)).toList(),
      );

  Future<void> recoverInterrupted() async {
    await db.customUpdate(
      "UPDATE catalog_submissions SET status='pending' WHERE status='sending'",
      updates: {db.catalogSubmissions},
    );
  }

  Future<CatalogSubmissionRequest?> next(String owner, DateTime now) async {
    final rows = await db
        .customSelect(
          "SELECT * FROM catalog_submissions WHERE owner=? AND status='pending' AND next_attempt<=? ORDER BY created_at,operation_id LIMIT 1",
          variables: [
            Variable(owner),
            Variable(now.millisecondsSinceEpoch ~/ 1000),
          ],
        )
        .get();
    return rows.isEmpty ? null : CatalogSubmissionRequest(rows.first.data);
  }

  Future<bool> claim(CatalogSubmissionRequest request) async =>
      await db.customUpdate(
        "UPDATE catalog_submissions SET status='sending',attempts=attempts+1,error=NULL WHERE operation_id=? AND owner=? AND status='pending'",
        variables: [Variable(request.operationId), Variable(request.owner)],
        updates: {db.catalogSubmissions},
      ) ==
      1;

  Future<void> finish(
    CatalogSubmissionRequest request,
    String status, {
    Map<String, dynamic>? result,
    String? error,
    DateTime? nextAttempt,
  }) async {
    await db.customUpdate(
      'UPDATE catalog_submissions SET status=?,result=?,error=?,next_attempt=? WHERE operation_id=? AND owner=? AND status=\'sending\'',
      variables: [
        Variable(status),
        Variable(result == null ? null : jsonEncode(result)),
        Variable(error),
        Variable(
          (nextAttempt ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000,
        ),
        Variable(request.operationId),
        Variable(request.owner),
      ],
      updates: {db.catalogSubmissions},
    );
  }

  Future<void> cancel(String owner, String operationId) async {
    await db.customUpdate(
      "UPDATE catalog_submissions SET status=CASE WHEN status='pending' AND attempts>0 THEN 'cancelled_unknown' ELSE 'cancelled' END,error=NULL WHERE owner=? AND operation_id=? AND status IN ('pending','failed')",
      variables: [Variable(owner), Variable(operationId)],
      updates: {db.catalogSubmissions},
    );
  }

  Future<void> retry(String owner, String operationId) async {
    await db.customUpdate(
      "UPDATE catalog_submissions SET status='pending',error=NULL,next_attempt=0 WHERE owner=? AND operation_id=? AND status IN ('pending','failed')",
      variables: [Variable(owner), Variable(operationId)],
      updates: {db.catalogSubmissions},
    );
  }
}
