/// Error thrown when a data of the database is missing or invalid.
class DatabaseError implements Exception {
  const DatabaseError(this.reason);

  final String reason;

  @override
  String toString() => reason;
}
