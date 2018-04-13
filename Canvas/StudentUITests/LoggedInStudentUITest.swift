//
//  LoggedInStudentUITest.swift
//  StudentUITests
//
//  Created by Layne Moseley on 4/12/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import Foundation
import XCTest
import SoGrey
import EarlGrey
import CanvasCore
import SoSeedySwift
@testable import CanvasKeymaster

class StudentUITest: StudentUITestBase {
    var student: Soseedy_CanvasUser!
    var courses: [Soseedy_Course]!
    
    override func setUp() {
        super.setUp()
        
        self.courses = [SoSeedySwift.createCourse(), SoSeedySwift.createCourse()]
        self.student = SoSeedySwift.createStudent(inAll: self.courses)
        SoSeedySwift.favorite(self.courses.first!, as: self.student)
        let loginInfo = SoSeedySwift.getNativeLoginInfo(self.student)
        NativeLoginManager.shared().injectLoginInformation(loginInfo) 
    }
}
