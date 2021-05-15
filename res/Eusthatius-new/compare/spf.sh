#!/bin/sh

for i in `seq 1 100`; do
   record=`./abnf-generate --start record tests/spf.abnf`
   echo Test $i... \($record\)
   # TODO: spfquery does not check the syntax :-(
   result=`spfquery --helo DOES.NOT.MATTER --ip 1.2.3.4 --override NOT.MATTER="$record"`
   if [ ! -z "$result" ]; then
       # Actual error
       echo $result
       exit 1
   fi
   # Haskell random generator does not have enough resolution :-(
   sleep 0.8 # A decimal requires GNU sleep?
done
