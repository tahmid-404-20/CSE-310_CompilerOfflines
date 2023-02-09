/* original parser id follows */
/* yysccsid[] = "@(#)yaccpar	1.9 (Berkeley) 02/21/93" */
/* (use YYMAJOR/YYMINOR for ifdefs dependent on parser version) */

#define YYBYACC 1
#define YYMAJOR 2
#define YYMINOR 0
#define YYPATCH 20221106

#define YYEMPTY        (-1)
#define yyclearin      (yychar = YYEMPTY)
#define yyerrok        (yyerrflag = 0)
#define YYRECOVERING() (yyerrflag != 0)
#define YYENOMEM       (-2)
#define YYEOF          0
#undef YYBTYACC
#define YYBTYACC 0
#define YYDEBUGSTR YYPREFIX "debug"
#define YYPREFIX "yy"

#define YYPURE 0

#line 2 "1905002.y"
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "bits/stdc++.h"
#include "1905002_SymbolTable.cpp"
#include "1905002_parseTreeUtil.cpp"
/* #define YYSTYPE SymbolInfo**/

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int yylineno;
extern int error_count;
long lastSyntaxErrorLine;
int syntaxErrorCount = 0;


FILE *errorout,*logout,*ptout,*fp;

SymbolTable st;
SymbolInfo scopeParameters;
string funcReturnType;

SymbolInfo *compRef;

void yyerror(char *s)
{
	/*write your code*/
	lastSyntaxErrorLine = yylineno;
}

void insertFunctionDefinition(SymbolInfo *type_specifier, SymbolInfo *funcName,SymbolInfo *parameter_list = NULL) {

  bool isInserted = st.insert(funcName->getName(), type_specifier->getName());
  if (isInserted) {   /* first time definition without declaration*/
    SymbolInfo *func = st.lookUp(funcName->getName());
    func->setIsFunction(true);
    /* as it is declared, is declared set false*/
    func->setIsFunctionDeclared(false);
    /* return type fixed*/
    func->setTypeSpecifier(type_specifier->getTypeSpecifier());
	funcReturnType = type_specifier->getTypeSpecifier();
    if (parameter_list != NULL) {
      func->setParameters(parameter_list->getParameterList(), parameter_list->getParameterTypeList());
    }
  } else {
    SymbolInfo *lookUp = st.lookUp(funcName->getName());
    if (!lookUp->getIsFunction()) {
        fprintf(errorout, "Line# %d: '%s' redeclared as different kind of symbol\n", funcName->getStartLine(), funcName->getName().c_str());
		syntaxErrorCount++;
    } else if(lookUp->getIsFunctionDeclared()){  /* declared but not defined yet, so this is probably the definition part*/
			if(type_specifier->getTypeSpecifier() != lookUp->getTypeSpecifier()) {
				fprintf(errorout, "Line# %d: Conflicting types for '%s'\n", type_specifier->getStartLine(), funcName->getName().c_str());
				syntaxErrorCount++;
			} else if((parameter_list == NULL && lookUp->getParameterList().size() != 0) || (parameter_list != NULL && lookUp->getParameterList().size() != parameter_list->getParameterList().size())) {
				fprintf(errorout, "Line# %d: Conflicting types for '%s'\n", funcName->getStartLine(), funcName->getName().c_str());
				syntaxErrorCount++;
			} else {
				bool isOkay = true;
				/* check for parameter type mismatch*/
				if(parameter_list != NULL) {
					vector<string> parameterTypeList = parameter_list->getParameterTypeList();
					vector<string> lookUpParameterTypeList = lookUp->getParameterTypeList();
					for(int i = 0; i < parameterTypeList.size(); i++) {
						if(parameterTypeList[i] != lookUpParameterTypeList[i] || lookUpParameterTypeList[i] == "VOID" || lookUpParameterTypeList[i] == "error" || parameterTypeList[i] == "error") {
							isOkay = false;
							break;
						}
					}
				}

				if(!isOkay) {
					fprintf(errorout, "Line# %d: Type of arguments in declaration and definition mismatch \n", funcName->getStartLine());
					syntaxErrorCount++;
				} else {
					/* everything is okay, so set declared to false*/
					lookUp->setIsFunctionDeclared(false);
					funcReturnType = type_specifier->getTypeSpecifier();
				}
			}
	} else {  /* declared and defined before*/
		fprintf(errorout, "Line# %d: Conflicting types for '%s'\n", funcName->getStartLine(), funcName->getName().c_str());
		syntaxErrorCount++;
	}
  }
}



string castType(SymbolInfo* leftSymbol,SymbolInfo* rightSymbol){
	string leftType = leftSymbol->getTypeSpecifier();
	string rightType = rightSymbol->getTypeSpecifier();
	if( leftType == "VOID" || rightType == "VOID" ) return "VOID";
	if( leftType == "error" || rightType == "error" ) return "error";
	if( leftType == "FLOAT" || rightType == "FLOAT" ) return "FLOAT";
	return "INT";
}


