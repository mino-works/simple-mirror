enum Costume {
  normal,
  carrot;

  String get label {
    switch (this) {
      case Costume.normal:
        return 'ノーマル';
      case Costume.carrot:
        return '人参コスプレ';
    }
  }

  String get directory {
    switch (this) {
      case Costume.normal:
        return 'assets/images/rabbits/default';
      case Costume.carrot:
        return 'assets/images/rabbits/carrot';
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
