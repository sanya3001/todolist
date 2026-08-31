import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/todo_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart' as todo_notification;

class TodoProvider extends ChangeNotifier {
 final List<TodoModel> _todos = [];
 final FirestoreService _firestoreService = FirestoreService();

 // ----------------------------------------------------
 // CALENDAR SCREEN માટેનું લોજીક
 // ----------------------------------------------------
 DateTime _selectedDate = DateTime.now();
 DateTime get selectedDate => _selectedDate;

 List<TodoModel> get todos => _todos;

 TodoProvider();

 // તારીખ બદલવા માટેનું ફંક્શન (Calendar માં વપરાશે)
 void updateSelectedDate(DateTime date) {
  _selectedDate = date;
  notifyListeners();
 }

 // ----------------------------------------------------
 // FIREBASE CRUD ઓપરેશન્સ
 // ----------------------------------------------------

 // Add Todo
 Future<void> addTodo(TodoModel todo) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  _todos.add(todo);
  notifyListeners();
  await _firestoreService.addTodo(user.uid, todo);
 }

 // Update Todo
 Future<void> updateTodo(String id, TodoModel todo) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final index = _todos.indexWhere((element) => element.id == id);
  if (index != -1) {
   _todos[index] = todo;
   notifyListeners();
   await _firestoreService.updateTodo(user.uid, todo);
  }
 }

 // Delete Todo
 Future<void> deleteTodo(String id) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  _todos.removeWhere((element) => element.id == id);
  notifyListeners();
  await _firestoreService.deleteTodo(user.uid, id);
 }

 // Load Todos from Firestore
 Future<void> loadTodos() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final todos = await _firestoreService.getTodos(user.uid);
  _todos.clear();
  _todos.addAll(todos);
  notifyListeners();

  for (var todo in _todos) {
   if (todo.reminderTime.isAfter(DateTime.now())) {
    int notifId = todo.id.hashCode.abs() % 2147483647;
    todo_notification.NotificationService.scheduleNotification(
     id: notifId,
     title: todo.title,
     body: "Reminder: ${todo.title}",
     scheduleTime: todo.reminderTime,
    );
   }
  }
 }

 // ----------------------------------------------------
 // FILTER ફંક્શન્સ (મેઈન સ્ક્રીન અને કેલેન્ડર માટે)
 // ----------------------------------------------------

 // ૧. કેલેન્ડરમાં સિલેક્ટ કરેલી તારીખ મુજબ ટાસ્ક આપશે
 List<TodoModel> getTodosForSelectedDate() {
  return _todos.where((todo) {
   return todo.date.year == _selectedDate.year &&
       todo.date.month == _selectedDate.month &&
       todo.date.day == _selectedDate.day;
  }).toList();
 }

 // ૨. મેઈન સ્ક્રીન: આજના (Today) ટાસ્ક આપશે
 List<TodoModel> getTodayTodos() {
  final now = DateTime.now();
  return _todos.where((todo) {
   return todo.date.year == now.year &&
       todo.date.month == now.month &&
       todo.date.day == now.day;
  }).toList();
 }

 // ૩. મેઈન સ્ક્રીન: ગઈકાલના (Yesterday) ટાસ્ક આપશે
 List<TodoModel> getYesterdayTodos() {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return _todos.where((todo) {
   return todo.date.year == yesterday.year &&
       todo.date.month == yesterday.month &&
       todo.date.day == yesterday.day;
  }).toList();
 }
}


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../models/todo_model.dart';
// import '../services/firestore_service.dart';
// import '../services/notification_service.dart' as todo_notification;
//
// class TodoProvider extends ChangeNotifier {
//  final List<TodoModel> _todos = [];
//  final FirestoreService _firestoreService = FirestoreService();
//
//  DateTime _selectedDate = DateTime.now();
//  DateTime get selectedDate => _selectedDate;
//
//  List<TodoModel> get todos => _todos;
//
//  TodoProvider();
//
//  // date change function
//  void updateSelectedDate(DateTime date) {
//   _selectedDate = date;
//   notifyListeners();
//  }
//
//  // Add Todo
//  Future<void> addTodo(TodoModel todo) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;
//
//   _todos.add(todo);
//   notifyListeners();
//   await _firestoreService.addTodo(user.uid, todo);
//  }
//
//  // Update Todo
//  Future<void> updateTodo(String id, TodoModel todo) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;
//
//   final index = _todos.indexWhere((element) => element.id == id);
//   if (index != -1) {
//    _todos[index] = todo;
//    notifyListeners();
//    await _firestoreService.updateTodo(user.uid, todo);
//   }
//  }
//
//  // Delete Todo
//  Future<void> deleteTodo(String id) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;
//
//   _todos.removeWhere((element) => element.id == id);
//   notifyListeners();
//   await _firestoreService.deleteTodo(user.uid, id);
//  }
//
//  // Load Todos from Firestore
//  Future<void> loadTodos() async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;
//
//   final todos = await _firestoreService.getTodos(user.uid);
//   _todos.clear();
//   _todos.addAll(todos);
//   notifyListeners();
//
//   for (var todo in _todos) {
//    if (todo.reminderTime.isAfter(DateTime.now())) {
//     int notifId = todo.id.hashCode.abs() % 2147483647;
//     todo_notification.NotificationService.scheduleNotification(
//      id: notifId,
//      title: todo.title,
//      body: "Reminder: ${todo.title}",
//      scheduleTime: todo.reminderTime,
//     );
//    }
//   }
//  }
//
//  List<TodoModel> getTodosForSelectedDate() {
//   return _todos.where((todo) {
//    return todo.date.year == _selectedDate.year &&
//        todo.date.month == _selectedDate.month &&
//        todo.date.day == _selectedDate.day;
//   }).toList();
//  }
// }