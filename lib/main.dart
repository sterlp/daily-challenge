import 'package:challengeapp/config/service/config_service.dart';
import 'package:challengeapp/home/widget/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:challengeapp/app_config.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/home/page/challenge_home_page.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/i18n/app_localizations_delegate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppContext _appContext;

  final ThemeData dark = ThemeData.dark().copyWith(
    accentColor: Colors.blue,
    indicatorColor: Colors.blue,
    textSelectionHandleColor: Colors.blue,
    textSelectionColor: Colors.blue,
    toggleableActiveColor: Colors.blue,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    )
  );
  final ThemeData light = ThemeData.light().copyWith(
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue
    )
  );

  MyApp({Key key, AppContext container}) :
        _appContext = container == null ? buildContext() : container,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // wrap the MaterialApp to ensure that all pages opened with the navigator also see the AppStateWidget
    return AppStateWidget(
      context: _appContext,
      child: FutureBuilder(
        future: _appContext.get<ConfigService>().init(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ValueListenableBuilder(
                valueListenable: _appContext.get<ConfigService>().isDarkMode,
                builder: (context, value, child) => MaterialApp(
                  // https://flutter.dev/docs/development/accessibility-and-localization/internationalization
                    localizationsDelegates: AppLocalizationsDelegate.delegates,
                    supportedLocales: AppLocalizationsDelegate.locales,
                    theme: value ? dark : light,
                    home: child
                ),
                child: ChallengeHomePage()
            );
          } else {
            return MaterialApp(home: LoadingWidget());
          }
        }
      )
    );
  }
}