# bash-redactor

A rudimentary log scrubber. Pass in a list of gzipped log files, or the name of a directory, and it:
+ copies the files to a temp working directory
+ retains the originals' metadata (timestamps, owner, etc) on the copies
+ redacts the specified fields 
+ makes a note of the redacted fields in an audit log

## Getting Started/Demo

I've provided some sample logs so you can test this code out. To get started:
1. Clone the master branch of this repo
1. From your local repo folder, run: `./mksamples.bash`
1. Test out using the script with a source directory with this command: `sudo ./redactor.bash -d ziplogs`
1. Test out using the script with a list of files with this command: `sudo ./redactor.bash -f "a.log.gz b.log.gz"`  

### Prerequisites

This is optimized for Linux, but will run on OS X. (The `master-sedbuilder` branch will have problems with maintaining the copied files` timestamps because I haven't gotten around to getting OS X to `touch` them correctly.)

This is a native bash script. All you need is bash. And love. Bash and love are all you need. And this paddle ball set.

### Installing

Installation is simple - just `git clone https://github.com/ingernet/bash-redactor.git` into your projects directory.


## Authors

* **Inger Klekacz** - [ingernet](https://github.com/ingernet)


