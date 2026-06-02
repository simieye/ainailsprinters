import 'dart:async';
import 'dart:math';

/// LK Box (龙虾云盒) 服务
/// 负责硬件状态监控、故障诊断与高并发调度
class LKBoxService {
  LKBoxService._();
  static final LKBoxService instance = LKBoxService._();

  final Random _random = Random();
  final StreamController<LKBoxEvent> _eventController =
      StreamController<LKBoxEvent>.broadcast();
  
  Timer? _heartbeatTimer;
  DeviceConnectionStatus _connectionStatus = DeviceConnectionStatus.disconnected;

  Stream<LKBoxEvent> get eventStream => _eventController.stream;
  DeviceConnectionStatus get connectionStatus => _connectionStatus;

  /// 连接 LK Box
  Future<bool> connect(String deviceId) async {
    _connectionStatus = DeviceConnectionStatus.connecting;
    _eventController.add(LKBoxEvent(
      type: 'connection',
      data: {'status': 'connecting', 'deviceId': deviceId},
    ));
    
    await Future.delayed(const Duration(seconds: 1));
    
    _connectionStatus = DeviceConnectionStatus.connected;
    _startHeartbeat();
    
    _eventController.add(LKBoxEvent(
      type: 'connection',
      data: {'status': 'connected', 'deviceId': deviceId},
    ));
    
    return true;
  }

  /// 断开连接
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _connectionStatus = DeviceConnectionStatus.disconnected;
    _eventController.add(LKBoxEvent(
      type: 'connection',
      data: {'status': 'disconnected'},
    ));
  }

  /// 获取设备状态
  Future<Map<String, dynamic>> getDeviceStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'deviceId': 'LK-2025-0001',
      'status': 'online',
      'firmwareVersion': '3.2.1',
      'uptime': '127h 42m',
      'temperature': 38.5,
      'humidity': 45.2,
      'cartridgeLevels': {
        'C': 0.85,
        'M': 0.62,
        'Y': 0.91,
        'K': 0.45,
        'Coating': 0.73,
      },
      'totalPrints': 12453,
      'printLifecycle': 0.25, // 50000次生命周期的25%
      'lastMaintenance': '2025-05-28',
      'networkLatency': 12,
      'cpuLoad': 0.35,
      'memoryUsage': 0.48,
    };
  }

  /// 获取打印统计数据 (B端)
  Future<Map<String, dynamic>> getPrintStats({String? storeId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    return {
      'today': {
        'prints': 47,
        'revenue': 940.0,
        'avgPrice': 20.0,
      },
      'thisWeek': {
        'prints': 312,
        'revenue': 6240.0,
        'trend': '+12%',
      },
      'thisMonth': {
        'prints': 1350,
        'revenue': 27000.0,
        'trend': '+18%',
      },
      'topDesigns': [
        {'name': '赛博霓虹', 'prints': 89, 'revenue': 1780},
        {'name': '樱花物语', 'prints': 76, 'revenue': 1520},
        {'name': '星空渐变', 'prints': 65, 'revenue': 1300},
      ],
      'peakHours': ['14:00', '15:00', '19:00', '20:00'],
    };
  }

  /// 获取 ROI 数据 (B端)
  Future<Map<String, dynamic>> getROIData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'initialInvestment': 15000,
      'currentRevenue': 27000,
      'roiPercent': 180,
      'paybackDays': 25,
      'estimatedPaybackDays': 45,
      'progressPercent': 0.72,
      'dailyRevenue': [180, 220, 195, 240, 260, 230, 280],
      'projectedAnnualRevenue': 324000,
    };
  }

  /// 远程 OTA 更新
  Future<bool> performOTA(String firmwareUrl) async {
    _eventController.add(LKBoxEvent(
      type: 'ota',
      data: {'status': 'downloading', 'progress': 0},
    ));
    
    for (int i = 0; i <= 100; i += 20) {
      await Future.delayed(const Duration(milliseconds: 300));
      _eventController.add(LKBoxEvent(
        type: 'ota',
        data: {'status': 'installing', 'progress': i / 100},
      ));
    }
    
    _eventController.add(LKBoxEvent(
      type: 'ota',
      data: {'status': 'completed', 'progress': 1.0},
    ));
    
    return true;
  }

  /// 心跳检测
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_connectionStatus == DeviceConnectionStatus.connected) {
        _eventController.add(LKBoxEvent(
          type: 'heartbeat',
          data: {
            'timestamp': DateTime.now().toIso8601String(),
            'latency': 8 + _random.nextInt(10),
            'status': 'healthy',
          },
        ));
      }
    });
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _eventController.close();
  }
}

enum DeviceConnectionStatus { connected, disconnected, connecting, error }

class LKBoxEvent {
  final String type;
  final Map<String, dynamic> data;

  const LKBoxEvent({required this.type, required this.data});
}
