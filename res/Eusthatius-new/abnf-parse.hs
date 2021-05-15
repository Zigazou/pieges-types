import qualified Types
import qualified Parse
import qualified System.Environment as Environment
import qualified System.IO as IO

displayProduction :: Parse.ABNF -> Parse.Rule -> IO ()
displayProduction abnf rulename = do
    let prod = Parse.resolveRules abnf (Parse.rule'name rulename)
    putStrLn ((Types.production'name prod) ++ ": " ++ (Types.safeToString (Types.production'safe prod)))

testIt filename = do
    content <- IO.readFile filename
    let result = Parse.parse' content
    -- TODO: printing some ABNF can be impossible (they can be recursive). 
    -- toString does not protect us against that.
    putStrLn (Parse.toString result)
    let result = Parse.parse content
    putStrLn ""
    putStrLn "After rules resolution:"
    putStrLn (Parse.toString result)
    putStrLn ""
    putStrLn "All the rules:"
    foreach result (displayProduction result)

foreach :: (Monad m) => [a1] -> (a1 -> m a) -> m [a]
foreach [] func = do
   return []
foreach x func = do 
   newHead <- func (head x) 
   newTail <- foreach (tail x) func
   return (newHead : newTail)

main = do
   args <- Environment.getArgs
   foreach args testIt  
