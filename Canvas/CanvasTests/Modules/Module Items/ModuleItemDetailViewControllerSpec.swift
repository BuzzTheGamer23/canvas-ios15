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

@testable import Canvas
import Quick
import Nimble
import SoAutomated
import TechDebt
@testable import SoEdventurous
import Marshal

class ModuleItemDetailViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ModuleItemDetailViewController") {
            it("should have next and previous buttons") {
                let vc = try! ModuleItemDetailViewController(session: currentSession, courseID: "1", moduleID: "1", moduleItemID: "1", route: ignoreRouteAction)
                _ = vc.view

                let next = vc.nextButton
                expect(next.title) == "Next"
                expect(next.accessibilityIdentifier).toNot(beNil())

                let previous = vc.previousButton
                expect(previous.title) == "Previous"
                expect(previous.accessibilityIdentifier).toNot(beNil())
            }

            describe("embed") {
                var item: ModuleItem!
                var vc: ModuleItemDetailViewController!
                var route: NSURL!
                beforeEach {
                    class Embedded: UIViewController {
                        override func viewDidLoad() {
                            super.viewDidLoad()
                            navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Foo", style: .Plain, target: nil, action: nil)]
                        }
                    }
                    login()

                    route = currentSession.baseURL / "unit-test/module-item-detail-vc-embedded-vc"
                    Router.sharedRouter().addRoute(route.path!) { _ in Embedded() }
                    
                    item = ModuleItem.build {
                        $0.url = route.absoluteString
                    }

                    vc = try! ModuleItemDetailViewController(session: currentSession, courseID: item.courseID, moduleID: item.moduleID, moduleItemID: item.id, route: ignoreRouteAction)
                    _ = vc.view
                    waitUntil { done in
                        if vc.isViewLoaded() { done() }
                    }
                }

                afterEach {
                    Router.sharedRouter().removeRoute(route.path!)
                }

                it("should display the module item view controller") {
                    expect(vc.view.subviews.count).toEventually(equal(2)) // toolbar + embedded view
                    expect(vc.navigationItem.rightBarButtonItems?.count).toEventually(equal(1))
                    expect(vc.navigationItem.rightBarButtonItems![0].title) == "Foo"
                }

                it("should append mark done button") {
                    item.completionRequirement = .MarkDone
                    item.completed = false
                    expect(vc.navigationItem.rightBarButtonItems?.count).toEventually(equal(2))
                    expect(vc.navigationItem.rightBarButtonItems![0].title) == "Foo"
                    expect(vc.navigationItem.rightBarButtonItems![1].title) == "Mark as Done"
                    expect(vc.navigationItem.rightBarButtonItems![1].accessibilityIdentifier).toNot(beNil())
                }
            }
        }
    }
}
