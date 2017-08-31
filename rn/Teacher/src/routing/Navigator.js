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
import { NativeModules } from 'react-native'
import { route } from './index'
import PropRegistry from './PropRegistry'

type ShowOptions = {
  modal: boolean,
  modalPresentationStyle: string,
  embedInNavigationController: boolean,
}

export type TraitCollectionType = 'compact' | 'regular' | 'unspecified'
export type TraitCollection = { [scope: string]: { [key: string]: TraitCollectionType} }

export default class Navigator {
  moduleName = ''
  screenConfig: Object = {}
  screenInstanceID: string = ''

  constructor (moduleName: string) {
    this.moduleName = moduleName
    this.screenInstanceID = this._uuid()
  }

  show (url: string, options: Object = { modal: false, modalPresentationStyle: 'formsheet' }, additionalProps: Object = {}): void {
    let screenInstanceID = this.screenInstanceID
    const additionalPropsFRD = Object.assign(additionalProps, { screenInstanceID })
    const r = route(url, additionalPropsFRD)
    PropRegistry.save(this.screenInstanceID, additionalPropsFRD)

    let canBecomeMaster = false
    if (r.config && r.config.canBecomeMaster) {
      canBecomeMaster = r.config.canBecomeMaster
    }
    if (options.modal) {
      this.present(r, { modal: options.modal, modalPresentationStyle: options.modalPresentationStyle || 'formsheet', embedInNavigationController: true, canBecomeMaster: canBecomeMaster, modalTransitionStyle: options.modalTransitionStyle })
    } else {
      this.push(r)
    }
  }

  push (route: RouteOptions) {
    NativeModules.Helm.pushFrom(this.moduleName, route.screen, route.passProps, route.config)
  }

  pop () {
    NativeModules.Helm.popFrom(this.moduleName)
  }

  present (route: RouteOptions, options: ShowOptions) {
    NativeModules.Helm.present(route.screen, route.passProps, options)
  }

  dismiss () {
    NativeModules.Helm.dismiss({})
  }

  dismissAllModals () {
    NativeModules.Helm.dismissAllModals({})
  }

  traitCollection (handler: (traits: TraitCollection) => void): any {
    return NativeModules.Helm.traitCollection(this.screenInstanceID, this.moduleName, handler)
  }

  _uuid (): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8) // eslint-disable-line one-var
      return v.toString(16)
    })
  }
}

