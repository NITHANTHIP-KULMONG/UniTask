import 'dart:math' as math;

int daysRemaining(DateTime due) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueDateOnly = DateTime(due.year, due.month, due.day);
  return dueDateOnly.difference(today).inDays;
}

double priorityScore(double weightPercent, DateTime due) {
  final remaining = daysRemaining(due);
  final effectiveDays = remaining <= 0 ? 1 : remaining;
  return weightPercent / math.max(1, effectiveDays);
}
