import 'utils/app_theme.dart';

void runSingletonExample() {
  print("\n--- Singleton ---");

  print(
      "\nO que é? O padrão Singleton garante que uma classe tenha apenas uma instância e fornece um ponto de acesso global a essa instância. Ele é útil quando você precisa de um único objeto para coordenar ações em todo o sistema, como um serviço de configuração, um gerenciador de recursos ou um pool de conexões.\n");

  print("Criando duas instâncias do serviço de configurações...");

  final settingsService1 = SettingsService();
  final settingsService2 = SettingsService();

  print("Tema atual do serviço 1: ${settingsService1.currentTheme}");
  print("Tema atual do serviço 2: ${settingsService2.currentTheme}");

  settingsService1.toggleTheme();

  print("Após alternar o tema no serviço 1:");
  print("Tema atual do serviço 1: ${settingsService1.currentTheme}");
  print("Tema atual do serviço 2: ${settingsService2.currentTheme}");

  print(
      "As duas instâncias são iguais? ${identical(settingsService1, settingsService2)}");
}

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();

  SettingsService._internal();

  factory SettingsService() => _instance;

  AppTheme _currentTheme = AppTheme.light;
  AppTheme get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme =
        _currentTheme == AppTheme.light ? AppTheme.dark : AppTheme.light;
  }

  AppLanguage _currentLanguage = AppLanguage.english;
  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage language) {
    _currentLanguage = language;
  }
}

enum AppLanguage { english, spanish, french, portuguese }
