import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/assignment.dart';
import '../domain/assignment_repository.dart';

class LocalAssignmentRepository implements AssignmentRepository {
  static const String _storageKey = 'assignments';

  const LocalAssignmentRepository();

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  @override
  Future<List<Assignment>> getAll() async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_storageKey) ?? <String>[];

    return jsonList
        .map(
          (item) => Assignment.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveAll(List<Assignment> assignments) async {
    final prefs = await _prefs;
    final jsonList = assignments.map((a) => jsonEncode(a.toJson())).toList();

    await prefs.setStringList(_storageKey, jsonList);
  }

  @override
  Future<void> add(Assignment assignment) async {
    final assignments = await getAll();
    assignments.add(assignment);
    await saveAll(assignments);
  }

  @override
  Future<void> update(Assignment assignment) async {
    final assignments = await getAll();
    final index = assignments.indexWhere((item) => item.id == assignment.id);
    if (index == -1) {
      return;
    }

    assignments[index] = assignment;
    await saveAll(assignments);
  }

  @override
  Future<void> delete(String id) async {
    final assignments = await getAll();
    assignments.removeWhere((assignment) => assignment.id == id);
    await saveAll(assignments);
  }
}
