/// 占いコンテンツの英語翻訳。
/// キーは日本語タイトル（FortuneGenerator の overallTitle）。
class FortuneTranslations {
  static const _data = <String, _FortuneTr>{
    '今日の主役はあなた': _FortuneTr(
      title: "Today's Star is You",
      message:
          "People naturally gravitate toward you today. Trust yourself and step forward — everything will go your way!",
    ),
    '伝説級の一日': _FortuneTr(
      title: "A Legendary Day",
      message:
          "Your hard work is finally paying off. This is your moment to shine. Take on new challenges with full confidence!",
    ),
    '恋愛オーラ急上昇': _FortuneTr(
      title: "Love Aura Skyrocketing",
      message:
          "Your charm is magnetic today. New connections are possible — just be yourself and something wonderful may follow.",
    ),
    '仕事がうまくいきそう': _FortuneTr(
      title: "Work is Going Your Way",
      message:
          "Focus and judgment are perfectly in sync. You'll be the go-to person today — embrace the spotlight.",
    ),
    'じわじわ運気アップ': _FortuneTr(
      title: "Luck is Quietly Rising",
      message:
          "Progress may feel slow, but it's real. Keep going — the small steps you take today will add up to something big.",
    ),
    'おだやかな一日': _FortuneTr(
      title: "A Peaceful Day",
      message:
          "No big waves today, just a comfortable flow. Stay consistent and let your routine carry you gently forward.",
    ),
    '休むが吉': _FortuneTr(
      title: "Rest is Best",
      message:
          "Pushing hard isn't the answer today. Give yourself permission to rest and recharge — it's the smartest move you can make.",
    ),
    '力をためよう': _FortuneTr(
      title: "Time to Build Strength",
      message:
          "Focus inward rather than outward today. Reflect and prepare, and your energy will grow for the days ahead.",
    ),
    '踏ん張りどき': _FortuneTr(
      title: "Hold Your Ground",
      message:
          "Things may feel tough, but getting through this will shift your momentum. Focus on what's right in front of you.",
    ),
    'ダメそう...': _FortuneTr(
      title: "Rough Day Ahead...",
      message:
          "Sometimes the best strategy is to stay low. Skip big decisions and let the day pass quietly — tomorrow is a new start.",
    ),
  };

  static String title(String jaTitle, String langCode) {
    if (langCode != 'en') return jaTitle;
    return _data[jaTitle]?.title ?? jaTitle;
  }

  static String message(String jaMessage, String jaTitle, String langCode) {
    if (langCode != 'en') return jaMessage;
    return _data[jaTitle]?.message ?? jaMessage;
  }
}

class _FortuneTr {
  final String title;
  final String message;
  const _FortuneTr({required this.title, required this.message});
}
