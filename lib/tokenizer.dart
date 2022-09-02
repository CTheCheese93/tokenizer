import 'package:tokenizer/primitives.dart';
import 'package:tokenizer/handlers.dart';

abstract class Tokenizer {
  ContentHandler contentHandler = ContentHandler();
  TokenHandler tokenHandler;
  TokenTypeHandler tokenTypeHandler;

  List<Token> tokenize(String content);

  Tokenizer(this.tokenTypeHandler, this.tokenHandler);
}