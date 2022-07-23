import 'unreported_exception.dart';
import 'displayable_exception.dart';

class FormValidationException extends DisplayableException with UnreportedException {
  const FormValidationException(String message) : super(message);

  @override
  String toString() => message;
}
