class ConnectionHistoryEntry {
  final String timestamp;
  final String event;
  final bool isSuccess;

  const ConnectionHistoryEntry({
    required this.timestamp,
    required this.event,
    this.isSuccess = true,
  });
}

