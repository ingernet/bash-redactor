#!/bin/bash
# I generate some files to work with based off of sample.log

mkdir -p ziplogs;

counter=1
while [ $counter -le 10 ]; do
    cp sample.log ziplogs/${counter}.log &&
    gzip ziplogs/${counter}.log
    ((counter++))
done

echo "sample files generated in ziplogs/" 1>&2;
echo "use them by running: `sudo ./redactor.bash -d ziplogs`" 1>&2;
