from dataclasses import dataclass
from enum import Enum
from io import StringIO


class TokenType(Enum):
    DP_INC = ">"
    DP_DEC = "<"
    DATA_INC = "+"
    DATA_DEC = "-"
    INPUT = ","
    OUTPUT = "."
    JZ = "["
    JNZ = "]"


BF_CHARS = [tt.value for tt in TokenType]


@dataclass
class Command:
    tok_type: TokenType
    param: int  # instruction jump address for JZ & JNZ, number of repetitions otherwise

    def __repr__(self) -> str:
        return f"{self.tok_type.value}: {self.param}"


def is_valid_bf(char: str) -> bool:
    return char in BF_CHARS


def tokenise(inp: str) -> list[TokenType]:
    return [TokenType(char) for char in inp if is_valid_bf(char)]


def parse(toks: list[TokenType]) -> list[Command]:
    commands: list[Command] = []

    # turn tokens into commands
    counter = 1
    for index, tok in enumerate(toks):
        if tok in (TokenType.JZ, TokenType.JNZ):
            commands.append(
                Command(tok, 0)  # this is filled in properly in the next step
            )
            continue

        if index + 1 < len(toks):
            if toks[index + 1] == tok:
                counter += 1
                continue

        commands.append(Command(tok, counter))
        counter = 1

    # resolve jump locations
    loc_stack: list[int] = []
    for index, comm in enumerate(commands):
        match comm.tok_type:
            case TokenType.JZ:
                loc_stack.append(index)
            case TokenType.JNZ:
                loc = loc_stack.pop()
                comm.param = loc
                commands[loc].param = index

    return commands


def run(comms: list[Command]) -> str:
    output = StringIO()
    cmd_ptr = 0
    data_ptr = 0
    memory = [0] * 30_000
    while cmd_ptr < len(comms):
        comm = comms[cmd_ptr]

        match comm.tok_type:
            case TokenType.DP_INC:
                data_ptr += comm.param
            case TokenType.DP_DEC:
                data_ptr -= comm.param
            case TokenType.DATA_INC:
                memory[data_ptr] += comm.param
            case TokenType.DATA_DEC:
                memory[data_ptr] -= comm.param
            case TokenType.JZ:
                if memory[data_ptr] == 0:
                    cmd_ptr = comm.param
            case TokenType.JNZ:
                if memory[data_ptr] != 0:
                    cmd_ptr = comm.param
            case TokenType.INPUT:
                for _ in range(comm.param):
                    memory[data_ptr] = ord(input())
            case TokenType.OUTPUT:
                for _ in range(comm.param):
                    output.write(chr(memory[data_ptr]))

        memory[data_ptr] %= 256
        cmd_ptr += 1

    return output.getvalue()


if __name__ == "__main__":
    inp = input()
    tokens = tokenise(inp)
    commands = parse(tokens)
    output = run(commands)
    print(output)
