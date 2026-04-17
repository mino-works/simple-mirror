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
      'watch_ad': '広告を見てもう一度占う',
      'watch_ad_unavailable': '広告機能は近日公開予定です',
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
      'menu_premium_desc': '占い無制限・全コスチューム解放',
      'menu_premium_unavailable': '課金機能は近日公開予定です',
      'menu_language': '言語',
      'lang_ja': '日本語',
      'lang_en': 'English',
    },
    'en': {
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
      'watch_ad': 'Watch ad for another fortune',
      'watch_ad_unavailable': 'Ad feature coming soon',
      'outfits_title': 'Outfits',
      'outfits_subtitle': 'Dress up your rabbit!',
      'back': 'Back',
      'coming_soon': 'Coming soon',
      'costume_normal': 'Normal',
      'costume_carrot': 'Carrot',
      'costume_dress': 'Dress',
      'menu_premium': 'Premium',
      'menu_premium_desc': 'Unlimited fortunes & all costumes',
      'menu_premium_unavailable': 'Purchase feature coming soon',
      'menu_language': 'Language',
      'lang_ja': '日本語',
      'lang_en': 'English',
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
