import 'unreported_exception.dart';

enum ConnectivityExceptionType { noInternet, timeout }

class ConnectivityException with UnreportedException {
  const ConnectivityException(this.type);

  final ConnectivityExceptionType type;
}
