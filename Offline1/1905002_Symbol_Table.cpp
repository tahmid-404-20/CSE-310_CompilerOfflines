#include <string.h>
#include<iostream>
#include<bits/stdc++.h>

#include "1905002_Scope_Table.cpp"

using namespace std;

class SymbolTable{
    unsigned int bucket_size;
    unsigned int table_count;
    ScopeTable* current;

public:
// Constructors
    SymbolTable(unsigned int bucket_size) {
        this->bucket_size = bucket_size;
        // construct the root Scope Table
        this->table_count = 1;
        current = new ScopeTable(bucket_size, table_count);
        table_count++;
    }

// destructor
    ~SymbolTable() {
        ScopeTable* temp = current;
        while(temp) {
            ScopeTable* parent = temp->getParentScope();
            delete temp;
            temp = parent;
        }
    }

    void enterScope() {
        ScopeTable* new_table = new ScopeTable(bucket_size,table_count,current);
        current = new_table;
        cout << "\tScopeTable# " << current->getId() << " created" << endl;

        table_count++;
    }

    bool exitScope() {
        ScopeTable* parent = current->getParentScope();
        if(!parent) {               // don't allow to get out of the root scope
            cout << "\tScopeTable# " << current->getId() << " cannot be removed" << endl;
            return false;
        } else {
            delete current;
            current = parent;
            return true;
        }
    }

    bool insert(string name, string type) {
        return current->insert(name, type);
    }

    bool remove(string name) {
        return current->dlt(name);
    }

    SymbolInfo* lookUp(string name) {
        ScopeTable* temp = current;

        while(temp) {
            SymbolInfo* found = temp->lookUp(name);
            if(!found) {
                temp = temp->getParentScope();
            } else {
                return found;
            }
        }

        cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;
        // 'j' not found in any of the ScopeTables
        return NULL;
    }

    void printCurrentScopeTable() {
        current->print();
    }

    void printAllScopeTable() {
        ScopeTable* temp = current;
        while(temp) {
            temp->print();
            temp = temp->getParentScope();
        }
    }
};

void printMismatchMessage(string str) {
    cout << "\tNumber of parameters mismatch for the command " << str << endl;
}

class ProcessLine{
    string str;
    int lastWordEndingIndex;

    public:
        ProcessLine(string str) {
            this->str = str;
            lastWordEndingIndex = 0;
        }
        
        string getNextWord() {
            unsigned int i = lastWordEndingIndex;

            // this loop avoids the space(s)
            for(;i<str.size();) {
                if(str[i] == ' ' || str[i] == '\n') 
                    i++;
                else
                    break;
            }

            unsigned int j = i;
            for(; str[j] != ' ' && str[j] != '\r' && str[j] != '\n' && (j < str.size()); j++);

            lastWordEndingIndex = j;
            return str.substr(i,j-i);
        }

        unsigned int noOfWords() {
            unsigned int n = 0;
            bool newWord = false;
            for(int i=0;i<str.size(); i++) {
                if(str[i] != ' ' && !newWord) {
                    newWord = true;
                    n++;
                } else if(str[i] == ' ' && newWord) {
                    newWord = false;
                }
            }

            return n;
        }        
};

int main() {  
    
    // i/o redirection
    ifstream cin("sample_input.txt");
    ofstream cout("output.txt");

    // optional performance optimizations    
    ios_base::sync_with_stdio(false);
    std::cin.tie(0);

    std::cin.rdbuf(cin.rdbuf());
    std::cout.rdbuf(cout.rdbuf());
    
    // "program" starts here
    unsigned int n;
    cin >> n;
    
    unsigned long long nCmd = 0;
    
    SymbolTable* t = new SymbolTable(n);
    cout << "\tScopeTable# 1 created" << endl;

    string str;
    char nl;
    while(getline(cin, str)) {
        if(str!="" && str!="\r") { // not blank line
            // if you want to process the line, do it here
            ProcessLine* line = new ProcessLine(str);
            // end of processing

            unsigned int nWords = line->noOfWords();
            string command = line->getNextWord();
            nCmd++;

            if(command == "I") {
                if(nWords != 3) {
                    cout << "Cmd " << nCmd << ": " << str << endl;
                    printMismatchMessage(command);
                } else {
                    string arg1 = line->getNextWord();
                    string arg2 = line->getNextWord();
                    cout << "Cmd " << nCmd << ": " << command << " " << arg1 << " " << arg2 << endl;
                    t->insert(arg1,arg2);
                }
            } else if(command == "L") {
                if(nWords != 2) {
                    cout << "Cmd " << nCmd << ": " << str << endl;
                    printMismatchMessage(command);
                } else {
                    string arg1 = line->getNextWord();
                    cout << "Cmd " << nCmd << ": " << command << " " << arg1 << endl;
                    t->lookUp(arg1);
                }
            } else if(command == "D") {
                if(nWords != 2) {
                    cout << "Cmd " << nCmd << ": " << str << endl;
                    printMismatchMessage(command);
                } else {
                    string arg1 = line->getNextWord();
                    cout << "Cmd " << nCmd << ": " << command << " " << arg1 << endl;
                    t->remove(arg1);
                }
            } else if(command == "P") {
                if(nWords != 2) {
                    cout << "Cmd " << nCmd << ": " << str << endl;
                    printMismatchMessage(command);
                } else {
                    string arg1 = line->getNextWord();
                    cout << "Cmd " << nCmd << ": " << command << " " << arg1 << endl;
                    if(arg1 == "A") {
                        t->printAllScopeTable();
                    } else if(arg1 == "C") {
                        t->printCurrentScopeTable();
                    } else {
                        cout << "Invalid command" << endl;
                    }
                }
            } else if(command == "S") {
                if(nWords != 1) {
                    cout << "Cmd " << nCmd << ": " << str << endl;
                    printMismatchMessage(command);
                } else {
                    cout << "Cmd " << nCmd << ": " << command << endl;
                    t->enterScope();
                }
            } else if(command == "E") {
                if(nWords != 1) {
                    cout << "Cmd " << nCmd << ": " << str << endl;
                    printMismatchMessage(command);
                } else {
                    cout << "Cmd " << nCmd << ": " << command << endl;
                    t->exitScope();
                }
            } else if(command == "Q") {
                if(nWords != 1) {
                    cout << "Cmd " << nCmd << ": " << str << endl;
                    printMismatchMessage(command);
                } else {
                    cout << "Cmd " << nCmd << ": " << str << endl;
                    delete t;
                    t = NULL;
                    delete line;
                    break;
                }
            } else {
                cout << "No command matches "  <<  str << endl;
            }

            delete line;
        }
    }

    if(!t) {
        delete t;
    }

    return 0;
}