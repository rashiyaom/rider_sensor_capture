enum DeviceType {
  watch,
  verityBand,
  camera,
  unknown,
}

enum BleConnectionState {
  scanning,
  connecting,
  connected,
  disconnected,
  reconnecting,
  lost, // Retries exhausted; persistent lost state
}

enum ConnectionHealth {
  good,        // Packet received within < 2.5s
  degraded,    // Packet gap 2.5s - 6s
  poor,        // Packet gap 6s - 15s
  disconnected,// No active connection
}

class BleDeviceModel {
  final String id;
  final String name;
  final DeviceType type;
  final BleConnectionState connectionState;
  final ConnectionHealth health;
  final int rssi;
  final DateTime lastSeen;
  final DateTime? lastPacketTime;
  final int packetsReceived;
  final int retryAttempts;

  const BleDeviceModel({
    required this.id,
    required this.name,
    required this.type,
    this.connectionState = BleConnectionState.disconnected,
    this.health = ConnectionHealth.disconnected,
    required this.rssi,
    required this.lastSeen,
    this.lastPacketTime,
    this.packetsReceived = 0,
    this.retryAttempts = 0,
  });

  BleDeviceModel copyWith({
    String? id,
    String? name,
    DeviceType? type,
    BleConnectionState? connectionState,
    ConnectionHealth? health,
    int? rssi,
    DateTime? lastSeen,
    DateTime? lastPacketTime,
    int? packetsReceived,
    int? retryAttempts,
  }) {
    return BleDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      connectionState: connectionState ?? this.connectionState,
      health: health ?? this.health,
      rssi: rssi ?? this.rssi,
      lastSeen: lastSeen ?? this.lastSeen,
      lastPacketTime: lastPacketTime ?? this.lastPacketTime,
      packetsReceived: packetsReceived ?? this.packetsReceived,
      retryAttempts: retryAttempts ?? this.retryAttempts,
    );
  }

  static DeviceType inferDeviceType(String deviceName) {
    final lower = deviceName.toLowerCase();
    if (lower.contains('polar') || lower.contains('verity') || lower.contains('sense')) {
      return DeviceType.verityBand;
    } else if (lower.contains('esp') || lower.contains('watch') || lower.contains('ride')) {
      return DeviceType.watch;
    } else if (lower.contains('cam') || lower.contains('gopro')) {
      return DeviceType.camera;
    }
    return DeviceType.unknown;
  }
}
