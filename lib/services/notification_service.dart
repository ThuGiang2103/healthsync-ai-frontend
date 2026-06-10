import 'dart:async';

typedef ReminderCallback = void Function();

class NotificationService {
  static final Map<int, Timer> _timers = {};

  static Future<void> init() async {}

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required ReminderCallback onTrigger,
  }) async {
    final delay = scheduledTime.difference(DateTime.now());

    if (delay.isNegative || delay.inSeconds == 0) {
      onTrigger();
      return;
    }

    await cancelReminder(id);

    _timers[id] = Timer(delay, () {
      _timers.remove(id);
      onTrigger();
    });
  }

  static Future<void> cancelReminder(int id) async {
    final timer = _timers.remove(id);
    timer?.cancel();
  }

  static Future<void> cancelAll() async {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
