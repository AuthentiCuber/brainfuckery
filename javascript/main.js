"use strict";

class TokenType {
    static DP_INC = ">";
    static DP_DEC = "<";
    static DATA_INC = "+";
    static DATA_DEC = "-";
    static INPUT = ",";
    static OUTPUT= ".";
    static JZ = "[";
    static JNZ = "]";

    static fromChar(c) {
        switch (c) {
            case ">":
                return TokenType.DP_INC;
            case "<":
                return TokenType.DP_DEC;
            case "+":
                return TokenType.DATA_INC;
            case "-":
                return TokenType.DATA_INC;
            case ",":
                return TokenType.INPUT;
            case ".":
                return TokenType.OUTPUT;
            case "[":
                return TokenType.JZ;
            case "]":
                return TokenType.JNZ;
        }
    }
}

class Command {
    constructor(tokType, param) {
        this.tokType = tokType;
        this.param = param;
    }
}

// use Int8Array for memory
