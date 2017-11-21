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

import httpClient from '../httpClient'
import { paginate, exhaust } from '../utils/pagination'

export function getLTILaunchDefinitions (courseID: string): Promise<ApiResponse<Array<getLTILaunchDefinitions>>> {
  const url = `courses/${courseID}/lti_apps/launch_definitions`

  const paginated = paginate(url, {
    params: {
      per_page: 99,
      placements: ['course_navigation'],
    },
  })
  return exhaust(paginated)
}

export function getExternalTool (courseID: string, id: string, options: GetExternalToolOptions): Promise<ApiResponse<ExternalTool>> {
  const { assignment } = options
  let params = {}
  const url = `courses/${courseID}/external_tools/${id}`

  if (assignment) {
    params['launch_type'] = 'assessment'
    params['assignment_id'] = assignment.id
  }

  return httpClient().get(url, { params })
}

export function getSessionlessLaunchURL (courseID: string, options: GetExternalToolOptions): Promise<string> {
  return getExternalTool(courseID, 'sessionless_launch', options).then(response => response.data.url)
}
