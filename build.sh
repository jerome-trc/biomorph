#!/bin/bash

mkdir -p ./out

cd ./biomorph
zip -0 -r ../out/biomorph.pk3 *

cd ../ccards
zip -0 -r ../out/biomorph-ccards.pk3 * 

cd ../drlmonsters
zip -0 -r ../out/biomorph-drlm.pk3 *
