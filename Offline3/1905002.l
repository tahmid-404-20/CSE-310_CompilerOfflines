%option noyywrap yylineno 
%x MULCOMMENT
%x SINGLELINECOMMENT
%x MULSTRING
%x SINGSTRING

%{
#include "stdio.h"
#include "stdlib.h"
#include "string"
#include "vector"
#include "1905002_SymbolTable.cpp"

// for system include
#include "y.tab.h"

using namespace std;

int line_count=1;
int error_count=0;
int string_lineno;
string string_out = "";
int unreg_escape_string;


int cmnt_lineno;
string cmnt_str = "";

extern FILE *logout;
extern FILE *errorout;
extern int yylineno;

char getASCIIChar(char ch) {
	// printf("Calleeed!!!");
	switch(ch) {
		case '\\': return ch;
		case '\"': return ch;
		case '\'': return ch;
		case 'n' : return '\n';
		case 't' : return '\t';
		case 'a' : return '\a';
		case 'f' : return '\f';
		case 'r' : return '\r';
		case 'b' : return '\b';
		case 'v' : return '\v';
		case '0' : return '\0';
		default:
			return -1;
	}
	
}

void removeTwoEnds(char *temp) {
	int n = yyleng;
	char ch[n + 1];
	strcpy(ch,yytext);

	int i,j;
	for(i=1,j=0;i<n-1;i++,j++) {
		temp[j] = ch[i];		
	}
	temp[j] = '\0';
}

void unescapeInputStringSingleLine(char *dest, const char *source, int n) {	
	char ch[n+1];
	strcpy(ch,source);
	
	int i,j;
	for(i=1,j=0;i<n-1;i++,j++) {
		if(ch[i] == '\\') {
			char c = getASCIIChar(ch[i+1]);
			if(c == '\b') {
				j -= 2;
				i++;
				continue;
			}
			dest[j] = c;
			i++;
		} else {
			dest[j] = ch[i];
		}
	}
	dest[j] = '\0';
}

void unescapeInputStringMultiline(char *dest, const char *source, int n) {	
	char ch[n+1];
	strcpy(ch,source);
	
	int i,j;
	for(i=1,j=0;i<n-1;i++,j++) {
		if(ch[i] == '\\') {
			if(ch[i+1] == '\n') {
				i += 2;
				dest[j] = '\t';
				continue;
			} else {
				char c = getASCIIChar(ch[i+1]);
				if(c == '\b') {
					j -= 2;
					i++;
					continue;
				}
				dest[j] = c;
				i++;
			}
		} else {
			dest[j] = ch[i];
		}
	}
	dest[j] = '\0';
}

void unescapeInputString(char *temp) {	
	int n = yyleng;
	char ch[n + 1];

	strcpy(ch,yytext);
	
	int i,j;
	for(i=1,j=0;i<n-1;i++,j++) {
		if(ch[i] == '\\') {
			char c = getASCIIChar(ch[i+1]);
			if(c == '\b') {
				j -= 2;
				i++;
				continue;
			}
			temp[j] = getASCIIChar(ch[i+1]);
			i++;
		} else {
			temp[j] = ch[i];
		}
	}
	temp[j] = '\0';
}

extern SymbolTable st;

%}

