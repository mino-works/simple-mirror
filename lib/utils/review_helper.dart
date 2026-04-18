import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewHelper {
  static const _keyFortune = 'review_shown_fortune';
  static const _keyCostume = 'review_shown_costume';

  static Future<void> requestForFortune() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyFortune) == true) return;
    await prefs.setBool(_keyFortune, true);
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    }
  }

  static Future<void> requestForCostume() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyCostume) == true) return;
    await prefs.setBool(_keyCostume, true);
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    }
  }
}
