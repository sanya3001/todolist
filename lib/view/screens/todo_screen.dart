import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todolist/auth/auth_service.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/providers/todo_provider.dart';
import 'package:nexowa_core/nexowa_core.dart';
import 'package:todolist/view/screens/search_screen.dart';
import 'package:todolist/view/screens/login_screen.dart';
import 'package:todolist/view/screens/calendar_screen.dart';
import '../../enum.dart';
import 'add_task_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String selectedFilter = "Today";

  @override
  void initState() {
    super.initState();
    _nxInit();
    Future.microtask(() {
      context.read<TodoProvider>().loadTodos();
    });
  }

  void _nxInit() async {
    await NexowaCore.instance.initializationDone;
  }

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

    return Scaffold(
      backgroundColor: Colors.white,

      // સાઇડ મેનુ (Drawer)
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('My Profile', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.indigo),
              title: const Text('Calendar View', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                }
              },
            ),
          ],
        ),
      ),

      body: Builder(
        builder: (context) => Stack(
          children: [
            // 1. Background Watermark
            Positioned(
              top: -70,
              right: 15,
              child: Text(
                DateTime.now().day.toString(),
                style: TextStyle(
                  fontSize: 180,
                  fontWeight: FontWeight.w900,
                  color: Colors.indigo.shade50.withOpacity(0.5),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Custom Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search_rounded, color: Colors.black87, size: 28),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
                          },
                        ),
                      ],
                    ),
                  ),

                  // 3. TO-DO Title + Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          "TO-DO",
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.0),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('MMM dd').format(DateTime.now()).toUpperCase(),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),

                  // 4. Filters (Yesterday, Today, All)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                    child: Row(
                      children: ["Today", "Yesterday", "All"].map((filter) {
                        bool isSelected = selectedFilter == filter;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.indigo : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.indigo : Colors.grey.shade600,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  NexowaCore.instance.nexowaAd(screenName: ScreenType.todo_scr_view.name),

                  // 5. Task List
                  Expanded(
                    child: Consumer<TodoProvider>(
                      builder: (_, provider, __) {
                        List<TodoModel> todos;

                        if (selectedFilter == "Today") {
                          todos = provider.getTodayTodos();
                        } else if (selectedFilter == "Yesterday") {
                          todos = provider.getYesterdayTodos();
                        } else {
                          todos = provider.todos;
                        }

                        if (todos.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.done_all, size: 60, color: Colors.grey.shade300),
                                const SizedBox(height: 15),
                                Text("No tasks for $selectedFilter", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: todos.length,
                          itemBuilder: (_, index) {
                            final todo = todos[index];
                            Color dashColor = getCategoryColor(todo.category);

                            bool isCompleted = todo.reminderTime.isBefore(DateTime.now());

                            String timeText = DateFormat('hh:mm a').format(todo.reminderTime);
                            if (todo.endTime != null) {
                              timeText += " - ${DateFormat('hh:mm a').format(todo.endTime!)}";
                            }

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
                                                    timeText.toUpperCase(),
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
                                      child: Divider(height: 1, color: Colors.grey.shade300, thickness: 1.5),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTaskScreen()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}