#pragma once
#include "1905002_SymbolInfo.cpp"
#include "bits/stdc++.h"
#define BUCKETSIZE 11

using std::string;

extern FILE *logout;

using namespace std;

class ScopeTable {
  SymbolInfo **a;
  unsigned int num_buckets;
  unsigned int id;
  ScopeTable *parent_scope;

public:
  // constructor
  ScopeTable(int num_buckets, unsigned int id) {
    this->num_buckets = num_buckets;
    this->id = id;

    a = new SymbolInfo *[this->num_buckets];
    for (unsigned int i = 0; i < num_buckets; i++) {
      a[i] = NULL;
    }

    parent_scope = NULL;
  }

  ScopeTable(int num_buckets, unsigned int id, ScopeTable *parent_scope) {
    this->num_buckets = num_buckets;
    this->id = id;

    a = new SymbolInfo *[this->num_buckets];
    for (unsigned int i = 0; i < num_buckets; i++) {
      a[i] = NULL;
    }

    this->parent_scope = parent_scope;
  }

  // destructor
  ~ScopeTable() {
    for (unsigned int i = 0; i < num_buckets; i++) {
      SymbolInfo *curr = a[i];
      SymbolInfo *prev = curr;

      while (curr) {
        prev = curr;
        curr = curr->getNext();
        delete prev;
      }
      a[i] = NULL;
    }

    delete[] a;
  }

  // getters
  ScopeTable *getParentScope() { return this->parent_scope; }

  unsigned int getId() { return id; }
  // setters
  void setParentScope(ScopeTable *parent) { this->parent_scope = parent; }

  // public functions
  SymbolInfo *lookUp(string name) {
    unsigned long long index = SDBMHash(name) % (unsigned long long)num_buckets;

    unsigned int pos = 1;
    SymbolInfo *p = a[index];
    while (p) {
      if (p->getName() != name) {
        p = p->getNext();
        pos++;
      } else {
        return p;
      }
    }

    return NULL;
  }

  bool insert(string name, string type) {

    unsigned long long index = SDBMHash(name) % (unsigned long long)num_buckets;

    // for clumsy output
    int pos = 1;
    SymbolInfo *prev;
    SymbolInfo *curr;
    prev = curr = a[index];
    while (curr) {
      if (curr->getName() != name) {
        prev = curr;
        curr = curr->getNext();
        pos++;
      } else {
        return false;
      }
    }

    SymbolInfo *obj = new SymbolInfo(name, type);
    if (!prev) {
      a[index] = obj;
    } else {
      prev->setNext(obj);
    }
    return true;
  }

  bool dlt(string name) {
    unsigned long long index = SDBMHash(name) % (unsigned long long)num_buckets;
    SymbolInfo *curr;
    SymbolInfo *prev;

    curr = prev = a[index];
    unsigned int pos = 1;
    while (curr) {
      if (curr->getName() == name) {
        if (a[index] == curr) {
          a[index] = curr->getNext();
          delete curr;
          return true;
        }

        prev->setNext(curr->getNext());
        delete curr;
        return true;
      }

      prev = curr;
      curr = curr->getNext();
      pos++;
    }
    return false;
  }

  void print(FILE *logout) {
    fprintf(logout, "\tScopeTable# %d\n", id);
    for (unsigned int i = 0; i < num_buckets; i++) {
      SymbolInfo *curr = a[i];

      if (curr) {
        fprintf(logout, "\t%d--> ", (i + 1));
        while (curr) {
          if (curr->getIsFunction()) {
            fprintf(logout, "<%s, FUNCTION, %s> ", curr->getName().c_str(),
                    curr->getTypeSpecifier().c_str());
          } else if (curr->getIsArray()) {
            fprintf(logout, "<%s, ARRAY, %s> ", curr->getName().c_str(),
                    curr->getTypeSpecifier().c_str());
          } else {
            fprintf(logout, "<%s, %s> ", curr->getName().c_str(),
                    curr->getTypeSpecifier().c_str());
          }

          curr = curr->getNext();
        }
        fprintf(logout, "\n");
      }
    }
  }

private:
  unsigned long long SDBMHash(string str) {
    unsigned long long hash = 0;
    unsigned long long len = str.length();

    for (unsigned int i = 0; i < len; i++) {
      hash = ((str[i]) + (hash << 6) + (hash << 16) - hash);
    }

    return hash;
  }
};

class SymbolTable {
  unsigned int bucket_size;
  unsigned int table_count;
  ScopeTable *current;

public:
  // Constructors
  SymbolTable(unsigned int bucket_size) {
    this->bucket_size = bucket_size;
    // construct the root Scope Table
    this->table_count = 1;
    current = new ScopeTable(bucket_size, table_count);
    table_count++;
  }

  SymbolTable() {
    this->bucket_size = BUCKETSIZE;
    // construct the root Scope Table
    this->table_count = 1;
    current = new ScopeTable(this->bucket_size, table_count);
    table_count++;
  }

  // destructor
  ~SymbolTable() {
    ScopeTable *temp = current;
    while (temp) {
      ScopeTable *parent = temp->getParentScope();
      delete temp;
      temp = parent;
    }
  }

  void enterScope() {
    ScopeTable *new_table = new ScopeTable(bucket_size, table_count, current);
    current = new_table;
    table_count++;
  }

  bool exitScope() {
    ScopeTable *parent = current->getParentScope();
    if (!parent) { // don't allow to get out of the root scope
      return false;
    } else {
      delete current;
      current = parent;
      return true;
    }
  }

  bool insert(string name, string type) { return current->insert(name, type); }

  bool remove(string name) { return current->dlt(name); }

  SymbolInfo *lookUp(string name) {
    ScopeTable *temp = current;

    while (temp) {
      SymbolInfo *found = temp->lookUp(name);
      if (!found) {
        temp = temp->getParentScope();
      } else {
        return found;
      }
    }
    // 'j' not found in any of the ScopeTables
    return NULL;
  }

  void printCurrentScopeTable(FILE *logout) { current->print(logout); }

  void printAllScopeTable(FILE *logout) {
    ScopeTable *temp = current;
    while (temp) {
      temp->print(logout);
      temp = temp->getParentScope();
    }
  }
};