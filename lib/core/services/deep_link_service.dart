import 'package:url_launcher/url_launcher.dart';

abstract class DeepLinkService {
  Future<void> openWhatsApp(String phoneNumber, {String? message});
  Future<void> openTeamsChat(String emailOrId, {String? message});
}

class UrlDeepLinkService implements DeepLinkService {
  @override
  Future<void> openTeamsChat(String emailOrId, {String? message}) async {
    final uri = Uri.parse(
      'https://teams.microsoft.com/l/chat/0/0?users=$emailOrId${message != null ? '&message=${Uri.encodeComponent(message)}' : ''}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Future<void> openWhatsApp(String phoneNumber, {String? message}) async {
    final uri = Uri.parse(
      'https://wa.me/$phoneNumber${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
