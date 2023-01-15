part of '../../glados.dart';

class Text extends StructuredText {
  Text(this.text);

  final String text;

  @override
  Iterable<String> toLines(int width) sync* {
    final words = text.split(' ');
    var line = StringBuffer();

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (line.length + (i == 0 ? 0 : 1) + word.length <= width) {
        if (i > 0) line.write(' ');
        line.write(word);
      } else {
        yield line.toString();
        line = StringBuffer(word);
      }
    }
    if (line.toString().trim().isNotEmpty) {
      yield line.toString();
    }
  }
}
