import '../models/diagnostics_bundle.dart';

abstract class DiagnosticsRepository {
  Future<DiagnosticsBundle> fetchDiagnostics();
  Future<DiagnosticsBundle> runDiagnosticsCheck();
}

