#!/bin/bash

BIOMORPH_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cp -r ../Biomorph /tmp/Biomorph

rm -rf -- /tmp/Biomorph/.git /tmp/Biomorph/.vscode /tmp/Biomorph/doc
rm -- /tmp/Biomorph/.gitignore /tmp/Biomorph/build.sh

cd /tmp/Biomorph
zip -0 -r $BIOMORPH_DIR/Biomorph.pk3 *
cd $BIOMORPH_DIR

rm -rf /tmp/Biomorph
