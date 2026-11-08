import 'package:flutter/foundation.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../state/dashboard_state.dart';

/// ViewModel managing state orchestration and telemetry lifecycle for the Dashboard screen.
///
/// Communicates strictly via [DashboardRepository] without direct data-source access.
class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardState _state = const DashboardInitial();
  bool _isFetching = false;
  bool _disposed = false;

  DashboardViewModel({
    required DashboardRepository repository,
  }) : _repository = repository;

  /// The current immutable presentation state.
  DashboardState get state => _state;

  /// Whether a telemetry fetch is actively in progress.
  bool get isFetching => _isFetching;

  /// Fetches telemetry from the repository and updates state.
  ///
  /// Prevents concurrent/duplicate requests if a fetch is already running.
  Future<void> loadTelemetry({bool showLoadingIndicator = true}) async {
    if (_isFetching || _disposed) return;

    _isFetching = true;

    if (showLoadingIndicator) {
      _updateState(const DashboardLoading());
    }

    try {
      final bundle = await _repository.getTelemetrySnapshot();
      if (_disposed) return;

      _updateState(
        DashboardLoaded(
          data: bundle,
          isDemoMode: bundle.session.dataSourceType.isSimulated,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (error) {
      if (_disposed) return;
      _updateState(
        DashboardError(
          error is StateError
              ? error.message
              : 'Failed to retrieve rover telemetry: $error',
        ),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Convenience method to refresh telemetry without replacing existing view with full loader.
  Future<void> refresh() => loadTelemetry(showLoadingIndicator: false);

  void _updateState(DashboardState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}
