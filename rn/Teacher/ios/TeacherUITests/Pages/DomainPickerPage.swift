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

class DomainPickerPage {

    // MARK: Singleton

    static let sharedInstance = DomainPickerPage()
    private init() {}

    // MARK: Page Elements

    private let domainField = e.selectBy(id: "domainPickerTextField")
    private let connectButton = e.selectBy(label: "Search for domain.")

    // MARK: - Assertions

    func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
    
        grey_dismissKeyboard()
        domainField.assertExists()
    }

    func assertDomainField(contains string: String, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)

        domainField.assertExists() // wait for element to exist. TODO: handle this in dsl.swift
        domainField.assert(with: grey_text(string))
    }

    // MARK: UI Actions

    func enterDomain(_ domain: String, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)

        domainField.assertExists() // wait for element to exist. TODO: handle this in dsl.swift
        domainField.perform(grey_replaceText(domain))
    }

    func openDomain(_ domain: String, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)

        enterDomain(domain)
        connectButton.tap()
    }

    func clearDomain(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)

        domainField.assertExists() // wait for element to exist. TODO: handle this in dsl.swift
        domainField.perform(grey_replaceText(""))
    }
}
