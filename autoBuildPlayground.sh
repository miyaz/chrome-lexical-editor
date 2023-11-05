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

cat <<EOS > ../Editor.tsx.patch
@@ -74,6 +74,71 @@
 import ContentEditable from './ui/ContentEditable';
 import Placeholder from './ui/Placeholder';
 
+import { useLexicalComposerContext } from "@lexical/react/LexicalComposerContext";
+import { BLUR_COMMAND, FOCUS_COMMAND, CLEAR_HISTORY_COMMAND, COMMAND_PRIORITY_EDITOR } from "lexical";
+import {exportFile} from '@lexical/file';
+import {version} from '../package.json';
+import type {EditorState} from 'lexical';
+
+type DocumentJSON = {
+  editorState: EditorState;
+  lastSaved: number;
+  version: typeof version;
+};
+
+const EditorFocusBlurPlugin = () => {
+  const [editor] = useLexicalComposerContext();
+  useEffect(() => {
+    editor.registerCommand(
+      BLUR_COMMAND,
+      (payload) => {
+        console.log(payload);
+        const now = new Date();
+        const editorState = editor.getEditorState();
+        const documentJSON: DocumentJSON = {
+          editorState: editorState.toJSON(),
+          lastSaved: now.getTime(),
+          version,
+        };
+        chrome.storage.local.set({ 
+          saveData: documentJSON,
+        })
+        .then(() => {
+          console.log("Value is set");
+        })
+        .catch((e) => {
+          console.log(e);
+        });
+      },
+      COMMAND_PRIORITY_EDITOR
+    );
+  }, []);
+
+  useEffect(() => {
+    editor.registerCommand(
+      FOCUS_COMMAND,
+      (payload) => {
+        console.log(payload);
+        chrome.storage.local.get(['saveData'], (res) => {
+          console.log(res)
+          //const json = JSON.parse(res);
+          const editorState = editor.parseEditorState(
+            JSON.stringify(res.saveData.editorState),
+          );
+          editor.setEditorState(editorState);
+          editor.dispatchCommand(CLEAR_HISTORY_COMMAND, undefined);
+        })
+        .catch((e) => {
+          console.log(e);
+        });
+      },
+      COMMAND_PRIORITY_EDITOR
+    );
+  }, []);
+
+  return null;
+};
+
 const skipCollaborationInit =
   // @ts-ignore
   window.parent != null && window.parent.frames.right === window;
@@ -154,6 +219,7 @@
         <ComponentPickerPlugin />
         <EmojiPickerPlugin />
         <AutoEmbedPlugin />
+        <EditorFocusBlurPlugin />
 
         <MentionsPlugin />
         <EmojisPlugin />
EOS

patch -u src/Editor.tsx < ../Editor.tsx.patch

npm run build-prod
#npm run build-dev

cd ${SCRIPT_DIR}
rm -rf build
cp manifest.json lexical-playground/build/
mv lexical-playground/build/ build
