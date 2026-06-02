import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// MCP (Model Context Protocol) 协议层
///
/// 负责 APP 与 SIMIAIOS 64智能体集群之间的双向异步通信。
/// 支持 WebSocket 连接管理、消息序列化/反序列化、心跳保活、自动重连。
class McpProtocolService {
  McpProtocolService._();

  static final McpProtocolService instance = McpProtocolService._();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  final _eventController = StreamController<McpEvent>.broadcast();
  final _connectionController = StreamController<McpConnectionState>.broadcast();

  McpConnectionState _connectionState = McpConnectionState.disconnected;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectBaseDelay = Duration(seconds: 2);

  // WebSocket URL（可通过环境变量或配置覆盖）
  String _wsUrl = 'wss://ws.ai-nails.com/ws/simiai';

  /// 连接状态流
  Stream<McpConnectionState> get connectionState => _connectionController.stream;

  /// 事件流（接收所有 MCP 事件）
  Stream<McpEvent> get events => _eventController.stream;

  /// 当前连接状态
  McpConnectionState get currentState => _connectionState;

  /// 设置 WebSocket 地址
  void setWsUrl(String url) {
    _wsUrl = url;
  }

  /// 建立 WebSocket 连接
  Future<void> connect({String? authToken, String? deviceId}) async {
    if (_connectionState == McpConnectionState.connected ||
        _connectionState == McpConnectionState.connecting) {
      return;
    }

    _updateConnectionState(McpConnectionState.connecting);

    try {
      final uri = Uri.parse(_wsUrl);
      _channel = WebSocketChannel.connect(uri);

      // 监听消息
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // 发送握手消息
      _sendHandshake(authToken: authToken, deviceId: deviceId);

      _updateConnectionState(McpConnectionState.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
    } catch (e) {
      _updateConnectionState(McpConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _reconnectAttempts = _maxReconnectAttempts; // 阻止重连
    await _channel?.sink.close();
    _channel = null;
    _updateConnectionState(McpConnectionState.disconnected);
  }

  /// 发送 MCP 消息到智能体集群
  void sendMessage(McpMessage message) {
    if (_connectionState != McpConnectionState.connected) {
      _eventController.addError(
        McpException('Not connected to MCP gateway'),
      );
      return;
    }

    try {
      final json = jsonEncode(message.toJson());
      _channel?.sink.add(json);
    } catch (e) {
      _eventController.addError(
        McpException('Failed to send message: $e'),
      );
    }
  }

  /// 向特定智能体分发任务
  void dispatchTask({
    required String agentId,
    required Map<String, dynamic> payload,
    McpPriority priority = McpPriority.normal,
  }) {
    final message = McpMessage(
      type: McpMessageType.dispatch,
      agentId: agentId,
      payload: payload,
      priority: priority,
      messageId: _generateMessageId(),
    );
    sendMessage(message);
  }

  /// 查询智能体集群状态
  void queryClusterStatus() {
    final message = McpMessage(
      type: McpMessageType.query,
      agentId: 'cluster_master',
      payload: {'action': 'status'},
      priority: McpPriority.low,
      messageId: _generateMessageId(),
    );
    sendMessage(message);
  }

  // ===== 私有方法 =====

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final event = McpEvent.fromJson(json);
      _eventController.add(event);
    } catch (e) {
      // 忽略无法解析的消息
    }
  }

  void _onError(dynamic error) {
    _updateConnectionState(McpConnectionState.disconnected);
    _eventController.addError(McpException('WebSocket error: $error'));
    _scheduleReconnect();
  }

  void _onDone() {
    _updateConnectionState(McpConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _sendHandshake({String? authToken, String? deviceId}) {
    final handshake = McpMessage(
      type: McpMessageType.handshake,
      agentId: 'client',
      payload: {
        'protocol_version': '3.0',
        'client_type': 'ai_nails_app',
        'auth_token': authToken,
        'device_id': deviceId,
        'capabilities': [
          'text_input',
          'voice_input',
          'image_reference',
          'ar_preview',
          'print_control',
        ],
      },
      priority: McpPriority.critical,
      messageId: _generateMessageId(),
    );
    _channel?.sink.add(jsonEncode(handshake.toJson()));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_connectionState == McpConnectionState.connected) {
        final ping = McpMessage(
          type: McpMessageType.heartbeat,
          agentId: 'client',
          payload: {'timestamp': DateTime.now().toIso8601String()},
          priority: McpPriority.critical,
          messageId: _generateMessageId(),
        );
        _channel?.sink.add(jsonEncode(ping.toJson()));
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;

    _reconnectTimer?.cancel();
    final delay = _reconnectBaseDelay * (_reconnectAttempts + 1);
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  void _updateConnectionState(McpConnectionState state) {
    _connectionState = state;
    _connectionController.add(state);
  }

  String _generateMessageId() {
    return 'mcp_${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
  }

  static int _counter = 0;

  /// 释放资源
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _eventController.close();
    _connectionController.close();
  }
}

// ===== MCP 数据模型 =====

/// 连接状态枚举
enum McpConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// 消息优先级
enum McpPriority {
  low,
  normal,
  high,
  critical,
}

/// 消息类型
enum McpMessageType {
  handshake,
  dispatch,
  query,
  response,
  heartbeat,
  event,
  error,
}

/// MCP 协议消息
class McpMessage {
  final McpMessageType type;
  final String agentId;
  final Map<String, dynamic> payload;
  final McpPriority priority;
  final String messageId;
  final DateTime timestamp;

  McpMessage({
    required this.type,
    required this.agentId,
    required this.payload,
    this.priority = McpPriority.normal,
    String? messageId,
    DateTime? timestamp,
  })  : messageId = messageId ?? 'mcp_${DateTime.now().millisecondsSinceEpoch}',
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'agent_id': agentId,
        'payload': payload,
        'priority': priority.name,
        'message_id': messageId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory McpMessage.fromJson(Map<String, dynamic> json) {
    return McpMessage(
      type: McpMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => McpMessageType.event,
      ),
      agentId: json['agent_id'] as String? ?? 'unknown',
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      priority: McpPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => McpPriority.normal,
      ),
      messageId: json['message_id'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'McpMessage(type: ${type.name}, agent: $agentId, id: $messageId)';
}

/// MCP 事件（服务端推送）
class McpEvent {
  final String eventType;
  final String? agentId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? correlationId;

  McpEvent({
    required this.eventType,
    this.agentId,
    required this.data,
    DateTime? timestamp,
    this.correlationId,
  }) : timestamp = timestamp ?? DateTime.now();

  factory McpEvent.fromJson(Map<String, dynamic> json) {
    return McpEvent(
      eventType: json['event_type'] as String? ?? 'unknown',
      agentId: json['agent_id'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      correlationId: json['correlation_id'] as String?,
    );
  }

  /// 便捷构造器

  /// 图案生成进度
  static const generationProgress = 'generation_progress';
  /// 图案生成完成
  static const generationComplete = 'generation_complete';
  /// 打印进度
  static const printProgress = 'print_progress';
  /// 打印完成
  static const printComplete = 'print_complete';
  /// 设备状态更新
  static const deviceStatusUpdate = 'device_status_update';
  /// 设备告警
  static const deviceWarning = 'device_warning';
  /// OTA 进度
  static const otaProgress = 'ota_progress';
  /// 墨盒不足
  static const cartridgeLow = 'cartridge_low';
  /// 集群事件
  static const clusterEvent = 'cluster_event';

  /// 从事件中获取进度（0.0 - 1.0）
  double? get progress => data['progress'] as double?;

  /// 从事件中获取状态文本
  String? get statusText => data['status'] as String?;

  @override
  String toString() => 'McpEvent($eventType, agent: $agentId)';
}

/// MCP 异常
class McpException implements Exception {
  final String message;
  final int? code;
  final Map<String, dynamic>? details;

  McpException(this.message, {this.code, this.details});

  @override
  String toString() => 'McpException($code): $message';
}
