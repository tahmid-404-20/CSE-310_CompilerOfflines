%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "bits/stdc++.h"
#include "1905002_SymbolTable.cpp"
#include "1905002_parseTreeUtil.cpp"
// #define YYSTYPE SymbolInfo*

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
	//write your code
	lastSyntaxErrorLine = yylineno;
}

void insertFunctionDefinition(SymbolInfo *type_specifier, SymbolInfo *funcName,SymbolInfo *parameter_list = NULL) {

  bool isInserted = st.insert(funcName->getName(), type_specifier->getName());
  if (isInserted) {   // first time definition without declaration
    SymbolInfo *func = st.lookUp(funcName->getName());
    func->setIsFunction(true);
    // as it is declared, is declared set false
    func->setIsFunctionDeclared(false);
    // return type fixed
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
    } else if(lookUp->getIsFunctionDeclared()){  // declared but not defined yet, so this is probably the definition part
			if(type_specifier->getTypeSpecifier() != lookUp->getTypeSpecifier()) {
				fprintf(errorout, "Line# %d: Conflicting types for '%s'\n", type_specifier->getStartLine(), funcName->getName().c_str());
				syntaxErrorCount++;
			} else if((parameter_list == NULL && lookUp->getParameterList().size() != 0) || (parameter_list != NULL && lookUp->getParameterList().size() != parameter_list->getParameterList().size())) {
				fprintf(errorout, "Line# %d: Conflicting types for '%s'\n", funcName->getStartLine(), funcName->getName().c_str());
				syntaxErrorCount++;
			} else {
				bool isOkay = true;
				// check for parameter type mismatch
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
					// everything is okay, so set declared to false
					lookUp->setIsFunctionDeclared(false);
					funcReturnType = type_specifier->getTypeSpecifier();
				}
			}
	} else {  // declared and defined before
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


%}

%union{
    SymbolInfo* symbolInfo; 
}


%token<symbolInfo> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE CONST_INT CONST_FLOAT CONST_CHAR ID NOT LOGICOP RELOP ADDOP MULOP INCOP DECOP ASSIGNOP LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON BITOP SINGLE_LINE_STRING MULTI_LINE_STRING LOWER_THAN_ELSE PRINTLN
%type<symbolInfo> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments LCURL_

%destructor { clearMemSyntaxTree($$);  } <symbolInfo>

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		//write your code in this block in all the similar blocks below
		fprintf(logout,"start : program \n");
		$$ = new SymbolInfo("program", "start");
		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());
		$$->addChild($1);

		printSyntaxTree(ptout, $$, 0);
		clearMemSyntaxTree($$);
		$$ = NULL;
		compRef = NULL;
	}
	;

program : program unit {
			fprintf(logout,"program : program unit \n");
			$$ = new SymbolInfo("program unit", "program");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
}
	| unit {
		fprintf(logout,"program : unit \n");
		$$ = new SymbolInfo("unit", "program");
		$$->setStartLine($1->getStartLine());
		$$->setEndLine($1->getEndLine());
		$$->addChild($1);
	}
	;
	
