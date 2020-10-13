#!/bin/bash

dirs=`find . -maxdepth 1 -type d `
testRoot=`pwd`
cd ../
projectRoot=`pwd`
cd $testRoot

for dir in $dirs;
do
    if test $dir = '.'; then
        continue
    fi
    echo $dir
    cd $dir
    ./run_test.sh $projectRoot
    cd $testRoot
done