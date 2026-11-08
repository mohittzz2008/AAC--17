import '../../domain/models/rover_configuration.dart';
import '../../domain/repositories/configuration_repository.dart';
import '../datasources/configuration_data_source.dart';

class ConfigurationRepositoryImpl implements ConfigurationRepository {
  final ConfigurationDataSource _dataSource;

  ConfigurationRepositoryImpl(this._dataSource);

  @override
  Future<RoverConfiguration> fetchConfiguration() {
    return _dataSource.getConfiguration();
  }

  @override
  Future<void> saveConfiguration(RoverConfiguration config) {
    return _dataSource.persistConfiguration(config);
  }

  @override
  Future<RoverConfiguration> resetToDefaults() {
    return _dataSource.getDefaults();
  }
}

