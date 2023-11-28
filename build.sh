#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd ${SCRIPT_DIR}

cd lexical-playground
npm i
npm run build-prod

cd ${SCRIPT_DIR}
rm -rf dist
cp manifest.json lexical-playground/build/
mv lexical-playground/build/ dist
