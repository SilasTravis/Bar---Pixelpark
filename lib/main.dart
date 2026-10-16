// Entry point of Pixel Bar — the bar cashier terminal (Windows + macOS).
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'constants/app_constants.dart';
import 'core/terminal/terminal_heartbeat_service.dart';
import 'core/theme/app_colors.dart';
import 'core/update/update_service.dart';
import 'injector_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  di.sl<UpdateService>().startBackgroundChecks();
  di.sl<TerminalHeartbeatService>().start();

  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1440, 900),
    minimumSize: Size(
      AppConstants.minWindowWidth,
      AppConstants.minWindowHeight,
    ),
    center: true,
    title: 'Pixel Bar',
    backgroundColor: AppColors.bg,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const App());
}
