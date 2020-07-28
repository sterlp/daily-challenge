import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterapp/challengelist/i18n/challengelist_localization.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/page/challenge_page.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/challengelist/widget/reward_widget.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/i18n/challenge_localization_delegate.dart';

typedef ChallengeChecked = void Function(Challenge challenge, bool checked);
typedef ChallengeDelete = void Function(Challenge challenge, BuildContext context);
typedef ChallengeEdit = void Function(Challenge challenge, BuildContext context);

class ChallengeWidget extends StatefulWidget {
  final Challenge challenge;
  final ChallengeDelete onDelete;

  ChallengeWidget({Key key, @required this.challenge, this.onDelete}) : super(key: key);

  @override
  _ChallengeWidgetState createState() => _ChallengeWidgetState();
}

class _ChallengeWidgetState extends State<ChallengeWidget> {
  static const _notOpenTextStyle = TextStyle(decoration: TextDecoration.lineThrough);
  static const _edge = EdgeInsets.all(4.0);

  TextStyle _overDueStyle;

  ChallengeListLocalizations _i18n;
  ChallengeLocalizations _commonI18n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = Localizations.of<ChallengeListLocalizations>(context, ChallengeListLocalizations);
    _commonI18n = Localizations.of<ChallengeLocalizations>(context, ChallengeLocalizations);
    _overDueStyle = TextStyle(color: Theme.of(context).errorColor);
  }

  _onEditChallenge(Challenge c, BuildContext context) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ChallengePage(challenge: c),
          fullscreenDialog: true
        )
    );
    if (result != null) setState(() {});
  }

  _onChallengeChecked(bool value, BuildContext context) async {
    if (widget.challenge.isFailed) {
      Scaffold.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Challenge ${widget.challenge.name} already failed.')));
    } else {
      final _challengeService = AppStateWidget.of(context).get<ChallengeService>();
      if (value) {
        await _challengeService.complete([widget.challenge]);
      } else {
        await _challengeService.incomplete([widget.challenge]);
      }
      // update view
      setState(() { });
    }
  }

  Widget _dueText() {
    final challenge = widget.challenge;
    final done = challenge.isDone;
    final failed = challenge.isFailed;

    if (done) return Text('Done ' + _commonI18n.formatDate(challenge.doneAt));
    else if (failed) {
      return Text('Failed since ' + _commonI18n.formatDate(challenge.latestAt), style: _overDueStyle);
    } else if (challenge.isOverdue) {
      if (challenge.latestAt == null) {
        return Text('Was due until ' + _commonI18n.formatDate(challenge.dueAt), style: _overDueStyle);
      } else {
        Duration failIn = challenge.latestAt.difference(DateTime.now());
        return Text(_i18n.challengeWillFail(failIn), style: _overDueStyle);
      }
    } else {
      return Text('Due until ' + _commonI18n.formatDate(challenge.dueAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final done = challenge.isDone;
    final failed = challenge.isFailed;
    final theme = Theme.of(context);

    var actions = <Widget>[];
    if (widget.onDelete != null) {
      actions.add(
        Padding(
          padding: _edge,
          child: IconSlideAction(
              caption: 'Delete',
              color: theme.errorColor,
              icon: Icons.delete,
              onTap: () => widget.onDelete(challenge, context)
          ),
        )
      );
    }
    // allow edit only for non completed challenges
    if (challenge.status == ChallengeStatus.open) {
      actions.add(
          Padding(
            padding: _edge,
            child: IconSlideAction(
                caption: 'Edit',
                color: theme.primaryColor,
                icon: Icons.edit,
                onTap: () => _onEditChallenge(challenge, context)
            ),
          )
      );
    }

    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Card(
          child: CheckboxListTile(
            onChanged: (v) => _onChallengeChecked(v, context),
            value: done,
            secondary: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                // transitionBuilder: (child, animation) => ScaleTransition(child: child, scale: animation),
                child: RewardWidget(
                    reward: widget.challenge.reward,
                    status: widget.challenge.status,
                    key: ValueKey('${widget.challenge.id}_${widget.challenge.status}'),
                )
            ),
            subtitle: _dueText(),
            title: Text(challenge.name, style: done || failed ? _notOpenTextStyle : null))
      ),
      secondaryActions: actions
    );
  }
}
