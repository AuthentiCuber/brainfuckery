import Data.Array (Array, (!), (//))
import Data.Array qualified as A
import Data.Char
import Data.List
import Data.Maybe
import Data.Tuple
import System.Environment
import System.IO

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

data Command = Command
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
makeToken :: [TokenType] -> Command
makeToken toks = Command (head toks) p
  where
    p = length toks

parse :: [TokenType] -> [Command]
parse inp = map makeToken $ groupBy groupCond inp
  where
    groupCond :: TokenType -> TokenType -> Bool
    groupCond JZ _ = False
    groupCond JNZ _ = False
    groupCond start curr = start == curr

-- bachpatch jump positions
resolveJumps' :: [(Int, Command)] -> [Int] -> [(Int, Int)] -> [(Int, Int)]
resolveJumps' [] stack pairs = pairs
resolveJumps' ((index, Command JZ _) : rest) stack pairs =
  resolveJumps' rest (index : stack) pairs
resolveJumps' ((index, Command JNZ _) : rest) stack pairs =
  resolveJumps' rest (tail stack) ((head stack, index) : pairs)

resolveJumps :: [Command] -> [Command]
resolveJumps inp = map jump comms
  where
    comms = zip [0 ..] inp
    jumps = filter (\(_, Command t _) -> isJump t) comms
    forwardIndices = resolveJumps' jumps [] []
    revIndices = map swap forwardIndices
    indices = forwardIndices ++ revIndices
    jump (i, tok@(Command t _))
      | isJump t = Command t $ fromMaybe (-1) $ lookup i indices
      | otherwise = tok

data ProgState = ProgState
  { commands :: [Command],
    cmd_ptr :: Int,
    data_ptr :: Int,
    memory :: Array Int Int,
    output :: String
  }

stepProg :: ProgState -> IO ProgState
stepProg (ProgState cmds ip dp mem output) = executeCmd cmd
  where
    cmd = cmds !! ip
    executeCmd :: Command -> IO ProgState
    executeCmd (Command DP_INC amount) = pure $ ProgState cmds (ip + 1) (dp + amount) mem output
    executeCmd (Command DP_DEC amount) = pure $ ProgState cmds (ip + 1) (dp - amount) mem output
    executeCmd (Command DATA_INC amount) = pure $ ProgState cmds (ip + 1) dp (mem // [(dp, newVal)]) output
      where
        newVal = (mem ! dp) + amount
    executeCmd (Command DATA_DEC amount) = pure $ ProgState cmds (ip + 1) dp (mem // [(dp, newVal)]) output
      where
        newVal = (mem ! dp) - amount
    executeCmd (Command JZ loc) = pure $ jz $ mem ! dp
      where
        jz cellVal
          | cellVal == 0 = ProgState cmds (loc + 1) dp mem output
          | otherwise = ProgState cmds (ip + 1) dp mem output
    executeCmd (Command JNZ loc) = pure $ jnz $ mem ! dp
      where
        jnz cellVal
          | cellVal /= 0 = ProgState cmds (loc + 1) dp mem output
          | otherwise = ProgState cmds (ip + 1) dp mem output
    executeCmd (Command OUTPUT amount) = pure $ ProgState cmds (ip + 1) dp mem newOut
      where
        newOut = output ++ replicate amount (chr cellData)
        cellData = mem ! dp
    executeCmd (Command INPUT _) = do
      c <- getChar
      let newVal = ord c
      return $ ProgState cmds (ip + 1) dp (mem // [(dp, newVal)]) output

runProg :: ProgState -> IO String
runProg prog
  | cmd_ptr prog == length (commands prog) = pure $ output prog
  | otherwise = do
      newState <- stepProg prog
      runProg newState

run :: String -> IO String
run inp = runProg $ ProgState cmds 0 0 mem ""
  where
    cmds = resolveJumps $ parse $ tokenise $ preprocess inp
    mem = A.listArray (0, memSize) $ replicate memSize 0
    memSize = 30000

parseArgs :: [String] -> IO String
parseArgs (x1 : xs)
  | x1 == "--literal" || x1 == "-l" = pure $ head xs
  | otherwise = readFile x1

main :: IO ()
main = do
  args <- getArgs
  input <- parseArgs args
  result <- run input
  putStr result
