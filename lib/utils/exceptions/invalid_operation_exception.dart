import 'displayable_exception.dart';
import 'unreported_exception.dart';

/// Exception thrown when an operation is invalid, cannot be performed.
class InvalidOperationException extends DisplayableException with UnreportedException {
  const InvalidOperationException(super.message);
}
