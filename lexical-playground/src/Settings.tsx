/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 */

import * as React from 'react';
import {useState} from 'react';

import {useSettings} from './context/SettingsContext';
import Switch from './ui/Switch';

export default function Settings(): JSX.Element {
  const {
    setOption,
    settings: {
      isRichText,
    },
  } = useSettings();
  const [showSettings, setShowSettings] = useState(false);

  return (
    <>
      <button
        id="options-button"
        className={`editor-dev-button ${showSettings ? 'active' : ''}`}
        onClick={() => setShowSettings(!showSettings)}
      />
      {showSettings ? (
        <div className="switches">
          <Switch
            onClick={() => {
              setOption('isRichText', !isRichText);
            }}
            checked={isRichText}
            text="Rich Text"
          />
        </div>
      ) : null}
    </>
  );
}
