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

import SoGrey
import EarlGrey

class CoursesListPage {

    // MARK: Singleton

    static let sharedInstance = CoursesListPage()
    private let tabBarController = TabBarControllerPage.sharedInstance
    private init() {}

    // MARK: Elements

    private let feedbackButton = e.selectBy(id: "favorited-course-list.feedback-btn")
    private let editButton = e.selectBy(id: "favorited-course-list.edit-btn")
    private let headerStarImage = e.selectBy(id: "favorited-course-list.header-star-img")
    private let headerCoursesLabel = e.selectBy(id: "favorited-course-list.header-courses-lbl")
    private let seeAllCoursesButton = e.selectBy(id: "favorited-course-list.see-all-btn")
    private let pageView = e.selectBy(id: "favorited-course-list.view")
    private let emptyStateWelcomeLabel = e.selectBy(id: "no-courses.welcome-lbl")
    private let emptyStateDescriptionLabel = e.selectBy(id: "no-courses.description-lbl")
    private let emptyStateAddCourseButton = e.selectBy(id: "no-courses.add-courses-btn")

    // MARK: - Helpers

    private func courseId(_ course: Course) -> String {
        return "course-card.kabob-\(course.id)"
    }

    private func courseCard(_ course: Course) -> GREYElementInteraction {
        return e.selectBy(id: course.courseCode)
    }

    // MARK: - Assertions

    func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        tabBarController.assertTabBarItems()
        pageView.assertExists()
    }

    func assertEmptyStatePageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        emptyStateWelcomeLabel.assertExists()
        emptyStateDescriptionLabel.assertExists()
        emptyStateAddCourseButton.assertExists()
    }

    func assertHasFavoritesStatePageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        feedbackButton.assertExists()
        editButton.assertExists()
        headerStarImage.assertExists()
        headerCoursesLabel.assertExists()
        seeAllCoursesButton.assertExists()
    }

    func assertCourseExists(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        e.selectBy(id: courseId(course)).assertExists()
    }

    func assertCourseDoesNotExist(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        e.selectBy(id: courseId(course)).assertHidden()
    }

    func assertCourseHidden(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        e.selectBy(id: courseId(course)).assertHidden()
    }

    // MARK: - UI Actions

    func openCourseFavoritesEditPage(_ emptyState: Bool, file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        if emptyState {
            emptyStateAddCourseButton.tap()
        } else {
            editButton.tapUntilHidden()
        }
    }

    func openAllCoursesPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        seeAllCoursesButton.tap()
    }

    func openCourseDetailsPage(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        courseCard(course).tap()
    }
}
