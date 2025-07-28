// Either type implementation for functional programming
abstract class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight);

  bool get isLeft;
  bool get isRight;

  R? get right => isRight ? (this as Right<L, R>).value : null;
  L? get left => isLeft ? (this as Left<L, R>).value : null;
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) {
    return ifLeft(value);
  }

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) {
    return ifRight(value);
  }

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;
}
