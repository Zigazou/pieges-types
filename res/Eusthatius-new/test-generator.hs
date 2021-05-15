import Types
import Generator

start = Production "start" (Sequence [Production "ident" (Repeat 1 6 letter) True, spaces, 
                     Production "main" (Choice [mkConstant "toto", 
                                                mkConstant "tata", 
                         Production "3useless" (Sequence [mkConstant "truc", 
                              mkCI_Constant "machin", 
                              mkCI_Constant "chose"]) True]) False, spaces, 
                         Production "2digits" (Repeat 2 2 digit) True, spaces1,
                            mkConstant ";"]) False

foo = [Production "empty" (Choice []) True, mkConstant "toto", mkConstant "tata", start, foobar]

foobar = Production "foobar" (Choice foo) False

recursiveProduction = Sequence [Production "question" (Choice [Production "recursiveInt" recursiveProduction False, digit]) False, letter]
recursiveGrammar = Production "recursive" (Choice [Production "recursiveInt" recursiveProduction False, digit]) False

main = do
  made <- generate recursiveGrammar 1
  putStrLn made
  