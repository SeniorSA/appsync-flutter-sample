import 'package:appsync_flutter/models/person.dart';
import 'package:appsync_flutter/services/person-service.dart';
import 'package:flutter/material.dart';

class PeopleList extends StatefulWidget {
  const PeopleList({Key key}) : super(key: key);

  @override
  _PeopleListState createState() => _PeopleListState();
}

class _PeopleListState extends State<PeopleList> {
  final PersonService personService = PersonService.instance;

  _onAdd(BuildContext context) {
    Navigator.pushNamed(context, '/register').then((value) => setState(() {}));
  }

  _edit(Person person) {
    Navigator.pushNamed(context, '/register', arguments: person)
        .then((value) => setState(() {}));
  }

  Future<void> _refreshStatus() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("People list"),
      ),
      body: FutureBuilder(
        future: personService.list(Person()),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data.length == 0) {
            return Container(
              child: Center(
                  child: Text(
                      'Nenhuma pessoa cadastrada, utilize o botão "+" no canto inferior direito para efetuar o registro.')),
              padding: EdgeInsets.all(25.0),
            );
          }
          return Container(
            child: RefreshIndicator(
              onRefresh: _refreshStatus,
              child: ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: snapshot.data.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.all(15),
                    child: GestureDetector(
                      child: Text(snapshot.data[index].name),
                      onTap: () => _edit(snapshot.data[index]),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_onAdd(context)},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
