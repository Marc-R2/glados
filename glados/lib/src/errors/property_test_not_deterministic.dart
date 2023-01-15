part of '../../glados.dart';

/// For the same input, a property test sometimes throws an exceptions and
/// sometimes doesn't. Property tests should be deterministic though.
class PropertyTestNotDeterministic implements Exception {
  PropertyTestNotDeterministic(this.input, this.output);

  final dynamic input;
  final dynamic output;

  @override
  String toString() {
    return Flow([
      Paragraph('A property test behaved undeterministically. For the input '
          '$input, it failed the first time, but succeeded the second time '
          'with output $output.'),
      Paragraph('Make sure that if given the same input, the property test '
          'always behaves the same way.'),
    ]).toString();
  }
}
