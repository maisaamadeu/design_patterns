Future<void> runRepositoryExample() async {
  print("\n--- Repository ---");

  print(
      "\nO que é? O padrão Repository atua como uma camada intermediária entre a aplicação e a fonte de dados, fornecendo uma interface para acessar e manipular os dados. Ele ajuda a separar a lógica de negócios da lógica de acesso a dados, promovendo um código mais limpo e testável.\n");

  final orderRepository = OrderRepositoryImpl();

  final orders = await orderRepository.getOrders();
  print("Pedidos obtidos:");
  for (var order in orders) {
    print("ID: ${order.id}, Descrição: ${order.description}");
  }

  print("\nAguardando 5 segundos antes de buscar novamente...");
  await Future.delayed(const Duration(seconds: 5));
  print("\nBuscando pedidos novamente...");
  final orders2 = await orderRepository.getOrders();
  print("Pedidos obtidos:");
  for (var order in orders2) {
    print("ID: ${order.id}, Descrição: ${order.description}");
  }
}

abstract class OrderRepository {
  Future<List<Order>> getOrders();
}

class OrderRepositoryImpl implements OrderRepository {
  final Duration _cacheDuration = const Duration(seconds: 15);
  DateTime? _lastFetched;
  List<Order> _cachedOrders = [];

  @override
  Future<List<Order>> getOrders() async {
    if (_lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < _cacheDuration) {
      print("Retornando pedidos do cache...");
      return _cachedOrders;
    }

    print("Buscando pedidos da fonte de dados...");
    await Future.delayed(const Duration(seconds: 2));
    _lastFetched = DateTime.now();
    _cachedOrders = [
      Order(1, "Pedido 1"),
      Order(2, "Pedido 2"),
      Order(3, "Pedido 3"),
    ];
    return _cachedOrders;
  }
}

class Order {
  final int id;
  final String description;

  Order(this.id, this.description);
}
