part of '../../glados.dart';

/// An [Generator] makes it possible to use [Glados] to test type [T].
/// Generates a new [Shrinkable] of type [T], using [size] as a rough
/// complexity estimate. The [random] instance should be used as a source for
/// all pseudo-randomness.
typedef Generator<T> = Shrinkable<T> Function(math.Random random, int size);
