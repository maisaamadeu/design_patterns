void runStrategyExample() {
  print("\n--- Strategy ---");

  print(
      "\nO que é? O padrão Strategy define uma família de algoritmos, encapsula cada um deles e os torna intercambiáveis. Ele permite que o algoritmo varie independentemente dos clientes que o utilizam, promovendo a flexibilidade e a extensibilidade do código.\n");

  final order = Order(100.0);

  print("Escolhendo a estratégia de pagamento: Cartão de Crédito");
  order.setPaymentStrategy(CreditCardPayment());
  order.pay();

  print("\nEscolhendo a estratégia de pagamento: PayPal");
  order.setPaymentStrategy(PayPalPayment());
  order.pay();
}

class Order {
  final double amount;
  PaymentStrategy? _paymentStrategy;

  Order(this.amount);

  void setPaymentStrategy(PaymentStrategy strategy) {
    _paymentStrategy = strategy;
  }

  void pay() {
    if (_paymentStrategy == null) {
      print("Nenhuma estratégia de pagamento selecionada.");
      return;
    }
    _paymentStrategy!.pay(amount);
  }
}

abstract class PaymentStrategy {
  void pay(double amount);
}

class CreditCardPayment implements PaymentStrategy {
  @override
  void pay(double amount) {
    print("Processando pagamento de R\$ $amount com Cartão de Crédito.");
  }
}

class PayPalPayment implements PaymentStrategy {
  @override
  void pay(double amount) {
    print("Processando pagamento de R\$ $amount com PayPal.");
  }
}
