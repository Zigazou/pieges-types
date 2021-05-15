module Parse where

import Text.ParserCombinators.Parsec as Parsec hiding (spaces, newline, option)
import qualified Monad
import Data.Maybe
import Prelude hiding (repeat)
import qualified List
import qualified Numeric
import qualified Data.Char as Char
import qualified Data.Map as Map
import qualified Types

facultative p = Monad.liftM Just p <|> return Nothing

infinity = 10::Int -- Arbitrary value for the repetition. TODO: use a better stuff.

-- Low-level types, used only for parsing ("real" types are in Types.hs)
type ABNF = [Rule]
data ParsedGrammar = Choice [ParsedGrammar] | Sequence [ParsedGrammar] | 
               Repeat Int Int ParsedGrammar | CI_Constant String | 
               -- CI : case-insensitive. RFC 4234 2.3
               Constant String | ConstantCode Int |
               RuleName String
                            deriving Show
data RuleDefinition = Definition | Incrementation deriving (Eq, Show)
data Rule = Rule {rule'name::String, rule'def::RuleDefinition, rule'content::ParsedGrammar, rule'core::Bool} deriving Show
-- Concatenation binds tighter than Alternative so:
--    a / b c  
-- is
--    a / (b c)

printable c =
        if Char.ord c <= 0x7E && Char.ord c >= 21 then
            c
        else
            -- Non-printable
            '?'

toString :: ABNF -> String
toString g = concat (List.intersperse "\n" 
                             (map toString' (filter (\r -> not (rule'core r)) g)))

toString' :: Rule -> String
toString' r =
    (rule'name r) ++ " : " ++ (toString'' (rule'content r))

toString'' :: ParsedGrammar -> String
toString'' (Choice gs) = "Choice[" ++ 
                         concat (List.intersperse " " (map toString'' gs)) ++ "]"
toString'' (Sequence gs) = "Seq[" ++ concat (List.intersperse " " (map toString'' gs)) ++ "]"
toString'' (Repeat l u g) = (show l) ++ "*" ++ (show u) ++ "" ++ (toString'' g)
toString'' (CI_Constant s) = s
toString'' (Constant s) = map printable s
toString'' (ConstantCode c) = (show c)
toString'' (RuleName r) = r

