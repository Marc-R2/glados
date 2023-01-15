part of '../../glados.dart';

/// Useful methods on [Generator]s.
extension GeneratorUtils<T> on Generator<T> {
  Generator<R> map<R>(R Function(T value) mapper) {
    return (random, size) {
      final value = this(random, size);
      return MappedShrinkableValue<T, R>(value, mapper);
    };
  }

  Generator<R> bind<R>(Generator<R> Function(T value) mapper) {
    return (random, size) => map(mapper)(random, size).value(random, size);
  }

  Generator<T?> get nullable {
    return (random, size) {
      final value = this(random, size);
      return NullableShrinkableValue(value);
    };
  }
}
