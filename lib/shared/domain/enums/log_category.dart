/// Functional category of an activity or event log record.
enum LogCategory {
  application('App'),
  device('Device'),
  sensor('Sensor'),
  camera('Camera'),
  communication('Comm'),
  configuration('Config'),
  firmware('Firmware');

  final String displayLabel;
  const LogCategory(this.displayLabel);
}

