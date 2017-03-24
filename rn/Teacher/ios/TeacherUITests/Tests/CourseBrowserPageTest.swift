//
//  CourseBrowserPageTest.swift
//  Teacher
//
//  Created by Taylor Wilson on 3/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import XCTest
import CanvasKeymaster

class CourseBrowserPageTest: XCTestCase {
  override func setUp() {
    super.setUp()
  }

  func testCourseBrowserPage_displaysEmptyList() {
    let teacher = Data.getNextTeacher(self)
    domainPickerPage.openDomain(teacher.domain)
    canvasLoginPage.logIn(teacher: teacher)
    CanvasKeymaster.the().resetKeymasterForTesting()
  }
}
