import '../../domain/models/diagnostics_bundle.dart';

abstract class DiagnosticsDataSource {
  Future<DiagnosticsBundle> getDiagnostics();
  Future<DiagnosticsBundle> executeDiagnostics();
}

