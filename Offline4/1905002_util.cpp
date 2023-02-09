#pragma once
#include "1905002_SymbolInfo.cpp"
#include "bits/stdc++.h"

using namespace std;

class GlobalVarDetails {
  string name;
  bool isArray;
  int arraySize;

public:
  GlobalVarDetails(string name, bool isArray = false, int arraySize = 0) {
    this->name = name;
    this->isArray = isArray;
    this->arraySize = arraySize;
  }

  string getName() { return name; }

  bool getIsArray() { return isArray; }

  int getArraySize() { return arraySize; }
};
