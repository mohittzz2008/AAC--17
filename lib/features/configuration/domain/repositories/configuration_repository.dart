import '../models/rover_configuration.dart';

abstract class ConfigurationRepository {
  Future<RoverConfiguration> fetchConfiguration();
  Future<void> saveConfiguration(RoverConfiguration config);
  Future<RoverConfiguration> resetToDefaults();
}

