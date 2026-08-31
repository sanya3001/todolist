class TodoModel {
  String id;
  String title;
  DateTime date;
  DateTime reminderTime;
  DateTime? endTime;
  String? location;
  String category;
  List<String> subTasks;

  TodoModel({
    required this.id,
    required this.title,
    required this.date,
    required this.reminderTime,
    this.endTime,
    this.location,
    this.category = "Work",
    this.subTasks = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "date": date.toIso8601String(),
      "reminderTime": reminderTime.toIso8601String(),
      "endTime": endTime?.toIso8601String(),
      "location": location,
      "category": category,
      "subTasks": subTasks,
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      date: DateTime.parse(json["date"]),
      reminderTime: DateTime.parse(json["reminderTime"]),
      endTime: json["endTime"] != null ? DateTime.parse(json["endTime"]) : null,
      location: json["location"],
      category: json["category"] ?? "Work",
      subTasks: List<String>.from(json['subTasks'] ?? []),
    );
  }
}