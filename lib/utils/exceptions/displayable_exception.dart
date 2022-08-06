/// An exception that may be directly displayed to the user
class DisplayableException implements Exception {
  const DisplayableException(this.message);

  final String message;

  @override
  String toString() => message;
}
