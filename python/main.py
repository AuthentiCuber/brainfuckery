from dataclasses import dataclass
from enum import Enum


class TokenType(Enum):
    DP_INC = ">"
    DP_DEC = "<"
    DATA_INC = "+"
    DATA_DEC = "-"
    INPUT = ","
    OUTPUT = ","
    JZ = "["
    JNZ = "]"


BF_CHARS = [tt.value for tt in TokenType]


@dataclass
class Token:
    tok_type: TokenType
    param: int  # instruction jump address for JZ & JNZ, number of repetitions otherwise


def is_valid_bf(char: str) -> bool:
    return char in BF_CHARS


def lex(inp: str) -> list[Token]:
    toks: list[Token] = []

    inp_index = 0
    while inp_index < len(inp):
        char = inp[inp_index]
        if not is_valid_bf(char):
            inp_index += 1
            continue

        if char in "[]":
            tok_type = TokenType(char)
        else:
            tok_type = TokenType(char)

    return toks
