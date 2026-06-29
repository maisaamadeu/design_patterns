# 📘 Design Patterns em Flutter
## Guia Prático para Entrevistas - Nível Pleno

> Apostila resumida e objetiva com os 10 principais Design Patterns utilizados em Flutter, focada em entrevistas de emprego.

---

## 📑 Índice

1. [Introdução](#introdução)
2. [Singleton](#1-singleton)
3. [Factory Method](#2-factory-method)
4. [Builder](#3-builder)
5. [Observer](#4-observer)
6. [Provider / Dependency Injection](#5-provider--dependency-injection)
7. [Repository](#6-repository)
8. [BLoC](#7-bloc)
9. [State](#8-state)
10. [Adapter](#9-adapter)
11. [Strategy](#10-strategy)
12. [Facade](#11-facade)
13. [Decorator](#12-decorator)
14. [Tabela Comparativa](#tabela-comparativa)
15. [Gabarito dos Exercícios](#gabarito-dos-exercícios)

---

## Introdução

**Design Patterns** são soluções reutilizáveis para problemas comuns no desenvolvimento de software. Em Flutter, eles são essenciais para criar código **escalável**, **testável** e **manutenível**.

### Classificação dos Patterns

| Tipo | Descrição | Patterns |
|------|-----------|----------|
| **Criacionais** | Criação de objetos | Singleton, Factory, Builder |
| **Estruturais** | Composição de classes | Adapter, Repository |
| **Comportamentais** | Comunicação entre objetos | Observer, State, Strategy, BLoC |

### Por que são importantes em entrevistas?

- Demonstram **maturidade técnica**
- Mostram capacidade de **arquitetar soluções**
- Indicam conhecimento de **boas práticas**
- Facilitam **comunicação técnica** com a equipe

---

## 1. Singleton

### O que é?
Garante que uma classe tenha **apenas uma instância** e fornece um ponto de acesso global a ela.

### Quando usar em Flutter?
- Serviços de API
- Gerenciadores de banco de dados
- Configurações globais
- Logger

### Exemplo Ilustrativo

```dart
class DatabaseService {
  // Instância única privada
  static final DatabaseService _instance = DatabaseService._internal();
  
  // Construtor privado
  DatabaseService._internal();
  
  // Factory que retorna sempre a mesma instância
  factory DatabaseService() => _instance;
  
  // Métodos do serviço
  Future<void> insert(Map<String, dynamic> data) async {
    print('Inserindo: $data');
  }
}

// Uso
void main() {
  final db1 = DatabaseService();
  final db2 = DatabaseService();
  
  print(db1 == db2); // true - mesma instância
}
```

### Exemplo Real: Serviço de Autenticação

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  AuthService._internal();
  
  factory AuthService() => _instance;
  
  String? _token;
  User? _currentUser;
  
  bool get isAuthenticated => _token != null;
  User? get currentUser => _currentUser;
  
  Future<bool> login(String email, String password) async {
    // Simula chamada API
    await Future.delayed(Duration(seconds: 1));
    _token = 'jwt_token_123';
    _currentUser = User(id: '1', name: 'João', email: email);
    return true;
  }
  
  void logout() {
    _token = null;
    _currentUser = null;
  }
}

class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}
```

### ⚠️ Pergunta de Entrevista

> **"Quais são os prós e contras do Singleton em Flutter?"**

**Resposta esperada:**
- ✅ **Prós:** Economia de memória, ponto único de acesso, estado compartilhado
- ❌ **Contras:** Dificulta testes unitários, cria acoplamento, pode causar memory leaks se mal implementado
- 💡 **Alternativa:** Usar GetIt ou Provider para injeção de dependências

### 📝 Exercício 1

Implemente um `SettingsService` usando Singleton que armazene:
- Tema atual (dark/light)
- Idioma preferido
- Método `toggleTheme()` e `setLanguage(String lang)`

---

## 2. Factory Method

### O que é?
Define uma interface para criar objetos, mas permite que subclasses decidam qual classe instanciar.

### Quando usar em Flutter?
- Criar widgets dinamicamente baseado em tipo
- Parsear JSON para diferentes modelos
- Criar diferentes implementações de uma interface

### Exemplo Ilustrativo

```dart
abstract class Button {
  Widget build();
}

class PrimaryButton implements Button {
  final String text;
  final VoidCallback onPressed;
  
  PrimaryButton({required this.text, required this.onPressed});
  
  @override
  Widget build() {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class SecondaryButton implements Button {
  final String text;
  final VoidCallback onPressed;
  
  SecondaryButton({required this.text, required this.onPressed});
  
  @override
  Widget build() {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// Factory
class ButtonFactory {
  static Button create(String type, String text, VoidCallback onPressed) {
    switch (type) {
      case 'primary':
        return PrimaryButton(text: text, onPressed: onPressed);
      case 'secondary':
        return SecondaryButton(text: text, onPressed: onPressed);
      default:
        throw ArgumentError('Tipo de botão desconhecido: $type');
    }
  }
}
```

### Exemplo Real: Parser de Notificações

```dart
abstract class NotificationModel {
  final String id;
  final String title;
  final DateTime createdAt;
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.createdAt,
  });
  
  // Factory method
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'message':
        return MessageNotification.fromJson(json);
      case 'promo':
        return PromoNotification.fromJson(json);
      case 'alert':
        return AlertNotification.fromJson(json);
      default:
        return GenericNotification.fromJson(json);
    }
  }
}

class MessageNotification extends NotificationModel {
  final String senderId;
  final String senderName;
  
  MessageNotification({
    required super.id,
    required super.title,
    required super.createdAt,
    required this.senderId,
    required this.senderName,
  });
  
  factory MessageNotification.fromJson(Map<String, dynamic> json) {
    return MessageNotification(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      senderId: json['sender_id'],
      senderName: json['sender_name'],
    );
  }
}

class PromoNotification extends NotificationModel {
  final double discount;
  final String promoCode;
  
  PromoNotification({
    required super.id,
    required super.title,
    required super.createdAt,
    required this.discount,
    required this.promoCode,
  });
  
  factory PromoNotification.fromJson(Map<String, dynamic> json) {
    return PromoNotification(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      discount: json['discount'].toDouble(),
      promoCode: json['promo_code'],
    );
  }
}

class AlertNotification extends NotificationModel {
  final String severity; // low, medium, high
  
  AlertNotification({
    required super.id,
    required super.title,
    required super.createdAt,
    required this.severity,
  });
  
  factory AlertNotification.fromJson(Map<String, dynamic> json) {
    return AlertNotification(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      severity: json['severity'],
    );
  }
}

class GenericNotification extends NotificationModel {
  GenericNotification({
    required super.id,
    required super.title,
    required super.createdAt,
  });
  
  factory GenericNotification.fromJson(Map<String, dynamic> json) {
    return GenericNotification(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

### ⚠️ Pergunta de Entrevista

> **"Qual a diferença entre Factory Method e Abstract Factory?"**

**Resposta esperada:**
- **Factory Method:** Cria UM tipo de objeto, delega criação para subclasses
- **Abstract Factory:** Cria FAMÍLIAS de objetos relacionados
- Em Flutter, Factory Method é mais comum (ex: `fromJson`)

### 📝 Exercício 2

Crie um `PaymentMethodFactory` que retorne diferentes implementações de pagamento (Pix, Cartão, Boleto) baseado em um JSON com campo `type`.

---

## 3. Builder

### O que é?
Separa a construção de um objeto complexo da sua representação, permitindo criar diferentes representações com o mesmo processo.

### Quando usar em Flutter?
- Construir objetos com muitos parâmetros opcionais
- Criar configurações complexas passo a passo
- Montar queries de banco de dados

### Exemplo Ilustrativo

```dart
class Pizza {
  final String size;
  final String crust;
  final List<String> toppings;
  final bool extraCheese;
  
  Pizza._({
    required this.size,
    required this.crust,
    required this.toppings,
    required this.extraCheese,
  });
}

class PizzaBuilder {
  String _size = 'medium';
  String _crust = 'traditional';
  List<String> _toppings = [];
  bool _extraCheese = false;
  
  PizzaBuilder setSize(String size) {
    _size = size;
    return this;
  }
  
  PizzaBuilder setCrust(String crust) {
    _crust = crust;
    return this;
  }
  
  PizzaBuilder addTopping(String topping) {
    _toppings.add(topping);
    return this;
  }
  
  PizzaBuilder withExtraCheese() {
    _extraCheese = true;
    return this;
  }
  
  Pizza build() {
    return Pizza._(
      size: _size,
      crust: _crust,
      toppings: _toppings,
      extraCheese: _extraCheese,
    );
  }
}

// Uso fluente
final pizza = PizzaBuilder()
    .setSize('large')
    .setCrust('thin')
    .addTopping('pepperoni')
    .addTopping('mushrooms')
    .withExtraCheese()
    .build();
```

### Exemplo Real: Query Builder para Firestore

```dart
class FirestoreQueryBuilder {
  final String _collection;
  final List<_WhereClause> _whereClauses = [];
  String? _orderByField;
  bool _descending = false;
  int? _limitCount;
  
  FirestoreQueryBuilder(this._collection);
  
  FirestoreQueryBuilder where(String field, String operator, dynamic value) {
    _whereClauses.add(_WhereClause(field, operator, value));
    return this;
  }
  
  FirestoreQueryBuilder orderBy(String field, {bool descending = false}) {
    _orderByField = field;
    _descending = descending;
    return this;
  }
  
  FirestoreQueryBuilder limit(int count) {
    _limitCount = count;
    return this;
  }
  
  Query<Map<String, dynamic>> build() {
    Query<Map<String, dynamic>> query = 
        FirebaseFirestore.instance.collection(_collection);
    
    for (final clause in _whereClauses) {
      query = _applyWhere(query, clause);
    }
    
    if (_orderByField != null) {
      query = query.orderBy(_orderByField!, descending: _descending);
    }
    
    if (_limitCount != null) {
      query = query.limit(_limitCount!);
    }
    
    return query;
  }
  
  Query<Map<String, dynamic>> _applyWhere(
    Query<Map<String, dynamic>> query, 
    _WhereClause clause
  ) {
    switch (clause.operator) {
      case '==':
        return query.where(clause.field, isEqualTo: clause.value);
      case '>':
        return query.where(clause.field, isGreaterThan: clause.value);
      case '<':
        return query.where(clause.field, isLessThan: clause.value);
      case '>=':
        return query.where(clause.field, isGreaterThanOrEqualTo: clause.value);
      case '<=':
        return query.where(clause.field, isLessThanOrEqualTo: clause.value);
      default:
        throw ArgumentError('Operador não suportado: ${clause.operator}');
    }
  }
}

class _WhereClause {
  final String field;
  final String operator;
  final dynamic value;
  
  _WhereClause(this.field, this.operator, this.value);
}

// Uso
final query = FirestoreQueryBuilder('users')
    .where('age', '>=', 18)
    .where('status', '==', 'active')
    .orderBy('createdAt', descending: true)
    .limit(10)
    .build();
```

### ⚠️ Pergunta de Entrevista

> **"Quando usar Builder ao invés de um construtor com parâmetros nomeados?"**

**Resposta esperada:**
- Quando há **muitos parâmetros opcionais** (>5)
- Quando a **ordem de configuração importa**
- Quando precisa **validar** o objeto antes de criar
- Quando quer uma **API fluente** (method chaining)

### 📝 Exercício 3

Crie um `HttpRequestBuilder` que permita configurar: URL, método (GET/POST/PUT/DELETE), headers, body e timeout.

---

## 4. Observer

### O que é?
Define uma dependência um-para-muitos entre objetos, onde quando um objeto muda de estado, todos os dependentes são notificados automaticamente.

### Quando usar em Flutter?
- **É a BASE do Flutter!**
- ChangeNotifier + Consumer/Selector
- ValueNotifier + ValueListenableBuilder
- Streams + StreamBuilder

### Exemplo Ilustrativo

```dart
// Implementação manual do Observer
abstract class Observer {
  void update(String event, dynamic data);
}

class Subject {
  final List<Observer> _observers = [];
  
  void addObserver(Observer observer) {
    _observers.add(observer);
  }
  
  void removeObserver(Observer observer) {
    _observers.remove(observer);
  }
  
  void notifyObservers(String event, dynamic data) {
    for (final observer in _observers) {
      observer.update(event, data);
    }
  }
}

// Exemplo de uso
class StockPrice extends Subject {
  double _price = 0;
  
  double get price => _price;
  
  set price(double value) {
    _price = value;
    notifyObservers('priceChanged', value);
  }
}

class StockDisplay implements Observer {
  final String name;
  
  StockDisplay(this.name);
  
  @override
  void update(String event, dynamic data) {
    print('[$name] Novo preço: R\$ $data');
  }
}
```

### Exemplo Real: ChangeNotifier no Flutter

```dart
// Model com ChangeNotifier
class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];
  
  List<CartItem> get items => List.unmodifiable(_items);
  
  int get itemCount => _items.length;
  
  double get total => _items.fold(0, (sum, item) => sum + item.total);
  
  void addItem(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((i) => i.productId == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        quantity: quantity,
      ));
    }
    
    notifyListeners(); // Notifica todos os observers
  }
  
  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }
  
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  
  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });
  
  double get total => price * quantity;
  
  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  
  Product({required this.id, required this.name, required this.price});
}

// Widget que observa mudanças
class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartNotifier>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Carrinho (${cart.itemCount})'),
          ),
          body: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.quantity}x R\$ ${item.price}'),
                trailing: Text('R\$ ${item.total.toStringAsFixed(2)}'),
              );
            },
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Total: R\$ ${cart.total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
```

### ⚠️ Pergunta de Entrevista

> **"Qual a diferença entre ChangeNotifier e ValueNotifier?"**

**Resposta esperada:**
- **ChangeNotifier:** Notifica mudanças genéricas, você decide quando chamar `notifyListeners()`
- **ValueNotifier:** Notifica automaticamente quando o `value` muda, ideal para valores únicos
- **ValueNotifier é mais eficiente** para valores simples, **ChangeNotifier** para estados complexos

### 📝 Exercício 4

Crie um `ThemeNotifier` usando `ChangeNotifier` que permita alternar entre tema claro e escuro, armazenando a preferência.

---

## 5. Provider / Dependency Injection

### O que é?
Fornece objetos para widgets descendentes na árvore sem precisar passá-los manualmente por construtores.

### Quando usar em Flutter?
- Compartilhar estado entre widgets
- Injetar serviços (API, Database)
- Gerenciar configurações globais
- Separar lógica de negócio da UI

### Exemplo Ilustrativo

```dart
// Configuração básica do Provider
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Serviços (não mudam)
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        
        // Estados reativos
        ChangeNotifierProvider<UserNotifier>(
          create: (_) => UserNotifier(),
        ),
        
        // Com dependência de outro provider
        ChangeNotifierProxyProvider<ApiService, ProductNotifier>(
          create: (_) => ProductNotifier(),
          update: (_, api, notifier) => notifier!..apiService = api,
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

### Exemplo Real: Arquitetura com Provider

```dart
// 1. Serviço de API
class ApiService {
  final String baseUrl = 'https://api.example.com';
  
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException('Erro: ${response.statusCode}');
  }
  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw ApiException('Erro: ${response.statusCode}');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

// 2. Notifier com estado
class ProductNotifier extends ChangeNotifier {
  ApiService? _apiService;
  
  set apiService(ApiService service) => _apiService = service;
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await _apiService!.get('/products');
      _products = (data['items'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// 3. Widget consumindo
class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produtos')),
      body: Consumer<ProductNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (notifier.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: ${notifier.error}'),
                  ElevatedButton(
                    onPressed: () => notifier.loadProducts(),
                    child: Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: notifier.products.length,
            itemBuilder: (context, index) {
              final product = notifier.products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('R\$ ${product.price}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ProductNotifier>().loadProducts();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

### ⚠️ Pergunta de Entrevista

> **"Qual a diferença entre `context.read()` e `context.watch()`?"**

**Resposta esperada:**
- **`context.read<T>()`:** Obtém o valor UMA vez, NÃO rebuilda quando muda. Use em callbacks (onPressed)
- **`context.watch<T>()`:** Observa mudanças e REBUILDA o widget. Use no build()
- **`context.select<T, R>()`:** Observa apenas UMA propriedade específica (mais otimizado)

### 📝 Exercício 5

Configure um `MultiProvider` com: `AuthService` (singleton), `AuthNotifier` (ChangeNotifier) e `UserNotifier` (depende de AuthNotifier).

---

## 6. Repository

### O que é?
Abstrai a lógica de acesso a dados, fornecendo uma interface limpa para a camada de domínio sem expor detalhes de implementação.

### Quando usar em Flutter?
- Separar fontes de dados (API, cache, local)
- Facilitar testes (mock do repository)
- Centralizar lógica de dados
- Implementar cache transparente

### Exemplo Ilustrativo

```dart
// Interface do Repository
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<List<User>> getAllUsers();
  Future<void> saveUser(User user);
  Future<void> deleteUser(String id);
}

// Implementação com API
class ApiUserRepository implements UserRepository {
  final ApiService _api;
  
  ApiUserRepository(this._api);
  
  @override
  Future<User> getUser(String id) async {
    final data = await _api.get('/users/$id');
    return User.fromJson(data);
  }
  
  @override
  Future<List<User>> getAllUsers() async {
    final data = await _api.get('/users');
    return (data['users'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }
  
  @override
  Future<void> saveUser(User user) async {
    await _api.post('/users', user.toJson());
  }
  
  @override
  Future<void> deleteUser(String id) async {
    await _api.delete('/users/$id');
  }
}
```

### Exemplo Real: Repository com Cache

```dart
// Interface
abstract class ProductRepository {
  Future<List<Product>> getProducts({bool forceRefresh = false});
  Future<Product> getProductById(String id);
  Future<void> favoriteProduct(String id);
}

// Implementação com cache
class ProductRepositoryImpl implements ProductRepository {
  final ApiService _api;
  final LocalStorage _localStorage;
  final Duration _cacheDuration = Duration(minutes: 5);
  
  DateTime? _lastFetch;
  List<Product>? _cachedProducts;
  
  ProductRepositoryImpl({
    required ApiService api,
    required LocalStorage localStorage,
  })  : _api = api,
        _localStorage = localStorage;
  
  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    // Verifica cache em memória
    if (!forceRefresh && _isCacheValid()) {
      return _cachedProducts!;
    }
    
    // Tenta cache local
    if (!forceRefresh) {
      final localData = await _localStorage.get('products');
      if (localData != null) {
        final cached = _parseProductList(localData);
        final cachedAt = DateTime.parse(localData['cached_at']);
        
        if (DateTime.now().difference(cachedAt) < _cacheDuration) {
          _cachedProducts = cached;
          _lastFetch = cachedAt;
          return cached;
        }
      }
    }
    
    // Busca da API
    try {
      final data = await _api.get('/products');
      final products = _parseProductList(data);
      
      // Salva no cache local
      await _localStorage.set('products', {
        ...data,
        'cached_at': DateTime.now().toIso8601String(),
      });
      
      // Atualiza cache em memória
      _cachedProducts = products;
      _lastFetch = DateTime.now();
      
      return products;
    } catch (e) {
      // Fallback para cache se API falhar
      if (_cachedProducts != null) {
        return _cachedProducts!;
      }
      rethrow;
    }
  }
  
  @override
  Future<Product> getProductById(String id) async {
    // Tenta encontrar no cache primeiro
    if (_cachedProducts != null) {
      final cached = _cachedProducts!.firstWhere(
        (p) => p.id == id,
        orElse: () => throw NotFoundException('Produto não encontrado'),
      );
      return cached;
    }
    
    // Busca da API
    final data = await _api.get('/products/$id');
    return Product.fromJson(data);
  }
  
  @override
  Future<void> favoriteProduct(String id) async {
    await _api.post('/products/$id/favorite', {});
    
    // Atualiza cache local
    if (_cachedProducts != null) {
      final index = _cachedProducts!.indexWhere((p) => p.id == id);
      if (index >= 0) {
        _cachedProducts![index] = _cachedProducts![index].copyWith(
          isFavorite: true,
        );
      }
    }
  }
  
  bool _isCacheValid() {
    return _cachedProducts != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration;
  }
  
  List<Product> _parseProductList(Map<String, dynamic> data) {
    return (data['items'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class LocalStorage {
  Future<Map<String, dynamic>?> get(String key) async {
    // Implementação com SharedPreferences ou Hive
    return null;
  }
  
  Future<void> set(String key, Map<String, dynamic> value) async {
    // Implementação com SharedPreferences ou Hive
  }
}
```

### ⚠️ Pergunta de Entrevista

> **"Por que usar Repository ao invés de chamar a API diretamente no Widget?"**

**Resposta esperada:**
1. **Separação de responsabilidades** - UI não conhece detalhes de dados
2. **Testabilidade** - Fácil criar mock do Repository
3. **Flexibilidade** - Trocar fonte de dados sem mudar UI
4. **Cache** - Implementar estratégias de cache transparentemente
5. **Manutenibilidade** - Lógica de dados centralizada

### 📝 Exercício 6

Crie um `OrderRepository` com interface e implementação que:
- Busque pedidos da API
- Tenha cache local com expiração de 10 minutos
- Retorne cache offline se API falhar

---

## 7. BLoC

### O que é?
**B**usiness **Lo**gic **C**omponent - Separa a lógica de negócios da UI usando Streams. Entrada são Events, saída são States.

### Quando usar em Flutter?
- Aplicações médias/grandes
- Fluxos complexos de dados
- Necessidade de rastreabilidade (debug)
- Equipes grandes (separação clara)

### Diagrama

```
┌─────────┐     Event     ┌─────────┐     State     ┌─────────┐
│   UI    │ ────────────► │   BLoC  │ ────────────► │   UI    │
└─────────┘               └─────────┘               └─────────┘
                               │
                               ▼
                        ┌─────────────┐
                        │ Repository  │
                        └─────────────┘
```

### Exemplo Ilustrativo

```dart
// Events
abstract class CounterEvent {}

class IncrementEvent extends CounterEvent {}
class DecrementEvent extends CounterEvent {}
class ResetEvent extends CounterEvent {}

// States
class CounterState {
  final int count;
  
  CounterState(this.count);
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<IncrementEvent>((event, emit) {
      emit(CounterState(state.count + 1));
    });
    
    on<DecrementEvent>((event, emit) {
      emit(CounterState(state.count - 1));
    });
    
    on<ResetEvent>((event, emit) {
      emit(CounterState(0));
    });
  }
}
```

### Exemplo Real: Login com BLoC

```dart
// Events
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  
  LoginSubmitted({required this.email, required this.password});
}

class LoginEmailChanged extends LoginEvent {
  final String email;
  LoginEmailChanged(this.email);
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  LoginPasswordChanged(this.password);
}

// States
enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final String email;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final bool isEmailValid;
  final bool isPasswordValid;
  
  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.isEmailValid = true,
    this.isPasswordValid = true,
  });
  
  bool get isFormValid => 
      isEmailValid && isPasswordValid && email.isNotEmpty && password.isNotEmpty;
  
  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    String? errorMessage,
    bool? isEmailValid,
    bool? isPasswordValid,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
    );
  }
}

// BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  
  LoginBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }
  
  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final isValid = _isValidEmail(event.email);
    emit(state.copyWith(
      email: event.email,
      isEmailValid: isValid,
      status: LoginStatus.initial,
    ));
  }
  
  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    final isValid = event.password.length >= 6;
    emit(state.copyWith(
      password: event.password,
      isPasswordValid: isValid,
      status: LoginStatus.initial,
    ));
  }
  
  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isFormValid) return;
    
    emit(state.copyWith(status: LoginStatus.loading));
    
    try {
      await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

// UI
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        authRepository: context.read<AuthRepository>(),
      ),
      child: BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state.status == LoginStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Erro no login')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text('Login')),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      context.read<LoginBloc>().add(LoginEmailChanged(value));
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: state.isEmailValid ? null : 'Email inválido',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      context.read<LoginBloc>().add(LoginPasswordChanged(value));
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      errorText: state.isPasswordValid 
                          ? null 
                          : 'Mínimo 6 caracteres',
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isFormValid && 
                                 state.status != LoginStatus.loading
                          ? () {
                              context.read<LoginBloc>().add(
                                LoginSubmitted(
                                  email: state.email,
                                  password: state.password,
                                ),
                              );
                            }
                          : null,
                      child: state.status == LoginStatus.loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Entrar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Repository interface
abstract class AuthRepository {
  Future<void> login({required String email, required String password});
}
```

### ⚠️ Pergunta de Entrevista

> **"Qual a diferença entre BLoC e Provider? Quando usar cada um?"**

**Resposta esperada:**
| Aspecto | BLoC | Provider |
|---------|------|----------|
| Complexidade | Alta | Baixa/Média |
| Curva de aprendizado | Íngreme | Suave |
| Testabilidade | Excelente | Boa |
| Boilerplate | Muito | Pouco |
| Debug | Fácil (eventos) | Médio |
| **Quando usar** | Apps grandes, fluxos complexos | Apps pequenos/médios |

### 📝 Exercício 7

Crie um `SearchBloc` com:
- Events: `SearchQueryChanged(String query)`, `SearchSubmitted`
- States: `initial`, `loading`, `loaded(List<Result>)`, `error(String)`
- Debounce de 300ms no `SearchQueryChanged`

---

## 8. State

### O que é?
Permite que um objeto altere seu comportamento quando seu estado interno muda. O objeto parecerá ter mudado de classe.

### Quando usar em Flutter?
- Fluxos com múltiplos estados (pedido, pagamento)
- Wizards/formulários multi-etapas
- Players de mídia (play, pause, stop)
- Conexão de rede (online, offline, connecting)

### Exemplo Ilustrativo

```dart
// Estados possíveis
abstract class OrderState {
  String get statusText;
  bool get canCancel;
  OrderState? next();
}

class PendingState implements OrderState {
  @override
  String get statusText => 'Aguardando pagamento';
  
  @override
  bool get canCancel => true;
  
  @override
  OrderState? next() => PaidState();
}

class PaidState implements OrderState {
  @override
  String get statusText => 'Pago - Preparando';
  
  @override
  bool get canCancel => true;
  
  @override
  OrderState? next() => ShippedState();
}

class ShippedState implements OrderState {
  @override
  String get statusText => 'Enviado';
  
  @override
  bool get canCancel => false;
  
  @override
  OrderState? next() => DeliveredState();
}

class DeliveredState implements OrderState {
  @override
  String get statusText => 'Entregue';
  
  @override
  bool get canCancel => false;
  
  @override
  OrderState? next() => null; // Estado final
}

// Contexto que usa os estados
class Order {
  OrderState _state = PendingState();
  
  String get status => _state.statusText;
  bool get canCancel => _state.canCancel;
  
  void advance() {
    final nextState = _state.next();
    if (nextState != null) {
      _state = nextState;
    }
  }
  
  void cancel() {
    if (_state.canCancel) {
      _state = CancelledState();
    } else {
      throw StateError('Pedido não pode ser cancelado');
    }
  }
}

class CancelledState implements OrderState {
  @override
  String get statusText => 'Cancelado';
  
  @override
  bool get canCancel => false;
  
  @override
  OrderState? next() => null;
}
```

### Exemplo Real: Player de Áudio

```dart
// Estados do player
abstract class PlayerState {
  void play(AudioPlayer player);
  void pause(AudioPlayer player);
  void stop(AudioPlayer player);
  String get icon;
}

class StoppedState implements PlayerState {
  @override
  void play(AudioPlayer player) {
    player._startPlayback();
    player._state = PlayingState();
  }
  
  @override
  void pause(AudioPlayer player) {
    // Não faz nada - já está parado
  }
  
  @override
  void stop(AudioPlayer player) {
    // Não faz nada - já está parado
  }
  
  @override
  String get icon => '▶️';
}

class PlayingState implements PlayerState {
  @override
  void play(AudioPlayer player) {
    // Não faz nada - já está tocando
  }
  
  @override
  void pause(AudioPlayer player) {
    player._pausePlayback();
    player._state = PausedState();
  }
  
  @override
  void stop(AudioPlayer player) {
    player._stopPlayback();
    player._state = StoppedState();
  }
  
  @override
  String get icon => '⏸️';
}

class PausedState implements PlayerState {
  @override
  void play(AudioPlayer player) {
    player._resumePlayback();
    player._state = PlayingState();
  }
  
  @override
  void pause(AudioPlayer player) {
    // Não faz nada - já está pausado
  }
  
  @override
  void stop(AudioPlayer player) {
    player._stopPlayback();
    player._state = StoppedState();
  }
  
  @override
  String get icon => '▶️';
}

// Context
class AudioPlayer extends ChangeNotifier {
  PlayerState _state = StoppedState();
  String? _currentTrack;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  String get icon => _state.icon;
  String? get currentTrack => _currentTrack;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _state is PlayingState;
  
  void loadTrack(String trackUrl, Duration duration) {
    _currentTrack = trackUrl;
    _duration = duration;
    _position = Duration.zero;
    notifyListeners();
  }
  
  void play() {
    _state.play(this);
    notifyListeners();
  }
  
  void pause() {
    _state.pause(this);
    notifyListeners();
  }
  
  void stop() {
    _state.stop(this);
    notifyListeners();
  }
  
  void seek(Duration position) {
    _position = position;
    notifyListeners();
  }
  
  // Métodos internos
  void _startPlayback() {
    print('Iniciando reprodução de $_currentTrack');
  }
  
  void _pausePlayback() {
    print('Pausando reprodução');
  }
  
  void _resumePlayback() {
    print('Retomando reprodução');
  }
  
  void _stopPlayback() {
    _position = Duration.zero;
    print('Parando reprodução');
  }
}

// Widget
class PlayerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayer>(
      builder: (context, player, _) {
        return Column(
          children: [
            Text(player.currentTrack ?? 'Nenhuma música'),
            Slider(
              value: player.position.inSeconds.toDouble(),
              max: player.duration.inSeconds.toDouble(),
              onChanged: (value) {
                player.seek(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: player.stop,
                ),
                IconButton(
                  icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 48,
                  onPressed: player.isPlaying ? player.pause : player.play,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
```

### ⚠️ Pergunta de Entrevista

> **"Qual a diferença entre State Pattern e Strategy Pattern?"**

**Resposta esperada:**
- **State:** O objeto muda de comportamento baseado em seu **estado interno**. O estado pode mudar automaticamente.
- **Strategy:** O **cliente escolhe** qual algoritmo usar. Não há transição automática.
- **State** = "O que eu sou agora?" / **Strategy** = "Como eu faço isso?"

### 📝 Exercício 8

Implemente uma máquina de estados para um semáforo com estados: `Red`, `Yellow`, `Green`. Cada estado deve ter:
- Duração em segundos
- Cor correspondente
- Próximo estado

---

## 9. Adapter

### O que é?
Converte a interface de uma classe em outra interface que o cliente espera. Permite que classes com interfaces incompatíveis trabalhem juntas.

### Quando usar em Flutter?
- Integrar APIs externas com formato diferente
- Converter modelos de terceiros para seus modelos
- Adaptar bibliotecas legadas
- Normalizar dados de múltiplas fontes

### Exemplo Ilustrativo

```dart
// Interface esperada pelo app
abstract class PaymentGateway {
  Future<PaymentResult> processPayment(double amount, String currency);
}

class PaymentResult {
  final bool success;
  final String transactionId;
  final String? errorMessage;
  
  PaymentResult({
    required this.success,
    required this.transactionId,
    this.errorMessage,
  });
}

// API externa com interface diferente (ex: Stripe)
class StripeApi {
  Future<Map<String, dynamic>> createCharge({
    required int amountInCents,
    required String currencyCode,
    required String source,
  }) async {
    // Simula chamada à API do Stripe
    await Future.delayed(Duration(seconds: 1));
    return {
      'id': 'ch_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'succeeded',
      'amount': amountInCents,
    };
  }
}

// Adapter
class StripeAdapter implements PaymentGateway {
  final StripeApi _stripeApi;
  final String _defaultSource;
  
  StripeAdapter({
    required StripeApi stripeApi,
    required String defaultSource,
  })  : _stripeApi = stripeApi,
        _defaultSource = defaultSource;
  
  @override
  Future<PaymentResult> processPayment(double amount, String currency) async {
    try {
      // Converte para formato do Stripe
      final amountInCents = (amount * 100).toInt();
      
      final response = await _stripeApi.createCharge(
        amountInCents: amountInCents,
        currencyCode: currency.toLowerCase(),
        source: _defaultSource,
      );
      
      // Converte resposta do Stripe para nosso formato
      return PaymentResult(
        success: response['status'] == 'succeeded',
        transactionId: response['id'],
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        transactionId: '',
        errorMessage: e.toString(),
      );
    }
  }
}
```

### Exemplo Real: Adapter para APIs de Mapas

```dart
// Interface unificada do app
abstract class MapService {
  Future<LatLng> geocode(String address);
  Future<String> reverseGeocode(LatLng location);
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination);
  Future<double> getDistance(LatLng origin, LatLng destination);
}

class LatLng {
  final double latitude;
  final double longitude;
  
  LatLng(this.latitude, this.longitude);
}

// API do Google Maps (formato próprio)
class GoogleMapsApi {
  Future<Map<String, dynamic>> findPlace(String query) async {
    // Retorna formato Google
    return {
      'results': [
        {
          'geometry': {
            'location': {'lat': -23.5505, 'lng': -46.6333}
          }
        }
      ]
    };
  }
  
  Future<Map<String, dynamic>> getDirections(
    Map<String, double> origin,
    Map<String, double> destination,
  ) async {
    return {
      'routes': [
        {
          'legs': [
            {
              'distance': {'value': 15000},
              'steps': [
                {'end_location': {'lat': -23.5505, 'lng': -46.6333}},
              ]
            }
          ]
        }
      ]
    };
  }
}

// Adapter para Google Maps
class GoogleMapsAdapter implements MapService {
  final GoogleMapsApi _api;
  
  GoogleMapsAdapter(this._api);
  
  @override
  Future<LatLng> geocode(String address) async {
    final response = await _api.findPlace(address);
    final location = response['results'][0]['geometry']['location'];
    return LatLng(location['lat'], location['lng']);
  }
  
  @override
  Future<String> reverseGeocode(LatLng location) async {
    // Implementação
    return 'Endereço encontrado';
  }
  
  @override
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    final response = await _api.getDirections(
      {'lat': origin.latitude, 'lng': origin.longitude},
      {'lat': destination.latitude, 'lng': destination.longitude},
    );
    
    final steps = response['routes'][0]['legs'][0]['steps'] as List;
    return steps.map((step) {
      final loc = step['end_location'];
      return LatLng(loc['lat'], loc['lng']);
    }).toList();
  }
  
  @override
  Future<double> getDistance(LatLng origin, LatLng destination) async {
    final response = await _api.getDirections(
      {'lat': origin.latitude, 'lng': origin.longitude},
      {'lat': destination.latitude, 'lng': destination.longitude},
    );
    
    final meters = response['routes'][0]['legs'][0]['distance']['value'];
    return meters / 1000; // Retorna em km
  }
}

// Uso no app - não importa qual serviço de mapa
class LocationService {
  final MapService _mapService;
  
  LocationService(this._mapService);
  
  Future<double> calculateDeliveryDistance(String address) async {
    final storeLocation = LatLng(-23.5505, -46.6333);
    final clientLocation = await _mapService.geocode(address);
    return _mapService.getDistance(storeLocation, clientLocation);
  }
}
```

### ⚠️ Pergunta de Entrevista

> **"Qual a diferença entre Adapter e Facade?"**

**Resposta esperada:**
- **Adapter:** Converte UMA interface para outra. Faz duas interfaces incompatíveis trabalharem juntas.
- **Facade:** Simplifica uma interface COMPLEXA. Fornece interface simplificada para um subsistema.
- **Adapter** = Tradutor / **Facade** = Recepcionista

### 📝 Exercício 9

Crie um `WeatherAdapter` que converta a resposta da OpenWeatherMap API para um modelo `Weather` do seu app com: temperatura (Celsius), descrição, ícone e umidade.

---

## 10. Strategy

### O que é?
Define uma família de algoritmos, encapsula cada um e os torna intercambiáveis. Permite que o algoritmo varie independentemente dos clientes que o usam.

### Quando usar em Flutter?
- Diferentes formas de autenticação (email, Google, Apple)
- Diferentes métodos de pagamento
- Diferentes algoritmos de ordenação/filtro
- Diferentes estratégias de validação

### Exemplo Ilustrativo

```dart
// Interface da estratégia
abstract class SortStrategy<T> {
  List<T> sort(List<T> items);
}

// Implementações
class PriceLowToHigh implements SortStrategy<Product> {
  @override
  List<Product> sort(List<Product> items) {
    return List.from(items)..sort((a, b) => a.price.compareTo(b.price));
  }
}

class PriceHighToLow implements SortStrategy<Product> {
  @override
  List<Product> sort(List<Product> items) {
    return List.from(items)..sort((a, b) => b.price.compareTo(a.price));
  }
}

class NameAZ implements SortStrategy<Product> {
  @override
  List<Product> sort(List<Product> items) {
    return List.from(items)..sort((a, b) => a.name.compareTo(b.name));
  }
}

class MostRecent implements SortStrategy<Product> {
  @override
  List<Product> sort(List<Product> items) {
    return List.from(items)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

// Contexto que usa a estratégia
class ProductList {
  List<Product> _products;
  SortStrategy<Product> _sortStrategy;
  
  ProductList(this._products, this._sortStrategy);
  
  void setSortStrategy(SortStrategy<Product> strategy) {
    _sortStrategy = strategy;
  }
  
  List<Product> getSortedProducts() {
    return _sortStrategy.sort(_products);
  }
}
```

### Exemplo Real: Estratégias de Autenticação

```dart
// Interface da estratégia
abstract class AuthStrategy {
  Future<UserCredential> authenticate();
  String get providerName;
  IconData get icon;
}

// Implementação: Email/Senha
class EmailAuthStrategy implements AuthStrategy {
  final String email;
  final String password;
  
  EmailAuthStrategy({required this.email, required this.password});
  
  @override
  Future<UserCredential> authenticate() async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  @override
  String get providerName => 'Email';
  
  @override
  IconData get icon => Icons.email;
}

// Implementação: Google
class GoogleAuthStrategy implements AuthStrategy {
  @override
  Future<UserCredential> authenticate() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    
    if (googleUser == null) {
      throw AuthException('Login cancelado');
    }
    
    final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  
  @override
  String get providerName => 'Google';
  
  @override
  IconData get icon => Icons.g_mobiledata;
}

// Implementação: Apple
class AppleAuthStrategy implements AuthStrategy {
  @override
  Future<UserCredential> authenticate() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }
  
  @override
  String get providerName => 'Apple';
  
  @override
  IconData get icon => Icons.apple;
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

// Serviço de autenticação usando Strategy
class AuthService {
  AuthStrategy? _currentStrategy;
  
  void setStrategy(AuthStrategy strategy) {
    _currentStrategy = strategy;
  }
  
  Future<User?> login() async {
    if (_currentStrategy == null) {
      throw AuthException('Nenhuma estratégia de autenticação definida');
    }
    
    try {
      final credential = await _currentStrategy!.authenticate();
      return credential.user;
    } catch (e) {
      throw AuthException('Falha ao autenticar: $e');
    }
  }
}

// Widget usando diferentes estratégias
class LoginPage extends StatelessWidget {
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Login com Email (precisa de form)
            ElevatedButton.icon(
              icon: Icon(Icons.email),
              label: Text('Entrar com Email'),
              onPressed: () => _showEmailForm(context),
            ),
            SizedBox(height: 16),
            
            // Login com Google
            ElevatedButton.icon(
              icon: Icon(Icons.g_mobiledata),
              label: Text('Entrar com Google'),
              onPressed: () async {
                _authService.setStrategy(GoogleAuthStrategy());
                await _authenticate(context);
              },
            ),
            SizedBox(height: 16),
            
            // Login com Apple (só iOS)
            if (Platform.isIOS)
              ElevatedButton.icon(
                icon: Icon(Icons.apple),
                label: Text('Entrar com Apple'),
                onPressed: () async {
                  _authService.setStrategy(AppleAuthStrategy());
                  await _authenticate(context);
                },
              ),
          ],
        ),
      ),
    );
  }
  
  void _showEmailForm(BuildContext context) {
    // Mostra formulário de email/senha
    // Depois chama:
    // _authService.setStrategy(EmailAuthStrategy(email: ..., password: ...));
    // _authenticate(context);
  }
  
  Future<void> _authenticate(BuildContext context) async {
    try {
      final user = await _authService.login();
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
```

### ⚠️ Pergunta de Entrevista

> **"Como você implementaria diferentes formas de pagamento usando Design Patterns?"**

**Resposta esperada:**
1. **Strategy Pattern** para diferentes métodos (Pix, Cartão, Boleto)
2. **Factory** para criar a estratégia correta baseado no tipo
3. **Repository** para persistir transações
4. Cada estratégia implementa interface `PaymentStrategy` com método `pay()`

### 📝 Exercício 10

Crie um sistema de desconto usando Strategy com:
- `PercentageDiscount(double percent)`
- `FixedDiscount(double amount)`
- `BuyXGetYDiscount(int buyQty, int freeQty)`

---

## 11. Facade

### O que é?
Fornece uma interface simplificada para um conjunto complexo de subsistemas. Em vez de interagir com múltiplos objetos, o cliente interage com um único ponto de entrada.

### Quando usar em Flutter?
- Inicialização de múltiplos serviços (Firebase, Analytics, Push)
- Encapsular operações multi-etapa (checkout, upload, OAuth)
- Ocultar complexidade de integrações externas
- Criar uma API de alto nível para funcionalidades complexas

### Exemplo Ilustrativo

```dart
// Subsistemas complexos
class LuzService {
  void ligar() => print('Luzes ligadas');
  void desligar() => print('Luzes desligadas');
  void diminuir(int percentual) => print('Luzes em $percentual%');
}

class ArCondicionadoService {
  void ligar(int temperatura) => print('AC ligado a ${temperatura}°C');
  void desligar() => print('AC desligado');
}

class NetflixService {
  void abrir() => print('Netflix aberto');
  void fechar() => print('Netflix fechado');
  void reproduzir(String titulo) => print('Reproduzindo: $titulo');
}

// Facade: uma interface simples para tudo isso
class SalaDeFilmeFacade {
  final _luz = LuzService();
  final _ac = ArCondicionadoService();
  final _netflix = NetflixService();

  void modoFilme(String titulo) {
    _luz.diminuir(20);
    _ac.ligar(22);
    _netflix.abrir();
    _netflix.reproduzir(titulo);
  }

  void encerrarFilme() {
    _luz.ligar();
    _ac.desligar();
    _netflix.fechar();
  }
}

// Uso: o cliente não sabe dos subsistemas
void main() {
  final sala = SalaDeFilmeFacade();
  sala.modoFilme('Inception');
  sala.encerrarFilme();
}
```

### Exemplo Real: Facade de Checkout

```dart
class PaymentService {
  Future<String> cobrar(double valor, String metodo) async {
    await Future.delayed(Duration(milliseconds: 500));
    return 'txn_${DateTime.now().millisecondsSinceEpoch}';
  }
}

class InventoryService {
  Future<void> reservar(String produtoId, int quantidade) async {
    print('Estoque reservado: $produtoId x$quantidade');
  }
}

class EmailService {
  Future<void> enviarConfirmacao(String email, String pedidoId) async {
    print('Email enviado para $email: pedido $pedidoId confirmado');
  }
}

class OrderService {
  Future<String> criar(List<Map<String, dynamic>> itens) async {
    return 'pedido_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// Facade: orquestra tudo em um único método
class CheckoutFacade {
  final _payment = PaymentService();
  final _inventory = InventoryService();
  final _email = EmailService();
  final _order = OrderService();

  Future<CheckoutResult> finalizar({
    required List<Map<String, dynamic>> itens,
    required double total,
    required String metodo,
    required String email,
  }) async {
    try {
      for (final item in itens) {
        await _inventory.reservar(item['id'], item['quantidade']);
      }
      final pedidoId = await _order.criar(itens);
      final transacaoId = await _payment.cobrar(total, metodo);
      await _email.enviarConfirmacao(email, pedidoId);

      return CheckoutResult(sucesso: true, pedidoId: pedidoId, transacaoId: transacaoId);
    } catch (e) {
      return CheckoutResult(sucesso: false, erro: e.toString());
    }
  }
}

class CheckoutResult {
  final bool sucesso;
  final String? pedidoId;
  final String? transacaoId;
  final String? erro;

  CheckoutResult({required this.sucesso, this.pedidoId, this.transacaoId, this.erro});
}

// Uso: o Widget chama um único método
void main() async {
  final checkout = CheckoutFacade();

  final resultado = await checkout.finalizar(
    itens: [{'id': 'prod_1', 'quantidade': 2}],
    total: 299.90,
    metodo: 'pix',
    email: 'joao@email.com',
  );

  print(resultado.sucesso
      ? 'Pedido ${resultado.pedidoId} confirmado!'
      : 'Erro: ${resultado.erro}');
}
```

### ⚠️ Pergunta de Entrevista

> **"Qual a diferença entre Facade e Adapter?"**

**Resposta esperada:**
- **Facade:** Simplifica uma interface complexa. Você cria uma camada mais simples em cima de subsistemas que já existem.
- **Adapter:** Converte uma interface para outra que o cliente espera. Resolve incompatibilidade entre duas interfaces existentes.
- **Facade** = simplifica / **Adapter** = traduz
- Exemplo: Facade é o controle remoto que simplifica TV+Som+Streaming. Adapter é o conversor de tomada que traduz 110V para 220V.

### 📝 Exercício 11

Crie um `AppInitializerFacade` que encapsule a inicialização sequencial de:
- `FirebaseService.initialize()`
- `CrashReportService.initialize()`
- `AnalyticsService.initialize()`
- `NotificationService.requestPermission()`

O método `initialize()` deve chamar todos na ordem correta e retornar quando tudo estiver pronto.

---

## 12. Decorator

### O que é?
Adiciona comportamento a um objeto dinamicamente, sem alterar sua classe original. É uma alternativa à herança para estender funcionalidades em tempo de execução.

### Quando usar em Flutter?
- Adicionar logging transparente a um repositório
- Adicionar cache a um serviço sem mudar a implementação original
- Adicionar retry automático a chamadas HTTP
- Adicionar autenticação (headers) a requisições

### Exemplo Ilustrativo

```dart
// Interface base
abstract class Cafe {
  String get descricao;
  double get preco;
}

// Componente concreto (o objeto base)
class CafeSimples implements Cafe {
  @override String get descricao => 'Café';
  @override double get preco => 5.0;
}

// Decoradores: envolvem o objeto e adicionam comportamento
class ComLeite implements Cafe {
  final Cafe _cafe;
  ComLeite(this._cafe);
  @override String get descricao => '${_cafe.descricao} + Leite';
  @override double get preco => _cafe.preco + 2.0;
}

class ComChocolate implements Cafe {
  final Cafe _cafe;
  ComChocolate(this._cafe);
  @override String get descricao => '${_cafe.descricao} + Chocolate';
  @override double get preco => _cafe.preco + 3.0;
}

class ComChantilly implements Cafe {
  final Cafe _cafe;
  ComChantilly(this._cafe);
  @override String get descricao => '${_cafe.descricao} + Chantilly';
  @override double get preco => _cafe.preco + 4.0;
}

void main() {
  // Empilha decoradores como quiser — sem criar subclasses novas
  Cafe pedido = CafeSimples();
  print('${pedido.descricao}: R\$ ${pedido.preco}'); // Café: R$ 5.0

  pedido = ComLeite(pedido);
  print('${pedido.descricao}: R\$ ${pedido.preco}'); // Café + Leite: R$ 7.0

  pedido = ComChocolate(ComLeite(CafeSimples()));
  print('${pedido.descricao}: R\$ ${pedido.preco}'); // Café + Leite + Chocolate: R$ 10.0

  pedido = ComChantilly(ComChocolate(ComLeite(CafeSimples())));
  print('${pedido.descricao}: R\$ ${pedido.preco}'); // Café + Leite + Chocolate + Chantilly: R$ 14.0
}
```

### Exemplo Real: Repository com Logging e Cache

```dart
abstract class ProdutoRepository {
  Future<List<Produto>> buscarTodos();
}

class Produto {
  final String id;
  final String nome;
  Produto({required this.id, required this.nome});
  @override String toString() => nome;
}

// Implementação base: vai na API
class ApiProdutoRepository implements ProdutoRepository {
  @override
  Future<List<Produto>> buscarTodos() async {
    await Future.delayed(Duration(milliseconds: 500));
    return [Produto(id: '1', nome: 'Notebook'), Produto(id: '2', nome: 'Mouse')];
  }
}

// Decorador 1: adiciona logging
class LoggingProdutoRepository implements ProdutoRepository {
  final ProdutoRepository _repo;
  LoggingProdutoRepository(this._repo);

  @override
  Future<List<Produto>> buscarTodos() async {
    print('[LOG] Buscando produtos...');
    final resultado = await _repo.buscarTodos();
    print('[LOG] ${resultado.length} produtos encontrados');
    return resultado;
  }
}

// Decorador 2: adiciona cache em memória
class CacheProdutoRepository implements ProdutoRepository {
  final ProdutoRepository _repo;
  List<Produto>? _cache;
  CacheProdutoRepository(this._repo);

  @override
  Future<List<Produto>> buscarTodos() async {
    if (_cache != null) {
      print('[CACHE] Retornando do cache');
      return _cache!;
    }
    _cache = await _repo.buscarTodos();
    return _cache!;
  }
}

// Empilha: API → Logging → Cache
void main() async {
  ProdutoRepository repo = ApiProdutoRepository();
  repo = LoggingProdutoRepository(repo);
  repo = CacheProdutoRepository(repo);

  print('--- 1ª busca (vai na API) ---');
  await repo.buscarTodos();

  print('\n--- 2ª busca (vem do cache) ---');
  await repo.buscarTodos();
}
```

**Saída:**
```
--- 1ª busca (vai na API) ---
[LOG] Buscando produtos...
[LOG] 2 produtos encontrados

--- 2ª busca (vem do cache) ---
[CACHE] Retornando do cache
```

### ⚠️ Pergunta de Entrevista

> **"Qual a diferença entre Decorator e herança?"**

**Resposta esperada:**
- **Herança:** Comportamento definido em tempo de **compilação**. Cada combinação de funcionalidades exige uma subclasse nova.
- **Decorator:** Comportamento adicionado em tempo de **execução**. Você empilha camadas livremente sem criar novas classes.
- Com herança, para `CaféComLeiteEChocolate` você precisaria de uma subclasse específica — as combinações explodem (problema da explosão de subclasses).
- Com Decorator: `ComChocolate(ComLeite(CafeSimples()))` — combinações ilimitadas com poucas classes.
- Segue o princípio **Aberto/Fechado**: aberto para extensão, fechado para modificação.

### 📝 Exercício 12

Crie decoradores para um `HttpClient`:
```dart
abstract class HttpClient {
  Future<String> get(String url);
}
```
Implemente:
- `LoggingHttpClient`: loga a URL e o tempo de resposta em ms
- `RetryHttpClient(maxTentativas: 3)`: tenta novamente em caso de erro
- `AuthHttpClient(token: String)`: adiciona `Authorization: Bearer <token>` à requisição

---

## Tabela Comparativa

| Pattern | Tipo | Complexidade | Quando Usar | Alternativa |
|---------|------|--------------|-------------|-------------|
| **Singleton** | Criacional | Baixa | Instância única global | GetIt, Provider |
| **Factory** | Criacional | Baixa | Criar objetos dinamicamente | Construtor nomeado |
| **Builder** | Criacional | Média | Objetos com muitos params | Named parameters |
| **Observer** | Comportamental | Média | Reatividade, notificações | Streams, Riverpod |
| **Provider** | Estrutural | Baixa | Injeção de dependências | GetIt, Riverpod |
| **Repository** | Estrutural | Média | Abstração de dados | - |
| **BLoC** | Comportamental | Alta | Apps complexos | Provider, Riverpod |
| **State** | Comportamental | Média | Máquina de estados | Enum + switch |
| **Adapter** | Estrutural | Baixa | APIs externas | Extension methods |
| **Strategy** | Comportamental | Baixa | Algoritmos intercambiáveis | Funções de alta ordem |
| **Facade** | Estrutural | Baixa | Simplificar subsistemas complexos | - |
| **Decorator** | Estrutural | Média | Adicionar comportamento dinamicamente | Mixins |

---

## Gabarito dos Exercícios

### Exercício 1 - Singleton (SettingsService)

```dart
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  
  SettingsService._internal();
  
  factory SettingsService() => _instance;
  
  bool _isDarkTheme = false;
  String _language = 'pt-BR';
  
  bool get isDarkTheme => _isDarkTheme;
  String get language => _language;
  
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
  }
  
  void setLanguage(String lang) {
    _language = lang;
  }
}
```

---

### Exercício 2 - Factory (PaymentMethodFactory)

```dart
abstract class PaymentMethod {
  Future<bool> processPayment(double amount);
  String get name;
}

class PixPayment implements PaymentMethod {
  final String pixKey;
  
  PixPayment({required this.pixKey});
  
  @override
  Future<bool> processPayment(double amount) async {
    print('Processando Pix de R\$ $amount para $pixKey');
    return true;
  }
  
  @override
  String get name => 'Pix';
  
  factory PixPayment.fromJson(Map<String, dynamic> json) {
    return PixPayment(pixKey: json['pix_key']);
  }
}

class CardPayment implements PaymentMethod {
  final String cardNumber;
  final String cvv;
  final String expiry;
  
  CardPayment({
    required this.cardNumber,
    required this.cvv,
    required this.expiry,
  });
  
  @override
  Future<bool> processPayment(double amount) async {
    print('Processando cartão ${cardNumber.substring(0, 4)}**** R\$ $amount');
    return true;
  }
  
  @override
  String get name => 'Cartão';
  
  factory CardPayment.fromJson(Map<String, dynamic> json) {
    return CardPayment(
      cardNumber: json['card_number'],
      cvv: json['cvv'],
      expiry: json['expiry'],
    );
  }
}

class BoletoPayment implements PaymentMethod {
  final String barcode;
  
  BoletoPayment({required this.barcode});
  
  @override
  Future<bool> processPayment(double amount) async {
    print('Gerando boleto de R\$ $amount');
    return true;
  }
  
  @override
  String get name => 'Boleto';
  
  factory BoletoPayment.fromJson(Map<String, dynamic> json) {
    return BoletoPayment(barcode: json['barcode'] ?? '');
  }
}

class PaymentMethodFactory {
  static PaymentMethod fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'pix':
        return PixPayment.fromJson(json);
      case 'card':
        return CardPayment.fromJson(json);
      case 'boleto':
        return BoletoPayment.fromJson(json);
      default:
        throw ArgumentError('Tipo de pagamento desconhecido: $type');
    }
  }
}
```

---

### Exercício 3 - Builder (HttpRequestBuilder)

```dart
enum HttpMethod { get, post, put, delete }

class HttpRequest {
  final String url;
  final HttpMethod method;
  final Map<String, String> headers;
  final Map<String, dynamic>? body;
  final Duration timeout;
  
  HttpRequest._({
    required this.url,
    required this.method,
    required this.headers,
    this.body,
    required this.timeout,
  });
}

class HttpRequestBuilder {
  String? _url;
  HttpMethod _method = HttpMethod.get;
  final Map<String, String> _headers = {};
  Map<String, dynamic>? _body;
  Duration _timeout = Duration(seconds: 30);
  
  HttpRequestBuilder url(String url) {
    _url = url;
    return this;
  }
  
  HttpRequestBuilder method(HttpMethod method) {
    _method = method;
    return this;
  }
  
  HttpRequestBuilder get() => method(HttpMethod.get);
  HttpRequestBuilder post() => method(HttpMethod.post);
  HttpRequestBuilder put() => method(HttpMethod.put);
  HttpRequestBuilder delete() => method(HttpMethod.delete);
  
  HttpRequestBuilder header(String key, String value) {
    _headers[key] = value;
    return this;
  }
  
  HttpRequestBuilder contentType(String type) {
    return header('Content-Type', type);
  }
  
  HttpRequestBuilder authorization(String token) {
    return header('Authorization', 'Bearer $token');
  }
  
  HttpRequestBuilder body(Map<String, dynamic> body) {
    _body = body;
    return this;
  }
  
  HttpRequestBuilder timeout(Duration timeout) {
    _timeout = timeout;
    return this;
  }
  
  HttpRequest build() {
    if (_url == null) {
      throw StateError('URL é obrigatória');
    }
    
    return HttpRequest._(
      url: _url!,
      method: _method,
      headers: Map.unmodifiable(_headers),
      body: _body,
      timeout: _timeout,
    );
  }
}

// Uso
final request = HttpRequestBuilder()
    .url('https://api.example.com/users')
    .post()
    .contentType('application/json')
    .authorization('my-token')
    .body({'name': 'João', 'email': 'joao@email.com'})
    .timeout(Duration(seconds: 10))
    .build();
```

---

### Exercício 4 - Observer (ThemeNotifier)

```dart
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get currentTheme => _isDarkMode 
      ? ThemeData.dark() 
      : ThemeData.light();
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _savePreference();
    notifyListeners();
  }
  
  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      _savePreference();
      notifyListeners();
    }
  }
  
  Future<void> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
  
  Future<void> _savePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}

// Uso no MaterialApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          theme: themeNotifier.currentTheme,
          home: HomePage(),
        );
      },
    );
  }
}
```

---

### Exercício 5 - Provider (MultiProvider Setup)

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. AuthService (Singleton-like)
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        
        // 2. AuthNotifier (depende de AuthService)
        ChangeNotifierProxyProvider<AuthService, AuthNotifier>(
          create: (_) => AuthNotifier(),
          update: (_, authService, authNotifier) {
            return authNotifier!..authService = authService;
          },
        ),
        
        // 3. UserNotifier (depende de AuthNotifier)
        ChangeNotifierProxyProvider<AuthNotifier, UserNotifier>(
          create: (_) => UserNotifier(),
          update: (_, authNotifier, userNotifier) {
            return userNotifier!..authNotifier = authNotifier;
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}

class AuthService {
  Future<String> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    return 'jwt_token_123';
  }
  
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 500));
  }
}

class AuthNotifier extends ChangeNotifier {
  AuthService? authService;
  
  String? _token;
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  
  Future<void> login(String email, String password) async {
    _token = await authService!.login(email, password);
    notifyListeners();
  }
  
  Future<void> logout() async {
    await authService!.logout();
    _token = null;
    notifyListeners();
  }
}

class UserNotifier extends ChangeNotifier {
  AuthNotifier? authNotifier;
  
  User? _user;
  User? get user => _user;
  
  Future<void> loadUser() async {
    if (authNotifier?.isAuthenticated ?? false) {
      // Carrega usuário usando o token
      _user = User(id: '1', name: 'João', email: 'joao@email.com');
      notifyListeners();
    }
  }
  
  void clear() {
    _user = null;
    notifyListeners();
  }
}
```

---

### Exercício 6 - Repository (OrderRepository)

```dart
abstract class OrderRepository {
  Future<List<Order>> getOrders({bool forceRefresh = false});
}

class OrderRepositoryImpl implements OrderRepository {
  final ApiService _api;
  final LocalStorage _storage;
  
  List<Order>? _cache;
  DateTime? _cacheTime;
  final Duration _cacheDuration = Duration(minutes: 10);
  
  OrderRepositoryImpl({
    required ApiService api,
    required LocalStorage storage,
  })  : _api = api,
        _storage = storage;
  
  @override
  Future<List<Order>> getOrders({bool forceRefresh = false}) async {
    // 1. Verifica cache em memória
    if (!forceRefresh && _isCacheValid()) {
      return _cache!;
    }
    
    // 2. Tenta cache local
    if (!forceRefresh) {
      final localOrders = await _loadFromLocal();
      if (localOrders != null) {
        _cache = localOrders;
        return localOrders;
      }
    }
    
    // 3. Busca da API
    try {
      final orders = await _fetchFromApi();
      _cache = orders;
      _cacheTime = DateTime.now();
      await _saveToLocal(orders);
      return orders;
    } catch (e) {
      // 4. Fallback para cache se API falhar
      if (_cache != null) {
        return _cache!;
      }
      rethrow;
    }
  }
  
  bool _isCacheValid() {
    return _cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration;
  }
  
  Future<List<Order>?> _loadFromLocal() async {
    final data = await _storage.get('orders');
    if (data == null) return null;
    
    final cachedAt = DateTime.parse(data['cached_at']);
    if (DateTime.now().difference(cachedAt) > _cacheDuration) {
      return null;
    }
    
    _cacheTime = cachedAt;
    return (data['items'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }
  
  Future<List<Order>> _fetchFromApi() async {
    final response = await _api.get('/orders');
    return (response['items'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }
  
  Future<void> _saveToLocal(List<Order> orders) async {
    await _storage.set('orders', {
      'items': orders.map((o) => o.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    });
  }
}
```

---

### Exercício 7 - BLoC (SearchBloc com Debounce)

```dart
// Events
abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class SearchSubmitted extends SearchEvent {}

// States
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SearchResult> results;
  SearchLoaded(this.results);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

// BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _repository;
  
  SearchBloc({required SearchRepository repository})
      : _repository = repository,
        super(SearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounce(Duration(milliseconds: 300)),
    );
    on<SearchSubmitted>(_onSubmitted);
  }
  
  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    
    emit(SearchLoading());
    
    try {
      final results = await _repository.search(event.query);
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
  
  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    // Força busca imediata
    if (state is SearchLoaded) {
      // Já tem resultados
      return;
    }
  }
}

// Transformer para debounce
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) {
    return events
        .debounceTime(duration)
        .asyncExpand(mapper);
  };
}

class SearchResult {
  final String id;
  final String title;
  
  SearchResult({required this.id, required this.title});
}

abstract class SearchRepository {
  Future<List<SearchResult>> search(String query);
}
```

---

### Exercício 8 - State (Semáforo)

```dart
abstract class TrafficLightState {
  Color get color;
  int get durationSeconds;
  TrafficLightState next();
}

class RedState implements TrafficLightState {
  @override
  Color get color => Colors.red;
  
  @override
  int get durationSeconds => 30;
  
  @override
  TrafficLightState next() => GreenState();
}

class YellowState implements TrafficLightState {
  @override
  Color get color => Colors.yellow;
  
  @override
  int get durationSeconds => 5;
  
  @override
  TrafficLightState next() => RedState();
}

class GreenState implements TrafficLightState {
  @override
  Color get color => Colors.green;
  
  @override
  int get durationSeconds => 25;
  
  @override
  TrafficLightState next() => YellowState();
}

class TrafficLight extends ChangeNotifier {
  TrafficLightState _state = RedState();
  int _remainingSeconds = 30;
  Timer? _timer;
  
  TrafficLightState get state => _state;
  Color get color => _state.color;
  int get remainingSeconds => _remainingSeconds;
  
  void start() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _remainingSeconds--;
      
      if (_remainingSeconds <= 0) {
        _state = _state.next();
        _remainingSeconds = _state.durationSeconds;
      }
      
      notifyListeners();
    });
  }
  
  void stop() {
    _timer?.cancel();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

---

### Exercício 9 - Adapter (WeatherAdapter)

```dart
// Modelo do app
class Weather {
  final double temperatureCelsius;
  final String description;
  final String iconUrl;
  final int humidity;
  
  Weather({
    required this.temperatureCelsius,
    required this.description,
    required this.iconUrl,
    required this.humidity,
  });
}

// API OpenWeatherMap retorna isso:
// {
//   "main": {"temp": 293.15, "humidity": 65},
//   "weather": [{"description": "cloudy", "icon": "04d"}]
// }

class OpenWeatherMapApi {
  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    // Simula resposta da API
    return {
      'main': {'temp': 293.15, 'humidity': 65},
      'weather': [{'description': 'nublado', 'icon': '04d'}],
    };
  }
}

// Adapter
class WeatherAdapter {
  final OpenWeatherMapApi _api;
  
  WeatherAdapter(this._api);
  
  Future<Weather> getWeather(String city) async {
    final data = await _api.getCurrentWeather(city);
    
    // Converte Kelvin para Celsius
    final kelvin = data['main']['temp'] as double;
    final celsius = kelvin - 273.15;
    
    // Extrai dados do weather
    final weatherData = (data['weather'] as List).first;
    final description = weatherData['description'] as String;
    final iconCode = weatherData['icon'] as String;
    
    // Monta URL do ícone
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';
    
    return Weather(
      temperatureCelsius: celsius,
      description: description,
      iconUrl: iconUrl,
      humidity: data['main']['humidity'] as int,
    );
  }
}
```

---

### Exercício 10 - Strategy (Sistema de Desconto)

```dart
abstract class DiscountStrategy {
  double apply(double price, int quantity);
  String get description;
}

class PercentageDiscount implements DiscountStrategy {
  final double percent;
  
  PercentageDiscount(this.percent);
  
  @override
  double apply(double price, int quantity) {
    final total = price * quantity;
    return total * (1 - percent / 100);
  }
  
  @override
  String get description => '$percent% de desconto';
}

class FixedDiscount implements DiscountStrategy {
  final double amount;
  
  FixedDiscount(this.amount);
  
  @override
  double apply(double price, int quantity) {
    final total = price * quantity;
    return (total - amount).clamp(0, double.infinity);
  }
  
  @override
  String get description => 'R\$ $amount de desconto';
}

class BuyXGetYDiscount implements DiscountStrategy {
  final int buyQty;
  final int freeQty;
  
  BuyXGetYDiscount({required this.buyQty, required this.freeQty});
  
  @override
  double apply(double price, int quantity) {
    // Calcula quantos "grupos" completos de (buyQty + freeQty)
    final groupSize = buyQty + freeQty;
    final groups = quantity ~/ groupSize;
    final remainder = quantity % groupSize;
    
    // Itens pagos = grupos * buyQty + resto (até buyQty)
    final paidItems = groups * buyQty + remainder.clamp(0, buyQty);
    
    return price * paidItems;
  }
  
  @override
  String get description => 'Leve $buyQty, pague ${buyQty - freeQty}';
}

// Uso
class ShoppingCart {
  final List<CartItem> items = [];
  DiscountStrategy? _discount;
  
  void setDiscount(DiscountStrategy discount) {
    _discount = discount;
  }
  
  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  
  double get total {
    if (_discount == null) return subtotal;
    
    return items.fold(0, (sum, item) {
      return sum + _discount!.apply(item.price, item.quantity);
    });
  }
  
  double get savings => subtotal - total;
}

// Exemplo de uso:
void main() {
  final cart = ShoppingCart();
  cart.items.add(CartItem(price: 100, quantity: 3));
  
  // Teste com 10% de desconto
  cart.setDiscount(PercentageDiscount(10));
  print('Total com 10%: ${cart.total}'); // 270
  
  // Teste com R$ 50 fixo
  cart.setDiscount(FixedDiscount(50));
  print('Total com R\$50: ${cart.total}'); // 250
  
  // Teste com Leve 3 Pague 2
  cart.setDiscount(BuyXGetYDiscount(buyQty: 2, freeQty: 1));
  print('Total L3P2: ${cart.total}'); // 200
}

class CartItem {
  final double price;
  final int quantity;
  
  CartItem({required this.price, required this.quantity});
  
  double get total => price * quantity;
}
```

---

### Exercício 11 - Facade (AppInitializerFacade)

```dart
class FirebaseService {
  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 300));
    print('Firebase inicializado');
  }
}

class CrashReportService {
  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 200));
    print('Crashlytics inicializado');
  }
}

class AnalyticsService {
  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 150));
    print('Analytics inicializado');
  }
}

class NotificationService {
  Future<void> requestPermission() async {
    await Future.delayed(Duration(milliseconds: 100));
    print('Permissão de push concedida');
  }
}

class AppInitializerFacade {
  final _firebase = FirebaseService();
  final _crashReport = CrashReportService();
  final _analytics = AnalyticsService();
  final _notification = NotificationService();

  Future<void> initialize() async {
    await _firebase.initialize();     // deve ser o primeiro
    await _crashReport.initialize();  // depende do Firebase
    await _analytics.initialize();
    await _notification.requestPermission();
    print('App pronto para uso!');
  }
}

void main() async {
  await AppInitializerFacade().initialize();
}
```

---

### Exercício 12 - Decorator (HttpClient)

```dart
abstract class HttpClient {
  Future<String> get(String url);
}

class SimpleHttpClient implements HttpClient {
  @override
  Future<String> get(String url) async {
    await Future.delayed(Duration(milliseconds: 400));
    return '{"status": "ok"}';
  }
}

class LoggingHttpClient implements HttpClient {
  final HttpClient _client;
  LoggingHttpClient(this._client);

  @override
  Future<String> get(String url) async {
    final stopwatch = Stopwatch()..start();
    print('[LOG] GET $url');
    final response = await _client.get(url);
    stopwatch.stop();
    print('[LOG] Respondeu em ${stopwatch.elapsedMilliseconds}ms');
    return response;
  }
}

class RetryHttpClient implements HttpClient {
  final HttpClient _client;
  final int maxTentativas;
  RetryHttpClient(this._client, {this.maxTentativas = 3});

  @override
  Future<String> get(String url) async {
    for (int tentativa = 1; tentativa <= maxTentativas; tentativa++) {
      try {
        return await _client.get(url);
      } catch (e) {
        if (tentativa == maxTentativas) rethrow;
        print('[RETRY] Tentativa $tentativa falhou. Tentando novamente...');
      }
    }
    throw Exception('Todas as tentativas falharam');
  }
}

class AuthHttpClient implements HttpClient {
  final HttpClient _client;
  final String token;
  AuthHttpClient(this._client, {required this.token});

  @override
  Future<String> get(String url) async {
    print('[AUTH] Bearer ${token.substring(0, 8)}...');
    return _client.get(url);
  }
}

void main() async {
  HttpClient client = SimpleHttpClient();
  client = RetryHttpClient(client, maxTentativas: 3);
  client = AuthHttpClient(client, token: 'jwt_token_secreto');
  client = LoggingHttpClient(client);

  await client.get('https://api.example.com/products');
}
```

---

## Referências

- [Flutter Documentation](https://docs.flutter.dev/)
- [Refactoring Guru - Design Patterns](https://refactoring.guru/design-patterns)
- [BLoC Library](https://bloclibrary.dev/)
- [Provider Package](https://pub.dev/packages/provider)

---

## Dicas para Entrevista

1. **Não decore**, entenda o problema que cada pattern resolve
2. **Saiba quando NÃO usar** - overengineering é comum
3. **Conheça alternativas** - Flutter tem formas nativas de resolver alguns problemas
4. **Pratique explicar** - whiteboard coding é comum
5. **Tenha exemplos reais** - "usei X no projeto Y para resolver Z"

---

**Boa sorte na entrevista!** 🚀
