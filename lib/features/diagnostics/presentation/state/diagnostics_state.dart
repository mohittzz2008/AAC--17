import '../../domain/models/diagnostics_bundle.dart';

sealed class DiagnosticsState {
  const DiagnosticsState();
}

class DiagnosticsInitial extends DiagnosticsState {
  const DiagnosticsInitial();
}

class DiagnosticsLoading extends DiagnosticsState {
  const DiagnosticsLoading();
}

class DiagnosticsLoaded extends DiagnosticsState {
  final DiagnosticsBundle data;
  final bool isRunningCheck;

  const DiagnosticsLoaded(this.data, {this.isRunningCheck = false});

  DiagnosticsLoaded copyWith({
    DiagnosticsBundle? data,
    bool? isRunningCheck,
  }) {
    return DiagnosticsLoaded(
      data ?? this.data,
      isRunningCheck: isRunningCheck ?? this.isRunningCheck,
    );
  }
}

class DiagnosticsError extends DiagnosticsState {
  final String message;
  const DiagnosticsError(this.message);
}