#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#line 106 "1905002.y"
typedef union YYSTYPE{
    SymbolInfo* symbolInfo; 
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
#line 138 "y.tab.c"

/* compatibility with bison */
#ifdef YYPARSE_PARAM
/* compatibility with FreeBSD */
# ifdef YYPARSE_PARAM_TYPE
#  define YYPARSE_DECL() yyparse(YYPARSE_PARAM_TYPE YYPARSE_PARAM)
# else
#  define YYPARSE_DECL() yyparse(void *YYPARSE_PARAM)
# endif
#else
# define YYPARSE_DECL() yyparse(void)
#endif

/* Parameters sent to lex. */
#ifdef YYLEX_PARAM
# define YYLEX_DECL() yylex(void *YYLEX_PARAM)
# define YYLEX yylex(YYLEX_PARAM)
#else
# define YYLEX_DECL() yylex(void)
# define YYLEX yylex()
#endif

#if !(defined(yylex) || defined(YYSTATE))
int YYLEX_DECL();
#endif

/* Parameters sent to yyerror. */
#ifndef YYERROR_DECL
#define YYERROR_DECL() yyerror(const char *s)
#endif
#ifndef YYERROR_CALL
#define YYERROR_CALL(msg) yyerror(msg)
#endif

#ifndef YYDESTRUCT_DECL
#define YYDESTRUCT_DECL() yydestruct(const char *msg, int psymb, YYSTYPE *val)
#endif
#ifndef YYDESTRUCT_CALL
#define YYDESTRUCT_CALL(msg, psymb, val) yydestruct(msg, psymb, val)
#endif

extern int YYPARSE_DECL();

#define IF 257
#define ELSE 258
#define FOR 259
#define WHILE 260
#define DO 261
#define BREAK 262
#define INT 263
#define CHAR 264
#define FLOAT 265
#define DOUBLE 266
#define VOID 267
#define RETURN 268
#define SWITCH 269
#define CASE 270
#define DEFAULT 271
#define CONTINUE 272
#define CONST_INT 273
#define CONST_FLOAT 274
#define CONST_CHAR 275
#define ID 276
#define NOT 277
#define LOGICOP 278
#define RELOP 279
#define ADDOP 280
#define MULOP 281
#define INCOP 282
#define DECOP 283
#define ASSIGNOP 284
#define LPAREN 285
#define RPAREN 286
#define LCURL 287
#define RCURL 288
#define LSQUARE 289
#define RSQUARE 290
#define COMMA 291
#define SEMICOLON 292
#define BITOP 293
#define SINGLE_LINE_STRING 294
#define MULTI_LINE_STRING 295
#define LOWER_THAN_ELSE 296
#define PRINTLN 297
#define YYERRCODE 256
typedef int YYINT;
static const YYINT yylhs[] = {                           -1,
    0,    1,    1,    2,    2,    2,    3,    3,   24,    4,
   25,    4,    4,    5,    5,    5,    5,    6,    6,    7,
    7,    8,    8,    8,    9,    9,    9,    9,   10,   10,
   11,   11,   11,   11,   11,   11,   11,   11,   11,   12,
   12,   12,   13,   13,   14,   14,   15,   15,   16,   16,
   17,   17,   18,   18,   19,   19,   19,   20,   20,   20,
   20,   20,   20,   20,   21,   21,   22,   22,   23,
};
static const YYINT yylen[] = {                            2,
    1,    2,    1,    1,    1,    1,    6,    5,    0,    7,
    0,    6,    6,    4,    3,    2,    1,    3,    2,    3,
    3,    1,    1,    1,    3,    6,    1,    4,    1,    2,
    1,    1,    1,    7,    5,    7,    5,    5,    3,    1,
    2,    2,    1,    4,    1,    3,    1,    3,    1,    3,
    1,    3,    1,    3,    2,    2,    1,    1,    4,    3,
    1,    1,    2,    2,    1,    0,    3,    1,    1,
};
static const YYINT yydefred[] = {                         0,
   22,   23,   24,    0,    0,    3,    5,    6,    4,    0,
    2,    0,    0,    0,   21,    0,    0,    0,   20,    0,
    0,    0,    0,    0,    0,    0,    8,    0,    0,    0,
   16,   28,    0,   69,   13,    0,   12,    7,    0,    0,
    0,    0,    0,    0,    0,    0,   61,   62,    0,    0,
    0,    0,   19,   40,    0,   33,   31,    0,    0,   29,
   32,    0,    0,   45,    0,    0,    0,   53,   57,   10,
   14,   26,   42,    0,    0,    0,    0,    0,    0,    0,
   56,   55,    0,    0,    0,   18,   30,   63,   64,    0,
   41,    0,    0,    0,    0,    0,    0,    0,   39,   68,
    0,    0,    0,   60,    0,   46,   48,    0,    0,   54,
    0,    0,    0,   59,    0,   44,    0,    0,    0,   37,
   67,   38,    0,    0,   36,   34,
};
#if defined(YYDESTRUCT_CALL) || defined(YYSTYPE_TOSTRING)
static const YYINT yystos[] = {                           0,
  263,  265,  267,  299,  300,  301,  302,  303,  306,  307,
  301,  256,  276,  308,  292,  285,  289,  291,  292,  256,
  286,  304,  307,  273,  276,  286,  292,  324,  286,  291,
  276,  290,  289,  287,  305,  322,  305,  292,  323,  307,
  273,  256,  257,  259,  260,  268,  273,  274,  276,  277,
  280,  285,  288,  292,  297,  305,  306,  307,  309,  310,
  311,  312,  313,  314,  315,  316,  317,  318,  319,  305,
  276,  290,  292,  285,  285,  285,  313,  285,  289,  312,
  318,  318,  313,  285,  276,  288,  310,  282,  283,  284,
  292,  278,  279,  280,  281,  313,  311,  313,  292,  314,
  320,  321,  313,  286,  276,  314,  315,  316,  317,  318,
  286,  311,  286,  286,  291,  290,  286,  310,  313,  310,
  314,  292,  258,  286,  310,  310,
};
#endif /* YYDESTRUCT_CALL || YYSTYPE_TOSTRING */
static const YYINT yydgoto[] = {                          4,
    5,    6,    7,    8,   22,   56,   57,   58,   14,   59,
   60,   61,   62,   63,   64,   65,   66,   67,   68,   69,
  101,  102,   36,   39,   28,
};
static const YYINT yysindex[] = {                      -159,
    0,    0,    0,    0, -159,    0,    0,    0,    0, -244,
    0, -281, -212, -176,    0, -247, -254, -255,    0, -259,
 -263, -269, -241, -239, -248, -227,    0, -227, -213, -159,
    0,    0, -189,    0,    0, -185,    0,    0, -227, -180,
 -181, -191, -167, -165, -162,    8,    0,    0, -195,    8,
    8,    8,    0,    0, -156,    0,    0, -242, -146,    0,
    0, -139, -187,    0, -145, -132, -141,    0,    0,    0,
    0,    0,    0,    8,  -42,    8, -157,    8,    8, -128,
    0,    0, -129, -117, -121,    0,    0,    0,    0,    8,
    0,    8,    8,    8,    8, -124,  -42, -114,    0,    0,
 -112, -105, -111,    0, -102,    0,    0,  -93, -141,    0,
  -68,    8,  -68,    0,    8,    0,  -99,  -64,  -90,    0,
    0,    0,  -68,  -68,    0,    0,
};
static const YYINT yyrindex[] = {                         0,
    0,    0,    0,    0,  201,    0,    0,    0,    0,    0,
    0,    0, -127,    0,    0,    0,    0,    0,    0,    0,
  -80,    0, -249,    0, -109,    0,    0,    0,  -76,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0, -210,
    0,    0,    0,    0,    0,    0,    0,    0,  -27,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0, -225,    0,    0,  -88, -228, -193,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  -71,    0,  -12,
    0,    0,    0,    0, -127,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  -70,    0,    0,    0,    0,    0, -115, -154,    0,
    0,    0,    0,    0,    0,    0,    0, -107,    0,    0,
    0,    0,    0,    0,    0,    0,
};
#if YYBTYACC
static const YYINT yycindex[] = {                         0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,
};
#endif
static const YYINT yygindex[] = {                         0,
    0,  205,    0,    0,    0,   -3,   44,   10,    0,    0,
  -54,  -73,  -47,  -46,  -77,  121,  125,  126,  -43,    0,
    0,    0,    0,    0,    0,
};
#define YYTABLESIZE 293
static const YYINT yytable[] = {                         77,
  100,   97,   80,   80,   87,   83,   81,   82,   20,   10,
   15,   12,  106,   12,   10,    1,   29,    2,   24,    3,
   25,   30,   35,  112,   37,   23,   26,   96,   27,   98,
   80,   13,  103,   85,   31,   70,   17,  121,   21,   40,
   33,   17,   80,    9,   80,   80,   80,   80,    9,   49,
   32,  110,   58,   58,   58,   58,  118,   49,  120,   34,
   58,   49,   49,   49,   58,  119,   58,   80,  125,  126,
   42,   43,   16,   44,   45,   15,   17,    1,   38,    2,
   15,    3,   46,   41,   51,   51,   51,   47,   48,   78,
   49,   50,   51,   79,   51,   71,   51,   51,   51,   52,
   73,   34,   53,    1,   91,    2,   54,    3,   72,   42,
   43,   55,   44,   45,   18,   19,    1,   74,    2,   75,
    3,   46,   76,   52,   52,   52,   47,   48,   84,   49,
   50,   52,   92,   51,   99,   52,   52,   52,   52,   95,
   34,   86,   88,   89,   90,   54,   93,   94,   35,   35,
   55,   35,   35,   88,   89,   35,  104,   35,  105,   35,
   35,  111,   50,   27,   27,   35,   35,   17,   35,   35,
   50,  113,   35,  114,   50,   50,   50,   35,  116,   35,
   35,   25,   25,  117,   35,  115,   94,   42,   43,   35,
   44,   45,  122,  123,    1,  124,    2,   47,    3,   46,
    1,   47,   47,   47,   47,   48,   11,   49,   50,   11,
    9,   51,  107,   42,   66,   65,   52,  108,   34,  109,
    0,    0,    0,   54,    0,    0,    0,    0,   55,    0,
   47,   48,    0,   49,   50,    0,    0,   51,    0,    0,
    0,    0,   52,    0,    0,    0,    0,    0,    0,   54,
   43,   43,   43,   43,   43,   43,   43,    0,   43,    0,
    0,    0,   43,   43,   43,   58,   58,   58,   58,    0,
    0,    0,    0,   58,    0,    0,    0,   58,   58,   58,
   47,   48,    0,   49,   50,    0,    0,   51,    0,    0,
    0,    0,   52,
};
static const YYINT yycheck[] = {                         46,
   78,   75,   50,   51,   59,   52,   50,   51,  256,    0,
  292,  256,   90,  256,    5,  263,  286,  265,  273,  267,
  276,  291,   26,   97,   28,   16,  286,   74,  292,   76,
   78,  276,   79,  276,  276,   39,  286,  115,  286,   30,
  289,  291,   90,    0,   92,   93,   94,   95,    5,  278,
  290,   95,  278,  279,  280,  281,  111,  286,  113,  287,
  286,  290,  291,  292,  290,  112,  292,  115,  123,  124,
  256,  257,  285,  259,  260,  286,  289,  263,  292,  265,
  291,  267,  268,  273,  278,  279,  280,  273,  274,  285,
  276,  277,  286,  289,  280,  276,  290,  291,  292,  285,
  292,  287,  288,  263,  292,  265,  292,  267,  290,  256,
  257,  297,  259,  260,  291,  292,  263,  285,  265,  285,
  267,  268,  285,  278,  279,  280,  273,  274,  285,  276,
  277,  286,  278,  280,  292,  290,  291,  292,  285,  281,
  287,  288,  282,  283,  284,  292,  279,  280,  256,  257,
  297,  259,  260,  282,  283,  263,  286,  265,  276,  267,
  268,  286,  278,  291,  292,  273,  274,  289,  276,  277,
  286,  286,  280,  286,  290,  291,  292,  285,  290,  287,
  288,  291,  292,  286,  292,  291,  280,  256,  257,  297,
  259,  260,  292,  258,  263,  286,  265,  286,  267,  268,
    0,  290,  291,  292,  273,  274,  287,  276,  277,    5,
  287,  280,   92,  256,  286,  286,  285,   93,  287,   94,
   -1,   -1,   -1,  292,   -1,   -1,   -1,   -1,  297,   -1,
  273,  274,   -1,  276,  277,   -1,   -1,  280,   -1,   -1,
   -1,   -1,  285,   -1,   -1,   -1,   -1,   -1,   -1,  292,
  278,  279,  280,  281,  282,  283,  284,   -1,  286,   -1,
   -1,   -1,  290,  291,  292,  278,  279,  280,  281,   -1,
   -1,   -1,   -1,  286,   -1,   -1,   -1,  290,  291,  292,
  273,  274,   -1,  276,  277,   -1,   -1,  280,   -1,   -1,
   -1,   -1,  285,
};
#if YYBTYACC
static const YYINT yyctable[] = {                        -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,
};
#endif
#define YYFINAL 4
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 297
#define YYUNDFTOKEN 325
#define YYTRANSLATE(a) ((a) > YYMAXTOKEN ? YYUNDFTOKEN : (a))
#if YYDEBUG
static const char *const yyname[] = {

"$end",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"error","IF","ELSE","FOR","WHILE","DO",
"BREAK","INT","CHAR","FLOAT","DOUBLE","VOID","RETURN","SWITCH","CASE","DEFAULT",
"CONTINUE","CONST_INT","CONST_FLOAT","CONST_CHAR","ID","NOT","LOGICOP","RELOP",
"ADDOP","MULOP","INCOP","DECOP","ASSIGNOP","LPAREN","RPAREN","LCURL","RCURL",
"LSQUARE","RSQUARE","COMMA","SEMICOLON","BITOP","SINGLE_LINE_STRING",
"MULTI_LINE_STRING","LOWER_THAN_ELSE","PRINTLN","$accept","start","program",
"unit","func_declaration","func_definition","parameter_list",
"compound_statement","var_declaration","type_specifier","declaration_list",
"statements","statement","expression_statement","variable","expression",
"logic_expression","rel_expression","simple_expression","term",
"unary_expression","factor","argument_list","arguments","LCURL_","$$1","$$2",
"illegal-symbol",
};
static const char *const yyrule[] = {
"$accept : start",
"start : program",
"program : program unit",
"program : unit",
"unit : var_declaration",
"unit : func_declaration",
"unit : func_definition",
"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",
"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON",
"$$1 :",
"func_definition : type_specifier ID LPAREN parameter_list RPAREN $$1 compound_statement",
"$$2 :",
"func_definition : type_specifier ID LPAREN RPAREN $$2 compound_statement",
"func_definition : type_specifier ID LPAREN error RPAREN compound_statement",
"parameter_list : parameter_list COMMA type_specifier ID",
"parameter_list : parameter_list COMMA type_specifier",
"parameter_list : type_specifier ID",
"parameter_list : type_specifier",
"compound_statement : LCURL_ statements RCURL",
"compound_statement : LCURL_ RCURL",
"var_declaration : type_specifier declaration_list SEMICOLON",
"var_declaration : type_specifier error SEMICOLON",
"type_specifier : INT",
"type_specifier : FLOAT",
"type_specifier : VOID",
"declaration_list : declaration_list COMMA ID",
"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE",
"declaration_list : ID",
"declaration_list : ID LSQUARE CONST_INT RSQUARE",
"statements : statement",
"statements : statements statement",
"statement : var_declaration",
"statement : expression_statement",
"statement : compound_statement",
"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",
"statement : IF LPAREN expression RPAREN statement",
"statement : IF LPAREN expression RPAREN statement ELSE statement",
"statement : WHILE LPAREN expression RPAREN statement",
"statement : PRINTLN LPAREN ID RPAREN SEMICOLON",
"statement : RETURN expression SEMICOLON",
"expression_statement : SEMICOLON",
"expression_statement : expression SEMICOLON",
"expression_statement : error SEMICOLON",
"variable : ID",
"variable : ID LSQUARE expression RSQUARE",
"expression : logic_expression",
"expression : variable ASSIGNOP logic_expression",
"logic_expression : rel_expression",
"logic_expression : rel_expression LOGICOP rel_expression",
"rel_expression : simple_expression",
"rel_expression : simple_expression RELOP simple_expression",
"simple_expression : term",
"simple_expression : simple_expression ADDOP term",
"term : unary_expression",
"term : term MULOP unary_expression",
"unary_expression : ADDOP unary_expression",
"unary_expression : NOT unary_expression",
"unary_expression : factor",
"factor : variable",
"factor : ID LPAREN argument_list RPAREN",
"factor : LPAREN expression RPAREN",
"factor : CONST_INT",
"factor : CONST_FLOAT",
"factor : variable INCOP",
"factor : variable DECOP",
"argument_list : arguments",
"argument_list :",
"arguments : arguments COMMA logic_expression",
"arguments : logic_expression",
"LCURL_ : LCURL",

};
#endif

#if YYDEBUG
int      yydebug;
#endif

int      yyerrflag;
int      yychar;
YYSTYPE  yyval;
YYSTYPE  yylval;
int      yynerrs;

#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
YYLTYPE  yyloc; /* position returned by actions */
YYLTYPE  yylloc; /* position from the lexer */
#endif

#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
#ifndef YYLLOC_DEFAULT
#define YYLLOC_DEFAULT(loc, rhs, n) \
do \
{ \
    if (n == 0) \
    { \
        (loc).first_line   = YYRHSLOC(rhs, 0).last_line; \
        (loc).first_column = YYRHSLOC(rhs, 0).last_column; \
        (loc).last_line    = YYRHSLOC(rhs, 0).last_line; \
        (loc).last_column  = YYRHSLOC(rhs, 0).last_column; \
    } \
    else \
    { \
        (loc).first_line   = YYRHSLOC(rhs, 1).first_line; \
        (loc).first_column = YYRHSLOC(rhs, 1).first_column; \
        (loc).last_line    = YYRHSLOC(rhs, n).last_line; \
        (loc).last_column  = YYRHSLOC(rhs, n).last_column; \
    } \
} while (0)
#endif /* YYLLOC_DEFAULT */
#endif /* defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED) */
#if YYBTYACC

#ifndef YYLVQUEUEGROWTH
#define YYLVQUEUEGROWTH 32
#endif
#endif /* YYBTYACC */

/* define the initial stack-sizes */
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH  YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 10000
#define YYMAXDEPTH  10000
#endif
#endif

#ifndef YYINITSTACKSIZE
#define YYINITSTACKSIZE 200
#endif

typedef struct {
    unsigned stacksize;
    YYINT    *s_base;
    YYINT    *s_mark;
    YYINT    *s_last;
    YYSTYPE  *l_base;
    YYSTYPE  *l_mark;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    YYLTYPE  *p_base;
    YYLTYPE  *p_mark;
#endif
} YYSTACKDATA;
#if YYBTYACC

struct YYParseState_s
{
    struct YYParseState_s *save;    /* Previously saved parser state */
    YYSTACKDATA            yystack; /* saved parser stack */
    int                    state;   /* saved parser state */
    int                    errflag; /* saved error recovery status */
    int                    lexeme;  /* saved index of the conflict lexeme in the lexical queue */
    YYINT                  ctry;    /* saved index in yyctable[] for this conflict */
};
typedef struct YYParseState_s YYParseState;
#endif /* YYBTYACC */
/* variables for the parser stack */
static YYSTACKDATA yystack;
#if YYBTYACC

/* Current parser state */
static YYParseState *yyps = 0;

/* yypath != NULL: do the full parse, starting at *yypath parser state. */
static YYParseState *yypath = 0;

/* Base of the lexical value queue */
static YYSTYPE *yylvals = 0;

/* Current position at lexical value queue */
static YYSTYPE *yylvp = 0;

/* End position of lexical value queue */
static YYSTYPE *yylve = 0;

/* The last allocated position at the lexical value queue */
static YYSTYPE *yylvlim = 0;

#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
/* Base of the lexical position queue */
static YYLTYPE *yylpsns = 0;

/* Current position at lexical position queue */
static YYLTYPE *yylpp = 0;

/* End position of lexical position queue */
static YYLTYPE *yylpe = 0;

/* The last allocated position at the lexical position queue */
static YYLTYPE *yylplim = 0;
#endif

/* Current position at lexical token queue */
static YYINT  *yylexp = 0;

static YYINT  *yylexemes = 0;
#endif /* YYBTYACC */
#line 1274 "1905002.y"
int main(int argc,char *argv[])
{

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	logout= fopen("1905002_log.txt","w");
	errorout = fopen("1905002_error.txt","w");
	ptout = fopen("1905002_parsetree.txt","w");	

	/* yylineno = 1; */
	yyin=fp;
	yyparse();
	
	fprintf(logout, "Total Lines: %d\n", yylineno);
	fprintf(logout, "Total Errors: %d\n", syntaxErrorCount + error_count);

	fclose(logout);
	fclose(errorout);
	fclose(ptout);
	
	// setting the global variable to NULL
	compRef = NULL;
	return 0;
}

#line 697 "y.tab.c"

/* Release memory associated with symbol. */
#if ! defined YYDESTRUCT_IS_DECLARED
static void
YYDESTRUCT_DECL()
{
    switch (psymb)
    {
	case 257:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 709 "y.tab.c"
	break;
	case 258:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 714 "y.tab.c"
	break;
	case 259:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 719 "y.tab.c"
	break;
	case 260:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 724 "y.tab.c"
	break;
	case 261:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 729 "y.tab.c"
	break;
	case 262:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 734 "y.tab.c"
	break;
	case 263:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 739 "y.tab.c"
	break;
	case 264:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 744 "y.tab.c"
	break;
	case 265:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 749 "y.tab.c"
	break;
	case 266:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 754 "y.tab.c"
	break;
	case 267:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 759 "y.tab.c"
	break;
	case 268:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 764 "y.tab.c"
	break;
	case 269:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 769 "y.tab.c"
	break;
	case 270:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 774 "y.tab.c"
	break;
	case 271:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 779 "y.tab.c"
	break;
	case 272:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 784 "y.tab.c"
	break;
	case 273:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 789 "y.tab.c"
	break;
	case 274:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 794 "y.tab.c"
	break;
	case 275:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 799 "y.tab.c"
	break;
	case 276:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 804 "y.tab.c"
	break;
	case 277:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 809 "y.tab.c"
	break;
	case 278:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 814 "y.tab.c"
	break;
	case 279:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 819 "y.tab.c"
	break;
	case 280:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 824 "y.tab.c"
	break;
	case 281:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 829 "y.tab.c"
	break;
	case 282:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 834 "y.tab.c"
	break;
	case 283:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 839 "y.tab.c"
	break;
	case 284:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 844 "y.tab.c"
	break;
	case 285:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 849 "y.tab.c"
	break;
	case 286:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 854 "y.tab.c"
	break;
	case 287:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 859 "y.tab.c"
	break;
	case 288:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 864 "y.tab.c"
	break;
	case 289:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 869 "y.tab.c"
	break;
	case 290:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 874 "y.tab.c"
	break;
	case 291:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 879 "y.tab.c"
	break;
	case 292:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 884 "y.tab.c"
	break;
	case 293:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 889 "y.tab.c"
	break;
	case 294:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 894 "y.tab.c"
	break;
	case 295:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 899 "y.tab.c"
	break;
	case 296:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 904 "y.tab.c"
	break;
	case 297:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 909 "y.tab.c"
	break;
	case 299:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 914 "y.tab.c"
	break;
	case 300:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 919 "y.tab.c"
	break;
	case 301:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 924 "y.tab.c"
	break;
	case 302:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 929 "y.tab.c"
	break;
	case 303:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 934 "y.tab.c"
	break;
	case 304:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 939 "y.tab.c"
	break;
	case 305:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 944 "y.tab.c"
	break;
	case 306:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 949 "y.tab.c"
	break;
	case 307:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 954 "y.tab.c"
	break;
	case 308:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 959 "y.tab.c"
	break;
	case 309:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 964 "y.tab.c"
	break;
	case 310:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 969 "y.tab.c"
	break;
	case 311:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 974 "y.tab.c"
	break;
	case 312:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 979 "y.tab.c"
	break;
	case 313:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 984 "y.tab.c"
	break;
	case 314:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 989 "y.tab.c"
	break;
	case 315:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 994 "y.tab.c"
	break;
	case 316:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 999 "y.tab.c"
	break;
	case 317:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 1004 "y.tab.c"
	break;
	case 318:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 1009 "y.tab.c"
	break;
	case 319:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 1014 "y.tab.c"
	break;
	case 320:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 1019 "y.tab.c"
	break;
	case 321:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 1024 "y.tab.c"
	break;
	case 322:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 1029 "y.tab.c"
	break;
	case 323:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 1034 "y.tab.c"
	break;
	case 324:
#line 114 "1905002.y"
	{ clearMemSyntaxTree((*val).symbolInfo);  }
#line 1039 "y.tab.c"
	break;
    }
}
#define YYDESTRUCT_IS_DECLARED 1
#endif

/* For use in generated program */
#define yydepth (int)(yystack.s_mark - yystack.s_base)
#if YYBTYACC
#define yytrial (yyps->save)
#endif /* YYBTYACC */

#if YYDEBUG
#include <stdio.h>	/* needed for printf */
#endif

#include <stdlib.h>	/* needed for malloc, etc */
#include <string.h>	/* needed for memset */

/* allocate initial stack or double stack size, up to YYMAXDEPTH */
static int yygrowstack(YYSTACKDATA *data)
{
    int i;
    unsigned newsize;
    YYINT *newss;
    YYSTYPE *newvs;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    YYLTYPE *newps;
#endif

    if ((newsize = data->stacksize) == 0)
        newsize = YYINITSTACKSIZE;
    else if (newsize >= YYMAXDEPTH)
        return YYENOMEM;
    else if ((newsize *= 2) > YYMAXDEPTH)
        newsize = YYMAXDEPTH;

    i = (int) (data->s_mark - data->s_base);
    newss = (YYINT *)realloc(data->s_base, newsize * sizeof(*newss));
    if (newss == 0)
        return YYENOMEM;

    data->s_base = newss;
    data->s_mark = newss + i;

    newvs = (YYSTYPE *)realloc(data->l_base, newsize * sizeof(*newvs));
    if (newvs == 0)
        return YYENOMEM;

    data->l_base = newvs;
    data->l_mark = newvs + i;

#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    newps = (YYLTYPE *)realloc(data->p_base, newsize * sizeof(*newps));
    if (newps == 0)
        return YYENOMEM;

    data->p_base = newps;
    data->p_mark = newps + i;
#endif

    data->stacksize = newsize;
    data->s_last = data->s_base + newsize - 1;

#if YYDEBUG
    if (yydebug)
        fprintf(stderr, "%sdebug: stack size increased to %d\n", YYPREFIX, newsize);
#endif
    return 0;
}

#if YYPURE || defined(YY_NO_LEAKS)
static void yyfreestack(YYSTACKDATA *data)
{
    free(data->s_base);
    free(data->l_base);
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    free(data->p_base);
#endif
    memset(data, 0, sizeof(*data));
}
#else
#define yyfreestack(data) /* nothing */
#endif /* YYPURE || defined(YY_NO_LEAKS) */
#if YYBTYACC

static YYParseState *
yyNewState(unsigned size)
{
    YYParseState *p = (YYParseState *) malloc(sizeof(YYParseState));
    if (p == NULL) return NULL;

    p->yystack.stacksize = size;
    if (size == 0)
    {
        p->yystack.s_base = NULL;
        p->yystack.l_base = NULL;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
        p->yystack.p_base = NULL;
#endif
        return p;
    }
    p->yystack.s_base    = (YYINT *) malloc(size * sizeof(YYINT));
    if (p->yystack.s_base == NULL) return NULL;
    p->yystack.l_base    = (YYSTYPE *) malloc(size * sizeof(YYSTYPE));
    if (p->yystack.l_base == NULL) return NULL;
    memset(p->yystack.l_base, 0, size * sizeof(YYSTYPE));
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    p->yystack.p_base    = (YYLTYPE *) malloc(size * sizeof(YYLTYPE));
    if (p->yystack.p_base == NULL) return NULL;
    memset(p->yystack.p_base, 0, size * sizeof(YYLTYPE));
#endif

    return p;
}

static void
yyFreeState(YYParseState *p)
{
    yyfreestack(&p->yystack);
    free(p);
}
#endif /* YYBTYACC */

#define YYABORT  goto yyabort
#define YYREJECT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR  goto yyerrlab
#if YYBTYACC
#define YYVALID        do { if (yyps->save)            goto yyvalid; } while(0)
#define YYVALID_NESTED do { if (yyps->save && \
                                yyps->save->save == 0) goto yyvalid; } while(0)
