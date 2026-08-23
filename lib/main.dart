import 'package:challengeapp/app_config.dart';
import 'package:challengeapp/config/service/config_service.dart';
import 'package:challengeapp/home/page/challenge_home_page.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/home/widget/loading_widget.dart';
import 'package:challengeapp/i18n/app_localizations_delegate.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppContainer _appContext;

  final ThemeData dark = ThemeData.dark().copyWith(
    colorScheme: ThemeData.dark().colorScheme.copyWith(secondary: Colors.blue),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    ),
    tabBarTheme: const TabBarThemeData(indicatorColor: Colors.blue),
  );
  final ThemeData light = ThemeData.light().copyWith(
    buttonTheme: const ButtonThemeData(buttonColor: Colors.blue),
  );

  MyApp({super.key, AppContainer? container})
    : _appContext = container ?? buildContext();

  @override
  Widget build(BuildContext context) {
    // wrap the MaterialApp to ensure that all pages opened with the navigator also see the AppStateWidget
    return AppStateWidget(
      context: _appContext,
      child: FutureBuilder(
        future: _appContext.get<ConfigService>().init(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ValueListenableBuilder<bool>(
              valueListenable: _appContext.get<ConfigService>().isDarkMode,
              builder: (context, value, child) => MaterialApp(
                // https://flutter.dev/docs/development/accessibility-and-localization/internationalization
                localizationsDelegates: AppLocalizationsDelegate.delegates,
                supportedLocales: AppLocalizationsDelegate.locales,
                theme: value ? dark : light,
                home: child,
              ),
              child: const ChallengeHomePage(),
            );
          } else {
            return const MaterialApp(home: LoadingWidget());
          }
        },
      ),
    );
  }
}
