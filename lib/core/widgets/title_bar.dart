import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:window_manager/window_manager.dart';

import '../../generated/l10n.dart';
import '../theme/nocturne_colors.dart';

/// Custom frameless title bar — `window_manager` hides the OS chrome
/// (`TitleBarStyle.hidden`), so drag/minimize/maximize/close are reimplemented
/// here to match the design's slim dark bar.
///
/// On macOS the native traffic-light buttons stay visible with a hidden
/// title bar, so this bar only leaves room for them instead of drawing a
/// second set of window controls.
class TitleBar extends StatefulWidget {
  const TitleBar({super.key});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> with WindowListener {
  bool _isMaximized = false;

  static final bool _nativeControls = Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((value) {
      if (mounted) setState(() => _isMaximized = value);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: NocturneColors.bg,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => windowManager.startDragging(),
              onDoubleTap: () => windowManager.isMaximized().then(
                (isMax) => isMax
                    ? windowManager.unmaximize()
                    : windowManager.maximize(),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: _nativeControls ? 80 : 12),
                child: Row(
                  children: [
                    const Icon(
                      PhosphorIconsFill.martini,
                      size: 14,
                      color: NocturneColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalization.of(context).appTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: NocturneColors.text.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_nativeControls) ...[
            _TitleBarButton(
              icon: PhosphorIconsRegular.minus,
              onPressed: () => windowManager.minimize(),
            ),
            _TitleBarButton(
              icon: _isMaximized
                  ? PhosphorIconsRegular.copySimple
                  : PhosphorIconsRegular.square,
              iconSize: _isMaximized ? 12 : 11,
              onPressed: () => _isMaximized
                  ? windowManager.unmaximize()
                  : windowManager.maximize(),
            ),
            _TitleBarButton(
              icon: PhosphorIconsRegular.x,
              hoverColor: NocturneColors.danger,
              onPressed: () => windowManager.close(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TitleBarButton extends StatelessWidget {
  const _TitleBarButton({
    required this.icon,
    required this.onPressed,
    this.iconSize = 13,
    this.hoverColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          hoverColor: (hoverColor ?? NocturneColors.neutral800).withValues(
            alpha: 0.5,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: NocturneColors.text.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

/// Every top-level screen of this frameless app: the custom title bar above
/// the page body, so the window can always be dragged and closed.
class WindowScaffold extends StatelessWidget {
  const WindowScaffold({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NocturneColors.bg,
      body: Column(
        children: [
          const TitleBar(),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
