//
//  Fixtures.swift
//  Discussions
//
//  Created by Nathan Armstrong on 5/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoAutomated

extension String: Fixture {
    public var name: String { return self }
    public var bundle: NSBundle { return NSBundle(forClass: DiscussionTopicTests.self) }
}
