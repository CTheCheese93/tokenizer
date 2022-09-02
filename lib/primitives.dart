class TokenType {
  String _type = "";

  String get type => _type;

  set type(String type) {
    _type = type.toUpperCase();
  }

  @override
  int get hashCode => Object.hash(type, type);
  
  @override
  operator ==(other){
    return type.toUpperCase() == (other as TokenType).type.toUpperCase()
      ? true : false;
  }

  TokenType(String s) {
    type = s;
  }
}

class Token {
  TokenType type;
  dynamic value;

  Token(this.type, this.value);
}

// class TypeChart {
//   Map<dynamic, TokenType> typeChart = {};
//   Map<TokenType, List<dynamic>> tokenTypeAssociations = {};

//   void loadTypeChart(
//     Map<dynamic, TokenType> newTypeChart,
//     Map<TokenType, List<dynamic>> newTokenTypeAssociations,
//     {bool replace = false}){
    
//     if (typeChart.isNotEmpty && replace == false) {
//       throw "TypeChart not empty";
//     } else {
//       typeChart = newTypeChart;
//       tokenTypeAssociations = newTokenTypeAssociations;
//     }
//   }

//   void _addTokenTypeAssociationWithCharCode(TokenType tokenType, int charCode){
//     tokenTypeAssociations[tokenType] == null
//       ? tokenTypeAssociations[tokenType] = [charCode]
//       : tokenTypeAssociations[tokenType]!.add(charCode);
//   }

//   void _addTokenTypeAssociation(TokenType tokenType, dynamic value){
//     tokenTypeAssociations[tokenType] == null
//       ? tokenTypeAssociations[tokenType] = [value]
//       : tokenTypeAssociations[tokenType]!.add(value);
//   }

//   void _addTokenTypeAssocationWithTokenType(TokenType tokenType) {
//     tokenTypeAssociations[tokenType] == null
//       ? tokenTypeAssociations[tokenType] = [tokenType]
//       : tokenTypeAssociations[tokenType]!.add(tokenType);
//   }

//   /// Standard way to map given value to TokenType
//   void mapTokenType(TokenType tokenType, dynamic value) {
//     typeChart[value] = tokenType;
//     _addTokenTypeAssociation(tokenType, value);
//   }

//   void mapTokenTypeToCharCode(TokenType tokenType, int charCode) {
//     typeChart[charCode] = tokenType;
//     _addTokenTypeAssociationWithCharCode(tokenType, charCode);
//   }

//   // Adds TokenType to TypeChart
//   void addTokenType(TokenType tokenType) {
//     typeChart[tokenType.type] = tokenType;
//     _addTokenTypeAssocationWithTokenType(tokenType);
//   }
// }