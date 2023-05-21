import 'package:flutter/material.dart';
import 'util/dbhelper.dart';
import './models/list_items.dart';
import './models/shopping_list.dart';
import './ui/items_screen.dart';
import './ui/shopping_list_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ShList());
  }
}

//this is the shlist class

class ShList extends StatefulWidget {
  @override
  _ShListState createState() => _ShListState();
}

class _ShListState extends State<ShList> {
  DbHelper helper = DbHelper();
  List<ShoppingList>? shoppingList;
  ShoppingListDialog? dialog;
  @override
  void initState() {
    dialog = ShoppingListDialog();
    super.initState();
  }

  Future showData() async {
    await helper.openDb();

    shoppingList = await helper.getLists();

    setState(() {
      shoppingList = shoppingList;
    });
  }

  @override
  Widget build(BuildContext context) {
    showData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Shopping List"),
      ),
      body: ListView.builder(
        itemCount: (shoppingList != null) ? shoppingList!.length : 0,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    10.0), // Set the desired border radius
                color: Colors.blue, // Set the desired background color here
              ),
              child: Dismissible(
                key: Key(shoppingList![index].name),
                onDismissed: (direction) {
                  String strName = shoppingList![index].name;
                  helper.deleteList(shoppingList![index]);

                  setState(() {
                    shoppingList!.removeAt(index);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$strName deleted")));
                },
                child: ListTile(
                    title: Text(shoppingList![index].name),
                    leading: CircleAvatar(
                      child: Text(shoppingList![index].priority.toString()),
                      backgroundColor: Colors.black,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ItemsScreen(shoppingList![index])),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => dialog!
                                .buildDialog(
                                    context, shoppingList![index], false));
                      },
                    )),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialog!.buildDialog(context, ShoppingList(0, '', 0), true),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
