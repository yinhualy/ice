//
// Copyright (c) ZeroC, Inc. All rights reserved.
//

import Ice
import TestCommon

class Client: TestHelperI {
    public override func run(args: [String]) throws {
        let communicator = try initialize(args)
        defer {
            communicator.destroy()
        }
        try allTests(self)
    }
}
