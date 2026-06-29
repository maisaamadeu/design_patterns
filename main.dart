import 'adapter.dart';
import 'bloc.dart';
import 'builder.dart';
import 'factory_method.dart';
import 'observer.dart';
import 'provider.dart';
import 'repository.dart';
import 'singleton.dart';
import 'state.dart';
import 'strategy.dart';

void main() async {
  print("--- Padrões de Projeto em Dart ---");
  runSingletonExample();
  runFactoryMethodExample();
  runBuilderExample();
  runObserverExample();
  runProviderExample();
  await runRepositoryExample();
  runStateExample();
  runAdapterExample();
  runStrategyExample();
  runBlocExample();
}
