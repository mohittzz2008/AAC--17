import '../models/movement_command.dart';
import '../models/movement_direction.dart';
import '../models/rover_operation_telemetry.dart';

/// Contract for sending remote movement commands and observing remote operation telemetry.
abstract interface class RoverOperationRepository {
  /// Fetches current operation telemetry and hardware health status.
  Future<RoverOperationTelemetry> fetchOperationTelemetry();

  /// Transmits a movement command (Forward, Backward, Left, Right).
  Future<MovementCommand> sendMovementCommand(MovementDirection direction);

  /// Sends a normal stop command to halt motor movement.
  Future<MovementCommand> sendStopCommand();

  /// Triggers an immediate hardware Emergency Stop.
  Future<MovementCommand> triggerEmergencyStop();

  /// Clears the Emergency Stop lock after safety acknowledgement.
  Future<MovementCommand> resetEmergencyStop();
}

