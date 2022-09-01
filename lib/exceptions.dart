class DuplicateTokenTypeException implements Exception {
  String cause;

  DuplicateTokenTypeException(this.cause);
}