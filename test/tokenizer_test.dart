import 'package:tokenizer/handlers.dart';
import 'package:tokenizer/tokenizer.dart';
import 'package:tokenizer/primitives.dart';
import 'package:tokenizer/exceptions.dart';
import 'package:test/test.dart';
import 'package:tokenizer/util.dart';

void main() {

  group('TokenTypeHandler', () {
    TokenTypeHandler tokenTypeHandler = TokenTypeHandler({
      TokenType("TEST"): (){}
    }, {});
  
    test('Can create TokenType of type CHAR', () {
      expect(TokenType("char").type, equals('CHAR'));
    });

    test('TokenType created as "cHaR" comes out "CHAR"', () {
      expect(TokenType("ChAr").type, equals("CHAR"));
    });

    test('TokenType matches based on string, case insensitive.', () {
      expect(TokenType("Char"), equals(TokenType("CHAR")));
    });

    test('Can successfully identify if TokenType exists as key', () {
      expect(tokenTypeHandler.tokenTypeIsMapped(TokenType("TEST")), equals(true));
    });

    test('Can map TokenTypes to functions', () {
      tokenTypeHandler.mapTokenTypeToFunction(TokenType("ADD"), (int x, int y) { return x + y;});

      expect(tokenTypeHandler.tokenFunction(TokenType("ADD")), isA<Function>());
    });

    test('Returns false when TokenType already has an existing mapping', () {
      tokenTypeHandler.mapTokenTypeToFunction(TokenType("Token"), (int x, int y) {
        return x + y;
      });

      expect(tokenTypeHandler.tokenFunction(TokenType("Token"))!(1,1), equals(2));

      expect(
        tokenTypeHandler.mapTokenTypeToFunction(TokenType("Token"), (int x, int y) { return x * y; }),
        equals(false) // throwsA(isA<DuplicateTokenTypeException>())
      );
    });

    test('Returns true when TokenType already has an existing mapping and replace is set to true', () {
      // Setting initial mapping
      tokenTypeHandler.mapTokenTypeToFunction(TokenType("Token"), (int x, int y) {
        return x + y;
      });

      // Confirming mapping works as intended
      expect(tokenTypeHandler.tokenFunction(TokenType("Token"))!(1,1), equals(2));

      // Attemping to replace mapping
      tokenTypeHandler.mapTokenTypeToFunction(TokenType("Token"), (int x, int y) { return x * y; }, replace: true);

      // Confirming replacement worked
      expect(
        tokenTypeHandler.tokenFunction(TokenType("Token"))!(1,1),
        equals(1) // throwsA(isA<DuplicateTokenTypeException>())
      );
    });
  });


  group('Token & TokenHandler', () {
    TokenTypeHandler tokenTypeHandler = TokenTypeHandler({}, {});
    TokenHandler tokenHandler = TokenHandler([]);

    test("Can create a Token with type WORD with value of 'ABC'", () {
      Token token = createToken(TokenType("WORD"), "ABC", tokenTypeHandler);
      expect(token, predicate((Token e) {
        return e.type == TokenType("WORD") && e.value == "ABC";
      }, 'Token is of correct type and value'));
    });

    test("Can add token to TokenHandler", () {
      Token token = createToken(TokenType("WORD"), "ABC", tokenTypeHandler);
      tokenHandler.addToken(token);

      expect(tokenHandler.tokens[0], equals(token));
    });

    test("Can clear tokens from TokenHandler", () {
      if (tokenHandler.tokens.isEmpty) {
        Token token = createToken(TokenType("CHAR"), "A", tokenTypeHandler);

        tokenHandler.addToken(token);
      }

      tokenHandler.clearTokens(confirm: true);

      expect(tokenHandler.tokens.isEmpty, equals(true));
    });

    test("Can add multiple tokens to TokenHandler", () {
      tokenHandler.clearTokens(confirm: true);

      Token tokenA = createToken(TokenType("CHAR"), "A", tokenTypeHandler);
      Token tokenB = createToken(TokenType("CHAR"), "B", tokenTypeHandler);

      tokenHandler.addTokens([tokenA, tokenB]);

      expect(tokenHandler.tokens.length, equals(2));
    });

    void buildABCTokenList() {
      tokenHandler.clearTokens(confirm: true);

      Token tokenA = createToken(TokenType("CHAR"), "A", tokenTypeHandler);
      Token tokenB = createToken(TokenType("CHAR"), "B", tokenTypeHandler);
      Token tokenC = createToken(TokenType("CHAR"), "C", tokenTypeHandler);

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
        
        result = contentHandler.lookaheadUntil([")"]);

        expect(result, equals("ABC"));
      }
    });

    test("Can get chars until specific char is found", () {
      ContentHandler contentHandler = buildContentHandler(content: "(ABC)");
      
      if (contentHandler.lookahead() == "(") {
        String result;

        // Eat "("
        contentHandler.getNextChar();
        
        result = contentHandler.getNextCharUntil([")"]);

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
