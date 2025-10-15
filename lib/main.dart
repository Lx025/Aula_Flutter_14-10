import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/firebase_options.web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseWebOptions);
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do Simples',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ToDoScreen(),
    );
  }
}

class ToDoScreen extends StatelessWidget {
  ToDoScreen({super.key});
  final CollectionReference todos = FirebaseFirestore.instance.collection(
    'todos',
  );

  final TextEditingController controller = TextEditingController();

  void addTodo() {
    final text = controller.text;
    if (text.isNotEmpty) {
      todos.add({'title': text, 'done': false});
      controller.clear();
    }
  }

  void toggleDone(DocumentSnapshot doc) {
    todos.doc(doc.id).update({'done': !doc['done']});
  }

  void deleteTodo(DocumentSnapshot doc) {
    todos.doc(doc.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ToDo"), actions: [

 ],
 ),
      body: Column(
        children: [
          // Campos da tela
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Nova tarefa'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: addTodo),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: todos.snapshots(),
              builder: (context, snapshot) {
                //Estado de carregando
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                //Tratamento de erro
                if (snapshot.hasError) {
                  return const Text(
                    "Ocorreu um erro ao carregar os dados",
                    style: TextStyle(color: Colors.red),
                  );
                }
                //Caso não haja nenhum registro
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text(
                    "Nenhum registro encontrado",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }

                // Dados disponíveis
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    return ListTile(
                      title: Text(
                        doc['title'],
                        style: TextStyle(
                          decoration: doc['done']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      leading: Checkbox(
                        value: doc['done'],
                        onChanged: (_) => toggleDone(doc),
                      ),
                      trailing: IconButton(
                        onPressed: () => deleteTodo(doc),
                        icon: Icon(Icons.delete),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
