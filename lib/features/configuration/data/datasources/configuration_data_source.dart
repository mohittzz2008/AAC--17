import '../../domain/models/rover_configuration.dart';

abstract class ConfigurationDataSource {
  Future<RoverConfiguration> getConfiguration();
  Future<void> persistConfiguration(RoverConfiguration config);
  Future<RoverConfiguration> getDefaults();
}

