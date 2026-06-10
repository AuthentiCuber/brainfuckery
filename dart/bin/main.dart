import 'dart:io';

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
  TokenType tokType;
  int param;

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

  List<int> jumpLocStack = [];
  for (var i = 0; i < cmds.length; i++) {
    switch (cmds[i].tokType) {
      case TokenType.jz:
        jumpLocStack.add(i);
        break;
      case TokenType.jnz:
        final jmpLoc = jumpLocStack.removeLast();
        cmds[i].param = jmpLoc;
        cmds[jmpLoc].param = i;
        break;
      default:
        break;
    }
  }

  return cmds;
}

String run(List<Command> cmds) {
  var output = StringBuffer();
  var memory = List.filled(30000, 0);
  var dataPtr = 0;
  var cmdPtr = 0;
  while (cmdPtr < cmds.length) {
    var currCmd = cmds[cmdPtr];

    switch (currCmd.tokType) {
      case TokenType.dpInc:
        dataPtr += currCmd.param;
        break;
      case TokenType.dpDec:
        dataPtr -= currCmd.param;
        break;
      case TokenType.dataInc:
        memory[dataPtr] += currCmd.param;
        break;
      case TokenType.dataDec:
        memory[dataPtr] -= currCmd.param;
        break;
      case TokenType.input:
        memory[dataPtr] = stdin.readByteSync();
        break;
      case TokenType.output:
        output.writeAll(
          List.filled(currCmd.param, String.fromCharCode(memory[dataPtr])),
        );
        break;
      case TokenType.jz:
        if (memory[dataPtr] == 0) {
          cmdPtr = currCmd.param;
        }
        break;
      case TokenType.jnz:
        if (memory[dataPtr] != 0) {
          cmdPtr = currCmd.param;
        }
        break;
    }

    memory[dataPtr] %= 256;
    cmdPtr++;
  }
  return output.toString();
}

void main(List<String> arguments) {
  final inputFilePath = arguments[0];
  final file = File(inputFilePath);
  final bfInput = file.readAsStringSync();
  final toks = tokenise(bfInput);
  final cmds = parse(toks);
  final output = run(cmds);
  print(output);
}
