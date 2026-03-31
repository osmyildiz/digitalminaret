class AppException implements Exception {
  AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppPermissionDeniedException extends AppException {
  AppPermissionDeniedException([super.message = 'Permission denied']);
}

class ServiceDisabledException extends AppException {
  ServiceDisabledException([super.message = 'Service disabled']);
}

class DataNotFoundException extends AppException {
  DataNotFoundException([super.message = 'Data not found']);
}
