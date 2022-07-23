/// Exception thrown when an operation is invalid, cannot be performed.
class InvalidOperationException implements Exception {
  final String reason;

  const InvalidOperationException(this.reason);

  @override
  String toString() => reason;
}
