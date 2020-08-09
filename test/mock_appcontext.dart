
import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:challengeapp/common/model/attached_entity.dart';
import 'package:challengeapp/config/service/config_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';

class CreditServiceMock with Mock implements CreditService {}
class RewardServiceMock with Mock implements RewardService {}
class ChallengeServiceMock with Mock implements ChallengeService {}
class ConfigStub extends ConfigService {
  @override
  Future<ConfigService> init() {
    // nothing ...
    return SynchronousFuture(this);
  }
}

class AttachedEntityMock<Entity extends AbstractEntity>
    with Mock implements AttachedEntity<Entity> {}

class AppContextMock {
  final AppContext appContext = AppContext();

  final CreditServiceMock creditServiceMock = CreditServiceMock();
  final credits = ValueNotifier(0);

  final RewardServiceMock rewardServiceMock = RewardServiceMock();
  final rewards =  <Reward>[];

  final ChallengeServiceMock challengeServiceMock = ChallengeServiceMock();
  final challenges = <Challenge>[];
  final overdueChallenges = <Challenge>[];

  final ConfigStub configStub = ConfigStub();

  AppContextMock() {
    when(creditServiceMock.creditNotifier).thenReturn(credits);
    when(creditServiceMock.credit).thenAnswer((realInvocation) => Future.value(credits.value));

    when(rewardServiceMock.listRewards(any, any)).thenAnswer((realInvocation) => Future.value(rewards));
    when(rewardServiceMock.attach(any)).thenReturn(AttachedEntityMock<Reward>());

    when(challengeServiceMock.loadByDate(any)).thenAnswer((realInvocation) => Future.value(challenges));
    when(challengeServiceMock.loadOverDue()).thenAnswer((realInvocation) => Future.value(overdueChallenges));
    when(challengeServiceMock.attach(any)).thenReturn(AttachedEntityMock<Challenge>());

    appContext.add<RewardService>(rewardServiceMock);
    appContext.add<CreditService>(creditServiceMock);
    appContext.add<ChallengeService>(challengeServiceMock);
    appContext.add<ConfigService>(configStub);
  }
}

