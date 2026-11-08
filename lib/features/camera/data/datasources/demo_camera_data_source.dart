import '../../../../shared/domain/enums/connection_status.dart';
import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';
import '../../domain/models/camera_telemetry.dart';
import 'camera_data_source.dart';

class DemoCameraDataSource implements CameraDataSource {
  const DemoCameraDataSource();

  @override
  Future<CameraTelemetry> getCameraTelemetry() async {
    return CameraTelemetry(
      moduleTitle: 'ESP32-CAM',
      connectionStatus: ConnectionStatus.disconnected,
      verification: HardwareVerificationStatus.notVerified,
      dataSourceType: DataSourceType.demoSimulated,
      resolution: null,
      frameRate: null,
      lastUpdate: null,
      streamHealth: 'Offline / Disconnected',
      disclaimer: 'Placeholder · Streaming unverified',
    );
  }

  @override
  Future<CameraTelemetry> attemptConnection() async {
    // Simulate brief network/hardware handshake delay
    await Future.delayed(const Duration(milliseconds: 600));
    return CameraTelemetry(
      moduleTitle: 'ESP32-CAM',
      connectionStatus: ConnectionStatus.disconnected,
      verification: HardwareVerificationStatus.notVerified,
      dataSourceType: DataSourceType.demoSimulated,
      resolution: null,
      frameRate: null,
      lastUpdate: null,
      streamHealth: 'Offline / Disconnected',
      disclaimer: 'Connection failed · No ESP32-CAM endpoint found',
    );
  }
}

