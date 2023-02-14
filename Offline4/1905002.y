%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "bits/stdc++.h"
#include "1905002_SymbolTable.cpp"
#include "1905002_parseTreeUtil.cpp"
#include "1905002_util.cpp"
// #define YYSTYPE SymbolInfo*

#define GLOBAL_SCOPPE_ID 1

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int yylineno;
extern int error_count;
long lastSyntaxErrorLine;
int syntaxErrorCount = 0;
long long tempFileLineCount = 0;
long long labelCount = 0;


FILE *errorout,*logout,*ptout,*fp, *codeout, *tempout;

// define your global variables here

// variables for printing as it is in code.asm
string headString = ";-------\n;\n;-------\n.MODEL SMALL\n.STACK 1000H\n.Data\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tnumber DB \"00000$\"\n";
string globalVarDescription = "DUP (0000H)\n";
string functionEntryString = "\tPUSH BP\n\tMOV BP, SP";
string printFunctionsFromSir = "new_line proc\n\tpush ax\n\tpush dx\n\tmov ah,2\n\tmov dl,cr\n\tint 21h\n\tmov ah,2\n\tmov dl,lf\n\tint 21h\n\tpop dx\n\tpop ax\n\tret\nnew_line endp\nprint_output proc  ;print what is in ax\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush si\n\tlea si,number\n\tmov bx,10\n\tadd si,4\n\tcmp ax,0\n\tjnge negate\n\tprint:\n\txor dx,dx\n\tdiv bx\n\tmov [si],dl\n\tadd [si],'0'\n\tdec si\n\tcmp ax,0\n\tjne print\n\tinc si\n\tlea dx,si\n\tmov ah,9\n\tint 21h\n\tpop si\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tret\n\tnegate:\n\tpush ax\n\tmov ah,2\n\tmov dl,'-'\n\tint 21h\n\tpop ax\n\tneg ax\n\tjmp print\nprint_output endp\n\tEND main";

SymbolTable st;
SymbolInfo scopeParameters;
vector<GlobalVarDetails*> globalVarList;

// function related variables
string funcReturnType;
string funcReturnLabel;
int funcParameterCount = 0;
int stackOffset = 0;
bool isFunctionBeingDefined = false;

// for code generation label fixing
map <long, string> labelMap;

SymbolInfo *compRef;
SymbolInfo *relExp2;
SymbolInfo *expr;
vector<long> relExp1TrueList;
vector<long> relExp1FalseList;


void yyerror(char *s)
{
	//write your code
	lastSyntaxErrorLine = yylineno;
}

void writeIntoTempFile(const string s) {
	fprintf(tempout, "%s\n", s.c_str());
	tempFileLineCount++;
}

string getVarRightSide(SymbolInfo *varPointer) {
  string varName;
  if (!varPointer->getIsArray()) {
    if (varPointer->getIsGlobalVariable()) {
      varName = varPointer->getVarName();
    } else {
		if(varPointer->getIsParameter()) {  // only for non-arrays in and local variables
			varName = "[BP+" + to_string(varPointer->getStackOffset()) + "]";
		} else {
			varName = "[BP-" + to_string(varPointer->getStackOffset()) + "]";
		}
    }
  } else {                         // array
    writeIntoTempFile("\tPOP AX"); // this is the index, pushed during array
                                   // indexing, now popping
    if (varPointer->getIsGlobalVariable()) {
	  writeIntoTempFile("\tSHL AX, 1");	
      writeIntoTempFile("\tLEA SI, " + varPointer->getVarName());
	  writeIntoTempFile("\tADD SI, AX");
      varName = "[SI]";
    } else {
      int stkOffset = varPointer->getStackOffset();
      writeIntoTempFile("\tMOV SI, BP");
      writeIntoTempFile("\tSUB SI, " +
                        to_string(stkOffset)); // [BP - 2] means a[0]
      writeIntoTempFile("\tSHL AX, 1");
      writeIntoTempFile("\tSUB SI, AX");
      varName = "[SI]";
    }

    return varName;
  }
}

string insertIntoLabelMap(vector<long> &labelList, string label) {
	for(int i=0;i<labelList.size();i++) {
		labelMap[labelList[i]] = label;
	}
}

void determineJumpForLogicalOp(SymbolInfo *relExp1) {	
	relExp1TrueList.clear();
	relExp1FalseList.clear();

	if(!relExp1->getIsRelational()) {
		writeIntoTempFile("; Line no: " + to_string(relExp1->getStartLine()));
		writeIntoTempFile("\tPOP AX");
		writeIntoTempFile("\tCMP AX, 0");
		writeIntoTempFile("\tJNE ");
		relExp1TrueList.push_back(tempFileLineCount);
		writeIntoTempFile("\tJMP ");
		relExp1FalseList.push_back(tempFileLineCount);	
	}

	relExp1->mergeTrueList(relExp1TrueList);
	relExp1->mergeFalseList(relExp1FalseList);
}

void writeForNonBooleanExpressions(SymbolInfo* expression, bool doPop = true) {
	vector<long> trueList;
	vector<long> falseList;
	if(!expression->getIsBoolean()) {
		writeIntoTempFile("; Line no: " + to_string(expression->getStartLine()) + " (Non-Boolean Expression)");
		if(doPop) {
			writeIntoTempFile("\tPOP AX");
		}
		writeIntoTempFile("\tCMP AX, 0");
		writeIntoTempFile("\tJNE ");
		trueList.push_back(tempFileLineCount);
		writeIntoTempFile("\tJMP ");
		falseList.push_back(tempFileLineCount);
	}

	expression->mergeTrueList(trueList);
	expression->mergeFalseList(falseList);
}

