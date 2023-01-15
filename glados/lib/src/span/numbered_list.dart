part of '../../glados.dart';

class NumberedList extends StructuredText {
  NumberedList(this.items);

  final List<StructuredText> items;

  @override
  Iterable<String> toLines(int width) sync* {
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      var isFirstLine = true;
      yield* item.toLines(width - 4).map((line) {
        final prefix = isFirstLine ? '${(i + 1)}.' : '';
        isFirstLine = false;
        return '${prefix.padRight(4)}$line';
      });
    }
  }
}
