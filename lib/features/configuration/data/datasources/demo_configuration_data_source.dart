import '../../domain/models/rover_configuration.dart';
import 'configuration_data_source.dart';

class DemoConfigurationDataSource implements ConfigurationDataSource {
  RoverConfiguration _currentConfig = const RoverConfiguration(
    deviceName: 'ROVER-01',
    operatingMode: 'Demo Mode',
    telemetryIntervalSeconds: 5,
    networkMode: 'Station (Wi-Fi)',
    ssid: 'Rover-AP',
    maskedPassword: '••••••••••••',
    distanceUnit: 'cm',
    cameraResolution: 'VGA 640x480',
  );

  @override
  Future<RoverConfiguration> getConfiguration() async {
    return _currentConfig;
  }

  @override
  Future<void> persistConfiguration(RoverConfiguration config) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentConfig = config;
  }

  @override
  Future<RoverConfiguration> getDefaults() async {
    return const RoverConfiguration(
      deviceName: 'ROVER-01',
      operatingMode: 'Demo Mode',
      telemetryIntervalSeconds: 5,
      networkMode: 'Station (Wi-Fi)',
      ssid: 'Rover-AP',
      maskedPassword: '••••••••••••',
      distanceUnit: 'cm',
      cameraResolution: 'VGA 640x480',
    );
  }
}

