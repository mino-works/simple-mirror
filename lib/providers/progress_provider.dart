import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/date_utils.dart';

class ProgressState {
  final Set<String> loginDays;
  const ProgressState({required this.loginDays});

  int get totalDays => loginDays.length;
  bool get isCarrotUnlocked => totalDays >= 7;
  bool get isDressUnlocked => totalDays >= 14;
  int get daysUntilCarrot => (7 - totalDays).clamp(0, 7);
  int get daysUntilDress => (14 - totalDays).clamp(0, 14);
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier() : super(const ProgressState(loginDays: {})) {
    _load();
  }

  static const _key = 'login_days';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    state = ProgressState(loginDays: Set<String>.from(list));
  }

  Future<void> recordFortuneView() async {
    final today = DateUtils.getTodayKey();
    if (state.loginDays.contains(today)) return;
    final updated = {...state.loginDays, today};
    state = ProgressState(loginDays: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated.toList());
  }

  // ── デバッグ用（リリース時は削除） ──────────────────────────
  Future<void> debugAddDays(int n) async {
    final base = DateTime.now();
    final existing = {...state.loginDays};
    for (var i = 1; existing.length < state.loginDays.length + n; i++) {
      final fake = base.subtract(Duration(days: i));
      existing.add('${fake.year}-${fake.month.toString().padLeft(2, '0')}-${fake.day.toString().padLeft(2, '0')}');
    }
    state = ProgressState(loginDays: existing);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, existing.toList());
  }

  Future<void> debugResetDays() async {
    state = const ProgressState(loginDays: {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
  // ────────────────────────────────────────────────────────────
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>(
  (ref) => ProgressNotifier(),
);
