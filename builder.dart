void runBuilderExample() {
  print("\n--- Builder ---");

  print(
      "\nO que é? O padrão Builder separa a construção de um objeto complexo da sua representação, permitindo que o mesmo processo de construção crie diferentes representações. Ele é útil quando você precisa criar objetos com muitas opções de configuração, tornando o código mais legível e fácil de manter.\n");

  HttpRequest request = HttpRequestBuilder()
      .setUrl("https://api.example.com/data")
      .setMethod(HttpMethod.post)
      .setHeaders({"Content-Type": "application/json"})
      .setBody('{"key": "value"}')
      .setTimeout(Duration(seconds: 10))
      .build();
  print("HttpRequest construído: $request");
}

class HttpRequest {
  final String url;
  final HttpMethod method;
  final Map<String, String> headers;
  final String body;
  final Duration timeout;

  HttpRequest({
    required this.url,
    required this.method,
    required this.headers,
    required this.body,
    required this.timeout,
  });

  @override
  String toString() {
    return 'HttpRequest(url: $url, method: $method, headers: $headers, body: $body, timeout: $timeout)';
  }
}

enum HttpMethod { get, post, put, delete }

class HttpRequestBuilder {
  String _url = '';
  HttpMethod _method = HttpMethod.get;
  Map<String, String> _headers = {};
  String _body = '';
  Duration _timeout = const Duration(seconds: 30);

  HttpRequestBuilder setUrl(String url) {
    _url = url;
    return this;
  }

  HttpRequestBuilder setMethod(HttpMethod method) {
    _method = method;
    return this;
  }

  HttpRequestBuilder setHeaders(Map<String, String> headers) {
    _headers = headers;
    return this;
  }

  HttpRequestBuilder setBody(String body) {
    _body = body;
    return this;
  }

  HttpRequestBuilder setTimeout(Duration timeout) {
    _timeout = timeout;
    return this;
  }

  HttpRequest build() {
    return HttpRequest(
      url: _url,
      method: _method,
      headers: _headers,
      body: _body,
      timeout: _timeout,
    );
  }
}
