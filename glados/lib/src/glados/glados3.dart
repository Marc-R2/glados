part of '../../glados.dart';

/// Just like [Glados], but with three parameters.
/// See [Glados] for more information about the arguments.
class Glados3<First, Second, Third> {
  Glados3([
    Generator<First>? firstGenerator,
    Generator<Second>? secondGenerator,
    Generator<Third>? thirdGenerator,
    ExploreConfig? explore,
  ])  : firstGenerator =
      firstGenerator ?? Any.defaultForWithBeautifulError<First>(3, 0),
        secondGenerator =
            secondGenerator ?? Any.defaultForWithBeautifulError<Second>(3, 1),
        thirdGenerator =
            thirdGenerator ?? Any.defaultForWithBeautifulError<Third>(3, 2),
        explore = explore ?? ExploreConfig();

  final Generator<First> firstGenerator;
  final Generator<Second> secondGenerator;
  final Generator<Third> thirdGenerator;
  final ExploreConfig explore;

  @isTest
  void test(
      String description,
      Tester3<First, Second, Third> body, {
        String? testOn,
        test_package.Timeout? timeout,
        dynamic skip,
        dynamic tags,
        Map<String, dynamic>? onPlatform,
        int? retry,
      }) {
    Glados(
      any.combine3(
        firstGenerator,
        secondGenerator,
        thirdGenerator,
            (First a, Second b, Third c) => [a, b, c],
      ),
      explore,
    ).test(
      description,
          (input) => body(input[0] as First, input[1] as Second, input[2] as Third),
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry,
    );
  }

  @isTest
  void testWithRandom(
      String description,
      Tester3WithRandom<First, Second, Third> body, {
        String? testOn,
        test_package.Timeout? timeout,
        dynamic skip,
        dynamic tags,
        Map<String, dynamic>? onPlatform,
        int? retry,
      }) {
    final random = explore.random.nextRandom();
    test(
      description,
          (a, b, c) => body(a, b, c, random.nextRandom()),
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry,
    );
  }
}
