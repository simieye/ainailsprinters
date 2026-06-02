class DeviceStatus {
  final String deviceId;
  final String firmwareVersion;
  final String status;
  final double temperature;
  final double humidity;
  final int totalPrints;
  final double printLifecycle;
  final String lastMaintenance;
  final int networkLatency;
  final double cpuLoad;
  final double memoryUsage;
  final Map<String, double> cartridgeLevels;

  const DeviceStatus({
    required this.deviceId,
    required this.firmwareVersion,
    required this.status,
    required this.temperature,
    required this.humidity,
    required this.totalPrints,
    required this.printLifecycle,
    required this.lastMaintenance,
    required this.networkLatency,
    required this.cpuLoad,
    required this.memoryUsage,
    required this.cartridgeLevels,
  });

  factory DeviceStatus.initial() => const DeviceStatus(
    deviceId: 'LK-2025-0001',
    firmwareVersion: '3.2.1',
    status: 'offline',
    temperature: 0,
    humidity: 0,
    totalPrints: 0,
    printLifecycle: 0,
    lastMaintenance: '',
    networkLatency: 0,
    cpuLoad: 0,
    memoryUsage: 0,
    cartridgeLevels: {},
  );

  factory DeviceStatus.fromMap(Map<String, dynamic> map) => DeviceStatus(
    deviceId: map['deviceId'] ?? '',
    firmwareVersion: map['firmwareVersion'] ?? '',
    status: map['status'] ?? 'offline',
    temperature: (map['temperature'] ?? 0).toDouble(),
    humidity: (map['humidity'] ?? 0).toDouble(),
    totalPrints: map['totalPrints'] ?? 0,
    printLifecycle: (map['printLifecycle'] ?? 0).toDouble(),
    lastMaintenance: map['lastMaintenance'] ?? '',
    networkLatency: map['networkLatency'] ?? 0,
    cpuLoad: (map['cpuLoad'] ?? 0).toDouble(),
    memoryUsage: (map['memoryUsage'] ?? 0).toDouble(),
    cartridgeLevels: Map<String, double>.from(map['cartridgeLevels'] ?? {}),
  );
}
