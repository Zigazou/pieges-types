import qualified Parse
import qualified Types
import qualified Generator

import qualified System.Environment as Environment
import qualified System.IO as IO
import qualified System.Console.GetOpt as GetOpt

testIt verbose start filename = do
    content <- IO.readFile filename
    let result = Parse.parse content
    if verbose then
       putStrLn (Parse.toString result)
     else
       putStr ""
    let startProduction = Parse.resolveRules result start
    if verbose then
       putStrLn (Types.toString startProduction)
     else
       putStr ""
    made <- Generator.generate (startProduction) 1
    putStrLn made
          
foreach :: (Monad m) => [a1] -> (a1 -> m a) -> m [a]
foreach [] func = do
   return []
foreach x func = do 
   newHead <- func (head x) 
   newTail <- foreach (tail x) func
   return (newHead : newTail)

-- Option processing

header = "Usage: abnf-generate [OPTION...] files.abnf..."

data Flag 
    = Verbose | Start String 
       deriving Show

options :: [GetOpt.OptDescr Flag]
options =
     [ GetOpt.Option ['v']     ["verbose"] (GetOpt.NoArg Verbose)       "more chatty output"
     , GetOpt.Option ['s']     ["start"]  (GetOpt.ReqArg Start "RULE")  "name of the starting production"
     ]
  
data OptionStore = ProgramOptions {option'verbose::Bool, option'start::String}

-- Defaults
emptyOptionStore :: OptionStore
emptyOptionStore = 
    ProgramOptions {option'verbose = False, option'start = "start" }

processFlags :: [Flag] -> OptionStore
processFlags []             = emptyOptionStore
processFlags (first : rest) =
  case first of
  Verbose        -> restOpts { option'verbose = True }
  Start f        -> restOpts { option'start = f }
  where restOpts = processFlags rest

programOpts :: [String] -> IO ([Flag], [String])
programOpts argv = 
       case GetOpt.getOpt GetOpt.Permute options argv of
          (o,n,[]  ) -> return(o,n)
          (_,_,errs) -> error (concat errs ++ GetOpt.usageInfo header options)

getOptionStore :: [Flag] -> OptionStore
getOptionStore f = processFlags f

main = do
  myargs <- Environment.getArgs
  (results, nonoptargs) <- programOpts myargs
  let opts = getOptionStore results
  let start = option'start opts
  let verbose = option'verbose opts
  foreach nonoptargs (testIt verbose start)
