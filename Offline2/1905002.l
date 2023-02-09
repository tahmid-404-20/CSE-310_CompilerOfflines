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
#include "1905002.cpp"

using namespace std;

int line_count=1;
int error_count=0;
int string_lineno;
string string_out = "";
int unreg_escape_string;


int cmnt_lineno;
string cmnt_str = "";

FILE *logout;
FILE *tokenout;

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

SymbolTable st;

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

"++"	|
"--"	{
            // operators start here
			fprintf(tokenout,"<INCOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",yylineno,yytext);
		}

"+"		|
"-"		{
			fprintf(tokenout,"<ADDOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",yylineno,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}

"*"		|
"/"     |
"%"		{
			fprintf(tokenout,"<MULOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",yylineno,yytext);
		}

"&&"	|
"||"	{
			fprintf(tokenout,"<LOGICOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",yylineno,yytext);
		}

"&"	    |
"|"     |
"^"     |
"<<"    |
">>"	{
			fprintf(tokenout,"<BITOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",yylineno,yytext);
		}

"<="	|
"=="    |
">="	|
">"     |
"<"		|
"!="	{
			fprintf(tokenout,"<RELOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",yylineno,yytext);
		}

"="     {
            fprintf(tokenout,"<ASSIGNOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",yylineno,yytext);

        }

"!"     {
            fprintf(tokenout,"<NOT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",yylineno,yytext);

        }

"("     {
            fprintf(tokenout,"<LPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",yylineno,yytext);

        }

")"     {
            fprintf(tokenout,"<RPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",yylineno,yytext);

        }

"{"     {
            fprintf(tokenout,"<LCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",yylineno,yytext);
			st.enterScope();
        }

"}"     {
            fprintf(tokenout,"<RCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",yylineno,yytext);
			st.exitScope();
        }

"["     {
            fprintf(tokenout,"<LSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",yylineno,yytext);

        }

"]"     {
            fprintf(tokenout,"<RSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",yylineno,yytext);

        }

","     {
            fprintf(tokenout,"<COMMA, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",yylineno,yytext);

        }

";"     {
            fprintf(tokenout,"<SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",yylineno,yytext);

        }

"if"	{
			fprintf(tokenout,"<IF, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",yylineno,yytext);
		}

"for"	{
			fprintf(tokenout,"<FOR, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",yylineno,yytext);
		}

"do"	{
			fprintf(tokenout,"<DO, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",yylineno,yytext);
		}

"int" {
			fprintf(tokenout,"<INT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",yylineno,yytext);
		}

"float"	{
			fprintf(tokenout,"<FLOAT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",yylineno,yytext);
		}

"void" {
			fprintf(tokenout,"<VOID, void>\n",yytext);
			fprintf(logout,"Line# %d: Token <VOID> Lexeme void found\n",yylineno,yytext);
		}

"switch" {
			fprintf(tokenout,"<SWITCH, switch>\n",yytext);
			fprintf(logout,"Line# %d: Token <SWITCH> Lexeme switch found\n",yylineno,yytext);
		}

"default" {
			fprintf(tokenout,"<DEFAULT, default>\n",yytext);
			fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme default found\n",yylineno,yytext);
		}

"else"	{
			fprintf(tokenout,"<ELSE, else>\n",yytext);
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme else found\n",yylineno,yytext);
		}

"while"	{
			fprintf(tokenout,"<WHILE, while>\n",yytext);
			fprintf(logout,"Line# %d: Token <WHILE> Lexeme while found\n",yylineno,yytext);
		}

"break"	{
			fprintf(tokenout,"<BREAK, break>\n",yytext);
			fprintf(logout,"Line# %d: Token <BREAK> Lexeme break found\n",yylineno,yytext);
		}

"char"	{
			fprintf(tokenout,"<CHAR, char>\n",yytext);
			fprintf(logout,"Line# %d: Token <CHAR> Lexeme char found\n",yylineno,yytext);
		}

"double" {
			fprintf(tokenout,"<DOUBLE, double>\n",yytext);
			fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme double found\n",yylineno,yytext);
		}

"return" {
			fprintf(tokenout,"<RETURN, return>\n",yytext);
			fprintf(logout,"Line# %d: Token <RETURN> Lexeme return found\n",yylineno,yytext);
		}

"case" {
			fprintf(tokenout,"<CASE, case>\n",yytext);
			fprintf(logout,"Line# %d: Token <CASE> Lexeme case found\n",yylineno,yytext);
		}

"continue" {
			fprintf(tokenout,"<CONTINUE, continue>\n",yytext);
			fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme continue found\n",yylineno,yytext);
		}

{CONSTCHAR} {
				int n = yyleng;
				char temp[n+1];
				unescapeInputString(temp);
                fprintf(tokenout,"<CONST_CHAR, %s>\n",temp);
                fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",yylineno,temp);
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
				fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
                fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",yylineno,yytext);
				//insert in symbol table and print symbol table content(only non empty buckets)
				// SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
				// st.insert(si);
			}

{DIGIT}+\.	{
				fprintf(tokenout,"<CONST_FLOAT, %s0>\n",yytext);
                fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s0 found\n",yylineno,yytext);   
			}

{CONSTFLOAT} {
                fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
                fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",yylineno,yytext);   
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
                fprintf(tokenout,"<ID, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",yylineno,yytext);
				string type("ID");
				string name(yytext);
				if(st.insert(name,type)) {
					st.printAllScopeTable();
				} else {
					fprintf(logout,"\t%s already exisits in the current ScopeTable\n", yytext);
				}      
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
		fprintf(tokenout,"<SINGLE LINE STRING, %s>\n",tok);
		fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",string_lineno,string_out.c_str());
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
		fprintf(tokenout,"<MULTI LINE STRING, %s>\n",tok);
		fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n",string_lineno,string_out.c_str());
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

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1905002_log.txt","w");
	tokenout= fopen("1905002_token.txt","w");

	yyin= fin;
    yylineno = 1;
	yylex();
	st.printAllScopeTable();
	fprintf(logout,"Total lines: %d\nTotal errors: %d\n", yylineno, error_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
