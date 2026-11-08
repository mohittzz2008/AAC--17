import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ROVER COMMAND typography definitions.
///
/// Interface Typography: Inter (with robust system sans-serif fallbacks).
/// Telemetry & Technical Typography: JetBrains Mono (with robust monospace fallbacks).
abstract final class AppTypography {
  static const String interfaceFontFamily = 'Inter';
  static const List<String> interfaceFontFallbacks = [
    'Inter',
    'Segoe UI',
    '-apple-system',
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  static const String telemetryFontFamily = 'JetBrains Mono';
  static const List<String> telemetryFontFallbacks = [
    'JetBrains Mono',
    'Consolas',
    'Courier New',
    'SF Mono',
    'Roboto Mono',
    'monospace',
  ];

  // Base text styles
  static const TextStyle interfaceBase = TextStyle(
    fontFamily: interfaceFontFamily,
    fontFamilyFallback: interfaceFontFallbacks,
    color: AppColors.white,
  );

  static const TextStyle telemetryBase = TextStyle(
    fontFamily: telemetryFontFamily,
    fontFamilyFallback: telemetryFontFallbacks,
    color: AppColors.white,
  );

  // Application Header
  static TextStyle get appTitle => interfaceBase.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
        color: AppColors.white,
      );

  static TextStyle get appSubtitle => interfaceBase.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.gold,
      );

  static TextStyle get demoBadge => interfaceBase.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.black,
      );

  // Status & Alert Banner
  static TextStyle get alertTitle => interfaceBase.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.white,
      );

  static TextStyle get alertSubtitle => interfaceBase.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: AppColors.secondaryText,
      );

  static TextStyle get cardTitle => interfaceBase.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.white,
      );

  static TextStyle get subtitle => interfaceBase.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: AppColors.secondaryText,
      );

  // Section Headers & Field Labels
  static TextStyle get sectionHeader => interfaceBase.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.secondaryText,
      );

  static TextStyle get fieldLabel => interfaceBase.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.secondaryText,
      );

  // Telemetry & Hardware Values (JetBrains Mono)
  static TextStyle get telemetryValue => telemetryValueMedium;

  static TextStyle get telemetryValueLarge => telemetryBase.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: AppColors.white,
      );

  static TextStyle get telemetryValueMedium => telemetryBase.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.white,
      );

  static TextStyle get telemetryValueRegular => telemetryBase.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.white,
      );

  static TextStyle get telemetryUnit => telemetryBase.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.white,
      );

  // Status Tags & Captions
  static TextStyle get statusTagGold => interfaceBase.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.gold,
      );

  static TextStyle get statusTagSecondary => interfaceBase.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.secondaryText,
      );

  static TextStyle get caption => interfaceBase.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: AppColors.secondaryText,
      );

  // Navigation
  static TextStyle get navLabelSelected => interfaceBase.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.gold,
      );

  static TextStyle get navLabelUnselected => interfaceBase.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: AppColors.secondaryText,
      );
}

