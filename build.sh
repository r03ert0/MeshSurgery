#!/bin/zsh
# Builds MeshSurgery.app with clang (no Xcode needed) into build/ and links it at the project root.
set -e
cd "$(dirname "$0")"
B=build; A=$B/MeshSurgery.app
rm -rf $B/obj $A; mkdir -p $B/obj $A/Contents/MacOS $A/Contents/Resources/{Base.lproj,en.lproj}
for f in DocumentRAMON Float3D Int2D Int3D Mesh MyDocument MyView RAMON Trackball main; do
  clang -c -fno-objc-arc -include src/MeshSurgery_Prefix.pch -arch arm64 -mmacosx-version-min=11.0 \
    -Wno-deprecated-declarations src/$f.m -o $B/obj/$f.o
done
clang -c -arch arm64 src/math3D.c -o $B/obj/math3D.o
clang -arch arm64 $B/obj/*.o -framework Cocoa -framework OpenGL -o $A/Contents/MacOS/MeshSurgery
cp -R src/Base.lproj/*.nib $A/Contents/Resources/Base.lproj/
cp src/en.lproj/* $A/Contents/Resources/en.lproj/
sed -e 's/${EXECUTABLE_NAME}/MeshSurgery/;s/${PRODUCT_NAME}/MeshSurgery/;s/$(PRODUCT_BUNDLE_IDENTIFIER)/org.r03ert0.MeshSurgery/' src/Info.plist > $A/Contents/Info.plist
printf 'APPL????' > $A/Contents/PkgInfo
codesign --force --sign - $A
ln -sfn $A MeshSurgery.app
