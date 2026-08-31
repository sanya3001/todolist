import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/providers/todo_provider.dart';
import 'package:nexowa_core/nexowa_core.dart';
import 'package:todolist/view/screens/search_screen.dart';
import '../../enum.dart';
import 'add_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

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

  List<TodoModel> _getEventsForDay(DateTime day, List<TodoModel> allTodos) {
    return allTodos.where((todo) => isSameDay(todo.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTaskScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.only(left: 24, top: 10, bottom: 10),
            child: Text(
              DateFormat('MMMM').format(provider.selectedDate).toUpperCase(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.5),
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: TableCalendar<TodoModel>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: provider.selectedDate,

              calendarFormat: _calendarFormat,
              availableGestures: AvailableGestures.horizontalSwipe,

              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.week: 'Week',
              },
              headerVisible: false,

              eventLoader: (day) => _getEventsForDay(day, provider.todos),

              selectedDayPredicate: (day) => isSameDay(provider.selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                provider.updateSelectedDate(selectedDay);
              },
              onPageChanged: (focusedDay) {
                provider.updateSelectedDate(focusedDay);
              },
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 12),
                weekendStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(color: Colors.indigoAccent, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.indigoAccent.withOpacity(0.2), shape: BoxShape.circle),
                defaultTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                weekendTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                outsideDaysVisible: false,
                markersMaxCount: 10,
              ),

              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox();
                  return Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(10).map((event) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: getCategoryColor(event.category),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 10),
          NexowaCore.instance.nexowaAd(screenName: ScreenType.todo_scr_view.name),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE dd, MMM').format(provider.selectedDate).toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 1.0),
                ),
                if (isSameDay(provider.selectedDate, DateTime.now()))
                  Text(
                    "Today",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
                  )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, color: Colors.grey.shade200, thickness: 1.5),
          ),
          const SizedBox(height: 10),

          // Task List
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (_, provider, __) {
                List<TodoModel> todos = provider.getTodosForSelectedDate();

                return NotificationListener<ScrollUpdateNotification>(
                  onNotification: (notification) {
                    if (notification.dragDetails != null && notification.scrollDelta != null) {
                      if (notification.scrollDelta! > 0 && _calendarFormat == CalendarFormat.month) {
                        setState(() => _calendarFormat = CalendarFormat.week);
                      }
                      else if (notification.scrollDelta! < 0 && notification.metrics.pixels <= 0 && _calendarFormat == CalendarFormat.week) {
                        setState(() => _calendarFormat = CalendarFormat.month);
                      }
                    }
                    return false;
                  },
                  child: todos.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text("No tasks for this day.", style: TextStyle(color: Colors.grey))),
                    ],
                  )
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemCount: todos.length,
                    itemBuilder: (_, index) {
                      final todo = todos[index];
                      Color dashColor = getCategoryColor(todo.category);

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
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. TIME
                                    SizedBox(
                                      width: 75,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 3.0),
                                        child: Text(
                                          timeText.toUpperCase(),
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),

                                    // 2. CATEGORY DOT
                                    Container(
                                      margin: const EdgeInsets.only(top: 9, right: 12),
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: dashColor,
                                      ),
                                    ),

                                    // 3. TASK TITLE & CATEGORY
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              todo.title,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                                height: 1.6,
                                              )
                                          ),
                                          if (todo.category.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                                todo.category.toUpperCase(),
                                                style: TextStyle(fontSize: 10, color: Colors.grey.shade400, letterSpacing: 1.0)
                                            ),
                                          ]
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 100, right: 24),
                                child: Divider(height: 1, color: Colors.grey.shade200, thickness: 1.5),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}