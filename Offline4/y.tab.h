#ifndef _yy_defines_h_
#define _yy_defines_h_

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
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union YYSTYPE{
    SymbolInfo* symbolInfo; 
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;

#endif /* _yy_defines_h_ */
