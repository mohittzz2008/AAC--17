/// Severity level for system events and activity log records.
enum LogSeverity {
  info('INFO'),
  warning('WARNING'),
  error('ERROR');

  final String displayLabel;
  const LogSeverity(this.displayLabel);

  bool get isInfo => this == LogSeverity.info;
  bool get isWarning => this == LogSeverity.warning;
  bool get isError => this == LogSeverity.error;
}

