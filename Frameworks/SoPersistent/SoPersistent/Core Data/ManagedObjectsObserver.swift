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
import ReactiveCocoa
import Result

/** Allows you to track and lookup a set of objects from a FetchedCollection
 by some uniqueID
 */
public class ManagedObjectsObserver<M: NSManagedObject, ID: Hashable> {
    public let collection: FetchedCollection<M>
    private let idFunction: M->ID
    private var propertiesByID: [ID: MutableProperty<M?>] = [:]
    private let scheduler: ManagedObjectContextScheduler
    
    private var collectionUpdatesDisposable: Disposable?
    
    public init(context: NSManagedObjectContext, collection: FetchedCollection<M>, idFunction: M->ID) {
        self.collection = collection
        self.idFunction = idFunction
        self.scheduler = ManagedObjectContextScheduler(context: context)
        for m in collection {
            propertiesByID[idFunction(m)] = MutableProperty(m)
        }
        
        collectionUpdatesDisposable = collection
            .collectionUpdates
            .observeOn(scheduler)
            .observeNext { [weak self] updates in
                self?.processUpdates(updates)
            }.map(ScopedDisposable.init)
    }
    
    private func sendUpdate(for model: M?, withID id: ID) {
        if let property = propertiesByID[id] {
            property.value = model
        } else {
            let property = MutableProperty(model)
            propertiesByID[id] = property
        }
    }
    
    private func processUpdates(updates: [CollectionUpdate<M>]) {
        for update in updates {
            switch update {
            case .Updated(_, let m):
                sendUpdate(for: m, withID: idFunction(m))
            case .Inserted(_, let m):
                sendUpdate(for: m, withID: idFunction(m))
            case .Deleted(_, let m):
                sendUpdate(for: nil, withID: idFunction(m))
            default: break
            }
        }
        countProperty.value = collection.count
    }
    
    public func producer(id: ID) -> SignalProducer<M?, NoError> {
        return SignalProducer<ID, NoError>(value: id)
            .observeOn(scheduler)
            .flatMap(.Latest) { [weak self] (id: ID) -> SignalProducer<M?, NoError> in
                guard let me = self else { return .empty }
                if let property = me.propertiesByID[id] {
                    return property.producer
                } else {
                    let property = MutableProperty<M?>(nil)
                    me.propertiesByID[id] = property
                    return property.producer
                }
        }
    }
    
    public subscript(id: ID) -> M? {
        return propertiesByID[id]?.value
    }
    
    private let countProperty = MutableProperty<Int>(0)
    
    public var count: SignalProducer<Int, NoError> {
        return countProperty.producer.uniqueValues()
    }
}
