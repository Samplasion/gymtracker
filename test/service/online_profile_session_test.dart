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
        MockPostgrestFilterBuilder,
        MockPostgrestTransformBuilder;

class _Storage extends Mock implements SupabaseStorageClient {}

class _Files extends Mock implements StorageFileApi {}

class _MaybeRow extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

class _Row extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>> {}

User _user(String id) => User(
  id: id,
  appMetadata: {},
  userMetadata: {'username': id},
  aud: 'authenticated',
  createdAt: '2026-01-01',
  emailConfirmedAt: '2026-01-01',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(UserAttributes());
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(const FileOptions());
  });
  for (final operation in [
    'profile',
    'account',
    'login',
    'register',
    'upload',
    'remove',
    'upload-storage',
    'remove-storage',
    'login-auth',
    'register-auth',
    'verification',
    'login-initial',
    'register-initial',
  ]) {
    for (final replacement in <String?>[null, 'B', 'A', 'unchanged']) {
      test(
        '$operation ignores late profile response after switching to $replacement',
        () async {
          final client = MockSupabaseClient();
          final auth = MockGoTrueClient();
          final storage = _Storage();
          final files = _Files();
          final query = MockSupabaseQueryBuilder();
          final filter = MockPostgrestFilterBuilder();
          final transform = MockPostgrestTransformBuilder();
          final row = _Row();
          final maybeRow = _MaybeRow();
          final initialLogin = operation.endsWith('-initial');
          final delayedAuth =
              initialLogin ||
              operation.endsWith('-auth') ||
              operation == 'verification';
          User? current = initialLogin ? null : _user('A');
          final events = StreamController<AuthState>.broadcast(sync: true);
          final pending = Completer<Map<String, dynamic>>();
          when(() => client.auth).thenReturn(auth);
          when(() => client.storage).thenReturn(storage);
          when(() => storage.from('profile_pictures')).thenReturn(files);
          when(
            () => files.uploadBinary(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            ),
          ).thenAnswer((_) async {
            if (operation == 'upload-storage') await pending.future;
            return 'A';
          });
          when(() => files.remove(any())).thenAnswer((_) async {
            if (operation == 'remove-storage') await pending.future;
            return [];
          });
          when(() => auth.currentUser).thenAnswer((_) => current);
          when(() => auth.onAuthStateChange).thenAnswer((_) => events.stream);
          when(() => client.from('profiles')).thenAnswer((_) => query);
          when(() => query.update(any())).thenAnswer((_) => filter);
          when(() => query.select(any())).thenAnswer((_) => filter);
          when(() => filter.eq(any(), any())).thenAnswer((_) => filter);
          when(() => filter.select()).thenAnswer((_) => filter);
          when(() => filter.single()).thenAnswer((_) => row);
          when(() => filter.limit(1)).thenAnswer((_) => transform);
          when(() => filter.maybeSingle()).thenAnswer((_) => maybeRow);
          when(
            () => maybeRow.then<dynamic>(any(), onError: any(named: 'onError')),
          ).thenAnswer(
            (call) => Future<Map<String, dynamic>?>.value(null).then(
              (value) => call.positionalArguments[0](value),
              onError: call.namedArguments[#onError] as Function?,
            ),
          );
          when(
            () => auth.updateUser(any()),
          ).thenAnswer((_) async => UserResponse.fromJson(current!.toJson()));
          Future<AuthResponse> authenticationResponse() async {
            if (delayedAuth) await pending.future;
            return AuthResponse(
              user: _user('A'),
              session: Session(
                accessToken: 'token',
                tokenType: 'bearer',
                user: _user('A'),
              ),
            );
          }

          when(
            () => auth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) => authenticationResponse());
          when(
            () => auth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            ),
          ).thenAnswer((_) => authenticationResponse());
          when(
            () => row.then<void>(any(), onError: any(named: 'onError')),
          ).thenAnswer(
            (call) => pending.future.then<void>((value) {
              call.positionalArguments[0](value);
            }, onError: call.namedArguments[#onError] as Function?),
          );
          when(
            () => row.then<dynamic>(any(), onError: any(named: 'onError')),
          ).thenAnswer(
            (call) => pending.future.then(
              (value) => call.positionalArguments[0](value),
              onError: call.namedArguments[#onError] as Function?,
            ),
          );
          when(
            () =>
                transform.then<dynamic>(any(), onError: any(named: 'onError')),
          ).thenAnswer(
            (call) => pending.future.then(
              (value) => call.positionalArguments[0]([value]),
              onError: call.namedArguments[#onError] as Function?,
            ),
          );
          final service = OnlineServiceImpl(client);
          addTearDown(() async {
            service.dispose();
            await events.close();
          });
          service.account = OnlineAccount(id: 'A', name: 'A');
          final request = switch (operation) {
            'profile' => service.updateProfile(fullName: 'New name'),
            'account' => service.updateAccount(
              email: 'a@example.test',
              username: 'New username',
            ),
            'upload' || 'upload-storage' => service.uploadAvatar(Uint8List(1)),
            'remove' || 'remove-storage' => service.removeAvatar(),
            'verification' => service.checkEmailVerificationAndLogIn(
              email: 'a@example.test',
              password: 'password',
            ),
            'login' || 'login-auth' || 'login-initial' => service.login(
              email: 'a@example.test',
              password: 'password',
            ),
            _ => service.register(
              email: 'a@example.test',
              password: 'password',
              username: 'A',
            ),
          };
          final expectation = replacement == 'unchanged'
              ? expectLater(request, completes)
              : expectLater(request, throwsStateError);
          await Future<void>.delayed(Duration.zero);
          if (initialLogin && replacement == 'unchanged') {
            events.add(AuthState(AuthChangeEvent.initialSession, null));
            current = _user('A');
            events.add(
              AuthState(
                AuthChangeEvent.signedIn,
                Session(
                  accessToken: 'new-token',
                  tokenType: 'bearer',
                  user: current!,
                ),
              ),
            );
            events.add(
              AuthState(
                AuthChangeEvent.initialSession,
                Session(
                  accessToken: 'new-token',
                  tokenType: 'bearer',
                  user: current!,
                ),
              ),
            );
          }
          if (replacement != 'unchanged') {
            current = replacement == null ? null : _user(replacement);
            events.add(AuthState(AuthChangeEvent.signedOut, null));
          }
          final expected = replacement == null
              ? null
              : OnlineAccount(
                  id: replacement == 'unchanged' ? 'A' : replacement,
                  name: 'Current account',
                );
          service.account = expected;
          var changes = 0;
          service.addListener(() => changes++);
          pending.complete({
            'username': 'New username',
            'full_name': 'New name',
          });
          await expectation;
          if (replacement == 'unchanged') {
            expect(service.account?.id, 'A');
            expect(changes, 1);
            if (operation == 'account')
              verify(() => auth.updateUser(any())).called(1);
          } else {
            expect(service.account, same(expected));
            expect(changes, 0);
            if (operation == 'account')
              verifyNever(() => auth.updateUser(any()));
            if (operation.endsWith('-storage'))
              verifyNever(() => query.update(any()));
          }
        },
      );
    }
  }
}
