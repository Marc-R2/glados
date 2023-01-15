part of '../../glados.dart';

class Code extends StructuredText {
  Code(this.code);

  final List<String> code;

  @override
  Iterable<String> toLines(int width) sync* {
    yield* code;
    yield '';
  }
}
