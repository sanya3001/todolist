import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _todoCollection(
      String userId,
      ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('todos');
  }

  // Add Todo
  Future<void> addTodo(
      String userId,
      TodoModel todo,
      ) async {
    await _todoCollection(userId)
        .doc(todo.id)
        .set(todo.toJson());

  }

  // Get Todos
  Future<List<TodoModel>> getTodos(
      String userId,
      ) async {
    final snapshot =
    await _todoCollection(userId).get();

    return snapshot.docs.map((doc) {
      return TodoModel.fromJson(doc.data());
    }).toList();
  }

  // Update Todo
  Future<void> updateTodo(
      String userId,
      TodoModel todo,
      ) async {
    await _todoCollection(userId)
        .doc(todo.id)
        .update(todo.toJson());
  }

  // Delete Todo
  Future<void> deleteTodo(
      String userId,
      String todoId,
      ) async {
    await _todoCollection(userId)
        .doc(todoId)
        .delete();
  }
}
