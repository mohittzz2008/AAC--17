import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';
import '../../domain/models/movement_command.dart';
import '../../domain/models/movement_direction.dart';
import '../../domain/models/rover_operation_telemetry.dart';
import 'rover_operation_data_source.dart';

class DemoRoverOperationDataSource implements RoverOperationDataSource {
  int _sequenceNumber = 0;
  bool _isEmergencyStopped = false;
  MovementDirection _currentDirection = MovementDirection.stop;

  @override
  Future<RoverOperationTelemetry> getOperationTelemetry() async {
    return RoverOperationTelemetry(
      dataSourceType: DataSourceType.demoSimulated,
      verificationStatus: HardwareVerificationStatus.notVerified,
      roverId: 'ROVER-01 (Demo)',
      isConnected: true,
      latencyMs: 48,
      batteryPercentage: 76,
      motionStatusText: _isEmergencyStopped
          ? 'EMERGENCY STOP'
          : (_currentDirection == MovementDirection.stop ? 'Idle' : 'Active (${_currentDirection.label})'),
      systemStatusText: _isEmergencyStopped ? 'Stop Engaged' : 'Nominal',
      cameraHealthText: 'Online (Simulated)',
      motorDriverHealthText: _isEmergencyStopped ? 'Disabled (E-Stop)' : 'OK',
      controllerHealthText: 'OK',
      sensorModulesHealthText: 'OK',
      overallHealthText: _isEmergencyStopped ? 'Emergency Stop Engaged' : 'All Systems OK',
      temperatureCelsius: 34.2,
      humidityPercentage: 42,
      ultrasonicDistanceMeters: 0.87,
      lightLux: 1240,
      pitchDegrees: 0.6,
      rollDegrees: 2.1,
      cameraResolution: '1080p',
      cameraFps: 30,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<MovementCommand> dispatchMovement(MovementDirection direction) async {
    _sequenceNumber++;
    if (_isEmergencyStopped) {
      // Emergency Stop takes absolute priority: cannot move while locked.
      return MovementCommand(
        direction: MovementDirection.stop,
        timestamp: DateTime.now(),
        sequenceNumber: _sequenceNumber,
        isEmergencyStop: true,
        isConfirmed: false,
      );
    }
    _currentDirection = direction;
    return MovementCommand(
      direction: direction,
      timestamp: DateTime.now(),
      sequenceNumber: _sequenceNumber,
      isEmergencyStop: false,
      isConfirmed: true,
    );
  }

  @override
  Future<MovementCommand> dispatchStop() async {
    _sequenceNumber++;
    if (!_isEmergencyStopped) {
      _currentDirection = MovementDirection.stop;
    }
    return MovementCommand(
      direction: MovementDirection.stop,
      timestamp: DateTime.now(),
      sequenceNumber: _sequenceNumber,
      isEmergencyStop: _isEmergencyStopped,
      isConfirmed: true,
    );
  }

  @override
  Future<MovementCommand> dispatchEmergencyStop() async {
    _sequenceNumber++;
    _isEmergencyStopped = true;
    _currentDirection = MovementDirection.stop;
    return MovementCommand(
      direction: MovementDirection.stop,
      timestamp: DateTime.now(),
      sequenceNumber: _sequenceNumber,
      isEmergencyStop: true,
      isConfirmed: true,
    );
  }

  @override
  Future<MovementCommand> resetEmergencyStop() async {
    _sequenceNumber++;
    _isEmergencyStopped = false;
    _currentDirection = MovementDirection.stop;
    return MovementCommand(
      direction: MovementDirection.stop,
      timestamp: DateTime.now(),
      sequenceNumber: _sequenceNumber,
      isEmergencyStop: false,
      isConfirmed: true,
    );
  }
}

