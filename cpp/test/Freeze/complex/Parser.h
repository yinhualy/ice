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

#ifndef PARSER_H
#define PARSER_H

#include <Complex.h>

#ifdef _WIN32
#   include <io.h>
#   define isatty _isatty
#   define fileno _fileno
// '_isatty' : inconsistent dll linkage.  dllexport assumed.
#   pragma warning( disable : 4273 )
#endif

//
// Stuff for flex and bison
//

#define YYSTYPE Complex::NodePtr
#define YY_DECL int yylex(YYSTYPE* yylvalp)
YY_DECL;
int yyparse();

//
// I must set the initial stack depth to the maximum stack depth to
// disable bison stack resizing. The bison stack resizing routines use
// simple malloc/alloc/memcpy calls, which do not work for the
// YYSTYPE, since YYSTYPE is a C++ type, with constructor, destructor,
// assignment operator, etc.
//
#define YYMAXDEPTH  20000 // 20000 should suffice. Bison default is 10000 as maximum.
#define YYINITDEPTH YYMAXDEPTH // Initial depth is set to max depth, for the reasons described above.

//
// Newer bison versions allow to disable stack resizing by defining
// yyoverflow.
//
#define yyoverflow(a, b, c, d, e, f) yyerror(a)

//
// unput() isn't needed. This prevents the function being defined, and
// the resulting compiler warning.
//
#define YY_NO_UNPUT

class Parser
{
public:

    Parser();
    ~Parser();

    Complex::NodePtr parse(const std::string&, bool = false);

    void error(const char*);
    void error(const std::string&);

    void getInput(char*, int&, int);
    void setResult(const Complex::NodePtr&);

private:

    std::string _buf;
    Complex::NodePtr _result;
    int _errors;
};

extern Parser* parser; // Current parser for bison/flex

#endif
