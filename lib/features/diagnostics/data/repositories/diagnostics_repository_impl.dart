import '../../domain/models/diagnostics_bundle.dart';
import '../../domain/repositories/diagnostics_repository.dart';
import '../datasources/diagnostics_data_source.dart';

class DiagnosticsRepositoryImpl implements DiagnosticsRepository {
  final DiagnosticsDataSource _dataSource;

  DiagnosticsRepositoryImpl(this._dataSource);

  @override
  Future<DiagnosticsBundle> fetchDiagnostics() {
    return _dataSource.getDiagnostics();
  }

  @override
  Future<DiagnosticsBundle> runDiagnosticsCheck() {
    return _dataSource.executeDiagnostics();
  }
}

