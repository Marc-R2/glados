part of '../../glados.dart';

class Paragraph extends StructuredText {
  Paragraph._(this.text, this.addNewline);
  Paragraph([String text = '']) : this._(text, true);
  Paragraph.noNl(String text) : this._(text, false);

  final String text;
  final bool addNewline;

  @override
  Iterable<String> toLines(int width) sync* {
    yield* Text(text).toLines(width);
    if (addNewline) yield '';
  }
}
