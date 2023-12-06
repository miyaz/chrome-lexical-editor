/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 */

import {defineConfig} from 'vite';
import react from '@vitejs/plugin-react';
import {resolve} from 'path';
import path from 'path';
import fs from 'fs';
import babel from '@rollup/plugin-babel';
import copy from 'rollup-plugin-copy'

// https://vitejs.dev/config/
export default defineConfig({
  define: {
    "process.env.IS_PREACT": process.env.IS_PREACT,
  },
  plugins: [
    babel({
      babelHelpers: 'bundled',
      babelrc: false,
      configFile: false,
      exclude: '/**/node_modules/**',
      extensions: ['jsx', 'js', 'ts', 'tsx', 'mjs'],
      plugins: ['@babel/plugin-transform-flow-strip-types'],
      presets: ['@babel/preset-react'],
    }),
    react(),
    copy({
      verbose: true,
      hook: 'writeBundle',
      targets: [{
        src: path.resolve(__dirname, 'node_modules/@excalidraw/excalidraw/dist/excalidraw-assets'),
        dest: 'build/assets',
      }]
    }),
  ],
  resolve: {
    alias: [
      {
        find: 'shared',
        replacement: path.resolve('./shared/src'),
      },
    ],
  },
  build: {
    outDir: 'build',
    rollupOptions: {
      input: {
        main: new URL('./index.html', import.meta.url).pathname,
      },
    },
    commonjsOptions: {
      include: 'node_modules/**',
      react: ['Component', 'createElement', 'createContext', 'useState'],
      'react-dom': ['render'],
    },
    minify: 'terser',
    terserOptions: {
      compress: {
        toplevel: true,
      }
    },
  },
});
