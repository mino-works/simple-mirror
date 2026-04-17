import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fortune.dart';
import '../utils/fortune_generator.dart';
import '../utils/date_utils.dart';

final fortuneProvider = StateNotifierProvider<FortuneNotifier, Fortune?>((ref) {
  return FortuneNotifier();
});

class FortuneNotifier extends StateNotifier<Fortune?> {
  FortuneNotifier() : super(null) {
    _loadTodayFortune();
  }

  final _initCompleter = Completer<void>();
  Future<void> get initialized => _initCompleter.future;

  Future<void> _loadTodayFortune() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateUtils.getTodayKey();
    final fortuneJson = prefs.getString(todayKey);
    if (fortuneJson != null) {
      final fortune = Fortune.fromJson(jsonDecode(fortuneJson) as Map<String, dynamic>);
      state = fortune;
    }
    _initCompleter.complete();
  }

  Future<void> generateAndSaveFortune() async {
    final fortune = FortuneGenerator.generateFortune();
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateUtils.getTodayKey();
    await prefs.setString(todayKey, jsonEncode(fortune.toJson()));
    state = fortune;
  }

  // デバッグ用: 特定のFortuneを直接セットする
  void setFortune(Fortune fortune) {
    state = fortune;
  }

  bool get hasTodayFortune => state != null;
}
