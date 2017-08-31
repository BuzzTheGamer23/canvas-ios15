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

import 'react-native'
import React from 'react'
import { CourseDetails, Refreshed } from '../CourseDetails.js'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'

const template = {
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/tab'),
  ...require('../../../../__templates__/helm'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../../routing')

let course = template.course()

let defaultProps = {
  navigator: template.navigator(),
  course,
  tabs: [template.tab()],
  courseColors: template.customColors(),
  courseID: course.id,
  refreshing: false,
}

test('renders correctly', () => {
  let tree = renderer.create(
    <CourseDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('refresh function first test', () => {
  const refreshCourses = jest.fn()
  const refreshTabs = jest.fn()
  const refreshLTITools = jest.fn()
  let refreshProps = {
    navigator: template.navigator(),
    courseID: course.id,
    tabs: [],
    refreshCourses,
    refreshTabs,
    refreshLTITools,
  }

  let refreshed = renderer.create(
    <Refreshed {...refreshProps} />
  )
  expect(refreshed.toJSON()).toMatchSnapshot()
  expect(refreshCourses).toHaveBeenCalled()
  expect(refreshTabs).toHaveBeenCalledWith(course.id)
})

test('refresh function second test', () => {
  const refreshCourses = jest.fn()
  const refreshTabs = jest.fn()
  const refreshLTITools = jest.fn()
  let refreshProps = {
    navigator: template.navigator(),
    courseID: course.id,
    course,
    tabs: [],
    refreshCourses,
    refreshTabs,
    refreshLTITools,
  }

  let refreshed = renderer.create(
    <Refreshed {...refreshProps} />
  )
  expect(refreshed.toJSON()).toMatchSnapshot()
  refreshed.getInstance().refresh()
  setProps(refreshed, refreshProps)
  expect(refreshCourses).toHaveBeenCalled()
  expect(refreshTabs).toHaveBeenCalledWith(course.id)
})

test('renders correctly without tabs', () => {
  let tree = renderer.create(
    <CourseDetails {...defaultProps} tabs={[]} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render without course', () => {
  const props = { ...defaultProps, course: null }
  expect(
    renderer.create(
      <CourseDetails {...props} />
    ).toJSON()
  ).toMatchSnapshot()
})

test('go back to course list', () => {
  const props = {
    ...defaultProps,
    navigator: template.navigator({
      dismiss: jest.fn(),
    }),
  }
  let tree = renderer.create(
    <CourseDetails {...props} />
  )

  tree.getInstance().back()
  expect(props.navigator.dismiss).toHaveBeenCalled()
})

test('select tab', () => {
  const tab = template.tab({
    id: 'assignments',
    html_url: '/courses/12/assignments',
  })
  const props = {
    ...defaultProps,
    course: template.course({ id: 12 }),
    tabs: [tab],
    navigator: template.navigator({
      show: jest.fn(),
    }),
  }

  let tree = renderer.create(
    <CourseDetails {...props} />
  ).toJSON()

  const tabRow: any = explore(tree).selectByID('courses-details.assignments-cell')
  tabRow.props.onPress()

  expect(props.navigator.show).toHaveBeenCalledWith('/courses/12/assignments')
})

test('edit course', () => {
  const props = {
    ...defaultProps,
    navigator: template.navigator({
      show: jest.fn(),
    }),
  }
  let tree = renderer.create(
    <CourseDetails {...props} />
  )

  tree.getInstance().editCourse()
  expect(props.navigator.show).toHaveBeenCalledWith(
    '/courses/1/settings',
    { modal: true, modalPresentationStyle: 'formsheet' }
  )
})

it('renders with image url', () => {
  let course = template.course({ image_download_url: 'http://www.fillmurray.com/100/100' })
  expect(
    renderer.create(
      <CourseDetails {...defaultProps} course={course} />
    ).toJSON()
  ).toMatchSnapshot()
})

it('renders without image url', () => {
  let course = template.course({ image_download_url: null })
  expect(
    renderer.create(
      <CourseDetails {...defaultProps} course={course} />
    ).toJSON()
  ).toMatchSnapshot()
})

it('renders with empty image url', () => {
  let course = template.course({ image_download_url: '' })
  expect(
    renderer.create(
      <CourseDetails {...defaultProps} course={course} />
    ).toJSON()
  ).toMatchSnapshot()
})

it('show placeholder', () => {
  const trait = jest.fn((callback) => {
    callback({
      screen: {
        horizontal: 'regular',
      },
      window: {
        horizontal: 'regular',
      },
    })
  })
  const show = jest.fn()
  const navigator = template.navigator({
    traitCollection: trait,
    show,
  })
  const props = {
    ...defaultProps,
    navigator,
  }
  let instance = renderer.create(
    <CourseDetails {...props} />
  ).getInstance()

  instance.showPlaceholder()
  expect(instance.placeholderDidShow).toEqual(true)
  expect(show).toHaveBeenLastCalledWith(
    '/courses/1/placeholder',
    {},
    { course }
  )
})
