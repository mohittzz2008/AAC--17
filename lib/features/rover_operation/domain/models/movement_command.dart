import 'movement_direction.dart';

/// Strongly typed movement command dispatched to the rover motor subsystem.
class MovementCommand {
  final MovementDirection direction;
  final DateTime timestamp;
  final int sequenceNumber;
  final bool isEmergencyStop;
  final bool isConfirmed;

  const MovementCommand({
    required this.direction,
    required this.timestamp,
    required this.sequenceNumber,
    this.isEmergencyStop = false,
    this.isConfirmed = false,
  });

  MovementCommand copyWith({
    MovementDirection? direction,
    DateTime? timestamp,
    int? sequenceNumber,
    bool? isEmergencyStop,
    bool? isConfirmed,
  }) {
    return MovementCommand(
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      isEmergencyStop: isEmergencyStop ?? this.isEmergencyStop,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

