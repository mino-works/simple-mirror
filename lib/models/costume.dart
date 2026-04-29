enum Costume {
  normal,
  carrot,
  dress,
  hiphop;

  /// ローカライズキー
  String get labelKey {
    switch (this) {
      case Costume.normal:
        return 'costume_normal';
      case Costume.carrot:
        return 'costume_carrot';
      case Costume.dress:
        return 'costume_dress';
      case Costume.hiphop:
        return 'costume_hiphop';
    }
  }

  /// 解放に必要な累計ログイン日数（0 = 最初から利用可能）
  int get unlockDays {
    switch (this) {
      case Costume.normal:
        return 0;
      case Costume.carrot:
        return 3;
      case Costume.dress:
        return 7;
      case Costume.hiphop:
        return 14;
    }
  }

  String get directory {
    switch (this) {
      case Costume.normal:
        return 'assets/images/rabbits/default';
      case Costume.carrot:
        return 'assets/images/rabbits/carrot';
      case Costume.dress:
        return 'assets/images/rabbits/dress';
      case Costume.hiphop:
        return 'assets/images/rabbits/hiphop';
    }
  }

  String get previewImage => '$directory/rabbit_star.png';

  String applyTo(String basePath) {
    if (this == Costume.normal) return basePath;
    final fileName = basePath.split('/').last;
    return '$directory/$fileName';
  }
}
