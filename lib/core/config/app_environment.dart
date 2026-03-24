enum AppEnvironment {
  dev,
  prod;

  static AppEnvironment fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.dev;
    }
  }
}
