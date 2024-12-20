#include "main.h"


Avl* create_tree(int id,long unsigned int load,long unsigned int capacity){
    /*Create a tree and return it's address*/
    Avl* temp=NULL;

    temp = malloc(sizeof(Avl));

    if(temp==NULL){
        exit(51); //malloc didn't work
    }

    temp->id=id;
    temp->load=load;
    temp->capacity=capacity;
    temp->eq=0;
    temp->sad=NULL;
    temp->sag=NULL;

    return temp;
}

Avl* leftrotation(Avl* tree){
    /*Make an avl left rotation and return the avl tree, if tree is NULL return tree*/
    Avl* pivot;
    int eq_tree=0,eq_p=0;
    
    if (tree != NULL){
        pivot=tree->sad;
        tree->sad=pivot->sag;
        pivot->sag=tree;    //faire attention
        eq_tree=tree->eq;
        eq_p=pivot->eq;

        tree->eq=eq_tree-max(eq_p,0,0)-1;
        pivot->eq=min(eq_tree-2,eq_tree+eq_p-2,eq_p-1);
        tree=pivot;
    }

    return tree;
}

Avl* rightrotation(Avl* tree){
    /*Make an avl right rotation and return the avl tree, if tree is NULL return tree*/
    Avl* pivot;
    int eq_tree=0,eq_p=0;

    if (tree != NULL){
        pivot=tree->sag;
        tree->sag=pivot->sad;
        pivot->sad=tree;
        eq_tree=tree->eq;
        eq_p=pivot->eq;

        tree->eq=eq_tree-min(eq_p,0,0)+1;
        pivot->eq=max(eq_tree+2,eq_tree+eq_p+2,eq_p+1);
        tree=pivot;
    }

    return tree;
}

Avl* double_leftrotaion(Avl* tree){
    /*Make an avl double left rotation and return the avl tree, if tree is NULL return tree*/
    if (tree != NULL){
        tree->sad=rightrotation(tree->sad);
    }
    return leftrotation(tree);
}

Avl* double_rightrotaion(Avl* tree){
    /*Make an avl double right rotation and return the avl tree, if tree is NULL return tree*/
    if (tree != NULL){
        tree->sag=leftrotation(tree->sag);
    }
    return rightrotation(tree);
}

Avl* balance(Avl* tree){
    /*Balance an Avl tree*/
    if (tree == NULL){
        return tree;
    }

    if(tree->eq>=2){
        if(tree->sad->eq>=0){
            return leftrotation(tree);
        }
        else{
            return double_leftrotaion(tree);
        }
    }
    else if(tree->eq<=-2){
        if(tree->sag->eq<=0){
            return rightrotation(tree);
        }
        else{
            return double_rightrotaion(tree);
        }
    }

    return tree;
}

Avl* insert_Avl(Avl* tree, int id, long unsigned int load, long unsigned int capacity,int* eq){
    /*A function that add a node with id ,load and cpacity to the avl tree*/
    if(tree==NULL){
        *eq=1;
        return create_tree(id,load,capacity);
    }
    else if(tree->id==id){
        tree->capacity+=capacity;
        tree->load+=load;

        return tree;
    }
    else if(id<tree->id){
        tree->sag=insert_Avl(tree->sag,id,load,capacity,eq);
        *eq=-*eq;
    }
    else if(id>tree->id){
        tree->sad=insert_Avl(tree->sad,id,load,capacity,eq);
    }
    else{
        *eq=0;
        return tree;
    }
    if(*eq!=0){ //this section of the code is changing the equiliber of the tree
       tree->eq=tree->eq+*eq;
        tree=balance(tree);
        if(tree->eq==0){
            *eq=0;
        }
        else{
            *eq=1;
        }
    }   
    return tree;
}

void show(Avl* tree){
    /*Show the Avl tree put into parameter in your command prompt, isn't used in the programm*/
    if(tree!=NULL){
        printf("id :%d\n capcity : %lu , load : %lu \n eq : %d \n",tree->id,tree->capacity,tree->load,tree->eq);
        show(tree->sag);
        show(tree->sad);
    }
}

void Avl_free(Avl* tree){
    /*A recursive function that free all the Avl in parameter*/
    if(tree!=NULL){
        tree->eq = 0;
        tree->id = 0;
        tree->capacity = 0;
        tree->load = 0;

        Avl_free(tree->sag);
        Avl_free(tree->sad);

        tree->sad = NULL;
        tree->sag = NULL;

        free(tree);
    }
}
