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

class CourseListPageTest: TeacherTest {

    func testCourseListEmptyPage_displaysEmptyState() {
        logIn(self)
        coursesListPage.assertEmptyStatePageObjects()
    }

//    func testCourseListPage_displaysPageObjects() {
//        logIn(self)
//        coursesListPage.assertHasFavoritesStatePageObjects()
//    }

    func testCourseListPage_displaysList() {
        logIn(self)
        let course = Data.getNextCourse(self)
        coursesListPage.assertCourseExists(course)
    }
}
