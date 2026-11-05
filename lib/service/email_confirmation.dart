import 'package:gymtracker/service/protocol.dart';

/// This link is only a hint: the verification screen must check with the server.
bool isEmailConfirmationLink(String url) {
  final uri = Uri.tryParse(url);
  return uri != null &&
      uri.scheme == 'gymtracker' &&
      uri.host == 'auth' &&
      uri.path == '/email-confirmed' &&
      uri.userInfo.isEmpty &&
      !uri.hasPort &&
      !uri.hasQuery &&
      !uri.hasFragment;
}

class EmailConfirmationListener with ProtocolListener {
  EmailConfirmationListener(this.onReturn);
  final void Function() onReturn;

  @override
  void onProtocolUrlReceived(String url) {
    if (isEmailConfirmationLink(url)) onReturn();
  }
}
