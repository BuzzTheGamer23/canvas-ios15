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
    
    


import ReactiveSwift
import Result
import CanvasCore

extension Assignment {
    func gradeColorfulViewModel(_ dataSource: EnrollmentsDataSource) -> ColorfulViewModel {
        let model = ColorfulViewModel(features: [.icon, .rightDetail])
        model.title.value = name
        model.rightDetail.value = grade
        model.color <~ dataSource.color(for: .course(withID: courseID))
        model.icon.value = icon
        return model
    }
}
