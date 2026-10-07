import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// The single light theme this app renders (no toggle: a bar counter is a
/// bright room, and one theme keeps every screen predictable).
///
/// Material 3 tints surfaces from the seed/primary by default; every
/// surface role is pinned to plain white/grey here so dialogs, menus and
/// dropdowns never pick up a lilac cast.
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.bg,
  canvasColor: AppColors.surface,
  fontFamily: AppTextStyles.body.fontFamily,
  colorScheme: const ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    primaryContainer: AppColors.accentSoft,
    onPrimaryContainer: AppColors.accent,
    secondary: AppColors.accent,
    onSecondary: AppColors.onAccent,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    surfaceTint: Colors.transparent,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surface,
    surfaceContainerHighest: AppColors.surfaceAlt,
    outline: AppColors.borderStrong,
    outlineVariant: AppColors.border,
    inverseSurface: AppColors.snackBar,
    onInverseSurface: Colors.white,
  ),
  textTheme: const TextTheme(
    headlineLarge: AppTextStyles.h1,
    headlineMedium: AppTextStyles.h2,
    headlineSmall: AppTextStyles.h3,
    titleLarge: AppTextStyles.h4,
    titleMedium: AppTextStyles.h5,
    titleSmall: AppTextStyles.h6,
    bodyLarge: AppTextStyles.body,
    bodyMedium: AppTextStyles.body,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(color: AppColors.border),
    ),
  ),
  dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 6,
    shadowColor: const Color(0x33141620),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(color: AppColors.border),
    ),
    titleTextStyle: AppTextStyles.h4,
    contentTextStyle: AppTextStyles.body,
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 4,
    shadowColor: const Color(0x26141620),
    textStyle: AppTextStyles.body,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: AppColors.border),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.snackBar,
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    actionTextColor: AppColors.accentBorder,
  ),
  tooltipTheme: const TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.snackBar,
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
    ),
    textStyle: TextStyle(color: Colors.white, fontSize: 12),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.borderStrong),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.borderStrong),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.accent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.danger, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.textMuted),
    floatingLabelStyle: const TextStyle(color: AppColors.accent),
    helperStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
    hintStyle: const TextStyle(color: AppColors.textDisabled),
    suffixStyle: const TextStyle(color: AppColors.textMuted),
    prefixIconColor: AppColors.textMuted,
    suffixIconColor: AppColors.textMuted,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.onAccent,
      disabledBackgroundColor: AppColors.surfaceAlt,
      disabledForegroundColor: AppColors.textDisabled,
      minimumSize: const Size(64, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    ),
  ),
  // The login button — the screen's one primary action, so solid brand.
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.onAccent,
      disabledBackgroundColor: AppColors.surfaceAlt,
      disabledForegroundColor: AppColors.textDisabled,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.text,
      backgroundColor: AppColors.surface,
      disabledForegroundColor: AppColors.textDisabled,
      minimumSize: const Size(64, 44),
      side: const BorderSide(color: AppColors.borderStrong),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accent,
      minimumSize: const Size(64, 44),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: AppColors.textMuted),
  ),
  iconTheme: const IconThemeData(color: AppColors.textMuted),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.accent,
    linearTrackColor: AppColors.accentSoft,
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(AppColors.borderStrong),
    thickness: WidgetStateProperty.all(6),
  ),
);
