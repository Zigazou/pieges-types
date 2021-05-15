module Types where

import qualified Data.List as List
import qualified Data.Char as Char

infinite = 10::Int -- Arbitrary limit

searchTerminals = 5::Int -- Maximum search depth for terminals

data Production = Production {production'name::String, 
                              production'def::Grammar, 
                              production'safe::Bool -- Indicates if we can "safely" 
                                               -- recurse into, without risking an infinite
                                               -- recursion. The ABNF parser will set 
                                               -- "safe" if it meets only terminals up to 
                                               -- level searchTerminals.
                             } deriving Show
-- TODO: store the line number, too

data Grammar = Choice [Production] | Sequence [Production] | 
               Repeat Int Int Production | Constant String | CI_Constant String deriving Show
               -- CI: case insensitive

printable c =
        if Char.ord c <= 0x7E && Char.ord c >= 21 then
            c
        else
            -- Non-printable
            '?'

safeToString s =
   if s then 
       " (Safe)"
   else
       " (UNsafe)"

toString :: Production -> String
toString p = toString' (production'def p) ++ safeToString (production'safe p)

-- TODO: control recursion, a production can be infinitely deep!
toString' :: Grammar -> String
toString' (Choice gs) = "Choice[" ++ 
                         concat (List.intersperse " " (map toString gs)) ++ "]"
toString' (Sequence gs) = "Seq[" ++ concat (List.intersperse " " (map toString gs)) ++ "]"
toString' (Repeat l u g) = (show l) ++ "*" ++ (show u) ++ "" ++ (toString g)
toString' (CI_Constant s) = "\"" ++ map printable s ++ "\""
toString' (Constant s) = "\"" ++ map printable s ++ "\""

mkConstant :: String -> Production
mkConstant s = Production s (Constant s) True

mkCI_Constant :: String -> Production
mkCI_Constant s = Production s (CI_Constant s) True

onlyTerminal :: Grammar -> Bool
onlyTerminal (Constant c) = True
onlyTerminal (CI_Constant c) = True
onlyTerminal _ = False

onlyTerminals :: [Production] -> [Production]
onlyTerminals gs = 
   filter (onlyTerminal . production'def)  gs

onlyTerminalAtDepth :: Int -> Grammar -> Bool
onlyTerminalAtDepth 0 _ = False
onlyTerminalAtDepth _ (Constant c) = True
onlyTerminalAtDepth _ (CI_Constant c) = True
onlyTerminalAtDepth 1 _ = False
onlyTerminalAtDepth d (Choice gs) = 
    or (map (onlyTerminalAtDepth (d-1) . production'def) gs)
onlyTerminalAtDepth d (Sequence gs) = 
    and (map (onlyTerminalAtDepth (d-1) . production'def) gs)
onlyTerminalAtDepth d (Repeat _ _ g) = 
    onlyTerminalAtDepth (d-1) (production'def g)

-- ALPHA in RFC 4234
letter = Production "letter" (Choice 
                 [mkConstant "a", mkConstant "b", mkConstant "c", mkConstant "d", 
                 mkConstant "e", mkConstant "f", mkConstant "g", mkConstant "h",
                 mkConstant "i", mkConstant "j", mkConstant "k", mkConstant "l",
                 mkConstant "i", mkConstant "j", mkConstant "k", mkConstant "l",
                 mkConstant "m", mkConstant "n", mkConstant "o", mkConstant "p",
                 mkConstant "q", mkConstant "r", mkConstant "s", mkConstant "t",
                 mkConstant "u", mkConstant "v", mkConstant "w", mkConstant "x",
                 mkConstant "y", mkConstant "z",
                 mkConstant "A", mkConstant "B", mkConstant "C", mkConstant "D",
                 mkConstant "E", mkConstant "F", mkConstant "G", mkConstant "H",
                 mkConstant "I", mkConstant "J", mkConstant "K", mkConstant "L",
                 mkConstant "M", mkConstant "N", mkConstant "O", mkConstant "P",
                 mkConstant "Q", mkConstant "R", mkConstant "S", mkConstant "T",
                 mkConstant "U", mkConstant "V", mkConstant "W", mkConstant "X",
                 mkConstant "Y", mkConstant "Z"
                  ]) True
letters = Production "letters" (Repeat 1 infinite letter) True

-- TODO: BIT, CHAR, CR, DQUOTE, WSP, SP, OCTET

-- DIGIT in RFC 4234
digit = Production "digit" (Choice 
              [mkConstant "0", mkConstant "1", mkConstant "2",
               mkConstant "3", mkConstant "4", mkConstant "5", 
               mkConstant "6", mkConstant "7", mkConstant "8", mkConstant "9"]) True

spaces = Production "spaces" (Repeat 0 infinite (mkConstant " ")) True
-- TODO: or a choice of tab or space?
spaces1 = Production "spaces" (Repeat 1 infinite (mkConstant " ")) True

