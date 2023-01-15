part of '../../glados.dart';

/// A wrapper for a value that knows how to shrink itself.
abstract class Shrinkable<T> {
  factory Shrinkable(T value, Iterable<Shrinkable<T>> Function() shrink) =
  _InlineShrinkableValue<T>;

  /// The actual value itself.
  T get value;

  /// Generates an [Iterable] of [Shrinkable]s that fulfill the following
  /// criteria:
  ///
  /// - They are _similar_ to this: They only differ in little ways.
  /// - They are _simpler_ than this: The transitive hull is finite acyclic. If
  ///   you would call [shrink] on all returned values and on the values
  ///   returned by them etc., this process should terminate sometime.
  Iterable<Shrinkable<T>> shrink();
}
