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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ChallengePage extends StatefulWidget {
  final Challenge challenge;

  const ChallengePage({super.key, required this.challenge});

  @override
  State<StatefulWidget> createState() => ChallengePageState();
}

class ChallengePageState extends FixedState<ChallengePage> {
  static final Logger _log = LoggerFactory.get<ChallengePage>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();

  final TextEditingController _dueAtController = TextEditingController();
  DateTime? _dueAt;
  final TextEditingController _latestAtController = TextEditingController();

  DateTime? _latestAt;
  late ChallengeService _challengeService;

  late ChallengeListLocalizations _i18n;
  late ChallengeLocalizations _commonI18n;

  @override
  void didChangeDependencies() {
    _i18n = Localizations.of<ChallengeListLocalizations>(
      context,
      ChallengeListLocalizations,
    )!;
    _commonI18n = Localizations.of<ChallengeLocalizations>(
      context,
      ChallengeLocalizations,
    )!;
    super.didChangeDependencies();
  }

  @override
  void saveInitState() {
    _challengeService = AppStateWidget.of(context).get<ChallengeService>();
    final c = widget.challenge;

    c.dueAt ??= DateTimeUtil.clearTime(DateTime.now());
    c.latestAt ??= c.dueAt!.add(Challenge.defaultChallengeWaitTime);

    _nameController.text = c.name;
    _rewardController.text = c.reward.toString();

    _dueAt = c.dueAt;
    _dueAtController.text = _commonI18n.formatDate(_dueAt);
    _latestAt = c.latestAt;
    _latestAtController.text = _commonI18n.formatDate(_latestAt);
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      var c = widget.challenge;
      c.name = _nameController.text;
      if (_rewardController.text != "") {
        c.reward = int.parse(_rewardController.text);
      }
      c.dueAt = _dueAt;
      c.latestAt = _latestAt;
      c = await _challengeService.save(c);
      if (!mounted) return;
      _log.debug('saved challenge: $c dueAt: $_dueAt latest $_latestAt');
      Navigator.pop(context, true);
    }
  }

  int _headTabCount = 0;
  void _headTap() {
    ++_headTabCount;
    if (_headTabCount >= 10) {
      _headTabCount = 0;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Replace data with presentation data?'),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('REPLACE ALL DATA'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      ).then((value) async {
        // ignore: use_build_context_synchronously
        if (value != null && value == true) {
          // ignore: use_build_context_synchronously
          await AppStateWidget.of(context).get<TestData>().deleteAll();
          // ignore: use_build_context_synchronously
          await AppStateWidget.of(context)
              .get<TestData>()
              .generatePresentationData();
          // ignore: use_build_context_synchronously
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
          TextButton(
            child: Text(_commonI18n.buttonSave(newChallenge)),
            onPressed: _save,
          ),
        ],
      ),
      // https://medium.com/flutterpub/create-beautiful-forms-with-flutter-47075cfe712
      body: InputForm(
        formKey: _formKey,
        children: <Widget>[
          TypeAheadField<String>(
            key: const ValueKey('challenge_name'),
            controller: _nameController,
            suggestionsCallback: (pattern) {
              if (pattern.length > 1) {
                return _challengeService
                    .completeChallengesName(pattern)
                    .then((names) => names.toList());
              }
              return null;
            },
            hideOnEmpty: true,
            itemBuilder: (context, suggestion) =>
                ListTile(title: Text(suggestion)),
            onSelected: (suggestion) {
              _nameController.text = suggestion;
              FocusScope.of(context).nextFocus();
            },
            builder: (context, controller, focusNode) => TextFormField(
              autofocus: true,
              controller: controller,
              focusNode: focusNode,
              inputFormatters: [
                LengthLimitingTextInputFormatter(Challenge.NAME_LENGTH),
              ],
              decoration: _i18n.challengeName.decorator,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v) {
                FocusScope.of(context).nextFocus();
              },
              validator: (String? v) =>
                  v.isNullOrEmpty ? _i18n.challengeName.nullError : null,
            ),
          ),
          TextFormField(
            controller: _dueAtController,
            onTap: () => _pickDueAt(c, context),
            readOnly: true,
            decoration: InputDecoration(
              icon: const Icon(Icons.today),
              labelText: _i18n.challengeDueAt.label,
              hintText: _i18n.challengeDueAt.hint,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
          ),

          TextFormField(
            controller: _latestAtController,
            onTap: () => _pickLatestAt(c, context),
            readOnly: true,
            decoration: InputDecoration(
              icon: const Icon(Icons.date_range),
              labelText: _i18n.challengeLatestAt.label,
              hintText: _i18n.challengeLatestAt.hint,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
          ),

          TextFormField(
            key: const ValueKey('challenge_reward'),
            controller: _rewardController,
            validator: (String? v) =>
                v.isNullOrEmpty ? _i18n.challengeReward.nullError : null,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            decoration: _i18n.challengeReward.decorator,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (v) => _save(),
          ),
        ],
      ),
    );
  }

  void _pickLatestAt(Challenge c, BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _latestAt,
      firstDate: _dueAt!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: _i18n.challengeLatestAt.hint,
    ).then((date) {
      if (date != null) {
        _latestAt = date;
        _latestAtController.text = _commonI18n.formatDate(_latestAt);
        // ignore: use_build_context_synchronously
        FocusScope.of(context).nextFocus();
      }
    });
  }

  void _pickDueAt(Challenge c, BuildContext context) {
    final now = DateTime.now();
    showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: now.isAfter(_dueAt!) ? _dueAt! : now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: _i18n.challengeDueAt.hint,
    ).then((date) {
      if (date != null) {
        _dueAt = date;
        _dueAtController.text = _commonI18n.formatDate(_dueAt);
        if (_latestAt != null && date.isAfter(_latestAt!)) {
          _latestAt = _dueAt;
          _latestAtController.text = _commonI18n.formatDate(date);
        }
        // ignore: use_build_context_synchronously
        FocusScope.of(context).nextFocus();
      }
    });
  }
}
