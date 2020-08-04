import 'package:challengeapp/config/service/config_service.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AppMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkTheme = AppStateWidget.of(context).get<ConfigService>().isDarkMode;
    return Drawer(
      child: Column(
        // padding: EdgeInsets.zero,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                  ),
                  child: Text(
                      'Challenge Yourself',
                      style: theme.textTheme.headline5
                  ),
                ),
              ),
            ],
          ),
          SwitchListTile(
            secondary: Icon(MdiIcons.paletteSwatch),
            title: Text(darkTheme.value ? 'Dark Theme' : 'Light Theme'),
            value: darkTheme.value,
            onChanged: (value) => darkTheme.value = value,
          ),
          ListTile(
            leading: Icon(MdiIcons.formatListChecks),
            title: Text('Issues & Feature Requests'),
            onTap: () => launch("https://github.com/sterlp/daily-challenge/issues"),
          ),
          ListTile(
            leading: Icon(Icons.bug_report),
            title: Text('Report a bug'),
            onTap: () => launch("https://github.com/sterlp/daily-challenge/issues/new"),
          ),
          Expanded(child: Container()),
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                PackageInfo packageInfo = snapshot.data;
                return ListTile(
                  leading: Icon(Icons.info),
                  title: Text('v${packageInfo.version} Beta'),
                );
              } else {
                return Container();
              }
            }
          ),
        ],
      ),
    );
  }
}
