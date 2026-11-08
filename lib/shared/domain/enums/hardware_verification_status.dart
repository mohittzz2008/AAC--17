/// Identifies whether a hardware module or sensor has been physically verified.
enum HardwareVerificationStatus {
  /// Module has been physically verified and calibrated.
  verified('VERIFIED'),

  /// Module assembly or calibration is pending or unconfirmed.
  notVerified('NOT VERIFIED');

  final String displayLabel;
  const HardwareVerificationStatus(this.displayLabel);

  bool get isVerified => this == HardwareVerificationStatus.verified;
  bool get isNotVerified => this == HardwareVerificationStatus.notVerified;
}