#endif /* YYBTYACC */

int
YYPARSE_DECL()
{
    int yym, yyn, yystate, yyresult;
#if YYBTYACC
    int yynewerrflag;
    YYParseState *yyerrctx = NULL;
#endif /* YYBTYACC */
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    YYLTYPE  yyerror_loc_range[3]; /* position of error start/end (0 unused) */
#endif
#if YYDEBUG
    const char *yys;

    if ((yys = getenv("YYDEBUG")) != 0)
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
    if (yydebug)
        fprintf(stderr, "%sdebug[<# of symbols on state stack>]\n", YYPREFIX);
#endif
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    memset(yyerror_loc_range, 0, sizeof(yyerror_loc_range));
#endif

#if YYBTYACC
    yyps = yyNewState(0); if (yyps == 0) goto yyenomem;
    yyps->save = 0;
#endif /* YYBTYACC */
    yym = 0;
    /* yyn is set below */
    yynerrs = 0;
    yyerrflag = 0;
    yychar = YYEMPTY;
    yystate = 0;

#if YYPURE
    memset(&yystack, 0, sizeof(yystack));
#endif

    if (yystack.s_base == NULL && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
    yystack.s_mark = yystack.s_base;
    yystack.l_mark = yystack.l_base;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    yystack.p_mark = yystack.p_base;
#endif
    yystate = 0;
    *yystack.s_mark = 0;

yyloop:
    if ((yyn = yydefred[yystate]) != 0) goto yyreduce;
    if (yychar < 0)
    {
#if YYBTYACC
        do {
        if (yylvp < yylve)
        {
            /* we're currently re-reading tokens */
            yylval = *yylvp++;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
            yylloc = *yylpp++;
#endif
            yychar = *yylexp++;
            break;
        }
        if (yyps->save)
        {
            /* in trial mode; save scanner results for future parse attempts */
            if (yylvp == yylvlim)
            {   /* Enlarge lexical value queue */
                size_t p = (size_t) (yylvp - yylvals);
                size_t s = (size_t) (yylvlim - yylvals);

                s += YYLVQUEUEGROWTH;
                if ((yylexemes = (YYINT *)realloc(yylexemes, s * sizeof(YYINT))) == NULL) goto yyenomem;
                if ((yylvals   = (YYSTYPE *)realloc(yylvals, s * sizeof(YYSTYPE))) == NULL) goto yyenomem;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                if ((yylpsns   = (YYLTYPE *)realloc(yylpsns, s * sizeof(YYLTYPE))) == NULL) goto yyenomem;
#endif
                yylvp   = yylve = yylvals + p;
                yylvlim = yylvals + s;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                yylpp   = yylpe = yylpsns + p;
                yylplim = yylpsns + s;
#endif
                yylexp  = yylexemes + p;
            }
            *yylexp = (YYINT) YYLEX;
            *yylvp++ = yylval;
            yylve++;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
            *yylpp++ = yylloc;
            yylpe++;
#endif
            yychar = *yylexp++;
            break;
        }
        /* normal operation, no conflict encountered */
#endif /* YYBTYACC */
        yychar = YYLEX;
#if YYBTYACC
        } while (0);
#endif /* YYBTYACC */
        if (yychar < 0) yychar = YYEOF;
#if YYDEBUG
        if (yydebug)
        {
            if ((yys = yyname[YYTRANSLATE(yychar)]) == NULL) yys = yyname[YYUNDFTOKEN];
            fprintf(stderr, "%s[%d]: state %d, reading token %d (%s)",
                            YYDEBUGSTR, yydepth, yystate, yychar, yys);
#ifdef YYSTYPE_TOSTRING
#if YYBTYACC
            if (!yytrial)
#endif /* YYBTYACC */
                fprintf(stderr, " <%s>", YYSTYPE_TOSTRING(yychar, yylval));
#endif
            fputc('\n', stderr);
        }
#endif
    }
#if YYBTYACC

    /* Do we have a conflict? */
    if (((yyn = yycindex[yystate]) != 0) && (yyn += yychar) >= 0 &&
        yyn <= YYTABLESIZE && yycheck[yyn] == (YYINT) yychar)
    {
        YYINT ctry;

        if (yypath)
        {
            YYParseState *save;
#if YYDEBUG
            if (yydebug)
                fprintf(stderr, "%s[%d]: CONFLICT in state %d: following successful trial parse\n",
                                YYDEBUGSTR, yydepth, yystate);
#endif
            /* Switch to the next conflict context */
            save = yypath;
            yypath = save->save;
            save->save = NULL;
            ctry = save->ctry;
            if (save->state != yystate) YYABORT;
            yyFreeState(save);

        }
        else
        {

            /* Unresolved conflict - start/continue trial parse */
            YYParseState *save;
#if YYDEBUG
            if (yydebug)
            {
                fprintf(stderr, "%s[%d]: CONFLICT in state %d. ", YYDEBUGSTR, yydepth, yystate);
                if (yyps->save)
                    fputs("ALREADY in conflict, continuing trial parse.\n", stderr);
                else
                    fputs("Starting trial parse.\n", stderr);
            }
#endif
            save                  = yyNewState((unsigned)(yystack.s_mark - yystack.s_base + 1));
            if (save == NULL) goto yyenomem;
            save->save            = yyps->save;
            save->state           = yystate;
            save->errflag         = yyerrflag;
            save->yystack.s_mark  = save->yystack.s_base + (yystack.s_mark - yystack.s_base);
            memcpy (save->yystack.s_base, yystack.s_base, (size_t) (yystack.s_mark - yystack.s_base + 1) * sizeof(YYINT));
            save->yystack.l_mark  = save->yystack.l_base + (yystack.l_mark - yystack.l_base);
            memcpy (save->yystack.l_base, yystack.l_base, (size_t) (yystack.l_mark - yystack.l_base + 1) * sizeof(YYSTYPE));
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
            save->yystack.p_mark  = save->yystack.p_base + (yystack.p_mark - yystack.p_base);
            memcpy (save->yystack.p_base, yystack.p_base, (size_t) (yystack.p_mark - yystack.p_base + 1) * sizeof(YYLTYPE));
#endif
            ctry                  = yytable[yyn];
            if (yyctable[ctry] == -1)
            {
#if YYDEBUG
                if (yydebug && yychar >= YYEOF)
                    fprintf(stderr, "%s[%d]: backtracking 1 token\n", YYDEBUGSTR, yydepth);
#endif
                ctry++;
            }
            save->ctry = ctry;
            if (yyps->save == NULL)
            {
                /* If this is a first conflict in the stack, start saving lexemes */
                if (!yylexemes)
                {
                    yylexemes = (YYINT *) malloc((YYLVQUEUEGROWTH) * sizeof(YYINT));
                    if (yylexemes == NULL) goto yyenomem;
                    yylvals   = (YYSTYPE *) malloc((YYLVQUEUEGROWTH) * sizeof(YYSTYPE));
                    if (yylvals == NULL) goto yyenomem;
                    yylvlim   = yylvals + YYLVQUEUEGROWTH;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                    yylpsns   = (YYLTYPE *) malloc((YYLVQUEUEGROWTH) * sizeof(YYLTYPE));
                    if (yylpsns == NULL) goto yyenomem;
                    yylplim   = yylpsns + YYLVQUEUEGROWTH;
#endif
                }
                if (yylvp == yylve)
                {
                    yylvp  = yylve = yylvals;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                    yylpp  = yylpe = yylpsns;
#endif
                    yylexp = yylexemes;
                    if (yychar >= YYEOF)
                    {
                        *yylve++ = yylval;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                        *yylpe++ = yylloc;
#endif
                        *yylexp  = (YYINT) yychar;
                        yychar   = YYEMPTY;
                    }
                }
            }
            if (yychar >= YYEOF)
            {
                yylvp--;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                yylpp--;
#endif
                yylexp--;
                yychar = YYEMPTY;
            }
            save->lexeme = (int) (yylvp - yylvals);
            yyps->save   = save;
        }
        if (yytable[yyn] == ctry)
        {
#if YYDEBUG
            if (yydebug)
                fprintf(stderr, "%s[%d]: state %d, shifting to state %d\n",
                                YYDEBUGSTR, yydepth, yystate, yyctable[ctry]);
#endif
            if (yychar < 0)
            {
                yylvp++;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                yylpp++;
#endif
                yylexp++;
            }
            if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
                goto yyoverflow;
            yystate = yyctable[ctry];
            *++yystack.s_mark = (YYINT) yystate;
            *++yystack.l_mark = yylval;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
            *++yystack.p_mark = yylloc;
#endif
            yychar  = YYEMPTY;
            if (yyerrflag > 0) --yyerrflag;
            goto yyloop;
        }
        else
        {
            yyn = yyctable[ctry];
            goto yyreduce;
        }
    } /* End of code dealing with conflicts */
#endif /* YYBTYACC */
    if (((yyn = yysindex[yystate]) != 0) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == (YYINT) yychar)
    {
#if YYDEBUG
        if (yydebug)
            fprintf(stderr, "%s[%d]: state %d, shifting to state %d\n",
                            YYDEBUGSTR, yydepth, yystate, yytable[yyn]);
#endif
        if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
        yystate = yytable[yyn];
        *++yystack.s_mark = yytable[yyn];
        *++yystack.l_mark = yylval;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
        *++yystack.p_mark = yylloc;
#endif
        yychar = YYEMPTY;
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if (((yyn = yyrindex[yystate]) != 0) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == (YYINT) yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag != 0) goto yyinrecovery;
#if YYBTYACC

    yynewerrflag = 1;
    goto yyerrhandler;
    goto yyerrlab; /* redundant goto avoids 'unused label' warning */

yyerrlab:
    /* explicit YYERROR from an action -- pop the rhs of the rule reduced
     * before looking for error recovery */
    yystack.s_mark -= yym;
    yystate = *yystack.s_mark;
    yystack.l_mark -= yym;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    yystack.p_mark -= yym;
#endif

    yynewerrflag = 0;
yyerrhandler:
    while (yyps->save)
    {
        int ctry;
        YYParseState *save = yyps->save;
#if YYDEBUG
        if (yydebug)
            fprintf(stderr, "%s[%d]: ERROR in state %d, CONFLICT BACKTRACKING to state %d, %d tokens\n",
                            YYDEBUGSTR, yydepth, yystate, yyps->save->state,
                    (int)(yylvp - yylvals - yyps->save->lexeme));
#endif
        /* Memorize most forward-looking error state in case it's really an error. */
        if (yyerrctx == NULL || yyerrctx->lexeme < yylvp - yylvals)
        {
            /* Free old saved error context state */
            if (yyerrctx) yyFreeState(yyerrctx);
            /* Create and fill out new saved error context state */
            yyerrctx                 = yyNewState((unsigned)(yystack.s_mark - yystack.s_base + 1));
            if (yyerrctx == NULL) goto yyenomem;
            yyerrctx->save           = yyps->save;
            yyerrctx->state          = yystate;
            yyerrctx->errflag        = yyerrflag;
            yyerrctx->yystack.s_mark = yyerrctx->yystack.s_base + (yystack.s_mark - yystack.s_base);
            memcpy (yyerrctx->yystack.s_base, yystack.s_base, (size_t) (yystack.s_mark - yystack.s_base + 1) * sizeof(YYINT));
            yyerrctx->yystack.l_mark = yyerrctx->yystack.l_base + (yystack.l_mark - yystack.l_base);
            memcpy (yyerrctx->yystack.l_base, yystack.l_base, (size_t) (yystack.l_mark - yystack.l_base + 1) * sizeof(YYSTYPE));
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
            yyerrctx->yystack.p_mark = yyerrctx->yystack.p_base + (yystack.p_mark - yystack.p_base);
            memcpy (yyerrctx->yystack.p_base, yystack.p_base, (size_t) (yystack.p_mark - yystack.p_base + 1) * sizeof(YYLTYPE));
#endif
            yyerrctx->lexeme         = (int) (yylvp - yylvals);
        }
        yylvp          = yylvals   + save->lexeme;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
        yylpp          = yylpsns   + save->lexeme;
#endif
        yylexp         = yylexemes + save->lexeme;
        yychar         = YYEMPTY;
        yystack.s_mark = yystack.s_base + (save->yystack.s_mark - save->yystack.s_base);
        memcpy (yystack.s_base, save->yystack.s_base, (size_t) (yystack.s_mark - yystack.s_base + 1) * sizeof(YYINT));
        yystack.l_mark = yystack.l_base + (save->yystack.l_mark - save->yystack.l_base);
        memcpy (yystack.l_base, save->yystack.l_base, (size_t) (yystack.l_mark - yystack.l_base + 1) * sizeof(YYSTYPE));
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
        yystack.p_mark = yystack.p_base + (save->yystack.p_mark - save->yystack.p_base);
        memcpy (yystack.p_base, save->yystack.p_base, (size_t) (yystack.p_mark - yystack.p_base + 1) * sizeof(YYLTYPE));
#endif
        ctry           = ++save->ctry;
        yystate        = save->state;
        /* We tried shift, try reduce now */
        if ((yyn = yyctable[ctry]) >= 0) goto yyreduce;
        yyps->save     = save->save;
        save->save     = NULL;
        yyFreeState(save);

        /* Nothing left on the stack -- error */
        if (!yyps->save)
        {
#if YYDEBUG
            if (yydebug)
                fprintf(stderr, "%sdebug[%d,trial]: trial parse FAILED, entering ERROR mode\n",
                                YYPREFIX, yydepth);
#endif
            /* Restore state as it was in the most forward-advanced error */
            yylvp          = yylvals   + yyerrctx->lexeme;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
            yylpp          = yylpsns   + yyerrctx->lexeme;
#endif
            yylexp         = yylexemes + yyerrctx->lexeme;
            yychar         = yylexp[-1];
            yylval         = yylvp[-1];
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
            yylloc         = yylpp[-1];
#endif
            yystack.s_mark = yystack.s_base + (yyerrctx->yystack.s_mark - yyerrctx->yystack.s_base);
            memcpy (yystack.s_base, yyerrctx->yystack.s_base, (size_t) (yystack.s_mark - yystack.s_base + 1) * sizeof(YYINT));
            yystack.l_mark = yystack.l_base + (yyerrctx->yystack.l_mark - yyerrctx->yystack.l_base);
            memcpy (yystack.l_base, yyerrctx->yystack.l_base, (size_t) (yystack.l_mark - yystack.l_base + 1) * sizeof(YYSTYPE));
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
            yystack.p_mark = yystack.p_base + (yyerrctx->yystack.p_mark - yyerrctx->yystack.p_base);
            memcpy (yystack.p_base, yyerrctx->yystack.p_base, (size_t) (yystack.p_mark - yystack.p_base + 1) * sizeof(YYLTYPE));
#endif
            yystate        = yyerrctx->state;
            yyFreeState(yyerrctx);
            yyerrctx       = NULL;
        }
        yynewerrflag = 1;
    }
    if (yynewerrflag == 0) goto yyinrecovery;
#endif /* YYBTYACC */

    YYERROR_CALL("syntax error");
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    yyerror_loc_range[1] = yylloc; /* lookahead position is error start position */
#endif

#if !YYBTYACC
    goto yyerrlab; /* redundant goto avoids 'unused label' warning */
yyerrlab:
#endif
    ++yynerrs;

yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if (((yyn = yysindex[*yystack.s_mark]) != 0) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == (YYINT) YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    fprintf(stderr, "%s[%d]: state %d, error recovery shifting to state %d\n",
                                    YYDEBUGSTR, yydepth, *yystack.s_mark, yytable[yyn]);
#endif
                if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
                yystate = yytable[yyn];
                *++yystack.s_mark = yytable[yyn];
                *++yystack.l_mark = yylval;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                /* lookahead position is error end position */
                yyerror_loc_range[2] = yylloc;
                YYLLOC_DEFAULT(yyloc, yyerror_loc_range, 2); /* position of error span */
                *++yystack.p_mark = yyloc;
#endif
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    fprintf(stderr, "%s[%d]: error recovery discarding state %d\n",
                                    YYDEBUGSTR, yydepth, *yystack.s_mark);
#endif
                if (yystack.s_mark <= yystack.s_base) goto yyabort;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                /* the current TOS position is the error start position */
                yyerror_loc_range[1] = *yystack.p_mark;
#endif
#if defined(YYDESTRUCT_CALL)
#if YYBTYACC
                if (!yytrial)
#endif /* YYBTYACC */
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                    YYDESTRUCT_CALL("error: discarding state",
                                    yystos[*yystack.s_mark], yystack.l_mark, yystack.p_mark);
#else
                    YYDESTRUCT_CALL("error: discarding state",
                                    yystos[*yystack.s_mark], yystack.l_mark);
#endif /* defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED) */
#endif /* defined(YYDESTRUCT_CALL) */
                --yystack.s_mark;
                --yystack.l_mark;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                --yystack.p_mark;
#endif
            }
        }
    }
    else
    {
        if (yychar == YYEOF) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            if ((yys = yyname[YYTRANSLATE(yychar)]) == NULL) yys = yyname[YYUNDFTOKEN];
            fprintf(stderr, "%s[%d]: state %d, error recovery discarding token %d (%s)\n",
                            YYDEBUGSTR, yydepth, yystate, yychar, yys);
        }
#endif
#if defined(YYDESTRUCT_CALL)
#if YYBTYACC
        if (!yytrial)
#endif /* YYBTYACC */
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
            YYDESTRUCT_CALL("error: discarding token", yychar, &yylval, &yylloc);
#else
            YYDESTRUCT_CALL("error: discarding token", yychar, &yylval);
#endif /* defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED) */
#endif /* defined(YYDESTRUCT_CALL) */
        yychar = YYEMPTY;
        goto yyloop;
    }

