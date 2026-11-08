import '../../domain/models/movement_command.dart';
import '../../domain/models/movement_direction.dart';
import '../../domain/models/rover_operation_telemetry.dart';
import '../../domain/repositories/rover_operation_repository.dart';
import '../datasources/rover_operation_data_source.dart';

class RoverOperationRepositoryImpl implements RoverOperationRepository {
  final RoverOperationDataSource _dataSource;

  RoverOperationRepositoryImpl(this._dataSource);

  @override
  Future<RoverOperationTelemetry> fetchOperationTelemetry() =>
      _dataSource.getOperationTelemetry();

  @override
  Future<MovementCommand> sendMovementCommand(MovementDirection direction) =>
      _dataSource.dispatchMovement(direction);

  @override
  Future<MovementCommand> sendStopCommand() => _dataSource.dispatchStop();

  @override
  Future<MovementCommand> triggerEmergencyStop() =>
      _dataSource.dispatchEmergencyStop();

  @override
  Future<MovementCommand> resetEmergencyStop() =>
      _dataSource.resetEmergencyStop();
}

