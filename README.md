# Tokenizer

I wanted to see if I could make a decent tokenizer that was easy to configure and extend.

## The Concept

### Primitives

#### TokenType

The fundamental building block that allows you to define different types of `Tokens`.

    class TokenType {
        String type;

        TokenType(this.type);
    }

#### Token

A very simple object that is identified by it's `TokenType` and contains a `value`

    class Token {
        TokenType type;
        dynamic value;

        Token(this.type, this.value);
    }

#### TypeChart

As of this writing, the `TypeChart` is a mess, but is being worked on as a top priority.

The main thing to know about the `TypeChart` is that it contains a property called `typeChart`

    Map<dynamic, TokenType> typeChart = {};

The point of the `TypeChart` is to map values (typically chars like "A" or "(") and associating them with a specific type of `Token`.

The advantage to using `dynamic` as the key's type means you can store anything from specific `Strings` to other `TokenTypes`.

I'd like to see the ability to recognize Regular Expressions as a way to easily identify matches to `Tokens`, but I get concerned about the performance implications already, much less with Regular Expressions involved.

This class will soon be renamed to something more like `TokenTypeChart` to clarify intent.

### Handlers

#### TokenTypeHandler

Does as the name implies, it holds onto it's own Map called `tokenTypes`.

    Map<String, TokenType> tokenTypes;

This Map is what allows for getting the correct `TokenType` through a call similar to `tokenType["CHAR"]`, which will look for a `TokenType` of "CHAR".

This is primarily due to not having implemented == operation yet. Idealy any `TokenType` with the same value would be considered the same:

    // Currently
    TokenType("CHAR") != TokenType("CHAR")

    // Ideal
    TokenType("CHAR") == TokenType("CHAR") && TokenType("ChAr") && TokenType("ChAR ");

The ideal would allow for `TokenTypes` to be created on the fly without worrying about it if it was the original `TokenType` being referenced.

It does imply though, that case is intended to be CAP CASE, preferring abbreviations like "LPREN" or "EXPR" over encouraging longer alternatives.

This implied standard may change in the future though.

A lot of what is in `TokenTypeHandler` acts as the second half to what the `TypeChart` provides.

In the future, I will likely combine `TypeHandler` and `TokenTypeChart`, or refactor them to be better suited with == operation capabilities.

#### TokenHandler

Manages all `Tokens` for the `Tokenizer` being used. Every `Tokenizer` has a `TokenHandler` which allows for easy management of `Tokens`.

`Tokens` can be added and created with `TokenHandler`, and it offers the traversal of the list of `Tokens` through functions like `lookahead()` and `getNextToken()`.

#### ContentHandler

`ContentHandler` is basically the same thing as the `TokenHandler`, except it is geared towards `Strings` rather than `Tokens`.

In theory, you could have two `Tokenizers`, one that turns Content (`Strings`) into `Tokens`, and another that turns those `Tokens` into other `Tokens`.

While this would be a two-step process, it does allow for flexibility when defining the end content. It also can be reduced down to one through some "fine wiring".

#### TypeHandler

Probably the worst Handler out of the bunch but the most important. It simply maps a `TokenType` to a `Function` that should be executed, passing in the other Handlers.

As it stands, `TypeHandler.typeHandlerChart` holds onto this mapping in the form of `Map<TokenType, Function>` but there is consideration of changing to `Map<TokenType, Map<String, Function>>`, which would allow for multiple `Functions` mapped to a single `TokenType` called by some sort of label.

This change would allow for some benefits, but because `TypeHandler` exists as a property inside a `Tokenizer`, it is limited on what it can provide.

This lends to the argument for removing `TypeHandler` from the `Tokenizer` itself and putting it at the same level of hierarchy as a `Tokenizer`.

I imagine such a change would end up with `Tokenizers` and their functions separated, with the `Tokenizer` focusing on process and the functions being focused on execution while also contributing to the overall pool of functions from other `Tokenizers` that can also be called upon.

### Tokenizer

At it's core, the `Tokenizer` is the central control of of all the Handlers and dictates the start and end of Tokenizing.

Because this project has been mainly a bottom-up approach, `Tokenizer` is probably the least developed so far.