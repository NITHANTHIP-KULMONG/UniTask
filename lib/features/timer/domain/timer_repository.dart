import 'timer_session.dart';

abstract class TimerRepository {
  Future<List<TimerSession>> getAll();

  Future<void> saveAll(List<TimerSession> sessions);

  Future<void> add(TimerSession session);

  Future<void> delete(String id);

  Future<void> clear();
}
