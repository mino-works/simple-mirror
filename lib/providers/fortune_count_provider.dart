import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/date_utils.dart';

class FortuneCountState {
  final int todayCount;
  final bool isLoaded;

  const FortuneCountState({required this.todayCount, this.isLoaded = false});

  bool canDivine(bool isPremium) => isPremium || todayCount == 0;
}

class FortuneCountNotifier extends StateNotifier<FortuneCountState> {
  FortuneCountNotifier() : super(const FortuneCountState(todayCount: 0)) {
    _load();
  }

  final _initCompleter = Completer<void>();
  Future<void> get initialized => _initCompleter.future;

  static const _countKey = 'fortune_count_today';
  static const _dateKey = 'fortune_count_date';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateUtils.getTodayKey();
    final savedDate = prefs.getString(_dateKey) ?? '';

    final count = (savedDate == today) ? (prefs.getInt(_countKey) ?? 0) : 0;
    state = FortuneCountState(todayCount: count, isLoaded: true);
    _initCompleter.complete();
  }

  Future<void> recordDivine() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateUtils.getTodayKey();
    final newCount = state.todayCount + 1;
    state = FortuneCountState(todayCount: newCount, isLoaded: true);
    await prefs.setInt(_countKey, newCount);
    await prefs.setString(_dateKey, today);
  }
}

final fortuneCountProvider =
    StateNotifierProvider<FortuneCountNotifier, FortuneCountState>(
  (ref) => FortuneCountNotifier(),
);
