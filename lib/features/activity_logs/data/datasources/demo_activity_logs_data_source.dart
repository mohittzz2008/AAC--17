import '../../../../shared/domain/enums/log_category.dart';
import '../../../../shared/domain/enums/log_severity.dart';
import '../../domain/models/activity_log_entry.dart';
import 'activity_logs_data_source.dart';

class DemoActivityLogsDataSource implements ActivityLogsDataSource {
  const DemoActivityLogsDataSource();

  @override
  Future<List<ActivityLogEntry>> getLogs() async {
    return const [
      ActivityLogEntry(
        id: 'LOG-001',
        timestamp: '10:24:32',
        category: LogCategory.application,
        severity: LogSeverity.info,
        title: 'Device discovery completed',
        description: 'Completed local network discovery scan. 1 demo device identified.',
        source: 'DiscoveryService',
      ),
      ActivityLogEntry(
        id: 'LOG-002',
        timestamp: '10:24:31',
        category: LogCategory.application,
        severity: LogSeverity.info,
        title: 'Demo mode activated',
        description: 'ROVER COMMAND launched in simulated telemetry mode.',
        source: 'RoverApp',
      ),
      ActivityLogEntry(
        id: 'LOG-003',
        timestamp: '10:20:11',
        category: LogCategory.communication,
        severity: LogSeverity.warning,
        title: 'Connection attempt failed',
        description: 'TCP handshake timed out. No physical ESP32 endpoint reachable.',
        source: 'TransportService',
        errorCode: 'ERR_TIMEOUT_CONN',
      ),
      ActivityLogEntry(
        id: 'LOG-004',
        timestamp: '10:15:10',
        category: LogCategory.camera,
        severity: LogSeverity.warning,
        title: 'Camera stream unavailable',
        description: 'ESP32-CAM video pipeline inactive or not connected.',
        source: 'CameraService',
        errorCode: 'ERR_CAM_DISCONNECTED',
      ),
      ActivityLogEntry(
        id: 'LOG-005',
        timestamp: '10:11:42',
        category: LogCategory.sensor,
        severity: LogSeverity.info,
        title: 'Sensor telemetry updated',
        description: 'HC-SR04 ultrasonic and RCWL-0516 radar readings refreshed.',
        source: 'TelemetryService',
      ),
      ActivityLogEntry(
        id: 'LOG-006',
        timestamp: '09:58:17',
        category: LogCategory.configuration,
        severity: LogSeverity.info,
        title: 'Default configuration loaded',
        description: 'Factory demo settings and polling parameters initialized.',
        source: 'ConfigService',
      ),
      ActivityLogEntry(
        id: 'LOG-007',
        timestamp: '09:55:40',
        category: LogCategory.application,
        severity: LogSeverity.info,
        title: 'Application cold start',
        description: 'Rover Command inspection frontend booted successfully.',
        source: 'MainBootstrap',
      ),
    ];
  }
}

