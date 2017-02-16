#!/bin/bash
#
# LineageOS Builder.
# This script helps keep sources updated, patched, and then builds it.
#
#

# List of supported devices

DEVICE_SUPPORT="clark falcon x5"

usage () {
   cat << EOF

cmbuild.sh <device> <version>
Input must be lower case.

This script helps keep sources updated, patched, and then builds LineageOS.
EOF
   exit 1
}

function list_include_item {
  local list="$1"
  local item="$2"
  if [[ $list =~ (^|[[:space:]])"$item"($|[[:space:]]) ]] ; then
    # yes, list include item
    result=0
  else
    result=1
  fi
  return $result
}

if [ $# -ne 2 ]; then
   usage
fi

DEVICE=$1
VERSION=$2

if `list_include_item "$DEVICE_SUPPORT" "$1"`; then
  echo ""
else 
  echo "Device NOT supported"
  usage
fi

repoinitcheck () {
echo "============================="
echo "Make sure repo was downloaded"
echo "============================="

if [ "$(ls -A ~/lineageos/system/$VERSION )" ]; then
    echo "========================="
    echo " Source appears to exist"
    echo "  Continuing to build" 
    echo "  LineageOS $VERSION"
    echo "========================="
    cd ~/lineageos/system/$VERSION/ 
else
    echo "Seems the LineageOS $VERSION build directory is empty."
    echo "Please run 'repo init' first."
    exit 1
fi
}

reposync () {
echo "========================="
echo "     Syncing repo        "
echo "========================="
repo forall -c 'git reset --hard --quiet;git clean --force'
repo sync --force-sync 
if [ "$?" = "0" ]; then
        echo "========================="
        echo "     Repo Success"
        echo "========================="
else
        echo "========================="
        echo "     Repo Failed"
        echo "========================="
	repo forall -vc "git reset --hard"
	repo sync --force-sync
	crashcheck Repo         
fi
}

crashcheck () {
if [ "$?" = "0" ]; then
        echo "========================="
        echo "    $@ Success"
        echo "========================="
else
        echo "========================="
        echo "    $@ Failed"
        echo "========================="
        exit 1
fi
}

patcher() {
echo "========================="
echo "    Applying patches"
echo "========================="
for file in ~/lineageos/patches/$VERSION/$DEVICE/*.patch ; do
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
}


unpatch() {
echo "========================="
echo "   Reversing Patches     "
echo "========================="
for file in ~/lineageos/patches/$VERSION/$DEVICE/*.patch ; do
        patch -R --force --quiet -p1  < $file
        if [ $? != "0" ]; then
                echo "Failed to reverse $file"
        else
                echo "Successfully reversed $file"
        fi
done
}

clark_build () {
echo "========================="
echo "Building for Moto X Pure"
echo "    Codename Clark"
echo "========================="
echo ""
echo ""
echo "========================="
echo "   Setting up Manifest"
echo "========================="
mkdir -p ~/lineageos/system/$VERSION/.repo/local_manifests/
cp ~/lineageos/manifests/$VERSION/"$DEVICE"_roomservice.xml ~/lineageos/system/$VERSION/.repo/local_manifests/roomservice.xml
echo "========================="
echo "    Executing source"
echo "========================="
unpatch
reposync
patch
source build/envsetup.sh
crashcheck Source
echo "========================="
echo "  Executing breakfast"
echo "========================="
breakfast $DEVICE
crashcheck Breakfast
echo "========================="
echo "    Clean up source"
echo "========================="
# Find command should remove rejected patch files (.rej)
find . \( -name \*.orig -o -name \*.rej \) -delete
mka clobber
crashcheck Clobber
mka clean
crashcheck Clean
echo "========================="
echo "    Starting Build"
echo "========================="
mkdir -p ../../logs/$DEVICE/$VERSION
brunch $DEVICE > ../../logs/$DEVICE/$VERSION/build.$(date +%m-%d-%y_%H:%M%P).log
crashcheck Build
mkdir -p ../../roms/$VERSION/$DEVICE
cp out/target/product/$DEVICE/lineage-*.zip* ../../roms/$VERSION/$DEVICE
echo "================================"
echo " You can find the build in"
echo " ~/lineage/roms/$VERSION/$DEVICE"
echo "================================"
unpatch
sleep 20
clear
}

falcon_build () {
echo "========================="
echo "Building for Moto G 2014"
echo "    Codename Falcon"
echo "========================="
echo ""
echo ""
echo "========================="
echo "   Setting up Manifest"
echo "========================="
mkdir -p ~/lineageos/system/$VERSION/.repo/local_manifests/
cp ~/lineageos/manifests/$VERSION/"$DEVICE"_roomservice.xml ~/lineageos/system/$VERSION/.repo/local_manifests/roomservice.xml
echo "========================="
echo "    Executing source"
echo "========================="
unpatch
reposync
patch
source build/envsetup.sh
crashcheck Source
echo "========================="
echo "  Executing breakfast"
echo "========================="
breakfast $DEVICE
crashcheck Breakfast
echo "========================="
echo "    Clean up source"
echo "========================="
# Find command should remove rejected patch files (.rej)
find . \( -name \*.orig -o -name \*.rej \) -delete
mka clobber
crashcheck Clobber
mka clean
crashcheck Clean
echo "========================="
echo "    Starting Build"
echo "========================="
mkdir -p ../../logs/$DEVICE/$VERSION
brunch $DEVICE > ../../logs/$DEVICE/$VERSION/build.$(date +%m-%d-%y_%H:%M%P).log
crashcheck Build
mkdir -p ../../roms/$VERSION/$DEVICE
cp out/target/product/$DEVICE/lineage-*.zip* ../../roms/$VERSION/$DEVICE
echo "================================"
echo " You can find the build in"
echo " ~/lineage/roms/$VERSION/$DEVICE"
echo "================================"
unpatch
sleep 20
clear
}

x5_build () {
echo "========================="
echo "Building for LG Volt"
echo "    Codename x5"
echo "========================="
echo ""
echo ""
echo "========================="
echo "   Setting up Manifest"
echo "========================="
mkdir -p ~/lineageos/system/$VERSION/.repo/local_manifests/
cp ~/lineageos/manifests/$VERSION/"$DEVICE"_roomservice.xml ~/lineageos/system/$VERSION/.repo/local_manifests/roomservice.xml
echo "========================="
echo "    Executing source"
echo "========================="
unpatch
reposync
patch
source build/envsetup.sh
crashcheck Source
echo "========================="
echo "  Executing breakfast"
echo "========================="
breakfast $DEVICE
crashcheck Breakfast
echo "========================="
echo "    Clean up source"
echo "========================="
# Find command should remove rejected patch files (.rej)
find . \( -name \*.orig -o -name \*.rej \) -delete
mka clobber
crashcheck Clobber
mka clean
crashcheck Clean
echo "========================="
echo "    Starting Build"
echo "========================="
mkdir -p ../../logs/$DEVICE/$VERSION
brunch $DEVICE > ../../logs/$DEVICE/$VERSION/build.$(date +%m-%d-%y_%H:%M%P).log
crashcheck Build
mkdir -p ../../roms/$VERSION/$DEVICE
cp out/target/product/$DEVICE/lineage-*.zip* ../../roms/$VERSION/$DEVICE
echo "================================"
echo " You can find the build in"
echo " ~/lineage/roms/$VERSION/$DEVICE"
echo "================================"
unpatch
sleep 20
clear
}


repoinitcheck
"$DEVICE"_build