import '../../domain/models/firmware_bundle.dart';

abstract class FirmwareDataSource {
  Future<FirmwareBundle> getFirmwareInfo();
  Future<FirmwareBundle> queryUpdates();
}

