#!/bin/sh

for i in `seq 1 100`; do
   echo Test $i...
   tag=`./abnf-generate --start language-tag tests/langtag-simple.abnf`
   result=`../../LTRU/GaBuZoMeu/check-wf $tag`
   if [ "$result" != "$tag is well-formed" ]; then
       if [ "$result" == "$tag is NOT well-formed: semantic error" ]; then
          continue
       fi
       if [ "$result" == "$tag is NOT well-formed: (line 1, column 1): unexpected \"-\" expecting letter, \"x\", \"X\" or Grandfathered tag" ]; then
          # This is actually a bug in the ABNF, which defines grandfathered tags by a rule, not by 
          # a list
          continue
       fi
       # Actual error
       echo $result
       exit 1
   fi
   # Haskell random generator does not have enough resolution :-(
   sleep 0.8 # A decimal requires GNU sleep?
done
