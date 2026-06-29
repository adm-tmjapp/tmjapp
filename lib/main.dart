import 'package:tmjapp/app/bootstrap.dart';
import 'package:tmjapp/core/config/app_environment.dart';

Future<void> main() async {
  await bootstrap(environment: AppEnvironment.dev);
}
