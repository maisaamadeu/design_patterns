import 'dart:async';

void runBlocExample() {
  print("\n--- BLoC (Business Logic Component) ---");

  print(
      "\nO que é? O padrão BLoC (Business Logic Component) é uma abordagem para gerenciar o estado e a lógica de negócios em aplicativos Flutter. Ele separa a lógica de negócios da interface do usuário, tornando o código mais modular, testável e reutilizável. O BLoC utiliza Streams para gerenciar eventos e estados, permitindo que os widgets reajam às mudanças de estado de forma eficiente.\n");

  final bloc = SearchBloc();

  bloc.states.listen((state) {
    switch (state) {
      case SearchInitial():
        print("Estado inicial: Nenhuma busca realizada.");
        break;

      case SearchLoading():
        print("Carregando resultados...");
        break;
      case SearchLoaded():
        print("Resultados carregados: ${state.results}");
        break;
      case SearchError():
        print("Erro ao buscar resultados: ${state.message}");
        break;
    }
  });

  bloc.addEvent(SearchQueryChanged("flutter"));

  Future.delayed(const Duration(seconds: 5), () {
    bloc.dispose();
  });
}

sealed class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<String> results;

  SearchLoaded(this.results);
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}

sealed class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;

  SearchQueryChanged(this.query);
}

class SearchBloc {
  final _events = StreamController<SearchEvent>();
  final _states = StreamController<SearchState>.broadcast();

  Stream<SearchState> get states => _states.stream;

  SearchBloc() {
    _events.stream.listen(_handleEvent);
    _states.add(SearchInitial());
  }

  void addEvent(SearchEvent event) {
    _events.add(event);
  }

  Future<void> _handleEvent(SearchEvent event) async {
    switch (event) {
      case SearchQueryChanged():
        print("Buscando resultados para a query: ${event.query}");
        _states.add(SearchLoading());
        try {
          await Future.delayed(const Duration(seconds: 2));
          final results = ['A', 'B', 'C'];
          _states.add(SearchLoaded(results));
        } catch (e) {
          _states.add(SearchError("Erro ao buscar resultados"));
        }
        break;
    }
  }

  void dispose() {
    print("Descartando BLoC e fechando streams...");
    _events.close();
    _states.close();
  }
}
