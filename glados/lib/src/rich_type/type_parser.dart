part of '../../glados.dart';

class _TypeParser {
  _TypeParser(this.string);

  final String string;
  int cursor = 0;

  String get current => cursor < string.length ? string[cursor] : '';
  void advance() => cursor++;
  bool get isDone => cursor == string.length;

  RichType parse() {
    var name = StringBuffer();
    var types = <RichType>[];
    while (!['<', '>', ',', ''].contains(current)) {
      name.write(current);
      advance();
    }
    if (name.isEmpty) throw FormatException("Type '$string' has no name");
    if (current == '>' || current == ',') {
      return RichType(name.toString());
    }
    if (current == '<') {
      while (current == '<' || current == ',') {
        advance();
        types.add(parse());
      }
      if (current != '>') {
        throw FormatException("'>' expected in '$string' at position $current");
      }
      advance();
    }
    return RichType(name.toString(), types);
  }
}
