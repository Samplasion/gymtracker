import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/paywall.dart';

extension PurchasesPresentation on PurchasesController {
  Future<void> presentPaywall() {
    if (!canPresentNativePaywall()) {
      return Go.to(() => PaywallScreen());
    }
    return presentNativePaywall();
  }
}