yyreduce:
    yym = yylen[yyn];
#if YYDEBUG
    if (yydebug)
    {
        fprintf(stderr, "%s[%d]: state %d, reducing by rule %d (%s)",
                        YYDEBUGSTR, yydepth, yystate, yyn, yyrule[yyn]);
#ifdef YYSTYPE_TOSTRING
#if YYBTYACC
        if (!yytrial)
#endif /* YYBTYACC */
            if (yym > 0)
            {
                int i;
                fputc('<', stderr);
                for (i = yym; i > 0; i--)
                {
                    if (i != yym) fputs(", ", stderr);
                    fputs(YYSTYPE_TOSTRING(yystos[yystack.s_mark[1-i]],
                                           yystack.l_mark[1-i]), stderr);
                }
                fputc('>', stderr);
            }
#endif
        fputc('\n', stderr);
    }
#endif
    if (yym > 0)
        yyval = yystack.l_mark[1-yym];
    else
        memset(&yyval, 0, sizeof yyval);
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)

    /* Perform position reduction */
    memset(&yyloc, 0, sizeof(yyloc));
#if YYBTYACC
    if (!yytrial)
#endif /* YYBTYACC */
    {
        YYLLOC_DEFAULT(yyloc, &yystack.p_mark[-yym], yym);
        /* just in case YYERROR is invoked within the action, save
           the start of the rhs as the error start position */
        yyerror_loc_range[1] = yystack.p_mark[1-yym];
    }
#endif

    switch (yyn)
    {
case 1:
#line 122 "1905002.y"
	{
		/*write your code in this block in all the similar blocks below*/
		fprintf(logout,"start : program \n");
		yyval.symbolInfo = new SymbolInfo("program", "start");
		yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
		yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
		yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

		printSyntaxTree(ptout, yyval.symbolInfo, 0);
		clearMemSyntaxTree(yyval.symbolInfo);
		yyval.symbolInfo = NULL;
		compRef = NULL;
	}
#line 1729 "y.tab.c"
break;
case 2:
#line 137 "1905002.y"
	{
			fprintf(logout,"program : program unit \n");
			yyval.symbolInfo = new SymbolInfo("program unit", "program");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-1].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
}
#line 1741 "y.tab.c"
break;
case 3:
#line 145 "1905002.y"
	{
		fprintf(logout,"program : unit \n");
		yyval.symbolInfo = new SymbolInfo("unit", "program");
		yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
		yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
		yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
	}
