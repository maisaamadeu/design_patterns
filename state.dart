void runStateExample() {
  print("\n--- State ---");

  print(
      "\nO que é? O padrão State permite que um objeto altere seu comportamento quando seu estado interno muda. Ele encapsula os estados em classes separadas, promovendo a flexibilidade e a extensibilidade do código.\n");

  final order = Order();
  print("Status do pedido: ${order.statusText}");
  print("Pode cancelar? ${order.canCancel}");

  order.advance();
  print("Status do pedido: ${order.statusText}");
  print("Pode cancelar? ${order.canCancel}");

  order.advance();
  print("Status do pedido: ${order.statusText}");
  print("Pode cancelar? ${order.canCancel}");

  order.advance();
  print("Status do pedido: ${order.statusText}");
  print("Pode cancelar? ${order.canCancel}");

  order.cancel();
}

class Order {
  OrderState _state = PendingState();

  String get statusText => _state.statusText;
  bool get canCancel => _state.canCancel;

  void advance() {
    final next = _state.next();
    if (next != null) {
      _state = next;
    }
  }

  void cancel() {
    if (canCancel) {
      print("Pedido cancelado.");
      _state = CanceledState();
    } else {
      print("Não é possível cancelar o pedido no estado atual: $statusText");
    }
  }
}

abstract class OrderState {
  String get statusText;
  bool get canCancel;
  OrderState? next();
}

class PendingState extends OrderState {
  @override
  String get statusText => "Aguardando pagamento";

  @override
  bool get canCancel => true;

  @override
  OrderState? next() => PaidState();
}

class PaidState extends OrderState {
  @override
  String get statusText => "Pedido pago";

  @override
  bool get canCancel => false;

  @override
  OrderState? next() => ShippedState();
}

class ShippedState extends OrderState {
  @override
  String get statusText => "Pedido enviado";

  @override
  bool get canCancel => false;

  @override
  OrderState? next() => DeliveredState();
}

class DeliveredState extends OrderState {
  @override
  String get statusText => "Pedido entregue";

  @override
  bool get canCancel => false;

  @override
  OrderState? next() => null;
}

class CanceledState extends OrderState {
  @override
  String get statusText => "Pedido cancelado";

  @override
  bool get canCancel => false;

  @override
  OrderState? next() => null;
}
