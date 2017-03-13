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

import Quick
import Nimble
import SoLazy
import ReactiveSwift
import Result
import SoAutomated

class RACHelpersSpec: QuickSpec {
    override func spec() {
        describe("accumulate") {
            it("should gather all next values into a single array") {
                let property = MutableProperty<Int>(0)
                let values = TestObserver<[Int], NoError>()
                property.signal.accumulate().observe(values.observer)

                property.value = 1
                values.assertValues([[1]])

                property.value = 2
                property.value = 3
                values.assertValues([[1], [1,2], [1,2,3]])
            }
        }
    }
}
