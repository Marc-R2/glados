import 'dart:math';

import 'package:meta/meta.dart';
import 'package:test/test.dart' as test_package;

import 'any.dart';
import 'generator.dart';
import 'utils.dart';

/// Configuration for several parameters used during the exploration phase.
class Explore {
  Explore({
    this.numRuns = 100,
    this.initialSize = 10,
    this.speed = 1,
    Random random,
  })  : assert(numRuns != null),
        assert(numRuns > 0),
        assert(initialSize != null),
        assert(initialSize > 0),
        assert(speed != null),
        assert(speed >= 0),
        this.random = random ?? Random(42);

  /// The number of runs after which [Glados] stops trying to break the
  /// invariant.
  final int numRuns;

  /// The initial size.
  final double initialSize;

  /// The amount by which the size will be increased each run.
  final double speed;

  /// The [Random] used for generating all randomness.
  ///
  /// By default, a [Random] with a seed is used so that the tests are
  /// deterministic.
  final Random random;
}

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
/// Glados(any.email).test('email test', (email) { ... });
/// ```
///
/// If you create a generator for a type that doesn't have a [Generator] yet
/// (or you want to swap out a built-in [Generator] for some reason), you can
/// set it as the default for that type:
///
/// ```dart
/// // Use the email generator for all Strings.
/// Any.defaults[String] = any.email;
/// ```
///
/// Then, you don't need to explicitly provide the [Generator] to [Glados]
/// anymore. Instead, [Glados] will use it based on given type parameters:
///
/// ```dart
/// // This will now use the any.email generator, because it was set as the
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
/// To customize the exploration phase, provide an [Explore] configuration.
/// See the [Explore] doc comments for more information.
class Glados<T> {
  Glados([Generator<T> generator, Explore explore])
      : this.generator = generator ?? Any.defaultFor<T>(),
        this.explore = explore ?? Explore();

  final Generator<T> generator;
  final Explore explore;

  /// Executes the given body with a bunch of parameters, trying to break it.
  @isTest
  void test(String name, Tester<T> body) {
    final stats = Statistics();

    /// Explores the input space for inputs that break the invariant. This works
    /// by gradually increasing the size. Returns the first value where the
    /// invariance is broken or null if no value was found.
    Shrinkable<T> explorePhase() {
      var count = 0;
      var size = explore.initialSize;

      while (count < explore.numRuns) {
        stats.exploreCounter++;
        final input = generator(explore.random, size.ceil());
        if (!succeeds(body, input.value)) {
          return input;
        }

        count++;
        size += explore.speed;
      }
      return null;
    }

    /// Shrinks the given value repeatedly. Returns the shrunk input.
    T shrinkPhase(Shrinkable<T> initialErrorInducingInput) {
      Shrinkable<T> input = initialErrorInducingInput;

      outer:
      while (true) {
        for (final shrunkInput in input.shrink()) {
          stats.shrinkCounter++;
          if (!succeeds(body, shrunkInput.value)) {
            input = shrunkInput;
            continue outer;
          }
        }
        break;
      }
      return input.value;
    }

    test_package.test(
      '$name (testing ${explore.numRuns} '
      '${explore.numRuns == 1 ? 'input' : 'inputs'})',
      () {
        final errorInducingInput = explorePhase();
        if (errorInducingInput == null) return;

        final shrunkInput = shrinkPhase(errorInducingInput);
        print('Tested ${stats.exploreCounter} '
            '${stats.exploreCounter == 1 ? 'input' : 'inputs'}, shrunk '
            '${stats.shrinkCounter} ${stats.shrinkCounter == 1 ? 'time' : 'times'}.'
            '\nFailing for input: $shrunkInput');
        body(shrunkInput); // This should fail the test again.

        throw InvarianceNotDeterministic();
      },
    );
  }
}

/// Just like [Glados], but with two parameters.
/// See [Glados] for more information about the arguments.
class Glados2<First, Second> {
  Glados2([
    Generator<First> firstGenerator,
    Generator<Second> secondGenerator,
    Explore explore,
  ])  : this.firstGenerator = firstGenerator ?? Any.defaultFor<First>(),
        this.secondGenerator = secondGenerator ?? Any.defaultFor<Second>(),
        this.explore = explore ?? Explore();

  final Generator<First> firstGenerator;
  final Generator<Second> secondGenerator;
  final Explore explore;

  void test(String name, Tester2<First, Second> body) {
    Glados(
      any.combine2(firstGenerator, secondGenerator, (a, b) => [a, b]),
    ).test(name, (input) {
      body(input[0] as First, input[1] as Second);
    });
  }
}

/// Just like [Glados], but with three parameters.
/// See [Glados] for more information about the arguments.
class Glados3<First, Second, Third> {
  Glados3([
    Generator<First> firstGenerator,
    Generator<Second> secondGenerator,
    Generator<Third> thirdGenerator,
    Explore explore,
  ])  : this.firstGenerator = firstGenerator ?? Any.defaultFor<First>(),
        this.secondGenerator = secondGenerator ?? Any.defaultFor<Second>(),
        this.thirdGenerator = thirdGenerator ?? Any.defaultFor<Third>(),
        this.explore = explore ?? Explore();

  final Generator<First> firstGenerator;
  final Generator<Second> secondGenerator;
  final Generator<Third> thirdGenerator;
  final Explore explore;

  void test(String name, Tester3<First, Second, Third> body) {
    Glados(any.combine3(
      firstGenerator,
      secondGenerator,
      thirdGenerator,
      (a, b, c) => [a, b, c],
    )).test(name, (input) {
      body(input[0] as First, input[1] as Second, input[2] as Third);
    });
  }
}
