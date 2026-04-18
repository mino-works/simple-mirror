import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _Delegate();

  static const supportedLocales = [Locale('ja'), Locale('en')];

  static const _strings = <String, Map<String, String>>{
    'ja': {
      'app_name': 'ミラー占い',
      // MirrorScreen
      'mirror': 'ミラー',
      'others_view': '他人から',
      'divining': '占い中...',
      'fortune_done': '占い完了！',
      'outfit': '着せ替え',
      // FortuneResultScreen
      'love': '恋愛運',
      'money': '金運',
      'work': '仕事運',
      'rabbit_message': '占い師ウサギのひとこと',
      'back_to_mirror': '鏡に戻る',
      'watch_ad': 'もう一度占う',
      'watch_ad_unavailable': '',
      // CostumeScreen
      'outfits_title': 'きせかえ',
      'outfits_subtitle': 'あなたのウサギをおしゃれに',
      'back': 'もどる',
      'coming_soon': 'Coming soon',
      // Costume names
      'costume_normal': 'ノーマル',
      'costume_carrot': '人参コスプレ',
      'costume_dress': 'ドレス',
      // Menu
      'menu_premium': 'プレミアム',
      'menu_premium_desc': '占い無制限',
      'menu_premium_unavailable': '課金機能は近日公開予定です',
      'menu_language': '言語',
      'lang_ja': '日本語',
      'lang_en': 'English',
      // IAP
      'plan_name': '無制限プラン',
      'plan_tagline': '何度でも占い放題',
      'plan_cta': 'もっと占う',
      'plan_cta_sub': '無制限プランで占い放題',
      'redivine': 'もう一度占う',
      'premium_subscribe': '無制限プランに登録',
      'premium_restore': '購入を復元',
      'premium_loading': '処理中...',
      'premium_already': '無制限プラン加入中',
      'premium_active_badge': '無制限プラン',
      // Legal
      'menu_support': 'サポート',
      'menu_terms': '利用規約',
      'menu_privacy': 'プライバシーポリシー',
    },
    'en': {
      'app_name': 'Mirror Fortune',
      'mirror': 'Mirror',
      'others_view': "Others' View",
      'divining': 'Divining...',
      'fortune_done': 'Fortune Ready!',
      'outfit': 'Outfits',
      'love': 'Love',
      'money': 'Money',
      'work': 'Work',
      'rabbit_message': "Rabbit's Message",
      'back_to_mirror': 'Back to Mirror',
      'watch_ad': 'Divine Again',
      'watch_ad_unavailable': '',
      'outfits_title': 'Outfits',
      'outfits_subtitle': 'Dress up your rabbit!',
      'back': 'Back',
      'coming_soon': 'Coming soon',
      'costume_normal': 'Normal',
      'costume_carrot': 'Carrot',
      'costume_dress': 'Dress',
      'menu_premium': 'Premium',
      'menu_premium_desc': 'Unlimited fortunes',
      'menu_premium_unavailable': 'Purchase feature coming soon',
      'menu_language': 'Language',
      'lang_ja': '日本語',
      'lang_en': 'English',
      // IAP
      'plan_name': 'Unlimited Plan',
      'plan_tagline': 'Unlimited fortunes',
      'plan_cta': 'Divine More',
      'plan_cta_sub': 'Unlimited fortunes anytime',
      'redivine': 'Divine Again',
      'premium_subscribe': 'Subscribe to Unlimited Plan',
      'premium_restore': 'Restore Purchases',
      'premium_loading': 'Processing...',
      'premium_already': 'Unlimited Plan Active',
      'premium_active_badge': 'Unlimited Plan',
      // Legal
      'menu_support': 'Support',
      'menu_terms': 'Terms of Service',
      'menu_privacy': 'Privacy Policy',
    },
  };

  String get(String key) =>
      _strings[locale.languageCode]?[key] ?? _strings['ja']![key] ?? key;

  String daysLeft(int n) {
    if (locale.languageCode == 'en') return '$n days left';
    return 'あと$n日';
  }
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) =>
      ['ja', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_Delegate old) => false;
}
