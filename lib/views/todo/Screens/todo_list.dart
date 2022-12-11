import 'dart:io';

import 'package:flutter/material.dart';

import '../../../Utils/database_helper.dart';

void main() {
  runApp(const TodoList());
}

class TodoList extends StatelessWidget {
  const TodoList({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Auction3>> users;
  TextEditingController firstNameTextController = TextEditingController();
  TextEditingController lastNameTextController = TextEditingController();
  DatabaseHandler dbHandler = DatabaseHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future: users,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var usersList = snapshot.data as List<Auction3>;
                    return ListView.builder(
                        itemCount: usersList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Auction3 user = usersList[index];
                          return ListTile(
                            title: Text(user.sbjt),
                            trailing: IconButton(
                              onPressed: () {
                                dbHandler.deleteUser(user.aucNo);
                                initState();
                                setState(() {});
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          );
                        });
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ),
          SingleChildScrollView(
              child: Column(children: <Widget>[
            TextField(
              controller: firstNameTextController,
              decoration: const InputDecoration(hintText: 'fisrt name'),
            ),
            TextField(
              controller: lastNameTextController,
              decoration: const InputDecoration(hintText: 'Last name'),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: ElevatedButton(
                onPressed: () async {
                  Auction3 user = Auction3.empty();
                  user.sbjt = firstNameTextController.text.toString();
                  user.aucM1 = lastNameTextController.text.toString();
                  await dbHandler.insertUser(user);

                  initState();

                  setState(() {});
                },
                child: const Text('Save'),
              ),
            ),
            Row(children: const <Widget>[
              Expanded(
                  child: Divider(
                color: Colors.black,
              )),
            ]),
          ])),
        ],
      ),
    );
  }

  @override
  void initState() {
    users = this.getUsersLIst();
  }

  Future<List<Auction3>> getUsersLIst() async {
    return await DatabaseHandler().getAllUsers();
  }
}
