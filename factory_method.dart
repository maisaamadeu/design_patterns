void runFactoryMethodExample() {
  print("\n--- Factory Method ---");

  print(
      "\nO que é? O padrão Factory Method define uma interface para criar um objeto, mas permite que as subclasses decidam qual classe instanciar. Ele permite adiar a instanciação para subclasses, promovendo a flexibilidade e a extensibilidade do código.\n");

  final payments = [
    {
      'type': 'pix',
      'pix_key': '1234567890',
    },
    {
      'type': 'boleto',
      'barcode': '12345678901234567890',
    },
  ];

  for (var paymentData in payments) {
    final paymentMethod = PaymentMethodFactory.create(paymentData);
    paymentMethod.processPayment();
  }
}

abstract class PaymentMethodFactory {
  void processPayment();

  factory PaymentMethodFactory.create(Map<String, dynamic> paymentData) {
    switch (paymentData['type']) {
      case 'pix':
        return PixPaymentFactory(paymentData['pix_key']);
      case 'boleto':
        return BoletoPaymentFactory(paymentData['barcode']);
      default:
        throw Exception('Invalid payment method type');
    }
  }
}

class PixPaymentFactory implements PaymentMethodFactory {
  final String pixKey;

  PixPaymentFactory(this.pixKey);

  @override
  void processPayment() {
    print("Processando pagamento PIX com chave: $pixKey");
  }
}

class BoletoPaymentFactory implements PaymentMethodFactory {
  final String barcode;

  BoletoPaymentFactory(this.barcode);

  @override
  void processPayment() {
    print("Processando pagamento Boleto com código de barras: $barcode");
  }
}
