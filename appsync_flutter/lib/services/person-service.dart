import 'package:appsync_flutter/exceptions/graphql-exception.dart';
import 'package:appsync_flutter/models/person.dart';
import 'package:appsync_flutter/services/crud-service.dart';
import 'package:appsync_flutter/utils/graphql-client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class PersonService extends CrudService<Person> {

  PersonService._privateConstructor();

  static final PersonService instance = PersonService._privateConstructor();

  static final GraphQL graphQLinstance = GraphQL.instance;

  getTableName() {
    return 'people';
  }

  Future<void> savePerson(Person person) async {
    var map = person.toMap();
    MutationOptions query = MutationOptions(
        document: gql(
          '''mutation savePerson(\$input: SavePerson!) {
              savePerson(input: \$input) {
                  id
                  last_modified
                  name
              }
            }
            ''',
        ),
        variables: {'input': map});
    var result = await graphQLinstance.client.mutate(query);
    if (result.exception != null && result.exception.graphqlErrors.length > 0) {
      throw new GraphQLException(result.exception.graphqlErrors[0].message);
    }
  }

  Future<List<Person>> getPersonGraphQL({DateTime datetime}) async {
    QueryOptions query = QueryOptions(
      document: gql(
        '''query {
            listPeople(filter: {${datetime != null ? 'last_modified: {gt: "${datetime.toUtc().toIso8601String()}"}' : 'deleted: {eq: false}'}}) {
              items {
                  id
                  last_modified
                  name
                  deleted
              }
            }
          }
          ''',
      ),
    );
    var result = await graphQLinstance.client.query(query);
    if (result.exception != null && result.exception.graphqlErrors.length > 0) {
      throw new Exception(result.exception.graphqlErrors[0].message);
    }
    List<dynamic> people = result.data['listPeople']['items'];
    if (people != null && people.length > 0) {
      return people.map((e) => Person().fromMap(e) as Person).toList();
    }
    return [];
  }
}