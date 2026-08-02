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
}
