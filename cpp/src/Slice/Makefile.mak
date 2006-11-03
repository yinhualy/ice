# **********************************************************************
#
# Copyright (c) 2003-2006 ZeroC, Inc. All rights reserved.
#
# This copy of Ice is licensed to you under the terms described in the
# ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ..\..

LIBNAME		= $(top_srcdir)\lib\slice$(LIBSUFFIX).lib
DLLNAME		= $(top_srcdir)\bin\slice$(SOVERSION)$(LIBSUFFIX).dll

TARGETS		= $(LIBNAME) $(DLLNAME)

OBJS		= Scanner.obj \
		  Grammar.obj \
		  Parser.obj \
		  CPlusPlusUtil.obj \
		  CsUtil.obj \
		  VbUtil.obj \
		  JavaUtil.obj \
		  Preprocessor.obj \
		  Checksum.obj \
		  PythonUtil.obj \
		  DotNetNames.obj \
		  RubyUtil.obj

SRCS		= $(OBJS:.obj=.cpp)

!include $(top_srcdir)/config/Make.rules.mak

CPPFLAGS	= -I.. -Idummyinclude $(CPPFLAGS) -DSLICE_API_EXPORTS  -DWIN32_LEAN_AND_MEAN

!if "$(BORLAND_HOME)" == "" & "$(OPTIMIZE)" != "yes"
PDBFLAGS        = /pdb:$(DLLNAME:.dll=.pdb)
!endif

$(LIBNAME): $(DLLNAME)

$(DLLNAME): $(OBJS)
	$(LINK) $(LD_DLLFLAGS) $(PDBFLAGS) $(OBJS) $(PREOUT)$(DLLNAME) $(PRELIBS)$(BASELIBS)
	move $(DLLNAME:.dll=.lib) $(LIBNAME)

Scanner.cpp : Scanner.l
	flex Scanner.l
	del /q $@
	echo #include "IceUtil/Config.h" > Scanner.cpp
	type lex.yy.c >> Scanner.cpp
	del /q lex.yy.c

Grammar.cpp Grammar.h: Grammar.y
	del /q Grammar.h Grammar.cpp
	bison -dvt --name-prefix "slice_" Grammar.y
	move Grammar.tab.c Grammar.cpp
	move Grammar.tab.h Grammar.h
	del /q Grammar.output

clean::
	del /q Grammar.cpp Grammar.h
	del /q Scanner.cpp
	del /q $(DLLNAME:.dll=.*)

install:: all
	copy $(LIBNAME) $(install_libdir)
	copy $(DLLNAME) $(install_bindir)

!if "$(OPTIMIZE)" != "yes"

!if "$(BORLAND_HOME)" == ""

install:: all
	copy $(DLLNAME:.dll=.pdb) $(install_bindir)

!else

install:: all
	copy $(DLLNAME:.dll=.tds) $(install_bindir)

!endif

!endif

!include .depend
