#!/bin/bash

# KNOWN ISSUES:
# Not recursive. Only goes down one level when passed a directory name. So logs/2018/january won't be parsed.

# requirements:
# 1. accept one or more text log.gz files
# 2. for each file, produce a redacted copy of the file that has been gzipped - meaning...logcopy.gz? or just logcopy.log?
# 3. create an audit log with the following info: 
# 	- name of each file that was processed
# 	- count of the number of lines in that file
# 	- count of total number of lines redacted from the log file
# 	- anything else that is pertinent
# 	- MUST NOT contain info from the redacted lines
# 4. do not alter logs in-place
# 5. redact all log lines as highlighted data indicates
# 6. code comments explaining usage and internal operations
# 7. must be fast and burly to accommodate giant log files
# 8. preserve as much metadata in redacted copies as possible

## SETUP

## USAGE
usage() { 
    echo "Usage: " 1>&2;
    echo "$0 -f file1 [file2 file3 etc.] || $0 -d directory_name" 1>&2;
    echo ""; exit 0;
}

# To add an additional field to redact, add it to the array below.
redacted_fields=('CC' 'SSN')


# Loop through list of redacted_fields and do a search and replace for each field's contents.
do_redact() {
    echo "Redacting $1..." 1>&2
    for i in "${redacted_fields[@]}"
    do
	    grep $i ${1}
    done
}

duplicate_file() {
    cp -p ${1} ${working_dir}
}

duplicate_dir() {
    cp -pi ${1} ${working_dir}
}

redact_files() {
    # copy your logs directory to a subdir of /tmp
    echo "creating copy of files";
    working_dir="/tmp/redactr_$(date "+%Y%m%d%H%M%S")";
    mkdir -p ${working_dir};

    # make a copy of your originals
    # TODO REPLACE ziplogs with stin
    sudo cp -p ziplogs/*.gz ${working_dir}/;

    echo "scrubbing copied files";
    for f in ${working_dir}/*; do
        cp "$f" "$f~" &&
        gzip -cd "$f~" | sed '/CC="[^"]*"/ s//CC="REDACTED"/g' | sed '/SSN="[^"]*"/ s//SSN="REDACTED"/g' | gzip >"$f"
        rm "$f~";
    done

    echo "done. go check out your files in: ${working_dir}";
}


# accept either a 1+ list of files with -f, or a directory, with -d
while getopts "fd:" OPTION
do
    case $OPTION in
        f)
            echo "You set flag -b"
            exit
            ;;
        d)
            echo "The value of -f is $OPTARG"
            MYOPTF=$OPTARG
            echo $MYOPTF
            exit
            ;;
        \?)
            usage
            exit
            ;;
    esac
done

redact_files;
