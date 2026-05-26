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
class Command:
    tok_type: TokenType
    param: int  # instruction jump address for JZ & JNZ, number of repetitions otherwise


def is_valid_bf(char: str) -> bool:
    return char in BF_CHARS


def tokenise(inp: str) -> list[TokenType]:
    return [TokenType(char) for char in inp if is_valid_bf(char)]
