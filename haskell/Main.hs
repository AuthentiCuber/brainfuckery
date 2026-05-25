import Data.List

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

isValidChar :: Char -> Bool
isValidChar c = c `elem` bfChars

preprocess :: String -> String
preprocess = filter isValidChar

tokenise :: String -> [TokenType]
tokenise = map getTokenType

groupCond :: TokenType -> TokenType -> Bool
groupCond JZ _ = False
groupCond JNZ _ = False
groupCond start curr = start == curr

makeToken :: [TokenType] -> Token
makeToken toks = Token (head toks) p
  where
    p = length toks

parse :: [TokenType] -> [Token]
parse inp = map makeToken $ groupBy groupCond inp

main :: IO ()
main = putStrLn "Hello BrainFuckery!"