string getRelopJumpStatements(string relString) {
	if(relString == "<")
		return "JL";
	else if(relString == ">")
		return "JG";
	else if(relString == "<=")
		return "JLE";
	else if(relString == ">=")
		return "JGE";
	else if(relString == "==")
		return "JE";
	else if(relString == "!=")
		return "JNE";
}

void insertFunctionDefinition(SymbolInfo *type_specifier, SymbolInfo *funcName,
                              SymbolInfo *parameter_list = NULL) {

  bool isInserted = st.insert(funcName->getName(), type_specifier->getName());
  if (isInserted) { // first time definition without declaration
    SymbolInfo *func = st.lookUp(funcName->getName());
    func->setIsFunction(true);
    // as it is declared, is declared set false
    func->setIsFunctionDeclared(false);
    // return type fixed
    func->setTypeSpecifier(type_specifier->getTypeSpecifier());
    funcReturnType = type_specifier->getTypeSpecifier();
    if (parameter_list != NULL) {
      func->setParameters(parameter_list->getParameterList(),
                          parameter_list->getParameterTypeList());
    }
  } else {
    SymbolInfo *lookUp = st.lookUp(funcName->getName());
    if (!lookUp->getIsFunction()) {
      fprintf(errorout,
              "Line# %d: '%s' redeclared as different kind of symbol\n",
              funcName->getStartLine(), funcName->getName().c_str());
      syntaxErrorCount++;
    } else if (lookUp->getIsFunctionDeclared()) { // declared but not defined
                                                  // yet, so this is probably
                                                  // the definition part
      if (type_specifier->getTypeSpecifier() != lookUp->getTypeSpecifier()) {
        fprintf(errorout, "Line# %d: Conflicting types for '%s'\n",
                type_specifier->getStartLine(), funcName->getName().c_str());
        syntaxErrorCount++;
      } else if ((parameter_list == NULL &&
                  lookUp->getParameterList().size() != 0) ||
                 (parameter_list != NULL &&
                  lookUp->getParameterList().size() !=
                      parameter_list->getParameterList().size())) {
        fprintf(errorout, "Line# %d: Conflicting types for '%s'\n",
                funcName->getStartLine(), funcName->getName().c_str());
        syntaxErrorCount++;
      } else {
        bool isOkay = true;
        // check for parameter type mismatch
        if (parameter_list != NULL) {
          vector<string> parameterTypeList =
              parameter_list->getParameterTypeList();
          vector<string> lookUpParameterTypeList =
              lookUp->getParameterTypeList();
          for (int i = 0; i < parameterTypeList.size(); i++) {
            if (parameterTypeList[i] != lookUpParameterTypeList[i] ||
                lookUpParameterTypeList[i] == "VOID" ||
                lookUpParameterTypeList[i] == "error" ||
                parameterTypeList[i] == "error") {
              isOkay = false;
              break;
            }
          }
        }

        if (!isOkay) {
          fprintf(errorout,
                  "Line# %d: Type of arguments in declaration and definition "
                  "mismatch \n",
                  funcName->getStartLine());
          syntaxErrorCount++;
        } else {
          // everything is okay, so set declared to false
          lookUp->setIsFunctionDeclared(false);
          funcReturnType = type_specifier->getTypeSpecifier();
        }
      }
    } else { // declared and defined before
      fprintf(errorout, "Line# %d: Conflicting types for '%s'\n",
              funcName->getStartLine(), funcName->getName().c_str());
      syntaxErrorCount++;
    }
  }
}

void printFuncDefEntryCommands(SymbolInfo *funcName) {
  writeIntoTempFile(funcName->getName() + " PROC");
  if (funcName->getName() == "main") {
	writeIntoTempFile("\tMOV AX, @DATA");
	writeIntoTempFile("\tMOV DS, AX");
  }

  writeIntoTempFile(functionEntryString);
}

string castType(SymbolInfo *leftSymbol, SymbolInfo *rightSymbol) {
  string leftType = leftSymbol->getTypeSpecifier();
  string rightType = rightSymbol->getTypeSpecifier();
  if (leftType == "VOID" || rightType == "VOID")
    return "VOID";
  if (leftType == "error" || rightType == "error")
    return "error";
  if (leftType == "FLOAT" || rightType == "FLOAT")
    return "FLOAT";
  return "INT";
}


%}

%union{
    SymbolInfo* symbolInfo; 
}


