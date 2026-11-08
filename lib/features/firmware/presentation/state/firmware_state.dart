import '../../domain/models/firmware_bundle.dart';

sealed class FirmwareState {
  const FirmwareState();
}

class FirmwareInitial extends FirmwareState {
  const FirmwareInitial();
}

class FirmwareLoading extends FirmwareState {
  const FirmwareLoading();
}

class FirmwareLoaded extends FirmwareState {
  final FirmwareBundle bundle;
  final bool isCheckingUpdates;
  final String? feedbackMessage;

  const FirmwareLoaded(
    this.bundle, {
    this.isCheckingUpdates = false,
    this.feedbackMessage,
  });

  FirmwareLoaded copyWith({
    FirmwareBundle? bundle,
    bool? isCheckingUpdates,
    String? feedbackMessage,
  }) {
    return FirmwareLoaded(
      bundle ?? this.bundle,
      isCheckingUpdates: isCheckingUpdates ?? this.isCheckingUpdates,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
    );
  }
}

class FirmwareError extends FirmwareState {
  final String message;
  const FirmwareError(this.message);
}

