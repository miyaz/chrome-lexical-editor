/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 */

import * as React from 'react';

import {useSettings} from './context/SettingsContext';

export default function Settings(): JSX.Element {
  const {
    setOption,
    settings: {
    },
  } = useSettings();

  return <></>
}
