//
//  Group+CollectionsTest.swift
//  Enrollments
//
//  Created by Egan Anderson on 6/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
@testable import EnrollmentKit
import TooLegit
import CoreData
import SoAutomated
import SoPersistent
import Nimble

class GroupCollectionsTests: XCTestCase {
    let session = Session.art
    var context: NSManagedObjectContext!
    
    lazy var studentContext: String->NSManagedObjectContext = { studentID in
        return try! self.session.enrollmentManagedObjectContext(studentID)
    }
    
    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
        }
    }
    
    // MARK: favoritesCollection
    
    func testGroup_favoritesCollection_includesGroupsWithIsFavoriteFlag() {
        let favorite = Group.build(inSession: session) { $0.isFavorite = true }
        let collection = try! Group.favoritesCollection(session)
        XCTAssert(collection.contains(favorite), "favoritesCollection includes groups with isFavorite flag")
    }
    
    func testGroup_favoritesCollection_excludesGroupsWithoutIsFavoriteFlag() {
        let nonFavorite = Group.build(inSession: session) { $0.isFavorite = false }
        let collection = try! Group.favoritesCollection(session)
        XCTAssertFalse(collection.contains(nonFavorite), "favoritesCollection excludes groups with isFavorite flag")
    }
    
    func testGroup_favoritesCollection_sortsByNameThenByID() {
        let first = Group.build(inSession: session) {
            $0.name = "A"
            $0.id = "1"
            $0.isFavorite = true
        }
        let second = Group.build(inSession: session) {
            $0.name = "B"
            $0.id = "2"
            $0.isFavorite = true
        }
        let third = Group.build(inSession: session) {
            $0.name = "B"
            $0.id = "3"
            $0.isFavorite = true
        }
        let collection = try! Group.favoritesCollection(session)
        XCTAssertEqual(collection[0, 0], first)
        XCTAssertEqual(collection[0, 1], second)
        XCTAssertEqual(collection[0, 2], third)
    }
    
    // MARK: refresher
    
    func testGroup_refresher_syncsGroups() {
        let refresher = try! Group.refresher(session)
        let count = Group.observeCount(inSession: session)
        expect {
            refresher.playback("refresh-all-groups", in: currentBundle, with: self.session)
        }.to(change({ count.currentCount }, from: 0, to: 2))
    }
    
    func testGroup_refresher_syncsFavoriteColors() {
        let group = Group.build(inSession: session) {
            $0.id = "24219"
            $0.color = nil
        }
        let refresher = try! Group.refresher(session)
        refresher.playback("refresh-all-groups", in: currentBundle, with: session)
        XCTAssertEqual("#555555", group.rawColor, "refresher syncs favorite colors")
    }
}