-- "Core rules" in RFC 4234, appendix B.1
predefinedRules :: ABNF 
predefinedRules = [Rule "ALPHA" Definition (Choice [Constant "A", Constant "B", Constant "C", Constant "D", Constant "E", Constant "F", Constant "G", Constant "H", Constant "I", Constant "J", Constant "K", Constant "L", Constant "M", Constant "N", Constant "O", Constant "P", Constant "Q", Constant "R", Constant "S", Constant "T", Constant "U", Constant "V", Constant "W", Constant "X", Constant "Y", Constant "Z", Constant "a", Constant "b", Constant "c", Constant "d", Constant "e", Constant "f", Constant "g", Constant "h", Constant "i", Constant "j", Constant "k", Constant "l", Constant "m", Constant "n", Constant "o", Constant "p", Constant "q", Constant "r", Constant "s", Constant "t", Constant "u", Constant "v", Constant "w", Constant "x", Constant "y", Constant "z"]) True, 
                   Rule "BIT"  Definition (Choice [Constant "0", Constant "1"]) True,
                   -- TODO: define CHAR and OCTET (but not VCHAR) with ConstantCode, not Constant?
                   Rule "CHAR"  Definition (Choice [Constant [Char.chr(1)], Constant [Char.chr(2)], Constant [Char.chr(3)], Constant [Char.chr(4)], Constant [Char.chr(5)], Constant [Char.chr(6)], Constant [Char.chr(7)], Constant [Char.chr(8)], Constant [Char.chr(9)], Constant [Char.chr(10)], Constant [Char.chr(11)], Constant [Char.chr(12)], Constant [Char.chr(13)], Constant [Char.chr(14)], Constant [Char.chr(15)], Constant [Char.chr(16)], Constant [Char.chr(17)], Constant [Char.chr(18)], Constant [Char.chr(19)], Constant [Char.chr(20)], Constant [Char.chr(21)], Constant [Char.chr(22)], Constant [Char.chr(23)], Constant [Char.chr(24)], Constant [Char.chr(25)], Constant [Char.chr(26)], Constant [Char.chr(27)], Constant [Char.chr(28)], Constant [Char.chr(29)], Constant [Char.chr(30)], Constant [Char.chr(31)], Constant [Char.chr(32)], Constant [Char.chr(33)], Constant [Char.chr(34)], Constant [Char.chr(35)], Constant [Char.chr(36)], Constant [Char.chr(37)], Constant [Char.chr(38)], Constant [Char.chr(39)], Constant [Char.chr(40)], Constant [Char.chr(41)], Constant [Char.chr(42)], Constant [Char.chr(43)], Constant [Char.chr(44)], Constant [Char.chr(45)], Constant [Char.chr(46)], Constant [Char.chr(47)], Constant [Char.chr(48)], Constant [Char.chr(49)], Constant [Char.chr(50)], Constant [Char.chr(51)], Constant [Char.chr(52)], Constant [Char.chr(53)], Constant [Char.chr(54)], Constant [Char.chr(55)], Constant [Char.chr(56)], Constant [Char.chr(57)], Constant [Char.chr(58)], Constant [Char.chr(59)], Constant [Char.chr(60)], Constant [Char.chr(61)], Constant [Char.chr(62)], Constant [Char.chr(63)], Constant [Char.chr(64)], Constant [Char.chr(65)], Constant [Char.chr(66)], Constant [Char.chr(67)], Constant [Char.chr(68)], Constant [Char.chr(69)], Constant [Char.chr(70)], Constant [Char.chr(71)], Constant [Char.chr(72)], Constant [Char.chr(73)], Constant [Char.chr(74)], Constant [Char.chr(75)], Constant [Char.chr(76)], Constant [Char.chr(77)], Constant [Char.chr(78)], Constant [Char.chr(79)], Constant [Char.chr(80)], Constant [Char.chr(81)], Constant [Char.chr(82)], Constant [Char.chr(83)], Constant [Char.chr(84)], Constant [Char.chr(85)], Constant [Char.chr(86)], Constant [Char.chr(87)], Constant [Char.chr(88)], Constant [Char.chr(89)], Constant [Char.chr(90)], Constant [Char.chr(91)], Constant [Char.chr(92)], Constant [Char.chr(93)], Constant [Char.chr(94)], Constant [Char.chr(95)], Constant [Char.chr(96)], Constant [Char.chr(97)], Constant [Char.chr(98)], Constant [Char.chr(99)], Constant [Char.chr(100)], Constant [Char.chr(101)], Constant [Char.chr(102)], Constant [Char.chr(103)], Constant [Char.chr(104)], Constant [Char.chr(105)], Constant [Char.chr(106)], Constant [Char.chr(107)], Constant [Char.chr(108)], Constant [Char.chr(109)], Constant [Char.chr(110)], Constant [Char.chr(111)], Constant [Char.chr(112)], Constant [Char.chr(113)], Constant [Char.chr(114)], Constant [Char.chr(115)], Constant [Char.chr(116)], Constant [Char.chr(117)], Constant [Char.chr(118)], Constant [Char.chr(119)], Constant [Char.chr(120)], Constant [Char.chr(121)], Constant [Char.chr(122)], Constant [Char.chr(123)], Constant [Char.chr(124)], Constant [Char.chr(125)], Constant [Char.chr(126)], Constant [Char.chr(127)]]) True,
                   Rule "CR" Definition (Constant "\n") True,
                   Rule "CRLF" Definition (Sequence [Constant "\n", Constant "\r"]) True,
                   Rule "CTL" Definition (Choice [Constant [Char.chr(0)], Constant [Char.chr(1)], Constant [Char.chr(2)], Constant [Char.chr(3)], Constant [Char.chr(4)], Constant [Char.chr(5)], Constant [Char.chr(6)], Constant [Char.chr(7)], Constant [Char.chr(8)], Constant [Char.chr(9)], Constant [Char.chr(10)], Constant [Char.chr(11)], Constant [Char.chr(12)], Constant [Char.chr(13)], Constant [Char.chr(14)], Constant [Char.chr(15)], Constant [Char.chr(16)], Constant [Char.chr(17)], Constant [Char.chr(18)], Constant [Char.chr(19)], Constant [Char.chr(20)], Constant [Char.chr(21)], Constant [Char.chr(22)], Constant [Char.chr(23)], Constant [Char.chr(24)], Constant [Char.chr(25)], Constant [Char.chr(26)], Constant [Char.chr(27)], Constant [Char.chr(28)], Constant [Char.chr(29)], Constant [Char.chr(30)], Constant [Char.chr(31)], Constant [Char.chr(127)]]) True,
                   Rule "DIGIT" Definition (Choice [Constant "0", Constant "1", Constant "2", Constant "3", Constant "4", Constant "5", Constant "6", Constant "7", Constant "8", Constant "9"]) True, 
                   Rule "DQUOTE" Definition (Constant "\"") True,
                   Rule "HEXDIG" Definition (Choice [Constant "0", Constant "1", Constant "2", Constant "3", Constant "4", Constant "5", Constant "6", Constant "7", Constant "8", Constant "9", Constant "A", Constant "B", Constant "C", Constant "D", Constant "E", Constant "F", Constant "a", Constant "b", Constant "c", Constant "d", Constant "e", Constant "f"]) True,
                   Rule "HTAB" Definition (Constant "\t") True,
                   Rule "LF" Definition (Constant "\n") True,
                   Rule "LWSP" Definition (Repeat 0 infinity (Choice [Choice [Constant " ", Constant "\t"], Sequence [Sequence [Constant "\n", Constant "\r"], Choice [Constant " ", Constant "\t"]]])) True,
                   Rule "OCTET" Definition (Choice [Constant [Char.chr(0)], Constant [Char.chr(1)], Constant [Char.chr(2)], Constant [Char.chr(3)], Constant [Char.chr(4)], Constant [Char.chr(5)], Constant [Char.chr(6)], Constant [Char.chr(7)], Constant [Char.chr(8)], Constant [Char.chr(9)], Constant [Char.chr(10)], Constant [Char.chr(11)], Constant [Char.chr(12)], Constant [Char.chr(13)], Constant [Char.chr(14)], Constant [Char.chr(15)], Constant [Char.chr(16)], Constant [Char.chr(17)], Constant [Char.chr(18)], Constant [Char.chr(19)], Constant [Char.chr(20)], Constant [Char.chr(21)], Constant [Char.chr(22)], Constant [Char.chr(23)], Constant [Char.chr(24)], Constant [Char.chr(25)], Constant [Char.chr(26)], Constant [Char.chr(27)], Constant [Char.chr(28)], Constant [Char.chr(29)], Constant [Char.chr(30)], Constant [Char.chr(31)], Constant [Char.chr(32)], Constant [Char.chr(33)], Constant [Char.chr(34)], Constant [Char.chr(35)], Constant [Char.chr(36)], Constant [Char.chr(37)], Constant [Char.chr(38)], Constant [Char.chr(39)], Constant [Char.chr(40)], Constant [Char.chr(41)], Constant [Char.chr(42)], Constant [Char.chr(43)], Constant [Char.chr(44)], Constant [Char.chr(45)], Constant [Char.chr(46)], Constant [Char.chr(47)], Constant [Char.chr(48)], Constant [Char.chr(49)], Constant [Char.chr(50)], Constant [Char.chr(51)], Constant [Char.chr(52)], Constant [Char.chr(53)], Constant [Char.chr(54)], Constant [Char.chr(55)], Constant [Char.chr(56)], Constant [Char.chr(57)], Constant [Char.chr(58)], Constant [Char.chr(59)], Constant [Char.chr(60)], Constant [Char.chr(61)], Constant [Char.chr(62)], Constant [Char.chr(63)], Constant [Char.chr(64)], Constant [Char.chr(65)], Constant [Char.chr(66)], Constant [Char.chr(67)], Constant [Char.chr(68)], Constant [Char.chr(69)], Constant [Char.chr(70)], Constant [Char.chr(71)], Constant [Char.chr(72)], Constant [Char.chr(73)], Constant [Char.chr(74)], Constant [Char.chr(75)], Constant [Char.chr(76)], Constant [Char.chr(77)], Constant [Char.chr(78)], Constant [Char.chr(79)], Constant [Char.chr(80)], Constant [Char.chr(81)], Constant [Char.chr(82)], Constant [Char.chr(83)], Constant [Char.chr(84)], Constant [Char.chr(85)], Constant [Char.chr(86)], Constant [Char.chr(87)], Constant [Char.chr(88)], Constant [Char.chr(89)], Constant [Char.chr(90)], Constant [Char.chr(91)], Constant [Char.chr(92)], Constant [Char.chr(93)], Constant [Char.chr(94)], Constant [Char.chr(95)], Constant [Char.chr(96)], Constant [Char.chr(97)], Constant [Char.chr(98)], Constant [Char.chr(99)], Constant [Char.chr(100)], Constant [Char.chr(101)], Constant [Char.chr(102)], Constant [Char.chr(103)], Constant [Char.chr(104)], Constant [Char.chr(105)], Constant [Char.chr(106)], Constant [Char.chr(107)], Constant [Char.chr(108)], Constant [Char.chr(109)], Constant [Char.chr(110)], Constant [Char.chr(111)], Constant [Char.chr(112)], Constant [Char.chr(113)], Constant [Char.chr(114)], Constant [Char.chr(115)], Constant [Char.chr(116)], Constant [Char.chr(117)], Constant [Char.chr(118)], Constant [Char.chr(119)], Constant [Char.chr(120)], Constant [Char.chr(121)], Constant [Char.chr(122)], Constant [Char.chr(123)], Constant [Char.chr(124)], Constant [Char.chr(125)], Constant [Char.chr(126)], Constant [Char.chr(127)], Constant [Char.chr(128)], Constant [Char.chr(129)], Constant [Char.chr(130)], Constant [Char.chr(131)], Constant [Char.chr(132)], Constant [Char.chr(133)], Constant [Char.chr(134)], Constant [Char.chr(135)], Constant [Char.chr(136)], Constant [Char.chr(137)], Constant [Char.chr(138)], Constant [Char.chr(139)], Constant [Char.chr(140)], Constant [Char.chr(141)], Constant [Char.chr(142)], Constant [Char.chr(143)], Constant [Char.chr(144)], Constant [Char.chr(145)], Constant [Char.chr(146)], Constant [Char.chr(147)], Constant [Char.chr(148)], Constant [Char.chr(149)], Constant [Char.chr(150)], Constant [Char.chr(151)], Constant [Char.chr(152)], Constant [Char.chr(153)], Constant [Char.chr(154)], Constant [Char.chr(155)], Constant [Char.chr(156)], Constant [Char.chr(157)], Constant [Char.chr(158)], Constant [Char.chr(159)], Constant [Char.chr(160)], Constant [Char.chr(161)], Constant [Char.chr(162)], Constant [Char.chr(163)], Constant [Char.chr(164)], Constant [Char.chr(165)], Constant [Char.chr(166)], Constant [Char.chr(167)], Constant [Char.chr(168)], Constant [Char.chr(169)], Constant [Char.chr(170)], Constant [Char.chr(171)], Constant [Char.chr(172)], Constant [Char.chr(173)], Constant [Char.chr(174)], Constant [Char.chr(175)], Constant [Char.chr(176)], Constant [Char.chr(177)], Constant [Char.chr(178)], Constant [Char.chr(179)], Constant [Char.chr(180)], Constant [Char.chr(181)], Constant [Char.chr(182)], Constant [Char.chr(183)], Constant [Char.chr(184)], Constant [Char.chr(185)], Constant [Char.chr(186)], Constant [Char.chr(187)], Constant [Char.chr(188)], Constant [Char.chr(189)], Constant [Char.chr(190)], Constant [Char.chr(191)], Constant [Char.chr(192)], Constant [Char.chr(193)], Constant [Char.chr(194)], Constant [Char.chr(195)], Constant [Char.chr(196)], Constant [Char.chr(197)], Constant [Char.chr(198)], Constant [Char.chr(199)], Constant [Char.chr(200)], Constant [Char.chr(201)], Constant [Char.chr(202)], Constant [Char.chr(203)], Constant [Char.chr(204)], Constant [Char.chr(205)], Constant [Char.chr(206)], Constant [Char.chr(207)], Constant [Char.chr(208)], Constant [Char.chr(209)], Constant [Char.chr(210)], Constant [Char.chr(211)], Constant [Char.chr(212)], Constant [Char.chr(213)], Constant [Char.chr(214)], Constant [Char.chr(215)], Constant [Char.chr(216)], Constant [Char.chr(217)], Constant [Char.chr(218)], Constant [Char.chr(219)], Constant [Char.chr(220)], Constant [Char.chr(221)], Constant [Char.chr(222)], Constant [Char.chr(223)], Constant [Char.chr(224)], Constant [Char.chr(225)], Constant [Char.chr(226)], Constant [Char.chr(227)], Constant [Char.chr(228)], Constant [Char.chr(229)], Constant [Char.chr(230)], Constant [Char.chr(231)], Constant [Char.chr(232)], Constant [Char.chr(233)], Constant [Char.chr(234)], Constant [Char.chr(235)], Constant [Char.chr(236)], Constant [Char.chr(237)], Constant [Char.chr(238)], Constant [Char.chr(239)], Constant [Char.chr(240)], Constant [Char.chr(241)], Constant [Char.chr(242)], Constant [Char.chr(243)], Constant [Char.chr(244)], Constant [Char.chr(245)], Constant [Char.chr(246)], Constant [Char.chr(247)], Constant [Char.chr(248)], Constant [Char.chr(249)], Constant [Char.chr(250)], Constant [Char.chr(251)], Constant [Char.chr(252)], Constant [Char.chr(253)], Constant [Char.chr(254)], Constant [Char.chr(255)]]) True,
                   Rule "SP" Definition (Constant " ") True,
                   Rule "VCHAR" Definition (Choice [Constant "!", Constant "\"", Constant "#", Constant "$", Constant "%", Constant "&", Constant "'", Constant "(", Constant ")", Constant "*", Constant "+", Constant ",", Constant "-", Constant ".", Constant "/", Constant "0", Constant "1", Constant "2", Constant "3", Constant "4", Constant "5", Constant "6", Constant "7", Constant "8", Constant "9", Constant ":", Constant ";", Constant "<", Constant "=", Constant ">", Constant "?", Constant "@", Constant "A", Constant "B", Constant "C", Constant "D", Constant "E", Constant "F", Constant "G", Constant "H", Constant "I", Constant "J", Constant "K", Constant "L", Constant "M", Constant "N", Constant "O", Constant "P", Constant "Q", Constant "R", Constant "S", Constant "T", Constant "U", Constant "V", Constant "W", Constant "X", Constant "Y", Constant "Z", Constant "[", Constant "\\", Constant "]", Constant "^", Constant "_", Constant "`", Constant "a", Constant "b", Constant "c", Constant "d", Constant "e", Constant "f", Constant "g", Constant "h", Constant "i", Constant "j", Constant "k", Constant "l", Constant "m", Constant "n", Constant "o", Constant "p", Constant "q", Constant "r", Constant "s", Constant "t", Constant "u", Constant "v", Constant "w", Constant "x", Constant "y", Constant "z", Constant "{", Constant "|", Constant "}", Constant "~"]) True,
                   Rule "WSP" Definition (Choice [Constant " ", Constant "\t"]) True
                   ]

-- Grammar, using the names of RFC 4234

-- Ancillary parsers, for very general stuff

dquote = char '"'

-- TODO: the RFC mandates "\n\r" but typical Unix files end with "\n"
crlf = do {string "\n"; optional (string "\r")} <?> "End of line"

wsp = (char ' ' <|> char '\t') <?> "Whitespace character"

cwsp = try (do {cnl; wsp; return ' '}) <|> wsp

spaces = many cwsp

cnl = comment <|> crlf

vchar = oneOf "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

noquotes = many (oneOf " !#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~") 

prose = many (oneOf " !\"#$%&'()*+,-./0123456789:;<=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")

-- Now, the useful grammar

rulelist = do
        result <- many1 rule'
        eof
        return result

rule' = do
     many (do {(many cwsp); cnl})
     result <- rule 
     many (do {(many cwsp); cnl})
     return result

rule = do
          name <- rulename
          def <- defined_as 
          content <- elements 
          cnl
          return (Rule name def content False)
    <?> "Rule"

comment = do
    many wsp
    char ';' 
    many (wsp <|> vchar)
    crlf    
  <?> "Comment"

defined_as = (do
    spaces
    def <- (try (do {string "=/"; return Incrementation})) <|> 
     (do {string "="; return Definition})  
    spaces
    return def)
  <?> "Definition operator"

