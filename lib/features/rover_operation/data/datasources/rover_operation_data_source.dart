import '../../domain/models/movement_command.dart';
import '../../domain/models/movement_direction.dart';
import '../../domain/models/rover_operation_telemetry.dart';

abstract interface class RoverOperationDataSource {
  Future<RoverOperationTelemetry> getOperationTelemetry();
  Future<MovementCommand> dispatchMovement(MovementDirection direction);
  Future<MovementCommand> dispatchStop();
  Future<MovementCommand> dispatchEmergencyStop();
  Future<MovementCommand> resetEmergencyStop();
}

