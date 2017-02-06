#!/bin/sh
REPO_SYNC=true
THREADS=15
VERSION=cm-13.0
if [ "$@" = "--no-sync" ]; then
REPO_SYNC=false
fi
crashcheck () {
if [ "$?" = "0" ]; then
        echo "#########################"
        echo "    $@ Success"
        echo "#########################"

else
        echo "#########################"
        echo "    $@ Failed"
        echo "#########################"
        exit 1
fi
}
if [ "$REPO_SYNC" = "true" ]; then
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
repo sync --force-sync 
if [ "$?" = "0" ]; then
        echo "#########################"
        echo "     Repo Success"
        echo "#########################"

else
        echo "#########################"
        echo "     Repo Failed"
        echo "#########################"
	repo forall -vc "git reset --hard"
	repo sync --force-sync
	crashcheck Repo         
fi
echo "#########################"
echo "    Applying patches"
echo "#########################"
for file in sprd-patches/sprd/$VERSION/*.patch ; do
        patch --force --quiet -p1  < $file
        if [ $? != "0" ]; then
                echo "Failed to apply needed patch, try manually patching $file"
                echo "Reversing failed patch"
                patch -R --force --quiet -p1  < $file
                exit 1
        else
                echo "Successfully applied $file"
        fi
done
fi
echo "#########################"
echo "    Executing source"
echo "#########################"
source build/envsetup.sh
crashcheck Source
echo "#########################"
echo "  Executing breakfast"
echo "#########################"
breakfast kanas3gnfcxx
crashcheck Breakfast
echo "#########################"
echo "    Executing make"
echo "#########################"
make clean -j$THREADS
crashcheck Clean
make bacon -j$THREADS
crashcheck Build
