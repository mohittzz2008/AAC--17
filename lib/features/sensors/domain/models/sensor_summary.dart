/// Aggregate summary metrics for the rover sensor suite.
class SensorSummary {
  final int totalCount;
  final int availableCount;
  final int unverifiedCount;
  final int issuesCount;

  const SensorSummary({
    required this.totalCount,
    required this.availableCount,
    required this.unverifiedCount,
    required this.issuesCount,
  });
}

