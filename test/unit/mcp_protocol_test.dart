import 'package:flutter_test/flutter_test.dart';
import 'package:ai_nails_app/core/services/mcp_protocol_service.dart';

void main() {
  group('McpMessage', () {
    test('should serialize to JSON correctly', () {
      final message = McpMessage(
        type: McpMessageType.dispatch,
        agentId: 'prompt_refiner',
        payload: {'raw_input': 'test prompt'},
        priority: McpPriority.high,
        messageId: 'test_001',
        timestamp: DateTime(2026, 6, 2, 10, 0),
      );

      final json = message.toJson();

      expect(json['type'], 'dispatch');
      expect(json['agent_id'], 'prompt_refiner');
      expect(json['payload']['raw_input'], 'test prompt');
      expect(json['priority'], 'high');
      expect(json['message_id'], 'test_001');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'type': 'response',
        'agent_id': 'design_generator',
        'payload': {'status': 'complete'},
        'priority': 'normal',
        'message_id': 'resp_001',
        'timestamp': '2026-06-02T10:00:00.000',
      };

      final message = McpMessage.fromJson(json);

      expect(message.type, McpMessageType.response);
      expect(message.agentId, 'design_generator');
      expect(message.payload['status'], 'complete');
      expect(message.priority, McpPriority.normal);
    });

    test('should handle missing fields gracefully', () {
      final json = {
        'type': 'event',
        'payload': {},
      };

      final message = McpMessage.fromJson(json);

      expect(message.type, McpMessageType.event);
      expect(message.agentId, 'unknown');
      expect(message.priority, McpPriority.normal);
    });
  });

  group('McpEvent', () {
    test('should parse event with progress', () {
      final json = {
        'event_type': 'generation_progress',
        'agent_id': 'design_generator',
        'data': {'progress': 0.65, 'status': 'denoising'},
      };

      final event = McpEvent.fromJson(json);

      expect(event.eventType, 'generation_progress');
      expect(event.agentId, 'design_generator');
      expect(event.progress, 0.65);
      expect(event.statusText, 'denoising');
    });

    test('should handle null progress', () {
      final json = {
        'event_type': 'device_warning',
        'data': {'message': 'low ink'},
      };

      final event = McpEvent.fromJson(json);

      expect(event.eventType, 'device_warning');
      expect(event.progress, isNull);
    });

    test('should have correct event type constants', () {
      expect(McpEvent.generationProgress, 'generation_progress');
      expect(McpEvent.generationComplete, 'generation_complete');
      expect(McpEvent.printProgress, 'print_progress');
      expect(McpEvent.printComplete, 'print_complete');
      expect(McpEvent.deviceStatusUpdate, 'device_status_update');
      expect(McpEvent.deviceWarning, 'device_warning');
      expect(McpEvent.otaProgress, 'ota_progress');
      expect(McpEvent.cartridgeLow, 'cartridge_low');
    });
  });

  group('McpException', () {
    test('should format error message', () {
      final exception = McpException('Connection failed', code: 500);
      expect(exception.toString(), 'McpException(500): Connection failed');
    });

    test('should work without code', () {
      final exception = McpException('Unknown error');
      expect(exception.toString(), 'McpException(null): Unknown error');
    });
  });

  group('McpPriority', () {
    test('should have four priority levels', () {
      expect(McpPriority.values.length, 4);
      expect(McpPriority.critical.index, 3);
      expect(McpPriority.low.index, 0);
    });
  });

  group('McpMessageType', () {
    test('should have all required message types', () {
      final types = McpMessageType.values.map((e) => e.name).toSet();
      expect(types.contains('handshake'), true);
      expect(types.contains('dispatch'), true);
      expect(types.contains('query'), true);
      expect(types.contains('response'), true);
      expect(types.contains('heartbeat'), true);
      expect(types.contains('event'), true);
      expect(types.contains('error'), true);
    });
  });

  group('McpConnectionState', () {
    test('should have four connection states', () {
      expect(McpConnectionState.values.length, 4);
      expect(McpConnectionState.connected.name, 'connected');
      expect(McpConnectionState.disconnected.name, 'disconnected');
    });
  });
}
