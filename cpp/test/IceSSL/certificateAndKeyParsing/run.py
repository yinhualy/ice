#!/usr/bin/env python
# **********************************************************************
#
# Copyright (c) 2001
# ZeroC, Inc.
# Billerica, MA, USA
#
# All Rights Reserved.
#
# Ice is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License version 2 as published by
# the Free Software Foundation.
#
# **********************************************************************

import os, sys

for toplevel in [".", "..", "../..", "../../..", "../../../.."]:
    toplevel = os.path.normpath(toplevel)
    if os.path.exists(os.path.join(toplevel, "config", "TestUtil.py")):
        break
else:
    raise "can't find toplevel directory!"

sys.path.append(os.path.join(toplevel, "config"))
import TestUtil

if TestUtil.protocol != "ssl" :
    print "This test may only be run with SSL enabled."
    sys.exit(0)

testOptions = " --IceSSL.Test.Client.CertPath=TOPLEVELDIR/test/IceSSL/certs" + \
              " --IceSSL.Server.CertPath=TOPLEVELDIR/test/IceSSL/certs" + \
              " --IceSSL.Server.Config= " + \
              " --IceSSL.Client.CertPath=TOPLEVELDIR/test/IceSSL/certs" + \
              " --IceSSL.Client.Config= "

testdir = os.path.join(toplevel,"test", "IceSSL", "certificateAndKeyParsing")
client = os.path.join(testdir, "certificateAndKeyParsing")

localClientOptions = TestUtil.clientServerProtocol + TestUtil.defaultHost
updatedOptions = localClientOptions.replace("TOPLEVELDIR", toplevel)
testOptions = testOptions.replace("TOPLEVELDIR", toplevel)
print "starting certificateAndKeyParsing...",
clientPipe = os.popen(client + updatedOptions + testOptions)
print "ok"

for output in clientPipe.xreadlines():
    print output,
    
clientStatus = clientPipe.close()

if clientStatus:
    sys.exit(1)

sys.exit(0)
