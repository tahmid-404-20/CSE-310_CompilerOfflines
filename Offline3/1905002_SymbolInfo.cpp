#pragma once
#include "bits/stdc++.h"

extern FILE *logout;

using namespace std;

class SymbolInfo {
  string name;
  string type;
  bool isLeaf;
  bool isArray;
  bool isFunction;
  bool isFunctionDeclared;
  bool isFromConstant;
  bool isArrayWithoutIndex;
  string constantIntValue;
  string constantFloatValue;
  string type_specifier;

  unsigned long long start_line;
  unsigned long long end_line;

  // variable declaration
  vector<string> name_list;
  vector<bool> is_array;

  // function declaration
  vector<string> parameter_list;
  vector<string> parameter_type_list;

  // for function call arrayChecking
  vector<bool> argument_is_arrayList;
  vector<bool> argument_is_arrayWithoutIndex;

  vector<SymbolInfo *> childList;
  // vector<SymbolInfo *> declarationList;

  SymbolInfo *next;

  void setFlags() {
    this->isLeaf = false;
    this->isArray = false;
    this->isFunction = false;
    this->isFunctionDeclared = false;
    this->isFromConstant = false;
    this->isArrayWithoutIndex = false;
    this->next = NULL;
  }

public:
  // constructor
  SymbolInfo(string name, string type) {
    this->name = name;
    this->type = type;
    setFlags();
  }

  SymbolInfo(char *name, char *type) {
    string n(name);
    string t(type);
    this->name = n;
    this->type = t;
    setFlags();
  }

  SymbolInfo(char *n, char *t, char *ts) {
    string name(n);
    string type(t);
    string type_specifier(ts);

    this->name = name;
    this->type = type;
    this->type_specifier = type_specifier;
    setFlags();
  }

  SymbolInfo() { this->next = NULL; }

  // destructor
  ~SymbolInfo() {
    this->next = NULL;
    // free childList
    // for (int i = 0; i < childList.size(); i++) {
    //   // if (childList[i] != NULL)
    //   delete childList[i];
    // }

    childList.clear();
  }

  // some adders
  void addDeclaration(string name, bool isArray) {
    name_list.push_back(name);
    is_array.push_back(isArray);
  }

  // for function declaration & definition
  void addParameter(const string name, const string type) {
    parameter_list.push_back(name);
    parameter_type_list.push_back(type);
  }

  // for argument passing
  void addParameterType(const string type) {
    parameter_type_list.push_back(type);
  }

  void addChild(SymbolInfo *child) { childList.push_back(child); }

  // getters
  const string &getName() { return name; }
  const string &getType() { return type; }
  const string &getTypeSpecifier() { return type_specifier; }
  const string &getConstantIntValue() { return constantIntValue; }
  const string &getConstantFloatValue() { return constantFloatValue; }

  // flag getters
  bool getIsFunctionDeclared() { return isFunctionDeclared; }
  bool getIsFromConstant() { return isFromConstant; }
  bool getIsArray() { return isArray; }
  bool getIsFunction() { return isFunction; }
  bool getIsLeaf() { return isLeaf; }
  bool getIsArrayWithoutIndex() { return isArrayWithoutIndex; }

  unsigned long long getEndLine() { return end_line; }
  unsigned long long getStartLine() { return start_line; }
  SymbolInfo *getNext() { return next; }

  vector<string> &getDeclarations() { return name_list; }
  vector<bool> &getIsArrayList() { return is_array; }

  vector<string> &getParameterList() { return parameter_list; }
  vector<string> &getParameterTypeList() { return parameter_type_list; }
  vector<bool> &getParameterIsArrayList() {
    return argument_is_arrayList;
  } // just to save space

  // argument passing
  vector<bool> &getArgumentIsArrayList() { return argument_is_arrayList; }
  vector<bool> &getArgumentIsArrayWithoutIndexList() {
    return argument_is_arrayWithoutIndex;
  }

  vector<SymbolInfo *> &getChildList() { return childList; }
  // vector<SymbolInfo *> &getDeclarationList() { return declarationList; }
  // end of getters here

  // setters
  void setName(const string &name) { this->name = name; }
  void setType(const string &type) { this->type = type; }
  void setTypeSpecifier(const string &type_specifier) {
    this->type_specifier = type_specifier;
  }
  void setTypeSpecifier(const char *type_specifier) {
    string t(type_specifier);
    this->type_specifier = t;
  }

  // flag setters
  void setIsLeaf(bool isLeaf) { this->isLeaf = isLeaf; }
  void setIsArray(bool isArray) { this->isArray = isArray; }
  void setIsFunction(bool isFunction) { this->isFunction = isFunction; }
  void setIsFromConstant(bool isFromConstant) {
    this->isFromConstant = isFromConstant;
  }
  void setIsFunctionDeclared(bool isFunctionDeclared) {
    this->isFunctionDeclared = isFunctionDeclared;
  }
  void setIsArrayWithoutIndex(bool isArrayWithoutIndex) {
    this->isArrayWithoutIndex = isArrayWithoutIndex;
  }

  // constant setters
  void setConstantIntValue(const string &constantIntValue) {
    this->constantIntValue = constantIntValue;
  }
  void setConstantFloatValue(const string &constantFloatValue) {
    this->constantFloatValue = constantFloatValue;
  }

  // line number for syntax tree
  void setEndLine(unsigned long long end_line) { this->end_line = end_line; }
  void setStartLine(unsigned long long start_line) {
    this->start_line = start_line;
  }

  // variable declaration
  void setDeclarationList(vector<string> &name_list) {
    this->name_list = name_list;
  }
  void setIsArrayList(vector<bool> &is_array) { this->is_array = is_array; }

  // function declaration
  void setParameters(vector<string> &parameter_list,
                     vector<string> &parameter_type_list) {
    this->parameter_list = parameter_list;
    this->parameter_type_list = parameter_type_list;
  }

  // argument passing
  void setParameterTypeList(vector<string> &parameter_type_list) {
    this->parameter_type_list = parameter_type_list;
  }
  // void setArgumentIsArrayList(vector<bool> &argument_is_arrayList) {
  //   this->argument_is_arrayList = argument_is_arrayList;
  // }
  // void setArgumentIsArrayWithoutIndexList(
  //     vector<bool> &argument_is_arrayWithoutIndex) {
  //   this->argument_is_arrayWithoutIndex = argument_is_arrayWithoutIndex;
  // }
  // void setArguments(vector<string> &parameter_type_list,
  //                   vector<bool> &argument_is_arrayList,
  //                   vector<bool> &argument_is_arrayWithoutIndex) {
  //   setParameterTypeList(parameter_type_list);
  //   setArgumentIsArrayList(argument_is_arrayList);
  //   setArgumentIsArrayWithoutIndexList(argument_is_arrayWithoutIndex);
  // }

  // required for function definition when goes to new scope, only use for the
  // global variable
  void clearParameters() {
    parameter_list.clear();
    parameter_type_list.clear();
    argument_is_arrayList.clear();
  }

  void setNext(SymbolInfo *next) { this->next = next; }
};