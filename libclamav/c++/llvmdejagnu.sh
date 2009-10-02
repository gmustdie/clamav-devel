#!/bin/bash
mkdir -p llvm/Release/bin
mkdir -p llvm/Debug/bin
cp lli llc llvm-as not count FileCheck tblgen llvm/Release/bin/
cp lli llc llvm-as not count FileCheck tblgen llvm/Debug/bin/

exec $GMAKE -C llvm check-lit TESTSUITE="CodeGen ExecutionEngine Integer TableGen Verifier"
