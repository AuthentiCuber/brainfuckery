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

  static bool isJump(TokenType tok) {
    return [TokenType.jz, TokenType.jnz].contains(tok);
  }
}

class Command {
  TokenType? tokType;
  int? param;

  Command(this.tokType, this.param);
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

List<Command> parse(List<TokenType> toks) {
  List<Command> cmds = [];
  int tokCounter = 1;
  for (var i = 0; i < toks.length; i++) {
    final currTok = toks[i];
    if (TokenType.isJump(currTok)) {
      cmds.add(Command(currTok, -1));
      continue;
    }

    if (i + 1 < toks.length) {
      if (toks[i + 1] == currTok) {
        tokCounter++;
        continue;
      }
    }

    cmds.add(Command(currTok, tokCounter));
    tokCounter = 1;
  }
  return cmds;
}

void main(List<String> arguments) {
  final toks = tokenise("++++++++[>+++++++++<-]>.");
  final cmds = parse(toks);
  cmds.forEach((cmd) => print("${cmd.tokType}:${cmd.param}"));
}
