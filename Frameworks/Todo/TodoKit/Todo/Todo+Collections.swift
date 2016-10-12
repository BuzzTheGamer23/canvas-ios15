//
//  Todo+Collections.swift
//  Todo
//
//  Created by Brandon Pluim on 4/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

// ---------------------------------------------
// MARK: - Calendar Events collection for current user
// ---------------------------------------------
extension Todo {

    public static func allTodos(session: Session) throws -> FetchedCollection<Todo> {
        let predicate = NSPredicate(format: "%K == false", "done")
        let frc = Todo.fetchedResults(predicate, sortDescriptors: ["assignmentDueDate".ascending, "assignmentName".ascending], sectionNameKeypath: nil, inContext: try session.todosManagedObjectContext())
        return try FetchedCollection(frc: frc)
    }

    public static func refresher(session: Session) throws -> Refresher {
        let remote = try Todo.getTodos(session)
        let context = try session.todosManagedObjectContext()
        let sync = Todo.syncSignalProducer(inContext: context, fetchRemote: remote)
        let key = cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<Todo>
}
