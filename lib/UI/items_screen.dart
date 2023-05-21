import 'package:flutter/material.dart';
import '../models/list_items.dart';
import '../models/shopping_list.dart';
import '../util/dbhelper.dart';
import 'list_item_dialog.dart';

class ItemsScreen extends StatefulWidget {
  final ShoppingList shoppingList;
  ItemsScreen(this.shoppingList);

  @override
  State<ItemsScreen> createState() => _ItemsScreenState(this.shoppingList);
}

class _ItemsScreenState extends State<ItemsScreen> {
  final ShoppingList shoppingList;
  DbHelper? helper;
  List<ListItem>? items;
  _ItemsScreenState(this.shoppingList);

  Future showData(int idList) async {
    await helper!.openDb();
    items = await helper!.getItems(idList);
    setState(() {
      items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    ListItemDialog dialog = new ListItemDialog();

    helper = DbHelper();
    showData(this.shoppingList.id);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(shoppingList.name),
      ),
      body: ListView.builder(
          itemCount: (items != null) ? items!.length : 0,
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
                    key: Key(items![index].name),
                    onDismissed: (direction) {
                      String strName = items![index].name;
                      helper!.deleteItem(items![index]);
                      setState(() {
                        items!.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("$strName deleted")));
                    },
                    child: ListTile(
                      title: Text(items![index].name),
                      subtitle: Text(
                          "Quantity: ${items![index].quantity} - Note:${items![index].note} "),
                      onTap: () {},
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => dialog
                                  .buildAlert(context, items![index], false));
                        },
                      ),
                    )),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => dialog.buildAlert(
                context, ListItem(0, shoppingList.id, '', '', ''), true),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