%token<symbolInfo> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE CONST_INT CONST_FLOAT CONST_CHAR ID NOT LOGICOP RELOP ADDOP MULOP INCOP DECOP ASSIGNOP LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON BITOP SINGLE_LINE_STRING MULTI_LINE_STRING LOWER_THAN_ELSE PRINTLN
%type<symbolInfo> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments LCURL_
%type<symbolInfo> Marker Jumper non_boolean_if

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

		fprintf(codeout, "%s", headString.c_str());
		for(int i=0;i<globalVarList.size();i++){
			if(globalVarList[i] -> getIsArray()) {
				fprintf(codeout, "\t%s DW %d %s", globalVarList[i]-> getName().c_str(), globalVarList[i]->getArraySize(), globalVarDescription.c_str());
			} else {
				fprintf(codeout, "\t%s DW 1 %s", globalVarList[i]-> getName().c_str(),  globalVarDescription.c_str());
			}
			
			delete globalVarList[i];
		}

		fprintf(codeout, ".CODE\n");

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
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {insertFunctionDefinition($1,$2,$4);printFuncDefEntryCommands($2);funcParameterCount=0;isFunctionBeingDefined=true;funcReturnLabel="L"+to_string(++labelCount);stackOffset=0;} compound_statement{
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

			writeIntoTempFile(funcReturnLabel + ":");
			writeIntoTempFile("\tADD SP, " + to_string(stackOffset));
			writeIntoTempFile("\tPOP BP");
			
			if($2->getName() == "main"){
				writeIntoTempFile("\tMOV AX,4CH");
				writeIntoTempFile("\tINT 21H");					
			} else {
				if(funcParameterCount == 0) {
					writeIntoTempFile("\tRET ");
				} else {
					writeIntoTempFile("\tRET " + to_string(funcParameterCount*2));
				}
			}
			writeIntoTempFile($2->getName() + " ENDP");			

}
		| type_specifier ID LPAREN RPAREN {insertFunctionDefinition($1,$2); printFuncDefEntryCommands($2);funcParameterCount=0;isFunctionBeingDefined=true;funcReturnLabel="L"+to_string(++labelCount);stackOffset=0;} compound_statement {
			fprintf(logout,"func_definition : type_specifier ID LPAREN RPAREN compound_statement \n");
			$$ = new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement", "func_definition");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine(compRef->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild(compRef);

			writeIntoTempFile(funcReturnLabel + ":");
			writeIntoTempFile("\tADD SP, " + to_string(stackOffset));
			writeIntoTempFile("\tPOP BP");
			if($2->getName() == "main"){
				writeIntoTempFile("\tMOV AX,4CH");
				writeIntoTempFile("\tINT 21H");					
			} else {
				if(funcParameterCount == 0) {
					writeIntoTempFile("\tRET ");
				} else {
					writeIntoTempFile("\tRET " + to_string(funcParameterCount*2));
				}
			}
			writeIntoTempFile($2->getName() + " ENDP");	
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

 		
compound_statement : LCURL_ statements Marker RCURL {
				fprintf(logout,"compound_statement : LCURL statements RCURL \n");
				$$ = new SymbolInfo("LCURL statements RCURL", "compound_statement");
				$$->setStartLine($1->getStartLine());
				$$->setEndLine($3->getEndLine());
				$$->addChild($1->getChildList()[0]);
				$$->addChild($2);
				$$->addChild($3);
				$$->addChild($4);

				compRef = $$;

				// $$->setTypeSpecifier($2->getTypeSpecifier());
				st.printAllScopeTable(logout);
				st.exitScope();

				insertIntoLabelMap($2->getNextList(), $3->getLabel());
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
				vector<int> arraySizeList = $2->getArraySizeList();

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
						SymbolInfo *look = st.lookUp(variables[i]);
						look->setIsArray(isArrayList[i]);
						look->setTypeSpecifier($1->getName());
						look->setArraySize(arraySizeList[i]);
						
						if(st.getCurrentScopeTableId() == 1) {
							// need to handle global arrays later
							globalVarList.push_back(new GlobalVarDetails(variables[i],isArrayList[i], arraySizeList[i]));
							look->setIsGlobalVariable(true);
						} else {
							// write here for local variable
							if(look->getIsArray()) {
								look->setStackOffset(stackOffset+2); // a[0] at BP-2, a[1] at BP-4, a[2] at BP-6, etc.
								stackOffset += look->getArraySize()*2;
								// fprintf(tempout, "\tSUB SP, %d\n", look->getArraySize()*2);
							} else {
								stackOffset += 2;
								// fprintf(tempout, "\tSUB SP, 2\n");
								look->setStackOffset(stackOffset);
							}					
						}
					}
				}

				if(st.getCurrentScopeTableId() != 1) {
					writeIntoTempFile("\tSUB SP, " +  to_string(stackOffset));
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
			$$->setArraySizeList($1->getArraySizeList());
			$$->addDeclaration($3->getName());
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
			$$->setArraySizeList($1->getArraySizeList());
			$$->addDeclaration($3->getName(), true, stoi($5->getName()));

		  }
 		  | ID {
			fprintf(logout,"declaration_list : ID \n");
			$$ = new SymbolInfo("ID", "declaration_list");			
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->addDeclaration($1->getName());
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

			$$->addDeclaration($1->getName(), true, stoi($3->getName()));
		  }
 		  ;
 		  
statements : statement {
			fprintf(logout,"statements : statement \n");
			$$ = new SymbolInfo("statement", "statements");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			$$->setNextList($1->getNextList());
}      
	   | statements Marker statement {
			fprintf(logout,"statements : statements statement \n");
			$$ = new SymbolInfo("statements statement", "statements");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			insertIntoLabelMap($1->getNextList(), $2->getLabel());
			$$->setNextList($3->getNextList());
	   }
	   ;

Marker: {
		$$ = new SymbolInfo("marker", "marker");
		$$->setLabel("L" + to_string(++labelCount));
		writeIntoTempFile("L" + to_string(labelCount) + ":");

	}

Jumper: {
		$$ = new SymbolInfo("", "");
		writeIntoTempFile("\tJMP ");
		$$->addNextList(tempFileLineCount);
	}
	;

