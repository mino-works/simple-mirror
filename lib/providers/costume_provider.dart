import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/costume.dart';

class CostumeNotifier extends StateNotifier<Costume> {
  CostumeNotifier() : super(Costume.normal) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('costume');
    if (saved != null) {
      state = Costume.values.firstWhere(
        (c) => c.name == saved,
        orElse: () => Costume.normal,
      );
    }
  }

  Future<void> select(Costume costume) async {
    state = costume;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('costume', costume.name);
  }
}

final costumeProvider = StateNotifierProvider<CostumeNotifier, Costume>(
  (ref) => CostumeNotifier(),
);
