import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ListOfNotesWidget.dart';
import 'package:search_widget/search_widget.dart';

import 'Search.dart';

class Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        bottomNavigationBar: Material(
          color: Theme.of(context).colorScheme.primary,
          child: TabBar(tabs: const <Widget>[
            Tab(icon: Icon(Icons.note_add)),
            Tab(icon: Icon(Icons.list_alt_rounded)),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: Text('Add a note'),
            ),
            Center(
              child: Search().build(context),
            )
          ],
        ),
      ),
    );
  }
}
