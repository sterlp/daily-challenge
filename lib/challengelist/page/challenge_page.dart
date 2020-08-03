import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:challengeapp/challengelist/i18n/challengelist_localization.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/common/widget/fixed_flutter_state.dart';
import 'package:challengeapp/common/widget/input_form.dart';
import 'package:challengeapp/db/test_data.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:challengeapp/log/logger.dart';
import 'package:challengeapp/util/date.dart';
import 'package:challengeapp/util/strings.dart';

class ChallengePage extends StatefulWidget {
  final Challenge challenge;

  ChallengePage({Key key, @required this.challenge}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChallengePageState();
}
class ChallengePageState extends FixedState<ChallengePage> {
  static final Logger _log = LoggerFactory.get<ChallengePage>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();

  final TextEditingController _dueAtController = TextEditingController();
  DateTime _dueAt;
  final TextEditingController _latestAtController = TextEditingController();

  DateTime _latestAt;
  ChallengeService _challengeService;

  ChallengeListLocalizations _i18n;
  ChallengeLocalizations _commonI18n;

  @override
  void didChangeDependencies() {
    _i18n = Localizations.of<ChallengeListLocalizations>(context, ChallengeListLocalizations);
    _commonI18n = Localizations.of<ChallengeLocalizations>(context, ChallengeLocalizations);
    super.didChangeDependencies();
  }

  @override
  void saveInitState() {
    _challengeService = AppStateWidget.of(context).get<ChallengeService>();
    final c = widget.challenge;

    c.dueAt ??= c.dueAt = DateTimeUtil.clearTime(DateTime.now());
    c.latestAt ??= c.dueAt.add(Challenge.defaultChallengeWaitTime);

    _nameController.text = c.name;
    _rewardController.text = c.reward == null ? null : c.reward.toString();

    _dueAt = c.dueAt;
    _dueAtController.text = _commonI18n.formatDate(_dueAt);
    _latestAt = c.latestAt;
    _latestAtController.text = _commonI18n.formatDate(_latestAt);
  }

  _save() async {
    if (_formKey.currentState.validate()) {
      var c = widget.challenge;
      c.name = _nameController.text;
      if (_rewardController.text != "") c.reward = int.parse(_rewardController.text);
      c.dueAt = _dueAt;
      c.latestAt = _latestAt;
      c = await _challengeService.save(c);
      _log.debug('saved challenge: $c dueAt: $_dueAt latest $_latestAt');
      Navigator.pop(context, true);
    }
  }

  int _headTabCount = 0;
  _headTap() {
    ++_headTabCount;
    if (_headTabCount >= 10) {
      _headTabCount = 0;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Replace data with presentation data?'),
            actions: <Widget>[
              FlatButton(child: const Text('CANCEL'), onPressed: () => Navigator.of(context).pop()),
              FlatButton(child: const Text('REPLACE ALL DATA'), onPressed: () => Navigator.of(context).pop(true))
            ],
          );
        }
      ).then((value) async {
        if (value != null && value == true)  {
          await AppStateWidget.of(context).get<TestData>().deleteAll();
          await AppStateWidget.of(context).get<TestData>().generatePresentationData();
          Navigator.pop(context, true);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rewardController.dispose();
    _dueAtController.dispose();
    _latestAtController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final newChallenge = c.id == null;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text(_i18n.editChallengeHeader(newChallenge)),
          onTap: _headTap,
        ),
        actions: <Widget>[
          FlatButton(child: Text(_commonI18n.buttonSave(newChallenge)), onPressed: _save)
        ]
      ),
      // https://medium.com/flutterpub/create-beautiful-forms-with-flutter-47075cfe712
      body: InputForm(
        formKey: _formKey,
        children: <Widget>[
          TypeAheadFormField(
            key: ValueKey('challenge_name'),
            textFieldConfiguration: TextFieldConfiguration (
              autofocus: true,
              inputFormatters: [LengthLimitingTextInputFormatter(Challenge.NAME_LENGTH)],
              controller: _nameController,
              decoration: _i18n.challengeName.decorator,
              textInputAction: TextInputAction.next,
              onSubmitted: (v) {
                FocusScope.of(context).nextFocus();
              },
            ),
            suggestionsCallback: (pattern) {
              if (pattern != null && pattern.length > 1) {
                return _challengeService.completeChallengesName(pattern);
              }
              return null;
            },
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              color: Theme.of(context).backgroundColor,
            ),
            noItemsFoundBuilder: (context) => null,
            itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
            onSuggestionSelected: (suggestion) {
              this._nameController.text = suggestion;
              FocusScope.of(context).nextFocus();
            },
            validator: (String v) => v.isNullOrEmpty ? _i18n.challengeName.nullError : null,
          ),
          TextFormField(
            controller: _dueAtController,
            onTap: () => _pickDueAt(c, context),
            readOnly: true,
            decoration: InputDecoration(
              icon: Icon(Icons.today),
              labelText: _i18n.challengeDueAt.label,
              hintText: _i18n.challengeDueAt.hint,
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),

          TextFormField(
            controller: _latestAtController,
            onTap: () => _pickLatestAt(c, context),
            readOnly: true,
            decoration: new InputDecoration(
              icon: Icon(Icons.date_range),
              labelText: _i18n.challengeLatestAt.label,
              hintText: _i18n.challengeLatestAt.hint,
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),

          TextFormField(
            controller: _rewardController,
            validator: (String v) => v.isNullOrEmpty ? _i18n.challengeReward.nullError : null,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            decoration: _i18n.challengeReward.decorator,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (v) => _save()
          ),
        ],
      )
    );
  }

  void _pickLatestAt(Challenge c, BuildContext context) {
    showDatePicker(context: context, initialDate: _latestAt, firstDate: _dueAt,
        lastDate: DateTime.now().add(Duration(days: 365)),
        helpText:_i18n.challengeLatestAt.hint,
    ).then((date) {
      if (date != null) {
        _latestAt = date;
        _latestAtController.text = _commonI18n.formatDate(_latestAt);
        FocusScope.of(context).nextFocus();
      }
    });
  }

  void _pickDueAt(Challenge c, BuildContext context) {
    var now = DateTime.now();
    showDatePicker(context: context, initialDate: _dueAt,
        firstDate: now.isAfter(_dueAt) ? _dueAt : now,
        lastDate: now.add(Duration(days: 365)),
        helpText: _i18n.challengeDueAt.hint
      ).then((date) {
      if (date != null) {
        _dueAt = date;
        _dueAtController.text = _commonI18n.formatDate(_dueAt);
        if (date.isAfter(_latestAt)) {
          _latestAt = _dueAt;
          _latestAtController.text = _commonI18n.formatDate(date);
        }
        FocusScope.of(context).nextFocus();
      }
    });
  }
}