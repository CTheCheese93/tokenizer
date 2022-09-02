import 'package:tokenizer/handlers.dart';
import 'package:tokenizer/tokenizer.dart';
import 'package:tokenizer/primitives.dart';
import 'package:tokenizer/exceptions.dart';
import 'package:test/test.dart';
import 'package:tokenizer/util.dart';

void main() {

  group('TokenType & Handler', () {
    TokenTypeHandler tokenTypeHandler = TokenTypeHandler({});
    TokenType charTokenType = TokenType("CHAR");
  
    test('Can create TokenType of type CHAR', () {
      expect(charTokenType.type, equals('CHAR'));
    });

    test('TokenType matches based on string, case insensitive.', () {
      expect(TokenType("Char"), equals(TokenType("CHAR")));
    });

    test('Can add TokenTypes to TokenHandler', () {
      tokenTypeHandler.addTokenType(charTokenType);

      expect(tokenTypeHandler.tokenTypes["CHAR"], equals(charTokenType));
    });

    test('Can create & add TokenTypes with TokenHandler', () {
      TokenType wordTokenType = tokenTypeHandler.createAndAddTokenType("WORD");

      expect(tokenTypeHandler.tokenTypes["WORD"], equals(wordTokenType));
    });

    test('Throws DuplicateTokenTypeException on creating & adding TokenTypes with TokenHandler that already exist', () {
      expect(
        () => tokenTypeHandler.createAndAddTokenType("WORD"),
        throwsA(isA<DuplicateTokenTypeException>())
      );
    });

    test('Throws DuplicateTokenTypeException on adding TokenType with same type already existing', () {
      TokenType duplicateWordTokenType = TokenType("WORD");

        expect(
          () => tokenTypeHandler.addTokenType(duplicateWordTokenType),
          throwsA(isA<DuplicateTokenTypeException>())
        );
    });
  });


  group('Token & TokenHandler', () {
    TokenTypeHandler tokenTypeHandler = TokenTypeHandler({
      "CHAR": TokenType("CHAR"),
      "WORD": TokenType("WORD")
    });
    Map<String, TokenType> tokenTypes = tokenTypeHandler.tokenTypes;
    TokenHandler tokenHandler = TokenHandler([]);

    test("Can create a Token with type WORD with value of 'ABC'", () {
      Token token = createToken("WORD", "ABC", tokenTypeHandler);
      expect(token, predicate((Token e) {
        return e.type == tokenTypes["WORD"] && e.value == "ABC";
      }, 'Token is of correct type and value'));
    });

    test("Can add token to TokenHandler", () {
      Token token = createToken("WORD", "ABC", tokenTypeHandler);
      tokenHandler.addToken(token);

      expect(tokenHandler.tokens[0], equals(token));
    });

    test("Can clear tokens from TokenHandler", () {
      if (tokenHandler.tokens.isEmpty) {
        Token token = createToken("CHAR", "A", tokenTypeHandler);

        tokenHandler.addToken(token);
      }

      tokenHandler.clearTokens(confirm: true);

      expect(tokenHandler.tokens.isEmpty, equals(true));
    });

    test("Can add multiple tokens to TokenHandler", () {
      tokenHandler.clearTokens(confirm: true);

      Token tokenA = createToken("CHAR", "A", tokenTypeHandler);
      Token tokenB = createToken("CHAR", "B", tokenTypeHandler);

      tokenHandler.addTokens([tokenA, tokenB]);

      expect(tokenHandler.tokens.length, equals(2));
    });

    void buildABCTokenList() {
      tokenHandler.clearTokens(confirm: true);

      Token tokenA = createToken("CHAR", "A", tokenTypeHandler);
      Token tokenB = createToken("CHAR", "B", tokenTypeHandler);
      Token tokenC = createToken("CHAR", "C", tokenTypeHandler);

      tokenHandler.addTokens([tokenA, tokenB, tokenC]);
    }

    test("Can lookahead 1 Token", () {
      buildABCTokenList();
      expect(tokenHandler.lookahead(), predicate((List<Token> e) {
        return e[0].value == "A";
      }));
    });

    test("Can lookahead 3 Tokens", () {
      buildABCTokenList();
      expect(tokenHandler.lookahead(size: 3), predicate((List<Token> e) {
        return
          e[0].value == "A" &&
          e[1].value == "B" &&
          e[2].value == "C";
      }));
    });

    test("Can get next Token", () {
      buildABCTokenList();
      expect(tokenHandler.getNextToken(), predicate((Token e) {
        return e.value == "A" && tokenHandler.tokenPosition == 1;
      }));
    });

    test("Can get next 3 Tokens", () {
      buildABCTokenList();
      expect(tokenHandler.getNextTokens(3), predicate((List<Token> e) {
        return
          e[0].value == "A" &&
          e[1].value == "B" &&
          e[2].value == "C" && tokenHandler.tokenPosition == 3;
      }));
    });
  });

  group("TypeChart", () {
    TypeChart typeChart = TypeChart();
    TokenTypeHandler tokenTypeHandler = TokenTypeHandler({
      "CHAR": TokenType("CHAR"),
      "WORD": TokenType("WORD"),
      "NUM":  TokenType("NUM")
    });

    test("Can load single type into TypeChart", () {
      // TODO: Rewrite TokenTypeHandler.tokenTypes to not require ! on this end.
      // TODO: Rewrite TokenTypeHandler to remove direct access to tokenTypes.
      typeChart.mapTokenType(tokenTypeHandler.tokenTypes["CHAR"]!, "A");

      // TODO: Rewrite TypeChart to remove direct access to typeChart ( getTypeFor(String value) ?)
      expect(typeChart.typeChart["A"], equals(tokenTypeHandler.tokenTypes["CHAR"]));
    });
  });

  group("Content Handler", () {
    ContentHandler buildContentHandler({content = "ABC"}) {
      return ContentHandler(content:content);
    }

    test("Can lookahead 1 char", () {
      ContentHandler contentHandler = buildContentHandler();
      expect(contentHandler.lookahead(), equals("A"));
    });

    test("Can lookahead 3 char", () {
      ContentHandler contentHandler = buildContentHandler();
      expect(contentHandler.lookahead(size: 3), equals("ABC"));
    });

    test("Can get next char", () {
      ContentHandler contentHandler = buildContentHandler();
      expect(contentHandler.getNextChar(), equals("A"));
    });

    test("Can lookbehind 1 char",() {
      ContentHandler contentHandler = buildContentHandler();
      contentHandler.getNextChar(); // "A"
      expect(contentHandler.lookbehind(), equals("A"));
    });

    test("Can get next 3 chars", () {
      ContentHandler contentHandler = buildContentHandler();
      expect(contentHandler.getNextChars(size: 3), predicate((String result) {
        return result == "ABC" && contentHandler.index == 3;
      }));
    });

    test("Can lookbehind 3 chars", () {
      ContentHandler contentHandler = buildContentHandler(content: "ABCD");
      contentHandler.getNextChars(size: 3);
      expect(contentHandler.lookbehind(size: 3), predicate((String result) {
        return result == "ABC" && contentHandler.index == 3;
      }));
    });

    test("Can lookahead until specific char is found", () {
      ContentHandler contentHandler = buildContentHandler(content: "(ABC)");
      
      if (contentHandler.lookahead() == "(") {
        String result;

        // Eat "("
        contentHandler.getNextChar();
        
        result = contentHandler.lookaheadUntil(")");

        expect(result, equals("ABC"));
      }
    });

    test("Can get chars until specific char is found", () {
      ContentHandler contentHandler = buildContentHandler(content: "(ABC)");
      
      if (contentHandler.lookahead() == "(") {
        String result;

        // Eat "("
        contentHandler.getNextChar();
        
        result = contentHandler.getNextCharUntil(")");

        expect(result, equals("ABC"));
        expect(contentHandler.lookahead(), equals(")"));
      }
    });

    test("Will throw error on lookahead at end of content", () {
      ContentHandler contentHandler = buildContentHandler();

      contentHandler.getNextChars(size: 3);

      expect(() => contentHandler.lookahead(), throwsRangeError);
    });

    test("Will throw error on getToken at end of content", () {
      ContentHandler contentHandler = buildContentHandler();

      contentHandler.getNextChars(size: 3);

      expect(() => contentHandler.getNextChar(), throwsRangeError);
    });
  });
}
