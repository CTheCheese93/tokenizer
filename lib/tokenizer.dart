import 'package:tokenizer/primitives.dart';
import 'package:tokenizer/handlers.dart';

abstract class Tokenizer {
  ContentHandler contentHandler = ContentHandler();
  TokenHandler tokenHandler;
  TypeChart typeChart;
  TypeHandler typeHandler;

  List<Token> tokenize(String content);

  Tokenizer(this.typeChart, this.typeHandler, this.tokenHandler);
}