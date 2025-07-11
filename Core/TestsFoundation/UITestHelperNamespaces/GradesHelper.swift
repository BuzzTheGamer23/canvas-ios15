//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Core
import XCTest

public class GradesHelper: BaseHelper {
    public static var totalGrade: XCUIElement { app.find(id: "CourseTotalGrade") }
    public static var filterButton: XCUIElement { app.find(id: "GradeList.filterButton") }
    public static var lockIcon: XCUIElement { app.find(id: "lockIcon") }
    public static var basedOnGradedSwitch: XCUIElement { app.find(id: "BasedOnGradedToggle", type: .toggle) }
    public static var emptyView: XCUIElement { app.find(id: "GradeList.emptyView") }

    public static func upcomingAssignmentsSectionTitle(numberOfItems: Int) -> XCUIElement {
        let itemCountLabel = String.localizedNumberOfItems(numberOfItems)
        return app.find(label: "Upcoming Assignments, \(itemCountLabel)", type: .staticText)
    }

    public static func labelOfAssignmentGroup(_ assignmentGroup: DSAssignmentGroup, numberOfItems: Int) -> XCUIElement {
        let itemCountLabel = String.localizedNumberOfItems(numberOfItems)
        return app.find(label: "\(assignmentGroup.name), \(itemCountLabel)", type: .staticText)
    }

    public static func cell(assignment: DSAssignment? = nil, assignmentId: String? = nil) -> XCUIElement {
        return app.find(id: "GradeListCell.\(assignment?.id ?? assignmentId!)")
    }

    public static func gradedLabel(assignmentCell: XCUIElement) -> XCUIElement {
        return assignmentCell.find(label: "Graded", type: .staticText)
    }

    public static func gradeLabel(assignmentCell: XCUIElement) -> XCUIElement {
        return assignmentCell.find(labelContaining: "Grade, ", type: .staticText)
    }

    public static func gradeOutOf(assignment: DSAssignment? = nil,
                                  assignmentId: String? = nil,
                                  actualPoints: String,
                                  maxPoints: String,
                                  letterGrade: String = "") -> XCUIElement {
        let assignment = app.find(id: "GradeListCell.\(assignment?.id ?? assignmentId!)")
        let lgSuffix = letterGrade == "" ? "" : " (\(letterGrade))"
        return assignment.find(label: "Grade, \(actualPoints) out of \(maxPoints)\(lgSuffix)")
    }

    public static func gradesAssignmentSubmittedLabel(assignment: DSAssignment) -> XCUIElement {
        return cell(assignment: assignment).findAll(type: .staticText, minimumCount: 3)[2]
    }

    public static func checkForTotalGrade(value: String) -> Bool {
        totalGrade.waitUntil(.visible).waitUntil(.label(expected: value))
        return totalGrade.isVisible && totalGrade.label == value
    }

    public static func navigateToAssignments(course: DSCourse) {
        DashboardHelper.courseCard(course: course).hit()
        CourseDetailsHelper.cell(type: .assignments).hit()
    }

    public static func navigateToGrades(course: DSCourse) {
        XCTContext.runActivity(named: "Navigate to Grades screen") { _ in
            let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
            XCTAssertTrue(courseCard.isVisible)

            courseCard.hit()
            CourseDetailsHelper.cell(type: .grades).hit()

            let filterButton = filterButton.waitUntil(.visible)
            XCTAssertTrue(filterButton.isVisible)
        }
    }

    /// Assumes the screen is already loaded
    public static func refreshGradesScreen() {
        XCTContext.runActivity(named: "Refresh Grades screen") { _ in
            let firstCell = app.find(idStartingWith: "GradeListCell").waitUntil(.visible, timeout: 1, gracePeriod: 0.5)
            if firstCell.isVisible {
                firstCell.pullToRefresh()
                return
            }

            let emptyView = emptyView.waitUntil(.visible, timeout: 1, gracePeriod: 0.5)
            if emptyView.isVisible {
                // avoiding the interactive panda which almost fills the view
                emptyView.pullToRefresh(x: 0.1, y: -0.1)
            }
        }
    }

    public struct Filter {
        public static var cancelButton: XCUIElement { app.find(label: "Cancel", type: .button) }
        public static var sortByGroupSwitch: XCUIElement { app.find(id: "GradeFilter.sortModeOptions.groupName") }
        public static var sortByDateSwitch: XCUIElement { app.find(id: "GradeFilter.sortModeOptions.dueDate") }
        public static var saveButton: XCUIElement { app.find(id: "GradeFilter.saveButton", type: .button) }

