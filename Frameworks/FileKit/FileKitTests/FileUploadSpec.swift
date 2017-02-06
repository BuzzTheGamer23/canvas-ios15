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
    
    

import SoAutomated
@testable import FileKit
import CoreData
import ReactiveSwift
import TooLegit
import AVFoundation
import SoPersistent
import Quick
import Nimble

class FileUploadSpec: QuickSpec {
    let session = User(credentials: .user4).session
    override func spec() {
        describe("FileUpload") {
            describe("begin") {
                it("through a series of requests creates a file") {
                    let data = try! Data(contentsOf: currentBundle.url(forResource: "testfile", withExtension: "txt")!)
                    let parentFolderID = "6782429"
                    let path = "/api/v1/users/\(parentFolderID)/files"

                    let context = try! self.session.filesManagedObjectContext()
                    let upload = FileUpload(inContext: context, backgroundSessionID: "unit test", path: path, data: data, name: "testfile.txt", contentType: nil, parentFolderID: parentFolderID, contextID: ContextID(id: parentFolderID, context: .user))
                    
                    let predicate = NSPredicate(format: "%K == %@", "backgroundSessionID", "unit test")
                    let observer = try! ManagedObjectObserver<FileUpload>(predicate: predicate, inContext: context)
                    var disposable: Disposable?

                    self.session.playback("upload-file") {
                        waitUntil(timeout: 5) { done in
                            disposable = observer.signal.observeResult { result in
                                expect(result.error).to(beNil())
                                if let upload = result.value?.1 {
                                    expect(upload.errorMessage).to(beNil())
                                    if upload.hasCompleted && upload.file != nil {
                                        done()
                                    }
                                }
                            }
                            upload.begin(inSession: self.session, inContext: context)
                        }
                    }

                    expect(upload.errorMessage).to(beNil())
                    expect(upload.file).toNot(beNil())
                    
                    disposable?.dispose()
                }
            }
        }
    }
}
