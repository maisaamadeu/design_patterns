// Demonstração da resposta para a pergunta de entrevista:
// "Como você implementaria diferentes formas de pagamento usando Design Patterns?"
//
// Arquitetura:
//   Factory  →  cria a Strategy correta baseada no tipo
//   Strategy →  executa o pagamento (Pix, Cartão, Boleto)
//   Repository → persiste a transação (mockado em memória)
//
//   PaymentService orquestra os três sem que nenhum conheça os outros.

void main() async {
  final repository = InMemoryTransactionRepository();
  final service = PaymentService(repository: repository);

  await service.processar(
    tipo: 'pix',
    valor: 150.00,
    detalhes: {'chave': 'joao@email.com'},
  );

  await service.processar(
    tipo: 'card',
    valor: 299.90,
    detalhes: {'numero': '1234****5678', 'parcelas': 3},
  );

  await service.processar(
    tipo: 'boleto',
    valor: 89.99,
    detalhes: {},
  );

  print('\n─── Extrato de transações ───────────────────────');
  final transacoes = await repository.buscarTodas();
  for (final t in transacoes) {
    print(t);
  }
}

// ═══════════════════════════════════════════════════════════════
// STRATEGY — define a interface e as implementações de pagamento
// ═══════════════════════════════════════════════════════════════

abstract class PaymentStrategy {
  String get tipo;
  Future<PaymentResult> pay(double valor, Map<String, dynamic> detalhes);
}

class PixPayment implements PaymentStrategy {
  @override
  String get tipo => 'pix';

  @override
  Future<PaymentResult> pay(double valor, Map<String, dynamic> detalhes) async {
    await Future.delayed(Duration(milliseconds: 300));
    final chave = detalhes['chave'] ?? 'chave_pix';
    print('[PIX] Transferindo R\$ $valor para chave: $chave');
    return PaymentResult(
      sucesso: true,
      mensagem: 'Pix realizado para $chave',
      codigo: 'PIX${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

class CardPayment implements PaymentStrategy {
  @override
  String get tipo => 'card';

  @override
  Future<PaymentResult> pay(double valor, Map<String, dynamic> detalhes) async {
    await Future.delayed(Duration(milliseconds: 500));
    final numero = detalhes['numero'] ?? '****';
    final parcelas = (detalhes['parcelas'] ?? 1) as int;
    final parcela = valor / parcelas;
    print('[CARTÃO] ${parcelas}x de R\$ ${parcela.toStringAsFixed(2)} no cartão $numero');
    return PaymentResult(
      sucesso: true,
      mensagem: 'Aprovado em ${parcelas}x de R\$ ${parcela.toStringAsFixed(2)}',
      codigo: 'CRD${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

class BoletoPayment implements PaymentStrategy {
  @override
  String get tipo => 'boleto';

  @override
  Future<PaymentResult> pay(double valor, Map<String, dynamic> detalhes) async {
    await Future.delayed(Duration(milliseconds: 200));
    print('[BOLETO] Gerando boleto de R\$ $valor — vence em 3 dias úteis');
    return PaymentResult(
      sucesso: true,
      mensagem: 'Boleto gerado. Vencimento em 3 dias úteis.',
      codigo: 'BOL${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

class PaymentResult {
  final bool sucesso;
  final String mensagem;
  final String codigo;

  PaymentResult({
    required this.sucesso,
    required this.mensagem,
    required this.codigo,
  });
}

// ═══════════════════════════════════════════════════════════════
// FACTORY — cria a Strategy correta sem que o chamador saiba qual
// ═══════════════════════════════════════════════════════════════

class PaymentFactory {
  static PaymentStrategy create(String tipo) {
    switch (tipo) {
      case 'pix':    return PixPayment();
      case 'card':   return CardPayment();
      case 'boleto': return BoletoPayment();
      default:       throw ArgumentError('Tipo de pagamento desconhecido: $tipo');
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// REPOSITORY — persiste transações (mockado em memória)
// ═══════════════════════════════════════════════════════════════

class Transaction {
  final String id;
  final String tipo;
  final double valor;
  final String status;
  final String codigo;
  final DateTime criadoEm;

  Transaction({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.status,
    required this.codigo,
    required this.criadoEm,
  });

  @override
  String toString() =>
      '[${tipo.toUpperCase()}] R\$ ${valor.toStringAsFixed(2)} | $status | $codigo';
}

abstract class TransactionRepository {
  Future<void> salvar(Transaction transaction);
  Future<List<Transaction>> buscarTodas();
  Future<Transaction?> buscarPorId(String id);
}

class InMemoryTransactionRepository implements TransactionRepository {
  final _store = <String, Transaction>{};

  @override
  Future<void> salvar(Transaction transaction) async {
    _store[transaction.id] = transaction;
    print('[REPO] Transação salva: ${transaction.id}');
  }

  @override
  Future<List<Transaction>> buscarTodas() async => _store.values.toList();

  @override
  Future<Transaction?> buscarPorId(String id) async => _store[id];
}

// ═══════════════════════════════════════════════════════════════
// PAYMENT SERVICE — orquestra Factory + Strategy + Repository
// ═══════════════════════════════════════════════════════════════

class PaymentService {
  final TransactionRepository _repository;

  PaymentService({required TransactionRepository repository})
      : _repository = repository;

  Future<Transaction> processar({
    required String tipo,
    required double valor,
    Map<String, dynamic> detalhes = const {},
  }) async {
    // 1. Factory decide qual Strategy usar
    final strategy = PaymentFactory.create(tipo);

    // 2. Strategy executa o pagamento
    final result = await strategy.pay(valor, detalhes);

    // 3. Repository persiste a transação
    final transaction = Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      tipo: tipo,
      valor: valor,
      status: result.sucesso ? 'APROVADO' : 'RECUSADO',
      codigo: result.codigo,
      criadoEm: DateTime.now(),
    );

    await _repository.salvar(transaction);
    return transaction;
  }
}
