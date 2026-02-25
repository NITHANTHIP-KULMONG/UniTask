import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/timer_repository.dart';
import '../domain/timer_session.dart';

class LocalTimerRepository implements TimerRepository {
  static const String _storageKey = 'timer_sessions';

  const LocalTimerRepository();

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  @override
  Future<List<TimerSession>> getAll() async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_storageKey) ?? <String>[];

    final sessions = jsonList
        .map(
          (item) => TimerSession.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();

    sessions.sort((a, b) => b.startAt.compareTo(a.startAt));
    return sessions;
  }

  @override
  Future<void> saveAll(List<TimerSession> sessions) async {
    final prefs = await _prefs;
    final jsonList = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  @override
  Future<void> add(TimerSession session) async {
    final sessions = await getAll();
    sessions.add(session);
    await saveAll(sessions);
  }

  @override
  Future<void> delete(String id) async {
    final sessions = await getAll();
    sessions.removeWhere((session) => session.id == id);
    await saveAll(sessions);
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_storageKey);
  }
}
