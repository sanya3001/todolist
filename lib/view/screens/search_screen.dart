import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/todo_model.dart';
import '../../providers/todo_provider.dart';
import 'add_task_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  Color getCategoryColor(String category) {
    switch (category) {
      case "Work": return Colors.purpleAccent;
      case "Health": return Colors.greenAccent;
      case "Family": return Colors.orangeAccent;
      case "Personal": return Colors.blueAccent;
      case "Design": return Colors.cyan;
      default: return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final searchText = searchController.text.toLowerCase();

    final searchResults = provider.todos.where((todo) {
      return todo.title.toLowerCase().contains(searchText);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: SizedBox(
          height: 45,
          child: TextField(
            controller: searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.all(0),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
      ),
      body: searchResults.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                searchText.isEmpty ? Icons.search_rounded : Icons.search_off_rounded,
                size: 60,
                color: Colors.grey.shade300
            ),
            const SizedBox(height: 15),
            Text(
              searchText.isEmpty ? 'Type to search your tasks...' : 'No task found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 15, bottom: 20),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final todo = searchResults[index];
          Color dashColor = getCategoryColor(todo.category);

          bool isCompleted = todo.reminderTime.isBefore(DateTime.now());
          String timeText = DateFormat('hh:mm a').format(todo.reminderTime);

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddTaskScreen(todo: todo)));
            },
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? const Color(0xFF5DD299) : Colors.transparent,
                            border: Border.all(
                              color: isCompleted ? const Color(0xFF5DD299) : Colors.grey.shade400,
                              width: 2.5,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  todo.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? Colors.grey.shade500 : Colors.black87,
                                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                  )
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  "${DateFormat('dd MMM').format(todo.date).toUpperCase()} • ${timeText.toUpperCase()}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isCompleted ? Colors.grey.shade400 : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5
                                  )
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 25,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.grey.shade300 : dashColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 68, right: 24),
                    child: Divider(height: 1, color: Colors.grey.shade200, thickness: 1.5),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/todo_provider.dart';
//
// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});
//
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController searchController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<TodoProvider>();
//
//     final searchText = searchController.text.toLowerCase();
//
//     final searchResults = provider.todos.where((todo) {
//       return todo.title.toLowerCase().contains(searchText);
//     }).toList();
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212), // ડાર્ક બેકગ્રાઉન્ડ
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: SizedBox(
//           height: 45, //
//           child: TextField(
//             controller: searchController,
//             autofocus: true,
//             style: const TextStyle(color: Colors.white, fontSize: 16),
//             textAlignVertical: TextAlignVertical.center, // ટેક્સ્ટને એકદમ વચ્ચે લાવવા
//             decoration: InputDecoration(
//               hintText: 'Search task...',
//               hintStyle: TextStyle(color: Colors.grey.shade500),
//               filled: true,
//               fillColor: const Color(0xFF1E1E1E), // બોક્સનો કલર
//               contentPadding: const EdgeInsets.all(0), // એક્સ્ટ્રા સ્પેસિંગ કાઢ્યું
//               prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22), // આઇકોન અંદર સેટ કર્યું
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide.none, // બોર્ડર કાઢી નાખી
//               ),
//             ),
//             onChanged: (_) {
//               setState(() {});
//             },
//           ),
//         ),
//       ),
//       body: searchResults.isEmpty
//           ? Center(
//         child: Text(
//           searchText.isEmpty ? 'Type to search your tasks...' : 'No task found',
//           style: const TextStyle(color: Colors.white54, fontSize: 16),
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.only(top: 15),
//         itemCount: searchResults.length,
//         itemBuilder: (context, index) {
//           final todo = searchResults[index];
//
//           return Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFF1E1E1E),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey.shade800),
//             ),
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//             child: ListTile(
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               leading: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: const BoxDecoration(
//                   color: Colors.indigoAccent, // અહીં ઘાટો કલર કર્યો
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.check_circle_outline, color: Colors.white), // અંદરનું આઇકોન સફેદ કર્યું
//               ),
//               title: Text(
//                 todo.title,
//                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               subtitle: Padding(
//                 padding: const EdgeInsets.only(top: 4.0),
//                 child: Text(
//                   "${todo.date.day}/${todo.date.month}/${todo.date.year} • ${TimeOfDay.fromDateTime(todo.reminderTime).format(context)}",
//                   style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }