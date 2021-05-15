#!/bin/sh

for i in `seq 1 100`; do
   echo Test $i...
   TMP=`mktemp`
   ./abnf-generate --start state-machine ../../Cosmogol/RFC/sm.abnf > $TMP
   result=`../../Cosmogol/Shadok/shadok $TMP | head -n 1`
   if [ ! -z "$result" ]; then
       if [ "$result" == "Semantic error in $TMP: State machine must be connected: Here is more information about the components of the graph:" ]; then
          continue
       fi
       # Yes, it requires GNU expr, I know. If someone knows a better solution...
       index=`expr index "$result" "Semantic error in $TMP: All variables must be declared:"`
       if [ $index == 1 ]; then
          continue
       fi
       # Actual error
       echo $result
       exit 1
   fi
   rm $TMP
   # Haskell random generator does not have enough resolution :-(
   sleep 0.8 # A decimal requires GNU sleep?
done