elements = do {result <- alternation; spaces; return result}

alternation :: GenParser Char st ParsedGrammar
alternation = do 
        theHead <- concatenation 
        theTail <- many (do {spaces; char '/' ; spaces; 
                                   result <- concatenation; return result})
        if length(theTail) == 0 then
           return theHead
         else
           return (Choice (theHead : theTail))

concatenation :: GenParser Char st ParsedGrammar
concatenation = do
        theHead <- repetition
        theTail <- many (do {spaces; result <- repetition; return result})
        if length(theTail) == 0 then
           return theHead
         else
           return (Sequence (theHead : theTail))

repetition :: GenParser Char st ParsedGrammar
repetition = do 
          nbOccurrencesMaybe <- facultative (repeat)
          e <- element
          spaces 
          if isNothing nbOccurrencesMaybe then 
            return e
           else
            let nbOccurrences = fromJust nbOccurrencesMaybe in
            return (Repeat (fst nbOccurrences) (snd nbOccurrences) e)

element :: GenParser Char st ParsedGrammar
element = do {result <- rulename; return (RuleName result)} <|>
          group <|>
          option <|>
          charVal <|> 
          numVal <|>
          proseVal

group = do
   char '('
   spaces
   result <- alternation
   spaces
   char ')'
   return result
  <?> "Group"

