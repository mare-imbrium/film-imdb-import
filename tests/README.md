# HOW TO GENERATE AND TEST

First put command to be run in a file named tests-01.sh or tests-02.sh
etc.

Execute this file by passing the name to ./genscript.sh tests-01.sh
A script file by same name will be created which contains command and
expected output.

Edit this file, in case some command is giving wrong output at present
and should give a different output when working correctly.

Now run the script file by passing it to ./runscript.sh as follows:
  ./runscript.sh tests-01.script.
This will execute each command and tally the output with that in the
script file.

We need to working on calling all test files once we have multiple.

