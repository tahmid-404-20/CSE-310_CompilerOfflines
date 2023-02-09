#pragma once
#include "1905002_SymbolInfo.cpp"
#include "bits/stdc++.h"

using namespace std;

void printSpaces(FILE *fout, unsigned long n) {
  for (unsigned long i = 0; i < n; i++) {
    fprintf(fout, " ");
  }
}

void printSymbolInfo(FILE *fout, SymbolInfo *s, unsigned long depth) {
  printSpaces(fout, depth);
  if (s->getIsLeaf()) {
    fprintf(fout, "%s : %s\t<Line: %llu>\n", s->getType().c_str(),
            s->getName().c_str(), s->getStartLine());
  } else {
    fprintf(fout, "%s : %s \t<Line: %llu-%llu>\n", s->getType().c_str(),
            s->getName().c_str(), s->getStartLine(), s->getEndLine());
  }
}

void printSyntaxTree(FILE *fout, SymbolInfo *s, unsigned long depth) {
  if (s == NULL) {
    return;
  }

  printSymbolInfo(fout, s, depth);

  if (!s->getIsLeaf()) {
    for (auto child : s->getChildList()) {
      printSyntaxTree(fout, child, depth + 1);
    }
  }
}

void clearMemSyntaxTree(SymbolInfo *s) {
  if (s == NULL) {
    return;
  }

  if (!s->getIsLeaf()) {
    for (auto child : s->getChildList()) {
      clearMemSyntaxTree(child);
    }
  }
  s->getChildList().clear();
  delete s;
  s = NULL;
}