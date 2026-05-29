import Data.List
import Data.Maybe
import Data.Tuple

bfChars :: [Char]
bfChars = "><+-,.[]"

data TokenType = DP_INC | DP_DEC | DATA_INC | DATA_DEC | INPUT | OUTPUT | JZ | JNZ
  deriving (Show, Eq)

getTokenType :: Char -> TokenType
getTokenType '>' = DP_INC
getTokenType '<' = DP_DEC
getTokenType '+' = DATA_INC
getTokenType '-' = DATA_DEC
getTokenType ',' = INPUT
getTokenType '.' = OUTPUT
getTokenType '[' = JZ
getTokenType ']' = JNZ

data Token = Token
  { tokType :: TokenType,
    param :: Int
  }
  deriving (Show)

isValidChar :: Char -> Bool
isValidChar c = c `elem` bfChars

preprocess :: String -> String
preprocess = filter isValidChar

tokenise :: String -> [TokenType]
tokenise = map getTokenType

-- combine repeated instructions
makeToken :: [TokenType] -> Token
makeToken toks = Token (head toks) p
  where
    p = length toks

parse :: [TokenType] -> [Token]
parse inp = map makeToken $ groupBy groupCond inp
  where
    groupCond :: TokenType -> TokenType -> Bool
    groupCond JZ _ = False
    groupCond JNZ _ = False
    groupCond start curr = start == curr

-- bachpatch jump positions
resolveJumps' :: [(Int, Token)] -> [Int] -> [(Int, Int)] -> [(Int, Int)]
resolveJumps' [] stack pairs = pairs
resolveJumps' ((index, Token JZ _) : rest) stack pairs =
  resolveJumps' rest (index : stack) pairs
resolveJumps' ((index, Token JNZ _) : rest) stack pairs =
  resolveJumps' rest (tail stack) ((head stack, index) : pairs)

resolveJumps :: [Token] -> [Token]
resolveJumps inp = map jump comms
  where
    comms = zip [0 ..] inp
    jumps = filter isJump comms
    isJump (_, Token JZ _) = True
    isJump (_, Token JNZ _) = True
    isJump _ = False
    forwardIndices = resolveJumps' jumps [] []
    revIndices = map swap forwardIndices
    indices = forwardIndices ++ revIndices
    jump (i, Token JZ _) = Token JZ $ fromMaybe (-1) $ lookup i indices
    jump (i, Token JNZ _) = Token JNZ $ fromMaybe (-1) $ lookup i indices
    jump (_, t) = t

main :: IO ()
main = putStrLn "Hello BrainFuckery!"
