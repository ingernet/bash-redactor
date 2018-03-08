#!/bin/bash

# KNOWN ISSUES:
# Not recursive. Only goes down one level when passed a directory name. So logs/2018/january won't be parsed.


## SETUP
rightnow=$(date "+%Y%m%d%H%M%S");
auditlogfile="audit_${rightnow}.csv";
working_dir="/tmp/redactor_${rightnow}";


## USAGE
usage() { 
    echo "Usage: " 1>&2;
    echo "Specify a few source files with: $0 -f 'file1.log.gz [ file2.log.gz file3.log.gz]'" 1>&2;
    echo "Specify an entire source directory with: $0 -d directory_name" 1>&2;
    echo "";
}

create_working_dir() {
    echo "Creating a temporary working directory." 1>&2;
    # create a subdir of /tmp
    mkdir -p ${working_dir};
}

create_audit_log() {
    echo "Creating audit log." 1>&2;
    printf "FILENAME,LINES_PROCESSED,FIELDS_REDACTED\n" > ${auditlogfile};
}

update_audit_log(){
    printf "${1##*/},${2},${3}\n" >> ${auditlogfile};
}

ack() {
    echo "...done. " 1>&2;
    echo "   You can access the redacted logs here: ${working_dir}" 1>&2;
    echo "   You can view the audit log of this process here: ${auditlogfile}" 1>&2;
}

redact_files() {
    echo "Scrubbing copied files." 1>&2;
    for f in ${working_dir}/*; do
        cp "$f" "$f~" &&
        gzip -cd "$f~" | sed '/ CC="[^"]*"/ s// CC="REDACTED"/g' | sed '/ SSN="[^"]*"/ s// SSN="REDACTED"/g' | gzip >"$f"
        rm "$f~";
        redactedcount=`zgrep -o REDACTED "${f}" | wc -l`
        update_audit_log "${f}" `gunzip -c  "$f" | wc -l` $redactedcount;
    done
    ack;
}

redact_directory() {
    # make a copy of your originals
    echo "Copying files from ${1} to the working directory"
    cp -p ${1}/*.gz ${working_dir}/
    redact_files;
}

# RUN



# accept either a 1+ list of files with -f, or a directory with -d
while getopts "f:d:" OPTION
do
    case $OPTION in
        f)
            srcfiles=${OPTARG};
            [[ -n ${srcfiles} ]] || usage;
            echo "running redactor on: ${srcfiles}";

            # Set up the audit log and the temporary working directory
            create_audit_log;
            create_working_dir;
            
            for x in ${srcfiles}; do
                if [[ "${x}" = *".gz" ]] && [[  "${x}" != *"tar.gz" ]]; then
                    cp -p ${x} ${working_dir}
                else
                    echo "skipping file ${x} - untarred, gzipped files only, please." 1>&2;
                fi
            done
            redact_files;
            ;;
        d)
            srcdir=${OPTARG}
            [[ -n "$srcdir" ]] || usage;
            redact_directory ${srcdir};
            # exit;
            ;;
        \?)
            usage;
            exit 1;
            ;;
    esac
done
