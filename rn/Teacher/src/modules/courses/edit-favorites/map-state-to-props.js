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

import type { EditFavoritesProps } from './prop-types'
import localeSort from '../../../utils/locale-sort'

export default function mapStateToProps (state: AppState): EditFavoritesProps {
  let courses = Object.keys(state.entities.courses)
    .map(id => state.entities.courses[id])
    .map(({ course }) => course)
    .sort((c1, c2) => localeSort(c1.name, c2.name))

  return {
    courses,
    favorites: state.favoriteCourses.courseRefs,
    pending: state.favoriteCourses.pending,
  }
}
