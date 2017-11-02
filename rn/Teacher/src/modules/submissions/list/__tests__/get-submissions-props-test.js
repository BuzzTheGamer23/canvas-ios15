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

import { gradeProp } from '../get-submissions-props'

const template = {
  ...require('../../../../__templates__/submissions'),
}

describe('GetSubmissionsProps gradeProp', () => {
  test('null submission', () => {
    const result = gradeProp(null)
    expect(result).toEqual('not_submitted')
  })

  test('unsubmitted submission', () => {
    const submission = template.submission({
      grade: null,
      submitted_at: null,
    })

    const result = gradeProp(submission)
    expect(result).toEqual('not_submitted')
  })

  test('excused submission', () => {
    const submission = template.submission({
      excused: true,
    })

    const result = gradeProp(submission)
    expect(result).toEqual('excused')
  })

  test('graded submission', () => {
    const grade = '33'
    const submission = template.submission({
      grade: grade,
      workflow_state: 'graded',
    })

    const result = gradeProp(submission)
    expect(result).toEqual(grade)
  })

  test('ungraded submission', () => {
    const submission = template.submission({
      grade_matches_current_submission: false,
    })

    const result = gradeProp(submission)
    expect(result).toEqual('ungraded')
  })
})
