import 'package:tokenizer/handlers.dart';
import 'package:tokenizer/primitives.dart';

Token createToken(TokenType tokenType, dynamic value, TokenTypeHandler tokenTypeHandler) {
  return Token(tokenType, value);
}