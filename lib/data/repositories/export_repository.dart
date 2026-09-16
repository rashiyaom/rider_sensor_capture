import 'dart:io';
import '../../features/export/models/export_options.dart';

abstract class ExportRepository {
  /// Calculate summary of data in the given range and mode
  Future<ExportSummary> getExportSummary({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
    bool onlyCrossConfirmed = false,
  });

  /// Build complete nested JSON structure with top-level trip_summary and multi-sensor validation
  Future<Map<String, dynamic>> buildJsonExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
    bool onlyCrossConfirmed = false,
  });

  /// Build File 1: sensor_timeseries_export.csv (high-frequency, per-reading with nearest GPS forward-filled)
  Future<String> buildSensorTimeseriesCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
    bool onlyCrossConfirmed = false,
  });

  /// Build File 2: event_records_export.csv (one row per event)
  Future<String> buildEventRecordsCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    bool onlyCrossConfirmed = false,
  });

  /// Build File 3: trip_summary_export.csv (one row per trip summary)
  Future<String> buildTripSummaryCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
  });

  /// Build legacy sensor readings CSV
  Future<String> buildSensorCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
    String? deviceId,
    bool onlyCrossConfirmed = false,
  });

  /// Build separate CSV strings for each individual sensor device
  Future<Map<String, String>> buildPerSensorCsvExports({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
    bool onlyCrossConfirmed = false,
  });

  /// Build CSV string for camera detections
  Future<String> buildCameraCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
  });

  /// Build complete CSV export for a specific Trip / Journey
  Future<String> exportTripCsv(int tripId);

  /// Build complete nested JSON export for a specific Trip / Journey
  Future<Map<String, dynamic>> exportTripJson(int tripId);

  /// Generate actual files for a specific Trip and return File handles
  Future<List<File>> generateTripExportFiles(int tripId, {required ExportFormat format});

  /// Generate actual files in the documents directory (including the 3 driver safety ML files)
  Future<List<File>> generateExportFiles({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportFormat format,
    required ExportMode mode,
    bool includePerSensorFiles = true,
    bool onlyCrossConfirmed = false,
  });

  /// Invoke native share sheet using share_plus
  Future<void> shareFiles(List<File> files);

  /// Get list of previously generated export files in documents directory
  Future<List<File>> getSavedExports();

  /// Delete a saved export file
  Future<void> deleteExportFile(File file);
}
