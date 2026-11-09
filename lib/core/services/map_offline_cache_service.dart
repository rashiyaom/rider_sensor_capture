import 'dart:io';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Cache statistics for the offline map tile engine.
class MapCacheStats {
  final int tileCount;
  final double sizeMb;
  final bool isDownloading;
  final double downloadProgress; // 0.0 to 1.0
  final String statusText;

  const MapCacheStats({
    this.tileCount = 0,
    this.sizeMb = 0.0,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.statusText = 'Ready',
  });

  MapCacheStats copyWith({
    int? tileCount,
    double? sizeMb,
    bool? isDownloading,
    double? downloadProgress,
    String? statusText,
  }) {
    return MapCacheStats(
      tileCount: tileCount ?? this.tileCount,
      sizeMb: sizeMb ?? this.sizeMb,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      statusText: statusText ?? this.statusText,
    );
  }
}

/// Service managing offline Dark Mode map tiles for remote / mountain test tracks.
///
/// Features:
/// * Local disk caching in `<app_docs>/map_tiles/`
/// * Pre-downloading bounding boxes around test tracks for offline navigation
/// * Tracking cache size in MB and tile count
/// * Clearing cache
class MapOfflineCacheService extends StateNotifier<MapCacheStats> {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 8),
    headers: {
      'User-Agent': 'ride_sensor_capture/1.0.1 (com.rashiyaom.ride_sensor_capture)',
    },
  ));

  Directory? _cacheDir;
  Directory? get cacheDir => _cacheDir;

  MapOfflineCacheService() : super(const MapCacheStats()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory(p.join(docDir.path, 'map_tiles'));
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
      await refreshStats();
    } catch (e) {
      if (kDebugMode) debugPrint('MapOfflineCacheService init error: $e');
    }
  }

  /// Refreshes the count and total MB size of cached tiles.
  Future<void> refreshStats() async {
    if (_cacheDir == null || !await _cacheDir!.exists()) return;

    try {
      int count = 0;
      int bytes = 0;
      await for (final file in _cacheDir!.list(recursive: false)) {
        if (file is File && file.path.endsWith('.png')) {
          count++;
          bytes += await file.length();
        }
      }
      final mb = bytes / (1024 * 1024);
      state = state.copyWith(
        tileCount: count,
        sizeMb: double.parse(mb.toStringAsFixed(2)),
        statusText: count > 0 ? '$count tiles (${mb.toStringAsFixed(1)} MB)' : 'Empty',
      );
    } catch (_) {}
  }

  /// Downloads and caches tiles covering a bounding box around a center coordinate.
  ///
  /// Typically covers zoom levels 14 to 16 (ideal for bike road navigation).
  Future<int> preCacheArea({
    required double centerLat,
    required double centerLng,
    double radiusKm = 2.5,
    int minZoom = 14,
    int maxZoom = 15,
  }) async {
    if (state.isDownloading || _cacheDir == null) return 0;

    state = state.copyWith(
      isDownloading: true,
      downloadProgress: 0.0,
      statusText: 'Preparing tile download…',
    );

    int totalDownloaded = 0;
    final List<_TileCoord> tilesToFetch = [];

    // Calculate tile coordinate ranges for each zoom level
    final latDelta = radiusKm / 111.32;
    final cosLat = math.cos(centerLat * math.pi / 180.0).abs();
    final lngDelta = radiusKm / (111.32 * (cosLat < 0.0001 ? 1.0 : cosLat));

    final minLat = centerLat - latDelta;
    final maxLat = centerLat + latDelta;
    final minLng = centerLng - lngDelta;
    final maxLng = centerLng + lngDelta;

    for (int z = minZoom; z <= maxZoom; z++) {
      final (minX, maxY) = _latLngToTileXY(minLat, minLng, z);
      final (maxX, minY) = _latLngToTileXY(maxLat, maxLng, z);

      final startX = math.min(minX, maxX);
      final endX = math.max(minX, maxX);
      final startY = math.min(minY, maxY);
      final endY = math.max(minY, maxY);

      for (int x = startX; x <= endX; x++) {
        for (int y = startY; y <= endY; y++) {
          tilesToFetch.add(_TileCoord(z, x, y));
        }
      }
    }

    // Cap maximum tiles to prevent network overload (e.g. max 120 tiles)
    final totalTiles = math.min(tilesToFetch.length, 120);

    for (int i = 0; i < totalTiles; i++) {
      final tile = tilesToFetch[i];
      final filePath = p.join(_cacheDir!.path, '${tile.z}_${tile.x}_${tile.y}.png');
      final file = File(filePath);

      if (!await file.exists()) {
        try {
          final url = 'https://basemaps.cartocdn.com/rastertiles/dark_all/${tile.z}/${tile.x}/${tile.y}.png';
          final response = await _dio.get<List<int>>(
            url,
            options: Options(responseType: ResponseType.bytes),
          );
          if (response.data != null && response.data!.isNotEmpty) {
            await file.writeAsBytes(response.data!);
            totalDownloaded++;
          }
        } catch (_) {
          // Continue fetching others even if single tile fails
        }
      } else {
        totalDownloaded++;
      }

      state = state.copyWith(
        downloadProgress: (i + 1) / totalTiles,
        statusText: 'Caching tiles: ${i + 1}/$totalTiles',
      );

      // Throttling to respect CartoDB tile servers
      await Future.delayed(const Duration(milliseconds: 30));
    }

    await refreshStats();
    state = state.copyWith(
      isDownloading: false,
      downloadProgress: 1.0,
      statusText: 'Cached $totalDownloaded tiles (${state.sizeMb} MB)',
    );

    return totalDownloaded;
  }

  /// Clears all cached offline tiles.
  Future<void> clearCache() async {
    if (_cacheDir == null || !await _cacheDir!.exists()) return;
    try {
      await for (final file in _cacheDir!.list(recursive: false)) {
        if (file is File) await file.delete();
      }
      await refreshStats();
    } catch (_) {}
  }

  static (int, int) _latLngToTileXY(double lat, double lng, int zoom) {
    final n = math.pow(2.0, zoom).toDouble();
    final x = ((lng + 180.0) / 360.0 * n).floor();
    final latRad = lat * math.pi / 180.0;
    final y = ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n).floor();
    return (x, y);
  }
}

class _TileCoord {
  final int z;
  final int x;
  final int y;
  const _TileCoord(this.z, this.x, this.y);
}

final mapOfflineCacheServiceProvider =
    StateNotifierProvider<MapOfflineCacheService, MapCacheStats>((ref) {
  return MapOfflineCacheService();
});
