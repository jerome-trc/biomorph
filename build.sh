#!/bin/bash

mkdir -p ./out

cd ./biomorph
zip -9 -r ../out/biomorph.pk3 *
cd ..
zip -9 ./out/biomorph.pk3 ./ATTRIB.md ./README.md ./LICENSE

cd ./pawn-patch
zip -9 -r ../out/biomorph-pawn-patch.pk3 *
cd ..
