part of '../../glados.dart';

class NullableShrinkableValue<T> implements Shrinkable<T?> {
  NullableShrinkableValue(this.originalValue);

  final Shrinkable<T> originalValue;

  @override
  T? get value => originalValue.value;

  @override
  Iterable<Shrinkable<T?>> shrink() {
    final shrinkableNull = Shrinkable<T?>(null, () => []);
    return originalValue
        .shrink()
        .cast<Shrinkable<T?>>()
        .followedBy([shrinkableNull]);
  }
}
