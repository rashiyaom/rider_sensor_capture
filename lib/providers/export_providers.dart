import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/export_repository.dart';
import '../data/repositories/export_repository_impl.dart';
import '../features/export/models/export_options.dart';
import 'db_providers.dart';

// Export repository provider
final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExportRepositoryImpl(db);
});

// Active filter state provider
final exportFilterProvider =
    StateNotifierProvider<ExportFilterNotifier, ExportFilterState>((ref) {
  return ExportFilterNotifier();
});

class ExportFilterNotifier extends StateNotifier<ExportFilterState> {
  ExportFilterNotifier() : super(const ExportFilterState());

  void setTimeRange(ExportTimeRangeType type) {
    state = state.copyWith(timeRangeType: type);
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(
      timeRangeType: ExportTimeRangeType.custom,
      customStartDate: start,
      customEndDate: end,
    );
  }

  void setFormat(ExportFormat format) {
    state = state.copyWith(format: format);
  }

  void setMode(ExportMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setOnlyCrossConfirmed(bool val) {
    state = state.copyWith(onlyCrossConfirmed: val);
  }
}

// Summary auto-provider: calculates expected counts whenever filters or database change
final exportSummaryProvider = FutureProvider<ExportSummary>((ref) async {
  final filter = ref.watch(exportFilterProvider);
  final repo = ref.watch(exportRepositoryProvider);

  return repo.getExportSummary(
    startUtc: filter.startUtc,
    endUtc: filter.endUtc,
    mode: filter.mode,
    onlyCrossConfirmed: filter.onlyCrossConfirmed,
  );
});

// Saved export files list provider
final savedExportFilesProvider = FutureProvider<List<File>>((ref) async {
  final repo = ref.watch(exportRepositoryProvider);
  return repo.getSavedExports();
});

// Export controller state for handling export progress & actions
enum ExportStatus { idle, generating, sharing, success, error }

class ExportControllerState {
  final ExportStatus status;
  final String statusMessage;
  final List<File> lastExportedFiles;
  final String? errorMessage;

  const ExportControllerState({
    this.status = ExportStatus.idle,
    this.statusMessage = '',
    this.lastExportedFiles = const [],
    this.errorMessage,
  });

  ExportControllerState copyWith({
    ExportStatus? status,
    String? statusMessage,
    List<File>? lastExportedFiles,
    String? errorMessage,
  }) {
    return ExportControllerState(
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      lastExportedFiles: lastExportedFiles ?? this.lastExportedFiles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ExportController extends StateNotifier<ExportControllerState> {
  final Ref ref;

  ExportController(this.ref) : super(const ExportControllerState());

  Future<void> runExport() async {
    final filter = ref.read(exportFilterProvider);
    final repo = ref.read(exportRepositoryProvider);

    try {
      state = state.copyWith(
        status: ExportStatus.generating,
        statusMessage: 'Extracting multi-modal data & formatting 3 ML files...',
        errorMessage: null,
      );

      final files = await repo.generateExportFiles(
        startUtc: filter.startUtc,
        endUtc: filter.endUtc,
        format: filter.format,
        mode: filter.mode,
        onlyCrossConfirmed: filter.onlyCrossConfirmed,
      );

      state = state.copyWith(
        status: ExportStatus.sharing,
        statusMessage: 'Triggering share sheet...',
        lastExportedFiles: files,
      );

      await repo.shareFiles(files);

      state = state.copyWith(
        status: ExportStatus.success,
        statusMessage: 'Export shared successfully (${files.length} file${files.length == 1 ? '' : 's'})',
      );

      ref.invalidate(savedExportFilesProvider);
    } catch (e) {
      state = state.copyWith(
        status: ExportStatus.error,
        statusMessage: 'Export failed',
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> reShareFiles(List<File> files) async {
    final repo = ref.read(exportRepositoryProvider);
    await repo.shareFiles(files);
  }

  Future<void> deleteExport(File file) async {
    final repo = ref.read(exportRepositoryProvider);
    await repo.deleteExportFile(file);
    ref.invalidate(savedExportFilesProvider);
  }

  void resetStatus() {
    state = const ExportControllerState();
  }
}

final exportControllerProvider =
    StateNotifierProvider<ExportController, ExportControllerState>((ref) {
  return ExportController(ref);
});
