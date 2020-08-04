import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:challengeapp/common/common_types.dart';
import 'package:challengeapp/common/widget/divider_with_label.dart';
import 'package:challengeapp/common/widget/fixed_flutter_state.dart';
import 'package:challengeapp/history/model/history_model.dart';
import 'package:challengeapp/history/service/history_service.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/home/widget/loading_widget.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends FixedState<HistoryPage> {
  final ValueNotifier<List<HistoryChallengeOrBoughtReward>> _data = ValueNotifier(null);
  HistoryService _historyService;
  ChallengeLocalizations _commonI18n;

  TextStyle _negative;
  static const _positive = TextStyle(color: Colors.green);

  @override
  void didChangeDependencies() {
    _historyService = AppStateWidget.of(context).get<HistoryService>();
    _commonI18n = Localizations.of<ChallengeLocalizations>(context, ChallengeLocalizations);

    _negative = TextStyle(color: Theme.of(context).errorColor);

    super.didChangeDependencies();
  }

  @override
  void saveInitState() {
    _doReload();
    super.saveInitState();
  }

  void _doReload() async {
    final data = await _historyService.loadHistory();
    _lastMonth = null;
    this._data.value = data;
  }

  int _lastMonth;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<HistoryChallengeOrBoughtReward>>(
      valueListenable: _data,
      builder: (context, value, child) {
        if (value == null) return LoadingWidget();

        return ListView.builder(
          padding: MyStyle.LIST_PADDING,
          itemCount: value.length,
          itemBuilder: (context, index) {
            final d = value[index];
            if (_lastMonth == null || _lastMonth != d.at.month) {
              _lastMonth = d.at.month;
              return Column(
                children: <Widget>[
                  DividerWithLabel(_commonI18n.formatMonth(d.at)),
                  _listTitle(d)
                ],
              );
            } else {
              return Column(
                children: [
                  _listTitle(d),
                ]
              );
            }
          },
        );
      },
    );
  }

  Widget _listTitle(HistoryChallengeOrBoughtReward d) {
    return Card(
      child: ListTile(
        leading: Container(
            width: 40, // can be whatever value you want
            alignment: Alignment.center,
            child: _icon(d)),
        title: Text(d.name),
        subtitle: Text(_commonI18n.formatDateTime(d.at)),
        trailing: _points(d.points),
      ),
    );
  }

  Widget _points(int p) {
    return Text(p.toString(), style: p >= 0 ? _positive : _negative, textScaleFactor: 1.2,);
  }

  Widget _icon(HistoryChallengeOrBoughtReward d) {
    if (d.isReward) return MyStyle.REWARD_ICON;
    else if (d.challenge.isDone) {
      return const Icon(MyStyle.ICON_DONE_CHALLENGE, color: Colors.green);
    } else {
      return Icon(MyStyle.ICON_FAILED_CHALLENGE, color: Theme.of(context).errorColor);
    }
  }
}
