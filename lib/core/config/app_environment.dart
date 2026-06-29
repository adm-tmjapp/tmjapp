enum AppEnvironment {
  dev('dev'),
  prod('prod');

  const AppEnvironment(this.value);

  final String value;

  String get envFileName => '.env.$value';
}
