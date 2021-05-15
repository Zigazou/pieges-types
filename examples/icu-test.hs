{-# LANGUAGE OverloadedStrings #-}
module Main where

import Prelude hiding (putStr, putStrLn, compare)

import Data.Text.ICU
import Data.Text.ICU.Normalize
import Data.Text.ICU.Char
import Data.Text.ICU.Translit
import Data.List (sortBy)
import qualified Data.Text as T
import qualified Data.Text.Lazy as L
import qualified Data.Text.Lazy.Builder as LB
import qualified Data.Text.Buildable as B
import Data.Text.Lazy.IO (putStr, putStrLn)
import Control.Monad (forM_)
import Data.Text.Format
import Data.List (intersperse)

normModeDescription :: NormalizationMode -> T.Text
normModeDescription None = "No decomposition/composition"
normModeDescription NFD = "Canon. decomposition"
normModeDescription NFKD = "Compat. decomposition"
normModeDescription NFC = "Canon. decomposition + canon. composition"
normModeDescription NFKC = "Compat. decomposition + canon. composition"
normModeDescription FCD = "Fast C/D form"

comparisonDescription :: Ordering -> T.Text
comparisonDescription LT = "<"
comparisonDescription GT = ">"
comparisonDescription EQ = "="

normalizationModes :: [ NormalizationMode ]
normalizationModes = [ NFD, NFKD, NFC, NFKC, FCD ]

prettyList :: [ T.Text ] -> T.Text
prettyList [] = "[]"
prettyList strings =
    T.concat [ "[\"", T.concat (intersperse "\",\"" strings), "\"]" ]

exampleNormalizationStrings :: [ T.Text ]
exampleNormalizationStrings =
    [ "⁇…"
    , "Frédéric"
    , "Fre\769de\769ric"
    , "ＦＲＥ\769ＤＥ\769ＲＩＣ"
    , "Eﬃcace"
    , "Efficace"
    , "Eﬃcace"
    , "Œuf"
    , "OEuf"
    , "Foreﬆier"
    ]

describeNormalizations :: [ NormalizationMode ] -> T.Text -> IO ()
describeNormalizations normModes string = do
    putStr $ format "■ {} {}:\n"
        [ LB.fromText string
        , LB.fromString (show string)
        ]

    forM_ normModes $ \normMode -> do
        let normalized = normalize normMode string
        putStr $
            format "    {} {}: {} {}\n"
                [ right 4 ' ' (LB.fromString $ show normMode)
                , right 42 ' ' (LB.fromText $ normModeDescription normMode)
                , LB.fromText normalized
                , LB.fromString (show normalized)
                ]

exampleComparisonStrings :: [ (T.Text, T.Text) ]
exampleComparisonStrings =
    [ ("Frédéric", "Fre\769de\769ric")
    , ("ＦＲＥ\769ＤＥ\769ＲＩＣ", "FRÉDÉRIC")
    , ("Eﬃcace", "Efficace")
    , ("Eﬃcace", "Efficaces")
    , ("Efficace", "Efficaces")
    , ("Œuf", "OEuf")
    , ("Foreﬆier", "Forestier")
    , ("⁇…", "??...")
    ]

describeComparison :: (T.Text, T.Text) -> IO ()
describeComparison (stringA, stringB) = do
    let stringAn = normalize NFKD stringA
        stringBn = normalize NFKD stringB
        comparison = compare [] stringAn stringBn

    putStr $ format "■ {} {} {} ({} {} {})\n"
        [ LB.fromText stringA
        , LB.fromText (comparisonDescription comparison)
        , LB.fromText stringB
        , LB.fromString (show stringA)
        , LB.fromText (comparisonDescription comparison)
        , LB.fromString (show stringB)
        ]

exampleCollationStrings :: [ [T.Text] ]
exampleCollationStrings =
    [ [ "Frédéric"
      , "Fre\769de\769ric"
      ]
    , [ "Eﬃcace"
      , "Efficace"
      , "Efficaces"
      , "Eﬃcaces"
      ]
    , [ "Œuf"
      , "OEuf"
      , "Œufs"
      , "OEufs"
      ]
    , [ "Foreﬆier"
      , "Forestier"
      , "Foreﬆiers"
      , "Forestiers"
      ]
    , [ "aaaa"
      , "ｃｏｔｅ"
      , "cote"
      , "côte"
      , "coté"
      , "côté"
      , "cote\769"
      , "côte\769"
      , "zzzz"
      ]
    , [ "ﬆ"
      , "ss"
      , "su"
      ]
    , [ "dz"
      , "dza"
      , "ǳ"
      , "dzb"
      , "ʣ"
      , "dzc"
      , "ea"
      ]
    , [ "⁇…"
      , "??..."
      , "⁇..."
      , "??…"
      ]
    , [ "φιλοσοφία"
      , "ありがとうございます"
      , "appartement"
      , "astronomie"
      , "philanthrope"
      , "philosophie"
      ]
    ]

describeCollation :: [T.Text] -> IO ()
describeCollation strings = do
    let frenchCollate = collate (collator (Locale "fr_FR"))
        sortedStrings = sortBy frenchCollate strings

    putStr $ format "■ {}\n    {}\n    {}\n"
        [ LB.fromText $ prettyList strings
        , LB.fromText $ prettyList sortedStrings
        , LB.fromString $ show sortedStrings
        ]
 
exampleUpperStrings :: [ T.Text ]
exampleUpperStrings =
    [ "Frédéric"
    , "Fre\769de\769ric"
    , "Eﬃcace"
    , "bœuf"
    , "Foreﬆier"
    ]

describeUpper :: T.Text -> IO ()
describeUpper string = do
    let frenchToUpper =  toUpper (Locale "fr_FR")

    putStr $ format "■ {} → {}\n"
        [ LB.fromText $ string
        , LB.fromText $ frenchToUpper string
        ]
 
exampleTranslitStrings :: [ T.Text ]
exampleTranslitStrings =
    [ "Frédéric"
    , "Fre\769de\769ric"
    , "Fre\769\769de\769\769ric"
    , "Eﬃcace"
    , "bœuf"
    , "Foreﬆier"
    , "こんにちは"
    , "φιλοσοφία"
    ]

describeTranslit :: T.Text -> IO ()
describeTranslit string = do
    let customTranslit =  transliterate
            (trans "Greek-Latin; Hiragana-Latin; Katakana-Latin; Latin-ASCII")

    putStr $ format "■ {} → {}\n"
        [ LB.fromText $ string
        , LB.fromText $ customTranslit string
        ]
 
describeSection :: T.Text -> IO () -> IO ()
describeSection title run = do
    putStr $ format "{}\n{}\n{}\n"
        [ center 79 '*' ("" :: T.Text)
        , center 79 '*' $ T.concat [ " ", title, " "]
        , center 79 '*' ("" :: T.Text)
        ]

    run

    putStrLn ""

    where
        center :: B.Buildable a => Int -> Char -> a -> LB.Builder
        center k c = LB.fromLazyText
                   . L.center (fromIntegral k) c
                   . LB.toLazyText
                   . B.build

main :: IO ()
main = do
    describeSection "NORMALIZATIONS"
        $ mapM_ (describeNormalizations normalizationModes)
                exampleNormalizationStrings 

    describeSection "COMPARISONS"
        $ mapM_ describeComparison exampleComparisonStrings 

    describeSection "COLLATIONS"
        $ mapM_ describeCollation exampleCollationStrings 

    describeSection "TOUPPER"
        $ mapM_ describeUpper exampleUpperStrings 

    describeSection "TRANSLITERATION"
        $ mapM_ describeTranslit exampleTranslitStrings 