option = do
   char '['
   spaces
   result <- alternation
   spaces
   char ']'
   return (Repeat 0 1 result)
  <?> "Option"

valFrom :: [Char] -> Int -> Int
valFrom v defaultVal = 
         if length v == 0 then
            defaultVal
          else
            (read v)::Int

repeat = do 
           (try (do
              atLeast <- many digit
              char '*'
              atMost <- many digit
              return (valFrom atLeast 0, valFrom atMost infinity)))
           <|> do
              num <- many1 digit
              let value = (read num)::Int 
              return (value, value)
   <?> "Repetition"

rulename = do
      start <- letter 
      rest <- (many (alphaNum <|> digit <|> char '-')) 
      return (start : rest)
   <?> "Rule name"

charVal = do {dquote; result <- noquotes; dquote; return (CI_Constant result)} <?> "Quoted string"

numVal = do
    char '%'
    value <- binVal <|> decVal <|> hexVal
    return value
   <?> "Numeric value"

binVal = do
    char 'b' <|> char 'B'
    value <- many1 (oneOf "01") -- TODO: the real rule is more complicated
    return (ConstantCode ((read value)::Int)) -- TODO: parse as binary

decVal = do
    char 'd' <|> char 'D'
    lowerS <- many1 digit -- TODO: the real rule is more complicated
    -- TODO: check the syntax? readDec returns what it could not parse
    -- case readDec x of { [(_, str)] | str /= "" -> error ...; ... }
    let lower = fst (head (Numeric.readDec lowerS))
    upperSMaybe <- facultative (do 
               char '-'
               result <- many1 digit
               return result)
    if isNothing upperSMaybe then
       return (ConstantCode lower)
     else do
       let upper = fst (head (Numeric.readDec (fromJust upperSMaybe)))
       return (Choice (map ConstantCode (enumFromTo lower upper)))
   
