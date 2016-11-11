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

/// A glorious shuffle method to shuffle all the things
public extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    public func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

public extension CollectionType {
    public func findFirst(test: (Generator.Element) throws -> Bool) rethrows -> Generator.Element? {
        for (_, element) in enumerate() {
            if try test(element) {
                return element
            }
        }
        return nil
    }

    public func any(test: ((Generator.Element) throws -> Bool)) rethrows -> Bool {
        return try findFirst(test) != nil
    }

    public func any() -> Bool {
        return any { _ in true }
    }
}

public extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    public mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
