import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/online.dart';
import 'package:mocktail/mocktail.dart';

import '../offline/online_service_offline_test.dart'
    show MockSupabaseClient, MockGoTrueClient;

void main() {
  for (final locale in ['it', 'en', 'fr']) {
    test(
      'password recovery uses the existing site and locale: $locale',
      () async {
        final client = MockSupabaseClient();
        final auth = MockGoTrueClient();
        when(() => client.auth).thenReturn(auth);
        when(
          () => auth.onAuthStateChange,
        ).thenAnswer((_) => const Stream.empty());
        when(() => auth.currentUser).thenReturn(null);
        when(
          () => auth.resetPasswordForEmail(
            any(),
            redirectTo: any(named: 'redirectTo'),
          ),
        ).thenAnswer((_) async {});
        final service = OnlineServiceImpl.withAchievementCatalog(
          client: client,
          achievementCatalog: () => {},
        );
        addTearDown(service.dispose);
        await service.requestPasswordRecovery(
          email: 'me@example.com',
          locale: locale,
        );
        verify(
          () => auth.resetPasswordForEmail(
            'me@example.com',
            redirectTo:
                'https://gym-bro.techtonicfault.com/${locale == 'it' ? 'it' : 'en'}/auth/reset-password',
          ),
        ).called(1);
        expect(service.account, isNull);
      },
    );
  }
}
