import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

LazyDatabase constructDb() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'ride_sensor_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      debugPrint(
        'Using ${result.chosenImplementation} due to missing features: ${result.missingFeatures}',
      );
    }

    return result.resolvedExecutor;
  });
}

