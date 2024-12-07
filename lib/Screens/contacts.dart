import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List _contacts = [];
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body()
    );
  }
  Widget _body() {
    if (_permissionDenied) return const Center(child: Text('Permission denied'));
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(_contacts[i].displayName),
        onTap: () async {
          final fullContact = await FlutterContacts.getContact(_contacts[i].id);
        }
      )
    );
  }
}