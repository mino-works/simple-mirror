import 'dart:math';
import '../models/fortune.dart';

class FortuneGenerator {
  static final Random _random = Random();

  static List<Fortune> getAllFortunes() {
    return [
      Fortune(
        overallLuck: 95,
        workLuck: 90,
        loveLuck: 95,
        moneyLuck: 85,
        overallTitle: '今日は最高！',
        overallComment: '今日は少し慎重なくらいがちょうどよさそう',
        workComment: '無理に頑張りすぎなくても大丈夫',
        loveComment: '心の声に耳を傾けると良い出会いがありそう',
        moneyComment: '衝動買いは少し待ってから考えてみて',
        dailyMessage: '今日も素敵な一日になりますように',
        expression: HamsterExpression.sparkle,
      ),
      Fortune(
        overallLuck: 80,
        workLuck: 75,
        loveLuck: 85,
        moneyLuck: 70,
        overallTitle: 'スゴそう',
        overallComment: '自然体でいると良い流れが来そう',
        workComment: 'アイデアが浮かびやすい一日になりそう',
        loveComment: '優しい言葉が大切な人との絆を深めそう',
        moneyComment: '節約より使い方の工夫が吉',
        dailyMessage: '小さな幸せを感じながら過ごせますように',
        expression: HamsterExpression.smile,
      ),
      Fortune(
        overallLuck: 65,
        workLuck: 60,
        loveLuck: 70,
        moneyLuck: 55,
        overallTitle: 'まあまあかな',
        overallComment: '小さな変化が大きな喜びにつながりそう',
        workComment: 'チームワークが鍵になりそう',
        loveComment: '自分を大切にすると愛される人になれるかも',
        moneyComment: '思いがけない収入のチャンスがあるかも',
        dailyMessage: '前向きな気持ちで一歩を踏み出してみて',
        expression: HamsterExpression.cheer,
      ),
      Fortune(
        overallLuck: 50,
        workLuck: 45,
        loveLuck: 55,
        moneyLuck: 40,
        overallTitle: 'ちょっと注意',
        overallComment: '周りの人に優しくすると運気が上がるかも',
        workComment: '新しいことに挑戦するのに良いタイミング',
        loveComment: '小さなサプライズが喜ばれそう',
        moneyComment: '大きな出費より小さな喜びを大切に',
        dailyMessage: '自分を信じて進んでください',
        expression: HamsterExpression.cheer,
      ),
      Fortune(
        overallLuck: 35,
        workLuck: 30,
        loveLuck: 40,
        moneyLuck: 25,
        overallTitle: 'ゆっくりしてね',
        overallComment: '今日は少し慎重なくらいがちょうどよさそう',
        workComment: '無理に頑張りすぎなくても大丈夫',
        loveComment: '心の声に耳を傾けると良い出会いがありそう',
        moneyComment: '衝動買いは少し待ってから考えてみて',
        dailyMessage: '今日も素敵な一日になりますように',
        expression: HamsterExpression.worry,
      ),
      Fortune(
        overallLuck: 85,
        workLuck: 80,
        loveLuck: 90,
        moneyLuck: 75,
        overallTitle: 'いい感じ！',
        overallComment: '自然体でいると良い流れが来そう',
        workComment: 'アイデアが浮かびやすい一日になりそう',
        loveComment: '優しい言葉が大切な人との絆を深めそう',
        moneyComment: '節約より使い方の工夫が吉',
        dailyMessage: '小さな幸せを感じながら過ごせますように',
        expression: HamsterExpression.smile,
      ),
      Fortune(
        overallLuck: 70,
        workLuck: 65,
        loveLuck: 75,
        moneyLuck: 60,
        overallTitle: 'がんばれ！',
        overallComment: '小さな変化が大きな喜びにつながりそう',
        workComment: 'チームワークが鍵になりそう',
        loveComment: '自分を大切にすると愛される人になれるかも',
        moneyComment: '思いがけない収入のチャンスがあるかも',
        dailyMessage: '前向きな気持ちで一歩を踏み出してみて',
        expression: HamsterExpression.cheer,
      ),
      Fortune(
        overallLuck: 55,
        workLuck: 50,
        loveLuck: 60,
        moneyLuck: 45,
        overallTitle: '普通だね',
        overallComment: '周りの人に優しくすると運気が上がるかも',
        workComment: '新しいことに挑戦するのに良いタイミング',
        loveComment: '小さなサプライズが喜ばれそう',
        moneyComment: '大きな出費より小さな喜びを大切に',
        dailyMessage: '自分を信じて進んでください',
        expression: HamsterExpression.cheer,
      ),
    ];
  }

  static Fortune generateFortune() {
    final fortunes = getAllFortunes();
    return fortunes[_random.nextInt(fortunes.length)];
  }
}
