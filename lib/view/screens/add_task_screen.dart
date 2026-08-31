import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexowa_core/nexowa_core.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/providers/todo_provider.dart';
import 'package:todolist/services/notification_service.dart' as todo_notification;
import '../../enum.dart';

class AddTaskScreen extends StatefulWidget {
  final TodoModel? todo;
  const AddTaskScreen({super.key, this.todo});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  DateTime? selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String selectedCategory = "Work";
  final List<String> categories = ["Work", "Family", "Health", "Personal", "Design"];

  List<TextEditingController> subTaskControllers = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.todo != null) {
      isEditing = true;
      titleController.text = widget.todo!.title;
      locationController.text = widget.todo!.location ?? "";
      selectedDate = widget.todo!.date;
      startTime = TimeOfDay.fromDateTime(widget.todo!.reminderTime);
      if (widget.todo!.endTime != null) {
        endTime = TimeOfDay.fromDateTime(widget.todo!.endTime!);
      }
      selectedCategory = widget.todo!.category;

      for (String subTask in widget.todo!.subTasks) {
        subTaskControllers.add(TextEditingController(text: subTask));
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    for (var controller in subTaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStart) startTime = picked;
        else endTime = picked;
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void saveTask() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter Task Title", style: TextStyle(color: Colors.white))));
      return;
    }
    if (selectedDate == null || startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Date and Start Time", style: TextStyle(color: Colors.white))));
      return;
    }

    List<String> finalSubTasks = subTaskControllers.map((c) => c.text.trim()).where((text) => text.isNotEmpty).toList();

    NexowaCore.instance.showActionAd(
      actionName: ActionName.add_todo_click.name,
      screenName: ScreenType.todo_scr_view.name,
      onRewardEarned: (_) {
        DateTime reminder = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, startTime!.hour, startTime!.minute);
        DateTime? endDT;
        if (endTime != null) endDT = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, endTime!.hour, endTime!.minute);

        final newTodo = TodoModel(
          id: isEditing ? widget.todo!.id : DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleController.text.trim(),
          date: selectedDate!,
          reminderTime: reminder,
          endTime: endDT,
          location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
          category: selectedCategory,
          subTasks: finalSubTasks,
        );

        if (isEditing) {
          context.read<TodoProvider>().updateTodo(widget.todo!.id, newTodo);
        } else {
          context.read<TodoProvider>().addTodo(newTodo);
        }

        todo_notification.NotificationService.scheduleNotification(
          id: newTodo.id.hashCode.abs() % 2147483647,
          title: newTodo.title,
          body: "Reminder at ${startTime!.format(context)}",
          scheduleTime: reminder,
        );
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildDateTimeRow({required String title, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.indigo, size: 20),
            ),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 15, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(isEditing ? "Edit Event" : "New Event", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 1. Task Details Section
              _buildSectionTitle("Task Details"),

              // Title TextField
              TextField(
                controller: titleController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "What do you want to do?",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.normal),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Location TextField
              TextField(
                controller: locationController,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration( shape: BoxShape.circle),
                      child: Icon(Icons.location_on_outlined, color: Colors.indigo.shade400, size: 20),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: "Location or Notes",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 2. Date & Time Section
              _buildSectionTitle("Date & Time"),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _buildDateTimeRow(
                      title: "Date",
                      value: selectedDate == null ? "Select Date" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      icon: Icons.calendar_today_rounded,
                      onTap: _pickDate,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200, indent: 16, endIndent: 16),

                    _buildDateTimeRow(
                      title: "Start Time",
                      value: startTime == null ? "Select" : startTime!.format(context),
                      icon: Icons.access_time_filled,
                      onTap: () => _pickTime(isStart: true),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200, indent: 16, endIndent: 16),

                    _buildDateTimeRow(
                      title: "End Time",
                      value: endTime == null ? "Select" : endTime!.format(context),
                      icon: Icons.timer_off_rounded,
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 3. Category Section
              _buildSectionTitle("Category"),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((cat) {
                  bool isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.indigo.shade500,
                    backgroundColor: Colors.white,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? Colors.indigo : Colors.grey.shade300, width: 1.0)
                    ),
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600
                    ),
                    onSelected: (val) => setState(() => selectedCategory = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // 4. Sub-Tasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("To-Do List"),
                  InkWell(
                    onTap: () => setState(() => subTaskControllers.add(TextEditingController())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.indigo.shade400, size: 18),
                          const SizedBox(width: 4),
                          Text("Add", style: TextStyle(color: Colors.indigo.shade400, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: List.generate(subTaskControllers.length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                              controller: subTaskControllers[index],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              decoration: const InputDecoration(
                                  hintText: "Sub-task name...",
                                  hintStyle: TextStyle(fontSize: 14),
                                  border: InputBorder.none,
                                  isDense: true
                              )
                          ),
                        ),
                        IconButton(
                            icon: Icon(Icons.close, color: Colors.grey.shade400, size: 20),
                            onPressed: () => setState(() {
                              subTaskControllers[index].dispose();
                              subTaskControllers.removeAt(index);
                            })
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // 5. Save Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ElevatedButton(
            onPressed: saveTask,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                elevation: 4,
                shadowColor: Colors.indigo.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
            ),
            child: Text(
                isEditing ? "Update Event" : "Create Event",
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)
            ),
          ),
        ),
      ),
    );
  }
}