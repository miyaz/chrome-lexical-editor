#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd ${SCRIPT_DIR}

if [ -d ./lexical/.git ]
then
  cd lexical
  git restore .
  git pull
  cd ..
else
  git clone https://github.com/facebook/lexical.git
fi
cp -rf lexical/packages/lexical-playground .
cp -rf lexical/packages/shared lexical-playground/shared/
#cp -rf lexical/scripts lexical-playground/
cd lexical-playground
npm i
npm -D i @babel/plugin-transform-flow-strip-types @babel/preset-react @rollup/plugin-babel

#cat <<EOS > ../vite.config.js.patch
#@@ -187,7 +187,7 @@ export default defineConfig({
#       plugins: [
#         '@babel/plugin-transform-flow-strip-types',
#         [
#-          require('../../scripts/error-codes/transform-error-messages'),
#+          require('./scripts/error-codes/transform-error-messages'),
#           {
#             noMinify: true,
#           },
#@@ -198,7 +198,12 @@ export default defineConfig({
#     react(),
#   ],
#   resolve: {
#-    alias: moduleResolution,
#+    alias: [
#+      {
#+        find: 'shared',
#+        replacement: path.resolve('./shared/src'),
#+      },
#+    ],
#   },
#   build: {
#     outDir: 'build',
#     rollupOptions: {
#       input: {
#         main: new URL('./index.html', import.meta.url).pathname,
#-        split: new URL('./split/index.html', import.meta.url).pathname,
#       },
#     },
#EOS
#
#patch -u vite.config.js < ../vite.config.js.patch

cat <<EOS > ../vite.prod.config.js.patch
@@ -181,14 +181,18 @@
     react(),
   ],
   resolve: {
-    alias: moduleResolution,
+    alias: [
+      {
+        find: 'shared',
+        replacement: path.resolve('./shared/src'),
+      },
+    ],
   },
   build: {
     outDir: 'build',
     rollupOptions: {
       input: {
         main: new URL('./index.html', import.meta.url).pathname,
-        split: new URL('./split/index.html', import.meta.url).pathname,
       },
     },
     commonjsOptions: {include: []},
EOS

patch -u vite.prod.config.js < ../vite.prod.config.js.patch

npm run build-prod
#npm run build-dev

cd ${SCRIPT_DIR}
rm -rf build
cp manifest.json lexical-playground/build/
mv lexical-playground/build/ build
