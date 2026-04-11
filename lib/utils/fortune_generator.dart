import 'dart:math';
import '../models/fortune.dart';

class FortuneGenerator {
  static final Random _random = Random();

  static const String _defaultDir = 'assets/images/rabbits/default';

  static List<Fortune> getAllFortunes() {
    return [
      // 1. 全項目★5
      Fortune(
        overallLuck: 100,
        loveLuck: 100,
        moneyLuck: 100,
        workLuck: 100,
        overallTitle: '伝説級の一日',
        overallComment: '何をやってもうまくいく、そんな日。',
        loveComment: '運命の出会いがあるかもしれない。',
        moneyComment: 'お金の流れが最高潮。',
        workComment: '仕事もすべて追い風。',
        dailyMessage: '今日のあなた、無敵です。全部うまくいく気しかしない。',
        expression: HamsterExpression.sparkle,
        imagePath: '$_defaultDir/rabbit_guts_pose.png',
      ),
      // 2. 恋愛★4 / 金★4 / 仕事★5
      Fortune(
        overallLuck: 85,
        loveLuck: 80,
        moneyLuck: 80,
        workLuck: 100,
        overallTitle: '今日の主人公はあなた',
        overallComment: '物語が動き出す、そんな予感のある一日。',
        loveComment: '気になる人への一歩が吉。',
        moneyComment: 'コツコツが実を結ぶ日。',
        workComment: '実力を発揮するチャンスが来る。',
        dailyMessage: '物語が動き出す予感。チャンスは逃さないで！',
        expression: HamsterExpression.proud,
        imagePath: '$_defaultDir/rabbit_hero_run.png',
      ),
      // 3. 恋愛★5 / 金★3 / 仕事★4
      Fortune(
        overallLuck: 80,
        loveLuck: 100,
        moneyLuck: 60,
        workLuck: 80,
        overallTitle: '恋愛偏差値爆上がり中',
        overallComment: '人に好かれやすいオーラが出ている日。',
        loveComment: '気づいたら囲まれてるかも。',
        moneyComment: '財布のひもは少し締めておいて。',
        workComment: '人間関係がうまく回る。',
        dailyMessage: '今日のあなた、なぜかモテオーラ出てます。自覚して。',
        expression: HamsterExpression.sparkle,
        imagePath: '$_defaultDir/rabbit_wink_heart.png',
      ),
      // 4. 恋愛★3 / 金★4 / 仕事★4
      Fortune(
        overallLuck: 70,
        loveLuck: 60,
        moneyLuck: 80,
        workLuck: 80,
        overallTitle: '着実に上昇中',
        overallComment: '地道な努力が形になってくる日。',
        loveComment: '焦らず自然体でいると吉。',
        moneyComment: '堅実な判断が○。',
        workComment: '積み重ねがじわじわ効いてくる。',
        dailyMessage: '地味にすごい一日になりそう。後から「あの日か」って思うやつ。',
        expression: HamsterExpression.smile,
        imagePath: '$_defaultDir/rabbit_climb_stairs.png',
      ),
      // 5. 全項目★3
      Fortune(
        overallLuck: 60,
        loveLuck: 60,
        moneyLuck: 60,
        workLuck: 60,
        overallTitle: '可もなく不可もなく…',
        overallComment: '普通の日こそ、実は奇跡かもしれない。',
        loveComment: '関係は現状維持。それでいい。',
        moneyComment: '大きな変動なし。安定の日。',
        workComment: 'マイペースが一番。',
        dailyMessage: '普通の日こそ、実は奇跡。今日も生きてえらい。',
        expression: HamsterExpression.normal,
        imagePath: '$_defaultDir/rabbit_relax_sit.png',
      ),
      // 6. 恋愛★2 / 金★3 / 仕事★4
      Fortune(
        overallLuck: 60,
        loveLuck: 40,
        moneyLuck: 60,
        workLuck: 80,
        overallTitle: '仕事だけ全力デー',
        overallComment: '仕事に集中すると吉。恋愛はのんびり。',
        loveComment: '今日は恋愛より自分磨きに専念を。',
        moneyComment: '必要なものだけ買うのが吉。',
        workComment: '仕事の神様が今日だけついてる。',
        dailyMessage: '恋愛はお休み。今日は仕事の神様があなたについてる。',
        expression: HamsterExpression.cheer,
        imagePath: '$_defaultDir/rabbit_work_pc.png',
      ),
      // 7. 恋愛★2 / 金★2 / 仕事★3
      Fortune(
        overallLuck: 45,
        loveLuck: 40,
        moneyLuck: 40,
        workLuck: 60,
        overallTitle: '今日はちょっと待って',
        overallComment: '勢いで動くより、立ち止まる勇気が大切な日。',
        loveComment: '感情的な発言には気をつけて。',
        moneyComment: '衝動買いは明日に持ち越して。',
        workComment: '確認作業を丁寧にやると〇。',
        dailyMessage: '勢いで動くと後悔するかも。深呼吸してから動こう。',
        expression: HamsterExpression.worry,
        imagePath: '$_defaultDir/rabbit_stop_hand.png',
      ),
      // 8. 恋愛★2 / 金★1 / 仕事★2
      Fortune(
        overallLuck: 35,
        loveLuck: 40,
        moneyLuck: 20,
        workLuck: 40,
        overallTitle: '全力で休んでいい日',
        overallComment: '今日は充電日。無理しないのが正解。',
        loveComment: '自分を大切にすることが先決。',
        moneyComment: '財布は閉じておいて。',
        workComment: '最低限だけやればOK。',
        dailyMessage: '頑張ってきたんだから、今日くらいだらけていい。えらい。',
        expression: HamsterExpression.worry,
        imagePath: '$_defaultDir/rabbit_sleep_futon.png',
      ),
      // 9. 恋愛★1 / 金★2 / 仕事★2
      Fortune(
        overallLuck: 30,
        loveLuck: 20,
        moneyLuck: 40,
        workLuck: 40,
        overallTitle: '充電期間中につき',
        overallComment: '今は動かず、蓄える時期。',
        loveComment: '恋愛より自分時間を優先して。',
        moneyComment: '節約モードが吉。',
        workComment: 'ペースを落としてコツコツと。',
        dailyMessage: '今は蓄える時期。じっとしてるのも立派な作戦です。',
        expression: HamsterExpression.worry,
        imagePath: '$_defaultDir/rabbit_sad.png',
      ),
      // 10. 全項目★1
      Fortune(
        overallLuck: 20,
        loveLuck: 20,
        moneyLuck: 20,
        workLuck: 20,
        overallTitle: '厄日かもしれない…',
        overallComment: '今日は何もしないのが一番の作戦かも。',
        loveComment: '告白も喧嘩も今日はNG。',
        moneyComment: '財布は家に置いていこう。',
        workComment: 'ミスしやすい日。慎重に。',
        dailyMessage: '今日は何もしないのが正解かも。おうちで寝ててください。',
        expression: HamsterExpression.worry,
        imagePath: '$_defaultDir/rabbit_rain_cloud.png',
      ),
    ];
  }

  static Fortune generateFortune() {
    final fortunes = getAllFortunes();
    return fortunes[_random.nextInt(fortunes.length)];
  }
}
