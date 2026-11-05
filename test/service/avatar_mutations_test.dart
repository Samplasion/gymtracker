import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/online.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../offline/online_service_offline_test.dart'
    show
        MockSupabaseClient,
        MockGoTrueClient,
        MockSupabaseQueryBuilder,
        MockPostgrestFilterBuilder;

class _Storage extends Mock implements SupabaseStorageClient {}

class _Files extends Mock implements StorageFileApi {}

class _Row extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(const FileOptions());
  });
  for (final remove in [false, true]) {
    for (final failStorage in [false, true]) {
      test(
        '${remove ? 'remove' : 'upload'}: ${failStorage ? 'storage failure preserves account' : 'metadata failure still publishes saved avatar'}',
        () async {
          final client = MockSupabaseClient();
          final auth = MockGoTrueClient();
          final storage = _Storage();
          final files = _Files();
          final query = MockSupabaseQueryBuilder();
          final filter = MockPostgrestFilterBuilder();
          final row = _Row();
          when(() => client.auth).thenReturn(auth);
          when(() => auth.currentUser).thenReturn(
            User(
              id: 'user',
              appMetadata: {},
              userMetadata: {},
              aud: 'authenticated',
              createdAt: '2026-01-01',
              email: 'user@example.com',
            ),
          );
          when(
            () => auth.onAuthStateChange,
          ).thenAnswer((_) => const Stream.empty());
          when(() => client.storage).thenReturn(storage);
          when(() => storage.from('profile_pictures')).thenReturn(files);
          when(
            () => files.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            ),
          ).thenAnswer((_) async {
            if (failStorage) throw StateError('Storage unavailable');
            return 'user';
          });
          when(() => files.remove(any())).thenAnswer((_) async {
            if (failStorage) throw StateError('Storage unavailable');
            return [];
          });
          when(() => client.from('profiles')).thenAnswer((_) => query);
          when(() => query.update(any())).thenAnswer((_) => filter);
          when(() => filter.eq('id', 'user')).thenAnswer((_) => filter);
          when(() => filter.select()).thenAnswer((_) => filter);
          when(() => filter.single()).thenAnswer((_) => row);
          when(
            () => row.then<dynamic>(any(), onError: any(named: 'onError')),
          ).thenAnswer(
            (call) =>
                Future<Map<String, dynamic>>.error(
                  StateError('Metadata unavailable'),
                ).then(
                  (value) => call.positionalArguments[0](value),
                  onError: call.namedArguments[#onError] as Function?,
                ),
          );
          final service = OnlineServiceImpl(client);
          addTearDown(service.dispose);
          final original = OnlineAccount(
            id: 'user',
            name: 'username',
            fullName: 'Full Name',
            updatedAt: 'old',
          );
          service.account = original;
          var changes = 0;
          service.addListener(() => changes++);
          final request = remove
              ? service.removeAvatar()
              : service.uploadAvatar(Uint8List(3));
          if (failStorage) {
            await expectLater(request, throwsStateError);
            expect(service.account, same(original));
            expect(changes, 0);
            verifyNever(() => query.update(any()));
          } else {
            await request;
            expect(service.account?.updatedAt, isNot('old'));
            expect(service.account?.name, 'username');
            expect(service.account?.fullName, 'Full Name');
            expect(changes, 1);
            // getAccount uses the refreshed cache, rather than reverting its revision.
            expect(await service.getAccount(), same(service.account));
          }
        },
      );
    }
  }
}
