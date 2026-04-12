class Fortune {
  final int overallLuck;
  final int workLuck;
  final int loveLuck;
  final int moneyLuck;
  final String overallTitle;
  final String overallComment;
  final String workComment;
  final String loveComment;
  final String moneyComment;
  final String dailyMessage;
  final HamsterExpression expression;
  final String imagePath;
  final String? backgroundPath;

  Fortune({
    required this.overallLuck,
    required this.workLuck,
    required this.loveLuck,
    required this.moneyLuck,
    required this.overallTitle,
    required this.overallComment,
    required this.workComment,
    required this.loveComment,
    required this.moneyComment,
    required this.dailyMessage,
    required this.expression,
    required this.imagePath,
    this.backgroundPath,
  });

  Map<String, dynamic> toJson() => {
        'overallLuck': overallLuck,
        'workLuck': workLuck,
        'loveLuck': loveLuck,
        'moneyLuck': moneyLuck,
        'overallTitle': overallTitle,
        'overallComment': overallComment,
        'workComment': workComment,
        'loveComment': loveComment,
        'moneyComment': moneyComment,
        'dailyMessage': dailyMessage,
        'expression': expression.name,
      };

  factory Fortune.fromJson(Map<String, dynamic> json) => Fortune(
        overallLuck: json['overallLuck'] as int,
        workLuck: json['workLuck'] as int,
        loveLuck: json['loveLuck'] as int,
        moneyLuck: (json['moneyLuck'] ?? json['socialLuck'] ?? 50) as int,
        overallTitle: (json['overallTitle'] ?? 'まあまあかな') as String,
        overallComment: json['overallComment'] as String,
        workComment: json['workComment'] as String,
        loveComment: json['loveComment'] as String,
        moneyComment: (json['moneyComment'] ?? json['socialComment'] ?? '') as String,
        dailyMessage: json['dailyMessage'] as String,
        expression: HamsterExpression.values.firstWhere(
          (e) => e.name == json['expression'],
          orElse: () => HamsterExpression.normal,
        ),
        imagePath: (json['imagePath'] as String?) ?? 'assets/images/rabbits/default/rabbit_01.png',
        backgroundPath: json['backgroundPath'] as String?,
      );
}

enum HamsterExpression { normal, smile, sparkle, cheer, worry, proud }
