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
    echo "Specify a few source files with: $0 -f file1 [file2 file3 etc.]" 1>&2;
    echo "Specify an entire source directory with: $0 -d directory_name" 1>&2;
    echo ""; exit 0;
}

redact_file() {
    $f = ${1}
    cp "$f" "$f~" &&
    gzip -cd "$f~" | sed '/CC="[^"]*"/ s//CC="REDACTED"/g' | sed '/SSN="[^"]*"/ s//SSN="REDACTED"/g' | gzip >"$f"
    rm "$f~";
}

redact_directory() {
    # create a subdir of /tmp
    working_dir="/tmp/redactr_$(date "+%Y%m%d%H%M%S")";
    mkdir -p ${working_dir};
    echo "working directory created: ${working_dir}" &&

    # make a copy of your originals
    echo "creating copy of files from ${1}"
    sudo cp -p ${1}/*.gz ${working_dir}/

    echo "scrubbing copied files";
    for f in ${working_dir}/*; do
        redact_file $
        # cp "$f" "$f~" &&
        # gzip -cd "$f~" | sed '/CC="[^"]*"/ s//CC="REDACTED"/g' | sed '/SSN="[^"]*"/ s//SSN="REDACTED"/g' | gzip >"$f"
        # rm "$f~";
    done

    echo "done. go check out your files in: ${working_dir}";
}

# accept either a 1+ list of files with -f, or a directory, with -d
while getopts "fd:" OPTION
do
    case $OPTION in
        f)
            echo "You set flag -f"
            # [[ -n "$gce_name" ]] || usage
            ;;
        d)
            srcdir=${OPTARG}
            [[ -n "$srcdir" ]] || usage;
            redact_directory ${srcdir};
            exit;
            ;;
        \?)
            usage
            ;;
    esac
done

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




# redact_files;
