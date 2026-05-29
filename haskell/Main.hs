import Data.Char
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

isJump :: TokenType -> Bool
isJump JZ = True
isJump JNZ = True
isJump _ = False

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
    jumps = filter (\(_, Token t _) -> isJump t) comms
    forwardIndices = resolveJumps' jumps [] []
    revIndices = map swap forwardIndices
    indices = forwardIndices ++ revIndices
    jump (i, tok@(Token t _))
      | isJump t = Token t $ fromMaybe (-1) $ lookup i indices
      | otherwise = tok

data ProgState = ProgState
  { commands :: [Token],
    cmd_ptr :: Int,
    data_ptr :: Int,
    memory :: [Int],
    output :: String
  }

stepProg :: ProgState -> Maybe ProgState
stepProg prog@(ProgState cmds ip dp mem output)
  | ip == length cmds = Nothing
  | otherwise = Just $ executeCmd cmd
  where
    cmd = cmds !! ip
    executeCmd (Token DP_INC amount) = ProgState cmds (ip + 1) (dp + amount) mem output
    executeCmd (Token DP_DEC amount) = ProgState cmds (ip + 1) (dp - amount) mem output
    executeCmd (Token JZ loc) = jz $ mem !! dp
      where
        jz cellVal
          | cellVal == 0 = ProgState cmds (loc + 1) dp mem output
          | otherwise = ProgState cmds (ip + 1) dp mem output
    executeCmd (Token JNZ loc) = jnz $ mem !! dp
      where
        jnz cellVal
          | cellVal /= 0 = ProgState cmds (loc + 1) dp mem output
          | otherwise = ProgState cmds (ip + 1) dp mem output
    executeCmd (Token OUTPUT amount) = ProgState cmds (ip + 1) dp mem (chr cellData : output)
      where
        cellData = mem !! dp

main :: IO ()
main = putStrLn "Hello BrainFuckery!"
