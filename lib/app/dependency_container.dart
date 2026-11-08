import '../features/activity_logs/data/datasources/demo_activity_logs_data_source.dart';
import '../features/activity_logs/data/repositories/activity_logs_repository_impl.dart';
import '../features/activity_logs/domain/repositories/activity_logs_repository.dart';
import '../features/activity_logs/presentation/viewmodels/activity_logs_viewmodel.dart';
import '../features/camera/data/datasources/demo_camera_data_source.dart';
import '../features/camera/data/repositories/camera_repository_impl.dart';
import '../features/camera/domain/repositories/camera_repository.dart';
import '../features/camera/presentation/viewmodels/camera_viewmodel.dart';
import '../features/configuration/data/datasources/demo_configuration_data_source.dart';
import '../features/configuration/data/repositories/configuration_repository_impl.dart';
import '../features/configuration/domain/repositories/configuration_repository.dart';
import '../features/configuration/presentation/viewmodels/configuration_viewmodel.dart';
import '../features/dashboard/data/datasources/demo_dashboard_data_source.dart';
import '../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import '../features/device_connection/data/datasources/demo_device_connection_data_source.dart';
import '../features/device_connection/data/repositories/device_connection_repository_impl.dart';
import '../features/device_connection/domain/repositories/device_connection_repository.dart';
import '../features/device_connection/presentation/viewmodels/device_connection_viewmodel.dart';
import '../features/diagnostics/data/datasources/demo_diagnostics_data_source.dart';
import '../features/diagnostics/data/repositories/diagnostics_repository_impl.dart';
import '../features/diagnostics/domain/repositories/diagnostics_repository.dart';
import '../features/diagnostics/presentation/viewmodels/diagnostics_viewmodel.dart';
import '../features/firmware/data/datasources/demo_firmware_data_source.dart';
import '../features/firmware/data/repositories/firmware_repository_impl.dart';
import '../features/firmware/domain/repositories/firmware_repository.dart';
import '../features/firmware/presentation/viewmodels/firmware_viewmodel.dart';
import '../features/rover_operation/data/datasources/demo_rover_operation_data_source.dart';
import '../features/rover_operation/data/repositories/rover_operation_repository_impl.dart';
import '../features/rover_operation/domain/repositories/rover_operation_repository.dart';
import '../features/rover_operation/presentation/viewmodels/rover_operation_viewmodel.dart';
import '../features/sensors/data/datasources/demo_sensors_data_source.dart';
import '../features/sensors/data/repositories/sensors_repository_impl.dart';
import '../features/sensors/domain/repositories/sensors_repository.dart';
import '../features/sensors/presentation/viewmodels/sensors_viewmodel.dart';
import '../features/system/data/datasources/demo_system_data_source.dart';
import '../features/system/data/repositories/system_repository_impl.dart';
import '../features/system/domain/repositories/system_repository.dart';
import '../features/system/presentation/viewmodels/system_viewmodel.dart';

/// Lightweight dependency container managing singleton repositories and ViewModels
/// across the entire application without external third-party dependencies.
class DependencyContainer {
  static final DependencyContainer _instance = DependencyContainer._internal();
  factory DependencyContainer() => _instance;

  DependencyContainer._internal() {
    _initRepositories();
    _initViewModels();
  }

  // Repositories
  late final DashboardRepository dashboardRepository;
  late final CameraRepository cameraRepository;
  late final SensorsRepository sensorsRepository;
  late final SystemRepository systemRepository;
  late final DeviceConnectionRepository deviceConnectionRepository;
  late final DiagnosticsRepository diagnosticsRepository;
  late final ActivityLogsRepository activityLogsRepository;
  late final ConfigurationRepository configurationRepository;
  late final FirmwareRepository firmwareRepository;
  late final RoverOperationRepository roverOperationRepository;

  // ViewModels
  late final DashboardViewModel dashboardViewModel;
  late final CameraViewModel cameraViewModel;
  late final SensorsViewModel sensorsViewModel;
  late final RoverOperationViewModel roverOperationViewModel;
  late final SystemViewModel systemViewModel;
  late final DeviceConnectionViewModel deviceConnectionViewModel;
  late final DiagnosticsViewModel diagnosticsViewModel;
  late final ActivityLogsViewModel activityLogsViewModel;
  late final ConfigurationViewModel configurationViewModel;
  late final FirmwareViewModel firmwareViewModel;

  void _initRepositories() {
    dashboardRepository = const DashboardRepositoryImpl(dataSource: DemoDashboardDataSource());
    cameraRepository = CameraRepositoryImpl(const DemoCameraDataSource());
    sensorsRepository = SensorsRepositoryImpl(const DemoSensorsDataSource());
    systemRepository = SystemRepositoryImpl(const DemoSystemDataSource());
    deviceConnectionRepository = DeviceConnectionRepositoryImpl(const DemoDeviceConnectionDataSource());
    diagnosticsRepository = DiagnosticsRepositoryImpl(const DemoDiagnosticsDataSource());
    activityLogsRepository = ActivityLogsRepositoryImpl(const DemoActivityLogsDataSource());
    configurationRepository = ConfigurationRepositoryImpl(DemoConfigurationDataSource());
    firmwareRepository = FirmwareRepositoryImpl(const DemoFirmwareDataSource());
    roverOperationRepository = RoverOperationRepositoryImpl(DemoRoverOperationDataSource());
  }

  void _initViewModels() {
    dashboardViewModel = DashboardViewModel(repository: dashboardRepository);
    cameraViewModel = CameraViewModel(cameraRepository);
    sensorsViewModel = SensorsViewModel(sensorsRepository);
    roverOperationViewModel = RoverOperationViewModel(roverOperationRepository);
    systemViewModel = SystemViewModel(systemRepository);
    deviceConnectionViewModel = DeviceConnectionViewModel(deviceConnectionRepository);
    diagnosticsViewModel = DiagnosticsViewModel(diagnosticsRepository);
    activityLogsViewModel = ActivityLogsViewModel(activityLogsRepository);
    configurationViewModel = ConfigurationViewModel(configurationRepository);
    firmwareViewModel = FirmwareViewModel(firmwareRepository);
  }

  void dispose() {
    dashboardViewModel.dispose();
    cameraViewModel.dispose();
    sensorsViewModel.dispose();
    roverOperationViewModel.dispose();
    systemViewModel.dispose();
    deviceConnectionViewModel.dispose();
    diagnosticsViewModel.dispose();
    activityLogsViewModel.dispose();
    configurationViewModel.dispose();
    firmwareViewModel.dispose();
  }
}
