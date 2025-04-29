class ServerException implements Exception {
  final String message;
  final int statusCode;

  ServerException({
    required this.message,
    required this.statusCode,
  });
  
  // Add a named constructor for backward compatibility
  ServerException.fromMessage({required this.message}) : statusCode = 500;
}

class CacheException implements Exception {
  final String message;

  CacheException({
    required this.message,
  });
}

class AuthException implements Exception {
  final String message;

  AuthException({
    required this.message,
  });
}
