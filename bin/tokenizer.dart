import 'package:tokenizer/handlers.dart';
import 'package:tokenizer/primitives.dart';
import 'package:tokenizer/tokenizer.dart';

class AlphaTokenizer implements Tokenizer {
  
  @override
  ContentHandler contentHandler = ContentHandler();

  @override
  TokenHandler tokenHandler = TokenHandler([]);
  
  @override
  TypeChart typeChart = TypeChart();
  
  @override
  TypeHandler typeHandler = TypeHandler({});

  @override
  List<Token> tokenize(String content) {
    contentHandler.loadContent(content);

    while(true) {
      try {
        String lookahead = contentHandler.lookahead();
        TokenType? lookaheadTokenType = typeChart.typeChart[lookahead];

        typeHandler.typeHandlerChart[lookaheadTokenType] != null
          ? typeHandler.typeHandlerChart[lookaheadTokenType]!(contentHandler, typeChart, typeHandler, tokenHandler)
          : throw "TokenType for $lookahead does not exist in TypeChart";
      } on RangeError {
        break;
      }
    }

    return tokenHandler.tokens;
  }

  AlphaTokenizer(this.contentHandler, this.typeChart, this.typeHandler, this.tokenHandler);

}

void main() {
  TypeChart alphaTypeChart = TypeChart();
  TypeHandler alphaTypeHandler = TypeHandler({});
  TokenTypeHandler alphaTokenTypeHandler = TokenTypeHandler({});
  TokenHandler alphaTokenHandler = TokenHandler([]);
  ContentHandler alphaContentHandler = ContentHandler();

  alphaTokenTypeHandler.addTokenType(TokenType("WORD"));
  alphaTokenTypeHandler.addTokenType(TokenType("EXPRESSION"));
  alphaTokenTypeHandler.addTokenType(TokenType("LINK"));

  alphaTypeHandler.addHandlerFunction(alphaTokenTypeHandler.tokenTypes["WORD"], () {

  });

  alphaTypeHandler.addHandlerFunction(alphaTokenTypeHandler.tokenTypes["EXPRESSION"], () {

  });

  alphaTypeHandler.addHandlerFunction(alphaTokenTypeHandler.tokenTypes["LINK"], () {

  });
  
  AlphaTokenizer alphaTokenizer = AlphaTokenizer(alphaContentHandler, alphaTypeChart, alphaTypeHandler, alphaTokenHandler);
}