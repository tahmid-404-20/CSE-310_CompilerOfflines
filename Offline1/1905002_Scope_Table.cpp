#include<bits/stdc++.h>

using namespace std;

class SymbolInfo{
    string name;
    string type;
    SymbolInfo* next;

public:
// constructor
    SymbolInfo(string name, string type) {
        this->name = name;
        this->type = type;
        this->next = NULL;
    }

    SymbolInfo() {
        this->next = NULL;
    }

// destructor
    ~SymbolInfo() {
        this->next = NULL;
    }

// getters
    const string& getName() {
        return name;
    }

    const string& getType() {
        return type;
    }

    SymbolInfo* getNext() {
        return next;
    }

// setters
    void setName(const string& name) {
        this->name = name;    
    }
    void setType(const string& type) {
        this->type = type;
    }

    void setNext(SymbolInfo* next) {
        this->next = next;
    }
};

class ScopeTable{
    SymbolInfo** a;
    unsigned int num_buckets;
    unsigned int id;
    ScopeTable* parent_scope;

public:
// constructor
    ScopeTable(int num_buckets, unsigned int id) {
        this->num_buckets = num_buckets;
        this->id = id;

        a = new SymbolInfo*[this->num_buckets];
        for(unsigned int i=0;i<num_buckets;i++) {
            a[i] = NULL;
        }

        parent_scope = NULL;
    } 

    ScopeTable(int num_buckets, unsigned int id, ScopeTable* parent_scope) {
        this->num_buckets = num_buckets;
        this->id = id;

        a = new SymbolInfo*[this->num_buckets];
        for(unsigned int i=0;i<num_buckets;i++) {
            a[i] = NULL;
        }

        this->parent_scope = parent_scope;
    } 

// destructor
    ~ScopeTable() {
        for(unsigned int i=0;i<num_buckets;i++) {
            SymbolInfo* curr = a[i];
            SymbolInfo* prev = curr;
            
            while(curr) {
                prev = curr;
                curr = curr->getNext();
                delete prev;
            }
            a[i] = NULL;
        }

        delete[] a;
        cout << "\tScopeTable# " << id << " removed" << endl;
    }

// getters
    ScopeTable* getParentScope() {
        return this->parent_scope;
    }
    
    unsigned int getId() {
        return id;
    }
// setters
    void setParentScope(ScopeTable* parent) {
        this->parent_scope = parent;
    }

// public functions
    SymbolInfo* lookUp(string name) {
        unsigned int index = SDBMHash(name);

        unsigned int pos = 1;
        SymbolInfo* p = a[index];
        while(p) {
            if(p->getName() != name) {
                p = p->getNext();
                pos++;
            } else {
                cout << "\t'" << name << "' found in ScopeTable# " << id << " at position " << (index+1) << ", " << pos << endl;
                return p;
            }            
        }

        return NULL;
    }

    bool insert(string name, string type) {        
       
        unsigned int index = SDBMHash(name);
        
        // for clumsy output
        int pos = 1;
        SymbolInfo* prev;
        SymbolInfo* curr;
        prev = curr = a[index];
        while(curr) {
            if(curr->getName() != name) {
                prev = curr;
                curr = curr->getNext();
                pos++;
            } else {
                cout << "\t'" << name << "' already exists in the current ScopeTable" << endl;
                return false;
            }                   
        }

        SymbolInfo* obj = new SymbolInfo(name,type);
        if(!prev) {
            a[index] = obj;
        } else {
            prev->setNext(obj);
        }
            
        cout << "\tInserted in ScopeTable# " << id <<  " at position " << (index+1) << ", " << pos << endl;
        return true;
    }

    bool dlt(string name) {
        unsigned int index = SDBMHash(name);
        SymbolInfo* curr;
        SymbolInfo* prev;

        curr = prev = a[index];
        unsigned int pos = 1;
        while(curr) {
            if(curr->getName() == name) {
                if(a[index] == curr) {
                    a[index] = curr->getNext();
                    delete curr;
                    cout << "\tDeleted '" << name << "' from ScopeTable# "<< id << " at position " << (index+1) << ", " << pos << endl;
                    return true;
                }

                prev->setNext(curr->getNext());
                delete curr;
                cout << "\tDeleted '" << name << "' from ScopeTable# "<< id << " at position " << (index+1) << ", " << pos << endl;
                return true;               
            }
            
            prev = curr;
            curr = curr->getNext();
            pos++;
        }

        cout << "\tNot found in the current ScopeTable" << endl;
        return false;
    }

    void print() {
        cout << "\tScopeTable# " << id << endl;
        for(unsigned int i=0;i<num_buckets;i++) {
            cout << "\t" << (i+1) << "--> ";

            SymbolInfo* curr = a[i];
            
            while(curr) {
                cout << "<" << curr->getName() << "," << curr->getType() << "> ";
                curr = curr->getNext();
            }
            cout << endl;
        }
    }

private:
    unsigned int SDBMHash(string str) {
        unsigned int hash = 0;
        unsigned int len = str.length();

        for (unsigned int i = 0; i < len; i++)
        {
            hash = ((str[i]) + (hash << 6) + (hash << 16) - hash) % num_buckets;
        }

        return hash;
    }

};