part of '../../glados.dart';

class MappedShrinkableValue<T, R> implements Shrinkable<R> {
  MappedShrinkableValue(this.originalValue, this.mapper);

  final Shrinkable<T> originalValue;
  final R Function(T value) mapper;

  @override
  R get value => mapper(originalValue.value);

  @override
  Iterable<Shrinkable<R>> shrink() {
    return originalValue.shrink().map((value) {
      return MappedShrinkableValue(value, mapper);
    });
  }
}
