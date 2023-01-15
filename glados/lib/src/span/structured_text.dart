part of '../../glados.dart';

abstract class StructuredText {
  Iterable<String> toLines(int width);

  @override
  String toString() => toLines(60).join('\n');
}
