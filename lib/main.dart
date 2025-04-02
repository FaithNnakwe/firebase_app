// Import Flutter package
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InventoryHomePage(title: 'Inventory Home Page'),
    );
  }
}

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key, required this.title});
  final String title;

  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final CollectionReference inventory = 
      FirebaseFirestore.instance.collection('inventory');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD0E1F9),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color(0xFFF9D6E1),
      ),
      body: StreamBuilder(
        stream: inventory.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data"));
          }

          final items = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text("Quantity: ${item['quantity']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editItem(context, item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(item.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
  padding: const EdgeInsets.all(16.0),
  child: TextButton(
    onPressed: () => _addItem(context),
    style: TextButton.styleFrom(
      backgroundColor: Colors.blue, // Button background color
      padding: EdgeInsets.symmetric(vertical: 12.0), // Button padding
    ),
    child: Text(
      "Add Item",
      style: TextStyle(color: Colors.white, fontSize: 18), // Text color & size
    ),
  ),
),
    );
  }

  void _deleteItem(String id) {
    inventory.doc(id).delete();
  }

  void _editItem(BuildContext context, QueryDocumentSnapshot item) {
  TextEditingController nameController = 
      TextEditingController(text: item['name']);
  TextEditingController quantityController = 
      TextEditingController(text: item['quantity'].toString());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Item Name"),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Quantity"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  quantityController.text.isNotEmpty) {
                inventory.doc(item.id).update({
                  'name': nameController.text,
                  'quantity': int.parse(quantityController.text),
                });
                Navigator.pop(context);
              }
            },
            child: Text("Update"),
          ),
        ],
      );
    },
  );
}

void _addItem(BuildContext context) {
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Add Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Item Name"),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Quantity"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && 
                  quantityController.text.isNotEmpty) {
                inventory.add({
                  'name': nameController.text,
                  'quantity': int.parse(quantityController.text),
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      );
    },
  );
}

}

