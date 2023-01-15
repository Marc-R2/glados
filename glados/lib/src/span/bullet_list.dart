part of '../../glados.dart';

class BulletList extends StructuredText {
  BulletList(this.items);

  final List<StructuredText> items;

  @override
  Iterable<String> toLines(int width) sync* {
    for (final item in items) {
      var isFirstLine = true;
      yield* item.toLines(width - 2).map((line) {
        var isFirst = isFirstLine;
        isFirstLine = false;
        return isFirst ? '* $line' : '  $line';
      });
    }
  }
}
