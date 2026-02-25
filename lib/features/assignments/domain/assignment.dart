class Assignment {
  final String id;
  final String subjectId;
  final String title;
  final DateTime dueDate;
  final double weightPercent;
  final bool isDone;
  final DateTime createdAt;

  const Assignment({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.dueDate,
    required this.weightPercent,
    required this.isDone,
    required this.createdAt,
  });

  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;

  Assignment copyWith({
    String? id,
    String? subjectId,
    String? title,
    DateTime? dueDate,
    double? weightPercent,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      weightPercent: weightPercent ?? this.weightPercent,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'weightPercent': weightPercent,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      weightPercent: (json['weightPercent'] as num).toDouble(),
      isDone: json['isDone'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Assignment &&
        other.id == id &&
        other.subjectId == subjectId &&
        other.title == title &&
        other.dueDate == dueDate &&
        other.weightPercent == weightPercent &&
        other.isDone == isDone &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        subjectId,
        title,
        dueDate,
        weightPercent,
        isDone,
        createdAt,
      );
}
