import '../models/firmware_bundle.dart';

abstract class FirmwareRepository {
  Future<FirmwareBundle> fetchFirmwareInfo();
  Future<FirmwareBundle> checkForUpdates();
}

