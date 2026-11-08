/// Cardinal movement directions supported by ROVER COMMAND.
enum MovementDirection {
  forward('Forward', 'W'),
  backward('Backward', 'S'),
  left('Turn Left', 'A'),
  right('Turn Right', 'D'),
  stop('Stop', 'None');

  final String label;
  final String keySymbol;

  const MovementDirection(this.label, this.keySymbol);
}

