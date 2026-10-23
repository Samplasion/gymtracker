import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_INSTANCE')
  static const String supabaseInstance = _Env.supabaseInstance;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const String supabaseAnonKey = _Env.supabaseAnonKey;

  @EnviedField(varName: "REVENUECAT_PROJECT_GOOGLE_API_KEY")
  static const String revenuecatProjectGoogleApiKey =
      _Env.revenuecatProjectGoogleApiKey;

  @EnviedField(varName: "REVENUECAT_PROJECT_APPLE_API_KEY")
  static const String revenuecatProjectAppleApiKey =
      _Env.revenuecatProjectAppleApiKey;

  @EnviedField(varName: "REVENUECAT_PROJECT_TEST_STORE_API_KEY")
  static const String revenuecatProjectTestStoreApiKey =
      _Env.revenuecatProjectTestStoreApiKey;

  @EnviedField(varName: "REVENUECAT_ACCESS_ENTITLEMENT_ID")
  static const String revenuecatAccessEntitlementId =
      _Env.revenuecatAccessEntitlementId;

  // Optional: the inbox remains available when push is not configured.
  @EnviedField(varName: 'FIREBASE_PROJECT_ID', defaultValue: '')
  static const String firebaseProjectId = _Env.firebaseProjectId;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID', defaultValue: '')
  static const String firebaseMessagingSenderId =
      _Env.firebaseMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_ANDROID_API_KEY', defaultValue: '')
  static const String firebaseAndroidApiKey = _Env.firebaseAndroidApiKey;

  @EnviedField(varName: 'FIREBASE_ANDROID_APP_ID', defaultValue: '')
  static const String firebaseAndroidAppId = _Env.firebaseAndroidAppId;

  @EnviedField(varName: 'FIREBASE_IOS_API_KEY', defaultValue: '')
  static const String firebaseIosApiKey = _Env.firebaseIosApiKey;

  @EnviedField(varName: 'FIREBASE_IOS_APP_ID', defaultValue: '')
  static const String firebaseIosAppId = _Env.firebaseIosAppId;

  @EnviedField(varName: 'FIREBASE_IOS_BUNDLE_ID', defaultValue: '')
  static const String firebaseIosBundleId = _Env.firebaseIosBundleId;
}
