import 'package:challengeapp/challengelist/i18n/challengelist_localization.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/widget/challenge_widget.dart';
import 'package:challengeapp/common/common_types.dart';

import '../../mock_app_context.dart';
import '../../test_helper.dart';

void main() {
  final _commonI18n = ChallengeLocalizations(const Locale('en'));
  final _i18n = ChallengeListLocalizations(const Locale('en'));

  AppContextMock appContextMock;
  AppContainer appContainer;

  setUp(() async {
    appContextMock = AppContextMock();
    appContainer = appContextMock.appContext;
  });

  testWidgets('Show failed challenge', (WidgetTester tester) async {
    final yesterday = DateTime.now().add(const Duration(days: -1));
    final c = Challenge.of('test challenge 1', yesterday, 77)
      ..status = ChallengeStatus.failed
      ..doneAt = yesterday
      ..dueAt = yesterday;

    await pumpTestApp(tester, ChallengeWidget(appContainer, c));

    expect(find.text('test challenge 1'), findsOneWidget);
    expect(find.text(_i18n.failedSince(_commonI18n.formatDate(c.latestAt))), findsOneWidget);
    expect(find.byIcon(MyStyle.ICON_FAILED_CHALLENGE), findsOneWidget);
    // no checkbox for failed challenges!
    expect(find.byType(Checkbox), findsNothing);

  });

  testWidgets('Show done challenge', (WidgetTester tester) async {
    final yesterday = DateTime.now().add(const Duration(days: -1));
    final c = Challenge.of('test challenge 1', yesterday, 77)
      ..status = ChallengeStatus.done
      ..doneAt = yesterday
      ..dueAt = yesterday;

    await pumpTestApp(tester, ChallengeWidget(appContainer, c));

    expect(find.text(_i18n.doneAt(_commonI18n.formatDate(c.doneAt))), findsOneWidget);
    expect(find.byIcon(MyStyle.ICON_DONE_CHALLENGE), findsOneWidget);

    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('Show simple challenge', (WidgetTester tester) async {
    // Create the widget by telling the tester to build it.
    final c = Challenge.of('test challenge 1', null, 77);
    await pumpTestApp(tester, Card(
      child: ListView(
        children: [
            ChallengeWidget(appContainer, c),
            ChallengeWidget(appContainer, Challenge.of('test challenge 2'))
          ]
        ),
      ),
      appContextMock.appContext
    );
    await tester.pumpAndSettle();

    expect(find.text(c.name), findsOneWidget);
    expect(find.text('77'), findsOneWidget);
    
    expect(find.text('test challenge 2'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    expect(find.byIcon(MyStyle.ICON_PENDING_CHALLENGE), findsNWidgets(2));
    expect(find.byType(Checkbox), findsNWidgets(2));
  });
}