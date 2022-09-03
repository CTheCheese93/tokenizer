import 'package:tokenizer/handlers.dart';
import 'package:tokenizer/primitives.dart';
import 'package:tokenizer/tokenizer.dart';

class AlphaTokenizer implements Tokenizer {
  @override
  ContentHandler contentHandler = ContentHandler();

  @override
  TokenHandler tokenHandler;
  
  @override
  TokenTypeHandler tokenTypeHandler;

  @override
  List<Token> tokenize(String content) {
    contentHandler.loadContent(content);

    while(true) {
      try {
        String lookahead = contentHandler.lookahead();
        TokenType contentTokenType = tokenTypeHandler.getTokenTypeOfContent(lookahead);
        // Should be checking what TokenType character should be
        Function? fnToCall = tokenTypeHandler.tokenFunction(contentTokenType);

        fnToCall == null ? throw "TokenType for $lookahead does not exist in TypeChart" : fnToCall(contentHandler, tokenTypeHandler, tokenHandler);
      } on RangeError {
        break;
      }
    }

    return tokenHandler.tokens;
  }

  AlphaTokenizer(this.tokenTypeHandler, this.tokenHandler);

}

Map<dynamic, TokenType> generateContentTokenMap(){
  Map<dynamic, TokenType> map = {};
  int i = 0;

  while (i <= 127) {
    if ((i >= "A".codeUnitAt(0) && i <= "Z".codeUnitAt(0))
      || i >= "a".codeUnitAt(0) && i <= "z".codeUnitAt(0)) {

      map[String.fromCharCode(i)] = TokenType("CHAR");

      i++;
      continue;
    }
    
    if (i >= "0".codeUnitAt(0) && i <= "9".codeUnitAt(0)){

      map[String.fromCharCode(i)] = TokenType("NUMBER");

      i++;
      continue;
    }
    
    if ((i >= "!".codeUnitAt(0) && i <= "/".codeUnitAt(0))
      || i >= ":".codeUnitAt(0) && i <= "@".codeUnitAt(0)
      || i >= "[".codeUnitAt(0) && i <= "`".codeUnitAt(0)
      || i >= "~".codeUnitAt(0) && i <= "~".codeUnitAt(0)) {

      map[String.fromCharCode(i)] = TokenType("SYMBOL");

      i++;
      continue;
    }

    map[String.fromCharCode(i)] = TokenType("UNKNOWN");
    i++;
  }

  return map;
}

void main() {
  TokenTypeHandler alphaTokenTypeHandler = TokenTypeHandler({}, generateContentTokenMap());
  TokenHandler alphaTokenHandler = TokenHandler([]);

  alphaTokenTypeHandler.mapTokenTypeToFunction(TokenType("WORD"), (ContentHandler ch, TokenTypeHandler tth, TokenHandler th){
    String word = ch.getNextCharUntil(" ");

    th.addToken(Token(TokenType("WORD"), word));
  });

  alphaTokenTypeHandler.mapTokenTypeToFunction(TokenType("CHAR"), (ContentHandler ch, TokenTypeHandler tth, TokenHandler th){
    // We know the first character in lookaheadwill be a CHAR, so we get the next one and isolate it
    String laResult = ch.lookahead(size: 2)[1];

    if (laResult.codeUnitAt(0) == " ".codeUnitAt(0)) {
      th.addToken(Token(TokenType("CHAR"), ch.getNextChar()));
      // Change TokenTypeHandler.tokenTypeExists to tokenTypeIsMapped
      // Change TokenTypeHandler.contentAsKeyExists to contentIsMapped
    } else if (tth.tokenTypeExists(TokenType("WORD"))){
      tth.tokenFunction(TokenType("WORD"))!(ch, tth, th);
    }
  });

  alphaTokenTypeHandler.mapTokenTypeToFunction(TokenType("NUMBER"), (ContentHandler ch, TokenTypeHandler tth, TokenHandler th){
    // We know the first character in lookaheadwill be a CHAR, so we get the next one and isolate it
    String laResult = ch.lookahead(size: 2)[1];

    if (laResult.codeUnitAt(0) == " ".codeUnitAt(0)) {
      th.addToken(Token(TokenType("CHAR"), ch.getNextChar()));
      // Change TokenTypeHandler.tokenTypeExists to tokenTypeIsMapped
      // Change TokenTypeHandler.contentAsKeyExists to contentIsMapped
    } else if (tth.tokenTypeExists(TokenType("WORD"))){
      tth.tokenFunction(TokenType("WORD"))!(ch, tth, th);
    }
  });

  alphaTokenTypeHandler.mapTokenTypeToFunction(TokenType("SYMBOL"), (ContentHandler ch, TokenTypeHandler tth, TokenHandler th){
    th.addToken(Token(TokenType("SYMBOL"), ch.getNextChar()));
  });

  alphaTokenTypeHandler.mapTokenTypeToFunction(TokenType("UNKNOWN"), (ContentHandler ch, TokenTypeHandler tth, TokenHandler th){
    th.addToken(Token(TokenType("UNKNOWN"), ch.getNextChar()));
  });
  
  AlphaTokenizer alphaTokenizer = AlphaTokenizer(alphaTokenTypeHandler, alphaTokenHandler);

  List<Token> results = alphaTokenizer.tokenize("A a bcd 123 ab3k 2 ! # * ( )");

  for (Token token in results) {
    print("${token.type.type}\t:\t${token.value}");
  }
}