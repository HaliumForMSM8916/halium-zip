#!/usr/bin/env/bash

echo "CLEANUP AROMA INSTALLER"
echo "======================="
echo "* Creating directories"
mkdir obj
mkdir out
cd "obj"
echo "* Cleanup objects"
rm -rf *.*
cd ..
echo "* Cleanup binaries"
cd out
rm -rf *
cd ../assets/META-INF/com/google/android/   
rm -rf update-binary
echo "Done"