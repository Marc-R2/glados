part of '../../glados.dart';

class Flow extends StructuredText {
  Flow(this.texts);

  final List<StructuredText> texts;

  @override
  Iterable<String> toLines(int width) sync* {
    yield* texts.expand((text) => text.toLines(width));
  }
}
