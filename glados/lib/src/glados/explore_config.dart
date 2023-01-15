part of '../../glados.dart';

/// Configuration for several parameters used during the exploration phase.
class ExploreConfig {
  ExploreConfig({
    this.numRuns = 100,
    this.initialSize = 10,
    this.speed = 1,
    math.Random? random,
  })  : assert(numRuns > 0),
        assert(initialSize > 0),
        assert(speed >= 0),
        random = random ?? math.Random(42);

  /// The number of runs after which [Glados] stops trying to break the
  /// property test.
  final int numRuns;

  /// The initial size.
  final double initialSize;

  /// The amount by which the size will be increased each run.
  final double speed;

  /// The [Random] used for generating all randomness.
  ///
  /// By default, a [Random] with a seed is used so that the tests are
  /// deterministic.
  final math.Random random;
}
