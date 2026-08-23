import 'package:challengeapp/config/service/config_service.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkTheme = AppStateWidget.of(context)
        .get<ConfigService>()
        .isDarkMode;
    return Drawer(
      child: Column(
        // padding: EdgeInsets.zero,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: DrawerHeader(
                  decoration: BoxDecoration(color: theme.primaryColor),
                  child: Text(
                    'Challenge Yourself',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
            ],
          ),
          SwitchListTile(
            secondary: const Icon(MdiIcons.paletteSwatch),
            title: Text(darkTheme.value ? 'Dark Theme' : 'Light Theme'),
            value: darkTheme.value,
            onChanged: (value) => darkTheme.value = value,
          ),
          ListTile(
            leading: const Icon(MdiIcons.formatListChecks),
            title: const Text('Issues & Feature Requests'),
            onTap: () => launchUrl(
              Uri.parse("https://github.com/sterlp/daily-challenge/issues"),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report a bug'),
            onTap: () => launchUrl(
              Uri.parse("https://github.com/sterlp/daily-challenge/issues/new"),
              mode: LaunchMode.externalApplication,
            ),
          ),
          Expanded(child: Container()),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final packageInfo = snapshot.data!;
                return ListTile(
                  leading: const Icon(Icons.info),
                  title: Text('v${packageInfo.version} Beta'),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