WHITESPACE [ \t\f\r\v]+
TAB [\t]+
EMPTYCHARLIT (\'\')
LETTER [a-zA-Z]
NEWLINE (\n|\r\n|\r)
DIGIT [0-9]
ID [A-Za-z_][A-Za-z0-9_]*
CONSTCHAR \'([^'"\\\n]|\\['"\\ntafrbv0])\'
UNFINCHARLIT (\'([^'"\\\n]|(\\['"\\ntafrbv0])))|(\'\\\')|(\')
MULCHARLIT \'([^'"\\]|\\['"\\ntafrbv0])([^'"\\\n]|\\['"\\ntafrbv0])+\'
UNREGESCAPE (\\[^'"\\ntafrbv0])
UNREGCHARLIT \'{UNREGESCAPE}\'
STRINGMID ([^\"\\\n]|\\['"\\ntafrbv0])*
SINGLELINESTRING \"([^"\\\n]|\\['"\\ntafrbv0])*\"
CONSTFLOAT {DIGIT}+(\.{DIGIT}*)?((E|e)[+-]?{DIGIT}+)?|\.{DIGIT}+|{DIGIT}+\.
REDUNDANTDECIMAL {DIGIT}*\.({DIGIT}*\.+{DIGIT}*)+

%%

{WHITESPACE} {}
{NEWLINE} {line_count++; }

"++"	{
            // operators start here
			yylval.symbolInfo = new SymbolInfo(yytext, "INCOP");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",yylineno,yytext);
			return INCOP;
		}

"--"	{
            // operators start here
			yylval.symbolInfo = new SymbolInfo(yytext, "DECOP");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <DECOP> Lexeme %s found\n",yylineno,yytext);
			return DECOP;
		}

"+"		|
"-"		{
			yylval.symbolInfo = new SymbolInfo(yytext, "ADDOP");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",yylineno,yytext);
			return ADDOP;
		}

"*"		|
"/"     |
"%"		{

			yylval.symbolInfo = new SymbolInfo(yytext, "MULOP");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",yylineno,yytext);
			return MULOP;
		}

"&&"	|
"||"	{
			yylval.symbolInfo = new SymbolInfo(yytext, "LOGICOP");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",yylineno,yytext);
			return LOGICOP;
		}

"&"	    |
"|"     |
"^"     |
"<<"    |
">>"	{
			yylval.symbolInfo = new SymbolInfo(yytext, "BITOP");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",yylineno,yytext);
			return BITOP;
		}

"<="	|
"=="    |
">="	|
">"     |
"<"		|
"!="	{
			yylval.symbolInfo = new SymbolInfo(yytext, "RELOP");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",yylineno,yytext);
			return RELOP;
		}

"="     {
			yylval.symbolInfo = new SymbolInfo(yytext, "ASSIGNOP");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",yylineno,yytext);
			return ASSIGNOP;

        }

"!"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "NOT");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",yylineno,yytext);
			return NOT;

        }

"("     {
			yylval.symbolInfo = new SymbolInfo(yytext, "LPAREN");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",yylineno,yytext);
			return LPAREN;

        }

")"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "RPAREN");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",yylineno,yytext);
			return RPAREN;

        }

"{"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "LCURL");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",yylineno,yytext);
			// st.enterScope();
			return LCURL;
        }

"}"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "RCURL");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",yylineno,yytext);
			// st.exitScope();
			return RCURL;
        }

"["     {
			yylval.symbolInfo = new SymbolInfo(yytext, "LSQUARE");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",yylineno,yytext);
			return LSQUARE;

        }

"]"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "RSQUARE");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",yylineno,yytext);
			return RSQUARE;


        }

","     {
			yylval.symbolInfo = new SymbolInfo(yytext, "COMMA");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",yylineno,yytext);
			return COMMA;


        }

";"     {
			yylval.symbolInfo = new SymbolInfo(yytext, "SEMICOLON");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",yylineno,yytext);
			return SEMICOLON;

        }

"println" {
			yylval.symbolInfo = new SymbolInfo(yytext, "PRINTLN");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <PRINTLN> Lexeme %s found\n",yylineno,yytext);
			return PRINTLN;
		}

"if"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "IF");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",yylineno,yytext);
			return IF;
		}

"for"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "FOR");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",yylineno,yytext);
			return FOR;
		}

"do"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "DO");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",yylineno,yytext);
			return DO;
		}

"int" {
			yylval.symbolInfo = new SymbolInfo(yytext, "INT");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",yylineno,yytext);
			return INT;
		}

"float"	{
			yylval.symbolInfo = new SymbolInfo(yytext, "FLOAT");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",yylineno,yytext);
			return FLOAT;
		}

"void" {
			yylval.symbolInfo = new SymbolInfo(yytext, "VOID");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <VOID> Lexeme void found\n",yylineno,yytext);
			return VOID;
		}

"switch" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "SWITCH");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <SWITCH> Lexeme switch found\n",yylineno,yytext);
			return SWITCH;
		}

"default" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "DEFAULT");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme default found\n",yylineno,yytext);
			return DEFAULT;
		}

"else"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "ELSE");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme else found\n",yylineno,yytext);
			return ELSE;
		}

"while"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "WHILE");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <WHILE> Lexeme while found\n",yylineno,yytext);
			return WHILE;
		}

"break"	{
			yylval.symbolInfo =  new SymbolInfo(yytext, "BREAK");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <BREAK> Lexeme break found\n",yylineno,yytext);
			return BREAK;
		}

"char"	{
			yylval.symbolInfo = new SymbolInfo(yytext, "CHAR");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <CHAR> Lexeme char found\n",yylineno,yytext);
			return CHAR;
		}

"double" {
			yylval.symbolInfo = new SymbolInfo(yytext, "DOUBLE");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme double found\n",yylineno,yytext);
			return DOUBLE;
		}

"return" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "RETURN");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <RETURN> Lexeme return found\n",yylineno,yytext);
			return RETURN;
		}

