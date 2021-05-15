module Generator where 

import qualified System.Random as Random
import qualified Data.Char as Char
import Types

-- Remember that recursive or mutually recursive grammars are legal.
maxSoftDepth = 20 -- Arbitrary. 
maxHardDepth = 100 -- Arbitrary. 

flipCoin :: IO Bool
flipCoin  = Random.getStdRandom (Random.random)

rollDice :: Int -> IO Int
rollDice n = Random.getStdRandom (Random.randomR (1,n))

rollDice' :: Int -> Int -> IO Int
rollDice' m n = Random.getStdRandom (Random.randomR (m,n))

foreach :: (Monad m) => [a1] -> (a1 -> m a) -> m [a]
foreach [] func = do
   return []
foreach x func = do 
   newHead <- func (head x) 
   newTail <- foreach (tail x) func
   return (newHead : newTail)

scrambleCase' c = do
  lower <- flipCoin
  if lower then
     return (Char.toLower c)
   else
     return (Char.toUpper c)

scrambleCase s = 
  foreach s scrambleCase' 

onlySafe :: Production -> Bool
onlySafe p = production'safe p

getSelection :: [Production] -> Int -> IO Production
getSelection gs d =
  if d >= maxHardDepth then
      error ("INTERNAL ERROR - TOO DEEP: " ++ (show d) ++ " levels, production list " ++ (show gs))
   else 
     if d >= maxSoftDepth then do
          let safe_gs = filter onlySafe gs
          if length safe_gs == 0 then do -- No safe productions, back to the normal rule
              -- putStrLn ("DEBUG Warning: no safe productions and we are already at level " ++ (show d) ++ ", production list " ++ (show (map production'name gs)))
              choice <- rollDice (length (gs))
              return (gs !! (choice-1))
           else do
              choice <- rollDice (length (safe_gs))
              return ((safe_gs !! (choice-1)))
      else do
          choice <- rollDice (length (gs))
          return (gs !! (choice-1))

incrementDepth gs d = 
        if length (tail gs) == 1 then 
           d + 1
        else 
           d

-- The second parameter is the depth level. When it reaches maxHardDepth, we stop
generate :: Production -> Int -> IO String
generate (Production n g _) d = do
  -- putStrLn ("DEBUG Evaluating production " ++ n ++ " at level " ++ (show d))
  generate' g (d+1)

generate' :: Grammar -> Int -> IO String

generate' (Constant s) _ = do
  return s

generate' (CI_Constant s) _ = do
  result <- scrambleCase s
  return result

generate' (Choice []) _ = do
  return ""

generate' (Choice gs) d = do
  selection <- getSelection gs d
  generate selection (d+1) -- TODO: IWBN to increase the depth faster if we
                                        -- already went there (idea by Kim Minh Kaplan)

generate' (Sequence []) _ = do
  return ""

generate' (Sequence gs) d = do
     if d >= maxHardDepth then
          error ("INTERNAL ERROR - TOO DEEP: \"Sequence\" at level " ++ (show d))
      else do
        newHead <- generate (head gs) (d+1)
        newTail <- generate' (Sequence (tail gs)) (incrementDepth gs d)
        return (newHead ++ newTail)

generate' (Repeat 0 0 _) _ = do
  return ""

generate' (Repeat m n g) d = 
  if m > n then
    error "Repeat's parameters must be in ascending order (the second being the largest)"
   else do
       if d >= maxHardDepth then
          error ("INTERNAL ERROR - TOO DEEP: \"Repeat\" at level " ++ (show d))
        else do
          choice <- rollDice' m n 
          generate' (Sequence (replicate choice g)) (d+1)

