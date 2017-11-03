//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* @flow */

import React from 'react'
import {
  Alert,
  NativeModules,
} from 'react-native'
import renderer from 'react-test-renderer'

import { AnnouncementEdit, mapStateToProps, type Props } from '../AnnouncementEdit'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'
import { defaultErrorTitle } from '../../../../redux/middleware/error-handler'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing/Screen')
  .mock('DatePickerIOS', () => 'DatePickerIOS')
  .mock('LayoutAnimation', () => ({
    easeInEaseOut: jest.fn(),
    Types: {
      easeInEaseOut: jest.fn(),
      spring: jest.fn(),
    },
    Properties: {
      opacity: 1,
    },
  }))
  .mock('../../../../common/components/rich-text-editor/RichTextEditor', () => 'RichTextEditor')
  .mock('Alert', () => ({
    alert: jest.fn(),
  }))
  .mock('../../../../common/components/UnmetRequirementBanner', () => 'UnmetRequirementBanner')
  .mock('../../../../common/components/RequiredFieldSubscript', () => 'RequiredFieldSubscript')
  .mock('Switch', () => 'Switch')

const template = {
  ...require('../../../../__templates__/discussion'),
  ...require('../../../../__templates__/attachment'),
  ...require('../../../../__templates__/error'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('AnnouncementEdit', () => {
  let props: Props
  let formFields
  beforeEach(() => {
    jest.clearAllMocks()
    formFields = {
      title: 'Cursed Hollow',
      message: 'Gather tribute or face my curse.',
      require_initial_post: false,
      delayed_post_at: null,
      attachment: null,
    }

    props = {
      ...formFields,
      announcementID: '1',
      courseID: '1',
      pending: 0,
      error: null,
      navigator: template.navigator(),
      createDiscussion: jest.fn(),
      updateDiscussion: jest.fn(),
      deletePendingNewDiscussion: jest.fn(),
      defaultDate: new Date(0),
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders new form', () => {
    props.announcementID = null
    const title = getTitle(render(props))
    expect(title).toEqual('New Announcement')
  })

  it('renders edit form', () => {
    props.announcementID = '1'
    const title = getTitle(render(props))
    expect(title).toEqual('Edit Announcement')
  })

  it('uses title from input', () => {
    props.announcementID = null
    props.title = 'Hanamura'
    props.createDiscussion = jest.fn()
    const component = render(props)
    changeTitle(component, 'Haunted Mines')
    tapDone(component)
    expect(props.createDiscussion).toHaveBeenCalledWith(
      props.courseID,
      { ...formFields, is_announcement: true, title: 'Haunted Mines' },
    )
  })

  it('sends is_announcement param on create', () => {
    props.announcementID = null
    props.createDiscussion = jest.fn()
    tapDone(render(props))
    expect(props.createDiscussion).toHaveBeenCalledWith(
      props.courseID,
      { ...formFields, is_announcement: true },
    )
  })

  it('provides defaults for new announcement', () => {
    props.announcementID = null
    props.title = ''
    props.message = 'required'
    props.require_initial_post = null
    props.delayed_post_at = null
    props.createDiscussion = jest.fn()
    tapDone(render(props))
    expect(props.createDiscussion.mock.calls).toMatchSnapshot()
  })

  it('renders delayed post at row if it exists', () => {
    props.delayed_post_at = null
    expect(explore(render(props).toJSON()).selectByID('announcements.edit.delayed-post-at-row')).toBeNull()
    props.delayed_post_at = (new Date()).toISOString()
    expect(explore(render(props).toJSON()).selectByID('announcements.edit.delayed-post-at-row')).not.toBeNull()
  })

  it('toggles delayed post at row options', () => {
    props.delayed_post_at = null
    const component = render(props)
    toggleDelayPosting(component, true)
    expect(explore(component.toJSON()).selectByID('announcements.edit.delayed-post-at-row')).not.toBeNull()
    toggleDelayPosting(component, false)
    expect(explore(component.toJSON()).selectByID('announcements.edit.delayed-post-at-row')).toBeNull()
  })

  it('toggles delayed post at date picker', () => {
    props.delayed_post_at = (new Date()).toISOString()
    const component = render(props)
    tapDelayedPostAtRow(component)
    expect(explore(component.toJSON()).selectByID('announcements.edit.delayed-post-at-date-picker')).not.toBeNull()
  })

  it('converts delayed post at date to iso string', () => {
    props.delayed_post_at = (new Date()).toISOString()
    const component = render(props)
    tapDelayedPostAtRow(component)
    const datePicker: any = explore(component.toJSON()).selectByID('announcements.edit.delayed-post-at-date-picker')
    datePicker.props.onDateChange(new Date(0))
    expect(getDelayPostAtValueFromLabel(component)).toEqual('Dec 31 5:00 PM')
  })

  it('shows modal when saving', () => {
    const component = render(props)
    tapDone(component)
    const modal: any = explore(component.toJSON()).query(({ type }) => type === 'Modal')[0]
    expect(modal.props.visible).toBeTruthy()
  })

  it('alerts save errors', () => {
    props.announcementID = null
    jest.useFakeTimers()
    // $FlowFixMe
    Alert.alert = jest.fn()
    const component = render(props)
    const createDiscussion = jest.fn(() => {
      setProps(component, { error: 'ERROR WAS ALERTED' })
    })
    component.update(<AnnouncementEdit {...props} createDiscussion={createDiscussion} />)
    tapDone(component)
    jest.runAllTimers()
    expect(Alert.alert).toHaveBeenCalledWith(defaultErrorTitle(), 'ERROR WAS ALERTED')
  })

  it('dismisses on successful save', () => {
    props.announcementID = null
    props.navigator.dismissAllModals = jest.fn()
    const component = render(props)
    const createDiscussion = jest.fn(() => {
      setProps(component, { pending: 0 })
    })
    component.update(<AnnouncementEdit {...props} createDiscussion={createDiscussion} />)
    tapDone(component)
    expect(props.navigator.dismissAllModals).toHaveBeenCalled()
  })

  it('updates with new props', () => {
    const component = render(props)
    const updateDiscussion = jest.fn(() => {
      setProps(component, { title: 'component will receive this title prop' })
    })
    component.update(<AnnouncementEdit {...props} updateDiscussion={updateDiscussion} />)
    tapDone(component)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('clears delay post at date', () => {
    props.delayed_post_at = (new Date(0)).toISOString()
    const component = render(props)
    clearDelayPostAt(component)
    expect(getDelayPostAtPicker(component)).toBeNull()
  })

  it('deletes pending new discussion on unmount', () => {
    props.deletePendingNewDiscussion = jest.fn()
    render(props).getInstance().componentWillUnmount()
    expect(props.deletePendingNewDiscussion).toHaveBeenCalledWith(props.courseID)
  })

  it('calls dismiss on cancel', () => {
    props.navigator.dismiss = jest.fn()
    tapCancel(render(props))
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('sets message placeholder', () => {
    expect(getMessageEditor(render(props)).props.placeholder).toEqual('Add description (required)')
  })

  it('shows banner on done press if message is blank', () => {
    props.message = null
    const component = render(props)
    expect(getUnmetRequirementBanner(component).props.visible).toBeFalsy()
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeTruthy()
  })

  it('focuses unmetRequirementBanner when it shows', () => {
    jest.useFakeTimers()
    props.message = null
    const component = render(props)
    expect(getUnmetRequirementBanner(component).props.visible).toBeFalsy()
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeTruthy()
    jest.runAllTimers()
    expect(NativeModules.NativeAccessibility.focusElement).toHaveBeenCalledWith(`announcement.edit.unmet-requirement-banner`)
  })

  it('calls updateDiscussion on done', () => {
    props.updateDiscussion = jest.fn()
    props.courseID = '1'
    props.announcementID = '2'
    const component = render(props)
    changeTitle(component, 'UPDATED TITLE')
    tapDone(component)
    expect(props.updateDiscussion).toHaveBeenCalledWith(
      '1',
      { ...formFields, title: 'UPDATED TITLE', is_announcement: true, id: '2' },
    )
  })

  it('shows attachments', () => {
    const spy = jest.fn()
    props.navigator.show = spy
    props.attachment = template.attachment()
    const btn: any = explore(render(props).toJSON()).selectRightBarButton('announcements.edit.attachment-btn')
    btn.action()
    expect(spy).toHaveBeenCalledWith(
      '/attachments',
      { modal: true },
      {
        attachments: [props.attachment],
        maxAllowed: 1,
        storageOptions: {
          upload: false,
        },
        onComplete: expect.any(Function),
      },
    )
  })

  function testRender (props: Props) {
    expect(render(props)).toMatchSnapshot()
  }

  function render (props: Props) {
    return renderer.create(<AnnouncementEdit {...props} />)
  }

  function tapDone (component: any): any {
    getDoneButton(component).action()
    return component
  }

  function tapCancel (component: any) {
    const done: any = explore(component.toJSON()).selectLeftBarButton('announcements.edit.cancelButton')
    done.action()
  }

  function changeTitle (component: any, value: string) {
    const input: any = explore(component.toJSON()).selectByID('announcements.edit.titleInput')
    input.props.onChangeText(value)
  }

  function getTitle (component: any): string {
    return explore(component.toJSON()).query(({ type }) => type === 'Screen')[0].props.title
  }

  function getMessageEditor (component: any): any {
    return explore(component.toJSON()).query(({ type }) => type === 'RichTextEditor')[0]
  }

  function getDoneButton (component: any): any {
    return explore(component.toJSON()).selectRightBarButton('announcements.edit.doneButton')
  }

  function toggleDelayPosting (component: any, enabled: boolean) {
    const toggle: any = explore(component.toJSON()).selectByID('announcements.edit.delay-posting-toggle')
    toggle.props.onValueChange(enabled)
  }

  function tapDelayedPostAtRow (component: any) {
    const row: any = explore(component.toJSON()).selectByID('announcements.edit.delayed-post-at-row')
    row.props.onPress()
  }

  function getDelayPostAtPicker (component: any): any {
    const label: any = explore(component.toJSON()).selectByID('announcements.edit.delayed-post-at-date-picker')
    return label
  }

  function getDelayPostAtValueFromLabel (component: any): string {
    const label: any = explore(component.toJSON()).selectByID('announcements.edit.delayed-post-at-value-label')
    return label.children[0]
  }

  function clearDelayPostAt (component: any) {
    const clearButton: any = explore(component.toJSON()).selectByID('announcements.edit.clear-delayed-post-at-button')
    clearButton.props.onPress()
  }

  function getUnmetRequirementBanner (component: any): any {
    return explore(component.toJSON()).selectByID('announcement.edit.unmet-requirement-banner')
  }
})

describe('map state to props', () => {
  it('maps new error and pending states to props', () => {
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            pending: 0,
            error: null,
            discussions: {
              pending: 0,
              error: null,
              refs: [],
              new: {
                pending: 14,
                error: 'Map this error',
              },
            },
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '1', announcementID: null })
    ).toMatchObject({
      pending: 14,
      error: 'Map this error',
    })
  })

  it('maps announcement state to props using new id', () => {
    const announcement = template.discussion({ id: '45', title: 'IT WORKED' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            pending: 0,
            error: null,
            discussions: {
              pending: 0,
              error: null,
              refs: [],
              new: {
                id: '45',
                pending: 14,
                error: 'Map this error',
              },
            },
          },
        },
        discussions: {
          '45': {
            pending: 0,
            error: null,
            data: announcement,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '1', announcementID: null })
    ).toMatchObject({ title: 'IT WORKED' })
  })

  it('maps announcement state to props', () => {
    const announcement = template.discussion({
      id: '1',
      title: 'Infernal Shrines',
      message: 'THE ENEMY IS ATTACKING YOUR CORE!',
      require_initial_post: true,
      delayed_post_at: null,
    })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        discussions: {
          '1': {
            pending: 45,
            error: 'YOUR CORE IS UNDER ATTACK',
            data: announcement,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '10', announcementID: '1' })
    ).toMatchObject({
      title: 'Infernal Shrines',
      message: 'THE ENEMY IS ATTACKING YOUR CORE!',
      require_initial_post: true,
      delayed_post_at: null,
      pending: 45,
      error: 'YOUR CORE IS UNDER ATTACK',
    })
  })

  it('maps attachment state to props', () => {
    const attachment = template.attachment()
    const announcement = template.discussion({
      id: '1',
      attachments: [attachment],
    })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        discussions: {
          '1': {
            pending: 0,
            error: null,
            data: announcement,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '1', announcementID: '1' })
    ).toMatchObject({ attachment })
  })
})