"case" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "CASE");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <CASE> Lexeme case found\n",yylineno,yytext);
			return CASE;
		}

"continue" {
			yylval.symbolInfo =  new SymbolInfo(yytext, "CONTINUE");
			yylval.symbolInfo->setStartLine(yylineno);
			yylval.symbolInfo->setEndLine(yylineno);
			yylval.symbolInfo->setIsLeaf(true);
			fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme continue found\n",yylineno,yytext);
			return CONTINUE;
		}

{CONSTCHAR} {
				int n = yyleng;
				char temp[n+1];
				unescapeInputString(temp);
				yylval.symbolInfo = new SymbolInfo(temp, "CONST_CHAR");
				yylval.symbolInfo->setStartLine(yylineno);
				yylval.symbolInfo->setEndLine(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
                fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",yylineno,temp);
				return CONST_CHAR;
            }

{EMPTYCHARLIT} {
				fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s\n", yylineno, yytext);
				error_count++;
}

{UNREGCHARLIT} {
				fprintf(logout,"Error at line# %d: UNRECOGNIZED_ESCAPE_SEQUENCE %s\n", yylineno, yytext);
				error_count++;
}

{MULCHARLIT} {
				fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n", yylineno, yytext);
				error_count++;
}

{UNFINCHARLIT} {
				fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n", yylineno, yytext);
				error_count++;
}

{DIGIT}+	{
				yylval.symbolInfo = new SymbolInfo(yytext, "CONST_INT");
				yylval.symbolInfo->setStartLine(yylineno);
				yylval.symbolInfo->setEndLine(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
                fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",yylineno,yytext);
				//insert in symbol table and print symbol table content(only non empty buckets)
				// SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
				// st.insert(si);
				return CONST_INT;
			}

{DIGIT}+\.	{
				yylval.symbolInfo = new SymbolInfo(yytext, "CONST_FLOAT");
				yylval.symbolInfo->setStartLine(yylineno);
				yylval.symbolInfo->setEndLine(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
                fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s0 found\n",yylineno,yytext);
				return CONST_FLOAT;   
			}

{CONSTFLOAT} {
				yylval.symbolInfo = new SymbolInfo(yytext, "CONST_FLOAT");
				yylval.symbolInfo->setStartLine(yylineno);
				yylval.symbolInfo->setEndLine(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
                fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",yylineno,yytext);
				return CONST_FLOAT;   
}

{REDUNDANTDECIMAL} {
				error_count++;
                fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",yylineno,yytext); 
}

({CONSTFLOAT}+|{REDUNDANTDECIMAL})(E|e)[+-]?({CONSTFLOAT}+|{REDUNDANTDECIMAL}) {
				error_count++;
                fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",yylineno,yytext); 
            }

{ID} {
                yylval.symbolInfo = new SymbolInfo(yytext, "ID");
				yylval.symbolInfo->setStartLine(yylineno);
				yylval.symbolInfo->setEndLine(yylineno);
				yylval.symbolInfo->setIsLeaf(true);
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",yylineno,yytext);
				return ID;
            }

{DIGIT}+{ID} {
                fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",yylineno,yytext);
				error_count++;  
            }

"/*" {          BEGIN(MULCOMMENT);
				cmnt_str = "";
				cmnt_lineno = yylineno;
                // fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme ",yylineno);            
            }
<MULCOMMENT>"*/" {BEGIN(INITIAL);
				fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme /*%s*/ found\n",cmnt_lineno,cmnt_str.c_str()); 
                // fprintf(logout,"%s found\n",yytext); 
            }
<MULCOMMENT>^(([^*]|\n)+) {
				string temp(yytext);
				cmnt_str += "\t" + temp;
                // fprintf(logout,"\t%s", yytext);                
            }
<MULCOMMENT>(([^*]|\n)+) {
				string temp(yytext);
				cmnt_str += temp;
                // fprintf(logout,"%s", yytext);                
            }
<MULCOMMENT>^(\*) {
				string temp(yytext);
				cmnt_str += "\t" + temp;
               	// fprintf(logout,"\t%s", yytext);  
}

<MULCOMMENT>(\*) {
               	string temp(yytext);
				cmnt_str += temp;
			   	// fprintf(logout,"%s", yytext);  
}

<MULCOMMENT><<EOF>> {
				error_count++;
				fprintf(logout, "Error at line# %d: UNFINISHED_COMMENT /*%s\n", yylineno,cmnt_str.c_str());
				BEGIN(INITIAL);
}

"//" {          cmnt_str = "";
				cmnt_lineno = yylineno;
				BEGIN(SINGLELINECOMMENT);
                // fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s",yylineno,yytext); 
}

<SINGLELINECOMMENT>({NEWLINE}) {}
<SINGLELINECOMMENT>(^{WHITESPACE}) {}

<SINGLELINECOMMENT>.*\\$ { 
				string temp(yytext);
				cmnt_str += temp + "\n";
				// fprintf(logout,"%s\n", yytext);
			}

<SINGLELINECOMMENT>.* {
				string temp(yytext);
				cmnt_str += temp;
				BEGIN(INITIAL);
				fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme //%s found\n",cmnt_lineno,cmnt_str.c_str());  
				// fprintf(logout,"%s found\n", yytext);
				}

<SINGLELINECOMMENT><<EOF>> { 
				error_count++;
				fprintf(logout, "Error at line# %d: Unfinished Comment found\n", cmnt_lineno);
				BEGIN(INITIAL);
}


\"{STRINGMID} {
	string_lineno = yylineno;
	string temp(yytext);
	string_out = temp;
	unreg_escape_string = 0;
	BEGIN(SINGSTRING);
}			

<SINGSTRING>{STRINGMID}\" {
	string temp(yytext);
	string_out += temp;
	int n = string_out.length();
	char tok[n+1];
	unescapeInputStringSingleLine(tok,string_out.c_str(), n);
	if(unreg_escape_string) {
		fprintf(logout,"Error at line# %d: UNRECONIZED_ESCAPE_SEQUENCE\n",string_lineno);
		error_count++;
		unreg_escape_string = 0;
	} else {
		yylval.symbolInfo = new SymbolInfo(tok, "SINGLE_LINE_STRING");
		yylval.symbolInfo->setStartLine(yylineno);
		yylval.symbolInfo->setEndLine(yylineno);
		yylval.symbolInfo->setIsLeaf(true);
		fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",string_lineno,string_out.c_str());
		return SINGLE_LINE_STRING;
	}

	BEGIN(INITIAL);
}

<SINGSTRING>{STRINGMID}\\\n {
	string temp(yytext);
	string_out += temp;
	BEGIN(MULSTRING);
}

<MULSTRING>{STRINGMID}\\\n {
	string temp(yytext);
	string_out += temp;
	BEGIN(MULSTRING);
}

<MULSTRING>{STRINGMID}\" {
	string temp(yytext);
	string_out += temp;
	int n = string_out.length();
	char tok[n+1];
	char t2[n+1];
	strcpy(t2, string_out.c_str());
	unescapeInputStringMultiline(tok,t2, n);
	if(unreg_escape_string) {
		fprintf(logout,"Error at line# %d: UNRECONIZED_ESCAPE_SEQUENCE\n",string_lineno);
		error_count++;
		unreg_escape_string = 0;
	} else {
		yylval.symbolInfo = new SymbolInfo(tok, "MULTI_LINE_STRING");
		yylval.symbolInfo->setStartLine(yylineno);
		yylval.symbolInfo->setEndLine(yylineno);
		yylval.symbolInfo->setIsLeaf(true);
		fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n",string_lineno,string_out.c_str());
		return MULTI_LINE_STRING;
	}
	BEGIN(INITIAL);
}

<SINGSTRING>{STRINGMID}[\n] {
	string temp(yytext);
	string_out += temp;
	fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s",string_lineno,string_out.c_str());
	error_count++;
	BEGIN(INITIAL);
}

<MULSTRING>{STRINGMID}[\n] {
	string temp(yytext);
	string_out += temp;
	fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s",yylineno-1, string_out.c_str());
	error_count++;
	BEGIN(INITIAL);
}

<SINGSTRING>(({STRINGMID})({UNREGESCAPE}+)) {
	// printf("Taken in single %s", yytext);
	unreg_escape_string = 1;
	string temp(yytext);
	string_out += temp;
}

<MULSTRING>(({STRINGMID})({UNREGESCAPE}+)) {
	// printf("Taken in double %s",yytext);
	unreg_escape_string = 1;
	string temp(yytext);
	string_out += temp;
}

<SINGSTRING><<EOF>> {
	// string temp(yytext);
	// string_out += temp;
	fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",yylineno,string_out.c_str());
	error_count++;
	BEGIN(INITIAL);
}

<MULSTRING><<EOF>> {
	string temp(yytext);
	string_out += temp;
	fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",yylineno, string_out.c_str());
	// printf("Line %d", yylineno);
	error_count++;
	BEGIN(INITIAL);
}


. {
	fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s\n",yylineno, yytext);
	error_count++;
}

%%