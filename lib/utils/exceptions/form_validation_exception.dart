import 'unreported_exception.dart';
import 'displayable_exception.dart';

class FormValidationException extends DisplayableException with UnreportedException {
  const FormValidationException(super.message);

  @override
  String toString() => message;
}