non_boolean_if: {
			$$ = new SymbolInfo("non_boolean_if", "non_boolean_if");
			writeForNonBooleanExpressions(expr);	
		}

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
	  | FOR LPAREN expression_statement Marker expression_statement {writeForNonBooleanExpressions($5, false);} Marker Jumper Marker expression {writeIntoTempFile("\tPOP AX");} Jumper RPAREN Marker statement {
			fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n");
			$$ = new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($7->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($7);
			$$->addChild($8);
			$$->addChild($9);
			$$->addChild($10);
			$$->addChild($12);
			$$->addChild($13);
			$$->addChild($14);
			$$->addChild($15);

			insertIntoLabelMap($5->getTrueList(), $7->getLabel());
			insertIntoLabelMap($12->getNextList(), $4->getLabel());
			insertIntoLabelMap($8->getNextList(), $14->getLabel());

			$$->setNextList($5->getFalseList());

			writeIntoTempFile("\tJMP " + $9->getLabel());

	  }
	  | IF LPAREN expression RPAREN non_boolean_if Marker statement %prec LOWER_THAN_ELSE {
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement \n");
			$$ = new SymbolInfo("IF LPAREN expression RPAREN statement", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($5->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			$$->addChild($7);

			insertIntoLabelMap($3->getTrueList(), $6->getLabel());
			$$->setNextList($3->getFalseList());
			$$->mergeNextList($6->getNextList());

			
	  }
	  | IF LPAREN expression RPAREN non_boolean_if Marker statement ELSE Jumper Marker statement {
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
			$$->addChild($8);
			$$->addChild($9);
			$$->addChild($10);
			$$->addChild($11);

			insertIntoLabelMap($3->getTrueList(), $6->getLabel());
			insertIntoLabelMap($3->getFalseList(), $10->getLabel());

			$$->setNextList($7->getNextList());
			$$->mergeNextList($9->getNextList());
			$$->mergeNextList($11->getNextList());
	  }
	  | WHILE LPAREN Marker expression {writeForNonBooleanExpressions($4);} RPAREN Marker statement{
			fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement \n");
			$$ = new SymbolInfo("WHILE LPAREN expression RPAREN statement", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($8->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($6);
			$$->addChild($7);
			$$->addChild($8);
			

			insertIntoLabelMap($4->getTrueList(), $7->getLabel());
			insertIntoLabelMap($8->getNextList(), $3->getLabel());

			$$->setNextList($4->getFalseList());

			writeIntoTempFile("\tJMP " + $3->getLabel());

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
				fprintf(errorout,"Line #%d: Undeclared variable %s\n", $1->getStartLine(), $3->getName().c_str());
				syntaxErrorCount++;
			}

			// icg code
			SymbolInfo* look = st.lookUp($3->getName());
			string varName;
			writeIntoTempFile("; Line no: " + to_string($1->getStartLine()) + " -> in println");
			if(look->getIsGlobalVariable()) {
				varName = look->getName();
			} else{					
				varName = "[BP-" + to_string(look->getStackOffset()) + "]";
			}
			
			writeIntoTempFile("\tMOV AX, " + varName);
			writeIntoTempFile("\tCALL print_output");
			writeIntoTempFile("\tCALL new_line");
	  }
	  | PRINTLN LPAREN ID LSQUARE expression RSQUARE RPAREN SEMICOLON {
			fprintf(logout,"statement : PRINTLN LPAREN ID LSQUARE expression RSQUARE RPAREN SEMICOLON \n");
			$$ = new SymbolInfo("PRINTLN LPAREN ID LSQUARE expression RSQUARE RPAREN SEMICOLON", "statement");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($8->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			$$->addChild($7);
			$$->addChild($8);

			// include some things later
			if(st.lookUp($3->getName()) == NULL){
				fprintf(errorout,"Line #%d: Undeclared variable %s\n", $1->getStartLine(), $3->getName().c_str());
				syntaxErrorCount++;
			}

			// icg code
			writeIntoTempFile("; Line no: " + to_string($1->getStartLine()) + " -> in println");
			writeIntoTempFile("\tPOP AX");
			SymbolInfo* look = st.lookUp($3->getName());
			string varName;
			// in our grammer, we don't send an array as a parameter, so no worrries with that
			if(look->getIsGlobalVariable()) {
				writeIntoTempFile("\tSHL AX, 1");	
      			writeIntoTempFile("\tLEA SI, " + look->getName());
	  			writeIntoTempFile("\tADD SI, AX");
      			varName = "[SI]";
					// writeIntoTempFile("\tMOV SI, AX");
					// varName = look->getName() +"[SI]";
				} else{					
					int stkOffset = look->getStackOffset();
					writeIntoTempFile("\tMOV SI, BP");
					writeIntoTempFile("\tSUB SI, " + to_string(stkOffset));   // [BP - 2] means a[0]
					writeIntoTempFile("\tSHL AX, 1");
					writeIntoTempFile("\tSUB SI, AX");
					varName = "[SI]";
				}	
			
			writeIntoTempFile("\tMOV AX, " + varName);
			writeIntoTempFile("\tCALL print_output");
			writeIntoTempFile("\tCALL new_line");

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

			// icg code
			writeIntoTempFile("; Line no: " + to_string($1->getStartLine()) + " -> in return");
			writeIntoTempFile("\tPOP AX");
			writeIntoTempFile("\tJMP " + funcReturnLabel);
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
				writeIntoTempFile("\tPOP AX");    // returning the stack to prev situation
			}		
			| expression SEMICOLON {
				fprintf(logout,"expression_statement : expression SEMICOLON \n");
				$$ = new SymbolInfo("expression SEMICOLON", "expression_statement");
				$$->setStartLine($1->getStartLine());
				$$->setEndLine($2->getEndLine());
				$$->addChild($1);
				$$->addChild($2);

				$$->setTypeSpecifier($1->getTypeSpecifier());

				// handle when n && i; type stmt without assignment, necessary in  for loop
				$$->setIsBoolean($1->getIsBoolean());
				$$->setTrueList($1->getTrueList());
				$$->setFalseList($1->getFalseList());
				$$->setNextList($1->getNextList());

				// if(!$1->getIsBoolean()) {
					writeIntoTempFile("\tPOP AX");    // returning the stack to prev situation
				// }
			}
			;
	  
variable : ID {
			fprintf(logout,"variable : ID \n");
			$$ = new SymbolInfo("ID", "variable");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			$$->addChild($1);

			SymbolInfo* look = st.lookUp($1->getName());

			$$->setIsGlobalVariable(look->getIsGlobalVariable());
			$$->setVarName(look->getName());
			$$->setIsArray(false);
			$$->setStackOffset(look->getStackOffset());
			$$->setIsParameter(look->getIsParameter());

			// if(look->getIsGlobalVariable()) {
			// 		$$->setVarName(look->getName());
			// } else{					
			// 	string varName = "[BP-" + to_string(look->getStackOffset()) + "]";
			// 	$$->setVarName(varName);
			// }		
			/*if(!look) {
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

				// icg code
				
			}*/
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

			// handle the case when expression can be a < b or a && b or (a < b) && c, same as assignment
			writeIntoTempFile("; Line no: " + to_string($1->getStartLine()) + " = operation");
			if($3->getIsBoolean()) {
				string label1 = "L" + to_string(++labelCount);
				insertIntoLabelMap($3->getTrueList(), label1);  // backpathing
				writeIntoTempFile(label1 + ":");
				writeIntoTempFile("\tMOV BX, 1");
				
				string jumpLabel = "L" + to_string(++labelCount);
				writeIntoTempFile("\tJMP " + jumpLabel);
				
				string label2 = "L" + to_string(++labelCount);
				// insertIntoLabelMap($3->getFalseList(), label2);  // backpatching, I have no idea why this generates segmentation fault
				vector<long> fList = $3->getFalseList();
				for(int i=0;i<fList.size();i++) {
					labelMap[fList[i]] = label2;
				}

				writeIntoTempFile(label2 + ":");
				writeIntoTempFile("\tMOV BX, 0");

				writeIntoTempFile(jumpLabel + ":");

				writeIntoTempFile("\tMOV AX, BX");
				writeIntoTempFile("\tPUSH AX");
			}

			SymbolInfo* look = st.lookUp($1->getName());
			$$->setIsGlobalVariable(look->getIsGlobalVariable());
			$$->setVarName(look->getName());
			$$->setIsArray(true);
			$$->setStackOffset(look->getStackOffset());
			
			// if(look->getIsGlobalVariable()) {
			// 		writeIntoTempFile("\tMOV SI, AX");
			// 		$$->setVarName(look->getName() +"[SI]");
			// 	} 
			// 	else{					
			// 		int stkOffset = look->getStackOffset();
			// 		writeIntoTempFile("\tMOV SI, BP");
			// 		writeIntoTempFile("\tSUB SI, " + to_string(stkOffset));   // [BP - 2] means a[0]
			// 		writeIntoTempFile("\tSHL AX, 1");
			// 		writeIntoTempFile("\tSUB SI, AX");
			// 		$$->setVarName("[SI]");
			// }		

			/*
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
			*/
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

			$$->setIsFromConstant($1->getIsFromConstant());
			$$->setConstantIntValue($1->getConstantIntValue());
			$$->setConstantFloatValue($1->getConstantFloatValue());

			$$->setIsBoolean($1->getIsBoolean());
  			$$->setTrueList($1->getTrueList());
  			$$->setFalseList($1->getFalseList());
  			$$->setNextList($1->getNextList());

			expr = $$;
		}	
	   | variable ASSIGNOP logic_expression	{
			fprintf(logout,"expression : variable ASSIGNOP logic_expression \n");
			$$ = new SymbolInfo("variable ASSIGNOP logic_expression", "expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			expr = $$;

			// icg code
			writeIntoTempFile("; Line no: " + to_string($1->getStartLine()) + " = operation");
			if($3->getIsBoolean()) {
				string label1 = "L" + to_string(++labelCount);
				insertIntoLabelMap($3->getTrueList(), label1);  // backpatching
				writeIntoTempFile(label1 + ":");
				writeIntoTempFile("\tMOV BX, 1");
				
				string jumpLabel = "L" + to_string(++labelCount);
				writeIntoTempFile("\tJMP " + jumpLabel);
				
				string label2 = "L" + to_string(++labelCount);
				// insertIntoLabelMap($3->getFalseList(), label2);  // backpatching, I have no idea why this generates segmentation fault
				vector<long> fList = $3->getFalseList();
				for(int i=0;i<fList.size();i++) {
					labelMap[fList[i]] = label2;
				}

				writeIntoTempFile(label2 + ":");
				writeIntoTempFile("\tMOV BX, 0");

				writeIntoTempFile(jumpLabel + ":");

				string varName = getVarRightSide($1);
				writeIntoTempFile("\tMOV " + varName + ", BX");
				writeIntoTempFile("\tMOV AX, BX");
				writeIntoTempFile("\tPUSH AX");

			} else {
				writeIntoTempFile("\tPOP BX");  // this is the logic exp when no boolean as for boolean, we don't push values, value to be assigned

				string varName = getVarRightSide($1);
				
				writeIntoTempFile("; line No " + to_string($1->getStartLine()));
				writeIntoTempFile("\tMOV " + varName + ", BX");
				writeIntoTempFile("\tMOV AX, " + varName);
				writeIntoTempFile("\tPUSH AX");  // supports a = b = c type of assignment
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

			$$->setIsFromConstant($1->getIsFromConstant());
			$$->setConstantIntValue($1->getConstantIntValue());
			$$->setConstantFloatValue($1->getConstantFloatValue());

			$$->setIsBoolean($1->getIsBoolean());
  			$$->setTrueList($1->getTrueList());
  			$$->setFalseList($1->getFalseList());
  			$$->setNextList($1->getNextList());

		}		
		 | rel_expression LOGICOP { determineJumpForLogicalOp($1);} Marker rel_expression {
			fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression \n");
			$$ = new SymbolInfo("rel_expression LOGICOP rel_expression", "logic_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine(relExp2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild(relExp2);


			$$->setIsBoolean(true);
			// $$->setTypeSpecifier(castType($1,$3));
			// if($$->getTypeSpecifier() != "error") {
			// 	if($$->getTypeSpecifier() == "VOID") {
			// 	fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $1->getStartLine());
			// 	syntaxErrorCount++;
			// 	$$->setTypeSpecifier("error");
			// 	} else {
			// 		if($$->getTypeSpecifier() != "error") {
			// 			$$->setTypeSpecifier("INT");
			// 		}
			// 	}
			// } else {
			// 	$$->setTypeSpecifier("error");
			// }

			// icg code
			writeIntoTempFile("; line No " + to_string($1->getStartLine()));
			vector<long> backPatchTrueList2;
			vector<long> backPatchFalseList2;
			if($2->getName() == "&&") {
				if(!$4->getIsRelational()) {
					writeIntoTempFile("\tPOP AX");
					writeIntoTempFile("\tCMP AX, 0");
					writeIntoTempFile("\tJNE ");
					backPatchTrueList2.push_back(tempFileLineCount);
					writeIntoTempFile("\tJMP ");
					backPatchFalseList2.push_back(tempFileLineCount);
				}
				
				// for relational(backPatchTrueList1 empty) or non-relational->($1->list is empty, so backPatchTrueList1 works)
				insertIntoLabelMap($1->getTrueList(), $4->getLabel()); // backpatching
				insertIntoLabelMap(relExp1TrueList, $4->getLabel());
				
				$$->setTrueList(relExp2->getTrueList());
				$$->mergeTrueList(backPatchTrueList2);

				$$->setFalseList($1->getFalseList());
				$$->mergeFalseList(relExp2->getFalseList());
				$$->mergeFalseList(relExp1FalseList);
				$$->mergeFalseList(backPatchFalseList2);
			} else{
				if(!$4->getIsRelational()) {
					writeIntoTempFile("\tPOP AX");
					writeIntoTempFile("\tCMP AX, 0");
					writeIntoTempFile("\tJNE ");
					backPatchTrueList2.push_back(tempFileLineCount);
					writeIntoTempFile("\tJMP ");
					backPatchFalseList2.push_back(tempFileLineCount);
				}

				insertIntoLabelMap($1->getFalseList(), $4->getLabel());
				insertIntoLabelMap(relExp1FalseList, $4->getLabel());

				$$->setFalseList(relExp2->getFalseList());
				$$->mergeFalseList(backPatchFalseList2);

				$$->setTrueList($1->getTrueList());
				$$->mergeTrueList(relExp2->getTrueList());
				$$->mergeTrueList(relExp1TrueList);
				$$->mergeTrueList(backPatchTrueList2);
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

			$$->setIsFromConstant($1->getIsFromConstant());
			$$->setConstantIntValue($1->getConstantIntValue());
			$$->setConstantFloatValue($1->getConstantFloatValue());

			relExp2 = $$;

			$$->setIsBoolean($1->getIsBoolean());
  			$$->setTrueList($1->getTrueList());
  			$$->setFalseList($1->getFalseList());
  			$$->setNextList($1->getNextList());
		}
		| simple_expression RELOP simple_expression	{
			fprintf(logout,"rel_expression : simple_expression RELOP simple_expression \n");
			$$ = new SymbolInfo("simple_expression RELOP simple_expression", "rel_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			$$->setIsBoolean(true);
			$$->setIsRelational(true);
			// $$->setTypeSpecifier(castType($1,$3));
			// if($$->getTypeSpecifier() != "error") {
			// 	if($$->getTypeSpecifier() == "VOID") {
			// 	fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $1->getStartLine());
			// 	syntaxErrorCount++;
			// 	$$->setTypeSpecifier("error");
			// 	} else {
			// 		if($$->getTypeSpecifier() != "error") {
			// 			$$->setTypeSpecifier("INT");
			// 		}
			// 	}	
			// } else {
			// 	$$->setTypeSpecifier("error");
			// }

			writeIntoTempFile("; line No " + to_string($1->getStartLine()));
			writeIntoTempFile("\tPOP BX");
			writeIntoTempFile("\tPOP AX");
			writeIntoTempFile("\tCMP AX, BX");
			writeIntoTempFile("\t" + getRelopJumpStatements($2->getName()) + " ");
			$$->addTrueList(tempFileLineCount);
			writeIntoTempFile("\tJMP ");			
			$$->addFalseList(tempFileLineCount);

			relExp2 = $$;
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

			$$->setIsFromConstant($1->getIsFromConstant());
			$$->setConstantIntValue($1->getConstantIntValue());
			$$->setConstantFloatValue($1->getConstantFloatValue());

			$$->setIsBoolean($1->getIsBoolean());
  			$$->setTrueList($1->getTrueList());
  			$$->setFalseList($1->getFalseList());
  			$$->setNextList($1->getNextList());
		}
		  | simple_expression ADDOP term {
			fprintf(logout,"simple_expression : simple_expression ADDOP term \n");
			$$ = new SymbolInfo("simple_expression ADDOP term", "simple_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			// if($1->getTypeSpecifier() != "error" && $3->getTypeSpecifier() != "error") {
			// 	if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID") {
			// 	fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $2->getStartLine());
			// 	syntaxErrorCount++;
			// 	// will handle in expression which can't be void
			// 	$$->setTypeSpecifier("error");
			// 	}
			// 	$$->setTypeSpecifier(castType($1,$3));
			// } else {
			// 	$$->setTypeSpecifier("error");
			// }

			writeIntoTempFile("; Line no " + to_string($1->getStartLine()));
			writeIntoTempFile("\tPOP BX");
			writeIntoTempFile("\tPOP AX");
			if($2->getName() == "+") {
				writeIntoTempFile("\tADD AX, BX");
			} else {
				writeIntoTempFile("\tSUB AX, BX");
			}
			writeIntoTempFile("\tPUSH AX");
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

			$$->setIsFromConstant($1->getIsFromConstant());
			$$->setConstantIntValue($1->getConstantIntValue());
			$$->setConstantFloatValue($1->getConstantFloatValue());

			$$->setIsBoolean($1->getIsBoolean());
  			$$->setTrueList($1->getTrueList());
  			$$->setFalseList($1->getFalseList());
  			$$->setNextList($1->getNextList());		
			
	}
    | term MULOP unary_expression {
			fprintf(logout,"term : term MULOP unary_expression \n");
			$$ = new SymbolInfo("term MULOP unary_expression", "term");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($3->getEndLine());
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);

			// $$->setIsFromConstant($3->getIsFromConstant());

			// if($1->getTypeSpecifier() != "error" && $3->getTypeSpecifier() != "error") {
			// 	if($1->getTypeSpecifier() == "VOID" || $3->getTypeSpecifier() == "VOID") {
			// 	fprintf(errorout, "Line# %d: Void cannot be used in expression \n", $2->getStartLine());
			// 	syntaxErrorCount++;
			// 	// will handle in expression which can't be void
			// 	string type = "error";
			// 	$$->setTypeSpecifier(type);
			// 	} else if(($1->getIsArray() && $1->getIsArrayWithoutIndex()) || ($3->getIsArray() && $3->getIsArrayWithoutIndex())) {
			// 		fprintf(errorout, "Line# %d: Array without index in '%s' operation  \n", $2->getStartLine(), $2->getName().c_str());
			// 		syntaxErrorCount++;
			// 		$$->setTypeSpecifier("error");
			// 	} else {
			// 		$$->setTypeSpecifier(castType($1,$3));
			// 		if($$->getTypeSpecifier() == "error") {
			// 			fprintf(errorout, "Line# %d: Incompatible types in expression\n", $2->getStartLine());
			// 			syntaxErrorCount++;
			// 		} else {
			// 			if($2->getName() == "%" && $$->getTypeSpecifier() != "INT") {
			// 				fprintf(errorout, "Line# %d: Operands of modulus must be integers \n", $2->getStartLine());
			// 				syntaxErrorCount++;
			// 				$$->setTypeSpecifier("error");
			// 		} else if($$->getIsFromConstant() && (($2->getName() == "%" || $2->getName() == "/") && (($3->getConstantIntValue() == "0") || ($3->getConstantFloatValue() == "0.0")))) {
			// 				fprintf(errorout, "Line# %d: Warning: division by zero \n", $2->getStartLine());
			// 				syntaxErrorCount++;
			// 				$$->setTypeSpecifier("error");
			// 			} 
			// 		}
			// 	}
			// } else {
			// 	$$->setTypeSpecifier("error");
			// }		

			writeIntoTempFile("; Line no " + to_string($1->getStartLine()));
			writeIntoTempFile("\tPOP BX");
			writeIntoTempFile("\tPOP AX");
			writeIntoTempFile("\tCWD");
			if($2->getName() == "*") {				
				writeIntoTempFile("\tMUL BX");
			} else if($2->getName() == "/") {
				writeIntoTempFile("\tDIV BX");
			} else {
				writeIntoTempFile("\tDIV BX");
				writeIntoTempFile("\tMOV AX, DX");   // remainder in dx
			}

			writeIntoTempFile("\tPUSH AX");
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

			writeIntoTempFile("; Line no " + to_string($1->getStartLine()));
			writeIntoTempFile("\tPOP AX");
			if($1->getName() == "-") {
				writeIntoTempFile("\tNEG AX");
			}
			writeIntoTempFile("\tPUSH AX");
		}
		 | NOT unary_expression {
			fprintf(logout,"unary_expression : NOT unary_expression \n");
			$$ = new SymbolInfo("NOT unary_expression", "unary_expression");
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($2->getEndLine());
			$$->addChild($1);
			$$->addChild($2);

			// if($2->getTypeSpecifier() != "error") {
			// 	if($2->getTypeSpecifier() != "INT") {
			// 	fprintf(errorout, "Line# %d: Operand of '!' is not an integer\n", $1->getStartLine());
			// 	syntaxErrorCount++;
			// 	$$->setTypeSpecifier("error");
			// 	} else {
			// 		$$->setTypeSpecifier("INT");
			// 	}
			// } else {
			// 	$$->setTypeSpecifier("error");
			// }

			if($2->getIsBoolean()) {
				writeIntoTempFile("; Line no " + to_string($1->getStartLine()) + " NOT operator");
				$$->setIsBoolean(true);
				$$->setTrueList($2->getFalseList());
				$$->setFalseList($2->getTrueList());
			} else {
				string label1 = "L" + to_string(++labelCount);
				string label2 = "L" + to_string(++labelCount);
				string jumpLabel = "L" + to_string(++labelCount);

				writeIntoTempFile("; Line no " + to_string($1->getStartLine()) + " NOT operator");
				writeIntoTempFile("\tPOP AX");
				writeIntoTempFile("\tCMP AX, 0");
				writeIntoTempFile("\tJNE " + label1);  // result non-zero, so make it zero
				writeIntoTempFile("\tJMP " + label2);

				writeIntoTempFile(label1 + ":");
				writeIntoTempFile("\tMOV AX, 0");
				writeIntoTempFile("\tJMP " + jumpLabel);

				writeIntoTempFile(label2 + ":");
				writeIntoTempFile("\tMOV AX, 1");

				writeIntoTempFile(jumpLabel + ":");
				writeIntoTempFile("\tPUSH AX"); 
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

			$$->setIsBoolean($1->getIsBoolean());
  			$$->setTrueList($1->getTrueList());
  			$$->setFalseList($1->getFalseList());
  			$$->setNextList($1->getNextList());

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

			string varName = getVarRightSide($1);

			writeIntoTempFile("\tMOV AX, " + varName);
			writeIntoTempFile("\tPUSH AX");
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

			writeIntoTempFile("\tCALL " + $1->getName());
			writeIntoTempFile("\tPUSH AX");
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

			$$->setIsBoolean($2->getIsBoolean());
  			$$->setTrueList($2->getTrueList());
  			$$->setFalseList($2->getFalseList());
  			$$->setNextList($2->getNextList());
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

			writeIntoTempFile("\tMOV AX, " + $1->getName());
			writeIntoTempFile("\tPUSH AX");
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

			string varName = getVarRightSide($1);

			writeIntoTempFile("; Line no " + to_string($1->getStartLine()));
			writeIntoTempFile("\tMOV AX, " + varName);
			writeIntoTempFile("\tPUSH AX");
			writeIntoTempFile("\tINC AX");
			writeIntoTempFile("\tMOV " + varName + ", AX");

			// fprintf(tempout, "\tMOV AX, %s\n\tPUSH AX\n\tINC AX\n\tMOV %s, AX\n\tPOP AX\n", $1->getVarName().c_str(), $1->getVarName().c_str());
			
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
			
			string varName = getVarRightSide($1);

			writeIntoTempFile("; Line no " + to_string($1->getStartLine()));
			writeIntoTempFile("\tMOV AX, " + varName);
			writeIntoTempFile("\tPUSH AX");
			writeIntoTempFile("\tDEC AX");
			writeIntoTempFile("\tMOV " + varName + ", AX");
			// fprintf(tempout, "\tMOV AX, %s\n\tPUSH AX\n\tDEC AX\n\tMOV %s, AX\n\tPOP AX\n", $1->getVarName().c_str(), $1->getVarName().c_str());
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

	int funcParamOffset = 4 + (parameterList.size() - 1) * 2; // starts with [BP +4]

	for(int i=0;i<parameterList.size();i++){
		string name = parameterList[i];
		string type = parameterTypeList[i];

		bool inserted = st.insert(name, type);
		
		if( !inserted ){
			fprintf(errorout, "Line# %d: Redefinition of parameter '%s'\n", $1->getStartLine(), name.c_str());
			syntaxErrorCount++;
			break;
		} else {
			SymbolInfo *look = st.lookUp(name);
			look->setTypeSpecifier(type);
			cout << "Hello " << isFunctionBeingDefined << endl;
			if(isFunctionBeingDefined){
				look->setIsParameter(true);				
				look->setStackOffset(funcParamOffset);
				funcParamOffset -= 2;
				funcParameterCount++;
			}
			
		}
	}

	isFunctionBeingDefined = false; // there may be different nested if and loop blocks
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

	codeout = fopen("1905002_code.asm","w");
	tempout = fopen("1905002_tempCode.txt","w");
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
	fclose(codeout);
	fclose(tempout);

	ifstream temp; 
	ofstream code;
	
	temp.open("1905002_tempCode.txt");
	code.open("1905002_code.asm", ios::app);
		
	// append temp.txt to code.txt
	string line;
  	int currentLineNo = 0;
  	while (getline(temp, line)) {
		currentLineNo++;
		code << line << labelMap[currentLineNo-1] << endl;
  	}

	code << printFunctionsFromSir << endl;
	// setting the global variable to NULL
	compRef = NULL;
	return 0;
}

