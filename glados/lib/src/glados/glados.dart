part of '../../glados.dart';

/// The entrypoint for [Glados] testing.
///
/// Usually, you directly call [test] on the [Glados] instance:
///
/// ```dart
/// Glados<int>().test('blub', (input) { ... });
/// ```
///
/// # Custom generators
///
/// The [generator] can be used to customize how values are generated and
/// shrunk. For example, if you test code that expects email addresses, it may
/// be inefficient to use the default [Generator] for [String] – if the tests
/// contain some sanity checks at the beginning, only a tiny fraction of values
/// actually passes through the code.
/// In that case, create a custom [Generator]. To do that, add an extension on
/// [Any], which is a namespace for [Generator]s:
///
/// ```dart
/// extension EmailAny on Any {
///   Generator<String> get email => simple(
///     generate: (random, size) => /* code for generating emails */,
///     shrink: (input) => /* code for shrinking the given email */,
///   );
/// }
/// ```
///
/// For more ways on how to cleverly combine generators, see
/// [the built-in definitions](anys.dart).
/// Then, you can use that generator like this:
///
/// ```dart
/// Glados(anys.email).test('email test', (email) { ... });
/// ```
///
/// If you create a generator for a type that doesn't have a [Generator] yet
/// (or you want to swap out a built-in [Generator] for some reason), you can
/// set it as the default for that type:
///
/// ```dart
/// // Use the email generator for all Strings.
/// Any.defaults[String] = anys.email;
/// ```
///
/// Then, you don't need to explicitly provide the [Generator] to [Glados]
/// anymore. Instead, [Glados] will use it based on given type parameters:
///
/// ```dart
/// // This will now use the anys.email generator, because it was set as the
/// // default for String before.
/// Glados<String>().test('blub', () { ... });
/// ```
///
/// If a [Generator] is the default [Generator] for a type, I recommend relying
/// on implicit discovery, as the type parameters make the intention clearer.
/// If you still want to provide the [explore] parameter, you can use [null] as
/// a [generator], causing [Glados] to look for the default [Generator].
///
/// ```dart
/// Glados<String>(null, Explore(...)).test('blub', () { ... });
/// ```
///
/// # Exploration
///
/// To customize the exploration phase, provide an [ExploreConfig] configuration.
/// See the [ExploreConfig] doc comments for more information.
class Glados<T> {
  Glados([Generator<T>? generator, ExploreConfig? explore])
      : generator = generator ?? Any.defaultForWithBeautifulError<T>(1, 0),
        explore = explore ?? ExploreConfig();

  final Generator<T> generator;
  final ExploreConfig explore;

  /// Executes the given body with a bunch of parameters, trying to break it.
  @isTest
  void test(
      String description,
      Tester<T> body, {
        String? testOn,
        test_package.Timeout? timeout,
        dynamic skip,
        dynamic tags,
        Map<String, dynamic>? onPlatform,
        int? retry,
      }) {
    final stats = Statistics();

    /// Explores the input space for inputs that break the property. This works
    /// by gradually increasing the size. Returns the first value where the
    /// property is broken or null if no value was found.
    Future<Shrinkable<T>?> explorePhase() async {
      var count = 0;
      var size = explore.initialSize;

      while (count < explore.numRuns) {
        stats.exploreCounter++;
        final input = generator(explore.random, size.ceil());
        if (!await succeeds(body, input.value)) {
          return input;
        }

        count++;
        size += explore.speed;
      }
      return null;
    }

    /// Shrinks the given value repeatedly. Returns the shrunk input.
    Future<T> shrinkPhase(Shrinkable<T> initialErrorInducingInput) async {
      var input = initialErrorInducingInput;

      outer:
      while (true) {
        for (final shrunkInput in input.shrink()) {
          stats.shrinkCounter++;
          if (!await succeeds(body, shrunkInput.value)) {
            input = shrunkInput;
            continue outer;
          }
        }
        break;
      }
      return input.value;
    }

    test_package.test(
      '$description (testing ${explore.numRuns} '
          '${explore.numRuns == 1 ? 'input' : 'inputs'})',
          () async {
        final errorInducingInput = await explorePhase();
        if (errorInducingInput == null) return;

        final shrunkInput = await shrinkPhase(errorInducingInput);
        print('Tested ${stats.exploreCounter} '
            '${stats.exploreCounter == 1 ? 'input' : 'inputs'}, shrunk '
            '${stats.shrinkCounter} ${stats.shrinkCounter == 1 ? 'time' : 'times'}.'
            '\nFailing for input: $shrunkInput');
        final output = body(shrunkInput); // This should fail the test again.

        throw PropertyTestNotDeterministic(shrunkInput, output);
      },
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
      TesterWithRandom<T> body, {
        String? testOn,
        test_package.Timeout? timeout,
        dynamic skip,
        dynamic tags,
        Map<String, dynamic>? onPlatform,
        int? retry,
      }) {
    // How many random values the test needs shouldn't change what other inputs
    // are chosen. Otherwise, if a test fails, you edit the content and then the
    // test succeeds, you're not sure what made the test succeed:
    //
    // - Maybe you fixed the root problem.
    // - Or you changed some calls to the random instance, causing the faulty
    //   input to never be generated in the first place.
    final random = explore.random.nextRandom();
    test(
      description,
          (a) => body(a, random.nextRandom()),
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry,
    );
  }
}
