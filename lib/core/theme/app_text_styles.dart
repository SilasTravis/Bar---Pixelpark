import 'package:flutter/material.dart';

import 'app_colors.dart';

/// `--font-heading` / `--font-body` is "Inter" in the design system. No
/// Inter font binaries are bundled in this project yet (add them under
/// `assets/fonts/` and declare the family in pubspec.yaml for a pixel-exact
/// match) — until then this falls back to the Windows platform default
/// (Segoe UI), which is visually close enough for a POS terminal.
const String? _fontFamily = null;

/// Heading + body text styles, sized to match the design's `h1`–`h6` and
/// body scale. Weight 500 (`--font-heading-weight`) for headings.
abstract final class AppTextStyles {
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    height: 1.4,
    color: AppColors.text,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 42,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 25,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );
  static const TextStyle h5 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );
  static const TextStyle h6 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.04, // 0.08em
    color: AppColors.text,
  );

  /// Small uppercase kicker label — used all over the design (`Kassa 2 ·
  /// Zaira`, section eyebrows) at `10px`, `0.1em` tracking.
  static const TextStyle kicker = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    letterSpacing: 1.0,
    fontWeight: FontWeight.w600,
  );

  /// Secondary text. On the light theme a plain alpha of the ink drops
  /// below AA quickly, so the default is the dedicated [AppColors.textMuted]
  /// (6.9:1 on white); pass [opacity] only for a deliberately faded variant.
  static TextStyle muted(TextStyle base, {double? opacity}) => base.copyWith(
    color: opacity == null
        ? AppColors.textMuted
        : (base.color ?? AppColors.text).withValues(alpha: opacity),
  );

  /// Money on the sale screen — tabular figures so prices line up and do
  /// not jitter as the total changes.
  static const TextStyle price = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
