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
    
    

import Foundation
import CoreData


public class FetchedCollectionViewController<M: NSManagedObject>: CollectionViewController {
    
    private (set) public var collection: FetchedCollection<M>!
    
    public override init() {
        super.init()
    }
    
    public func prepare<VM: CollectionViewCellViewModel>(collection: FetchedCollection<M>, refresher: Refresher? = nil, viewModelFactory: M->VM) {
        self.collection = collection
        self.refresher = refresher
        dataSource = CollectionCollectionViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
    }
}
