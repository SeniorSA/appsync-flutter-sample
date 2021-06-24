import 'package:appsync_flutter/models/person.dart';
import 'package:appsync_flutter/services/person-service.dart';
import 'package:flutter/material.dart';

class PeopleForm extends StatefulWidget {
  final Person person;

  const PeopleForm({Key key, this.person}) : super(key: key);

  @override
  _PeopleFormState createState() => _PeopleFormState();
}

class _PeopleFormState extends State<PeopleForm> {
  final nameController = TextEditingController();
  final PersonService personService = PersonService.instance;

  @override
  initState() {
    super.initState();
    final person = widget.person;

    /// Condição para a tela em caso de update ou create
    if (person != null) {
      nameController.value = TextEditingValue(text: person.name);
    }
  }

  _onSave() async {
    var person = Person(name: nameController.text);
    if (widget.person != null) {
      person.id = widget.person.id;
      person.deleted = widget.person.deleted;
      await personService.update(person);
    } else {
      await personService.insert(person);
    }
    Navigator.pop(context);
  }

  _delete() async {
    await personService.delete(widget.person);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.person != null ? "Edit" : "Register") + " person"),
        actions: [
          Visibility(
            visible: widget.person != null,
            child: Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: _delete,
                child: Icon(
                  Icons.delete,
                  size: 26.0,
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Type your name'),
              controller: nameController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _onSave,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
