#include <stdio.h>
#include <stdlib.h>

typedef struct avl{
    long unsigned int capacity;   
    long unsigned int load;
    struct avl* sad;
    struct avl* sag;
    int eq;
    int id;    //Id of the station
}Avl;

int max(int a,int b, int c);

int min(int a,int b, int c);

Avl* create_tree(int id,long unsigned int load,long unsigned int capacity);

Avl* leftrotation(Avl* tree);

Avl* rightrotation(Avl* tree);

Avl* double_leftrotaion(Avl* tree);

Avl* double_rightrotaion(Avl* tree);

Avl* balance(Avl* tree);

Avl* insert_Avl(Avl* tree, int id, long unsigned int load, long unsigned int capacity,int* eq);

void show(Avl* tree);

void Avl_free(Avl* tree);

Avl* add_line(Avl* tree, FILE* fp);

void Avlwriting(FILE* fp,Avl* tree);

int programm();