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
# To add an additional field to redact, add it to the array below.
# TODO GET SEDBUILDER TO USE THIS.
scrubbed_fields=('CC' 'SSN')
rightnow=$(date "+%Y%m%d%H%M%S");
auditlogfile="audit_${rightnow}.csv";

## USAGE
usage() { 
    echo "Usage: " 1>&2;
    echo "Specify a few source files with: $0 -f 'file1.log.gz [file2.log.gz file3.log.gz etc.]'" 1>&2;
    echo "Specify an entire source directory with: $0 -d directory_name" 1>&2;
    echo "";
}

create_working_dir() {
    # create a subdir of /tmp
    working_dir="/tmp/redactr_${rightnow}";
    mkdir -p ${working_dir} &&
    echo "working directory created: ${working_dir}";
}

create_audit_log() {
    printf "FILENAME,LINES_PROCESSED,FIELDS_REDACTED\n" > ${auditlogfile};
}

update_audit_log(){
    printf "${1},${2},${3}\n" >> ${auditlogfile};
}

redact_files() {
    for f in ${working_dir}/*; do
        cp "$f" "$f~" &&
        gzip -cd "$f~" | sed '/ CC="[^"]*"/ s//CC="REDACTED"/g' | sed '/ SSN="[^"]*"/ s//SSN="REDACTED"/g' | gzip >"$f"
        rm "$f~";
    done
}

redact_directory() {
    # make a copy of your originals
    echo "creating copy of files from ${1}"
    cp -p ${1}/*.gz ${working_dir}/

    echo "scrubbing copied files";
    redact_files;

    echo "done. go check out your files in: ${working_dir}";
}

# accept either a 1+ list of files with -f, or a directory, with -d
while getopts ":f:d:" OPTION
do
    case $OPTION in
        f)
            srcfiles=${OPTARG};
            [[ -n ${srcfiles} ]] || usage;
            echo "running redactor on: ${srcfiles}";
            create_audit_log &&
            create_working_dir &&
            for x in ${srcfiles}; do
                cp -p ${x} ${working_dir}
            done
            redact_files;
            ;;
        d)
            srcdir=${OPTARG}
            [[ -n "$srcdir" ]] || usage;
            create_audit_log &&
            create_working_dir &&
            redact_directory ${srcdir};
            # exit;
            ;;
        \?)
            usage;
            exit 1;
            ;;
    esac
done
