void runProviderExample() {
  print("\n--- Provider ---");

  print(
      "\nO que é? O padrão Provider é um padrão de gerenciamento de estado que permite compartilhar dados e lógica entre diferentes partes de um aplicativo. Ele facilita a injeção de dependências e promove a separação de preocupações, tornando o código mais modular e testável.\n");

  final container = ServiceContainer();

  container.register(ApiService());
  container.register(AuthService(container.get<ApiService>()));
  container.register(UserService(container.get<AuthService>()));

  final signInScreen = SignInScreen(container.get<AuthService>());
  final profileScreen = ProfileScreen(container.get<UserService>());

  signInScreen.signIn("john_doe", "password123");
  profileScreen.showProfile();
}

class ServiceContainer {
  final _services = <Type, dynamic>{};

  void register<T>(T service) {
    _services[T] = service;
  }

  T get<T>() {
    final service = _services[T];

    if (service == null) {
      throw Exception('Service of type $T not found');
    }

    return service as T;
  }
}

class ApiService {
  String get(String url) {
    print('[API] GET $url');
    return '{"id": 1, "name": "John Doe"}';
  }
}

class AuthService {
  final ApiService _api;
  String? _token;

  AuthService(this._api);

  bool get isAuthenticated => _token != null;

  void login(String username, String password) {
    print('[Auth] Logando com nome de usuário: $username');
    _api.get('/login?username=$username&password=$password');
    _token = 'jwt_abc123';
    print('[Auth] Logado com sucesso. Token: $_token');
  }
}

class UserService {
  final AuthService _auth;

  UserService(this._auth);

  void profile() {
    if (!_auth.isAuthenticated) {
      print('[User] Usuário não autenticado. Por favor, faça login primeiro.');
      return;
    }
    print('[User] Buscando perfil do usuário autenticado...');
  }
}

class SignInScreen {
  final AuthService _auth;

  SignInScreen(this._auth);

  void signIn(String username, String password) {
    print('[SignInScreen] Tentando fazer login...');
    _auth.login(username, password);
  }
}

class ProfileScreen {
  final UserService _userService;

  ProfileScreen(this._userService);

  void showProfile() {
    print('[ProfileScreen] Exibindo perfil do usuário...');
    _userService.profile();
  }
}
