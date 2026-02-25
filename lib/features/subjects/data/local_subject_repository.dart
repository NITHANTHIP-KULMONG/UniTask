import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/subject.dart';
import '../domain/subject_repository.dart';

class LocalSubjectRepository implements SubjectRepository {
  static const String _storageKey = 'subjects';

  const LocalSubjectRepository();

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  @override
  Future<List<Subject>> getAll() async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_storageKey) ?? <String>[];

    return jsonList
        .map(
          (item) => Subject.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveAll(List<Subject> subjects) async {
    final prefs = await _prefs;
    final jsonList = subjects.map((s) => jsonEncode(s.toJson())).toList();

    await prefs.setStringList(_storageKey, jsonList);
  }

  @override
  Future<void> add(Subject subject) async {
    final subjects = await getAll();
    subjects.add(subject);
    await saveAll(subjects);
  }

  @override
  Future<void> update(Subject subject) async {
    final subjects = await getAll();
    final index = subjects.indexWhere((item) => item.id == subject.id);
    if (index == -1) {
      return;
    }

    subjects[index] = subject;
    await saveAll(subjects);
  }

  @override
  Future<void> delete(String id) async {
    final subjects = await getAll();
    subjects.removeWhere((subject) => subject.id == id);
    await saveAll(subjects);
  }
}
