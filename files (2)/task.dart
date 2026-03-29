class Task {
  final int id;
  final String title;
  final String description;
  final String dueDate;
  final String status;
  final int? blockedById;
  final int sortOrder;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
    this.sortOrder = 0,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        dueDate: json['due_date'],
        status: json['status'],
        blockedById: json['blocked_by_id'],
        sortOrder: json['sort_order'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'due_date': dueDate,
        'status': status,
        'blocked_by_id': blockedById,
        'sort_order': sortOrder,
      };

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? dueDate,
    String? status,
    int? blockedById,
    bool clearBlockedBy = false,
    int? sortOrder,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        status: status ?? this.status,
        blockedById: clearBlockedBy ? null : (blockedById ?? this.blockedById),
        sortOrder: sortOrder ?? this.sortOrder,
      );

  bool isBlocked(List<Task> allTasks) {
    if (blockedById == null) return false;
    final blocker = allTasks.where((t) => t.id == blockedById).firstOrNull;
    return blocker != null && blocker.status != 'Done';
  }
}