hexVal = do
    char 'x' <|> char 'X'
    lowerS <- many1 hexDigit -- TODO: the real rule is more complicated
    -- TODO: check the syntax? readHex returns what it could not parse
    -- case readHex x of { [(_, str)] | str /= "" -> error ...; ... }
    let lower = fst (head (Numeric.readHex lowerS))
    upperSMaybe <- facultative (do 
               char '-'
               result <- many1 hexDigit
               return result)
    if isNothing upperSMaybe then
       return (ConstantCode lower)
     else do
       let upper = fst (head (Numeric.readHex (fromJust upperSMaybe)))
       return (Choice (map ConstantCode (enumFromTo lower upper)))

-- Because proseVal is typically used for free-form definitions of the
-- rule, it is not really useful to support it.  RFC 3986, for
-- instance, use "0<pchar>" where it should use "<pchar>". RFC 4234
-- provides little guidance here so we assume that the proseVal is a
-- rule name (most of the times, it is not tree, it is free-form text,
-- like a comment).
proseVal = do
   char '<'
   value <- prose
   char '>'
   return (RuleName value)
  <?> "Prose value"

-- End of RFC 4234 grammar constructs

definedRules :: ABNF -> [String]
definedRules g = map ((map Char.toLower) . rule'name) 
                     (filter (\r -> rule'def r == Definition) g)

usedRules :: ABNF -> [String]
usedRules g = List.nub (concat (map usedRules' (map rule'content g)))

usedRules' :: ParsedGrammar -> [String]
usedRules' (Sequence gs) = concat (map usedRules' gs)
usedRules' (Choice gs) = concat (map usedRules' gs)
usedRules' (Repeat _ _ r) = usedRules' r
usedRules' (RuleName n) = [n]
usedRules' _ = []

