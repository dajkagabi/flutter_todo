import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TodoListScreen extends ConsumerWidget {
  // Widget, ami figyeli a providereket (ConsumerWidget)
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teendőlista'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // StreamBuilder widget a Firestore-ból érkező adatok kezeléséhez
        stream: FirebaseFirestore.instance
            .collection('todos')
            .snapshots(), // Figyeljük a 'todos' gyűjtemény változásait
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Ha hiba történt
            return Center(child: Text('Hiba: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // Ha még töltődnek az adatok
            return const Center(child: CircularProgressIndicator());
          }

          final todos =
              snapshot.data!.docs; // Az adatok lekérdezése a snapshotból

          return ListView.builder(
            // ListView az adatok listázásához
            itemCount: todos.length,
            itemBuilder: (context, index) {
              // Itemek felépítése
              final todo = todos[index];
              final title = todo['title'];
              final completed =
                  todo['completed']; // A teendő állapota (kész/nincs kész)

              return ListTile(
                // Teendők megjelenítéséhez
                title: Text(title),
                leading: Checkbox(
                  // Checkbox a teendő állapotának beállításához
                  value: completed,
                  onChanged: (value) {
                    // Az állapot változásakor
                    todo.reference.update(
                        {'completed': value}); // Frissítjük az adatbázist
                  },
                ),
                trailing: IconButton(
                  // Gomb a teendő törléséhez
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Törlés
                    todo.reference.delete();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Gomb új teendő hozzáadásához
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newTodoTitle = '';
              return AlertDialog(
                title: const Text('Új teendő hozzáadása'),
                content: TextField(
                  //Új teendő
                  onChanged: (value) => newTodoTitle =
                      value, // Cím változásakor frissítjük a newTodoTitle változót
                ),
                actions: [
                  TextButton(
                    // Mégse gomb
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Mégse'),
                  ),
                  TextButton(
                    // Hozzáadás gomb
                    onPressed: () {
                      if (newTodoTitle.isNotEmpty) {
                        // Ha a cím nem üres
                        FirebaseFirestore.instance.collection('todos').add({
                          // Hozzáadjuk az új teendőt az adatbázishoz
                          'title': newTodoTitle,
                          'completed': false,
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Hozzáadás'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
