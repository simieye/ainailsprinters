import 'dart:async';

/// 蓝牙打印服务
/// 负责连接美甲打印机、发送打印指令、监控打印进度
class BluetoothPrintService {
  BluetoothPrintService._();
  static final BluetoothPrintService instance = BluetoothPrintService._();

  PrintConnectionState _connectionState = PrintConnectionState.disconnected;
  Timer? _progressTimer;
  final _stateController = StreamController<PrintConnectionState>.broadcast();
  final _progressController = StreamController<PrintProgress>.broadcast();
  final _eventController = StreamController<PrintEvent>.broadcast();

  Stream<PrintConnectionState> get connectionState => _stateController.stream;
  Stream<PrintProgress> get printProgress => _progressController.stream;
  Stream<PrintEvent> get events => _eventController.stream;
  PrintConnectionState get currentState => _connectionState;

  /// 扫描可用的打印机设备
  Future<List<PrintDevice>> scanDevices() async {
    // 模拟蓝牙扫描
    await Future.delayed(const Duration(seconds: 2));

    return [
      const PrintDevice(
        id: 'NP-2025-0001',
        name: 'AI NAILS Printer Pro',
        model: 'NP-3.0',
        signalStrength: -42,
        firmwareVersion: '3.2.1',
      ),
      const PrintDevice(
        id: 'NP-2025-0002',
        name: 'AI NAILS Printer Mini',
        model: 'NP-2.0',
        signalStrength: -68,
        firmwareVersion: '3.1.0',
      ),
    ];
  }

  /// 连接打印机
  Future<bool> connect(String deviceId) async {
    _updateState(PrintConnectionState.connecting);

    try {
      // 模拟蓝牙连接
      await Future.delayed(const Duration(seconds: 1));

      _updateState(PrintConnectionState.connected);
      _eventController.add(PrintEvent(
        type: 'connected',
        data: {'deviceId': deviceId},
      ));
      return true;
    } catch (e) {
      _updateState(PrintConnectionState.error);
      _eventController.add(PrintEvent(
        type: 'error',
        data: {'error': e.toString()},
      ));
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _progressTimer?.cancel();
    _updateState(PrintConnectionState.disconnected);
    _eventController.add(const PrintEvent(
      type: 'disconnected',
      data: {},
    ));
  }

  /// 开始打印
  Future<bool> startPrint({
    required String designUrl,
    required int fingerIndex,
    int dpi = 1200,
    bool coating = true,
  }) async {
    if (_connectionState != PrintConnectionState.connected) {
      _eventController.add(const PrintEvent(
        type: 'error',
        data: {'error': '打印机未连接'},
      ));
      return false;
    }

    _updateState(PrintConnectionState.printing);

    try {
      // 模拟打印过程（10秒）
      int progress = 0;
      _progressTimer = Timer.periodic(
        const Duration(milliseconds: 200),
        (timer) {
          progress += 2;
          _progressController.add(PrintProgress(
            percent: progress / 100.0,
            status: progress < 30
                ? '准备打印...'
                : progress < 60
                    ? '喷墨中...'
                    : progress < 90
                        ? '固化涂层...'
                        : '完成...',
            fingerIndex: fingerIndex,
          ));

          if (progress >= 100) {
            timer.cancel();
            _updateState(PrintConnectionState.connected);
            _eventController.add(PrintEvent(
              type: 'print_complete',
              data: {
                'design_url': designUrl,
                'finger_index': fingerIndex,
                'duration': 10.0,
                'dpi': dpi,
              },
            ));
          }
        },
      );

      _eventController.add(PrintEvent(
        type: 'print_started',
        data: {
          'design_url': designUrl,
          'finger_index': fingerIndex,
          'dpi': dpi,
          'coating': coating,
        },
      ));

      return true;
    } catch (e) {
      _updateState(PrintConnectionState.error);
      _eventController.add(PrintEvent(
        type: 'error',
        data: {'error': e.toString()},
      ));
      return false;
    }
  }

  /// 取消打印
  Future<void> cancelPrint() async {
    _progressTimer?.cancel();
    _updateState(PrintConnectionState.connected);
    _eventController.add(const PrintEvent(
      type: 'print_cancelled',
      data: {},
    ));
  }

  /// 获取打印机状态
  Future<PrinterStatus> getPrinterStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));

    return const PrinterStatus(
      deviceId: 'NP-2025-0001',
      temperature: 38.5,
      humidity: 45.2,
      cartridgeC: 0.85,
      cartridgeM: 0.62,
      cartridgeY: 0.91,
      cartridgeK: 0.45,
      coating: 0.73,
      totalPrints: 12453,
      printLifecycle: 0.25,
      isOnline: true,
    );
  }

  void _updateState(PrintConnectionState state) {
    _connectionState = state;
    _stateController.add(state);
  }

  void dispose() {
    _progressTimer?.cancel();
    _stateController.close();
    _progressController.close();
    _eventController.close();
  }
}

/// 连接状态
enum PrintConnectionState {
  disconnected,
  connecting,
  connected,
  printing,
  error,
}

/// 打印设备信息
class PrintDevice {
  final String id;
  final String name;
  final String model;
  final int signalStrength;
  final String firmwareVersion;

  const PrintDevice({
    required this.id,
    required this.name,
    required this.model,
    required this.signalStrength,
    required this.firmwareVersion,
  });
}

/// 打印进度
class PrintProgress {
  final double percent;
  final String status;
  final int fingerIndex;

  const PrintProgress({
    required this.percent,
    required this.status,
    required this.fingerIndex,
  });
}

/// 打印事件
class PrintEvent {
  final String type;
  final Map<String, dynamic> data;

  const PrintEvent({required this.type, required this.data});
}

/// 打印机状态
class PrinterStatus {
  final String deviceId;
  final double temperature;
  final double humidity;
  final double cartridgeC;
  final double cartridgeM;
  final double cartridgeY;
  final double cartridgeK;
  final double coating;
  final int totalPrints;
  final double printLifecycle;
  final bool isOnline;

  const PrinterStatus({
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.cartridgeC,
    required this.cartridgeM,
    required this.cartridgeY,
    required this.cartridgeK,
    required this.coating,
    required this.totalPrints,
    required this.printLifecycle,
    required this.isOnline,
  });
}
