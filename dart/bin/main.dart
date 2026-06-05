enum TokenType {
  dpInc(">"),
  dpDec("<"),
  dataInc("+"),
  dataDec("-"),
  input(","),
  output("."),
  jz("["),
  jnz("]");

  const TokenType(this.char);

  final String char;

  factory TokenType.fromChar(String char) {
    switch (char) {
      case ">":
        return TokenType.dpInc;
      case "<":
        return TokenType.dpDec;
      case "+":
        return TokenType.dataInc;
      case "-":
        return TokenType.dataDec;
      case "[":
        return TokenType.jz;
      case "]":
        return TokenType.jnz;
      case ".":
        return TokenType.output;
      case ",":
        return TokenType.input;
      default:
        throw StateError("This should never happen");
    }
  }
}

class Command {
  TokenType? tokType;
  int? param;
}

const bfChars = "><+-[],.";

bool isValidBF(String char) {
  return bfChars.contains(char);
}

List<TokenType> tokenise(String inp) {
  List<TokenType> toks = [];
  for (var i = 0; i < inp.length; i++) {
    String char = inp[i];
    if (!isValidBF(char)) continue;
    toks.add(TokenType.fromChar(char));
  }
  return toks;
}

void main(List<String> arguments) {
  final toks = tokenise("++++++++[>+++++++++<-]>.");
  print(toks);
}
