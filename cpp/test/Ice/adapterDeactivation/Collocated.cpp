// **********************************************************************
//
// Copyright (c) 2002
// ZeroC, Inc.
// Billerica, MA, USA
//
// All Rights Reserved.
//
// Ice is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License version 2 as published by
// the Free Software Foundation.
//
// **********************************************************************

#include <Ice/Application.h>
#include <ServantLocatorI.h>
#include <TestCommon.h>
#include <Test.h>

using namespace std;
using namespace Ice;

class TestServer : public Application
{
public:

    virtual int run(int, char*[]);
};

int
main(int argc, char* argv[])
{
    TestServer app;
    return app.main(argc, argv);
}

int
TestServer::run(int argc, char* argv[])
{
    communicator()->getProperties()->setProperty("TestAdapter.Endpoints", "default -p 12345 -t 2000");
    Ice::ObjectAdapterPtr adapter = communicator()->createObjectAdapter("TestAdapter");
    ServantLocatorPtr locator = new ServantLocatorI;
    adapter->addServantLocator(locator, "");

    TestPrx allTests(const CommunicatorPtr&);
    TestPrx obj = allTests(communicator());

    cout << "testing whether server is gone... " << flush;
    try
    {
	obj->ice_ping();
	test(false);
    }
    catch(const LocalException&)
    {
	cout << "ok" << endl;
    }

    adapter->waitForDeactivate();
    return EXIT_SUCCESS;
}
