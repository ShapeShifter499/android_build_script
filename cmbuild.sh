#!/bin/sh
THREADS=6
VERSION=cm-13.0
echo "#########################"
echo "   Reversing Patches     "
echo "#########################"
for file in sprd-patches/sprd/$VERSION/*.patch ; do
	patch -R --force --quiet -p1  < $file
	if [ $? != "0" ]; then
		echo "Failed to reverse $file"
	else
		echo "Successfully reversed $file"
	fi
done
echo "#########################"
echo "     Syncing repo        "
echo "#########################"
repo sync --force-sync -j$THREADS
echo "#########################"
echo "    Applying patches"
echo "#########################"
for file in sprd-patches/sprd/$VERSION/*.patch ; do
        patch --force --quiet -p1  < $file
        if [ $? != "0" ]; then
		echo "Failed to apply needed patch, try manually patching $file"
		echo "Reversing failed patch"
		patch -R --force --quiet -p1  < $file
		exit
        else
                echo "Successfully applied $file"
        fi
done
echo "#########################"
echo "    Executing source"
echo "#########################"
source build/envsetup.sh
echo "#########################"
echo "  Executing breakfast"
echo "#########################"
breakfast kanas3gnfcxx
echo "#########################" 
echo "    Executing make"
echo "#########################"
make clean -j$THREADS
make bacon -j$THREADS
if [ "$?" = "0" ]; then
	echo "#########################"
        echo "     Build Success"
	echo "#########################"

else
	echo "#########################"
	echo "     Build Failed"
	echo "#########################"
fi