        public static func optionButton(gradingPeriod: DSGradingPeriod? = nil) -> XCUIElement {
            let periodId = gradingPeriod?.id ?? "_this_is_an_unlikely_id_preserved_for_the_all_option_"
            return app.find(id: "GradeFilter.gradingPeriodOptions.\(periodId)")
        }
    }

    // MARK: Data Seeding
    @discardableResult
    public static func submitAssignment(course: DSCourse, student: DSUser, assignment: DSAssignment, body: String? = nil) -> DSSubmission {
        return seeder.createSubmission(courseId: course.id, assignmentId: assignment.id, requestBody: .init(
            submission_type: .online_text_entry, body: body ?? "This is a submission body", user_id: student.id))
    }

    public static func createSubmissionsForAssignments(course: DSCourse, student: DSUser, assignments: [DSAssignment]) {
        for assignment in assignments {
            submitAssignment(course: course, student: student, assignment: assignment)
            sleep(1)
        }
    }

    public static func createAssignments(course: DSCourse, count: Int, points_possible: [Float]? = nil, grading_type: GradingType? = nil) -> [DSAssignment] {
        var assignments = [DSAssignment]()
        for i in 0..<count {
            assignments.append(
                seeder.createAssignment(
                    courseId: course.id,
                    assignementBody: .init(
                        name: "\(grading_type?.rawValue.capitalized ?? "Sample") Assignment \(i)",
                        description: "This is a description for Assignment \(i)",
                        published: true,
                        points_possible: points_possible?[i] ?? 100,
                        grading_type: grading_type)))
            sleep(1)
        }
        return assignments
    }

    public static func gradeAssignment(grade: String, course: DSCourse, assignment: DSAssignment, user: DSUser) {
        seeder.postGrade(courseId: course.id, assignmentId: assignment.id, userId: user.id, requestBody: .init(posted_grade: grade))
    }

    public static func gradeAssignments(grades: [String], course: DSCourse, assignments: [DSAssignment], user: DSUser) {
        for i in 0..<assignments.count {
            gradeAssignment(grade: grades[i], course: course, assignment: assignments[i], user: user)
            sleep(1)
        }
    }

    public static func excuseStudentFromAssignment(course: DSCourse, assignment: DSAssignment, user: DSUser) {
        seeder.postGrade(
            courseId: course.id,
            assignmentId: assignment.id,
            userId: user.id,
            requestBody: .init(excuse: true))
    }

    public static func createEnrollmentTerm(
        name: String = "Test Enrollment Term",
        startAt: Date = Date.now.addMonths(-1),
        endAt: Date = Date.now.addMonths(1)
    ) -> DSEnrollmentTerm {
        return seeder.createEnrollmentTerm(name: name, startAt: startAt, endAt: endAt)
    }

    public static func createGradingPeriodSet(
        title: String = "Test Grading Period",
        enrollmentTerms: [DSEnrollmentTerm]? = []
    ) -> DSGradingPeriodSet {
        return seeder.createGradingPeriodSet(title: title, enrollmentTerms: enrollmentTerms ?? [createEnrollmentTerm()])
    }

    public static func addGradingPeriod(
        gradingPeriodSet: DSGradingPeriodSet,
        title: String = "Test Grading Period",
        startDate: Date = Date.now.addDays(-1),
        endDate: Date = Date.now.addDays(1),
        closeDate: Date = Date.now.addDays(1)
    ) -> DSGradingPeriod {
        return seeder.addGradingPeriod(
            gradingPeriodSet: gradingPeriodSet,
            title: title,
            startDate: startDate,
            endDate: endDate,
            closeDate: closeDate
        )
    }

    @discardableResult
    public static func createTestGradingPeriods(enrollmentTerm: DSEnrollmentTerm) -> [DSGradingPeriod] {
        let gradingPeriodSet = createGradingPeriodSet(enrollmentTerms: [enrollmentTerm])
        let firstGP = addGradingPeriod(
            gradingPeriodSet: gradingPeriodSet,
            title: "First GP",
            startDate: Date.now,
            endDate: Date.now.addSeconds(120),
            closeDate: Date.now.addSeconds(120)
        )
        let secondGP = addGradingPeriod(
            gradingPeriodSet: gradingPeriodSet,
            title: "Second GP",
            startDate: Date.now.addSeconds(240),
            endDate: Date.now.addSeconds(360),
            closeDate: Date.now.addSeconds(360)
        )
        return [firstGP, secondGP]
    }
}
