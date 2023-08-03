#!/bin/bash

mkdir -p ./out

cd ./biomorph
zip -0 -r ../out/biomorph.pk3 *
cd ..

cd ./pawn-patch
zip -0 -r ../out/biomorph-pawn-patch.pk3 *
cd ..
