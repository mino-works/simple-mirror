enum Costume {
  normal,
  carrot,
  dress;

  String get label {
    switch (this) {
      case Costume.normal:
        return 'ノーマル';
      case Costume.carrot:
        return '人参コスプレ';
      case Costume.dress:
        return 'ドレス';
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
    }
  }

  String get previewImage => '$directory/rabbit_star.png';

  /// basePath（defaultのパス）をこのコスチュームのパスに変換する
  String applyTo(String basePath) {
    if (this == Costume.normal) return basePath;
    final fileName = basePath.split('/').last;
    return '$directory/$fileName';
  }
}
