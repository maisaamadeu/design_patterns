import 'utils/app_theme.dart';

void runObserverExample() {
  print("\n--- Observer ---");

  print(
      "\nO que é? O padrão Observer define uma dependência um-para-muitos entre objetos, de forma que quando um objeto muda de estado, todos os seus dependentes são notificados e atualizados automaticamente. Ele é útil para implementar sistemas de eventos, onde múltiplos objetos precisam reagir a mudanças em outro objeto.\n");

  print("Criando tema e observadores...");
  final theme = Theme();
  final observer1 = ThemeObserver("Observer 1");
  final observer2 = ThemeObserver("Observer 2");

  theme.attach(observer1);
  theme.attach(observer2);

  print("Alterando tema para dark...");
  theme.currentTheme = AppTheme.dark;
}

abstract class Observer {
  void update(String event, dynamic data);
}

class Subject {
  final List<Observer> _observers = [];

  void attach(Observer observer) {
    _observers.add(observer);
  }

  void detach(Observer observer) {
    _observers.remove(observer);
  }

  void notify(String event, dynamic data) {
    for (var observer in _observers) {
      observer.update(event, data);
    }
  }
}

class Theme extends Subject {
  AppTheme _currentTheme = AppTheme.light;
  AppTheme get currentTheme => _currentTheme;

  set currentTheme(AppTheme theme) {
    _currentTheme = theme;
    notify("themeChanged", theme);
  }
}

class ThemeObserver implements Observer {
  final String name;

  ThemeObserver(this.name);

  @override
  void update(String event, dynamic data) {
    if (event == "themeChanged") {
      print("$name recebeu notificação: Tema alterado para $data");
    }
  }
}
