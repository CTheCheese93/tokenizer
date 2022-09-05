import 'package:tokenizer/primitives.dart';
import 'package:tokenizer/exceptions.dart';

//
// Token Type Handler
//

class TokenTypeHandler {
  Map<TokenType, Function> _tthChart;
  Map<dynamic, TokenType> _contentChart;

  bool tokenTypeIsMapped(TokenType tokenType) {
    return _tthChart.containsKey(tokenType);
  }

  // TODO: Needs testing
  bool contentIsMapped(dynamic content) {
    return _contentChart.containsKey(content);
  }

  bool mapTokenTypeToFunction(TokenType tokenType, Function fn, {replace = false}) {
    if (tokenTypeIsMapped(tokenType) && replace == false) {
      return false;
    }

    _tthChart[tokenType] = fn;
    return true;
  }

  // TODO: Needs testing
  bool mapContentToTokenType(dynamic content, TokenType tokenType) {
    if(contentIsMapped(content)) {
      return false;
    }

    _contentChart[content] = tokenType;
    return true;
  }

  Function? tokenFunction(TokenType tokenType){
      return _tthChart[tokenType];
  }

  TokenType getTokenTypeOfContent(String content) {
    if (contentIsMapped(content)) {
      return _contentChart[content]!;
    } else {
      return TokenType("UKNOWN");
    }
  }
  
  TokenTypeHandler(this._tthChart, this._contentChart);
}

//
// Token Handler
//

class TokenHandler {
  List<Token> tokens;
  int tokenPosition;

  bool addToken(Token token) {
    tokens.add(token);
    return true;
  }

  bool addTokens(List<Token> tokensToAdd) {
    tokens.addAll(tokensToAdd);
    return true;
  }

  List<Token> lookahead({int size = 3}){
    if (tokenPosition + size - 1 <= tokens.length - 1) {
      return tokens.sublist(tokenPosition, tokenPosition + size);
    } else {
      throw "Size of $size + tokenPosition of $tokenPosition exceeds tokens.length: ${tokens.length}";
    }
  }

  bool clearTokens({bool confirm = false}) {
    if (confirm) {
      tokens = [];
      tokenPosition = 0;
      return true;
    } else {
      throw "You must confirm to clear tokens from TokenHandler";
    }
  }

  Token getNextToken() {
    if (tokenPosition <= tokens.length - 1) {
      tokenPosition++;
      return tokens[tokenPosition - 1];
    } else {
      throw "TokenHandler's tokenPosition ($tokenPosition) exceeds limit (${tokens.length - 1})";
    }
  }

  List<Token> getNextTokens(int size) {
    if (tokenPosition + size - 1 <= tokens.length - 1) {
      List<Token> nextTokens = [];
      int sz = size;
      while (sz != 0) {
        nextTokens.add(getNextToken());
        sz--;
      }
      
      return nextTokens;
    } else {
      throw "Size of $size + tokenPosition of $tokenPosition exceeds tokens.length: ${tokens.length}";
    }
  }

  TokenHandler(this.tokens, {this.tokenPosition = 0});
}

//
// Content Handler
//

class ContentHandler {
  int index;
  // TODO: Implement row and col tracking
  int row;
  int col;
  String content;

  String lookahead({int size = 1}) {
    if (index + size - 1 <= content.length - 1) {
      return content.substring(index, index + size);
    } else {
      throw RangeError("Content Handler index ($index) + Result Size ($size) exceeds content size (${content.length}).");
    }
  }

  String lookbehind({int size = 1}) {
    if (index - size >= 0) {
      return content.substring(index - size, index);
    } else {
      throw UnimplementedError();
    }
  }

  String getNextChar() {
    if (index <= content.length - 1) {
      index += 1;
      return content[index-1];
    } else {
      throw RangeError("Content Handler index ($index) exceeds content size (${content.length})");
    }
  }

  String getNextChars({int size = 1}) {
    if (index + size - 1 <= content.length - 1) {
      String result = content.substring(index, index + size);
      index += size;
      return result;
    } else {
      throw RangeError("Content Handler index ($index) + Result Size ($size) exceeds content size (${content.length - 1})");
    }
  }

  // TODO: Needs to handle EOF type results
  String lookaheadUntil(List<String> charList) {
    int size = 1;
    String lookaheadResult = lookahead();

    bool charFound() {
      for (String char in charList) {
        if (lookaheadResult.endsWith(char)) {
          return true;
        }
      }

      return false;
    }

    bool charNotTerminal() {
      // Is the last character terminal?
      switch(lookaheadResult[lookaheadResult.length-1].codeUnitAt(0)) {
        case 13:   // CR
        case 10:   // LF
          return false;
      }

      return true;
    }

    // Goes one further than what we actually need
    while(!charFound() && charNotTerminal()) {
      lookaheadResult = lookahead(size: ++size);
    }

    return lookaheadResult.substring(0, lookaheadResult.length - 1);
  }

  String getNextCharUntil(List<String> charList) {
    String lookaheadResult = lookaheadUntil(charList);

    return getNextChars(size: lookaheadResult.length);
  }

  bool loadContent(String content) {
    this.content = content;
    return true;
  }

  ContentHandler({this.content = "", this.index = 0, this.row = 0, this.col = 0});
}