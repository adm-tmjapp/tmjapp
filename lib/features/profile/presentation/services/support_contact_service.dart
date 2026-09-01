import 'package:url_launcher/url_launcher.dart';

class SupportContactService {
  static const phoneDisplay = '0800 123 4567';
  static const phone = '08001234567';
  static const email = 'suporte@tmjapp.com.br';

  Future<bool> call() => launchUrl(
        Uri(scheme: 'tel', path: phone),
        mode: LaunchMode.externalApplication,
      );

  Future<bool> emailSupport({String? subject, String? body}) => launchUrl(
        Uri(
          scheme: 'mailto',
          path: email,
          queryParameters: {
            'subject': subject ?? 'Ajuda com o TMJApp',
            if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
          },
        ),
        mode: LaunchMode.externalApplication,
      );
}
