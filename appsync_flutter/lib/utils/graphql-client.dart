import 'package:appsync_flutter/environment/enviroment.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQL {

  static final GraphQL instance = GraphQL._privateConstructor();

  factory GraphQL() {
    return instance;
  }

  GraphQL._privateConstructor();

  static GraphQLClient _client;

  GraphQLClient get client {
    if (_client != null) return _client;
    _client = _getClient();
    return _client;
  }

  GraphQLClient _getClient() {
    HttpLink httpLink = HttpLink(Environment.graphQLEndpoint);
    final AuthLink authLink = AuthLink(
        getToken: () => Environment.graphQLEndApiKey,
        headerKey: 'x-api-key');
    final Link link = authLink.concat(httpLink);
    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }
}
