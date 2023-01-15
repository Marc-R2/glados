part of '../../glados.dart';

/// An inline version for the [Shrinkable].
class _InlineShrinkableValue<T> implements Shrinkable<T> {
  _InlineShrinkableValue(this.value, this._shrinker);

  @override
  final T value;
  final Iterable<Shrinkable<T>> Function() _shrinker;

  @override
  Iterable<Shrinkable<T>> shrink() => _shrinker();

  @override
  String toString() => 'Shrinkable<$T>($value)';
}
