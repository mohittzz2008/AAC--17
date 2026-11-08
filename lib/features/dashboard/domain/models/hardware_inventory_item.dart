import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';

/// Represents an individual item in the 2x2 Hardware Overview cluster.
class HardwareInventoryItem {
  final String categoryKey;
  final String specification;
  final HardwareVerificationStatus verification;
  final DataSourceType dataSourceType;

  const HardwareInventoryItem({
    required this.categoryKey,
    required this.specification,
    this.verification = HardwareVerificationStatus.notVerified,
    this.dataSourceType = DataSourceType.demoSimulated,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HardwareInventoryItem &&
          runtimeType == other.runtimeType &&
          categoryKey == other.categoryKey &&
          specification == other.specification &&
          verification == other.verification &&
          dataSourceType == other.dataSourceType;

  @override
  int get hashCode =>
      categoryKey.hashCode ^
      specification.hashCode ^
      verification.hashCode ^
      dataSourceType.hashCode;
}

