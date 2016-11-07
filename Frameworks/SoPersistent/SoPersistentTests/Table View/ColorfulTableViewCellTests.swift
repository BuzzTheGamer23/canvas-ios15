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
    
    

@testable import SoPersistent
import XCTest
import Nimble

class ColorfulTableViewCellTests: XCTestCase {
    let tableView = UITableView()

    override func setUp() {
        super.setUp()
    }

    func testItShouldHaveNilAccessibilityIdentifiersByDefault() {
        let vm = ColorfulViewModel(style: .Subtitle)
        ColorfulViewModel.tableViewDidLoad(tableView)

        let cell = vm.cellForTableView(tableView, indexPath: NSIndexPath(forRow: 0, inSection: 0))
        expect(cell.accessibilityIdentifier).to(beNil())
        expect(cell.textLabel!.accessibilityIdentifier).to(beNil())
        expect(cell.detailTextLabel!.accessibilityIdentifier).to(beNil())

        vm.accessoryView.value = UIView()
        expect(cell.accessoryView!.accessibilityIdentifier).to(beNil())

        vm.icon.value = .icon(.inbox)
        expect(cell.imageView!.accessibilityIdentifier).to(beNil())
    }

    func testItShouldSetAccessibilityIdentifiers() {
        let vm = ColorfulViewModel(style: .Subtitle)
        vm.accessoryView.value = UIView()
        vm.icon.value = .icon(.inbox)
        ColorfulViewModel.tableViewDidLoad(tableView)

        let row0 = vm.cellForTableView(tableView, indexPath: NSIndexPath(forRow: 0, inSection: 0))
        vm.accessibilityIdentifier.value = "course"
        expect(row0.textLabel!.accessibilityIdentifier) == "course_title_0_0"
        expect(row0.detailTextLabel!.accessibilityIdentifier) == "course_detail_0_0"
        expect(row0.accessoryView!.accessibilityIdentifier) == "course_accessory_image_0_0"
        expect(row0.imageView!.accessibilityIdentifier) == "course_icon_0_0"
        expect(row0.accessibilityIdentifier) == "course_cell_0_0"
        vm.accessibilityIdentifier.value = "event"
        expect(row0.textLabel!.accessibilityIdentifier) == "event_title_0_0"
        expect(row0.detailTextLabel!.accessibilityIdentifier) == "event_detail_0_0"
        expect(row0.accessoryView!.accessibilityIdentifier) == "event_accessory_image_0_0"
        expect(row0.imageView!.accessibilityIdentifier) == "event_icon_0_0"
        expect(row0.accessibilityIdentifier) == "event_cell_0_0"

        let row1Section1 = vm.cellForTableView(tableView, indexPath: NSIndexPath(forRow: 1, inSection: 1))
        vm.accessibilityIdentifier.value = "course"
        expect(row1Section1.textLabel!.accessibilityIdentifier) == "course_title_1_1"
        expect(row1Section1.detailTextLabel!.accessibilityIdentifier) == "course_detail_1_1"
        expect(row1Section1.accessoryView!.accessibilityIdentifier) == "course_accessory_image_1_1"
        expect(row1Section1.imageView!.accessibilityIdentifier) == "course_icon_1_1"
        expect(row1Section1.accessibilityIdentifier) == "course_cell_1_1"
        vm.accessibilityIdentifier.value = "event"
        expect(row1Section1.textLabel!.accessibilityIdentifier) == "event_title_1_1"
        expect(row1Section1.detailTextLabel!.accessibilityIdentifier) == "event_detail_1_1"
        expect(row1Section1.accessoryView!.accessibilityIdentifier) == "event_accessory_image_1_1"
        expect(row1Section1.imageView!.accessibilityIdentifier) == "event_icon_1_1"
        expect(row1Section1.accessibilityIdentifier) == "event_cell_1_1"
    }
}
