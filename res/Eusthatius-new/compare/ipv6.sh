#!/bin/sh

for i in `seq 1 100`; do
   echo Test $i...
   #addr=`./abnf-generate -s ipv6address tests/ipv6-rfc3987.abnf`
   addr=`./abnf-generate -s ip-address-v6 tests/ipv6-rfc3632.abnf`
   result=`ping6 -c1 $addr 2>&1 | head -1`
   if [ "$result" == "unknown host" ]; then
       echo $addr ": " $result
       exit 1
   fi
   # Haskell random generator does not have enough resolution :-(
   sleep 0.8 # A decimal requires GNU sleep?
done
