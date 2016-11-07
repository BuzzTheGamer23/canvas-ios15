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
import Marshal
import SoLazy

public final class User: NSManagedObject {
    @NSManaged private (set) public var id: String
    @NSManaged private (set) public var loginID: String?
    @NSManaged private (set) public var name: String
    @NSManaged private (set) public var sortableName: String
    @NSManaged private (set) public var email: String?
    @NSManaged private (set) public var avatarURL: NSURL?
    @NSManaged private (set) public var obverveeID: String?
}

extension User: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("id")
        name            = try json <| "name"
        loginID         = try json <| "login_id"
        sortableName    = try json <| "sortable_name"
        email           = try json <| "primary_email"

        let avatarURLString: String? = try json <| "avatar_url"
        if let urlString = avatarURLString {
            avatarURL   = NSURL(string: urlString)
        }
    }
}
