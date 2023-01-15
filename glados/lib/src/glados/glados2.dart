part of '../../glados.dart';

/// Just like [Glados], but with two parameters.
/// See [Glados] for more information about the arguments.
class Glados2<First, Second> {
  Glados2([
    Generator<First>? firstGenerator,
    Generator<Second>? secondGenerator,
    ExploreConfig? explore,
  ])  : firstGenerator =
      firstGenerator ?? Any.defaultForWithBeautifulError<First>(2, 0),
        secondGenerator =
            secondGenerator ?? Any.defaultForWithBeautifulError<Second>(2, 1),
        explore = explore ?? ExploreConfig();

  final Generator<First> firstGenerator;
  final Generator<Second> secondGenerator;
  final ExploreConfig explore;

  @isTest
  void test(
      String description,
      Tester2<First, Second> body, {
        String? testOn,
        test_package.Timeout? timeout,
        dynamic skip,
        dynamic tags,
        Map<String, dynamic>? onPlatform,
        int? retry,
      }) {
    Glados(
      any.combine2(
        firstGenerator,
        secondGenerator,
            (First a, Second b) => [a, b],
      ),
      explore,
    ).test(
      description,
          (input) => body(input[0] as First, input[1] as Second),
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
      Tester2WithRandom<First, Second> body, {
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
          (a, b) => body(a, b, random.nextRandom()),
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry,
    );
  }
}