#line 1752 "y.tab.c"
break;
case 4:
#line 154 "1905002.y"
	{
			fprintf(logout,"unit : var_declaration  \n");
			yyval.symbolInfo = new SymbolInfo("var_declaration", "unit");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
	}
#line 1763 "y.tab.c"
break;
case 5:
#line 161 "1905002.y"
	{
			fprintf(logout,"unit : func_declaration \n");
			yyval.symbolInfo = new SymbolInfo("func_declaration", "unit");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
	 }
#line 1774 "y.tab.c"
break;
case 6:
#line 168 "1905002.y"
	{
			fprintf(logout,"unit : func_definition \n");
			yyval.symbolInfo = new SymbolInfo("func_definition", "unit");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
	 }
#line 1785 "y.tab.c"
break;
case 7:
#line 177 "1905002.y"
	{
			fprintf(logout,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n");
			yyval.symbolInfo = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", "func_declaration");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-5].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-5].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			if(yystack.l_mark[-2].symbolInfo->getTypeSpecifier() != "error") {
				bool isInserted = st.insert(yystack.l_mark[-4].symbolInfo->getName(), yystack.l_mark[-5].symbolInfo->getTypeSpecifier());

				if(!isInserted) {
					SymbolInfo* looked = st.lookUp(yystack.l_mark[-4].symbolInfo->getName());
					if(looked->getIsFunction()) {
						fprintf(errorout, "Line %d: '%s' redeclared as different kind of symbol\n", yystack.l_mark[-4].symbolInfo->getStartLine(), yystack.l_mark[-4].symbolInfo->getName().c_str());
						syntaxErrorCount++;
						yyval.symbolInfo->setTypeSpecifier("error");
					} else {
						fprintf(errorout, "Line %d: Conflicting types for '%s'\n", yystack.l_mark[-4].symbolInfo->getStartLine(), yystack.l_mark[-4].symbolInfo->getName().c_str());
						syntaxErrorCount++;
						yyval.symbolInfo->setTypeSpecifier("error");
					}
				} else {
					SymbolInfo* func = st.lookUp(yystack.l_mark[-4].symbolInfo->getName());
					func->setTypeSpecifier(yystack.l_mark[-5].symbolInfo->getTypeSpecifier());
					func->setIsFunction(true);
					func->setIsFunctionDeclared(true);
					func->setParameters(yystack.l_mark[-2].symbolInfo->getParameterList(), yystack.l_mark[-2].symbolInfo->getParameterTypeList());
				}
			}
			scopeParameters.clearParameters();
		}
#line 1825 "y.tab.c"
break;
case 8:
#line 213 "1905002.y"
	{
			fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n");
			yyval.symbolInfo = new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON", "func_declaration");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-4].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			bool isInserted = st.insert(yystack.l_mark[-3].symbolInfo->getName(), yystack.l_mark[-4].symbolInfo->getTypeSpecifier());
			if(!isInserted) {
					SymbolInfo* looked = st.lookUp(yystack.l_mark[-3].symbolInfo->getName());
					if(looked->getIsFunction()) {
						fprintf(errorout, "Line %d: '%s' redeclared as different kind of symbol\n", yystack.l_mark[-3].symbolInfo->getStartLine(), yystack.l_mark[-3].symbolInfo->getName().c_str());
						syntaxErrorCount++;
						yyval.symbolInfo->setTypeSpecifier("error");
					} else {
						fprintf(errorout, "Line %d: Conflicting types for '%s'\n", yystack.l_mark[-3].symbolInfo->getStartLine(), yystack.l_mark[-3].symbolInfo->getName().c_str());
						syntaxErrorCount++;
						yyval.symbolInfo->setTypeSpecifier("error");
					}
			} else {
				SymbolInfo* func = st.lookUp(yystack.l_mark[-3].symbolInfo->getName());
				func->setTypeSpecifier(yystack.l_mark[-4].symbolInfo->getTypeSpecifier());
				func->setIsFunction(true);
				func->setIsFunctionDeclared(true);
			}
			scopeParameters.clearParameters();
		}
#line 1860 "y.tab.c"
break;
case 9:
#line 246 "1905002.y"
	{insertFunctionDefinition(yystack.l_mark[-4].symbolInfo,yystack.l_mark[-3].symbolInfo,yystack.l_mark[-1].symbolInfo);}
#line 1865 "y.tab.c"
break;
case 10:
#line 246 "1905002.y"
	{
			fprintf(logout,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n");
			yyval.symbolInfo = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement", "func_definition");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-6].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(compRef->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-6].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-5].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(compRef);


}
#line 1883 "y.tab.c"
break;
case 11:
#line 260 "1905002.y"
	{insertFunctionDefinition(yystack.l_mark[-3].symbolInfo,yystack.l_mark[-2].symbolInfo);}
#line 1888 "y.tab.c"
break;
case 12:
#line 260 "1905002.y"
	{
			fprintf(logout,"func_definition : type_specifier ID LPAREN RPAREN compound_statement \n");
			yyval.symbolInfo = new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement", "func_definition");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-5].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(compRef->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-5].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(compRef);
		}
#line 1903 "y.tab.c"
break;
case 13:
#line 271 "1905002.y"
	{
			fprintf(logout,"Error at line no %d : Syntax Error\n", lastSyntaxErrorLine);
			yyval.symbolInfo = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN", "func_definition");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-5].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[-1].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-5].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			SymbolInfo* temp = new SymbolInfo("error", "parameter_list");
			temp->setStartLine(lastSyntaxErrorLine);
			temp->setEndLine(lastSyntaxErrorLine);
			temp->setIsLeaf(true);
			yyval.symbolInfo->addChild(temp);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);

			clearMemSyntaxTree(yystack.l_mark[0].symbolInfo);

			fprintf(errorout, "Line# %d: Syntax error at parameter list of function definition\n", lastSyntaxErrorLine);
			syntaxErrorCount++;
		}
#line 1927 "y.tab.c"
break;
case 14:
#line 293 "1905002.y"
	{
			fprintf(logout,"parameter_list : parameter_list COMMA type_specifier ID \n");
			yyval.symbolInfo = new SymbolInfo("parameter_list COMMA type_specifier ID", "parameter_list");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-3].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setParameters(yystack.l_mark[-3].symbolInfo->getParameterList(), yystack.l_mark[-3].symbolInfo->getParameterTypeList());

			if(yystack.l_mark[-1].symbolInfo->getTypeSpecifier() == "VOID"){
				fprintf(errorout,"Line #%d: Function parameter can not be void \n");
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else {
				yyval.symbolInfo->addParameter(yystack.l_mark[0].symbolInfo->getName(), yystack.l_mark[-1].symbolInfo->getTypeSpecifier());
				scopeParameters.addParameter(yystack.l_mark[0].symbolInfo->getName(), yystack.l_mark[-1].symbolInfo->getTypeSpecifier());
			}
		}
#line 1952 "y.tab.c"
break;
case 15:
#line 314 "1905002.y"
	{
			fprintf(logout,"parameter_list : parameter_list COMMA type_specifier \n");
			yyval.symbolInfo = new SymbolInfo("parameter_list COMMA type_specifier", "parameter_list");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setParameters(yystack.l_mark[-2].symbolInfo->getParameterList(), yystack.l_mark[-2].symbolInfo->getParameterTypeList());

			if(yystack.l_mark[0].symbolInfo->getTypeSpecifier() == "VOID"){
				fprintf(errorout,"Line #%d: Function parameter can not be void \n");
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else {
				yyval.symbolInfo->addParameter("", yystack.l_mark[0].symbolInfo->getTypeSpecifier()); /* checked at entering scope*/
				scopeParameters.addParameter("", yystack.l_mark[0].symbolInfo->getTypeSpecifier());
			}
		}
#line 1976 "y.tab.c"
break;
case 16:
#line 334 "1905002.y"
	{
			fprintf(logout,"parameter_list : type_specifier ID\n");
			yyval.symbolInfo = new SymbolInfo("type_specifier ID", "parameter_list");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-1].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			
			scopeParameters.clearParameters();
			if(yystack.l_mark[-1].symbolInfo->getTypeSpecifier() == "VOID"){
				fprintf(errorout,"Line #%d: Function parameter can not be void \n");
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else {
				yyval.symbolInfo->addParameter(yystack.l_mark[0].symbolInfo->getName(), yystack.l_mark[-1].symbolInfo->getTypeSpecifier());
				scopeParameters.addParameter(yystack.l_mark[0].symbolInfo->getName(), yystack.l_mark[-1].symbolInfo->getTypeSpecifier());
			}
		}
#line 1998 "y.tab.c"
break;
case 17:
#line 352 "1905002.y"
	{
			fprintf(logout,"parameter_list : type_specifier \n");
			yyval.symbolInfo = new SymbolInfo("type_specifier", "parameter_list");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			
			scopeParameters.clearParameters();

			if(yystack.l_mark[0].symbolInfo->getTypeSpecifier() == "VOID"){
				fprintf(errorout,"Line #%d: Function parameter can not be void \n");
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else {
				/* $$->setTypeSpecifier($1->getTypeSpecifier());*/
				yyval.symbolInfo->addParameter("", yystack.l_mark[0].symbolInfo->getTypeSpecifier()); 
				scopeParameters.addParameter("", yystack.l_mark[0].symbolInfo->getTypeSpecifier());
			}
		}
#line 2021 "y.tab.c"
break;
case 18:
#line 374 "1905002.y"
	{
				fprintf(logout,"compound_statement : LCURL statements RCURL \n");
				yyval.symbolInfo = new SymbolInfo("LCURL statements RCURL", "compound_statement");
				yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
				yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
				yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo->getChildList()[0]);
				yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
				yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

				compRef = yyval.symbolInfo;

				/* $$->setTypeSpecifier($2->getTypeSpecifier());*/
				st.printAllScopeTable(logout);
				st.exitScope();
			}
#line 2040 "y.tab.c"
break;
case 19:
#line 389 "1905002.y"
	{
				fprintf(logout,"compound_statement : LCURL RCURL \n");
				yyval.symbolInfo = new SymbolInfo("LCURL RCURL", "compound_statement");
				yyval.symbolInfo->setStartLine(yystack.l_mark[-1].symbolInfo->getStartLine());
				yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
				yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo->getChildList()[0]);
				yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
				
				compRef = yyval.symbolInfo;
				
				st.printAllScopeTable(logout);
				st.exitScope();
			}
#line 2057 "y.tab.c"
break;
case 20:
#line 404 "1905002.y"
	{
			fprintf(logout,"var_declaration : type_specifier declaration_list SEMICOLON  \n");
			yyval.symbolInfo = new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);										

			if(yystack.l_mark[-2].symbolInfo->getName() == "VOID") {
				vector<string> variables = yystack.l_mark[-1].symbolInfo->getDeclarations();
				for(auto variable:variables) {
					fprintf(errorout, "Line# %d: Variable or field '%s' declared void\n", yylineno, variable.c_str());
					syntaxErrorCount++;
				}
			} else {
				vector<string> variables = yystack.l_mark[-1].symbolInfo->getDeclarations();
				vector<bool> isArrayList = yystack.l_mark[-1].symbolInfo->getIsArrayList();

				for(int i = 0; i < variables.size(); i++) {
					bool isInserted = st.insert(variables[i], yystack.l_mark[-2].symbolInfo->getName());
					if(isInserted == false) {
						SymbolInfo* lookUp = st.lookUp(variables[i]);

						if(lookUp->getIsFunction()) {
							fprintf(errorout, "Line# %d: '%s' redeclared as different kind of symbol\n", yylineno, variables[i].c_str());
							syntaxErrorCount++;
						} else {
							fprintf(errorout, "Line# %d: Conflicting types for '%s'\n", yylineno, variables[i].c_str());
							syntaxErrorCount++;
						}						
					} else {
						int ins = 0;
						if(isArrayList[i] == true) ins = 1;
						/* printf("Inserted %d %d %s\n", isInserted, ins, variables[i].c_str());*/
						st.lookUp(variables[i])->setIsArray(isArrayList[i]);
						st.lookUp(variables[i])->setTypeSpecifier(yystack.l_mark[-2].symbolInfo->getName());
					}
				}
			}
		}
#line 2102 "y.tab.c"
break;
case 21:
#line 445 "1905002.y"
	{
			fprintf(logout,"Error at line no %d : Syntax Error\n", lastSyntaxErrorLine);
			yyval.symbolInfo = new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			SymbolInfo* temp = new SymbolInfo("error", "declaration_list");
			temp->setStartLine(lastSyntaxErrorLine);
			temp->setEndLine(lastSyntaxErrorLine);
			temp->setIsLeaf(true);
			yyval.symbolInfo->addChild(temp);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			fprintf(errorout, "Line# %d: Syntax error at declaration list of variable declaration\n", lastSyntaxErrorLine);
			syntaxErrorCount++;										

		}
#line 2123 "y.tab.c"
break;
case 22:
#line 464 "1905002.y"
	{
			fprintf(logout,"type_specifier\t: INT \n");
			yyval.symbolInfo = new SymbolInfo("INT", "type_specifier");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setTypeSpecifier("INT");
		}
#line 2136 "y.tab.c"
break;
case 23:
#line 473 "1905002.y"
	{
			fprintf(logout,"type_specifier\t: FLOAT \n");
			yyval.symbolInfo = new SymbolInfo("FLOAT", "type_specifier");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setTypeSpecifier("FLOAT");
		}
#line 2149 "y.tab.c"
break;
case 24:
#line 482 "1905002.y"
	{
			fprintf(logout,"type_specifier\t: VOID \n");
			yyval.symbolInfo = new SymbolInfo("VOID", "type_specifier");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setTypeSpecifier("VOID");
		}
