import '../../../../shared/domain/enums/connection_status.dart';
import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';
import '../../../../shared/domain/enums/measurement_validity.dart';
import '../../../dashboard/domain/models/rover_session_status.dart';
import '../../domain/models/system_telemetry_bundle.dart';
import 'system_data_source.dart';

class DemoSystemDataSource implements SystemDataSource {
  const DemoSystemDataSource();

  @override
  Future<SystemTelemetryBundle> getSystemTelemetry() async {
    return const SystemTelemetryBundle(
      session: RoverSessionStatus(
        roverId: 'ROVER-01',
        sessionDescription: 'Demo presentation only · No live telemetry',
        verification: HardwareVerificationStatus.notVerified,
        connection: ConnectionStatus.disconnected,
        dataSourceType: DataSourceType.demoSimulated,
      ),
      overview: SystemOverview(
        roverId: 'ROVER-01',
        mode: 'Demo',
        connection: ConnectionStatus.disconnected,
        lastUpdate: '--',
      ),
      power: SystemPowerInfo(
        batteryDescription: '12V Li-ion battery',
        buckDescription: '2 × 6V buck converters',
        voltageValidity: MeasurementValidity.unavailable,
        chargeValidity: MeasurementValidity.unavailable,
        buckOutputValidity: MeasurementValidity.unavailable,
      ),
      verificationStatus: HardwareVerificationStatus.notVerified,
    );
  }
}
