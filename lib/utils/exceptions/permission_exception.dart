import 'unreported_exception.dart';

/// Exception thrown when a device permission was denied.
/// (like localisation, camera, etc)
class PermissionDeniedException with UnreportedException {
  const PermissionDeniedException();
}
