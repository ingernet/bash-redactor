#!/bin/bash
# I generate some files to work with based off of sample.log

counter=1
while [ $counter -le 10 ]; do
    cp sample.log ziplogs/${counter}.log &&
    gzip ziplogs/${counter}.log
    ((counter++))
done

echo "sample files generated in ziplogs/";
