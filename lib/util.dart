import 'package:tokenizer/handlers.dart';
import 'package:tokenizer/primitives.dart';

Token createToken(String type, dynamic value, TokenTypeHandler tokenTypeHandler) {
  TokenType? tokenType = tokenTypeHandler.tokenTypes[type.toUpperCase()];

  if (tokenType != null) {
    return Token(tokenType, value);
  }

  throw "TokenType ${type.toUpperCase()} doesn't exist!";
}