unit : var_declaration {
			fprintf(logout,"unit : var_declaration  \n");
			$$ = new SymbolInfo("var_declaration", "unit");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
	}
     | func_declaration {
			fprintf(logout,"unit : func_declaration \n");
			$$ = new SymbolInfo("func_declaration", "unit");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
	 }
     | func_definition {
			fprintf(logout,"unit : func_definition \n");
			$$ = new SymbolInfo("func_definition", "unit");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
			fprintf(logout,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n");
			$$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", "func_declaration");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($6->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);

			if($4->getTypeSpecifier() != "error") {
				bool isInserted = st.insert($2->getName(), $1->getTypeSpecifier());

				if(!isInserted) {
					SymbolInfo* looked = st.lookUp($2->getName());
					if(looked->getIsFunction()) {
						fprintf(errorout, "Line %d: '%s' redeclared as different kind of symbol\n", $2->getStartLine(), $2->getName().c_str());
						syntaxErrorCount++;
						$$->setTypeSpecifier("error");
					} else {
						fprintf(errorout, "Line %d: Conflicting types for '%s'\n", $2->getStartLine(), $2->getName().c_str());
						syntaxErrorCount++;
						$$->setTypeSpecifier("error");
					}
				} else {
					SymbolInfo* func = st.lookUp($2->getName());
					func->setTypeSpecifier($1->getTypeSpecifier());
					func->setIsFunction(true);
					func->setIsFunctionDeclared(true);
					func->setParameters($4->getParameterList(), $4->getParameterTypeList());
				}
			}
			scopeParameters.clearParameters();
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
			fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n");
			$$ = new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON", "func_declaration");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($5->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);

			bool isInserted = st.insert($2->getName(), $1->getTypeSpecifier());
			if(!isInserted) {
					SymbolInfo* looked = st.lookUp($2->getName());
					if(looked->getIsFunction()) {
						fprintf(errorout, "Line %d: '%s' redeclared as different kind of symbol\n", $2->getStartLine(), $2->getName().c_str());
						syntaxErrorCount++;
						$$->setTypeSpecifier("error");
					} else {
						fprintf(errorout, "Line %d: Conflicting types for '%s'\n", $2->getStartLine(), $2->getName().c_str());
						syntaxErrorCount++;
						$$->setTypeSpecifier("error");
					}
			} else {
				SymbolInfo* func = st.lookUp($2->getName());
				func->setTypeSpecifier($1->getTypeSpecifier());
				func->setIsFunction(true);
				func->setIsFunctionDeclared(true);
			}
			scopeParameters.clearParameters();
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {insertFunctionDefinition($1,$2,$4);} compound_statement {
			fprintf(logout,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n");
			$$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement", "func_definition");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine(compRef->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild(compRef);


}
		| type_specifier ID LPAREN RPAREN {insertFunctionDefinition($1,$2);} compound_statement {
			fprintf(logout,"func_definition : type_specifier ID LPAREN RPAREN compound_statement \n");
			$$ = new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement", "func_definition");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine(compRef->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild(compRef);
		}
		| type_specifier ID LPAREN error RPAREN compound_statement {
			fprintf(logout,"Error at line no %d : Syntax Error\n", lastSyntaxErrorLine);
			$$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN", "func_definition");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($5->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			SymbolInfo* temp = new SymbolInfo("error", "parameter_list");
			temp->setStartLine(lastSyntaxErrorLine);
			temp->setEndLine(lastSyntaxErrorLine);
			temp->setIsLeaf(true);
			$$->addChild(temp);
			$$->addChild($5);

			clearMemSyntaxTree($6);

			fprintf(errorout, "Line# %d: Syntax error at parameter list of function definition\n", lastSyntaxErrorLine);
			syntaxErrorCount++;
		}
 		;

parameter_list  : parameter_list COMMA type_specifier ID {
			fprintf(logout,"parameter_list : parameter_list COMMA type_specifier ID \n");
			$$ = new SymbolInfo("parameter_list COMMA type_specifier ID", "parameter_list");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($4->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);

			$$->setParameters($1->getParameterList(), $1->getParameterTypeList());

			if($3->getTypeSpecifier() == "VOID"){
				fprintf(errorout,"Line #%d: Function parameter can not be void \n");
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else {
				$$->addParameter($4->getName(), $3->getTypeSpecifier());
				scopeParameters.addParameter($4->getName(), $3->getTypeSpecifier());
			}
		}
		| parameter_list COMMA type_specifier {
			fprintf(logout,"parameter_list : parameter_list COMMA type_specifier \n");
			$$ = new SymbolInfo("parameter_list COMMA type_specifier", "parameter_list");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setParameters($1->getParameterList(), $1->getParameterTypeList());

			if($3->getTypeSpecifier() == "VOID"){
				fprintf(errorout,"Line #%d: Function parameter can not be void \n");
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else {
				$$->addParameter("", $3->getTypeSpecifier()); // checked at entering scope
				scopeParameters.addParameter("", $3->getTypeSpecifier());
			}
		}
 		| type_specifier ID {
			fprintf(logout,"parameter_list : type_specifier ID\n");
			$$ = new SymbolInfo("type_specifier ID", "parameter_list");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			
			scopeParameters.clearParameters();
			if($1->getTypeSpecifier() == "VOID"){
				fprintf(errorout,"Line #%d: Function parameter can not be void \n");
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else {
				$$->addParameter($2->getName(), $1->getTypeSpecifier());
				scopeParameters.addParameter($2->getName(), $1->getTypeSpecifier());
			}
		}
		| type_specifier {
			fprintf(logout,"parameter_list : type_specifier \n");
			$$ = new SymbolInfo("type_specifier", "parameter_list");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
			
			scopeParameters.clearParameters();

			if($1->getTypeSpecifier() == "VOID"){
				fprintf(errorout,"Line #%d: Function parameter can not be void \n");
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else {
				// $$->setTypeSpecifier($1->getTypeSpecifier());
				$$->addParameter("", $1->getTypeSpecifier()); 
				scopeParameters.addParameter("", $1->getTypeSpecifier());
			}
		}
 		;

 		
compound_statement : LCURL_ statements RCURL {
				fprintf(logout,"compound_statement : LCURL statements RCURL \n");
				$$ = new SymbolInfo("LCURL statements RCURL", "compound_statement");
				$$->setStartLine($1->getStartLine());
				$$->setEndLine($3->getEndLine());
				$$->addChild($1->getChildList()[0]);
				$$->addChild($2);
				$$->addChild($3);

				compRef = $$;

				// $$->setTypeSpecifier($2->getTypeSpecifier());
				st.printAllScopeTable(logout);
				st.exitScope();
			}
 		    | LCURL_ RCURL {
				fprintf(logout,"compound_statement : LCURL RCURL \n");
				$$ = new SymbolInfo("LCURL RCURL", "compound_statement");
				$$->setStartLine($1->getStartLine());
				$$->setEndLine($2->getEndLine());
				$$->addChild($1->getChildList()[0]);
				$$->addChild($2);
				
				compRef = $$;
				
				st.printAllScopeTable(logout);
				st.exitScope();
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
			fprintf(logout,"var_declaration : type_specifier declaration_list SEMICOLON  \n");
			$$ = new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);										

			if($1->getName() == "VOID") {
				vector<string> variables = $2->getDeclarations();
				for(auto variable:variables) {
					fprintf(errorout, "Line# %d: Variable or field '%s' declared void\n", yylineno, variable.c_str());
					syntaxErrorCount++;
				}
			} else {
				vector<string> variables = $2->getDeclarations();
				vector<bool> isArrayList = $2->getIsArrayList();

				for(int i = 0; i < variables.size(); i++) {
					bool isInserted = st.insert(variables[i], $1->getName());
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
						// printf("Inserted %d %d %s\n", isInserted, ins, variables[i].c_str());
						st.lookUp(variables[i])->setIsArray(isArrayList[i]);
						st.lookUp(variables[i])->setTypeSpecifier($1->getName());
					}
				}
			}
		}
		| type_specifier error SEMICOLON {
			fprintf(logout,"Error at line no %d : Syntax Error\n", lastSyntaxErrorLine);
			$$ = new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			SymbolInfo* temp = new SymbolInfo("error", "declaration_list");
			temp->setStartLine(lastSyntaxErrorLine);
			temp->setEndLine(lastSyntaxErrorLine);
			temp->setIsLeaf(true);
			$$->addChild(temp);
			$$->addChild($3);

			fprintf(errorout, "Line# %d: Syntax error at declaration list of variable declaration\n", lastSyntaxErrorLine);
			syntaxErrorCount++;										

		}
 		 ;
 		 
type_specifier	: INT {
			fprintf(logout,"type_specifier\t: INT \n");
			$$ = new SymbolInfo("INT", "type_specifier");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->setTypeSpecifier("INT");
		}
 		| FLOAT {
			fprintf(logout,"type_specifier\t: FLOAT \n");
			$$ = new SymbolInfo("FLOAT", "type_specifier");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->setTypeSpecifier("FLOAT");
		}
 		| VOID {
			fprintf(logout,"type_specifier\t: VOID \n");
			$$ = new SymbolInfo("VOID", "type_specifier");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->setTypeSpecifier("VOID");
		}
 		;
 		
declaration_list : declaration_list COMMA ID {
			fprintf(logout,"declaration_list : declaration_list COMMA ID  \n");
			$$ = new SymbolInfo("declaration_list COMMA ID", "declaration_list");			
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setDeclarationList($1->getDeclarations());
			$$->setIsArrayList($1->getIsArrayList());
			$$->addDeclaration($3->getName(), false);
		}
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE {
			fprintf(logout,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE \n");
			$$ = new SymbolInfo("declaration_list COMMA ID LSQUARE CONST_INT RSQUARE", "declaration_list");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($6->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);

			$$->setDeclarationList($1->getDeclarations());
			$$->setIsArrayList($1->getIsArrayList());
			$$->addDeclaration($3->getName(), true);

		  }
 		  | ID {
			fprintf(logout,"declaration_list : ID \n");
			$$ = new SymbolInfo("ID", "declaration_list");			
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->addDeclaration($1->getName(), false);
		  }
 		  | ID LSQUARE CONST_INT RSQUARE {
			fprintf(logout,"declaration_list : ID LSQUARE CONST_INT RSQUARE \n");
			$$ = new SymbolInfo("ID LSQUARE CONST_INT RSQUARE", "declaration_list");			
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($4->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);

			$$->addDeclaration($1->getName(), true);
		  }
 		  ;
 		  
statements : statement {
			fprintf(logout,"statements : statement \n");
			$$ = new SymbolInfo("statement", "statements");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
}      
	   | statements statement {
			fprintf(logout,"statements : statements statement \n");
			$$ = new SymbolInfo("statements statement", "statements");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);

	   }
	   ;
	   
statement : var_declaration {
			fprintf(logout,"statement : var_declaration \n");
			$$ = new SymbolInfo("var_declaration", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

}
	  | expression_statement {
			fprintf(logout,"statement : expression_statement \n");
			$$ = new SymbolInfo("expression_statement", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

	  }
	  | compound_statement {
			fprintf(logout,"statement : compound_statement \n");
			$$ = new SymbolInfo("compound_statement", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
			fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n");
			$$ = new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($7->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			$$->addChild($7);

	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement \n");
			$$ = new SymbolInfo("IF LPAREN expression RPAREN statement", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($5->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);

	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement \n");
			$$ = new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($7->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			$$->addChild($7);

	  }
	  | WHILE LPAREN expression RPAREN statement {
			fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement \n");
			$$ = new SymbolInfo("WHILE LPAREN expression RPAREN statement", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($5->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
			fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n");
			$$ = new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($5->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);

			// include some things later
			if(st.lookUp($3->getName()) == NULL){
				fprintf(logout,"Line #%d: Undeclared variable %s\n", $1->getStartLine(), $3->getName().c_str());
				syntaxErrorCount++;
			}
	  }
	  | RETURN expression SEMICOLON {
			fprintf(logout,"statement : RETURN expression SEMICOLON \n");
			$$ = new SymbolInfo("RETURN expression SEMICOLON", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			
			// return type checking
			string type = $2->getTypeSpecifier();
			if(type == "VOID"){
				fprintf(errorout,"Line #%d: Void cannot be used in expression \n", $1->getStartLine());
				syntaxErrorCount++;
			} else if(funcReturnType == "VOID") {
				fprintf(errorout,"Line# %d: Non void return expression in void function \n", $1->getStartLine());
				syntaxErrorCount++;
			} else if(funcReturnType == "FLOAT" && type == "INT") {
				// ok
			} else {
				if(funcReturnType != type) {
					fprintf(errorout,"Line #%d: Return type mismatch \n", $1->getStartLine());
					syntaxErrorCount++;
				}
			}
	  }
	  ;
	  
expression_statement 	: SEMICOLON	{
				fprintf(logout,"expression_statement : SEMICOLON \n");
				$$ = new SymbolInfo("SEMICOLON", "expression_statement");
				$$->setStartLine($1->getStartLine());
				$$->setEndLine($1->getEndLine());
				$$->addChild($1);

				// give a look here!!!!!
				// string type = "VOID";
				// $$->setTypeSpecifier(type);
			}		
			| expression SEMICOLON {
				fprintf(logout,"expression_statement : expression SEMICOLON \n");
				$$ = new SymbolInfo("expression SEMICOLON", "expression_statement");
				$$->setStartLine($1->getStartLine());
				$$->setEndLine($2->getEndLine());
				$$->addChild($1);
				$$->addChild($2);

				$$->setTypeSpecifier($1->getTypeSpecifier());
			} | error SEMICOLON {
			fprintf(logout,"Error at line no %d : Syntax Error\n", lastSyntaxErrorLine);
			$$ = new SymbolInfo("expression SEMICOLON", "expression_statement");
			$$->setStartLine($2->getStartLine());
			$$->setEndLine($2->getEndLine());
			SymbolInfo* temp = new SymbolInfo("error", "expression");
			temp->setStartLine(lastSyntaxErrorLine);
			temp->setEndLine(lastSyntaxErrorLine);
			temp->setIsLeaf(true);
			$$->addChild(temp);
			$$->addChild($2);

			fprintf(errorout, "Line# %d: Syntax error at expression of expression statement\n", lastSyntaxErrorLine);
			syntaxErrorCount++;	
			}
			;
	  
variable : ID {
			fprintf(logout,"variable : ID \n");
			$$ = new SymbolInfo("ID", "variable");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			SymbolInfo* look = st.lookUp($1->getName());		
			if(!look) {
				fprintf(errorout, "Line# %d: Undeclared variable '%s'\n", $1->getStartLine(), $1->getName().c_str());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else if(look->getIsFunction() == true) {
				fprintf(errorout, "Line# %d: '%s' is a function\n", $1->getStartLine(), $1->getName().c_str());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else {
				$$->setTypeSpecifier(look->getTypeSpecifier());
				$$->setIsArray(look->getIsArray());
				$$->setIsArrayWithoutIndex(true);
			}
	}		
	 | ID LSQUARE expression RSQUARE {
			fprintf(logout,"variable : ID LSQUARE expression RSQUARE \n");
			$$ = new SymbolInfo("ID LSQUARE expression RSQUARE", "variable");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($4->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);

			SymbolInfo* look = st.lookUp($1->getName());
			if(!look) {
				fprintf(errorout, "Line# %d: Undeclared variable '%s'\n", $1->getStartLine(), $1->getName().c_str());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			}
			else if(look->getIsArray() == false) {
				fprintf(errorout, "Line# %d: '%s' is not an array\n", $1->getStartLine(), $1->getName().c_str());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else if(look->getIsFunction() == true) {
				fprintf(errorout, "Line# %d: '%s' is a function\n", $1->getStartLine(), $1->getName().c_str());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else if($3->getTypeSpecifier() != "INT" && $3->getTypeSpecifier()!= "CONST_INT") {
				fprintf(errorout, "Line# %d: Array subscript is not an integer\n", $1->getStartLine());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else {
				$$->setTypeSpecifier(look->getTypeSpecifier());
				$$->setIsArray(true);
				$$->setIsArrayWithoutIndex(false);
			}
	 }
	 ;
	 
expression : logic_expression {
			fprintf(logout,"expression : logic_expression \n");
			$$ = new SymbolInfo("logic_expression", "expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
		}	
	   | variable ASSIGNOP logic_expression {
			fprintf(logout,"expression : variable ASSIGNOP logic_expression \n");
			$$ = new SymbolInfo("variable ASSIGNOP logic_expression", "expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			if($1->getTypeSpecifier() != "error" && $3->getTypeSpecifier() != "error") {
				if( $3->getTypeSpecifier() == "VOID" ){
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $1->getStartLine());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
				} else if($1->getIsArray() == true && $1->getIsArrayWithoutIndex() == true) {
					fprintf(errorout, "Line# %d: Assignment to expression with array type\n", $1->getStartLine());
					syntaxErrorCount++;
					$$->setTypeSpecifier("error");
				} else if( $1->getTypeSpecifier()== "FLOAT" && $3->getTypeSpecifier() == "INT" ){
				// okay, i don't know how type cast occurs
				} else if( $1->getTypeSpecifier()== "INT" && $3->getTypeSpecifier() == "FLOAT" ){
					fprintf(errorout, "Line# %d: Warning: possible loss of data in assignment of FLOAT to INT\n", $1->getStartLine());
					syntaxErrorCount++;
					$$->setTypeSpecifier("error");
				} else if($1->getTypeSpecifier()!=$3->getTypeSpecifier() && !($1->getTypeSpecifier() =="error" || $3->getTypeSpecifier() =="error")){
					fprintf(errorout, "Line# %d: Type mismatch for assignment operator \n", $1->getStartLine());
					syntaxErrorCount++;
					$$->setTypeSpecifier("error");
				} else {
					$$->setTypeSpecifier(castType($1,$3));
				}
			} else {
				$$->setTypeSpecifier("error");
			}
			
	   }	
	   ;
			
logic_expression : rel_expression {
			fprintf(logout,"logic_expression : rel_expression \n");
			$$ = new SymbolInfo("rel_expression", "logic_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
		}		
		 | rel_expression LOGICOP rel_expression {
			fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression \n");
			$$ = new SymbolInfo("rel_expression LOGICOP rel_expression", "logic_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			$$->setTypeSpecifier(castType($1,$3));
			if($$->getTypeSpecifier() != "error") {
				if($$->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $1->getStartLine());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
				} else {
					if($$->getTypeSpecifier() != "error") {
						$$->setTypeSpecifier("INT");
					}
				}
			} else {
				$$->setTypeSpecifier("error");
			}
			
		 }	
		 ;
			
rel_expression	: simple_expression {
			fprintf(logout,"rel_expression : simple_expression \n");
			$$ = new SymbolInfo("simple_expression", "rel_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
		}
		| simple_expression RELOP simple_expression	{
			fprintf(logout,"rel_expression : simple_expression RELOP simple_expression \n");
			$$ = new SymbolInfo("simple_expression RELOP simple_expression", "rel_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setTypeSpecifier(castType($1,$3));
			if($$->getTypeSpecifier() != "error") {
				if($$->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $1->getStartLine());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
				} else {
					if($$->getTypeSpecifier() != "error") {
						$$->setTypeSpecifier("INT");
					}
				}	
			} else {
				$$->setTypeSpecifier("error");
			}
			
		}
		;
				
simple_expression : term {
			fprintf(logout,"simple_expression : term \n");
			$$ = new SymbolInfo("term", "simple_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
		}
		  | simple_expression ADDOP term {
			fprintf(logout,"simple_expression : simple_expression ADDOP term \n");
			$$ = new SymbolInfo("simple_expression ADDOP term", "simple_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			if($1->getTypeSpecifier() != "error" && $3->getTypeSpecifier() != "error") {
				if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $2->getStartLine());
				syntaxErrorCount++;
				// will handle in expression which can't be void
				$$->setTypeSpecifier("error");
				}
				$$->setTypeSpecifier(castType($1,$3));
			} else {
				$$->setTypeSpecifier("error");
			}
			
		  }
		  ;
					
term : unary_expression {
			fprintf(logout,"term : unary_expression \n");
			$$ = new SymbolInfo("unary_expression", "term");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($1->getTypeSpecifier());
	}
    | term MULOP unary_expression {
			fprintf(logout,"term : term MULOP unary_expression \n");
			$$ = new SymbolInfo("term MULOP unary_expression", "term");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setIsFromConstant($3->getIsFromConstant());

			if($1->getTypeSpecifier() != "error" && $3->getTypeSpecifier() != "error") {
				if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $2->getStartLine());
				syntaxErrorCount++;
				// will handle in expression which can't be void
				string type = "error";
				$$->setTypeSpecifier(type);
				} else if(($1->getIsArray() && $1->getIsArrayWithoutIndex()) || ($3->getIsArray() && $3->getIsArrayWithoutIndex())) {
					fprintf(errorout, "Line# %d: Array without index in '%s' operation  \n", $2->getStartLine(), $2->getName().c_str());
					syntaxErrorCount++;
					$$->setTypeSpecifier("error");
				} else {
					$$->setTypeSpecifier(castType($1,$3));
					if($$->getTypeSpecifier() == "error") {
						fprintf(errorout, "Line# %d: Incompatible types in expression\n", $2->getStartLine());
						syntaxErrorCount++;
					} else {
						if($2->getName() == "%" && $$->getTypeSpecifier() != "INT") {
							fprintf(errorout, "Line# %d: Operands of modulus must be integers \n", $2->getStartLine());
							syntaxErrorCount++;
							$$->setTypeSpecifier("error");
					} else if($$->getIsFromConstant() && (($2->getName() == "%" || $2->getName() == "/") && (($3->getConstantIntValue() == "0") || ($3->getConstantFloatValue() == "0.0")))) {
							fprintf(errorout, "Line# %d: Warning: division by zero \n", $2->getStartLine());
							syntaxErrorCount++;
							$$->setTypeSpecifier("error");
						} 
					}
				}
			} else {
				$$->setTypeSpecifier("error");
			}			
	 }
     ;

unary_expression : ADDOP unary_expression {
			fprintf(logout,"unary_expression : ADDOP unary_expression \n");
			$$ = new SymbolInfo("ADDOP unary_expression", "unary_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);


			if($2->getTypeSpecifier() != "error") {
				if($2->getTypeSpecifier() == "VOID") {
				fprintf(errorout, "Line# %d: Operand of '%s' is void\n", $1->getStartLine(), $1->getName().c_str());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
				} else {
					$$->setTypeSpecifier($2->getTypeSpecifier());
				}
			}			
		}
		 | NOT unary_expression {
			fprintf(logout,"unary_expression : NOT unary_expression \n");
			$$ = new SymbolInfo("NOT unary_expression", "unary_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);

			if($2->getTypeSpecifier() != "error") {
				if($2->getTypeSpecifier() != "INT") {
				fprintf(errorout, "Line# %d: Operand of '!' is not an integer\n", $1->getStartLine());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
				} else {
					$$->setTypeSpecifier("INT");
				}
			} else {
				$$->setTypeSpecifier("error");
			}
		 }
		 | factor {
			fprintf(logout,"unary_expression : factor \n");
			$$ = new SymbolInfo("factor", "unary_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->setTypeSpecifier($1->getTypeSpecifier());
			
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());
			$$->setIsFromConstant($1->getIsFromConstant());
			$$->setConstantIntValue($1->getConstantIntValue());
			$$->setConstantFloatValue($1->getConstantFloatValue());

		 }
		 ;
	
factor	: variable {
			fprintf(logout,"factor : variable \n");
			$$ = new SymbolInfo("variable", "factor");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);
			$$->setIsArray($1->getIsArray());
			$$->setIsArrayWithoutIndex($1->getIsArrayWithoutIndex());
			
			$$->setTypeSpecifier($1->getTypeSpecifier());
	}
	| ID LPAREN argument_list RPAREN {
		// try after implementing function
			fprintf(logout,"factor : ID LPAREN argument_list RPAREN \n");
			$$ = new SymbolInfo("ID LPAREN argument_list RPAREN", "factor");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($4->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);

			SymbolInfo* lookUp = st.lookUp($1->getName());
			if(lookUp == NULL) {
				fprintf(errorout, "Line# %d: Undeclared function '%s'\n", $1->getStartLine(), $1->getName().c_str());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			} else {
				if(lookUp->getIsFunction() == false) {
					fprintf(errorout, "Line# %d: '%s' is not a function\n", $1->getStartLine(), $1->getName().c_str());
					syntaxErrorCount++;
					$$->setTypeSpecifier("error");
				} else {
					// check number of arguments and type
					int nArguments = $3->getParameterTypeList().size();
					int nParameters = lookUp->getParameterTypeList().size();

					if(nArguments < nParameters) {
						fprintf(errorout, "Line# %d: Too few arguments to function '%s'\n", $1->getStartLine(), $1->getName().c_str());
						syntaxErrorCount++;
						$$->setTypeSpecifier("error");

					} else if(nArguments > nParameters) {
						fprintf(errorout, "Line# %d: Too many arguments to function '%s'\n", $1->getStartLine(), $1->getName().c_str());
						syntaxErrorCount++;
						$$->setTypeSpecifier("error");						
					} else {
						if(nParameters != 0) {
							// type checking
							bool isTypeMatch = true;
							for(int i = 0; i < nParameters; i++) {
								if($3->getParameterTypeList()[i] != lookUp->getParameterTypeList()[i]) {
									fprintf(errorout, "Line# %d: Type mismatch for argument %d of '%s'\n", $1->getStartLine(), (i+1), $1->getName().c_str());
									// fprintf(errorout, "Line# %d: Type func def '%s' ,  type arg '%s' argNo- %d\n", $1->getStartLine(), 
									// $3->getParameterTypeList()[i].c_str(), lookUp->getParameterTypeList()[i].c_str(), $1->getName().c_str());
									syntaxErrorCount++;
									$$->setTypeSpecifier("error");
									isTypeMatch = false;									
								} 
							}
							if(isTypeMatch) {
								$$->setTypeSpecifier(lookUp->getTypeSpecifier());
							}					
						} else {   // nParams = 0
							$$->setTypeSpecifier(lookUp->getTypeSpecifier());
						}
					}
				}
			}
	}
	| LPAREN expression RPAREN {
			fprintf(logout,"factor : LPAREN expression RPAREN \n");
			$$ = new SymbolInfo("LPAREN expression RPAREN", "factor");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->setIsArray($2->getIsArray());
			$$->setIsArrayWithoutIndex($2->getIsArrayWithoutIndex());

			$$->setTypeSpecifier($2->getTypeSpecifier());
	}
	| CONST_INT {
			fprintf(logout,"factor : CONST_INT \n");
			$$ = new SymbolInfo("CONST_INT", "factor");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->setTypeSpecifier("INT");

			$$->setIsFromConstant(true);
			$$->setConstantIntValue($1->getName());
	}
	| CONST_FLOAT {
			fprintf(logout,"factor : CONST_FLOAT \n");
			$$ = new SymbolInfo("CONST_FLOAT", "factor");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->setTypeSpecifier("FLOAT");

			$$->setIsFromConstant(true);
			$$->setConstantFloatValue($1->getName());
	}
	| variable INCOP {
			fprintf(logout,"factor : variable INCOP \n");
			$$ = new SymbolInfo("variable INCOP", "factor");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);

			if($1->getTypeSpecifier() == "INT") {
				$$->setTypeSpecifier($1->getTypeSpecifier());
			} else {
				fprintf(errorout, "Line# %d: Invalid type for increment/decrement operator\n", $1->getStartLine());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			}
			
	}
	| variable DECOP {
			fprintf(logout,"factor : variable DECOP \n");
			$$ = new SymbolInfo("variable DECOP", "factor");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);

			if($1->getTypeSpecifier() == "INT") {
				$$->setTypeSpecifier($1->getTypeSpecifier());
			} else {
				fprintf(errorout, "Line# %d: Invalid type for increment/decrement operator\n", $1->getStartLine());
				syntaxErrorCount++;
				$$->setTypeSpecifier("error");
			}
	}
	;
	
argument_list : arguments {
				fprintf(logout,"argument_list : arguments \n");
				$$ = new SymbolInfo("arguments", "argument_list");
				$$->setStartLine($1->getStartLine());
				$$->setEndLine($1->getEndLine());
				$$->addChild($1);

				$$->setParameterTypeList($1->getParameterTypeList());
			}
			| {
				fprintf(logout,"argument_list : \n");
				$$ = new SymbolInfo("", "argument_list");
				$$->setStartLine(yylineno);
				$$->setEndLine(yylineno);
				
				// if fsanitize raises error, uncomment this
				// $$->addChild($1);
			  }
			  ;
	
arguments : arguments COMMA logic_expression {
			fprintf(logout,"arguments : arguments COMMA logic_expression \n");
			$$ = new SymbolInfo("arguments COMMA logic_expression", "arguments");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setParameterTypeList($1->getParameterTypeList());
			$$->addParameterType($3->getTypeSpecifier());
		}
	      | logic_expression {
			fprintf(logout,"arguments : logic_expression \n");
			$$ = new SymbolInfo("logic_expression", "arguments");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->addParameterType($1->getTypeSpecifier());
		}
	      ;

 
LCURL_ : LCURL {
	$$ = $1;
	st.enterScope();
	// printf("Entered scope");
	$$->addChild($1);
	$$->setStartLine($1->getStartLine());
	$$->setEndLine($1->getEndLine());

	vector<string> parameterList = scopeParameters.getParameterList();
	vector<string> parameterTypeList = scopeParameters.getParameterTypeList();

	for(int i=0;i<parameterList.size();i++){
		string name = parameterList[i];
		string type = parameterTypeList[i];

		// if (name == "") {
		// 	continue;
		// }

		bool inserted = st.insert(name, type);
		
		if( !inserted ){
			fprintf(errorout, "Line# %d: Redefinition of parameter '%s'\n", $1->getStartLine(), name.c_str());
			syntaxErrorCount++;
			break;
		} else {
			st.lookUp(name)->setTypeSpecifier(type);
		}
	}

	scopeParameters.clearParameters();
}


%%
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