#line 2162 "y.tab.c"
break;
case 25:
#line 493 "1905002.y"
	{
			fprintf(logout,"declaration_list : declaration_list COMMA ID  \n");
			yyval.symbolInfo = new SymbolInfo("declaration_list COMMA ID", "declaration_list");			
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setDeclarationList(yystack.l_mark[-2].symbolInfo->getDeclarations());
			yyval.symbolInfo->setIsArrayList(yystack.l_mark[-2].symbolInfo->getIsArrayList());
			yyval.symbolInfo->addDeclaration(yystack.l_mark[0].symbolInfo->getName(), false);
		}
#line 2179 "y.tab.c"
break;
case 26:
#line 506 "1905002.y"
	{
			fprintf(logout,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE \n");
			yyval.symbolInfo = new SymbolInfo("declaration_list COMMA ID LSQUARE CONST_INT RSQUARE", "declaration_list");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-5].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-5].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setDeclarationList(yystack.l_mark[-5].symbolInfo->getDeclarations());
			yyval.symbolInfo->setIsArrayList(yystack.l_mark[-5].symbolInfo->getIsArrayList());
			yyval.symbolInfo->addDeclaration(yystack.l_mark[-3].symbolInfo->getName(), true);

		  }
#line 2200 "y.tab.c"
break;
case 27:
#line 523 "1905002.y"
	{
			fprintf(logout,"declaration_list : ID \n");
			yyval.symbolInfo = new SymbolInfo("ID", "declaration_list");			
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->addDeclaration(yystack.l_mark[0].symbolInfo->getName(), false);
		  }
#line 2213 "y.tab.c"
break;
case 28:
#line 532 "1905002.y"
	{
			fprintf(logout,"declaration_list : ID LSQUARE CONST_INT RSQUARE \n");
			yyval.symbolInfo = new SymbolInfo("ID LSQUARE CONST_INT RSQUARE", "declaration_list");			
			yyval.symbolInfo->setStartLine(yystack.l_mark[-3].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->addDeclaration(yystack.l_mark[-3].symbolInfo->getName(), true);
		  }
#line 2229 "y.tab.c"
break;
case 29:
#line 546 "1905002.y"
	{
			fprintf(logout,"statements : statement \n");
			yyval.symbolInfo = new SymbolInfo("statement", "statements");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
}
#line 2240 "y.tab.c"
break;
case 30:
#line 553 "1905002.y"
	{
			fprintf(logout,"statements : statements statement \n");
			yyval.symbolInfo = new SymbolInfo("statements statement", "statements");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-1].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

	   }
#line 2253 "y.tab.c"
break;
case 31:
#line 564 "1905002.y"
	{
			fprintf(logout,"statement : var_declaration \n");
			yyval.symbolInfo = new SymbolInfo("var_declaration", "statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

}
#line 2265 "y.tab.c"
break;
case 32:
#line 572 "1905002.y"
	{
			fprintf(logout,"statement : expression_statement \n");
			yyval.symbolInfo = new SymbolInfo("expression_statement", "statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

	  }
#line 2277 "y.tab.c"
break;
case 33:
#line 580 "1905002.y"
	{
			fprintf(logout,"statement : compound_statement \n");
			yyval.symbolInfo = new SymbolInfo("compound_statement", "statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

	  }
#line 2289 "y.tab.c"
break;
case 34:
#line 588 "1905002.y"
	{
			fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n");
			yyval.symbolInfo = new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement", "statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-6].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-6].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-5].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

	  }
#line 2307 "y.tab.c"
break;
case 35:
#line 602 "1905002.y"
	{
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement \n");
			yyval.symbolInfo = new SymbolInfo("IF LPAREN expression RPAREN statement", "statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-4].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

	  }
#line 2323 "y.tab.c"
break;
case 36:
#line 614 "1905002.y"
	{
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement \n");
			yyval.symbolInfo = new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement", "statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-6].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-6].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-5].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

	  }
#line 2341 "y.tab.c"
break;
case 37:
#line 628 "1905002.y"
	{
			fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement \n");
			yyval.symbolInfo = new SymbolInfo("WHILE LPAREN expression RPAREN statement", "statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-4].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
	  }
#line 2356 "y.tab.c"
break;
case 38:
#line 639 "1905002.y"
	{
			fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n");
			yyval.symbolInfo = new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON", "statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-4].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-4].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			/* include some things later*/
			if(st.lookUp(yystack.l_mark[-2].symbolInfo->getName()) == NULL){
				fprintf(logout,"Line #%d: Undeclared variable %s\n", yystack.l_mark[-4].symbolInfo->getStartLine(), yystack.l_mark[-2].symbolInfo->getName().c_str());
				syntaxErrorCount++;
			}
	  }
#line 2377 "y.tab.c"
break;
case 39:
#line 656 "1905002.y"
	{
			fprintf(logout,"statement : RETURN expression SEMICOLON \n");
			yyval.symbolInfo = new SymbolInfo("RETURN expression SEMICOLON", "statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			
			
			/* return type checking*/
			string type = yystack.l_mark[-1].symbolInfo->getTypeSpecifier();
			if(type == "VOID"){
				fprintf(errorout,"Line #%d: Void cannot be used in expression \n", yystack.l_mark[-2].symbolInfo->getStartLine());
				syntaxErrorCount++;
			} else if(funcReturnType == "VOID") {
				fprintf(errorout,"Line# %d: Non void return expression in void function \n", yystack.l_mark[-2].symbolInfo->getStartLine());
				syntaxErrorCount++;
			} else if(funcReturnType == "FLOAT" && type == "INT") {
				/* ok*/
			} else {
				if(funcReturnType != type) {
					fprintf(errorout,"Line #%d: Return type mismatch \n", yystack.l_mark[-2].symbolInfo->getStartLine());
					syntaxErrorCount++;
				}
			}
	  }
#line 2408 "y.tab.c"
break;
case 40:
#line 685 "1905002.y"
	{
				fprintf(logout,"expression_statement : SEMICOLON \n");
				yyval.symbolInfo = new SymbolInfo("SEMICOLON", "expression_statement");
				yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
				yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
				yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

				/* give a look here!!!!!*/
				/* string type = "VOID";*/
				/* $$->setTypeSpecifier(type);*/
			}
#line 2423 "y.tab.c"
break;
case 41:
#line 696 "1905002.y"
	{
				fprintf(logout,"expression_statement : expression SEMICOLON \n");
				yyval.symbolInfo = new SymbolInfo("expression SEMICOLON", "expression_statement");
				yyval.symbolInfo->setStartLine(yystack.l_mark[-1].symbolInfo->getStartLine());
				yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
				yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
				yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

				yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[-1].symbolInfo->getTypeSpecifier());
			}
#line 2437 "y.tab.c"
break;
case 42:
#line 705 "1905002.y"
	{
			fprintf(logout,"Error at line no %d : Syntax Error\n", lastSyntaxErrorLine);
			yyval.symbolInfo = new SymbolInfo("expression SEMICOLON", "expression_statement");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			SymbolInfo* temp = new SymbolInfo("error", "expression");
			temp->setStartLine(lastSyntaxErrorLine);
			temp->setEndLine(lastSyntaxErrorLine);
			temp->setIsLeaf(true);
			yyval.symbolInfo->addChild(temp);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			fprintf(errorout, "Line# %d: Syntax error at expression of expression statement\n", lastSyntaxErrorLine);
			syntaxErrorCount++;	
			}
