// **********************************************************************
//
// Copyright (c) 2001
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

interface Intf1;
local interface Intf1;
local interface Intf1 { void op(); };

interface Intf2 { void op(); };
local interface Intf2;

local interface Intf3;
interface Intf3;
interface Intf3 { void op(); };

local interface Intf4 { void op(); };
interface Intf4;

interface Class1;
local interface Class1;
local interface Class1 { void op(); };

interface Class2 { void op(); };
local interface Class2;

local interface Class3;
interface Class3;
interface Class3 { void op(); };

local interface Class4 { void op(); };
interface Class4;
