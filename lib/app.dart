import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/local_source/local_source.dart';
import 'core/localization/locale_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'generated/l10n.dart';
import 'injector_container.dart';
import 'router/app_navigator.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Saved tokens → straight to the shell, which validates them with
    // `GET /v1/bar/auth/me` and checks the open shift.
    final hasSession = sl<LocalSource>().hasSession;

    return BlocProvider(
      create: (_) => sl<LocaleCubit>(),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) => MaterialApp(
          onGenerateTitle: (context) => AppLocalization.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          navigatorKey: rootNavigatorKey,
          // Light only — even when the OS is in dark mode.
          theme: appTheme,
          themeMode: ThemeMode.light,
          locale: locale,
          supportedLocales: AppLocalization.delegate.supportedLocales,
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: hasSession ? Routes.home : Routes.login,
          routes: {
            Routes.login: (_) => const LoginPage(),
            Routes.home: (_) => const HomePage(),
          },
        ),
      ),
    );
  }
}
