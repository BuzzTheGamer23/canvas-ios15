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

// @flow

import React from 'react'
import {
  SpeedGrader,
  mapStateToProps,
  refreshSpeedGrader,
  shouldRefresh,
  isRefreshing,
} from '../SpeedGrader'
import renderer from 'react-test-renderer'
import shuffle from 'knuth-shuffle-seeded'

jest.mock('../components/GradePicker')
jest.mock('../components/Header')
jest.mock('../components/SubmissionPicker.js')
jest.mock('../components/FilesTab')
jest.mock('../components/SimilarityScore')
jest.mock('../../../common/components/BottomDrawer')
jest.mock('knuth-shuffle-seeded', () => jest.fn())

const templates = {
  ...require('../../../__templates__/submissions'),
  ...require('../../../__templates__/assignments'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
  ...require('../../submissions/list/__templates__/submission-props'),
}

jest.mock('../../submissions/list/get-submissions-props', () => ({
  getSubmissionsProps: () => {
    const templates = {
      ...require('../../submissions/list/__templates__/submission-props'),
    }
    return {
      pending: false,
      submissions: [
        templates.submissionProps({ status: 'missing' }),
        templates.submissionProps(),
      ],
    }
  },
}))

let ownProps = {
  assignmentID: '1',
  userID: '1',
  courseID: '1',
}

let defaultProps = {
  ...ownProps,
  pending: false,
  refreshing: false,
  refresh: jest.fn(),
  refreshSubmissions: jest.fn(),
  refreshSubmissionSummary: jest.fn(),
  navigator: templates.navigator(),
  submissions: [],
  submissionEntities: {},
  resetDrawer: jest.fn(),
  assignmentSubmissionTypes: ['none'],
  gradeSubmissionWithRubric: jest.fn(),
}

describe('SpeedGrader', () => {
  it('renders', () => {
    let tree = renderer.create(
      <SpeedGrader {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with a filter', () => {
    let props = {
      ...defaultProps,
      submissions: [templates.submissionProps(), templates.submissionProps({ status: 'missing' })],
      selectedFilter: {
        filter: {
          type: 'notsubmitted',
          title: 'Who Cares?',
          filterFunc: subs => subs.filter(sub => sub.status === 'missing'),
        },
      },
    }
    let tree = renderer.create(
      <SpeedGrader {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('shows the loading spinner when there are no submissions', () => {
    let tree = renderer.create(
      <SpeedGrader {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('shows the loading spinner when pending and not refreshing', () => {
    let tree = renderer.create(
      <SpeedGrader {...defaultProps} pending={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders submissions if there are some', () => {
    const submissions = [templates.submissionProps()]
    const props = { ...defaultProps, submissions }
    let tree = renderer.create(
      <SpeedGrader {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('supplies getItemLayout', () => {
    let view = renderer.create(
      <SpeedGrader {...defaultProps} />
    )
    expect(view.getInstance().getItemLayout(null, 2)).toEqual({
      length: 770,
      offset: 770 * 2,
      index: 2,
    })
  })
})

describe('refresh functions', () => {
  beforeEach(() => jest.resetAllMocks())
  const props = {
    courseID: '12',
    assignmentID: '55',
    userID: '145',
    refreshSubmissions: jest.fn(),
    refreshSubmissionSummary: jest.fn(),
    refreshEnrollments: jest.fn(),
    refreshAssignment: jest.fn(),
    refreshGroupsForCourse: jest.fn(),
    resetDrawer: jest.fn(),
    assignmentSubmissionTypes: ['none'],
    submissions: [],
    submissionEntities: {},
    refresh: jest.fn(),
    refreshing: false,
    pending: false,
    navigator: templates.navigator(),
    isModeratedGrading: false,
    hasAssignment: true,
    hasRubric: false,
    groupAssignment: null,
    studentIndex: 1,
    gradeSubmissionWithRubric: jest.fn(),
  }
  it('refreshSubmissions', () => {
    refreshSpeedGrader(props)
    expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID, false)
    expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
    expect(props.refreshAssignment).toHaveBeenCalledWith(props.courseID, props.assignmentID)
  })
  it('refreshSubmissions on group assignments', () => {
    refreshSpeedGrader({
      ...props,
      groupAssignment: { groupCategoryID: '334', gradeIndividually: false },
    })
    expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID, true)
    expect(props.refreshGroupsForCourse).toHaveBeenCalledWith(props.courseID)
    expect(props.refreshAssignment).toHaveBeenCalledWith(props.courseID, props.assignmentID)
  })
  it('isRefreshing', () => {
    const isNot = isRefreshing(props)
    expect(isNot).toBeFalsy()

    const is = isRefreshing({ ...props, pending: true })
    expect(is).toBeTruthy()
  })
  it('shouldRefresh', () => {
    const should = shouldRefresh(props)
    expect(should).toBeTruthy()

    const submissions = [templates.submissionProps()]
    const shouldNot = shouldRefresh({ ...props, submissions })
    expect(shouldNot).toBeFalsy()
  })
})

test('mapStateToProps shuffles when anonymous grading is on', () => {
  const assignment = templates.assignment()
  const appState = templates.appState({
    entities: {
      submissions: {},
      assignments: {
        [assignment.id]: {
          data: assignment,
          anonymousGradingOn: true,
        },
      },
    },
  })
  mapStateToProps(appState, {
    assignmentID: assignment.id,
    courseID: '2',
    userID: '3',
    studentIndex: 1,
  })
  expect(shuffle).toHaveBeenCalled()
})
