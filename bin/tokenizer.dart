import 'package:tokenizer/handlers.dart';
import 'package:tokenizer/primitives.dart';
import 'package:tokenizer/tokenizer.dart';

class AlphaTokenizer implements Tokenizer {
  
  @override
  ContentHandler contentHandler = ContentHandler();

  @override
  TokenHandler tokenHandler = TokenHandler([]);
  
  @override
  TokenTypeHandler tokenTypeHandler = TokenTypeHandler({});

  @override
  List<Token> tokenize(String content) {
    contentHandler.loadContent(content);

    while(true) {
      try {
        String lookahead = contentHandler.lookahead();
        Function? fnToCall = tokenTypeHandler.tokenFunction(TokenType(lookahead));

        return fnToCall == null ? throw "TokenType for $lookahead does not exist in TypeChart" : fnToCall();
      } on RangeError {
        break;
      }
    }

    return tokenHandler.tokens;
  }

  AlphaTokenizer(this.contentHandler, this.tokenTypeHandler, this.tokenHandler);

}

void main() {
  // TypeChart alphaTypeChart = TypeChart();
  // TypeHandler alphaTypeHandler = TypeHandler({});
  // TokenTypeHandler alphaTokenTypeHandler = TokenTypeHandler({});
  // TokenHandler alphaTokenHandler = TokenHandler([]);
  // ContentHandler alphaContentHandler = ContentHandler();

  // alphaTokenTypeHandler.addTokenType(TokenType("WORD"));
  // alphaTokenTypeHandler.addTokenType(TokenType("EXPRESSION"));
  // alphaTokenTypeHandler.addTokenType(TokenType("LINK"));

  // alphaTypeHandler.addHandlerFunction(alphaTokenTypeHandler.tokenTypes["WORD"], () {

  // });

  // alphaTypeHandler.addHandlerFunction(alphaTokenTypeHandler.tokenTypes["EXPRESSION"], () {

  // });

  // alphaTypeHandler.addHandlerFunction(alphaTokenTypeHandler.tokenTypes["LINK"], () {

  // });
  
  // AlphaTokenizer alphaTokenizer = AlphaTokenizer(alphaContentHandler, alphaTypeChart, alphaTypeHandler, alphaTokenHandler);
}