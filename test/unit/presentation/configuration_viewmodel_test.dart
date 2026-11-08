import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/features/configuration/data/datasources/demo_configuration_data_source.dart';
import 'package:rover_command/features/configuration/data/repositories/configuration_repository_impl.dart';
import 'package:rover_command/features/configuration/presentation/state/configuration_state.dart';
import 'package:rover_command/features/configuration/presentation/viewmodels/configuration_viewmodel.dart';

void main() {
  group('ConfigurationViewModel Tests', () {
    late ConfigurationViewModel viewModel;

    setUp(() {
      final repository = ConfigurationRepositoryImpl(DemoConfigurationDataSource());
      viewModel = ConfigurationViewModel(repository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('loadConfiguration sets initial clean state', () async {
      await viewModel.loadConfiguration();

      expect(viewModel.state, isA<ConfigurationLoaded>());
      final state = viewModel.state as ConfigurationLoaded;
      expect(state.hasUnsavedChanges, isFalse);
      expect(state.currentConfig.deviceName, 'ROVER-01');
    });

    test('mutating device name triggers hasUnsavedChanges flag', () async {
      await viewModel.loadConfiguration();
      viewModel.updateDeviceName('ROVER-ALPHA');

      final state = viewModel.state as ConfigurationLoaded;
      expect(state.hasUnsavedChanges, isTrue);
      expect(state.currentConfig.deviceName, 'ROVER-ALPHA');
    });

    test('saveChanges persists new values and clears dirty flag', () async {
      await viewModel.loadConfiguration();
      viewModel.updateDeviceName('ROVER-BETA');
      await viewModel.saveChanges();

      final state = viewModel.state as ConfigurationLoaded;
      expect(state.hasUnsavedChanges, isFalse);
      expect(state.savedConfig.deviceName, 'ROVER-BETA');
    });
  });
}

