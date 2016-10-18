//
//  Course+CollectionsTests.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
@testable import EnrollmentKit
import TooLegit
import CoreData
import SoAutomated
import SoPersistent
import Nimble

class CourseCollectionsTests: UnitTestCase {
    let session = Session.nas
    var context: NSManagedObjectContext!

    lazy var studentContext: String->NSManagedObjectContext = { studentID in
        var context: NSManagedObjectContext!
        attempt {
            context = try self.session.enrollmentManagedObjectContext(studentID)
        }
        return context
    }

    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
        }
    }

    // MARK: allCoursesCollection

    func testCourse_allCoursesCollection_sortsByNameThenByID() {
        let first = Course.build(inSession: session) { $0.name = "A"; $0.id = "1" }
        let second = Course.build(inSession: session) { $0.name = "B"; $0.id = "2" }
        let third = Course.build(inSession: session) { $0.name = "C"; $0.id = "3" }

        attempt {
            let collection = try Course.allCoursesCollection(session)
            XCTAssertEqual(collection[0,0], first)
            XCTAssertEqual(collection[0,1], second)
            XCTAssertEqual(collection[0,2], third)
        }
    }

    // MARK: favoritesCollection

    func testCourse_favoritesCollection_includesCoursesWithIsFavoriteFlag() {
        let favorite = Course.build(inSession: session) { $0.isFavorite = true }
        attempt {
            let collection = try Course.favoritesCollection(session)
            XCTAssert(collection.contains(favorite), "favoritesCollection includes courses with isFavorite flag")
        }
    }

    func testCourse_favoritesCollection_excludesCoursesWithoutIsFavoriteFlag() {
        let nonFavorite = Course.build(inSession: session) { $0.isFavorite = false }
        attempt {
            let collection = try Course.favoritesCollection(session)
            XCTAssertFalse(collection.contains(nonFavorite), "favoritesCollection excludes courses with isFavorite flag")
        }
    }

    func testCourse_favoritesCollection_sortsByNameThenByID() {
        let first = Course.build(inSession: session) { $0.name = "A"; $0.id = "1"; $0.isFavorite = true }
        let second = Course.build(inSession: session) { $0.name = "B"; $0.id = "2"; $0.isFavorite = true }
        let third = Course.build(inSession: session) { $0.name = "B"; $0.id = "3"; $0.isFavorite = true }
        attempt {
            let collection = try Course.favoritesCollection(session)
            XCTAssertEqual(collection[0,0], first)
            XCTAssertEqual(collection[0,1], second)
            XCTAssertEqual(collection[0,2], third)
        }
    }

    // MARK: collectionByStudent

    func testCourse_collectionByStudent_includesCoursesInStudentContext() {
        let course = Course.build(inSession: session, options: ["scope": "1"])
        attempt {
            let collection = try Course.collectionByStudent(session, studentID: "1")
            XCTAssert(collection.contains(course), "collectionByStudent includes courses in student context")
        }
    }

    func testCourse_collectionByStudent_excludesCoursesNotInStudentContext() {
        let course = Course.build(inSession: session)
        let other = Course.build(inSession: session, options: ["scope": "2"])
        attempt {
            let collection = try Course.collectionByStudent(session, studentID: "1")
            XCTAssertFalse(collection.contains(course), "collectionByStudent excludes courses in regular context")
            XCTAssertFalse(collection.contains(other), "collectionByStudent excludes courses in other student contexts")
        }
    }

    func testCourse_collectionByStudent_sortsByNameThenByID() {
        let first = Course.build(inSession: session, options: ["scope": "1"]) { $0.name = "A"; $0.id = "1" }
        let second = Course.build(inSession: session, options: ["scope": "1"]) { $0.name = "B"; $0.id = "2" }
        let third = Course.build(inSession: session, options: ["scope": "1"]) { $0.name = "B"; $0.id = "3" }
        attempt {
            let collection = try Course.collectionByStudent(session, studentID: "1")
            XCTAssertEqual(collection[0,0], first)
            XCTAssertEqual(collection[0,1], second)
            XCTAssertEqual(collection[0,2], third)
        }
    }

    // MARK: refresher

    func testCourse_refresher_syncsCourses() {
        attempt {
            let refresher = try Course.refresher(session)
            let count = Course.observeCount(inSession: session)
            expect {
                refresher.playback("refresh-all-courses", in: currentBundle, with: self.session)
            }.to(change({ count.currentCount }, from: 0, to: 3))
        }
    }

    func testCourse_refresher_syncsFavoriteColors() {
        attempt {
            let course = Course.build(inSession: session) { $0.id = "24219"; $0.color = nil }
            try context.save()
            let refresher = try Course.refresher(session)
            refresher.playback("refresh-all-courses", in: currentBundle, with: session)
            XCTAssertEqual("#009688", course.rawColor, "refresher syncs favorite colors")
        }
    }
}

class CourseTableViewControllerTests: UnitTestCase {
    let session = Session.nas
    let tvc = Course.TableViewController()
    let viewModelFactory = ViewModelFactory<Course>.new { _ in UITableViewCell() }

    func testTableViewController_prepare_setsCollection() {
        attempt {
            let collection = try Course.allCoursesCollection(session)
            tvc.prepare(collection, viewModelFactory: viewModelFactory)
            XCTAssertEqual(collection, tvc.collection, "prepare sets the collection")
        }
    }

    func testTableViewController_prepare_setsRefresher() {
        attempt {
            let collection = try Course.allCoursesCollection(session)
            let refresher = try Course.refresher(session)
            tvc.prepare(collection, refresher: refresher, viewModelFactory: viewModelFactory)
            XCTAssertNotNil(tvc.refresher, "prepare sets the refresher")
        }
    }

    func testTableViewController_prepare_setsDataSource() {
        attempt {
            let collection = try Course.allCoursesCollection(session)
            tvc.prepare(collection, viewModelFactory: viewModelFactory)
            XCTAssertNotNil(tvc.dataSource, "prepare sets the data source")
        }
    }
}
