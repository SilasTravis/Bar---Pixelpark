import 'package:flutter/material.dart';

/// Pixel Bar's light palette — the only theme this terminal renders.
///
/// Tuned for a bright bar counter: near-white surfaces, near-black text and
/// a brand purple deepened from the cashier app's Nocturne `#9184D9` so
/// white text on it stays readable (≈5:1). Every text/background pair below
/// meets WCAG AA (4.5:1) unless noted.
abstract final class AppColors {
  // ── Surfaces ──────────────────────────────────────────────────────────
  /// Window / scaffold background — a whisper of grey so white cards and
  /// tiles separate from it without shadows.
  static const Color bg = Color(0xFFF4F5F9);

  /// Cards, tiles, panels, dialogs, menus, header, title bar.
  static const Color surface = Color(0xFFFFFFFF);

  /// Recessed rows inside a white panel (cart lines, step buttons).
  static const Color surfaceAlt = Color(0xFFF1F2F7);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color text = Color(0xFF14161F); // 17:1 on white
  static const Color textMuted = Color(0xFF555B6E); // 6.9:1 on white
  static const Color textDisabled = Color(0xFF9AA0B2);

  // ── Lines ─────────────────────────────────────────────────────────────
  /// Card / tile / panel outline — replaces the dark theme's shadows.
  static const Color border = Color(0xFFDCDFE8);

  /// Inputs and outlined buttons: a control must read as a control.
  static const Color borderStrong = Color(0xFFB9BECD);
  static const Color divider = Color(0xFFE6E8EF);

  // ── Brand ─────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF6A5BD0); // 5.2:1 vs white
  static const Color accentSoft = Color(0xFFEFEDFC); // selected/tinted fill
  static const Color accentBorder = Color(0xFFC9C2F5);
  static const Color onAccent = Color(0xFFFFFFFF);

  // ── Payment methods (big, distinct, never confused) ────────────────────
  static const Color cash = Color(0xFF15803D); // green, 5.0:1 vs white
  static const Color cashSoft = Color(0xFFE8F6EE);
  static const Color card = Color(0xFF2563EB); // blue, 5.2:1 vs white
  static const Color cardSoft = Color(0xFFE8EFFD);

  // ── Status ────────────────────────────────────────────────────────────
  static const Color success = cash;
  static const Color danger = Color(0xFFDC2626); // 4.8:1 vs white
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFCA5A5);

  /// Amber fill (badges, the "printer failed" snackbar — black text on it).
  static const Color warning = Color(0xFFF59E0B);

  /// Amber as text on white (a surplus in the cash count).
  static const Color warningText = Color(0xFFB45309); // 5.0:1 vs white

  /// Default snackbar: dark ink bar, white text — the one dark element,
  /// kept because it is the most noticeable transient on a light screen.
  static const Color snackBar = Color(0xFF1F2330);
}

/// Border radii — `--radius-sm/md/lg`.
abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 14;
}

/// Spacing scale — `--space-1..8`.
abstract final class AppSpacing {
  static const double x1 = 2.8;
  static const double x2 = 5.6;
  static const double x3 = 8.4;
  static const double x4 = 11.2;
  static const double x6 = 16.8;
  static const double x8 = 22.4;
}

/// Elevation for the light theme: a crisp 1px outline does the separating;
/// md/lg add only a faint ambient shadow (no heavy dark drops).
abstract final class AppShadow {
  static const List<BoxShadow> sm = [
    BoxShadow(color: AppColors.border, spreadRadius: 1, blurRadius: 0),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: AppColors.border, spreadRadius: 1, blurRadius: 0),
    BoxShadow(color: Color(0x0F141620), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: AppColors.borderStrong, spreadRadius: 1, blurRadius: 0),
    BoxShadow(color: Color(0x1A141620), blurRadius: 24, offset: Offset(0, 8)),
  ];
}
