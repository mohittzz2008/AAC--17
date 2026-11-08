/// Identifies the transport-level communication state with a hardware entity.
enum ConnectionStatus {
  /// Active telemetry/communication channel established.
  connected('CONNECTED'),

  /// Handshake or connection establishment currently in progress.
  connecting('CONNECTING'),

  /// No active physical link or network connection exists.
  disconnected('NOT CONNECTED');

  final String displayLabel;
  const ConnectionStatus(this.displayLabel);

  bool get isConnected => this == ConnectionStatus.connected;
  bool get isConnecting => this == ConnectionStatus.connecting;
  bool get isDisconnected => this == ConnectionStatus.disconnected;
}

