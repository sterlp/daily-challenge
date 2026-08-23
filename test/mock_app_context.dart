import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:challengeapp/common/model/attached_entity.dart';
import 'package:challengeapp/config/service/config_service.dart';
import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';

class CreditServiceMock with Mock implements CreditService {
  @override
  ValueNotifier<int> get creditNotifier => super.noSuchMethod(
    Invocation.getter(#creditNotifier),
    returnValue: ValueNotifier<int>(0),
  ) as ValueNotifier<int>;

  @override
  Future<int> get credit => super.noSuchMethod(
    Invocation.getter(#credit),
    returnValue: Future<int>.value(0),
  ) as Future<int>;
}

class RewardServiceMock with Mock implements RewardService {
  @override
  Future<List<Reward>> listRewards(int? limit, int? offset) =>
      super.noSuchMethod(
        Invocation.method(#listRewards, [limit, offset]),
        returnValue: Future<List<Reward>>.value(<Reward>[]),
      ) as Future<List<Reward>>;

  @override
  AttachedEntity<Reward> attach(Reward? reward) => super.noSuchMethod(
    Invocation.method(#attach, [reward]),
    returnValue: AttachedEntityMock<Reward>(),
  ) as AttachedEntity<Reward>;
}

class ChallengeServiceMock with Mock implements ChallengeService {
  @override
  Future<List<Challenge>> loadByDate(
    DateTime? dateTime,
    bool? includeOverdue,
  ) => super.noSuchMethod(
    Invocation.method(#loadByDate, [dateTime, includeOverdue]),
    returnValue: Future<List<Challenge>>.value(<Challenge>[]),
  ) as Future<List<Challenge>>;

  @override
  Future<int> failOverDue(List<Challenge>? values) => super.noSuchMethod(
    Invocation.method(#failOverDue, [values]),
    returnValue: Future<int>.value(0),
  ) as Future<int>;

  @override
  Future<Challenge> save(Challenge? c) => super.noSuchMethod(
    Invocation.method(#save, [c]),
    returnValue: Future<Challenge>.value(Challenge()),
  ) as Future<Challenge>;

  @override
  AttachedEntity<Challenge> attach(Challenge? challenge) => super.noSuchMethod(
    Invocation.method(#attach, [challenge]),
    returnValue: AttachedEntityMock<Challenge>(),
  ) as AttachedEntity<Challenge>;

  @override
  Future<Iterable<String>> completeChallengesName(String? pattern) =>
      super.noSuchMethod(
        Invocation.method(#completeChallengesName, [pattern]),
        returnValue: Future<Iterable<String>>.value(<String>[]),
      ) as Future<Iterable<String>>;
}

class ConfigStub extends ConfigService {
  @override
  Future<ConfigService> init() {
    // nothing ...
    return SynchronousFuture(this);
  }
}

class AttachedEntityMock<Entity extends AbstractEntity>
    implements AttachedEntity<Entity> {
  @override
  void dispose() {}

  @override
  Future<void> close() => SynchronousFuture<void>(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class AppContextMock {
  final AppContainer appContext = AppContainer();

  final CreditServiceMock creditServiceMock = CreditServiceMock();
  final credits = ValueNotifier(0);

  final RewardServiceMock rewardServiceMock = RewardServiceMock();
  final rewards = <Reward>[];

  final ChallengeServiceMock challengeServiceMock = ChallengeServiceMock();
  final challenges = <Challenge>[];

  final ConfigStub configStub = ConfigStub();

  AppContextMock() {
    when(creditServiceMock.creditNotifier).thenReturn(credits);
    when(creditServiceMock.credit)
        .thenAnswer((realInvocation) => Future.value(credits.value));

    when(rewardServiceMock.listRewards(any, any))
        .thenAnswer((realInvocation) => Future.value(rewards));
    when(rewardServiceMock.attach(any))
        .thenReturn(AttachedEntityMock<Reward>());

    when(challengeServiceMock.loadByDate(any, any))
        .thenAnswer((realInvocation) => Future.value(challenges));
    when(challengeServiceMock.attach(any))
        .thenReturn(AttachedEntityMock<Challenge>());

    appContext.add<RewardService>(rewardServiceMock);
    appContext.add<CreditService>(creditServiceMock);
    appContext.add<ChallengeService>(challengeServiceMock);
    appContext.add<ConfigService>(configStub);
  }
}