#line 2456 "y.tab.c"
break;
case 43:
#line 722 "1905002.y"
	{
			fprintf(logout,"variable : ID \n");
			yyval.symbolInfo = new SymbolInfo("ID", "variable");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			SymbolInfo* look = st.lookUp(yystack.l_mark[0].symbolInfo->getName());		
			if(!look) {
				fprintf(errorout, "Line# %d: Undeclared variable '%s'\n", yystack.l_mark[0].symbolInfo->getStartLine(), yystack.l_mark[0].symbolInfo->getName().c_str());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else if(look->getIsFunction() == true) {
				fprintf(errorout, "Line# %d: '%s' is a function\n", yystack.l_mark[0].symbolInfo->getStartLine(), yystack.l_mark[0].symbolInfo->getName().c_str());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else {
				yyval.symbolInfo->setTypeSpecifier(look->getTypeSpecifier());
				yyval.symbolInfo->setIsArray(look->getIsArray());
				yyval.symbolInfo->setIsArrayWithoutIndex(true);
			}
	}
#line 2482 "y.tab.c"
break;
case 44:
#line 744 "1905002.y"
	{
			fprintf(logout,"variable : ID LSQUARE expression RSQUARE \n");
			yyval.symbolInfo = new SymbolInfo("ID LSQUARE expression RSQUARE", "variable");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-3].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			SymbolInfo* look = st.lookUp(yystack.l_mark[-3].symbolInfo->getName());
			if(!look) {
				fprintf(errorout, "Line# %d: Undeclared variable '%s'\n", yystack.l_mark[-3].symbolInfo->getStartLine(), yystack.l_mark[-3].symbolInfo->getName().c_str());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			}
			else if(look->getIsArray() == false) {
				fprintf(errorout, "Line# %d: '%s' is not an array\n", yystack.l_mark[-3].symbolInfo->getStartLine(), yystack.l_mark[-3].symbolInfo->getName().c_str());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else if(look->getIsFunction() == true) {
				fprintf(errorout, "Line# %d: '%s' is a function\n", yystack.l_mark[-3].symbolInfo->getStartLine(), yystack.l_mark[-3].symbolInfo->getName().c_str());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else if(yystack.l_mark[-1].symbolInfo->getTypeSpecifier() != "INT" && yystack.l_mark[-1].symbolInfo->getTypeSpecifier()!= "CONST_INT") {
				fprintf(errorout, "Line# %d: Array subscript is not an integer\n", yystack.l_mark[-3].symbolInfo->getStartLine());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else {
				yyval.symbolInfo->setTypeSpecifier(look->getTypeSpecifier());
				yyval.symbolInfo->setIsArray(true);
				yyval.symbolInfo->setIsArrayWithoutIndex(false);
			}
	 }
#line 2520 "y.tab.c"
break;
case 45:
#line 780 "1905002.y"
	{
			fprintf(logout,"expression : logic_expression \n");
			yyval.symbolInfo = new SymbolInfo("logic_expression", "expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			yyval.symbolInfo->setIsArray(yystack.l_mark[0].symbolInfo->getIsArray());
			yyval.symbolInfo->setIsArrayWithoutIndex(yystack.l_mark[0].symbolInfo->getIsArrayWithoutIndex());

			yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
		}
#line 2535 "y.tab.c"
break;
case 46:
#line 791 "1905002.y"
	{
			fprintf(logout,"expression : variable ASSIGNOP logic_expression \n");
			yyval.symbolInfo = new SymbolInfo("variable ASSIGNOP logic_expression", "expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			if(yystack.l_mark[-2].symbolInfo->getTypeSpecifier() != "error" && yystack.l_mark[0].symbolInfo->getTypeSpecifier() != "error") {
				if( yystack.l_mark[0].symbolInfo->getTypeSpecifier() == "VOID" ){
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", yystack.l_mark[-2].symbolInfo->getStartLine());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
				} else if(yystack.l_mark[-2].symbolInfo->getIsArray() == true && yystack.l_mark[-2].symbolInfo->getIsArrayWithoutIndex() == true) {
					fprintf(errorout, "Line# %d: Assignment to expression with array type\n", yystack.l_mark[-2].symbolInfo->getStartLine());
					syntaxErrorCount++;
					yyval.symbolInfo->setTypeSpecifier("error");
				} else if( yystack.l_mark[-2].symbolInfo->getTypeSpecifier()== "FLOAT" && yystack.l_mark[0].symbolInfo->getTypeSpecifier() == "INT" ){
				/* okay, i don't know how type cast occurs*/
				} else if( yystack.l_mark[-2].symbolInfo->getTypeSpecifier()== "INT" && yystack.l_mark[0].symbolInfo->getTypeSpecifier() == "FLOAT" ){
					fprintf(errorout, "Line# %d: Warning: possible loss of data in assignment of FLOAT to INT\n", yystack.l_mark[-2].symbolInfo->getStartLine());
					syntaxErrorCount++;
					yyval.symbolInfo->setTypeSpecifier("error");
				} else if(yystack.l_mark[-2].symbolInfo->getTypeSpecifier()!=yystack.l_mark[0].symbolInfo->getTypeSpecifier() && !(yystack.l_mark[-2].symbolInfo->getTypeSpecifier() =="error" || yystack.l_mark[0].symbolInfo->getTypeSpecifier() =="error")){
					fprintf(errorout, "Line# %d: Type mismatch for assignment operator \n", yystack.l_mark[-2].symbolInfo->getStartLine());
					syntaxErrorCount++;
					yyval.symbolInfo->setTypeSpecifier("error");
				} else {
					yyval.symbolInfo->setTypeSpecifier(castType(yystack.l_mark[-2].symbolInfo,yystack.l_mark[0].symbolInfo));
				}
			} else {
				yyval.symbolInfo->setTypeSpecifier("error");
			}
			
	   }
#line 2575 "y.tab.c"
break;
case 47:
#line 829 "1905002.y"
	{
			fprintf(logout,"logic_expression : rel_expression \n");
			yyval.symbolInfo = new SymbolInfo("rel_expression", "logic_expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			yyval.symbolInfo->setIsArray(yystack.l_mark[0].symbolInfo->getIsArray());
			yyval.symbolInfo->setIsArrayWithoutIndex(yystack.l_mark[0].symbolInfo->getIsArrayWithoutIndex());

			yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
		}
#line 2590 "y.tab.c"
break;
case 48:
#line 840 "1905002.y"
	{
			fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression \n");
			yyval.symbolInfo = new SymbolInfo("rel_expression LOGICOP rel_expression", "logic_expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			
			yyval.symbolInfo->setTypeSpecifier(castType(yystack.l_mark[-2].symbolInfo,yystack.l_mark[0].symbolInfo));
			if(yyval.symbolInfo->getTypeSpecifier() != "error") {
				if(yyval.symbolInfo->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", yystack.l_mark[-2].symbolInfo->getStartLine());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
				} else {
					if(yyval.symbolInfo->getTypeSpecifier() != "error") {
						yyval.symbolInfo->setTypeSpecifier("INT");
					}
				}
			} else {
				yyval.symbolInfo->setTypeSpecifier("error");
			}
			
		 }
#line 2619 "y.tab.c"
break;
case 49:
#line 867 "1905002.y"
	{
			fprintf(logout,"rel_expression : simple_expression \n");
			yyval.symbolInfo = new SymbolInfo("simple_expression", "rel_expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			yyval.symbolInfo->setIsArray(yystack.l_mark[0].symbolInfo->getIsArray());
			yyval.symbolInfo->setIsArrayWithoutIndex(yystack.l_mark[0].symbolInfo->getIsArrayWithoutIndex());

			yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
		}
#line 2634 "y.tab.c"
break;
case 50:
#line 878 "1905002.y"
	{
			fprintf(logout,"rel_expression : simple_expression RELOP simple_expression \n");
			yyval.symbolInfo = new SymbolInfo("simple_expression RELOP simple_expression", "rel_expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setTypeSpecifier(castType(yystack.l_mark[-2].symbolInfo,yystack.l_mark[0].symbolInfo));
			if(yyval.symbolInfo->getTypeSpecifier() != "error") {
				if(yyval.symbolInfo->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", yystack.l_mark[-2].symbolInfo->getStartLine());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
				} else {
					if(yyval.symbolInfo->getTypeSpecifier() != "error") {
						yyval.symbolInfo->setTypeSpecifier("INT");
					}
				}	
			} else {
				yyval.symbolInfo->setTypeSpecifier("error");
			}
			
		}
#line 2663 "y.tab.c"
break;
case 51:
#line 905 "1905002.y"
	{
			fprintf(logout,"simple_expression : term \n");
			yyval.symbolInfo = new SymbolInfo("term", "simple_expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			yyval.symbolInfo->setIsArray(yystack.l_mark[0].symbolInfo->getIsArray());
			yyval.symbolInfo->setIsArrayWithoutIndex(yystack.l_mark[0].symbolInfo->getIsArrayWithoutIndex());

			yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
		}
#line 2678 "y.tab.c"
break;
case 52:
#line 916 "1905002.y"
	{
			fprintf(logout,"simple_expression : simple_expression ADDOP term \n");
			yyval.symbolInfo = new SymbolInfo("simple_expression ADDOP term", "simple_expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			if(yystack.l_mark[-2].symbolInfo->getTypeSpecifier() != "error" && yystack.l_mark[0].symbolInfo->getTypeSpecifier() != "error") {
				if(yystack.l_mark[-2].symbolInfo->getTypeSpecifier() == "VOID" || yystack.l_mark[0].symbolInfo->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", yystack.l_mark[-1].symbolInfo->getStartLine());
				syntaxErrorCount++;
				/* will handle in expression which can't be void*/
				yyval.symbolInfo->setTypeSpecifier("error");
				}
				yyval.symbolInfo->setTypeSpecifier(castType(yystack.l_mark[-2].symbolInfo,yystack.l_mark[0].symbolInfo));
			} else {
				yyval.symbolInfo->setTypeSpecifier("error");
			}
			
		  }
#line 2704 "y.tab.c"
break;
case 53:
#line 940 "1905002.y"
	{
			fprintf(logout,"term : unary_expression \n");
			yyval.symbolInfo = new SymbolInfo("unary_expression", "term");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			yyval.symbolInfo->setIsArray(yystack.l_mark[0].symbolInfo->getIsArray());
			yyval.symbolInfo->setIsArrayWithoutIndex(yystack.l_mark[0].symbolInfo->getIsArrayWithoutIndex());

			yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
	}
#line 2719 "y.tab.c"
break;
case 54:
#line 951 "1905002.y"
	{
			fprintf(logout,"term : term MULOP unary_expression \n");
			yyval.symbolInfo = new SymbolInfo("term MULOP unary_expression", "term");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setIsFromConstant(yystack.l_mark[0].symbolInfo->getIsFromConstant());

			if(yystack.l_mark[-2].symbolInfo->getTypeSpecifier() != "error" && yystack.l_mark[0].symbolInfo->getTypeSpecifier() != "error") {
				if(yystack.l_mark[-2].symbolInfo->getTypeSpecifier() == "VOID" || yystack.l_mark[0].symbolInfo->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", yystack.l_mark[-1].symbolInfo->getStartLine());
				syntaxErrorCount++;
				/* will handle in expression which can't be void*/
				string type = "error";
				yyval.symbolInfo->setTypeSpecifier(type);
				} else if((yystack.l_mark[-2].symbolInfo->getIsArray() && yystack.l_mark[-2].symbolInfo->getIsArrayWithoutIndex()) || (yystack.l_mark[0].symbolInfo->getIsArray() && yystack.l_mark[0].symbolInfo->getIsArrayWithoutIndex())) {
					fprintf(errorout, "Line# %d: Array without index in '%s' operation  \n", yystack.l_mark[-1].symbolInfo->getStartLine(), yystack.l_mark[-1].symbolInfo->getName().c_str());
					syntaxErrorCount++;
					yyval.symbolInfo->setTypeSpecifier("error");
				} else {
					yyval.symbolInfo->setTypeSpecifier(castType(yystack.l_mark[-2].symbolInfo,yystack.l_mark[0].symbolInfo));
					if(yyval.symbolInfo->getTypeSpecifier() == "error") {
						fprintf(errorout, "Line# %d: Incompatible types in expression\n", yystack.l_mark[-1].symbolInfo->getStartLine());
						syntaxErrorCount++;
					} else {
						if(yystack.l_mark[-1].symbolInfo->getName() == "%" && yyval.symbolInfo->getTypeSpecifier() != "INT") {
							fprintf(errorout, "Line# %d: Operands of modulus must be integers \n", yystack.l_mark[-1].symbolInfo->getStartLine());
							syntaxErrorCount++;
							yyval.symbolInfo->setTypeSpecifier("error");
					} else if(yyval.symbolInfo->getIsFromConstant() && ((yystack.l_mark[-1].symbolInfo->getName() == "%" || yystack.l_mark[-1].symbolInfo->getName() == "/") && ((yystack.l_mark[0].symbolInfo->getConstantIntValue() == "0") || (yystack.l_mark[0].symbolInfo->getConstantFloatValue() == "0.0")))) {
							fprintf(errorout, "Line# %d: Warning: division by zero \n", yystack.l_mark[-1].symbolInfo->getStartLine());
							syntaxErrorCount++;
							yyval.symbolInfo->setTypeSpecifier("error");
						} 
					}
				}
			} else {
				yyval.symbolInfo->setTypeSpecifier("error");
			}			
	 }
#line 2766 "y.tab.c"
break;
case 55:
#line 996 "1905002.y"
	{
			fprintf(logout,"unary_expression : ADDOP unary_expression \n");
			yyval.symbolInfo = new SymbolInfo("ADDOP unary_expression", "unary_expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-1].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);


			if(yystack.l_mark[0].symbolInfo->getTypeSpecifier() != "error") {
				if(yystack.l_mark[0].symbolInfo->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Operand of '%s' is void\n", yystack.l_mark[-1].symbolInfo->getStartLine(), yystack.l_mark[-1].symbolInfo->getName().c_str());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
				} else {
					yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
				}
			}			
		}
#line 2789 "y.tab.c"
break;
case 56:
#line 1015 "1905002.y"
	{
			fprintf(logout,"unary_expression : NOT unary_expression \n");
			yyval.symbolInfo = new SymbolInfo("NOT unary_expression", "unary_expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-1].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			if(yystack.l_mark[0].symbolInfo->getTypeSpecifier() != "error") {
				if(yystack.l_mark[0].symbolInfo->getTypeSpecifier() != "INT") {
				fprintf(errorout, "Line# %d: Operand of '!' is not an integer\n", yystack.l_mark[-1].symbolInfo->getStartLine());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
				} else {
					yyval.symbolInfo->setTypeSpecifier("INT");
				}
			} else {
				yyval.symbolInfo->setTypeSpecifier("error");
			}
		 }
#line 2813 "y.tab.c"
break;
case 57:
#line 1035 "1905002.y"
	{
			fprintf(logout,"unary_expression : factor \n");
			yyval.symbolInfo = new SymbolInfo("factor", "unary_expression");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
			
			yyval.symbolInfo->setIsArray(yystack.l_mark[0].symbolInfo->getIsArray());
			yyval.symbolInfo->setIsArrayWithoutIndex(yystack.l_mark[0].symbolInfo->getIsArrayWithoutIndex());
			yyval.symbolInfo->setIsFromConstant(yystack.l_mark[0].symbolInfo->getIsFromConstant());
			yyval.symbolInfo->setConstantIntValue(yystack.l_mark[0].symbolInfo->getConstantIntValue());
			yyval.symbolInfo->setConstantFloatValue(yystack.l_mark[0].symbolInfo->getConstantFloatValue());

		 }
#line 2833 "y.tab.c"
break;
case 58:
#line 1053 "1905002.y"
	{
			fprintf(logout,"factor : variable \n");
			yyval.symbolInfo = new SymbolInfo("variable", "factor");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			yyval.symbolInfo->setIsArray(yystack.l_mark[0].symbolInfo->getIsArray());
			yyval.symbolInfo->setIsArrayWithoutIndex(yystack.l_mark[0].symbolInfo->getIsArrayWithoutIndex());
			
			yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
	}
#line 2848 "y.tab.c"
break;
case 59:
#line 1064 "1905002.y"
	{
		/* try after implementing function*/
			fprintf(logout,"factor : ID LPAREN argument_list RPAREN \n");
			yyval.symbolInfo = new SymbolInfo("ID LPAREN argument_list RPAREN", "factor");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-3].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-3].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			SymbolInfo* lookUp = st.lookUp(yystack.l_mark[-3].symbolInfo->getName());
			if(lookUp == NULL) {
				fprintf(errorout, "Line# %d: Undeclared function '%s'\n", yystack.l_mark[-3].symbolInfo->getStartLine(), yystack.l_mark[-3].symbolInfo->getName().c_str());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			} else {
				if(lookUp->getIsFunction() == false) {
					fprintf(errorout, "Line# %d: '%s' is not a function\n", yystack.l_mark[-3].symbolInfo->getStartLine(), yystack.l_mark[-3].symbolInfo->getName().c_str());
					syntaxErrorCount++;
					yyval.symbolInfo->setTypeSpecifier("error");
				} else {
					/* check number of arguments and type*/
					int nArguments = yystack.l_mark[-1].symbolInfo->getParameterTypeList().size();
					int nParameters = lookUp->getParameterTypeList().size();

					if(nArguments < nParameters) {
						fprintf(errorout, "Line# %d: Too few arguments to function '%s'\n", yystack.l_mark[-3].symbolInfo->getStartLine(), yystack.l_mark[-3].symbolInfo->getName().c_str());
						syntaxErrorCount++;
						yyval.symbolInfo->setTypeSpecifier("error");

					} else if(nArguments > nParameters) {
						fprintf(errorout, "Line# %d: Too many arguments to function '%s'\n", yystack.l_mark[-3].symbolInfo->getStartLine(), yystack.l_mark[-3].symbolInfo->getName().c_str());
						syntaxErrorCount++;
						yyval.symbolInfo->setTypeSpecifier("error");						
					} else {
						if(nParameters != 0) {
							/* type checking*/
							bool isTypeMatch = true;
							for(int i = 0; i < nParameters; i++) {
								if(yystack.l_mark[-1].symbolInfo->getParameterTypeList()[i] != lookUp->getParameterTypeList()[i]) {
									fprintf(errorout, "Line# %d: Type mismatch for argument %d of '%s'\n", yystack.l_mark[-3].symbolInfo->getStartLine(), (i+1), yystack.l_mark[-3].symbolInfo->getName().c_str());
									/* fprintf(errorout, "Line# %d: Type func def '%s' ,  type arg '%s' argNo- %d\n", $1->getStartLine(), */
									/* $3->getParameterTypeList()[i].c_str(), lookUp->getParameterTypeList()[i].c_str(), $1->getName().c_str());*/
									syntaxErrorCount++;
									yyval.symbolInfo->setTypeSpecifier("error");
									isTypeMatch = false;									
								} 
							}
							if(isTypeMatch) {
								yyval.symbolInfo->setTypeSpecifier(lookUp->getTypeSpecifier());
							}					
						} else {   /* nParams = 0*/
							yyval.symbolInfo->setTypeSpecifier(lookUp->getTypeSpecifier());
						}
					}
				}
			}
	}
#line 2911 "y.tab.c"
break;
case 60:
#line 1123 "1905002.y"
	{
			fprintf(logout,"factor : LPAREN expression RPAREN \n");
			yyval.symbolInfo = new SymbolInfo("LPAREN expression RPAREN", "factor");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
			yyval.symbolInfo->setIsArray(yystack.l_mark[-1].symbolInfo->getIsArray());
			yyval.symbolInfo->setIsArrayWithoutIndex(yystack.l_mark[-1].symbolInfo->getIsArrayWithoutIndex());

			yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[-1].symbolInfo->getTypeSpecifier());
	}
#line 2928 "y.tab.c"
break;
case 61:
#line 1136 "1905002.y"
	{
			fprintf(logout,"factor : CONST_INT \n");
			yyval.symbolInfo = new SymbolInfo("CONST_INT", "factor");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setTypeSpecifier("INT");

			yyval.symbolInfo->setIsFromConstant(true);
			yyval.symbolInfo->setConstantIntValue(yystack.l_mark[0].symbolInfo->getName());
	}
#line 2944 "y.tab.c"
break;
case 62:
#line 1148 "1905002.y"
	{
			fprintf(logout,"factor : CONST_FLOAT \n");
			yyval.symbolInfo = new SymbolInfo("CONST_FLOAT", "factor");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setTypeSpecifier("FLOAT");

			yyval.symbolInfo->setIsFromConstant(true);
			yyval.symbolInfo->setConstantFloatValue(yystack.l_mark[0].symbolInfo->getName());
	}
#line 2960 "y.tab.c"
break;
case 63:
#line 1160 "1905002.y"
	{
			fprintf(logout,"factor : variable INCOP \n");
			yyval.symbolInfo = new SymbolInfo("variable INCOP", "factor");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-1].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			if(yystack.l_mark[-1].symbolInfo->getTypeSpecifier() == "INT") {
				yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[-1].symbolInfo->getTypeSpecifier());
			} else {
				fprintf(errorout, "Line# %d: Invalid type for increment/decrement operator\n", yystack.l_mark[-1].symbolInfo->getStartLine());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			}
			
	}
#line 2981 "y.tab.c"
break;
case 64:
#line 1177 "1905002.y"
	{
			fprintf(logout,"factor : variable DECOP \n");
			yyval.symbolInfo = new SymbolInfo("variable DECOP", "factor");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-1].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			if(yystack.l_mark[-1].symbolInfo->getTypeSpecifier() == "INT") {
				yyval.symbolInfo->setTypeSpecifier(yystack.l_mark[-1].symbolInfo->getTypeSpecifier());
			} else {
				fprintf(errorout, "Line# %d: Invalid type for increment/decrement operator\n", yystack.l_mark[-1].symbolInfo->getStartLine());
				syntaxErrorCount++;
				yyval.symbolInfo->setTypeSpecifier("error");
			}
	}
#line 3001 "y.tab.c"
break;
case 65:
#line 1195 "1905002.y"
	{
				fprintf(logout,"argument_list : arguments \n");
				yyval.symbolInfo = new SymbolInfo("arguments", "argument_list");
				yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
				yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
				yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

				yyval.symbolInfo->setParameterTypeList(yystack.l_mark[0].symbolInfo->getParameterTypeList());
			}
#line 3014 "y.tab.c"
break;
case 66:
#line 1204 "1905002.y"
	{
				fprintf(logout,"argument_list : \n");
				yyval.symbolInfo = new SymbolInfo("", "argument_list");
				yyval.symbolInfo->setStartLine(yylineno);
				yyval.symbolInfo->setEndLine(yylineno);
				
				/* if fsanitize raises error, uncomment this*/
				/* $$->addChild($1);*/
			  }
#line 3027 "y.tab.c"
break;
case 67:
#line 1215 "1905002.y"
	{
			fprintf(logout,"arguments : arguments COMMA logic_expression \n");
			yyval.symbolInfo = new SymbolInfo("arguments COMMA logic_expression", "arguments");
			yyval.symbolInfo->setStartLine(yystack.l_mark[-2].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[-2].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[-1].symbolInfo);
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->setParameterTypeList(yystack.l_mark[-2].symbolInfo->getParameterTypeList());
			yyval.symbolInfo->addParameterType(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
		}
#line 3043 "y.tab.c"
break;
case 68:
#line 1227 "1905002.y"
	{
			fprintf(logout,"arguments : logic_expression \n");
			yyval.symbolInfo = new SymbolInfo("logic_expression", "arguments");
			yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
			yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());
			yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);

			yyval.symbolInfo->addParameterType(yystack.l_mark[0].symbolInfo->getTypeSpecifier());
		}
#line 3056 "y.tab.c"
break;
case 69:
#line 1239 "1905002.y"
	{
	yyval.symbolInfo = yystack.l_mark[0].symbolInfo;
	st.enterScope();
	/* printf("Entered scope");*/
	yyval.symbolInfo->addChild(yystack.l_mark[0].symbolInfo);
	yyval.symbolInfo->setStartLine(yystack.l_mark[0].symbolInfo->getStartLine());
	yyval.symbolInfo->setEndLine(yystack.l_mark[0].symbolInfo->getEndLine());

	vector<string> parameterList = scopeParameters.getParameterList();
	vector<string> parameterTypeList = scopeParameters.getParameterTypeList();

	for(int i=0;i<parameterList.size();i++){
		string name = parameterList[i];
		string type = parameterTypeList[i];

		/* if (name == "") {*/
		/* 	continue;*/
		/* }*/

		bool inserted = st.insert(name, type);
		
		if( !inserted ){
			fprintf(errorout, "Line# %d: Redefinition of parameter '%s'\n", yystack.l_mark[0].symbolInfo->getStartLine(), name.c_str());
			syntaxErrorCount++;
			break;
		} else {
			st.lookUp(name)->setTypeSpecifier(type);
		}
	}

	scopeParameters.clearParameters();
}
#line 3092 "y.tab.c"
break;
#line 3094 "y.tab.c"
    default:
        break;
    }
    yystack.s_mark -= yym;
    yystate = *yystack.s_mark;
    yystack.l_mark -= yym;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    yystack.p_mark -= yym;
#endif
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
        {
            fprintf(stderr, "%s[%d]: after reduction, ", YYDEBUGSTR, yydepth);
#ifdef YYSTYPE_TOSTRING
#if YYBTYACC
            if (!yytrial)
#endif /* YYBTYACC */
                fprintf(stderr, "result is <%s>, ", YYSTYPE_TOSTRING(yystos[YYFINAL], yyval));
#endif
            fprintf(stderr, "shifting from state 0 to final state %d\n", YYFINAL);
        }
#endif
        yystate = YYFINAL;
        *++yystack.s_mark = YYFINAL;
        *++yystack.l_mark = yyval;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
        *++yystack.p_mark = yyloc;
#endif
        if (yychar < 0)
        {
#if YYBTYACC
            do {
            if (yylvp < yylve)
            {
                /* we're currently re-reading tokens */
                yylval = *yylvp++;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                yylloc = *yylpp++;
#endif
                yychar = *yylexp++;
                break;
            }
            if (yyps->save)
            {
                /* in trial mode; save scanner results for future parse attempts */
                if (yylvp == yylvlim)
                {   /* Enlarge lexical value queue */
                    size_t p = (size_t) (yylvp - yylvals);
                    size_t s = (size_t) (yylvlim - yylvals);

                    s += YYLVQUEUEGROWTH;
                    if ((yylexemes = (YYINT *)realloc(yylexemes, s * sizeof(YYINT))) == NULL)
                        goto yyenomem;
                    if ((yylvals   = (YYSTYPE *)realloc(yylvals, s * sizeof(YYSTYPE))) == NULL)
                        goto yyenomem;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                    if ((yylpsns   = (YYLTYPE *)realloc(yylpsns, s * sizeof(YYLTYPE))) == NULL)
                        goto yyenomem;
#endif
                    yylvp   = yylve = yylvals + p;
                    yylvlim = yylvals + s;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                    yylpp   = yylpe = yylpsns + p;
                    yylplim = yylpsns + s;
#endif
                    yylexp  = yylexemes + p;
                }
                *yylexp = (YYINT) YYLEX;
                *yylvp++ = yylval;
                yylve++;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
                *yylpp++ = yylloc;
                yylpe++;
#endif
                yychar = *yylexp++;
                break;
            }
            /* normal operation, no conflict encountered */
#endif /* YYBTYACC */
            yychar = YYLEX;
#if YYBTYACC
            } while (0);
#endif /* YYBTYACC */
            if (yychar < 0) yychar = YYEOF;
#if YYDEBUG
            if (yydebug)
            {
                if ((yys = yyname[YYTRANSLATE(yychar)]) == NULL) yys = yyname[YYUNDFTOKEN];
                fprintf(stderr, "%s[%d]: state %d, reading token %d (%s)\n",
                                YYDEBUGSTR, yydepth, YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == YYEOF) goto yyaccept;
        goto yyloop;
    }
    if (((yyn = yygindex[yym]) != 0) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == (YYINT) yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#if YYDEBUG
    if (yydebug)
    {
        fprintf(stderr, "%s[%d]: after reduction, ", YYDEBUGSTR, yydepth);
#ifdef YYSTYPE_TOSTRING
#if YYBTYACC
        if (!yytrial)
#endif /* YYBTYACC */
            fprintf(stderr, "result is <%s>, ", YYSTYPE_TOSTRING(yystos[yystate], yyval));
#endif
        fprintf(stderr, "shifting from state %d to state %d\n", *yystack.s_mark, yystate);
    }
#endif
    if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
    *++yystack.s_mark = (YYINT) yystate;
    *++yystack.l_mark = yyval;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    *++yystack.p_mark = yyloc;
#endif
    goto yyloop;
#if YYBTYACC

    /* Reduction declares that this path is valid. Set yypath and do a full parse */
yyvalid:
    if (yypath) YYABORT;
    while (yyps->save)
    {
        YYParseState *save = yyps->save;
        yyps->save = save->save;
        save->save = yypath;
        yypath = save;
    }
#if YYDEBUG
    if (yydebug)
        fprintf(stderr, "%s[%d]: state %d, CONFLICT trial successful, backtracking to state %d, %d tokens\n",
                        YYDEBUGSTR, yydepth, yystate, yypath->state, (int)(yylvp - yylvals - yypath->lexeme));
#endif
    if (yyerrctx)
    {
        yyFreeState(yyerrctx);
        yyerrctx = NULL;
    }
    yylvp          = yylvals + yypath->lexeme;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    yylpp          = yylpsns + yypath->lexeme;
#endif
    yylexp         = yylexemes + yypath->lexeme;
    yychar         = YYEMPTY;
    yystack.s_mark = yystack.s_base + (yypath->yystack.s_mark - yypath->yystack.s_base);
    memcpy (yystack.s_base, yypath->yystack.s_base, (size_t) (yystack.s_mark - yystack.s_base + 1) * sizeof(YYINT));
    yystack.l_mark = yystack.l_base + (yypath->yystack.l_mark - yypath->yystack.l_base);
    memcpy (yystack.l_base, yypath->yystack.l_base, (size_t) (yystack.l_mark - yystack.l_base + 1) * sizeof(YYSTYPE));
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
    yystack.p_mark = yystack.p_base + (yypath->yystack.p_mark - yypath->yystack.p_base);
    memcpy (yystack.p_base, yypath->yystack.p_base, (size_t) (yystack.p_mark - yystack.p_base + 1) * sizeof(YYLTYPE));
#endif
    yystate        = yypath->state;
    goto yyloop;
#endif /* YYBTYACC */

yyoverflow:
    YYERROR_CALL("yacc stack overflow");
#if YYBTYACC
    goto yyabort_nomem;
yyenomem:
    YYERROR_CALL("memory exhausted");
yyabort_nomem:
#endif /* YYBTYACC */
    yyresult = 2;
    goto yyreturn;

yyabort:
    yyresult = 1;
    goto yyreturn;

yyaccept:
#if YYBTYACC
    if (yyps->save) goto yyvalid;
#endif /* YYBTYACC */
    yyresult = 0;

yyreturn:
#if defined(YYDESTRUCT_CALL)
    if (yychar != YYEOF && yychar != YYEMPTY)
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
        YYDESTRUCT_CALL("cleanup: discarding token", yychar, &yylval, &yylloc);
#else
        YYDESTRUCT_CALL("cleanup: discarding token", yychar, &yylval);
#endif /* defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED) */

    {
        YYSTYPE *pv;
#if defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED)
        YYLTYPE *pp;

        for (pv = yystack.l_base, pp = yystack.p_base; pv <= yystack.l_mark; ++pv, ++pp)
             YYDESTRUCT_CALL("cleanup: discarding state",
                             yystos[*(yystack.s_base + (pv - yystack.l_base))], pv, pp);
#else
        for (pv = yystack.l_base; pv <= yystack.l_mark; ++pv)
             YYDESTRUCT_CALL("cleanup: discarding state",
                             yystos[*(yystack.s_base + (pv - yystack.l_base))], pv);
#endif /* defined(YYLTYPE) || defined(YYLTYPE_IS_DECLARED) */
    }
#endif /* defined(YYDESTRUCT_CALL) */

#if YYBTYACC
    if (yyerrctx)
    {
        yyFreeState(yyerrctx);
        yyerrctx = NULL;
    }
    while (yyps)
    {
        YYParseState *save = yyps;
        yyps = save->save;
        save->save = NULL;
        yyFreeState(save);
    }
    while (yypath)
    {
        YYParseState *save = yypath;
        yypath = save->save;
        save->save = NULL;
        yyFreeState(save);
    }
#endif /* YYBTYACC */
    yyfreestack(&yystack);
    return (yyresult);
}
