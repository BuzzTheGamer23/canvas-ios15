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
import SoPersistent
import TooLegit
import ReactiveCocoa

extension Module {
    public static func predicate(forModulesIn courseID: String) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "courseID", courseID)
    }

    public static func predicate(withIDs ids: [String]) -> NSPredicate {
        return NSPredicate(format: "%K IN %@", "id", ids)
    }

    public static func collectionCacheKey(context: NSManagedObjectContext, courseID: String) -> String {
        return cacheKey(context, [courseID])
    }

    public static func collection<T>(session: Session, courseID: String, moduleIDs: [String]? = nil, titleForSectionTitle: String? -> String? = { _ in nil }) throws -> FetchedCollection<T> {
        let context = try session.soEdventurousManagedObjectContext()
        let pred = moduleIDs.flatMap { NSCompoundPredicate(andPredicateWithSubpredicates: [predicate(forModulesIn: courseID), predicate(withIDs: $0)]) } ?? predicate(forModulesIn: courseID)
        let frc = Module.fetchedResults(pred, sortDescriptors: ["position".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc, titleForSectionTitle: titleForSectionTitle)
    }

    public static func refresher(session: Session, courseID: String) throws -> Refresher {
        let context = try session.soEdventurousManagedObjectContext()
        let remote = try Module.getModules(session, courseID: courseID)
        let sync = Module.syncSignalProducer(inContext: context, fetchRemote: remote)
        let key = collectionCacheKey(context, courseID: courseID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<Module>
}
