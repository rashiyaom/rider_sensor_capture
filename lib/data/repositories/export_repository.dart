import 'dart:io';
import '../../features/export/models/export_options.dart';

abstract class ExportRepository {
  /// Calculate summary of data in the given range and mode
  Future<ExportSummary> getExportSummary({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
  });

  /// Build complete nested JSON structure
  Future<Map<String, dynamic>> buildJsonExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
  });

  /// Build CSV string for sensor readings (with event parameters attached)
  Future<String> buildSensorCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
  });

  /// Build CSV string for camera detections
  Future<String> buildCameraCsvExport({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportMode mode,
  });

  /// Generate actual files in the documents directory
  Future<List<File>> generateExportFiles({
    DateTime? startUtc,
    DateTime? endUtc,
    required ExportFormat format,
    required ExportMode mode,
  });

  /// Invoke native share sheet using share_plus
  Future<void> shareFiles(List<File> files);

  /// Get list of previously generated export files in documents directory
  Future<List<File>> getSavedExports();

  /// Delete a saved export file
  Future<void> deleteExportFile(File file);
}
