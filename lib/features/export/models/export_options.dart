enum ExportTimeRangeType {
  thisSession,
  today,
  past7Days,
  allData,
  custom,
}

enum ExportFormat {
  json,
  csv,
  both,
}

enum ExportMode {
  eventsOnly,
  fullRawSession,
}

class ExportFilterState {
  final ExportTimeRangeType timeRangeType;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final ExportFormat format;
  final ExportMode mode;

  const ExportFilterState({
    this.timeRangeType = ExportTimeRangeType.allData,
    this.customStartDate,
    this.customEndDate,
    this.format = ExportFormat.both,
    this.mode = ExportMode.eventsOnly,
  });

  DateTime? get startUtc {
    final now = DateTime.now().toUtc();
    switch (timeRangeType) {
      case ExportTimeRangeType.thisSession:
        // Assume session start within the last 4 hours or start of day
        return now.subtract(const Duration(hours: 4));
      case ExportTimeRangeType.today:
        return DateTime.utc(now.year, now.month, now.day);
      case ExportTimeRangeType.past7Days:
        return now.subtract(const Duration(days: 7));
      case ExportTimeRangeType.custom:
        return customStartDate?.toUtc();
      case ExportTimeRangeType.allData:
        return null;
    }
  }

  DateTime? get endUtc {
    if (timeRangeType == ExportTimeRangeType.custom) {
      return customEndDate?.toUtc();
    }
    return DateTime.now().toUtc();
  }

  ExportFilterState copyWith({
    ExportTimeRangeType? timeRangeType,
    DateTime? customStartDate,
    DateTime? customEndDate,
    ExportFormat? format,
    ExportMode? mode,
  }) {
    return ExportFilterState(
      timeRangeType: timeRangeType ?? this.timeRangeType,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      format: format ?? this.format,
      mode: mode ?? this.mode,
    );
  }
}

class ExportSummary {
  final int eventCount;
  final int sensorReadingCount;
  final int cameraDetectionCount;
  final int estimatedSizeBytes;

  const ExportSummary({
    this.eventCount = 0,
    this.sensorReadingCount = 0,
    this.cameraDetectionCount = 0,
    this.estimatedSizeBytes = 0,
  });

  String get formattedEstimatedSize {
    if (estimatedSizeBytes < 1024) return '$estimatedSizeBytes B';
    if (estimatedSizeBytes < 1024 * 1024) {
      return '${(estimatedSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(estimatedSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