occurrences :: Eq a => a -> [a] -> Int
occurrences r g = sum (map (\r2 -> if r == r2 then 1 else 0) g)

multiplyDefined :: [String] -> String -> Bool
multiplyDefined g n = (occurrences n g) > 1

repeatedRules :: ABNF -> [String]
repeatedRules g =
    let defined = definedRules g in
    List.nub (filter (multiplyDefined defined) defined)

undefinedRules :: ABNF -> [String]
undefinedRules g =
   let defined = definedRules g in
   filter (\rulename -> notElem (map Char.toLower rulename) defined) (usedRules g)

mergeIncrementalAlternatives' :: Rule -> Rule -> Rule
mergeIncrementalAlternatives' r1 r2 =
   Rule  (rule'name r1)
         Definition 
         (Choice [rule'content r1, rule'content r2]) 
         False

createRule :: ABNF -> String -> Rule
createRule g n = 
   let rule = getRule g n in
   let incrRules = getIncrRules g n in
   if length incrRules == 0 then
       rule
   else
       foldl mergeIncrementalAlternatives' rule incrRules

mergeIncrementalAlternatives :: ABNF -> ABNF
mergeIncrementalAlternatives g = 
    map (createRule g) (definedRules g)

-- parse' does *not* test the produced grammar
parse' :: String -> ABNF
parse' input = case (Parsec.parse rulelist "" input) of
            Left err -> error ("parse error at " ++ (show err))
            Right g -> predefinedRules ++ g

parse :: String -> ABNF 
parse input = 
   let parsed = parse' input in 
   let undefinedNum = length (undefinedRules parsed) in
   if undefinedNum > 0 then
       error ((show undefinedNum) ++ " rules are undefined: " ++ 
                                      (show (undefinedRules parsed)))
   else
       let mergedParsed = mergeIncrementalAlternatives parsed in
       let repeated = repeatedRules mergedParsed in
          if length(repeated) > 0 then
              error ("Rules are multiply defined" ++ (show repeated))
            else
               -- TODO: more semantic checks
               mergedParsed

getRule :: ABNF -> String -> Rule
getRule abnf rulename =
    let result = filter (\r -> map Char.toLower (rule'name r) == 
                               map Char.toLower rulename &&
                               rule'def r == Definition) abnf in
    -- if length(result) > 1 it means the ABNF is corrupted
    if length(result) == 0 then
        error ("No such rule " ++ rulename)
    else
        head result 

getIncrRules :: ABNF -> String -> [Rule]
getIncrRules abnf rulename =
    let result = filter (\r -> map Char.toLower (rule'name r) == 
                               map Char.toLower rulename &&
                               rule'def r == Incrementation) abnf in
    result

resolveRulesIn :: ABNF -> ParsedGrammar -> Types.Production
resolveRulesIn abnf (Sequence gs) = Types.Production "Unnamed Sequence" (Types.Sequence (
                                            map (resolveRulesIn abnf) gs)) False
resolveRulesIn abnf (Choice gs) = Types.Production "Unnamed Choice" (Types.Choice (
                                            map (resolveRulesIn abnf) gs)) False
resolveRulesIn abnf (Repeat start stop g) = Types.Production ("Unnamed Repeat " ++ (show start) ++ " " ++ (show stop))
                             (Types.Repeat start stop (resolveRulesIn abnf g)) False
resolveRulesIn abnf (Constant c) = Types.mkConstant c
resolveRulesIn abnf (CI_Constant c) = Types.mkCI_Constant c
resolveRulesIn abnf (ConstantCode i) = Types.mkConstant [(Char.chr i)]
resolveRulesIn abnf (RuleName r) = resolveRules abnf r

resolveRules :: ABNF -> String -> Types.Production
resolveRules abnf rulename =
    let rule = getRule abnf rulename in
    resolveRules' abnf (rulename, rule'def rule, rule'content rule)
    
resolveRules' :: ABNF -> (String, RuleDefinition, ParsedGrammar) -> Types.Production
resolveRules' abnf (n, _, Sequence gs) = 
      let definition = Types.Sequence (map (resolveRulesIn abnf) gs) in
              Types.Production n definition 
                                (Types.onlyTerminalAtDepth Types.searchTerminals definition)
resolveRules' abnf (n, _, Choice gs) = 
      let definition = Types.Choice (map (resolveRulesIn abnf) gs) in
                Types.Production n definition
                                 (Types.onlyTerminalAtDepth Types.searchTerminals definition)
resolveRules' abnf (n, _, Repeat start stop g) = 
      let definition = Types.Repeat start stop (resolveRulesIn abnf g) in
               Types.Production n definition
                                (Types.onlyTerminalAtDepth Types.searchTerminals definition)
resolveRules' abnf (n, _, Constant c) = Types.Production n (Types.Constant c) True
resolveRules' abnf (n, _, CI_Constant c) = Types.Production n (Types.CI_Constant c) True
resolveRules' abnf (n, _, RuleName r) = resolveRules abnf r 
