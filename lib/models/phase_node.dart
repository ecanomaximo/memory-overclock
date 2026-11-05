enum PhaseStatus { locked, current, completed }

class PhaseNode {
  final int id;
  final String title;
  final bool isBoss;
  final double xRatio; // 0.0 (esquerda) a 1.0 (direita)
  final PhaseStatus status;

  const PhaseNode({
    required this.id,
    required this.title,
    this.isBoss = false,
    this.xRatio = 0.5,
    this.status = PhaseStatus.locked,
  });

  bool get isLocked => status == PhaseStatus.locked;
  bool get isCurrent => status == PhaseStatus.current;
  bool get isCompleted => status == PhaseStatus.completed;

  PhaseNode copyWith({
    int? id,
    String? title,
    bool? isBoss,
    double? xRatio,
    PhaseStatus? status,
  }) {
    return PhaseNode(
      id: id ?? this.id,
      title: title ?? this.title,
      isBoss: isBoss ?? this.isBoss,
      xRatio: xRatio ?? this.xRatio,
      status: status ?? this.status,
    );
  }
}
