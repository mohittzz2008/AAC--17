import '../../domain/models/rover_configuration.dart';

sealed class ConfigurationState {
  const ConfigurationState();
}

class ConfigurationInitial extends ConfigurationState {
  const ConfigurationInitial();
}

class ConfigurationLoading extends ConfigurationState {
  const ConfigurationLoading();
}

class ConfigurationLoaded extends ConfigurationState {
  final RoverConfiguration currentConfig;
  final RoverConfiguration savedConfig;
  final bool isSaving;
  final String? feedbackMessage;

  const ConfigurationLoaded({
    required this.currentConfig,
    required this.savedConfig,
    this.isSaving = false,
    this.feedbackMessage,
  });

  bool get hasUnsavedChanges => currentConfig != savedConfig;

  ConfigurationLoaded copyWith({
    RoverConfiguration? currentConfig,
    RoverConfiguration? savedConfig,
    bool? isSaving,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return ConfigurationLoaded(
      currentConfig: currentConfig ?? this.currentConfig,
      savedConfig: savedConfig ?? this.savedConfig,
      isSaving: isSaving ?? this.isSaving,
      feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }
}

class ConfigurationError extends ConfigurationState {
  final String message;
  const ConfigurationError(this.message);
}

