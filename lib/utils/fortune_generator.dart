import 'dart:math';
import '../models/fortune.dart';

class FortuneGenerator {
  static final Random _random = Random();

  static const String _defaultDir = 'assets/images/rabbits/default';
  static const String _bgDir = 'assets/images/backgrounds';

  static List<Fortune> getAllFortunes() {
    return [
      // 1. 全項目★5
      Fortune(
        overallLuck: 100,
        loveLuck: 100,
        moneyLuck: 100,
        workLuck: 100,
        overallTitle: '今日の主役はあなた',
        overallComment: '何をやってもうまくいく、そんな日。',
        loveComment: '運命の出会いがあるかもしれない。',
        moneyComment: 'お金の流れが最高潮。',
        workComment: '仕事もすべて追い風。',
        dailyMessage: '今日は自然とあなたに注目が集まりそう。何をやっても上手くいくので迷わず一歩前に出よう！',
        expression: HamsterExpression.sparkle,
        imagePath: '$_defaultDir/rabbit_star.png',
        backgroundPath: '$_bgDir/star_bg.jpeg',
      ),
      // 2. 恋愛★5 / 金★4 / 仕事★5
      Fortune(
        overallLuck: 90,
        loveLuck: 100,
        moneyLuck: 80,
        workLuck: 100,
        overallTitle: '伝説級の一日',
        overallComment: '努力が形になる、記念すべき一日。',
        loveComment: '気持ちを伝えるなら今日がチャンス。',
        moneyComment: 'コツコツが実を結ぶ日。',
        workComment: '実力を発揮するチャンスが来る。',
        dailyMessage: '新しい挑戦に向けて気持ちが高まりやすい日☆ 今までの努力が形になり、その成果を見せるタイミングです。',
        expression: HamsterExpression.sparkle,
        imagePath: '$_defaultDir/rabbit_legend.png',
        backgroundPath: '$_bgDir/great_bg.jpeg',
      ),
      // 3. 恋愛★5 / 金★3 / 仕事★4
      Fortune(
        overallLuck: 80,
        loveLuck: 100,
        moneyLuck: 60,
        workLuck: 80,
        overallTitle: '恋愛オーラ急上昇',
        overallComment: '人に好かれやすいオーラが出ている日。',
        loveComment: '気づいたら囲まれてるかも。',
        moneyComment: '財布のひもは少し締めておいて。',
        workComment: '人間関係がうまく回る。',
        dailyMessage: 'あなたの魅力が伝わりやすく、新しい出会いの予感☆ 飾るより、素直に話すと運気が上がります。',
        expression: HamsterExpression.sparkle,
        imagePath: '$_defaultDir/rabbit_love.png',
        backgroundPath: '$_bgDir/great_bg.jpeg',
      ),
      // 4. 恋愛★3 / 金★4 / 仕事★5
      Fortune(
        overallLuck: 80,
        loveLuck: 60,
        moneyLuck: 80,
        workLuck: 100,
        overallTitle: '仕事がうまくいきそう',
        overallComment: '集中力と判断力がかみ合う一日。',
        loveComment: '今日は恋愛より自分磨きに専念を。',
        moneyComment: '堅実な判断が○。',
        workComment: '仕事の神様が今日だけついてる。',
        dailyMessage: '集中力と判断力がかみ合いやすく、仕事や勉強が進みそうです。周囲から頼られる一日になりそう。',
        expression: HamsterExpression.cheer,
        imagePath: '$_defaultDir/rabbit_work.png',
        backgroundPath: '$_bgDir/great_bg.jpeg',
      ),
      // 5. 恋愛★3 / 金★4 / 仕事★3
      Fortune(
        overallLuck: 65,
        loveLuck: 60,
        moneyLuck: 80,
        workLuck: 60,
        overallTitle: 'じわじわ運気アップ',
        overallComment: '地道な努力が形になってくる日。',
        loveComment: '焦らず自然体でいると吉。',
        moneyComment: '小さな積み重ねが実を結ぶ。',
        workComment: '積み重ねがじわじわ効いてくる。',
        dailyMessage: '派手さはなくても、少しずつ運が上向いていく日。小さなことでもやめずに続けるのが開運のポイントです。',
        expression: HamsterExpression.smile,
        imagePath: '$_defaultDir/rabbit_good.png',
        backgroundPath: '$_bgDir/normal_bg.jpeg',
      ),
      // 6. 全項目★3
      Fortune(
        overallLuck: 60,
        loveLuck: 60,
        moneyLuck: 60,
        workLuck: 60,
        overallTitle: 'おだやかな一日',
        overallComment: '普通の日こそ、実は奇跡かもしれない。',
        loveComment: '関係は現状維持。それでいい。',
        moneyComment: '大きな変動なし。安定の日。',
        workComment: 'マイペースが一番。',
        dailyMessage: '大きな波はなく過ごしやすい日です。急いで何かを変えるより続けることで運気が整います。',
        expression: HamsterExpression.normal,
        imagePath: '$_defaultDir/rabbit_normal.png',
        backgroundPath: '$_bgDir/normal_bg.jpeg',
      ),
      // 7. 全項目★2（背景なし・ウサギ画像に背景込み）
      Fortune(
        overallLuck: 40,
        loveLuck: 40,
        moneyLuck: 40,
        workLuck: 40,
        overallTitle: '休むが吉',
        overallComment: '今日は充電日。無理しないのが正解。',
        loveComment: '自分を大切にすることが先決。',
        moneyComment: '財布は閉じておいて。',
        workComment: '最低限だけやればOK。',
        dailyMessage: '無理に頑張るよりしっかり休むほうがよさそうです。自分をいたわる時間をつくってみて。',
        expression: HamsterExpression.worry,
        imagePath: '$_defaultDir/rabbit_onsen.png',
      ),
      // 8. 恋愛★2 / 金★2 / 仕事★1
      Fortune(
        overallLuck: 35,
        loveLuck: 40,
        moneyLuck: 40,
        workLuck: 20,
        overallTitle: '力をためよう',
        overallComment: '今は動かず、蓄える時期。',
        loveComment: '恋愛より自分時間を優先して。',
        moneyComment: '節約モードが吉。',
        workComment: 'ペースを落としてコツコツと。',
        dailyMessage: '前に出るより内側を整えることが大事な日です。焦って答えを出さず、準備に目を向けると運が育ちます。',
        expression: HamsterExpression.worry,
        imagePath: '$_defaultDir/rabbit_sleep.png',
        backgroundPath: '$_bgDir/normal_bg.jpeg',
      ),
      // 9. 恋愛★1 / 金★2 / 仕事★2
      Fortune(
        overallLuck: 30,
        loveLuck: 20,
        moneyLuck: 40,
        workLuck: 40,
        overallTitle: '踏ん張りどき',
        overallComment: '勢いで動くより、立ち止まる勇気が大切な日。',
        loveComment: '感情的な発言には気をつけて。',
        moneyComment: '衝動買いは明日に持ち越して。',
        workComment: '確認作業を丁寧にやると〇。',
        dailyMessage: 'しんどくても、ここを越えることで流れが変わりそうです。完璧にやろうとせず、まずは目の前のことに集中して。',
        expression: HamsterExpression.worry,
        imagePath: '$_defaultDir/rabbit_reset.png',
        backgroundPath: '$_bgDir/rain_bg.jpeg',
      ),
      // 10. 全項目★1
      Fortune(
        overallLuck: 20,
        loveLuck: 20,
        moneyLuck: 20,
        workLuck: 20,
        overallTitle: 'ダメそう...',
        overallComment: '今日は何もしないのが一番の作戦かも。',
        loveComment: '告白も喧嘩も今日はNG。',
        moneyComment: '財布は家に置いていこう。',
        workComment: 'ミスしやすい日。慎重に。',
        dailyMessage: '流れに逆らわないほうがよさそうです。大事な決断は急がず、静かにやり過ごすことを意識すると傷が浅く済みます。',
        expression: HamsterExpression.worry,
        imagePath: '$_defaultDir/rabbit_bad.png',
        backgroundPath: '$_bgDir/rain_bg.jpeg',
      ),
    ];
  }

  static Fortune generateFortune() {
    final fortunes = getAllFortunes();
    return fortunes[_random.nextInt(fortunes.length)];
  }
}
