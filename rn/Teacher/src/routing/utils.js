//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import {
  processColor,
  Image,
} from 'react-native'
import { type TraitCollection } from './Navigator'
import i18n from 'format-message'

function isColorKey (key: string): boolean {
  const COLOR_REGEX = /color$/i
  return COLOR_REGEX.test(key)
}

function isImageKey (key: string): boolean {
  const IMAGE_REGEX = /image/i
  return IMAGE_REGEX.test(key)
}

function processConfig (config: Object, id: string, configureCallback: (event: string, callback: () => void) => string): Object {
  const obj = {}
  Object.keys(config).forEach(key => {
    if (key === 'children') return
    if (typeof config[key] === 'function') {
      const id = config['actionID'] || config['testID']
      if (id) {
        obj[key] = configureCallback(id, config[key])
      } else {
        console.warn('Configuring callback with potentially non unique event id')
        obj[key] = configureCallback(key, config[key])
      }
    } else if (isColorKey(key)) {
      obj[key] = processColor(config[key])
    } else if ((typeof config[key] !== 'string') && isImageKey(key)) {
      obj[key] = Image.resolveAssetSource(config[key])
    } else if (Array.isArray(config[key])) {
      obj[key] = config[key].map(c => {
        return processConfig(c, id, configureCallback)
      })
    } else {
      obj[key] = config[key]
    }
  })
  return obj
}
/*
*   Display Modes: < compact | regular | unspecified >
*   regular = ipad in landscape orientation
*   compact = most other device orientation sizes , iphone, iphone+ in portrait
*   unspecified = view has not registered traits yet
*/
function isRegularDisplayMode (traits: TraitCollection): boolean {
  try {
    return traits.window.horizontal === 'regular'
  } catch (e) {}
  return false   //  default to false
}

function checkDefaults (props: Object): Object {
  return {
    ...props,
    backButtonTitle: props.backButtonTitle || i18n('Back'),
  }
}

module.exports = {
  processConfig,
  isRegularDisplayMode,
  checkDefaults,
}
